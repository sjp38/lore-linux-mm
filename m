Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5846B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:38:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l2so29405224wml.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:38:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z21si4920923wrz.204.2017.01.11.09.38.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 09:38:06 -0800 (PST)
Date: Wed, 11 Jan 2017 18:38:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: shrink_inactive_list() failed to reclaim pages
Message-ID: <20170111173802.GK16365@dhcp22.suse.cz>
References: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cheng-yu Lee <cylee@google.com>
Cc: linux-mm@kvack.org, Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>

[CC Minchan and Sergey for the zram part]

On Thu 12-01-17 01:16:11, Cheng-yu Lee wrote:
> Hi community,
> 
> I have a x86_64 Chromebook running 3.14 kernel with 8G of memory. Using

Do you see the same with the current Linus tree?

> zram with swap size set to ~12GB. When in low memory, kswapd is awaken to
> reclaim pages, but under some circumstances the kernel can not find pages
> to reclaim while I'm sure there're still plenty of memory which could be
> reclaimed from background processes (For example, I run some C programs
> which just malloc() lots of memory and get suspended in the background.
> There's no reason they could't be swapped). The consequence is that most of
> CPU time is spent on page reclamation. The system hangs or becomes very
> laggy for a long period. Sometimes it even triggers a kernel panic by the
> hung task detector like:
> <0>[46246.676366] Kernel panic - not syncing: hung_task: blocked tasks
> 
> I've added kernel message to trace the problem. I found shrink_inactive_list()
> can barely find any page to reclaim. More precisely, when the problem
> happens, lots of page have _count > 2 in __remove_mapping(). So the
> condition at line 662 of vmscan.c holds:
> http://lxr.free-electrons.com/source/mm/vmscan.c#L662
> Thus the kernel fails to reclaim those pages at line 1209
> http://lxr.free-electrons.com/source/mm/vmscan.c#L1209

I assume that you are talking about the anonymous LRU

> It's weird that the inactive anonymous list is huge (several GB), but
> nothing can really be freed. So I did some hack to see if moving more pages
> from the active list helps. I commented out the "inactive_list_is_low()"
> checking at line 2420
> in shrink_node_memcg() so shrink_active_list() is always called.
> http://lxr.free-electrons.com/source/mm/vmscan.c#L2420
> It turns out that the hack helps. If moving more pages from the active
> list, kswapd works smoothly. The whole 12G zram can be used up before
> system enters OOM condition.
> 
> Any idea why the whole inactive anonymous LRU is occupied by pages which
> can not be freed for la long time (several minutes before system dies) ?
> Are there any parameters I can tune to help the situation ? I've tried
> swappiness but it doesn't help.
> 
> An alternative is to patch the kernel to call shrink_active_list() more
> frequently when it finds there's nothing that can be reclaimed . But I am
> not sure if it's the right direction. Also it's not so trivial to figure
> out where to add the call.
> 
> Thanks,
> Cheng-Yu

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
