Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 337B46B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 06:04:45 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o5NA4VYq000623
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5NA4cao1446070
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:38 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5NA4ZMR005459
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 20:04:38 +1000
From: "Ian Munsie" <imunsie@au1.ibm.com>
Subject: [PATCH 31/40] trace syscalls: Convert various generic compat syscalls
Date: Wed, 23 Jun 2010 20:03:12 +1000
Message-Id: <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com>
In-Reply-To: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Cc: Jason Baron <jbaron@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <michael@ellerman.id.au>, Ian Munsie <imunsie@au1.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, David Howells <dhowells@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@suse.de>, Dinakar Guniguntala <dino@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Eric Biederman <ebiederm@xmission.com>, Simon Kagstrom <simon.kagstrom@netinsight.net>, WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.org>, Roland McGrath <roland@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mike Frysinger <vapier.adi@gmail.com>, Andi Kleen <ak@linux.intel.com>, Neil Horman <nhorman@tuxdriver.com>, Eric Dumazet <eric.dumazet@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Berg <johannes@sipsolutions.net>, Roel Kluin <roel.kluin@gmail.com>, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Ian Munsie <imunsie@au1.ibm.com>

This patch converts numerous trivial compat syscalls through the generic
kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.

Signed-off-by: Ian Munsie <imunsie@au1.ibm.com>
---
 fs/compat.c            |    2 +-
 fs/compat_ioctl.c      |    4 ++--
 ipc/compat_mq.c        |   24 ++++++++++++------------
 kernel/futex_compat.c  |   19 ++++++++++---------
 kernel/kexec.c         |    8 ++++----
 kernel/ptrace.c        |    4 ++--
 kernel/sysctl_binary.c |    2 +-
 mm/mempolicy.c         |   19 ++++++++++---------
 net/compat.c           |   28 ++++++++++++++--------------
 9 files changed, 56 insertions(+), 54 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index df0b502..9897b7b 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1823,7 +1823,7 @@ struct compat_sel_arg_struct {
 	compat_uptr_t tvp;
 };
 
-asmlinkage long compat_sys_old_select(struct compat_sel_arg_struct __user *arg)
+COMPAT_SYSCALL_DEFINE1(old_select, struct compat_sel_arg_struct __user *, arg)
 {
 	struct compat_sel_arg_struct a;
 
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 641640d..60d7e91 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1674,8 +1674,8 @@ static int compat_ioctl_check_table(unsigned int xcmd)
 	return ioctl_pointer[i] == xcmd;
 }
 
-asmlinkage long compat_sys_ioctl(unsigned int fd, unsigned int cmd,
-				unsigned long arg)
+COMPAT_SYSCALL_DEFINE3(ioctl, unsigned int, fd, unsigned int, cmd,
+				unsigned long, arg)
 {
 	struct file *filp;
 	int error = -EBADF;
diff --git a/ipc/compat_mq.c b/ipc/compat_mq.c
index d8d1e9f..53593d3 100644
--- a/ipc/compat_mq.c
+++ b/ipc/compat_mq.c
@@ -46,9 +46,9 @@ static inline int put_compat_mq_attr(const struct mq_attr *attr,
 		| __put_user(attr->mq_curmsgs, &uattr->mq_curmsgs);
 }
 
-asmlinkage long compat_sys_mq_open(const char __user *u_name,
-			int oflag, compat_mode_t mode,
-			struct compat_mq_attr __user *u_attr)
+COMPAT_SYSCALL_DEFINE4(mq_open, const char __user *, u_name,
+			int, oflag, compat_mode_t, mode,
+			struct compat_mq_attr __user *, u_attr)
 {
 	void __user *p = NULL;
 	if (u_attr && oflag & O_CREAT) {
@@ -75,10 +75,10 @@ static int compat_prepare_timeout(struct timespec __user * *p,
 	return 0;
 }
 
-asmlinkage long compat_sys_mq_timedsend(mqd_t mqdes,
-			const char __user *u_msg_ptr,
-			size_t msg_len, unsigned int msg_prio,
-			const struct compat_timespec __user *u_abs_timeout)
+COMPAT_SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes,
+			const char __user *, u_msg_ptr,
+			size_t, msg_len, unsigned int, msg_prio,
+			const struct compat_timespec __user *, u_abs_timeout)
 {
 	struct timespec __user *u_ts;
 
@@ -102,8 +102,8 @@ asmlinkage ssize_t compat_sys_mq_timedreceive(mqd_t mqdes,
 			u_msg_prio, u_ts);
 }
 
-asmlinkage long compat_sys_mq_notify(mqd_t mqdes,
-			const struct compat_sigevent __user *u_notification)
+COMPAT_SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
+			const struct compat_sigevent __user *, u_notification)
 {
 	struct sigevent __user *p = NULL;
 	if (u_notification) {
@@ -119,9 +119,9 @@ asmlinkage long compat_sys_mq_notify(mqd_t mqdes,
 	return sys_mq_notify(mqdes, p);
 }
 
-asmlinkage long compat_sys_mq_getsetattr(mqd_t mqdes,
-			const struct compat_mq_attr __user *u_mqstat,
-			struct compat_mq_attr __user *u_omqstat)
+COMPAT_SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
+			const struct compat_mq_attr __user *, u_mqstat,
+			struct compat_mq_attr __user *, u_omqstat)
 {
 	struct mq_attr mqstat;
 	struct mq_attr __user *p = compat_alloc_user_space(2 * sizeof(*p));
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index d49afb2..d798c9f 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -10,6 +10,7 @@
 #include <linux/compat.h>
 #include <linux/nsproxy.h>
 #include <linux/futex.h>
+#include <linux/syscalls.h>
 
 #include <asm/uaccess.h>
 
@@ -114,9 +115,9 @@ void compat_exit_robust_list(struct task_struct *curr)
 	}
 }
 
-asmlinkage long
-compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
-			   compat_size_t len)
+COMPAT_SYSCALL_DEFINE2(set_robust_list,
+		struct compat_robust_list_head __user *, head,
+		compat_size_t, len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -129,9 +130,9 @@ compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 	return 0;
 }
 
