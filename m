Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id BE13F6B00BE
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:24:00 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so9243198pbb.33
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 11:24:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id k7si20977490pbl.251.2014.03.11.11.23.58
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 11:23:59 -0700 (PDT)
Date: Tue, 11 Mar 2014 11:23:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-Id: <20140311112355.d335295ed62cd480eb5ab33c@linux-foundation.org>
In-Reply-To: <20140219190139.GQ10134@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
	<20140218225548.GI31892@mtj.dyndns.org>
	<20140219092731.GA4849@quack.suse.cz>
	<20140219190139.GQ10134@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Derek Basehore <dbasehore@chromium.org>, Alexander Viro <viro@zento.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, semenzato@chromium.org

On Wed, 19 Feb 2014 14:01:39 -0500 Tejun Heo <tj@kernel.org> wrote:

> Hello, Jan.
> 
> On Wed, Feb 19, 2014 at 10:27:31AM +0100, Jan Kara wrote:
> >   You are the workqueue expert so you may know better ;) But the way I
> > understand it is that queue_delayed_work() does nothing if the timer is
> > already running. Since we queue flusher work to run either immediately or
> > after dirty_writeback_interval we are safe to run queue_delayed_work()
> > whenever we want it to run after dirty_writeback_interval and
> > mod_delayed_work() whenever we want to run it immediately.
> 
> Ah, okay, so it's always mod on immediate and queue on delayed.  Yeah,
> that should work.
> 
> > But it's subtle and some interface where we could say queue delayed work
> > after no later than X would be easier to grasp.
> 
> Yeah, I think it'd be better if we had something like
> mod_delayed_work_if_later().  Hmm...

The code comments which you asked for were not forthcoming.

Are you otherwise OK with merging this into 3.14 and -stable?


From: Derek Basehore <dbasehore@chromium.org>
Subject: backing_dev: fix hung task on sync

bdi_wakeup_thread_delayed() used mod_delayed_work() to schedule work to
writeback dirty inodes.  The problem with this is that it can delay work
that is scheduled for immediate execution, such as the work from
sync_inodes_sb().  This can happen since mod_delayed_work can now steal
work from a work_queue.  This fixes the problem by using
queue_delayed_work instead.  This is a regression from the move to the bdi
workqueue design.

The reason that this causes a problem is that laptop-mode will change the
delay, dirty_writeback_centisecs, to 60000 (10 minutes) by default.  In
the case that bdi_wakeup_thread_delayed races with sync_inodes_sb, sync
will be stopped for 10 minutes and trigger a hung task.  Even if
dirty_writeback_centisecs is not long enough to cause a hung task, we
still don't want to delay sync for that long.

For the same reason, this also changes bdi_writeback_workfn to immediately
queue the work again in the case that the work_list is not empty.  The
same problem can happen if the sync work is run on the rescue worker.

Signed-off-by: Derek Basehore <dbasehore@chromium.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Alexander Viro <viro@zento.linux.org.uk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Derek Basehore <dbasehore@chromium.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Benson Leung <bleung@chromium.org>
Cc: Sonny Rao <sonnyrao@chromium.org>
Cc: Luigi Semenzato <semenzato@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/fs-writeback.c |    5 +++--
 mm/backing-dev.c  |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff -puN fs/fs-writeback.c~backing_dev-fix-hung-task-on-sync fs/fs-writeback.c
--- a/fs/fs-writeback.c~backing_dev-fix-hung-task-on-sync
+++ a/fs/fs-writeback.c
@@ -1039,8 +1039,9 @@ void bdi_writeback_workfn(struct work_st
 		trace_writeback_pages_written(pages_written);
 	}
 
-	if (!list_empty(&bdi->work_list) ||
-	    (wb_has_dirty_io(wb) && dirty_writeback_interval))
+	if (!list_empty(&bdi->work_list))
+		mod_delayed_work(bdi_wq, &wb->dwork, 0);
+	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
 		queue_delayed_work(bdi_wq, &wb->dwork,
 			msecs_to_jiffies(dirty_writeback_interval * 10));
 
diff -puN mm/backing-dev.c~backing_dev-fix-hung-task-on-sync mm/backing-dev.c
--- a/mm/backing-dev.c~backing_dev-fix-hung-task-on-sync
+++ a/mm/backing-dev.c
@@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct ba
 	unsigned long timeout;
 
 	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
-	mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
+	queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
