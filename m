Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF4F6B0269
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 21:35:19 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so139356471pab.0
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 18:35:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yt1si39237247pab.45.2015.11.14.18.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Nov 2015 18:35:18 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511102313.36685.arekm@maven.pl>
	<56449E44.7020407@I-love.SAKURA.ne.jp>
	<201511122228.26399.arekm@maven.pl>
	<201511142140.38245.arekm@maven.pl>
In-Reply-To: <201511142140.38245.arekm@maven.pl>
Message-Id: <201511151135.JGD81717.OFOOSMFJFQHVtL@I-love.SAKURA.ne.jp>
Date: Sun, 15 Nov 2015 11:35:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl
Cc: htejun@gmail.com, cl@linux.com, mhocko@suse.com, linux-mm@kvack.org, xfs@oss.sgi.com

Arkadiusz Miskiewicz wrote:
> > > vmstat_update() and submit_flushes() remained pending for about 110
> > > seconds. If xlog_cil_push_work() were spinning inside GFP_NOFS
> > > allocation, it should be reported as MemAlloc: traces, but no such lines
> > > are recorded. I don't know why xlog_cil_push_work() did not call
> > > schedule() for so long. Anyway, applying
> > > http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz should
> > > solve vmstat_update() part.
> > 
> > To apply that patch on top of 4.1.13 I also had to apply patches listed
> > below.
> > 
> > So in summary appllied:
> > http://sprunge.us/GYBb
> > http://sprunge.us/XWUX
> > http://sprunge.us/jZjV
> 
> I've tried more to trigger "page allocation failure" with usual actions that 
> triggered it previously but couldn't reproduce. With these patches applied it 
> doesn't happen.
> 
> Logs from my tests:
> 
> http://ixion.pld-linux.org/~arekm/log-mm-3.txt.gz
> http://ixion.pld-linux.org/~arekm/log-mm-4.txt.gz (with swap added)
> 
Good.

vmstat_update() and submit_flushes() are no longer pending for long.

log-mm-4.txt:Nov 14 16:40:08 srv kernel: [167753.393960]     pending: vmstat_shepherd, vmpressure_work_fn
log-mm-4.txt:Nov 14 16:40:08 srv kernel: [167753.393984]     pending: submit_flushes [md_mod]
log-mm-4.txt:Nov 14 16:41:08 srv kernel: [167813.439405]     pending: submit_flushes [md_mod]
log-mm-4.txt:Nov 14 17:17:19 srv kernel: [169985.104806]     pending: vmstat_shepherd

I think that the vmstat statistics now have correct values.

> But are these patches solving the problem or just hiding it?
> 
Excuse me but I can't judge.

If you are interested in monitoring how vmstat statistics are changing
under stalled condition, you can try below patch.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35a46b4..3de3a14 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2794,8 +2794,7 @@ static int kmallocwd(void *unused)
 	rcu_read_unlock();
 	preempt_enable();
 	show_workqueue_state();
-	if (dump_target_pid <= 0)
-		dump_target_pid = -pid;
+	show_mem(0);
 	/* Wait until next timeout duration. */
 	schedule_timeout_interruptible(kmallocwd_timeout);
 	if (memalloc_counter[index])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
