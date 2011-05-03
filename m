Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 441576B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 23:51:17 -0400 (EDT)
Date: Tue, 3 May 2011 11:51:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110503035112.GA10906@localhost>
References: <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
 <20110502102945.GA7688@localhost>
 <BANLkTinXnhh5V0eH71=6PxZWpQxvti7QVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinXnhh5V0eH71=6PxZWpQxvti7QVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, "Li, Shaohua" <shaohua.li@intel.com>, Hugh Dickins <hughd@google.com>

Hi Minchan,

On Tue, May 03, 2011 at 08:49:20AM +0800, Minchan Kim wrote:
> Hi Wu, Sorry for slow response.
> I guess you know why I am slow. :)

Yeah, never mind :)

> Unfortunately, my patch doesn't consider order-0 pages, as you mentioned below.
> I read your mail which states it doesn't help although it considers
> order-0 pages and drain.
> Actually, I tried to look into that but in my poor system(core2duo, 2G
> ram), nr_alloc_fail never happens. :(

I'm running a 4-core 8-thread CPU with 3G ram.

Did you run with this patch?

[PATCH] mm: readahead page allocations are OK to fail
https://lkml.org/lkml/2011/4/26/129

It's very good at generating lots of __GFP_NORETRY order-0 page
allocation requests.

> I will try it in other desktop but I am not sure I can reproduce it.
> 
> >
> > root@fat /home/wfg# ./test-dd-sparse.sh
> > start time: 246
> > total time: 531
> > nr_alloc_fail 14097
> > allocstall 1578332
> > LOC:     542698     538947     536986     567118     552114     539605     541201     537623   Local timer interrupts
> > RES:       3368       1908       1474       1476       2809       1602       1500       1509   Rescheduling interrupts
> > CAL:     223844     224198     224268     224436     223952     224056     223700     223743   Function call interrupts
> > TLB:        381         27         22         19         96        404        111         67   TLB shootdowns
> >
> > root@fat /home/wfg# getdelays -dip `pidof dd`
> > print delayacct stats ON
> > printing IO accounting
> > PID     5202
> >
> >
> > CPU             count     real total  virtual total    delay total
> >                 1132     3635447328     3627947550   276722091605
> > IO              count    delay total  delay average
> >                    2      187809974             62ms
> > SWAP            count    delay total  delay average
> >                    0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                 1334    35304580824             26ms
> > dd: read=278528, write=0, cancelled_write=0
> >
> > I guess your patch is mainly fixing the high order allocations while
> > my workload is mainly order 0 readahead page allocations. There are
> > 1000 forks, however the "start time: 246" seems to indicate that the
> > order-1 reclaim latency is not improved.
> 
> Maybe, 8K * 1000 isn't big footprint so I think reclaim doesn't happen.

It's mainly a guess. In an earlier experiment of simply increasing
nr_to_reclaim to high_wmark_pages() without any other constraints, it
does manage to reduce start time to about 25 seconds.

> > I'll try modifying your patch and see how it works out. The obvious
> > change is to apply it to the order-0 case. Hope this won't create much
> > more isolated pages.
> >
> > Attached is your patch rebased to 2.6.39-rc3, after resolving some
> > merge conflicts and fixing a trivial NULL pointer bug.
> 
> Thanks!
> I would like to see detail with it in my system if I can reproduce it.

OK.

> >> > no cond_resched():
> >>
> >> What's this?
> >
> > I tried a modified patch that also removes the cond_resched() call in
> > __alloc_pages_direct_reclaim(), between try_to_free_pages() and
> > get_page_from_freelist(). It seems not helping noticeably.
> >
> > It looks safe to remove that cond_resched() as we already have such
> > calls in shrink_page_list().
> 
> I tried similar thing but Andrew have a concern about it.
> https://lkml.org/lkml/2011/3/24/138

Yeah cond_resched() is at least not the root cause of our problems..

> >> > +                     if (total_scanned > 2 * sc->nr_to_reclaim)
> >> > +                             goto out;
> >>
> >> If there are lots of dirty pages in LRU?
> >> If there are lots of unevictable pages in LRU?
> >> If there are lots of mapped page in LRU but may_unmap = 0 cases?
> >> I means it's rather risky early conclusion.
> >
> > That test means to avoid scanning too much on __GFP_NORETRY direct
> > reclaims. My assumption for __GFP_NORETRY is, it should fail fast when
> > the LRU pages seem hard to reclaim. And the problem in the 1000 dd
> > case is, it's all easy to reclaim LRU pages but __GFP_NORETRY still
> > fails from time to time, with lots of IPIs that may hurt large
> > machines a lot.
> 
> I don't have  enough time and a environment to test it.
> So I can't make sure of it but my concern is a latency.
> If you solve latency problem considering CPU scaling, I won't oppose it. :)

OK, let's head for that direction :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
