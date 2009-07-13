Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D95EE6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 20:18:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D0bqVr014287
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 09:37:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4454745DE5A
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:37:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00CA545DE52
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:37:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6232E08001
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:37:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78DC9E08003
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:37:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 2/2] Don't continue reclaim if the system have plenty  free memory
In-Reply-To: <28c262360907090358q7cdbd067y22b7312c489e7598@mail.gmail.com>
References: <20090709140234.239F.A69D9226@jp.fujitsu.com> <28c262360907090358q7cdbd067y22b7312c489e7598@mail.gmail.com>
Message-Id: <20090713092428.6249.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 09:37:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 9, 2009 at 2:08 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Hi, Kosaki.
> >>
> >> On Tue, Jul 7, 2009 at 6:48 PM, KOSAKI
> >> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > Subject: [PATCH] Don't continue reclaim if the system have plenty free memory
> >> >
> >> > On concurrent reclaim situation, if one reclaimer makes OOM, maybe other
> >> > reclaimer can stop reclaim because OOM killer makes enough free memory.
> >> >
> >> > But current kernel doesn't have its logic. Then, we can face following accidental
> >> > 2nd OOM scenario.
> >> >
> >> > 1. System memory is used by only one big process.
> >> > 2. memory shortage occur and concurrent reclaim start.
> >> > 3. One reclaimer makes OOM and OOM killer kill above big process.
> >> > 4. Almost reclaimable page will be freed.
> >> > 5. Another reclaimer can't find any reclaimable page because those pages are
> >> > ? already freed.
> >> > 6. Then, system makes accidental and unnecessary 2nd OOM killer.
> >> >
> >>
> >> Did you see the this situation ?
> >> Why I ask is that we have already a routine for preventing parallel
> >> OOM killing in __alloc_pages_may_oom.
> >>
> >> Couldn't it protect your scenario ?
> >
> > Can you please see actual code of this patch?
> 
> I mean follow as,
> 
> static inline struct page *
> __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>         struct zonelist *zonelist, enum zone_type high_zoneidx,
> ...
> <snip>
> 
>         /*
>          * Go through the zonelist yet one more time, keep very high watermark
>          * here, this is only to catch a parallel oom killing, we must fail if
>          * we're still under heavy pressure.
>          */
>         page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
>                 order, zonelist, high_zoneidx,
>                 ALLOC_WMARK_HIGH|ALLOC_CPUSET,
>                 preferred_zone, migratetype);

Thanks, I catch your point.
Yes, the issue explained my description only happen old distro kernel.
I haven't notice this issue was already fixed. very thanks.

but above fix doesn't make sense. it mean
 - concurrent reclaim can drop too many usable memory
 - but only gurantee it doesn't cause oom

Then, I'll fix my patch description.



> > Those two patches fix different problem.
> >
> > 1/2 fixes the issue of that concurrent direct reclaimer makes
> > too many isolated pages.
> > 2/2 fixes the issue of that reclaim and exit race makes accidental oom.
> >
> >
> >> If it can't, Could you explain the scenario in more detail ?
> >
> > __alloc_pages_may_oom() check don't effect the threads of already
> > entered reclaim. it's obvious.
> 
> Threads which are entered into direct reclaim mode will call
> __alloc_pages_may_oom before out_of_memory.
> At that time, if one big process is killed a while ago,
> get_page_from_freelist in __alloc_pages_may_oom will be succeeded at
> last. So I think it doesn't occur OOM.
> 
> But in that case, we suffered from unnecessary page scanning per each
> priority(12~0). So in this case, your patch is good to me. then you
> would be better to change log. :)






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
