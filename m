Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFC076B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 00:33:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z128so26703128pfb.4
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 21:33:14 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h7si3756623plk.119.2017.01.11.21.33.13
        for <linux-mm@kvack.org>;
        Wed, 11 Jan 2017 21:33:13 -0800 (PST)
Date: Thu, 12 Jan 2017 14:33:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: shrink_inactive_list() failed to reclaim pages
Message-ID: <20170112053312.GB8387@bbox>
References: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
 <20170111173802.GK16365@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111173802.GK16365@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Cheng-yu Lee <cylee@google.com>, linux-mm@kvack.org, Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Thanks for Ccing me, Michal.

On Wed, Jan 11, 2017 at 06:38:02PM +0100, Michal Hocko wrote:
> [CC Minchan and Sergey for the zram part]
> 
> On Thu 12-01-17 01:16:11, Cheng-yu Lee wrote:
> > Hi community,
> > 
> > I have a x86_64 Chromebook running 3.14 kernel with 8G of memory. Using
> 
> Do you see the same with the current Linus tree?
> 
> > zram with swap size set to ~12GB. When in low memory, kswapd is awaken to
> > reclaim pages, but under some circumstances the kernel can not find pages
> > to reclaim while I'm sure there're still plenty of memory which could be
> > reclaimed from background processes (For example, I run some C programs
> > which just malloc() lots of memory and get suspended in the background.
> > There's no reason they could't be swapped). The consequence is that most of
> > CPU time is spent on page reclamation. The system hangs or becomes very
> > laggy for a long period. Sometimes it even triggers a kernel panic by the
> > hung task detector like:
> > <0>[46246.676366] Kernel panic - not syncing: hung_task: blocked tasks
> > 
> > I've added kernel message to trace the problem. I found shrink_inactive_list()
> > can barely find any page to reclaim. More precisely, when the problem
> > happens, lots of page have _count > 2 in __remove_mapping(). So the
> > condition at line 662 of vmscan.c holds:
> > http://lxr.free-electrons.com/source/mm/vmscan.c#L662
> > Thus the kernel fails to reclaim those pages at line 1209
> > http://lxr.free-electrons.com/source/mm/vmscan.c#L1209
> 
> I assume that you are talking about the anonymous LRU
> 
> > It's weird that the inactive anonymous list is huge (several GB), but
> > nothing can really be freed. So I did some hack to see if moving more pages
> > from the active list helps. I commented out the "inactive_list_is_low()"
> > checking at line 2420
> > in shrink_node_memcg() so shrink_active_list() is always called.
> > http://lxr.free-electrons.com/source/mm/vmscan.c#L2420
> > It turns out that the hack helps. If moving more pages from the active
> > list, kswapd works smoothly. The whole 12G zram can be used up before
> > system enters OOM condition.
> > 
> > Any idea why the whole inactive anonymous LRU is occupied by pages which
> > can not be freed for la long time (several minutes before system dies) ?
> > Are there any parameters I can tune to help the situation ? I've tried
> > swappiness but it doesn't help.

I've never heard such problem until now so my *imaginary* scenario is some
of driver or something in your system calls get_user_pages or friends to
grab a page reference count so that lots of anonymous pages are pinned.
With that, VM swapped it out but cannot free the page until someone releases
the refcount of the page.
On the situation, what VM can do it is to rotate the page back into inactive
LRU's head. It causes inactive list's size is never changed so that
inactive_anon_is_low always return false. It means VM cannot deactivate
reclaimable pages on active list to inactive's LRU so it ends up scanning
inactive anonymous LRU list fulled of pinned pages.

There would be several ways to solve but before that, I want to confirm
my random guess.

> > 
> > An alternative is to patch the kernel to call shrink_active_list() more
> > frequently when it finds there's nothing that can be reclaimed . But I am
> > not sure if it's the right direction. Also it's not so trivial to figure
> > out where to add the call.
> > 
> > Thanks,
> > Cheng-Yu
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
