Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 076696B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 11:01:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g128so6485002itb.5
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 08:01:26 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k12si10362061iok.66.2017.11.06.08.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 08:01:24 -0800 (PST)
Date: Mon, 6 Nov 2017 17:01:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in generic_file_write_iter
Message-ID: <20171106160107.GA20227@worktop.programming.kicks-ass.net>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
 <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz>
 <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>

On Mon, Nov 06, 2017 at 02:35:44PM +0100, Dmitry Vyukov wrote:
> On Mon, Nov 6, 2017 at 2:33 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Mon, Nov 06, 2017 at 02:15:44PM +0100, Jan Kara wrote:
> >
> >> > Should we annotate these inodes with different lock types? Or use
> >> > nesting annotations?
> >>
> >> Well, you'd need to have a completely separate set of locking classes for
> >> each filesystem to avoid false positives like these. And that would
> >> increase number of classes lockdep has to handle significantly. So I'm not
> >> sure it's really worth it...
> >
> > Especially when you consider that backing file might be on a filesystem
> > that lives on another loop device.  *All* per-{device,fs} locks involved
> > would need classes split that way...
> 
> 
> This crashes our test machines left and right. We've seen 100000+ of
> these crashes. We need to do at least something. Can we disable all
> checking of these mutexes if they inherently have positives?

Its not the mutexes that's the problem.. Its the completion that crosses
the filesystem layers.

> +Ingo, Peter, maybe you have some suggestions of how to fight this
> lockdep false positives. Full thread is here:
> https://groups.google.com/forum/#!msg/syzkaller-bugs/NJ_4llH84XI/c7M9jNLTAgAJ

The best I could come up with is something like the below; its not
at all pretty and I could see people objecting; least of all myself for
the __complete() thing, but I ran out of creative naming juice.



---
 block/bio.c                |  2 +-
 block/blk-core.c           |  8 ++++++--
 drivers/block/loop.c       |  9 +++++++++
 include/linux/blk_types.h  |  1 +
 include/linux/blkdev.h     |  1 +
 include/linux/completion.h |  8 +++++++-
 kernel/sched/completion.c  | 11 ++++-------
 7 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index cc60213e56d8..22bedceb7bae 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -919,7 +919,7 @@ EXPORT_SYMBOL_GPL(bio_iov_iter_get_pages);
 
 static void submit_bio_wait_endio(struct bio *bio)
 {
-	complete(bio->bi_private);
+	__complete(bio->bi_private, !bio_flagged(bio, BIO_STACKED));
 }
 
 /**
diff --git a/block/blk-core.c b/block/blk-core.c
index 048be4aa6024..bb4092d716c3 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -194,8 +194,12 @@ static void req_bio_endio(struct request *rq, struct bio *bio,
 	if (error)
 		bio->bi_status = error;
 
-	if (unlikely(rq->rq_flags & RQF_QUIET))
-		bio_set_flag(bio, BIO_QUIET);
+	if (unlikely(rq->rq_flags & (RQF_QUIET|RQF_STACKED))) {
+		if (rq->rq_flags & RQF_QUIET)
+			bio_set_flag(bio, BIO_QUIET);
+		if (rq->rq_flags & RQF_STACKED)
+			bio_set_flag(bio, BIO_STACKED);
+	}
 
 	bio_advance(bio, nbytes);
 
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 85de67334695..7d702d2c4ade 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -452,6 +452,15 @@ static void lo_complete_rq(struct request *rq)
 {
 	struct loop_cmd *cmd = blk_mq_rq_to_pdu(rq);
 
+	/*
+	 * Assuming loop ensures the associated filesystems form a DAG, this
+	 * cross-filesystem release can never form a deadlock.
+	 *
+	 * Inform the request that the corresponding BIO is of a stacked
+	 * device and thereby forgo dependency checking.
+	 */
+	rq->rq_flags |= RQF_STACKED;
+
 	if (unlikely(req_op(cmd->rq) == REQ_OP_READ && cmd->use_aio &&
 		     cmd->ret >= 0 && cmd->ret < blk_rq_bytes(cmd->rq))) {
 		struct bio *bio = cmd->rq->bio;
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 96ac3815542c..bf9b37de7975 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -136,6 +136,7 @@ struct bio {
 				 * throttling rules. Don't do it again. */
 #define BIO_TRACE_COMPLETION 10	/* bio_endio() should trace the final completion
 				 * of this bio. */
+#define BIO_STACKED	11
 /* See BVEC_POOL_OFFSET below before adding new flags */
 
 /*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 8da66379f7ea..dcf4b1a70f77 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -121,6 +121,7 @@ typedef __u32 __bitwise req_flags_t;
 /* Look at ->special_vec for the actual data payload instead of the
    bio chain. */
 #define RQF_SPECIAL_PAYLOAD	((__force req_flags_t)(1 << 18))
+#define RQF_STACKED		((__force req_flags_t)(1 << 19))
 
 /* flags that prevent us from merging requests: */
 #define RQF_NOMERGE_FLAGS \
diff --git a/include/linux/completion.h b/include/linux/completion.h
index 0662a417febe..a6680197f2af 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -161,7 +161,13 @@ extern long wait_for_completion_killable_timeout(
 extern bool try_wait_for_completion(struct completion *x);
 extern bool completion_done(struct completion *x);
 
-extern void complete(struct completion *);
+extern void __complete(struct completion *, bool);
+
+static inline void complete(struct completion *x)
+{
+	__complete(x, true);
+}
+
 extern void complete_all(struct completion *);
 
 #endif
diff --git a/kernel/sched/completion.c b/kernel/sched/completion.c
index 2ddaec40956f..a2071513decf 100644
--- a/kernel/sched/completion.c
+++ b/kernel/sched/completion.c
@@ -28,23 +28,20 @@
  * It may be assumed that this function implies a write memory barrier before
  * changing the task state if and only if any tasks are woken up.
  */
-void complete(struct completion *x)
+void __complete(struct completion *x, bool link)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&x->wait.lock, flags);
-
-	/*
-	 * Perform commit of crossrelease here.
-	 */
-	complete_release_commit(x);
+	if (link)
+		complete_release_commit(x);
 
 	if (x->done != UINT_MAX)
 		x->done++;
 	__wake_up_locked(&x->wait, TASK_NORMAL, 1);
 	spin_unlock_irqrestore(&x->wait.lock, flags);
 }
-EXPORT_SYMBOL(complete);
+EXPORT_SYMBOL(__complete);
 
 /**
  * complete_all: - signals all threads waiting on this completion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