-asmlinkage long
-compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
-			   compat_size_t __user *len_ptr)
+COMPAT_SYSCALL_DEFINE3(get_robust_list, int, pid,
+		compat_uptr_t __user *, head_ptr,
+		compat_size_t __user *, len_ptr)
 {
 	struct compat_robust_list_head __user *head;
 	unsigned long ret;
@@ -170,9 +171,9 @@ err_unlock:
 	return ret;
 }
 
-asmlinkage long compat_sys_futex(u32 __user *uaddr, int op, u32 val,
-		struct compat_timespec __user *utime, u32 __user *uaddr2,
-		u32 val3)
+COMPAT_SYSCALL_DEFINE6(futex, u32 __user *, uaddr, int, op, u32, val,
+		struct compat_timespec __user *, utime, u32 __user *, uaddr2,
+		u32, val3)
 {
 	struct timespec ts;
 	ktime_t t, *tp = NULL;
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 474a847..0b261ed 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1024,10 +1024,10 @@ out:
 }
 
 #ifdef CONFIG_COMPAT
-asmlinkage long compat_sys_kexec_load(unsigned long entry,
-				unsigned long nr_segments,
-				struct compat_kexec_segment __user *segments,
-				unsigned long flags)
+COMPAT_SYSCALL_DEFINE4(kexec_load, unsigned long, entry,
+				unsigned long, nr_segments,
+				struct compat_kexec_segment __user *, segments,
+				unsigned long, flags)
 {
 	struct compat_kexec_segment in;
 	struct kexec_segment out, __user *ksegments;
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 74a3d69..0d91d7f 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -826,8 +826,8 @@ int compat_ptrace_request(struct task_struct *child, compat_long_t request,
 	return ret;
 }
 
-asmlinkage long compat_sys_ptrace(compat_long_t request, compat_long_t pid,
-				  compat_long_t addr, compat_long_t data)
+COMPAT_SYSCALL_DEFINE4(ptrace, compat_long_t, request, compat_long_t, pid,
+				  compat_long_t, addr, compat_long_t, data)
 {
 	struct task_struct *child;
 	long ret;
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 1357c57..fb061c7 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -1502,7 +1502,7 @@ struct compat_sysctl_args {
 	compat_ulong_t	__unused[4];
 };
 
-asmlinkage long compat_sys_sysctl(struct compat_sysctl_args __user *args)
+COMPAT_SYSCALL_DEFINE1(sysctl, struct compat_sysctl_args __user *, args)
 {
 	struct compat_sysctl_args tmp;
 	compat_size_t __user *compat_oldlenp;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 5d6fb33..b9fbceb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1372,10 +1372,10 @@ SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
 
 #ifdef CONFIG_COMPAT
 
-asmlinkage long compat_sys_get_mempolicy(int __user *policy,
-				     compat_ulong_t __user *nmask,
-				     compat_ulong_t maxnode,
-				     compat_ulong_t addr, compat_ulong_t flags)
+COMPAT_SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
+				     compat_ulong_t __user *, nmask,
+				     compat_ulong_t, maxnode,
+				     compat_ulong_t, addr, compat_ulong_t, flags)
 {
 	long err;
 	unsigned long __user *nm = NULL;
@@ -1400,8 +1400,9 @@ asmlinkage long compat_sys_get_mempolicy(int __user *policy,
 	return err;
 }
 
-asmlinkage long compat_sys_set_mempolicy(int mode, compat_ulong_t __user *nmask,
-				     compat_ulong_t maxnode)
+COMPAT_SYSCALL_DEFINE3(set_mempolicy, int, mode,
+				     compat_ulong_t __user *, nmask,
+				     compat_ulong_t, maxnode)
 {
 	long err = 0;
 	unsigned long __user *nm = NULL;
@@ -1423,9 +1424,9 @@ asmlinkage long compat_sys_set_mempolicy(int mode, compat_ulong_t __user *nmask,
 	return sys_set_mempolicy(mode, nm, nr_bits+1);
 }
 
-asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
-			     compat_ulong_t mode, compat_ulong_t __user *nmask,
-			     compat_ulong_t maxnode, compat_ulong_t flags)
+COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
+			     compat_ulong_t, mode, compat_ulong_t __user *, nmask,
+			     compat_ulong_t, maxnode, compat_ulong_t, flags)
 {
 	long err = 0;
 	unsigned long __user *nm = NULL;
diff --git a/net/compat.c b/net/compat.c
index ec24d9e..eb861c6 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -385,8 +385,8 @@ static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
 	return sock_setsockopt(sock, level, optname, optval, optlen);
 }
 
-asmlinkage long compat_sys_setsockopt(int fd, int level, int optname,
-				char __user *optval, unsigned int optlen)
+COMPAT_SYSCALL_DEFINE5(setsockopt, int, fd, int, level, int, optname,
+				char __user *, optval, unsigned int, optlen)
 {
 	int err;
 	struct socket *sock;
@@ -498,8 +498,8 @@ int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *usersta
 }
 EXPORT_SYMBOL(compat_sock_get_timestampns);
 
-asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
-				char __user *optval, int __user *optlen)
+COMPAT_SYSCALL_DEFINE5(getsockopt, int, fd, int, level, int, optname,
+				char __user *, optval, int __user *, optlen)
 {
 	int err;
 	struct socket *sock;
@@ -731,31 +731,31 @@ static unsigned char nas[20]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(4),AL(5)};
 #undef AL
 
-asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
+COMPAT_SYSCALL_DEFINE3(sendmsg, int, fd, struct compat_msghdr __user *, msg, unsigned, flags)
 {
 	return sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
-asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, unsigned int flags)
+COMPAT_SYSCALL_DEFINE3(recvmsg, int, fd, struct compat_msghdr __user *, msg, unsigned int, flags)
 {
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
-asmlinkage long compat_sys_recv(int fd, void __user *buf, size_t len, unsigned flags)
+COMPAT_SYSCALL_DEFINE4(recv, int, fd, void __user *, buf, size_t, len, unsigned, flags)
 {
 	return sys_recv(fd, buf, len, flags | MSG_CMSG_COMPAT);
 }
 
-asmlinkage long compat_sys_recvfrom(int fd, void __user *buf, size_t len,
-				    unsigned flags, struct sockaddr __user *addr,
-				    int __user *addrlen)
+COMPAT_SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, buf, size_t, len,
+				    unsigned, flags, struct sockaddr __user *, addr,
+				    int __user *, addrlen)
 {
 	return sys_recvfrom(fd, buf, len, flags | MSG_CMSG_COMPAT, addr, addrlen);
 }
 
-asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
-				    unsigned vlen, unsigned int flags,
-				    struct compat_timespec __user *timeout)
+COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
+				    unsigned, vlen, unsigned int, flags,
+				    struct compat_timespec __user *, timeout)
 {
 	int datagrams;
 	struct timespec ktspec;
@@ -775,7 +775,7 @@ asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
 	return datagrams;
 }
 
-asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
+COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
 {
 	int ret;
 	u32 a[6];
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
