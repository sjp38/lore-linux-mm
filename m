Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j9G5YT3I022126
	for <linux-mm@kvack.org>; Sat, 15 Oct 2005 23:34:30 -0600
Subject: Re: Another Clock-pro approx
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <1129349427.7845.117.camel@twins>
References: <434EA6E8.30603@programming.kicks-ass.net>
	 <1129272286.3637.186.camel@moon.c3.lanl.gov>
	 <1129275512.7845.47.camel@twins>
	 <1129347305.3637.310.camel@moon.c3.lanl.gov>
	 <1129349427.7845.117.camel@twins>
Content-Type: text/plain
Message-Id: <1129440868.3637.492.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Sat, 15 Oct 2005 23:34:28 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-14 at 22:10, Peter Zijlstra wrote:
> On Fri, 2005-10-14 at 21:35 -0600, Song Jiang wrote:
> > Peter,
> > 
> > Two obvious issues in the actions are 
> > (1) test bits have never been set; 
> > (2) pages in T3 have never been promoted into T1/T2.
> 
> Drad, more missing information:
> On fault the new page is searched for in T3, if present T1-100 otherwise
> T1-010.
> 

I am interested in rethinking the mechanism of clock-pro under your 
3-digit code abstraction. 

I put my comments in pairs of brackets.

(Please confirm: all T1 and T2 pages are resident.)


T1-rotation:

h/c   test   ref          action
 0       0       0           T2-000 
 0       0       1           T2-001 

 0       1       0           T2-000 
 0       1       1           T1-100
 1       0       0           T2-001 [T1-010 because I don't see why 
 we can artificially give it a ref. But we can give it a second
chance to test its next reuse in T1]
                               
 1       0       1           T1-100
 1       1       0           <cannot happen>
 1       1       1           <cannot happen>


T2-rotation:

h/c   test   ref          action
 0       0       0           <remove page from list>
 0       0       1           T1-000  [T1-010 to test its next reuse]

 0       1       0           T3-010 
 0       1       1           T1-100


T3-rotation: 
    present:       T1-100
    not present:  T1-010


My obsevations: 

(1) The test bits of all T1 cold pages are 1 
(test bit is irrelevant to hot pages),
because once a T1 page with test bit 1 has its
test bit cleared, it either leaves T1 or
becomes a hot page.
So that in T1-rotation, the cases of 000, 001 
cannot happen.

(2)  The test bits of all T2 cold pages are 0,
because all T2 pages are from T1, and there are 
no T1 actions generating a test bit.
So that in T2-rotation, the cases of 010, 011 
cannot happen.

(3) The test bits of all T3 pages are designed
to be 1. (I will keep thinking how to really 
achieve the design goal).

Considering the above, there is no need to
explictly use a test bit.


> > 
> > 
> > HAND-cold --> last resident cold page (== bottom of stack
> > Q) where a victim page is going to be searched.
> 
> Do you imply here that HAND-cold pushes HAND-hot? If so, then it is

   HAND-hot pushes HAND-test, but not necessarily HAND-cold,
because a cold page that is turned from a hot page can stay 
below the HAND-hot in the LIRS stack.

> possible to write this 2-hand clock as 2 lists, where the top one will
> always push its tail into the head of the botton, and the botton will
> puth into the head of the top one on reference.
> This is exactly what I have done.

I have no issue with this.

> > If we use separate lists for h/c pages (like active/inactive
> > lists), we lose the chance for the comparison, and major 
> > performance advantages of clock-pro are lost.  
> 
> Neither my proposal nor CART have h/c separarted lists. CARTs T1 list
> can contain both hot and cold pages as can mine.
> 
My fault in expressing. I actually mean multiple lists,
not necessarily hot and cold pages have to be in seperate 
lists. To effectively set the test bits, I wonder we might 
have to put non-resident pages with resident pages
in the same list. But I will keep thinking how to 
make them seperate without compromising the role
of test period.   


> > Actually 
> > CAR/CART have been shown in the aforementioned paper 
> > not be able to deal with loop access problem of LRU, 
> > and that is the reason.
> 
> I fixed that:
>   http://programming.kicks-ass.net/kernel-patches/cart/cart-cart-r.patch

That is nice.


> > 
> > Let me know if the single list suggestion is feasible
> > in the Linux kernel. 
> 
> Single list should not be a problem. However I still have some trouble
> with placing the page meta-data of non-resident pages on those lists.
> 
    We should have a way out on this.

Song


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
