Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E96466B0260
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:58:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so4103201pgq.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:58:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a7si3175616pll.301.2017.12.14.04.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 04:58:46 -0800 (PST)
Date: Thu, 14 Dec 2017 04:58:09 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: d1fc031747 ("sched/wait: assert the wait_queue_head lock is
 .."):  EIP: __wake_up_common
Message-ID: <20171214125809.GB30288@bombadil.infradead.org>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com>
 <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Dec 13, 2017 at 05:03:00PM -0800, Andrew Morton wrote:
> >     sched/wait: assert the wait_queue_head lock is held in __wake_up_common
> >     
> >     Better ensure we actually hold the lock using lockdep than just commenting
> >     on it.  Due to the various exported _locked interfaces it is far too easy
> >     to get the locking wrong.
> 
> I'm probably sitting on an older version.  I've dropped
> 
> epoll: use the waitqueue lock to protect ep->wq
> sched/wait: assert the wait_queue_head lock is held in __wake_up_common

Looks pretty clear to me that userfaultfd is also abusing the wake_up_locked
interfaces:

        spin_lock(&ctx->fault_pending_wqh.lock);
        __wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
        __wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
        spin_unlock(&ctx->fault_pending_wqh.lock);

Sure, it's locked, but not by the lock you thought it was going to be.

There doesn't actually appear to be a bug here; fault_wqh is always serialised
by fault_pending_wqh.lock, but lockdep can't know that.  I think this patch
will solve the problem.

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ac9a4e65ca49..a39bc3237b68 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -879,7 +879,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 */
 	spin_lock(&ctx->fault_pending_wqh.lock);
 	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
-	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
+	__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, &range);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
 	/* Flush pending events that may still wait on event_wqh */
@@ -1045,7 +1045,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			 * anyway.
 			 */
 			list_del(&uwq->wq.entry);
-			__add_wait_queue(&ctx->fault_wqh, &uwq->wq);
+			add_wait_queue(&ctx->fault_wqh, &uwq->wq);
 
 			write_seqcount_end(&ctx->refile_seq);
 
@@ -1194,7 +1194,7 @@ static void __wake_userfault(struct userfaultfd_ctx *ctx,
 		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL,
 				     range);
 	if (waitqueue_active(&ctx->fault_wqh))
-		__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, range);
+		__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, range);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
