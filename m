Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAEF6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:56:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z128so48686232pfb.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 04:56:08 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id o2si9219747pga.26.2017.01.12.04.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 04:56:07 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 127so3503594pfg.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 04:56:07 -0800 (PST)
Date: Thu, 12 Jan 2017 21:55:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: shrink_inactive_list() failed to reclaim pages
Message-ID: <20170112125538.GA424@tigerII.localdomain>
References: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
 <20170111173802.GK16365@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111173802.GK16365@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Cheng-yu Lee <cylee@google.com>, linux-mm@kvack.org, Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>

Hello,

On (01/11/17 18:38), Michal Hocko wrote:
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

hm. as a side note, I think this is not the first time I see
"kswapd consumes 100% cpu" report.

https://bugzilla.kernel.org/show_bug.cgi?id=65201#c50

http://lkml.iu.edu//hypermail/linux/kernel/1601.2/03564.html

https://marc.info/?l=linux-mm&m=145442159521487

https://marc.info/?l=linux-mm&m=145443027124595

	-ss

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
> > 
> > An alternative is to patch the kernel to call shrink_active_list() more
> > frequently when it finds there's nothing that can be reclaimed . But I am
> > not sure if it's the right direction. Also it's not so trivial to figure
> > out where to add the call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
