Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j9E6imfP007484
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 00:44:48 -0600
Subject: Re: Another Clock-pro approx
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <434EA6E8.30603@programming.kicks-ass.net>
References: <434EA6E8.30603@programming.kicks-ass.net>
Content-Type: text/plain
Message-Id: <1129272286.3637.186.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Fri, 14 Oct 2005 00:44:46 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Peter,

    I didn't see your explanation of the actions such as T2-000.
So I put my understanding at the below. 

While setting three lists, do you indicate that a page 
can have 3 set of pointers, each for the links in one list?

If we don't restrict ourselves to the current active and inactive
list data structure, can you point to us what major approximations
we have to make on the original clock-pro policy so that the policy 
becomes acceptable in the kernel? (I understand that zoned data
structure is one of the required adaptations.) The reason I'm asking 
the question is that I didn't see some major changes here in your
approxiamtion? Once I understand the kernel required adaptations, 
I can work with you for a clock-pro approximation.

I have a clock-pro simulator in C code and powerpoint presentation 
slides explaining clock-pro operations. If you are interested in
any of them, let me know.

Thanks.

   Song

 
 
On Thu, 2005-10-13 at 12:26, Peter Zijlstra wrote:
> Hi,
> 
> I've been thinking on another clock-pro approximation.
> 
> Each page has 3 bits: hot/cold, test and referenced.
> Say we have 3 lists: T1, T2 and T3.
> and variable: s
> 
> T1 will have hot and cold pages, T2 will only have cold pages and T3
> will have the non-resident pages.
> c will be the total number of resident pages; |T1| + |T2| + |T3| = 2c.
                                                Do you mean |T1 U T2 U
T3| = 2c ?

> 
> 
> T1-rotation:
> 
> h/c   test   ref          action
>  0         0       0                T2-000  the page leaves T1, T2, and T3     
>  0         0       1                T2-001   the page must be resident, do nothing          
>  0       1       0           T2-000           test bit is cleared. if it is non-resident, it leaves T3
>  0       1       1           T1-100           test bit is cleared
>  1       0       0           T2-001           turn into cold page
>  1       0       1           T1-100           ref bit is cleared
>  1       1       0           <cannot happen>
>  1       1       1           <cannot happen>
> 
> 
> T2-rotation:
> 
> h/c   test   ref          action
>  0         0       0           <remove page from list> the pages leaves T1, T2 and T3
>  0         0        1              T1-000  this page must be resident, free the page, the page leaves T1, T2, and T3   
>  0         1        0              T3-010  if the page is resident, free the page, place it in T3. Otherwise, do nothing 
>  0         1        1              T1-100   the page must be resident, move the page to T1, rotate T1 to a hot page into a cold one  
> 
> 
> T3-rotation: frees up non-resident slots
> 
> So, on fault we rotate T2, unless empty then we start by rotating T1
> until T2 contains at least 1 cold page.
> If a T2 rotation creates a hot page, we rotate T1 to degrade a hot
> page to a cold page in order to keep the cold page target m_c.
> Every T1 rotation adds |T1| to s. While s > c, we subtract c from s and
       Does |T1| mean the total size if T1? Can you explain why in more
detail?

> turn T3 for each subtraction.
> 
> Compare to clock-pro:
>   T1-rotation <-> Hand_hot
>   T2-rotation <-> Hand_cold
>   T3-rotation <-> Hand_test
> 
> The normal m_c adaption rules can be applied.
> 
> Zoned edition:
> This can be done per zone by having:
> T1_i, T2_i, T3_j, s, t, u_j
> where _i is the zone index and _j the non-resident bucket index.
> 
> Then each T1_i turn will add |T1_i| to s, each c in s will increment t by 1.
> On each non-resident bucket access we increment u_j until it equals t
> and for each increment we rotate the bucket.
> 
> 
> 
> Kind regards,
> 
> Peter Zijlstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
