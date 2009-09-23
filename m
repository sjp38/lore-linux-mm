Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78AE46B005A
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:34 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 70/80] c/r: Add AF_UNIX support (v12)
Date: Wed, 23 Sep 2009 19:51:50 -0400
Message-Id: <1253749920-18673-71-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Dan Smith <danms@us.ibm.com>, Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports socketpair()s, path-based, and
abstract sockets.

Changes in v12:
  - Collect sockets for leak-detection
  - Adjust socket reference count during leak detection phase

Changes in v11:
  - Create a struct socket for orphan socket during checkpoint
  - Make sockets proper objhash objects and use checkpoint_obj() on them
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*
  - Remove struct timeval from socket header
  - Save and restore UNIX socket peer credentials
  - Set socket flags on restore using sock_setsockopt() where possible
  - Fail on the TIMESTAMPING_* flags for the moment (with a TODO)
  - Remove other explicit flag checks that are no longer copied blindly
  - Changed functions/variables names to follow existing conventions
  - Use proto_ops->{checkpoint,restart} methods for af_unix
  - Cleanup sock_file_restore()/sock_file_checkpoint()
  - Make ckpt_hdr_socket be part of ckpt_hdr_file_socket
  - Fold do_sock_file_checkpoint() into sock_file_checkpoint()
  - Fold do_sock_file_restore() into sock_file_restore()
  - Move sock_file_{checkpoint,restore} to net/checkpoint.c
  - Properly define sock_file_{checkpoint,restore} in header file
  - sock_file_restore() now calls restore_file_common()

Changes in v10:
  - Moved header structure definitions back to checkpoint_hdr.h
  - Moved AF_UNIX checkpoint/restart code to net/unix/checkpoint.c
  - Make sock_unix_*() functions only compile if CONFIG_UNIX=y
  - Add TODO for CONFIG_UNIX=m case

Changes in v9:
  - Fix double-free of skb's in the list and target holding queue in the
    error path of sock_copy_buffers()
  - Adjust use of ckpt_read_string() to match new signature

Changes in v8:
  - Fix stale dev_alloc_skb() from before the conversion to skb_clone()
  - Fix a couple of broken error paths
  - Fix memory leak of kvec.iov_base on successful return from sendmsg()
  - Fix condition for deciding when to run sock_cptrst_verify()
  - Fix buffer queue copy algorithm to hold the lock during walk(s)
  - Log the errno when either getname() or getpeer() fails
  - Add comments about ancillary messages in the UNIX queue
  - Add TODO comments for credential restore and flags via setsockopt()
  - Add TODO comment about strangely-connected dgram sockets and the use
    of sendmsg(peer)

Changes in v7:
  - Fix failure to free iov_base in error path of sock_read_buffer()
  - Change sock_read_buffer() to use _ckpt_read_obj_type() to get the
    header length and then use ckpt_kread() directly to read the payload
  - Change sock_read_buffers() to sock_unix_read_buffers() and break out
    some common functionality to better accommodate the subsequent INET
    patch
  - Generalize sock_unix_getnames() into sock_getnames() so INET can use it
  - Change skb_morph() to skb_clone() which uses the more common path and
    still avoids the copy
  - Add check to validate the socket type before creating socket
    on restore
  - Comment the CAP_NET_ADMIN override in sock_read_buffer_hdr
  - Strengthen the comment about priming the buffer limits
  - Change the objhash functions to deny direct checkpoint of sockets and
    remove the reference counting function
  - Change SOCKET_BUFFERS to SOCKET_QUEUE
  - Change this,peer objrefs to signed integers
  - Remove names from internal socket structures
  - Fix handling of sock_copy_buffers() result
  - Use ckpt_fill_fname() instead of d_path() for writing CWD
  - Use sock_getname() and sock_getpeer() for proper security hookage
  - Return -ENOSYS for unsupported socket families in checkpoint and restart
  - Use sock_setsockopt() and sock_getsockopt() where possible to save and
    restore socket option values
  - Check for SOCK_DESTROY flag in the global verify function because none
    of our supported socket types use it
  - Check for SOCK_USE_WRITE_QUEUE in AF_UNIX restore function because
    that flag should not be used on such a socket
  - Check socket state in UNIX restart path to validate the subset of valid
    values

Changes in v6:
  - Moved the socket addresses to the per-type header
  - Eliminated the HASCWD flag
  - Remove use of ckpt_write_err() in restart paths
  - Change the order in which buffers are read so that we can set the
    socket's limit equal to the size of the image's buffers (if appropriate)
    and then restore the original values afterwards.
  - Use the ckpt_validate_errno() helper
  - Add a check to make sure that we didn't restore a (UNIX) socket with
    any skb's in the send buffer
  - Fix up sock_unix_join() to not leave addr uninitialized for socketpair
  - Remove inclusion of checkpoint_hdr.h in the socket files
  - Make sock_unix_write_cwd() use ckpt_write_string() and use the new
    ckpt_read_string() for reading the cwd
  - Use the restored realcred credentials in sock_unix_join()
  - Fix error path of the chdir_and_bind
  - Change the algorithm for reloading the socket buffers to use sendmsg()
    on the socket's peer for better accounting
  - For DGRAM sockets, check the backlog value against the system max
    to avoid letting a restart bypass the overloaded queue length
  - Use sock_bind() instead of sock->ops->bind() to gain the security hook
  - Change "restart" to "restore" in some of the function names

Changes in v5:
  - Change laddr and raddr buffers in socket header to be long enough
    for INET6 addresses
  - Place socket.c and sock.h function definitions inside #ifdef
    CONFIG_CHECKPOINT
  - Add explicit check in sock_unix_makeaddr() to refuse if the
    checkpoint image specifies an addr length of 0
  - Split sock_unix_restart() into a few pieces to facilitate:
  - Changed behavior of the unix restore code so that unlinked LISTEN
    sockets don't do a bind()...unlink()
  - Save the base path of a bound socket's path so that we can chdir()
    to the base before bind() if it is a relative path
  - Call bind() for any socket that is not established but has a
    non-zero-length local address
  - Enforce the current sysctl limit on socket buffer size during restart
    unless the user holds CAP_NET_ADMIN
  - Unlink a path-based socket before calling bind()

