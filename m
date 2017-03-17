Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4E56B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:13:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so14791879wrb.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:13:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si11924426wrv.297.2017.03.17.10.13.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 10:13:43 -0700 (PDT)
Date: Fri, 17 Mar 2017 18:13:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170317171339.GA23957@dhcp22.suse.cz>
References: <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
[...]
> Why does the kernel prefer to swapin/out and not use
> 
> a.) the free memory?

It will use all the free memory up to min watermark which is set up
based on min_free_kbytes.

> b.) the buffer/cache?

the memory reclaim is strongly biased towards page cache and we try to
avoid swapout as much as possible (see get_scan_count).
 
> There is ~100M memory available but kernel swaps all the time ...
> 
> Any ideas?
> 
> Kernel: 4.9.14-200.fc25.x86_64
> 
> top - 17:33:43 up 28 min,  3 users,  load average: 3.58, 1.67, 0.89
> Tasks: 145 total,   4 running, 141 sleeping,   0 stopped,   0 zombie
> %Cpu(s): 19.1 us, 56.2 sy,  0.0 ni,  4.3 id, 13.4 wa, 2.0 hi,  0.3 si,  4.7
> st
> KiB Mem :   230076 total,    61508 free,   123472 used,    45096 buff/cache
> 
> procs -----------memory---------- ---swap-- -----io---- -system--
> ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy id wa st
>  3  5 303916  60372    328  43864 27828  200 41420   236 6984 11138 11 47  6 23 14

I am really surprised to see any reclaim at all. 26% of free memory
doesn't sound as if we should do a reclaim at all. Do you have an
unusual configuration of /proc/sys/vm/min_free_kbytes ? Or is there
anything running inside a memory cgroup with a small limit?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
