Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id C30436B025F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:20:00 -0500 (EST)
Received: by oixx65 with SMTP id x65so36816288oix.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:20:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e3si11615262oif.93.2015.11.13.04.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 04:19:59 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511111719.44035.arekm@maven.pl>
	<201511120719.EBF35970.OtSOHOVFJMFQFL@I-love.SAKURA.ne.jp>
	<201511120706.10739.arekm@maven.pl>
	<56449E44.7020407@I-love.SAKURA.ne.jp>
	<20151112200641.GR19199@dastard>
In-Reply-To: <20151112200641.GR19199@dastard>
Message-Id: <201511132119.BAG65154.QVHStOOFFMOLFJ@I-love.SAKURA.ne.jp>
Date: Fri, 13 Nov 2015 21:19:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: arekm@maven.pl, htejun@gmail.com, cl@linux.com, mhocko@suse.com, linux-mm@kvack.org, xfs@oss.sgi.com

Dave Chinner wrote:
> So why have we only scanned *176* pages* during reclaim?  On other
> OOM reports in this trace it's as low as 12.  Either that stat is
> completely wrong, or we're not doing sufficient page LRU reclaim
> scanning....
> 
> > [ 9662.234685] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
> > 
> > vmstat_update() and submit_flushes() remained pending for about 110 seconds.
> > If xlog_cil_push_work() were spinning inside GFP_NOFS allocation, it should be
> > reported as MemAlloc: traces, but no such lines are recorded. I don't know why
> > xlog_cil_push_work() did not call schedule() for so long.
> 
> I'd say it is repeatedly waiting for IO completion on log buffers to
> write out the checkpoint. It's making progress, just if it's taking
> multiple second per journal IO it will take a long time to write a
> checkpoint. All the other blocked tasks in XFS inode reclaim are
> either waiting directly on IO completion or waiting for the log to
> complete a flush, so this really just looks like an overloaded IO
> subsystem to me....

The vmstat statistics can become wrong when vmstat_update() workqueue item
cannot be processed due to in-flight workqueue item not calling schedule().
If in-flight workqueue item (in this case xlog_cil_push_work()) called
schedule(), the pending vmstat_update() workqueue item will be processed
and the vmstat becomes up to dated. Like you expect that xlog_cil_push_work()
was waiting for IO completion on log buffers rather than spinning inside
GFP_NOFS allocation, what should happened is xlog_cil_push_work() called
schedule() and vmstat_update() was processed. But vmstat_update() remained
pending for about 110 seconds. That's strange...

Arkadiusz is trying http://marc.info/?l=linux-mm&m=144725782107096&w=2
which is for making sure that vmstat_update() workqueue item is processed
by changing wait_iff_congested() to call schedule(), and we are waiting
for test results.

Well, one of dependent patches "vmstat: explicitly schedule per-cpu work
on the CPU we need it to run on" might be relevant to this problem.

If http://sprunge.us/GYBb and http://sprunge.us/XWUX solve the problem
(for both with swap case and without swap case), the vmstat statistics
was wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