Changes in v4:
  - Changed the signdness of rcvlowat, rcvtimeo, sndtimeo, and backlog
    to match their struct sock definitions.  This should avoid issues
    with sign extension.
  - Add a sock_cptrst_verify() function to be run at restore time to
    validate several of the values in the checkpoint image against
    limits, flag masks, etc.
  - Write an error string with ctk_write_err() in the obscure cases
  - Don't write socket buffers for listen sockets
  - Sanity check address lengths before we agree to allocate memory
  - Check the result of inserting the peer object in the objhash on
    restart
  - Check return value of sock_cptrst() on restart
  - Change logic in remote getname() phase of checkpoint to not fail for
    closed (et al) sockets
  - Eliminate the memory copy while reading socket buffers on restart

Changes in v3:
  - Move sock_file_checkpoint() above sock_file_restore()
  - Change __sock_file_*() functions to do_sock_file_*()
  - Adjust some of the struct cr_hdr_socket alignment
  - Improve the sock_copy_buffers() algorithm to avoid locking the source
    queue for the entire operation
  - Fix alignment in the socket header struct(s)
  - Move the per-protocol structure (ckpt_hdr_socket_un) out of the
    common socket header and read/write it separately
  - Fix missing call to sock_cptrst() in restore path
  - Break out the socket joining into another function
  - Fix failure to restore the socket address thus fixing getname()
  - Check the state values on restart
  - Fix case of state being TCP_CLOSE, which allows dgram sockets to be
    properly connected (if appropriate) to their peer and maintain the
    sockaddr for getname() operation
  - Fix restoring a listening socket that has been unlink()'d
  - Fix checkpointing sockets with an in-flight FD-passing SKB.  Fail
    with EBUSY.
  - Fix checkpointing listening sockets with an unaccepted connection.
    Fail with EBUSY.
  - Changed 'un' to 'unix' in function and structure names

Changes in v2:
  - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
    to be rather common in other uses of skb_copy())
  - Move the ckpt_hdr_socket structure definition to linux/socket.h
  - Fix whitespace issue
  - Move sock_file_checkpoint() to net/socket.c for symmetry

Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   69 ++++
 include/linux/checkpoint.h     |    7 +
 include/linux/checkpoint_hdr.h |   87 +++++
 include/linux/net.h            |    2 +
 include/net/af_unix.h          |   14 +
 include/net/sock.h             |   12 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  752 ++++++++++++++++++++++++++++++++++++++++
 net/socket.c                   |    6 +-
 net/unix/Makefile              |    1 +
 net/unix/af_unix.c             |    9 +
 net/unix/checkpoint.c          |  634 +++++++++++++++++++++++++++++++++
 13 files changed, 1601 insertions(+), 1 deletions(-)
 create mode 100644 net/checkpoint.c
 create mode 100644 net/unix/checkpoint.c

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 1de89d6..058bc0e 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -22,6 +22,7 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 
 /**************************************************************************
@@ -591,6 +592,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_FIFO,
 		.restore = fifo_file_restore,
 	},
+	/* socket */
+	{
+		.file_name = "SOCKET",
+		.file_type = CKPT_FILE_SOCKET,
+		.restore = sock_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index bf2f761..0978060 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -20,6 +20,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -234,6 +235,40 @@ static void obj_groupinfo_drop(void *ptr, int lastref)
 	put_group_info((struct group_info *) ptr);
 }
 
+static int obj_sock_grab(void *ptr)
+{
+	sock_hold((struct sock *) ptr);
+	return 0;
+}
+
+static void obj_sock_drop(void *ptr, int lastref)
+{
+	struct sock *sk = (struct sock *) ptr;
+
+	/*
+	 * Sockets created during restart are graft()ed, i.e. have a
+	 * valid @sk->sk_socket. Because only an fput() results in the
+	 * necessary sock_release(), we may leak the struct socket of
+	 * sockets that were not attached to a file. Therefore, if
+	 * @lastref is set, we hereby invoke sock_release() on sockets
+	 * that we have put into the objhash but were never attached
+	 * to a file.
+	 */
+	if (lastref && sk->sk_socket && !sk->sk_socket->file) {
+		struct socket *sock = sk->sk_socket;
+		sock_orphan(sk);
+		sock->sk = NULL;
+		sock_release(sock);
+	}
+
+	sock_put((struct sock *) ptr);
+}
+
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -362,6 +397,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* sock object */
+	{
+		.obj_name = "SOCKET",
+		.obj_type = CKPT_OBJ_SOCK,
+		.ref_drop = obj_sock_drop,
+		.ref_grab = obj_sock_grab,
+		.ref_users = obj_sock_users,
+		.checkpoint = checkpoint_sock,
+		.restore = restore_sock,
+	},
 };
 
 
@@ -751,6 +796,26 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
  */
 
 /**
+ * obj_sock_adjust_users - remove implicit reference on DEAD sockets
+ * @obj: CKPT_OBJ_SOCK object to adjust
+ *
+ * Sockets that have been disconnected from their struct file have
+ * a reference count one less than normal sockets.  The objhash's
+ * assumption of such a reference is therefore incorrect, so we correct
+ * it here.
+ */
+static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
+{
+	struct sock *sk = (struct sock *)obj->ptr;
+
+	if (sock_flag(sk, SOCK_DEAD)) {
+		obj->users--;
+		ckpt_debug("Adjusting SOCK %i count to %i\n",
+			   obj->objref, obj->users);
+	}
+}
+
+/**
  * ckpt_obj_contained - test if shared objects are contained in checkpoint
  * @ctx: checkpoint context
  *
@@ -773,6 +838,10 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
 			continue;
+
+		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
+			obj_sock_adjust_users(obj);
+
 		if (obj->ops->ref_users(obj->ptr) != obj->users) {
 			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
 			ckpt_write_err(ctx, "OP", "leak: usage (%d != %d (%s)",
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index ec98a43..92a21b2 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -29,6 +29,7 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
+#include <net/sock.h>
 
 /* ckpt_ctx: kflags */
 #define CKPT_CTX_CHECKPOINT_BIT		0
@@ -77,6 +78,12 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+/* socket functions */
+extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
+			      struct socket *socket,
+			      struct sockaddr *loc, unsigned *loc_len,
+			      struct sockaddr *rem, unsigned *rem_len);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e4dfbd7..ac16c59 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -12,6 +12,14 @@
 
 #include <linux/types.h>
 
