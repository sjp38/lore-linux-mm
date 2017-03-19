Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 538926B038A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 11:18:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so12127123wmg.7
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 08:18:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h132si11301225wmf.127.2017.03.19.08.18.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 08:18:43 -0700 (PDT)
Date: Sun, 19 Mar 2017 11:18:38 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170319151837.GD12414@dhcp22.suse.cz>
References: <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 17-03-17 21:08:31, Gerhard Wiesinger wrote:
> On 17.03.2017 18:13, Michal Hocko wrote:
> >On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
> >[...]
> >>Why does the kernel prefer to swapin/out and not use
> >>
> >>a.) the free memory?
> >It will use all the free memory up to min watermark which is set up
> >based on min_free_kbytes.
> 
> Makes sense, how is /proc/sys/vm/min_free_kbytes default value calculated?

See init_per_zone_wmark_min

> >>b.) the buffer/cache?
> >the memory reclaim is strongly biased towards page cache and we try to
> >avoid swapout as much as possible (see get_scan_count).
> 
> If I understand it correctly, swapping is preferred over dropping the
> cache, right. Can this behaviour be changed to prefer dropping the
> cache to some minimum amount?  Is this also configurable in a way?

No, we enforce swapping if the amount of free + file pages are below the
cumulative high watermark.

> (As far as I remember e.g. kernel 2.4 dropped the caches well).
> 
> >>There is ~100M memory available but kernel swaps all the time ...
> >>
> >>Any ideas?
> >>
> >>Kernel: 4.9.14-200.fc25.x86_64
> >>
> >>top - 17:33:43 up 28 min,  3 users,  load average: 3.58, 1.67, 0.89
> >>Tasks: 145 total,   4 running, 141 sleeping,   0 stopped,   0 zombie
> >>%Cpu(s): 19.1 us, 56.2 sy,  0.0 ni,  4.3 id, 13.4 wa, 2.0 hi,  0.3 si,  4.7
> >>st
> >>KiB Mem :   230076 total,    61508 free,   123472 used,    45096 buff/cache
> >>
> >>procs -----------memory---------- ---swap-- -----io---- -system--
> >>------cpu-----
> >>  r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy id wa st
> >>  3  5 303916  60372    328  43864 27828  200 41420   236 6984 11138 11 47  6 23 14
> >I am really surprised to see any reclaim at all. 26% of free memory
> >doesn't sound as if we should do a reclaim at all. Do you have an
> >unusual configuration of /proc/sys/vm/min_free_kbytes ? Or is there
> >anything running inside a memory cgroup with a small limit?
> 
> nothing special set regarding /proc/sys/vm/min_free_kbytes (default values),
> detailed config below. Regarding cgroups, none of I know. How to check (I
> guess nothing is set because cg* commands are not available)?

be careful because systemd started to use some controllers. You can
easily check cgroup mount points.

> /proc/sys/vm/min_free_kbytes
> 45056

So at least 45M will be kept reserved for the system. Your data
indicated you had more memory. How does /proc/zoneinfo look like?
Btw. you seem to be using fc kernel, are there any patches applied on
top of Linus tree? Could you try to retest vanilla kernel?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
