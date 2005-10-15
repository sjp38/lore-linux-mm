Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j9F3Z7I6027219
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 21:35:07 -0600
Subject: Re: Another Clock-pro approx
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <1129275512.7845.47.camel@twins>
References: <434EA6E8.30603@programming.kicks-ass.net>
	 <1129272286.3637.186.camel@moon.c3.lanl.gov>
	 <1129275512.7845.47.camel@twins>
Content-Type: text/plain
Message-Id: <1129347305.3637.310.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Fri, 14 Oct 2005 21:35:05 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter,

Two obvious issues in the actions are 
(1) test bits have never been set; 
(2) pages in T3 have never been promoted into T1/T2.

I might have to take the responsibility for all
the confusion in the understanding of why clock-pro
works. (e.g. clock-pro can deal with access-once, loop
accesses effectively).  I should have put a pseudo code
in the clock-pro paper.  However, even with a pseudo
code, the description of clock-pro would seem much more
complicated than the idea behind it actually is. To
get its idea without being bothered by all the details
involved in the clock-pro description, my suggestion
is that let's base our discussion/design on the original
LIRS algorithm.   
(see section 3 of the following paper
http://www.cs.wm.edu/hpcs/WWW/HTML/publications/papers/TR-05-11.pdf)

In the context of the LIRS algorithm, compare to clock-pro,

cold <--> HIR 
hot <--> LIR

HAND_hot --> bottom of the LIRS stack (= last resident hot
page). This is the most critical position in the stack,
which serves as a criterion of hot/cold.  A reference
to a page above it (if the stack is vertically viewed)
makes the page a hot one, otherwise, the page remains as
a cold one. This is also the place where a hot page is
demoted to a cold one.


HAND-cold --> last resident cold page (== bottom of stack
Q) where a victim page is going to be searched.

If we allow an unlimited number of non-resident stay in
the stack, there is no need for a HAND_test. Actually
HAND_hot serves the purpose.  If we have a limit on that
(say the memory size c), then the HAND-test points to the
last non-resident cold page or last hot page, whichever
is higher.

The idea behind LIRS is very simple: the last hot page is the
one least deserving to reside in memory (ignoring the
small number of resident cold pages here). If you have
a reference above it (in the stack), then you are more
deserving to get in (as a hot one), and the last hot one
gets out (as a cold one). Otherwise, no h/c states change.

A major difference between LIRS and Clock-pro is that
clock-pro delays the actions on references (except page
faults). Taking this difference into reading clock-pro 
description, you can easily unravel all the tricks played 
in it.

The conclusion is that it is essential for clock-pro
to allow the location comparison in a single list between
(non-resident) cold page and the last hot page, so that
we know which cold page should be promoted into
a hot page with a reference. If we use HAND_test, we must
make sure HAND_test stays above HAND_hot.

If we use separate lists for h/c pages (like active/inactive
lists), we lose the chance for the comparison, and major 
performance advantages of clock-pro are lost.  Actually 
CAR/CART have been shown in the aforementioned paper 
not be able to deal with loop access problem of LRU, 
and that is the reason.

It is fine to have a common non-resident page pool for 
the zoned memory, if we can also set their corresponding
place-holders in a single list for each zone.

Let me know if the single list suggestion is feasible
in the Linux kernel. 

Thanks. 

Song


 



On Fri, 2005-10-14 at 01:38, Peter Zijlstra wrote:
> On Fri, 2005-10-14 at 00:44 -0600, Song Jiang wrote:
> > Hi, Peter,
> > 
> >     I didn't see your explanation of the actions such as T2-000.
> > So I put my understanding at the below. 
> 
> My bad, I keep forgetting to write half the stuff down, often the most
> important pieces appear missing ;-(
> 
> As I told Rik yesterday on IRC, the main idea behind it was to make T1 +
> T2 behave like 1 big SC-list and superimpose T3 thereon by coupling the
> rotation speed. And thus creating 1 virtual wheel as clock-pro has. The
> split in T1 and T2 acts as the hot hand and determines the length of the
> test period.
> 
> |T1| + |T2| <= c
> |T1| + |T2| + |T3| <= 2c
> 
> Resident:
> T1 can contain pages marked as both hot and cold.
> T2 can only contain cold pages.
> 
> Non-resident:
> T3 can only contain non-resident cold pages in their test period.
> 
> The actions presented like Tn-abc are to be read as: place page on the
> head of list Tn with the hot/cold bit set to a, the test bit set to b
> and the referenced bit set to c.
> 
> > While setting three lists, do you indicate that a page 
> > can have 3 set of pointers, each for the links in one list?
> 
> No, a page can only be on 1 list at a time.
> 
> > If we don't restrict ourselves to the current active and inactive
> > list data structure, can you point to us what major approximations
> > we have to make on the original clock-pro policy so that the policy 
> > becomes acceptable in the kernel? (I understand that zoned data
> > structure is one of the required adaptations.) The reason I'm asking 
> > the question is that I didn't see some major changes here in your
> > approxiamtion? Once I understand the kernel required adaptations, 
> > I can work with you for a clock-pro approximation.
> 
> Yes the zoned data structure is the most difficult. It gives rise to the
> fact that we have to split the resident from the non-resident page
> management. Each zone will have a resident part and all zones will share
> the non-resident part. This because a page leaving zone 1 could be
> faulted back in zone 2.
> 
> Another is that the pageout operation is async, ie. we start writeback
> against a page but until it is finished the page has to stay on the
> resident lists but as soon as writeback finishes and we have not yet had
> another reference we need to reclaim the page asap.
> 
> The last one, and I'm not quite sure on this one (Rik?), is that when we
> insert a page we're sure it is going to be referenced right after the
> context switch to userspace. Hence we effectively insert referenced
> pages.
> 
> Rik, any things missing here?
> 
> > I have a clock-pro simulator in C code and powerpoint presentation 
> > slides explaining clock-pro operations. If you are interested in
> > any of them, let me know.
> > 
> > Thanks.
> > 
> >    Song
> > 
> >  
> > 
> > On Thu, 2005-10-13 at 12:26, Peter Zijlstra wrote:
> > > Hi,
> > > 
> > > I've been thinking on another clock-pro approximation.
> > > 
> > > Each page has 3 bits: hot/cold, test and referenced.
> > > Say we have 3 lists: T1, T2 and T3.
> > > and variable: s
> > > 
> > > T1 will have hot and cold pages, T2 will only have cold pages and T3
> > > will have the non-resident pages.
> > > c will be the total number of resident pages; |T1| + |T2| + |T3| = 2c.
> >                                                 Do you mean |T1 U T2 U
> > T3| = 2c ?
> 
> See above.
> 
> New and improved actions:
> 
> > > T1-rotation:
> > > 
> > > h/c   test   ref       action
> > >  0      0     0        T2-000   page is passed on to T2
> > >  0      0     1        T2-001   page is passed on to T2
> > >  0      1     0        T2-000   page to T2, clear test bit
> > >  0      1     1        T1-100   make it hot
> > >  1      0     0        T2-010   turn into cold page, start test period
> > >  1      0     1        T1-100   keep it hot, clear ref bit
> > >  1      1     0        <cannot happen>
> > >  1      1     1        <cannot happen>
> > > 
> > > 
> > > T2-rotation:
> > > 
> > > h/c   test   ref       action
> > >  0      0     0        <remove page from list>
> > >  0      0     1        T1-000  keep it cold, keep it resident.
> > >  0      1     0        T3-010  make it non-resident
> > >  0      1     1        T1-100  make it hot
> > > 
> > > 
> > > T3-rotation: remove from non-resident list.
> 
> A fault will check the non-resident list and also remove the page if
> found.
> 
> > > So, on fault we rotate T2, unless empty then we start by rotating T1
> > > until T2 contains at least 1 cold page.
> > > If a T2 rotation creates a hot page, we rotate T1 to degrade a hot
> > > page to a cold page in order to keep the cold page target m_c.
> > > Every T1 rotation adds |T1| to s. While s > c, we subtract c from s and
> 
> >        Does |T1| mean the total size if T1? 
> 
> Yes, |T1| is the size of T1. 
> 
> > Can you explain why in more
> > detail?
> > 
> 
> This because the hot hand pushes the test hand.
> 
> Hmmm, maybe it should not be every T1 rotation, but only rotations on
> hot pages that get accounted. Because at that point the hot page with
> the largest inter reference period will disappear and the test period
> changes.
> 
> So the idea is to couple to rotation speed of T3 to T1 and scale the
> respective sizes. 
> 
> > > turn T3 for each subtraction.
> > > 
> > > Compare to clock-pro:
> > >   T1-rotation <-> Hand_hot
> > >   T2-rotation <-> Hand_cold
> > >   T3-rotation <-> Hand_test
> > > 
> > > The normal m_c adaption rules can be applied.
> > > 
> > > Zoned edition:
> > > This can be done per zone by having:
> > > T1_i, T2_i, T3_j, s, t, u_j
> > > where _i is the zone index and _j the non-resident bucket index.
> > > 
> > > Then each T1_i turn will add |T1_i| to s, each c in s will increment t by 1.
> > > On each non-resident bucket access we increment u_j until it equals t
> > > and for each increment we rotate the bucket.
> > > 
> 
> More thoughts, it should probably be: u_j = t/J. Where J is the total
> number of buckets.
> 
> 
> Kind regards,
> 
> Peter Zijlstra
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