+#ifdef __KERNEL__
+#include <linux/socket.h>
+#include <linux/un.h>
+#else
+#include <sys/socket.h>
+#include <sys/un.h>
+#endif
+
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
@@ -92,6 +100,11 @@ enum {
 	CKPT_HDR_SIGNAL_TASK,
 	CKPT_HDR_SIGPENDING,
 
+	CKPT_HDR_SOCKET = 701,
+	CKPT_HDR_SOCKET_QUEUE,
+	CKPT_HDR_SOCKET_BUFFER,
+	CKPT_HDR_SOCKET_UNIX,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -127,6 +140,7 @@ enum obj_type {
 	CKPT_OBJ_CRED,
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
+	CKPT_OBJ_SOCK,
 	CKPT_OBJ_MAX
 };
 
@@ -353,6 +367,7 @@ enum file_type {
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
 	CKPT_FILE_FIFO,
+	CKPT_FILE_SOCKET,
 	CKPT_FILE_MAX
 };
 
@@ -376,6 +391,78 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+/* socket */
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	struct { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u32 reuse;
+		__u16 family;
+		__u8 state;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct { /* struct sock */
+		__s64 rcvlowat;
+		__u64 flags;
+
+		__s64 rcvtimeo;
+		__s64 sndtimeo;
+
+		__u32 err;
+		__u32 err_soft;
+		__u32 priority;
+		__s32 rcvbuf;
+		__s32 sndbuf;
+		__u16 type;
+		__s16 backlog;
+
+		__u8 protocol;
+		__u8 state;
+		__u8 shutdown;
+		__u8 userlocks;
+		__u8 no_check;
+
+		struct linger linger;
+	} sock __attribute__ ((aligned(8)));
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_queue {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+	__u32 total_bytes;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__s32 sk_objref;
+	__s32 pr_objref;
+};
+
+#define CKPT_UNIX_LINKED 1
+struct ckpt_hdr_socket_unix {
+	struct ckpt_hdr h;
+	__s32 this;
+	__s32 peer;
+	__u32 peercred_uid;
+	__u32 peercred_gid;
+	__u32 flags;
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr_un laddr;
+	struct sockaddr_un raddr;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_file_socket {
+	struct ckpt_hdr_file common;
+	__s32 sock_objref;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/net.h b/include/linux/net.h
index b99f350..d1ce6eb 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -232,6 +232,8 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
+extern int	     sock_attach_fd(struct socket *sock, struct file *file,
+				    int flags);
 extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1614d78..e42a714 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -68,4 +68,18 @@ static inline int unix_sysctl_register(struct net *net) { return 0; }
 static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 #endif
+
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
+extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+			struct ckpt_hdr_socket *h);
+extern int unix_collect(struct ckpt_ctx *ctx, struct socket *sock);
+
+#else
+#define unix_checkpoint NULL
+#define unix_restore NULL
+#endif /* CONFIG_CHECKPOINT */
+
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 12530bf..ec351f9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1646,4 +1646,16 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+#ifdef CONFIG_CHECKPOINT
+/* Checkpoint/Restart Functions */
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+extern int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_sock(struct ckpt_ctx *ctx);
+extern int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+extern struct file *sock_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *h);
+extern int sock_file_collect(struct ckpt_ctx *ctx, struct file *file);
+#endif
+
 #endif	/* _SOCK_H */
diff --git a/net/Makefile b/net/Makefile
index ba324ae..91d12fe 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -66,3 +66,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
new file mode 100644
index 0000000..a11ec7a
--- /dev/null
+++ b/net/checkpoint.c
@@ -0,0 +1,752 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author(s): Dan Smith <danms@us.ibm.com>
+ *             Oren Laadan <orenl@cs.columbia.edu>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/socket.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/namei.h>
+#include <linux/syscalls.h>
+#include <linux/sched.h>
+#include <linux/fs_struct.h>
+
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	struct sock *sk;
+};
+
+static int sock_copy_buffers(struct sk_buff_head *from,
+			     struct sk_buff_head *to,
+			     uint32_t *total_bytes)
+{
+	int count1 = 0;
+	int count2 = 0;
+	int i;
+	struct sk_buff *skb;
+	struct sk_buff **skbs;
+
+	*total_bytes = 0;
+
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb)
+		count1++;
+	spin_unlock(&from->lock);
+
+	skbs = kzalloc(sizeof(*skbs) * count1, GFP_KERNEL);
+	if (!skbs)
+		return -ENOMEM;
+
+	for (i = 0; i < count1;  i++) {
+		skbs[i] = dev_alloc_skb(0);
+		if (!skbs[i])
+			goto err;
+	}
+
+	i = 0;
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb) {
+		if (++count2 > count1)
+			break; /* The queue changed as we read it */
+
+		skb_morph(skbs[i], skb);
+		skbs[i]->sk = skb->sk;
+		skb_queue_tail(to, skbs[i]);
+
+		*total_bytes += skb->len;
+		i++;
+	}
+	spin_unlock(&from->lock);
+
+	if (count1 != count2)
+		goto err;
+
+	kfree(skbs);
+
+	return count1;
+ err:
+	while (skb_dequeue(to))
+		; /* Pull all the buffers out of the queue */
+	for (i = 0; i < count1; i++)
+		kfree_skb(skbs[i]);
+	kfree(skbs);
+
+	return -EAGAIN;
+}
+
+static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				struct sk_buff_head *queue,
+				int dst_objref)
+{
+	struct sk_buff *skb;
+
+	skb_queue_walk(queue, skb) {
+		struct ckpt_hdr_socket_buffer *h;
+		int ret = 0;
+
+		/* FIXME: This could be a false positive for non-unix
+		 *        buffers, so add a type check here in the
+		 *        future
+		 */
+		if (UNIXCB(skb).fp) {
+			ckpt_write_err(ctx, "TE", "af_unix: pass fd", -EBUSY);
+			return -EBUSY;
+		}
+
+		/* The other ancillary messages are always present
+		 * unlike descriptors.  Even though we can't detect
+		 * them and fail the checkpoint, we're not at risk
+		 * because we don't save out (or restore) the control
+		 * information contained in the skb.
+		 */
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+		if (!h)
+			return -ENOMEM;
+
+		BUG_ON(!skb->sk);
+		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
+		if (ret < 0)
+			goto end;
+		h->sk_objref = ret;
+		h->pr_objref = dst_objref;
+
+		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+		if (ret < 0)
+			goto end;
+
+		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
+					  CKPT_HDR_BUFFER);
+	end:
+		ckpt_hdr_put(ctx, h);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int sock_write_buffers(struct ckpt_ctx *ctx,
+			      struct sk_buff_head *queue,
+			      int dst_objref)
+{
+	struct ckpt_hdr_socket_queue *h;
+	struct sk_buff_head tmpq;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (!h)
+		return -ENOMEM;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &h->total_bytes);
+	if (ret < 0)
+		goto out;
+
+	h->skb_count = ret;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (!ret)
+		ret = __sock_write_buffers(ctx, &tmpq, dst_objref);
+
+ out:
+	ckpt_hdr_put(ctx, h);
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+int sock_deferred_write_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	int ret;
+	int dst_objref;
+
+	dst_objref = ckpt_obj_lookup(ctx, dq->sk, CKPT_OBJ_SOCK);
+	if (dst_objref < 0) {
+		ckpt_write_err(ctx, "TE", "socket: owner gone?", dst_objref);
+		return dst_objref;
+	}
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue, dst_objref);
+	ckpt_debug("write recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue, dst_objref);
+	ckpt_debug("write send buffers: %i\n", ret);
+
+	return ret;
+}
+
+int sock_defer_write_buffers(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk = sk;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      sock_deferred_write_buffers, NULL);
+}
+
+int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
+		       struct sockaddr *loc, unsigned *loc_len,
+		       struct sockaddr *rem, unsigned *rem_len)
+{
+	int ret;
+
+	ret = sock_getname(sock, loc, loc_len);
+	if (ret) {
+		ckpt_write_err(ctx, "TEP", "socket: getname local", ret, sock);
+		return -EINVAL;
+	}
+
+	ret = sock_getpeer(sock, rem, rem_len);
+	if (ret) {
+		if ((sock->sk->sk_type != SOCK_DGRAM) &&
+		    (sock->sk->sk_state == TCP_ESTABLISHED)) {
+			ckpt_write_err(ctx, "TEP", "socket: getname peer",
+				       ret, sock);
+			return -EINVAL;
+		}
+		*rem_len = 0;
+	}
+
+	return 0;
+}
+
+static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
+{
+	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
+		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
+
+	if (h->sock.shutdown & ~SHUTDOWN_MASK)
+		return -EINVAL;
+	if (h->sock.userlocks & ~userlocks_mask)
+		return -EINVAL;
+	if (!ckpt_validate_errno(h->sock.err))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sock_cptrst_opt(int op, struct socket *sock,
+			   int optname, char *opt, int len)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+
+	if (op == CKPT_CPT)
+		ret = sock_getsockopt(sock, SOL_SOCKET, optname, opt, &len);
+	else
+		ret = sock_setsockopt(sock, SOL_SOCKET, optname, opt, len);
+
+	set_fs(fs);
+
+	return ret;
+}
+
+#define CKPT_COPY_SOPT(op, sk, name, opt) \
+	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
+
+static int sock_cptrst_bufopts(int op, struct sock *sk,
+			       struct ckpt_hdr_socket *h)
+{
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sk, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
+			ckpt_debug("Failed to set SO_RCVBUF");
+			return -EINVAL;
+		}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_SNDBUF, &h->sock.sndbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sk, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
+			ckpt_debug("Failed to set SO_SNDBUF");
+			return -EINVAL;
+		}
+
+	/* It's silly that we have to fight ourselves here, but
+	 * sock_setsockopt() doubles the initial value, so divide here
+	 * to store the user's value and avoid doubling on restart
+	 */
+	if ((op == CKPT_CPT) && (h->sock.rcvbuf != SOCK_MIN_RCVBUF))
+		h->sock.rcvbuf >>= 1;
+
+	if ((op == CKPT_CPT) && (h->sock.sndbuf != SOCK_MIN_SNDBUF))
+		h->sock.sndbuf >>= 1;
+
+	return 0;
+}
+
+struct sock_flag_mapping {
+	int opt;
+	int flag;
+};
+
+struct sock_flag_mapping sk_flag_map[] = {
+	{SO_OOBINLINE, SOCK_URGINLINE},
+	{SO_KEEPALIVE, SOCK_KEEPOPEN},
+	{SO_BROADCAST, SOCK_BROADCAST},
+	{SO_TIMESTAMP, SOCK_RCVTSTAMP},
+	{SO_TIMESTAMPNS, SOCK_RCVTSTAMPNS},
+	{SO_DEBUG, SOCK_DBG},
+	{SO_DONTROUTE, SOCK_LOCALROUTE},
+};
+
+struct sock_flag_mapping sock_flag_map[] = {
+	{SO_PASSCRED, SOCK_PASSCRED},
+};
+
+static int sock_restore_flag(struct socket *sock,
+			     unsigned long *flags,
+			     int flag,
+			     int option)
+{
+	int v = 1;
+	int ret = 0;
+
+	if (test_and_clear_bit(flag, flags))
+		ret = sock_setsockopt(sock, SOL_SOCKET, option,
+				      (char *)&v, sizeof(v));
+
+	return ret;
+}
+
+
+static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
+{
+	unsigned long sk_flags = h->sock.flags;
+	unsigned long sock_flags = h->socket.flags;
+	int ret;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(sk_flag_map); i++) {
+		int opt = sk_flag_map[i].opt;
+		int flag = sk_flag_map[i].flag;
+		ret = sock_restore_flag(sock, &sk_flags, flag, opt);
+		if (ret) {
+			ckpt_debug("Failed to set skopt %i: %i\n", opt, ret);
+			return ret;
+		}
+	}
+
+	for (i = 0; i < ARRAY_SIZE(sock_flag_map); i++) {
+		int opt = sock_flag_map[i].opt;
+		int flag = sock_flag_map[i].flag;
+		ret = sock_restore_flag(sock, &sock_flags, flag, opt);
+		if (ret) {
+			ckpt_debug("Failed to set sockopt %i: %i\n", opt, ret);
+			return ret;
+		}
+	}
+
+	/* TODO: Handle SOCK_TIMESTAMPING_* flags */
+	if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
+		ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
+		return -ENOSYS;
+	}
+
+	if (test_and_clear_bit(SOCK_DEAD, &sk_flags))
+		sock_set_flag(sock->sk, SOCK_DEAD);
+
+
+	/* Anything that is still set in the flags that isn't part of
+	 * our protocol's default set, indicates an error
+	 */
+	if (sk_flags & ~sock->sk->sk_flags) {
+		ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int sock_copy_timeval(int op, struct sock *sk,
+			     int sockopt, __s64 *saved)
+{
+	struct timeval tv;
+
+	if (op == CKPT_CPT) {
+		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
+			return -EINVAL;
+		*saved = timeval_to_ns(&tv);
+	} else {
+		tv = ns_to_timeval(*saved);
+		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
+		       struct ckpt_hdr_socket *h, int op)
+{
+	if (sk->sk_socket) {
+		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
+	}
+
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sk->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sk->sk_family);
+
+	CKPT_COPY(op, h->sock.shutdown, sk->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sk->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sk->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sk->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sk->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sk->sk_err_soft);
+	CKPT_COPY(op, h->sock.type, sk->sk_type);
+	CKPT_COPY(op, h->sock.state, sk->sk_state);
+	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
+
+	if (sock_cptrst_bufopts(op, sk, h))
+		return -EINVAL;
+
+	if (CKPT_COPY_SOPT(op, sk, SO_REUSEADDR, &h->sock_common.reuse)) {
+		ckpt_debug("Failed to set SO_REUSEADDR");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_PRIORITY, &h->sock.priority)) {
+		ckpt_debug("Failed to set SO_PRIORITY");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVLOWAT, &h->sock.rcvlowat)) {
+		ckpt_debug("Failed to set SO_RCVLOWAT");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_LINGER, &h->sock.linger)) {
+		ckpt_debug("Failed to set SO_LINGER");
+		return -EINVAL;
+	}
+
+	if (sock_copy_timeval(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
+		ckpt_debug("Failed to set SO_SNDTIMEO");
+		return -EINVAL;
+	}
+
+	if (sock_copy_timeval(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
+		ckpt_debug("Failed to set SO_RCVTIMEO");
+		return -EINVAL;
+	}
+
+	if (op == CKPT_CPT) {
+		h->sock.flags = sk->sk_flags;
+		h->socket.flags = sk->sk_socket->flags;
+	} else {
+		int ret;
+		mm_segment_t old_fs;
+
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = sock_restore_flags(sk->sk_socket, h);
+		set_fs(old_fs);
+		if (ret)
+			return ret;
+	}
+
+	if ((h->socket.state == SS_CONNECTED) &&
+	    (h->sock.state != TCP_ESTABLISHED)) {
+		ckpt_debug("socket/sock in inconsistent state: %i/%i",
+			   h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->sock.state < TCP_ESTABLISHED) ||
+		   (h->sock.state >= TCP_MAX_STATES)) {
+		ckpt_debug("sock in invalid state: %i", h->sock.state);
+		return -EINVAL;
+	} else if ((h->socket.state < SS_FREE) ||
+		   (h->socket.state > SS_DISCONNECTING)) {
+		ckpt_debug("socket in invalid state: %i",
+			   h->socket.state);
+		return -EINVAL;
+	}
+
+	if (op == CKPT_RST)
+		return sock_cptrst_verify(h);
+	else
+		return 0;
+}
+
+static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+	struct ckpt_hdr_socket *h;
+	int ret;
+
+	if (!sock->ops->checkpoint) {
+		ckpt_write_err(ctx, "TEVP", "socket: proto_ops",
+			       -ENOSYS, sock->ops, sock);
+		return -ENOSYS;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (!h)
+		return -ENOMEM;
+
+	/* part I: common to all sockets */
+	ret = sock_cptrst(ctx, sk, h, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	/* part II: per socket type state */
+	ret = sock->ops->checkpoint(ctx, sock);
+	if (ret < 0)
+		goto out;
+
+	/* part III: socket buffers */
+	if ((sk->sk_state != TCP_LISTEN) && (!sock_flag(sk, SOCK_DEAD)))
+		ret = sock_defer_write_buffers(ctx, sk);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct socket *sock;
+	int ret;
+
+	if (sk->sk_socket)
+		return __do_sock_checkpoint(ctx, sk);
+
+	/* Temporarily adopt this orphan socket */
+	ret = sock_create(sk->sk_family, sk->sk_type, 0, &sock);
+	if (ret < 0)
+		return ret;
+	sock_graft(sk, sock);
+
+	ret = __do_sock_checkpoint(ctx, sk);
+
+	sock_orphan(sk);
+	sock->sk = NULL;
+	sock_release(sock);
+
+	return ret;
+}
+
+int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_sock_checkpoint(ctx, (struct sock *)ptr);
+}
+
+int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_socket *h;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	h->sock_objref = checkpoint_obj(ctx, sk, CKPT_OBJ_SOCK);
+	if (h->sock_objref < 0) {
+		ret = h->sock_objref;
+		goto out;
+	}
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int sock_collect_skbs(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct sk_buff_head tmpq;
+	struct sk_buff *skb;
+	int ret = 0;
+	int bytes;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &bytes);
+	if (ret < 0)
+		return ret;
+
+	skb_queue_walk(&tmpq, skb) {
+		/* Socket buffers do not maintain a ref count on their
+		 * owning sock because they're counted in sock_wmem_alloc.
+		 * So, we only need to collect sockets from the queue that
+		 * won't be collected any other way (i.e. DEAD sockets that
+		 * are hanging around only because they're waiting for us
+		 * to process their skb.
+		 */
+
+		if (!ckpt_obj_lookup(ctx, skb->sk, CKPT_OBJ_SOCK) &&
+		    sock_flag(skb->sk, SOCK_DEAD)) {
+			ret = ckpt_obj_collect(ctx, skb->sk, CKPT_OBJ_SOCK);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+int sock_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_write_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_receive_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_obj_collect(ctx, sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sock->ops->collect)
+		ret = sock->ops->collect(ctx, sock);
+
+	return ret;
+}
+
+static struct file *sock_alloc_attach_fd(struct socket *sock)
+{
+	struct file *file;
+	int err;
+
+	file = get_empty_filp();
+	if (!file)
+		return ERR_PTR(ENOMEM);
+
+	err = sock_attach_fd(sock, file, 0);
+	if (err < 0) {
+		put_filp(file);
+		file = ERR_PTR(err);
+	}
+
+	/* Since objhash assumes the initial reference for a socket,
+	 * we bump it here for this descriptor, unlike other places in
+	 * the socket code which assume the descriptor is the owner.
+	 */
+	sock_hold(sock->sk);
+
+	return file;
+}
+
+struct sock *do_sock_restore(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_socket *h;
+	struct socket *sock;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	/* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
+	h->sock.type &= SOCK_TYPE_MASK;
+
+	ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
+	if (ret < 0)
+		goto err;
+
+	if (!sock->ops->restore) {
+		ckpt_debug("proto_ops lacks checkpoint: %pS\n", sock->ops);
+		ret = -EINVAL;
+		goto err;
+	}
+
+	/*
+	 * part II: per socket type state
+	 * (also takes care of part III: socket buffer)
+	 */
+	ret = sock->ops->restore(ctx, sock, h);
+	if (ret < 0)
+		goto err;
+
+	/* part I: common to all sockets */
+	ret = sock_cptrst(ctx, sock->sk, h, CKPT_RST);
+	if (ret < 0)
+		goto err;
+
+	ckpt_hdr_put(ctx, h);
+	return sock->sk;
+ err:
+	ckpt_hdr_put(ctx, h);
+	sock_release(sock);
+	return ERR_PTR(ret);
+}
+
+void *restore_sock(struct ckpt_ctx *ctx)
+{
+	return do_sock_restore(ctx);
+}
+
+struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_socket *h = (struct ckpt_hdr_file_socket *)ptr;
+	struct sock *sk;
+	struct file *file;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE || ptr->f_type != CKPT_FILE_SOCKET)
+		return ERR_PTR(-EINVAL);
+
+	sk = ckpt_obj_fetch(ctx, h->sock_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk))
+		return ERR_PTR(PTR_ERR(sk));
+
+	file = sock_alloc_attach_fd(sk->sk_socket);
+	if (IS_ERR(file))
+		return file;
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+
+	return file;
+}
diff --git a/net/socket.c b/net/socket.c
index 63c4498..0a4d539 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -140,6 +140,10 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =   sock_file_checkpoint,
+	.collect = sock_file_collect,
+#endif
 };
 
 /*
@@ -368,7 +372,7 @@ static int sock_alloc_fd(struct file **filep, int flags)
 	return fd;
 }
 
-static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
+int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
 	struct qstr name = { .name = "" };
diff --git a/net/unix/Makefile b/net/unix/Makefile
index b852a2b..fbff1e6 100644
--- a/net/unix/Makefile
+++ b/net/unix/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_UNIX)	+= unix.o
 
 unix-y			:= af_unix.o garbage.o
 unix-$(CONFIG_SYSCTL)	+= sysctl_net_unix.o
+unix-$(CONFIG_CHECKPOINT) += checkpoint.o
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fc3ebb9..b3d4f16 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -523,6 +523,9 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -544,6 +547,9 @@ static const struct proto_ops unix_dgram_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -565,6 +571,9 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static struct proto unix_proto = {
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
new file mode 100644
index 0000000..8b7cb22
--- /dev/null
+++ b/net/unix/checkpoint.c
@@ -0,0 +1,634 @@
+#include <linux/namei.h>
+#include <linux/file.h>
+#include <linux/fs_struct.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/user.h>
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+struct dq_join {
+	struct ckpt_ctx *ctx;
+	int src_objref;
+	int dst_objref;
+};
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	int sk_objref; /* objref of the socket these buffers belong to */
+};
+
+#define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
+
+static inline int unix_need_cwd(struct sockaddr_un *addr, unsigned long len)
+{
+	return (!UNIX_ADDR_EMPTY(len)) &&
+		addr->sun_path[0] &&
+		(addr->sun_path[0] != '/');
+}
+
+static int unix_join(struct sock *src, struct sock *dst)
+{
+	if (unix_sk(src)->peer != NULL)
+		return 0; /* We're second */
+
+	sock_hold(dst);
+	unix_sk(src)->peer = dst;
+
+	return 0;
+
+}
+
+static int unix_deferred_join(void *data)
+{
+	struct dq_join *dq = (struct dq_join *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *src;
+	struct sock *dst;
+
+	src = ckpt_obj_fetch(ctx, dq->src_objref, CKPT_OBJ_SOCK);
+	if (!src) {
+		ckpt_debug("Missing src sock ref %i\n", dq->src_objref);
+		return -EINVAL;
+	}
+
+	dst = ckpt_obj_fetch(ctx, dq->dst_objref, CKPT_OBJ_SOCK);
+	if (!src) {
+		ckpt_debug("Missing dst sock ref %i\n", dq->dst_objref);
+		return -EINVAL;
+	}
+
+	return unix_join(src, dst);
+}
+
+static int unix_defer_join(struct ckpt_ctx *ctx,
+			   int src_objref,
+			   int dst_objref)
+{
+	struct dq_join dq;
+
+	dq.ctx = ctx;
+	dq.src_objref = src_objref;
+	dq.dst_objref = dst_objref;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_join, NULL);
+}
+
+static int unix_write_cwd(struct ckpt_ctx *ctx,
+			  struct sock *sk, const char *sockpath)
+{
+	struct path path;
+	char *buf;
+	char *fqpath;
+	int offset;
+	int len = PATH_MAX;
+	int ret = -ENOENT;
+
+	buf = kmalloc(len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	path.dentry = unix_sk(sk)->dentry;
+	path.mnt = unix_sk(sk)->mnt;
+
+	fqpath = ckpt_fill_fname(&path, &ctx->fs_mnt, buf, &len);
+	if (IS_ERR(fqpath)) {
+		ret = PTR_ERR(fqpath);
+		goto out;
+	}
+
+	offset = strlen(fqpath) - strlen(sockpath);
+	if (offset <= 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	fqpath[offset] = '\0';
+
+	ckpt_debug("writing socket directory: %s\n", fqpath);
+	ret = ckpt_write_string(ctx, fqpath, offset + 1);
+ out:
+	kfree(buf);
+	return ret;
+}
+
+int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct unix_sock *sk = unix_sk(sock->sk);
+	struct ckpt_hdr_socket_unix *un;
+	int new;
+	int ret = -ENOMEM;
+
+	if ((sock->sk->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&sock->sk->sk_receive_queue)) {
+		ckpt_write_err(ctx, "TEP", "af_unix: listen with pending peers",
+			       -EBUSY, sock);
+		return -EBUSY;
+	}
+
+	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (!un)
+		return -EINVAL;
+
+	ret = ckpt_sock_getnames(ctx, sock,
+				 (struct sockaddr *)&un->laddr, &un->laddr_len,
+				 (struct sockaddr *)&un->raddr, &un->raddr_len);
+	if (ret)
+		goto out;
+
+	if (sk->dentry && (sk->dentry->d_inode->i_nlink > 0))
+		un->flags |= CKPT_UNIX_LINKED;
+
+	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
+	if (un->this < 0)
+		goto out;
+
+	if (sk->peer)
+		un->peer = checkpoint_obj(ctx, sk->peer, CKPT_OBJ_SOCK);
+	else
+		un->peer = 0;
+
+	if (un->peer < 0) {
+		ret = un->peer;
+		goto out;
+	}
+
+	un->peercred_uid = sock->sk->sk_peercred.uid;
+	un->peercred_gid = sock->sk->sk_peercred.gid;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
+	if (ret < 0)
+		goto out;
+
+	if (unix_need_cwd(&un->laddr, un->laddr_len))
+		ret = unix_write_cwd(ctx, sock->sk, un->laddr.sun_path);
+ out:
+	ckpt_hdr_put(ctx, un);
+
+	return ret;
+}
+
+int unix_collect(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct unix_sock *sk = unix_sk(sock->sk);
+	int ret;
+
+	ret = ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sk->peer)
+		ret = ckpt_obj_collect(ctx, sk->peer, CKPT_OBJ_SOCK);
+
+	return 0;
+}
+
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
+				    struct sockaddr *addr,
+				    unsigned int addrlen)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	struct sock *sk;
+	struct msghdr msg;
+	struct kvec kvec;
+	uint8_t sock_shutdown;
+	uint8_t peer_shutdown = 0;
+	void *buf = NULL;
+	int sndbuf;
+	int len;
+	int ret = 0;
+
+	memset(&msg, 0, sizeof(msg));
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
+	if (len < 0) {
+		ret = len;
+		goto out;
+	} else if (len > SKB_MAX_ALLOC) {
+		ckpt_debug("Socket buffer too big (%i > %lu)",
+			   len, SKB_MAX_ALLOC);
+		ret = -ENOSPC;
+		goto out;
+	}
+
+	sk = ckpt_obj_fetch(ctx, h->sk_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk)) {
+		ret = PTR_ERR(sk);
+		goto out;
+	}
+
+	/* If we don't have a destination or a peer and we know the
+	 * destination of this skb, then we must need to join with our
+	 * peer
+	 */
+	if (!addrlen && !unix_sk(sk)->peer) {
+		struct sock *pr;
+		pr = ckpt_obj_fetch(ctx, h->pr_objref, CKPT_OBJ_SOCK);
+		if (IS_ERR(pr)) {
+			ckpt_debug("Failed to get our peer: %li\n", PTR_ERR(pr));
+			ret = PTR_ERR(pr);
+			goto out;
+		}
+		ret = unix_join(sk, pr);
+		if (ret < 0) {
+			ckpt_debug("Failed to join: %i\n", ret);
+			goto out;
+		}
+	}
+
+	kvec.iov_len = len;
+	buf = kmalloc(len, GFP_KERNEL);
+	kvec.iov_base = buf;
+	if (!buf) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = ckpt_kread(ctx, kvec.iov_base, len);
+	if (ret < 0)
+		goto out;
+
+	msg.msg_name = addr;
+	msg.msg_namelen = addrlen;
+
+	/* If peer is shutdown, unshutdown it for this process */
+	sock_shutdown = sk->sk_shutdown;
+	sk->sk_shutdown &= ~SHUTDOWN_MASK;
+
+	/* Unshutdown peer too, if necessary */
+	if (unix_sk(sk)->peer) {
+		peer_shutdown = unix_sk(sk)->peer->sk_shutdown;
+		unix_sk(sk)->peer->sk_shutdown &= ~SHUTDOWN_MASK;
+	}
+
+	/* Make sure there's room in the send buffer */
+	sndbuf = sk->sk_sndbuf;
+	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len) &&
+	    capable(CAP_NET_ADMIN))
+		sk->sk_sndbuf += len;
+	else
+		sk->sk_sndbuf = sysctl_wmem_max;
+
+	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, len);
+	ckpt_debug("kernel_sendmsg(%i,%i): %i\n", h->sk_objref, len, ret);
+	if ((ret > 0) && (ret != len))
+		ret = -ENOMEM;
+
+	sk->sk_sndbuf = sndbuf;
+	sk->sk_shutdown = sock_shutdown;
+	if (peer_shutdown)
+		unix_sk(sk)->peer->sk_shutdown = peer_shutdown;
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(buf);
+	return ret;
+}
+
+static int unix_read_buffers(struct ckpt_ctx *ctx,
+			     struct sockaddr *addr,
+			     unsigned int addrlen)
+{
+	struct ckpt_hdr_socket_queue *h;
+	int ret = 0;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	for (i = 0; i < h->skb_count; i++) {
+		ret = sock_read_buffer_sendmsg(ctx, addr, addrlen);
+		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
+		if (ret < 0)
+			goto out;
+
+		if (ret > h->total_bytes) {
+			ckpt_debug("Buffers exceeded claim");
+			ret = -EINVAL;
+			goto out;
+		}
+
+		h->total_bytes -= ret;
+		ret = 0;
+	}
+
+	ret = h->skb_count;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int unix_deferred_restore_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *sk;
+	struct sockaddr *addr = NULL;
+	unsigned int addrlen = 0;
+	int ret;
+
+	sk = ckpt_obj_fetch(ctx, dq->sk_objref, CKPT_OBJ_SOCK);
+	if (!sk) {
+		ckpt_debug("Missing sock ref %i\n", dq->sk_objref);
+		return -EINVAL;
+	}
+
+	if ((sk->sk_type == SOCK_DGRAM) && (unix_sk(sk)->addr != NULL)) {
+		addr = (struct sockaddr *)&unix_sk(sk)->addr->name;
+		addrlen = unix_sk(sk)->addr->len;
+	}
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read send buffers: %i\n", ret);
+	if (ret > 0)
+		ret = -EINVAL; /* No send buffers for UNIX sockets */
+
+	return ret;
+}
+
+static int unix_defer_restore_buffers(struct ckpt_ctx *ctx, int sk_objref)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk_objref = sk_objref;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_restore_buffers, NULL);
+}
+
+static struct unix_address *unix_makeaddr(struct sockaddr_un *sun_addr,
+					  unsigned len)
+{
+	struct unix_address *addr;
+
+	if (len > sizeof(struct sockaddr_un))
+		return ERR_PTR(-EINVAL);
+
+	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
+	if (!addr)
+		return ERR_PTR(-ENOMEM);
+
+	memcpy(addr->name, sun_addr, len);
+	addr->len = len;
+	atomic_set(&addr->refcnt, 1);
+
+	return addr;
+}
+
+static int unix_restore_connected(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_socket *h,
+				  struct ckpt_hdr_socket_unix *un,
+				  struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr *addr = NULL;
+	unsigned long flags = h->sock.flags;
+	unsigned int addrlen = 0;
+	int dead = test_bit(SOCK_DEAD, &flags);
+	int ret = 0;
+
+
+	if (un->peer == 0) {
+		/* These get propagated to the msghdr, so only set them
+		 * if we're not connected to a peer, else we'll get an error
+		 * when we sendmsg()
+		 */
+		addr = (struct sockaddr *)&un->laddr;
+		addrlen = un->laddr_len;
+	}
+
+	sk->sk_peercred.pid = task_tgid_vnr(current);
+
+	if (may_setuid(ctx->realcred->user->user_ns, un->peercred_uid) &&
+	    may_setgid(un->peercred_gid)) {
+		sk->sk_peercred.uid = un->peercred_uid;
+		sk->sk_peercred.gid = un->peercred_gid;
+	} else {
+		ckpt_debug("peercred %i:%i would require setuid",
+			   un->peercred_uid, un->peercred_gid);
+		return -EPERM;
+	}
+
+	if (!dead && (un->peer > 0)) {
+		ret = unix_defer_join(ctx, un->this, un->peer);
+		ckpt_debug("unix_defer_join: %i\n", ret);
+	}
+
+	if (!dead && !ret)
+		ret = unix_defer_restore_buffers(ctx, un->this);
+
+	return ret;
+}
+
+static int unix_unlink(const char *name)
+{
+	struct path spath;
+	struct path ppath;
+	int ret;
+
+	ret = kern_path(name, 0, &spath);
+	if (ret)
+		return ret;
+
+	ret = kern_path(name, LOOKUP_PARENT, &ppath);
+	if (ret)
+		goto out_s;
+
+	if (!spath.dentry) {
+		ckpt_debug("No dentry found for %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	if (!ppath.dentry || !ppath.dentry->d_inode) {
+		ckpt_debug("No inode for parent of %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	ret = vfs_unlink(ppath.dentry->d_inode, spath.dentry);
+ out_p:
+	path_put(&ppath);
+ out_s:
+	path_put(&spath);
+
+	return ret;
+}
+
+/* Call bind() for socket, optionally changing (temporarily) to @path first
+ * if non-NULL
+ */
+static int unix_chdir_and_bind(struct socket *sock,
+			       const char *path,
+			       struct sockaddr *addr,
+			       unsigned long addrlen)
+{
+	struct sockaddr_un *un = (struct sockaddr_un *)addr;
+	struct path cur = { .mnt = NULL, .dentry = NULL };
+	struct path dir = { .mnt = NULL, .dentry = NULL };
+	int ret;
+
+	if (path) {
+		ckpt_debug("switching to cwd %s for unix bind", path);
+
+		ret = kern_path(path, 0, &dir);
+		if (ret)
+			return ret;
+
+		ret = inode_permission(dir.dentry->d_inode,
+				       MAY_EXEC | MAY_ACCESS);
+		if (ret)
+			goto out;
+
+		write_lock(&current->fs->lock);
+		cur = current->fs->pwd;
+		current->fs->pwd = dir;
+		write_unlock(&current->fs->lock);
+	}
+
+	ret = unix_unlink(un->sun_path);
+	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
+	if ((ret == 0) || (ret == -ENOENT))
+		ret = sock_bind(sock, addr, addrlen);
+
+	if (path) {
+		write_lock(&current->fs->lock);
+		current->fs->pwd = cur;
+		write_unlock(&current->fs->lock);
+	}
+ out:
+	if (path)
+		path_put(&dir);
+
+	return ret;
+}
+
+static int unix_fakebind(struct socket *sock,
+			 struct sockaddr_un *addr, unsigned long len)
+{
+	struct unix_address *uaddr;
+
+	uaddr = unix_makeaddr(addr, len);
+	if (IS_ERR(uaddr))
+		return PTR_ERR(uaddr);
+
+	unix_sk(sock->sk)->addr = uaddr;
+
+	return 0;
+}
+
+static int unix_restore_bind(struct ckpt_hdr_socket *h,
+			     struct ckpt_hdr_socket_unix *un,
+			     struct socket *sock,
+			     const char *path)
+{
+	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
+	unsigned long len = un->laddr_len;
+	unsigned long flags = h->sock.flags;
+	int dead = test_bit(SOCK_DEAD, &flags);
+
+	if (dead)
+		return unix_fakebind(sock, &un->laddr, len);
+	else if (!un->laddr.sun_path[0])
+		return sock_bind(sock, addr, len);
+	else if (!(un->flags & CKPT_UNIX_LINKED))
+		return unix_fakebind(sock, &un->laddr, len);
+	else
+		return unix_chdir_and_bind(sock, path, addr, len);
+}
+
+/* Some easy pre-flight checks before we get underway */
+static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
+{
+	struct net *net = sock_net(sock->sk);
+	unsigned long sk_flags = h->sock.flags;
+
+	if ((h->socket.state == SS_CONNECTING) ||
+	    (h->socket.state == SS_DISCONNECTING) ||
+	    (h->socket.state == SS_FREE)) {
+		ckpt_debug("AF_UNIX socket can't be SS_(DIS)CONNECTING");
+		return -EINVAL;
+	}
+
+	/* AF_UNIX overloads the backlog setting to define the maximum
+	 * queue length for DGRAM sockets.  Make sure we don't let the
+	 * caller exceed that value on restart.
+	 */
+	if ((h->sock.type == SOCK_DGRAM) &&
+	    (h->sock.backlog > net->unx.sysctl_max_dgram_qlen)) {
+		ckpt_debug("DGRAM backlog of %i exceeds system max of %i\n",
+			   h->sock.backlog, net->unx.sysctl_max_dgram_qlen);
+		return -EINVAL;
+	}
+
+	if (test_bit(SOCK_USE_WRITE_QUEUE, &sk_flags)) {
+		ckpt_debug("AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+		 struct ckpt_hdr_socket *h)
+
+{
+	struct ckpt_hdr_socket_unix *un;
+	int ret = -EINVAL;
+	char *cwd = NULL;
+
+	ret = unix_precheck(sock, h);
+	if (ret)
+		return ret;
+
+	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (IS_ERR(un))
+		return PTR_ERR(un);
+
+	if (un->peer < 0)
+		goto out;
+
+	if (unix_need_cwd(&un->laddr, un->laddr_len)) {
+		cwd = ckpt_read_string(ctx, PATH_MAX);
+		if (IS_ERR(cwd)) {
+			ret = PTR_ERR(cwd);
+			goto out;
+		}
+	}
+
+	if ((h->sock.state != TCP_ESTABLISHED) &&
+	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
+		ret = unix_restore_bind(h, un, sock, cwd);
+		if (ret)
+			goto out;
+	}
+
+	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
+		ret = unix_restore_connected(ctx, h, un, sock);
+	else if (h->sock.state == TCP_LISTEN)
+		ret = sock->ops->listen(sock, h->sock.backlog);
+	else
+		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
+ out:
+	ckpt_hdr_put(ctx, un);
+	kfree(cwd);
+	return ret;
+}
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
