Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78D2D6B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 11:50:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so95220131lfg.2
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 08:50:27 -0700 (PDT)
Received: from mail.sig21.net (mail.sig21.net. [80.244.240.74])
        by mx.google.com with ESMTPS id d75si2552816wma.12.2016.06.25.08.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Jun 2016 08:50:26 -0700 (PDT)
Date: Sat, 25 Jun 2016 17:50:06 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
Message-ID: <20160625155006.GA4166@sig21.net>
References: <20160616212641.GA3308@sig21.net>
 <c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
 <20160623091830.GA32535@sig21.net>
 <201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

On Thu, Jun 23, 2016 at 08:26:35PM +0900, Tetsuo Handa wrote:
> 
> Since you think you saw OOM messages with the older kernels, I assume that the OOM
> killer was invoked on your 4.6.2 kernel. The OOM reaper in Linux 4.6 and Linux 4.7
> will not help if the OOM killed process was between down_write(&mm->mmap_sem) and
> up_write(&mm->mmap_sem).
> 
> I was not able to confirm whether the OOM killed process (I guess it was java)
> was holding mm->mmap_sem for write, for /proc/sys/kernel/hung_task_warnings
> dropped to 0 before traces of java threads are printed or console became
> unusable due to the "delayed: kcryptd_crypt, ..." line. Anyway, I think that
> kmallocwd will report it.
> 
> > > It is sad that we haven't merged kmallocwd which will report
> > > which memory allocations are stalling
> > >  ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).
> > 
> > Would you like me to try it?  It wouldn't prevent the hang, though,
> > just print better debug ouptut to serial console, right?
> > Or would it OOM kill some process?
> 
> Yes, but for bisection purpose, please try commit 78ebc2f7146156f4 without
> applying kmallocwd. If that commit helps avoiding flood of the allocation
> failure warnings, we can consider backporting it. If that commit does not
> help, I think you are reporting a new location which we should not use
> memory reserves.
> 
> kmallocwd will not OOM kill some process. kmallocwd will not prevent the hang.
> kmallocwd just prints information of threads which are stalling inside memory
> allocation request.

First I tried today's git, linux-4.7-rc4-187-g086e3eb, and
the good news is that the oom killer seems to work very
well and reliably killed the offending task (java).
It happened a few times, the AOSP build broke and I restarted
it until it completed.  E.g.:

[ 2083.604374] Purging GPU memory, 0 pages freed, 4508 pages still pinned.
[ 2083.611000] 96 and 0 pages still available in the bound and unbound GPU page lists.
[ 2083.618815] make invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[ 2083.629257] make cpuset=/ mems_allowed=0
...
[ 2084.688753] Out of memory: Kill process 10431 (java) score 378 or sacrifice child
[ 2084.696593] Killed process 10431 (java) total-vm:5200964kB, anon-rss:2521764kB, file-rss:0kB, shmem-rss:0kB
[ 2084.938058] oom_reaper: reaped process 10431 (java), now anon-rss:0kB, file-rss:8kB, shmem-rss:0kB

Next I tried 4.6.2 with 78ebc2f7146156f4, then with kmallocwd (needed one manual fixup),
then both patches.  It still livelocked in all cases, the log spew looked
a bit different with 78ebc2f7146156f4 applied but still continued
endlessly.  kmallocwd alone didn't trigger, with both patches
applied kmallocwd triggered but:

[  363.815595] MemAlloc-Info: stalling=33 dying=0 exiting=42 victim=0 oom_count=0
[  363.815601] MemAlloc: kworker/0:0(4) flags=0x4208860 switches=212 seq=1 gfp=0x26012c0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOTRACK) order=0 delay=17984
** 1402 printk messages dropped ** [  363.818816]  [<ffffffff8116d519>] __do_page_cache_readahead+0x144/0x29d
** 501 printk messages dropped **

I'll zip up the logs and send them off-list.


Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
