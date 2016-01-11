Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:08:05 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 13/13] aio: add support for aio renameat operation
Message-ID: <86d03af4b834ddfc451334ab7a63d1f57c47755d.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Add support for an aio renameat operation that implements an
asynchronous renameat2().

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c                     | 63 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/aio_abi.h |  9 +++++++
 2 files changed, 72 insertions(+)

diff --git a/fs/aio.c b/fs/aio.c
index 5cb3d74..aaecadf 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -240,6 +240,7 @@ long aio_do_unlinkat(int fd, const char *filename, int flags, int mode);
 long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at);
 
 long aio_readahead(struct aio_kiocb *iocb, unsigned long len);
+long aio_renameat(struct aio_kiocb *iocb, struct iocb *user_iocb);
 
 static __always_inline bool aio_may_use_threads(void)
 {
@@ -1946,6 +1947,63 @@ long aio_readahead(struct aio_kiocb *iocb, unsigned long len)
 		return aio_thread_queue_iocb(iocb, aio_thread_op_readahead, 0);
 	return len;
 }
+
+static long aio_thread_op_renameat(struct aio_kiocb *iocb)
+{
+	const void * __user user_info = (void * __user)iocb->common.private;
+	struct renameat_info info;
+	const char * __user old;
+	const char * __user new;
+	int olddir, newdir;
+	unsigned flags;
+	long ret;
+
+	use_mm(aio_get_mm(&iocb->common));
+	if (unlikely(copy_from_user(&info, user_info, sizeof(info)))) {
+		ret = -EFAULT;
+		goto done;
+	}
+
+	old = (const char * __user)(unsigned long)info.oldpath;
+	new = (const char * __user)(unsigned long)info.newpath;
+	olddir = info.olddirfd;
+	newdir = info.newdirfd;
+	flags = info.flags;
+
+	if (((unsigned long)old != info.oldpath) ||
+	    ((unsigned long)new != info.newpath) ||
+	    (olddir != info.olddirfd) ||
+	    (newdir != info.newdirfd) ||
+	    (flags != info.flags))
+		ret = -EINVAL;
+	else
+		ret = sys_renameat2(olddir, old, newdir, new, flags);
+done:
+	unuse_mm(aio_get_mm(&iocb->common));
+	return ret;
+}
+
+long aio_renameat(struct aio_kiocb *iocb, struct iocb *user_iocb)
+{
+	const void * __user user_info;
+
+	if (user_iocb->aio_nbytes != sizeof(struct renameat_info))
+		return -EINVAL;
+	if (user_iocb->aio_offset)
+		return -EINVAL;
+
+	user_info = (const void * __user)user_iocb->aio_buf;
+	if (unlikely(!access_ok(VERIFY_READ, user_info,
+				sizeof(struct renameat_info))))
+		return -EFAULT;
+
+	iocb->common.private = (void *)user_info;
+	return aio_thread_queue_iocb(iocb, aio_thread_op_renameat,
+				     AIO_THREAD_NEED_TASK |
+				     AIO_THREAD_NEED_FS |
+				     AIO_THREAD_NEED_FILES |
+				     AIO_THREAD_NEED_CRED);
+}
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
 /*
@@ -2063,6 +2121,11 @@ rw_common:
 			ret = aio_readahead(req, user_iocb->aio_nbytes);
 		break;
 
+	case IOCB_CMD_RENAMEAT:
+		if (aio_may_use_threads())
+			ret = aio_renameat(req, user_iocb);
+		break;
+
 	default:
 		pr_debug("EINVAL: no operation provided\n");
 		return -EINVAL;
diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
index 4def682..9417abd 100644
--- a/include/uapi/linux/aio_abi.h
+++ b/include/uapi/linux/aio_abi.h
@@ -48,6 +48,7 @@ enum {
 	IOCB_CMD_OPENAT = 9,
 	IOCB_CMD_UNLINKAT = 10,
 	IOCB_CMD_READAHEAD = 12,
+	IOCB_CMD_RENAMEAT = 13,
 };
 
 /*
@@ -108,6 +109,14 @@ struct iocb {
 	__u32	aio_resfd;
 }; /* 64 bytes */
 
+struct renameat_info {
+	__s64	olddirfd;
+	__u64	oldpath;
+	__s64	newdirfd;
+	__u64	newpath;
+	__u64	flags;
+};
+
 #undef IFBIG
 #undef IFLITTLE
 
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
