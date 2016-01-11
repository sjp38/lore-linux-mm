Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:00 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 04/13] signals: add and use aio_get_task() to direct signals sent via io_send_sig()
Message-ID: <461f869cb59a2aa970015f0dd24b02a39c4b9956.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

When a signal is triggered due to an i/o, io_send_sig() needs to deliver
the signal to the task issuing the i/o.  Prepare for thread based aios
by annotating task_struct with a struct kiocb pointer that enables
io_sed_sig() to direct these signals to the submitter of the aio.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c              | 16 ++++++++++++++++
 include/linux/aio.h   |  3 +++
 include/linux/sched.h |  5 +++++
 kernel/signal.c       |  8 +++++++-
 4 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/fs/aio.c b/fs/aio.c
index fc453ca..55c8ff5 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -191,6 +191,9 @@ struct aio_kiocb {
 	struct iov_iter		ki_iter;
 	struct iovec		*ki_iovec;
 	struct iovec		ki_inline_vecs[UIO_FASTIOV];
+
+	/* Fields used for threaded aio helper. */
+	struct task_struct	*ki_submit_task;
 };
 
 /*------ sysctl variables----*/
@@ -586,6 +589,17 @@ struct mm_struct *aio_get_mm(struct kiocb *req)
 	return NULL;
 }
 
+struct task_struct *aio_get_task(struct kiocb *req)
+{
+	if (req->ki_complete == aio_complete) {
+		struct aio_kiocb *iocb;
+
+		iocb = container_of(req, struct aio_kiocb, common);
+		return iocb->ki_submit_task;
+	}
+	return current;
+}
+
 static void free_ioctx(struct work_struct *work)
 {
 	struct kioctx *ctx = container_of(work, struct kioctx, free_work);
@@ -1045,6 +1059,8 @@ static void kiocb_free(struct aio_kiocb *req)
 		eventfd_ctx_put(req->ki_eventfd);
 	if (req->ki_iovec != req->ki_inline_vecs)
 		kfree(req->ki_iovec);
+	if (req->ki_submit_task)
+		put_task_struct(req->ki_submit_task);
 	kmem_cache_free(kiocb_cachep, req);
 }
 
diff --git a/include/linux/aio.h b/include/linux/aio.h
index c5791d4..9a62e8a 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -18,6 +18,7 @@ extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
 struct mm_struct *aio_get_mm(struct kiocb *req);
+struct task_struct *aio_get_task(struct kiocb *req);
 #else
 static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
@@ -26,6 +27,8 @@ static inline long do_io_submit(aio_context_t ctx_id, long nr,
 static inline void kiocb_set_cancel_fn(struct kiocb *req,
 				       kiocb_cancel_fn *cancel) { }
 static inline struct mm_struct *aio_get_mm(struct kiocb *req) { return NULL; }
+static inline struct task_struct *aio_get_task(struct kiocb *req)
+{ return current; }
 #endif /* CONFIG_AIO */
 
 /* for sysctl: */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6376d58..bdbf11b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1633,6 +1633,11 @@ struct task_struct {
 /* journalling filesystem info */
 	void *journal_info;
 
+/* threaded aio info */
+#if IS_ENABLED(CONFIG_AIO)
+	struct kiocb *kiocb;
+#endif
+
 /* stacked block device info */
 	struct bio_list *bio_list;
 
diff --git a/kernel/signal.c b/kernel/signal.c
index 7c14cb4..5da9180 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -34,6 +34,7 @@
 #include <linux/compat.h>
 #include <linux/cn_proc.h>
 #include <linux/compiler.h>
+#include <linux/aio.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
@@ -1432,7 +1433,12 @@ int send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
  */
 int io_send_sig(int sig)
 {
-	return send_sig(sig, current, 0);
+	struct task_struct *task = current;
+#if IS_ENABLED(CONFIG_AIO)
+	if (task->kiocb)
+		task = aio_get_task(task->kiocb);
+#endif
+	return send_sig(sig, task, 0);
 }
 EXPORT_SYMBOL(io_send_sig);
 
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
