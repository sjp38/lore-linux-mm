Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:31 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 08/13] aio: add support for aio poll via aio thread helper
Message-ID: <b47275df9e1c1cd65adbc5a1d88d6202592a1355.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Applications that require a unified event loop occasionally have a need
to interface with libraries or other code that require notification on a
file descriptor becoming ready for read or write via poll.  Add support
for the aio poll operation to enable these use-cases by way of the
thread based aio helpers.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c                     | 46 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/aio_abi.h |  2 +-
 2 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/fs/aio.c b/fs/aio.c
index 576b780..4384df4 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -200,6 +200,7 @@ struct aio_kiocb {
 	struct task_struct	*ki_submit_task;
 #if IS_ENABLED(CONFIG_AIO_THREAD)
 	struct task_struct	*ki_cancel_task;
+	unsigned long		ki_data;
 	unsigned long		ki_rlimit_fsize;
 	aio_thread_work_fn_t	ki_work_fn;
 	struct work_struct	ki_work;
@@ -225,6 +226,7 @@ static const struct address_space_operations aio_ctx_aops;
 
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
 ssize_t aio_fsync(struct kiocb *iocb, int datasync);
+long aio_poll(struct aio_kiocb *iocb);
 
 static __always_inline bool aio_may_use_threads(void)
 {
@@ -1675,6 +1677,45 @@ ssize_t aio_fsync(struct kiocb *iocb, int datasync)
 	return aio_thread_queue_iocb(req, datasync ? aio_thread_op_fdatasync
 						   : aio_thread_op_fsync, 0);
 }
+
+static long aio_thread_op_poll(struct aio_kiocb *iocb)
+{
+	struct file *file = iocb->common.ki_filp;
+	short events = iocb->ki_data;
+	struct poll_wqueues table;
+	unsigned int mask;
+	ssize_t ret = 0;
+
+	poll_initwait(&table);
+	events |= POLLERR | POLLHUP;
+
+	for (;;) {
+		mask = DEFAULT_POLLMASK;
+		if (file->f_op && file->f_op->poll) {
+			table.pt._key = events;
+			mask = file->f_op->poll(file, &table.pt);
+		}
+		/* Mask out unneeded events. */
+		mask &= events;
+		ret = mask;
+		if (mask)
+			break;
+
+		ret = -EINTR;
+		if (signal_pending(current))
+			break;
+
+		poll_schedule_timeout(&table, TASK_INTERRUPTIBLE, NULL, 0);
+	}
+
+	poll_freewait(&table);
+	return ret;
+}
+
+long aio_poll(struct aio_kiocb *req)
+{
+	return aio_thread_queue_iocb(req, aio_thread_op_poll, 0);
+}
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
 /*
@@ -1764,6 +1805,11 @@ rw_common:
 			ret = aio_fsync(&req->common, 0);
 		break;
 
+	case IOCB_CMD_POLL:
+		if (aio_may_use_threads())
+			ret = aio_poll(req);
+		break;
+
 	default:
 		pr_debug("EINVAL: no operation provided\n");
 		return -EINVAL;
diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
index bb2554f..7639fb1 100644
--- a/include/uapi/linux/aio_abi.h
+++ b/include/uapi/linux/aio_abi.h
@@ -39,8 +39,8 @@ enum {
 	IOCB_CMD_FDSYNC = 3,
 	/* These two are experimental.
 	 * IOCB_CMD_PREADX = 4,
-	 * IOCB_CMD_POLL = 5,
 	 */
+	IOCB_CMD_POLL = 5,
 	IOCB_CMD_NOOP = 6,
 	IOCB_CMD_PREADV = 7,
 	IOCB_CMD_PWRITEV = 8,
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
