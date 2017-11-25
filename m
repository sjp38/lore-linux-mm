Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9D006B025F
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 06:07:34 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r70so30722122ioi.2
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 03:07:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j124si10006039ite.59.2017.11.25.03.07.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Nov 2017 03:07:33 -0800 (PST)
Subject: Re: [PATCH] mm,page_alloc: Use min watermark for last second allocation attempt.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510915081-3768-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171120093851.gs3zqpmmyacxplor@dhcp22.suse.cz>
In-Reply-To: <20171120093851.gs3zqpmmyacxplor@dhcp22.suse.cz>
Message-Id: <201711252007.HDF15235.SFQOMHLFOVtFJO@I-love.SAKURA.ne.jp>
Date: Sat, 25 Nov 2017 20:07:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

Michal Hocko wrote:
> On Fri 17-11-17 19:38:01, Tetsuo Handa wrote:
> [...]
> > [ 1792.835056] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
> > [ 1792.836073] Killed process 14458 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
> 
> Wen you are in a situation when you are killing 88kB process then you
> are most probably going to suffer more oom kills anyway. Optimizing for
> this case is thus questionable at best. You would need to come up with
> a reasonable explanation why the livelock as described by Andrea is not
> possible with the current MM reclaim retry implementation. I am not
> saying the patch is wrong but your justification _is_ wrong.

What I wanted you to check is the fact that there was about 1.5 seconds of time
window and free: was 948KB above min: watermark (which is  larger than 88KB) and
total free was 1560KB above min: (which means that making free memory was in progress
rather than suffer more OOM kills).

[ 1792.835056] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
[ 1792.836073] Killed process 14458 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[ 1792.837757] oom_reaper: reaped process 14458 (normal-priority), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 1794.366070] systemd-journal invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
(...snipped...)
[ 1794.366295] Normal free:18448kB min:17500kB low:21872kB high:26244kB active_anon:650740kB inactive_anon:18976kB active_file:220kB inactive_file:436kB unevictable:0kB writepending:0kB present:1048576kB managed:966968kB mlocked:0kB kernel_stack:19568kB pagetables:36132kB bounce:0kB free_pcp:2736kB local_pcp:680kB free_cma:0kB
(...snipped...)
[ 1794.366342] Normal: 557*4kB (UM) 476*8kB (UMH) 126*16kB (UMH) 84*32kB (UM) 16*64kB (UM) 9*128kB (UM) 4*256kB (UM) 4*512kB (UM) 3*1024kB (M) 0*2048kB 0*4096kB = 19060kB
(...snipped...)
[ 1794.366368] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
[ 1794.367372] Killed process 14459 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[ 1794.369143] oom_reaper: reaped process 14459 (normal-priority), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

But since I can't find better justification for this patch, I decided to send remaining
patches first: http://lkml.kernel.org/r/1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
