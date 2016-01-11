Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:06:42 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 02/13] aio: add aio_get_mm() helper
Message-ID: <15fa9ae56d448d75a3a814ad44544522e0c627e0.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

For various async operations, it is necessary to have a way of finding
the address space to use for accessing user memory.  Add the helper
struct mm_struct *aio_get_mm(struct kiocb *) to address this use-case.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c            | 15 +++++++++++++++
 include/linux/aio.h |  2 ++
 2 files changed, 17 insertions(+)

diff --git a/fs/aio.c b/fs/aio.c
index e0d5398..2cd5071 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -154,6 +154,7 @@ struct kioctx {
 	struct file		*aio_ring_file;
 
 	unsigned		id;
+	struct mm_struct	*mm;
 };
 
 /*
@@ -202,6 +203,8 @@ static struct vfsmount *aio_mnt;
 static const struct file_operations aio_ring_fops;
 static const struct address_space_operations aio_ctx_aops;
 
+static void aio_complete(struct kiocb *kiocb, long res, long res2);
+
 static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
 {
 	struct qstr this = QSTR_INIT("[aio]", 5);
@@ -568,6 +571,17 @@ static int kiocb_cancel(struct aio_kiocb *kiocb)
 	return cancel(&kiocb->common);
 }
 
+struct mm_struct *aio_get_mm(struct kiocb *req)
+{
+	if (req->ki_complete == aio_complete) {
+		struct aio_kiocb *iocb;
+
+		iocb = container_of(req, struct aio_kiocb, common);
+		return iocb->ki_ctx->mm;
+	}
+	return NULL;
+}
+
 static void free_ioctx(struct work_struct *work)
 {
 	struct kioctx *ctx = container_of(work, struct kioctx, free_work);
@@ -719,6 +733,7 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 		return ERR_PTR(-ENOMEM);
 
 	ctx->max_reqs = nr_events;
+	ctx->mm = mm;
 
 	spin_lock_init(&ctx->ctx_lock);
 	spin_lock_init(&ctx->completion_lock);
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 9eb42db..c5791d4 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -17,6 +17,7 @@ extern void exit_aio(struct mm_struct *mm);
 extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
+struct mm_struct *aio_get_mm(struct kiocb *req);
 #else
 static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
@@ -24,6 +25,7 @@ static inline long do_io_submit(aio_context_t ctx_id, long nr,
 				bool compat) { return 0; }
 static inline void kiocb_set_cancel_fn(struct kiocb *req,
 				       kiocb_cancel_fn *cancel) { }
+static inline struct mm_struct *aio_get_mm(struct kiocb *req) { return NULL; }
 #endif /* CONFIG_AIO */
 
 /* for sysctl: */
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
