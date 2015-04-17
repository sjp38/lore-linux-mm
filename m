Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2826B0073
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:41:21 -0400 (EDT)
Received: by pdea3 with SMTP id a3so122948967pde.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:41:20 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id xh5si15984081pbc.41.2015.04.17.02.41.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 02:41:19 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH v2 03/11] lib: public headers and API implementations for userspace programs
Date: Fri, 17 Apr 2015 18:36:06 +0900
Message-Id: <1429263374-57517-4-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

userspace programs access via public API, lib_init(), with passed
arguments struct SimImported and struct SimExported.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Signed-off-by: Ryo Nakamura <upa@haeena.net>
---
 arch/lib/include/sim-assert.h |  23 +++
 arch/lib/include/sim-init.h   | 134 ++++++++++++++
 arch/lib/include/sim-printf.h |  13 ++
 arch/lib/include/sim-types.h  |  53 ++++++
 arch/lib/include/sim.h        |  51 ++++++
 arch/lib/lib-device.c         | 187 +++++++++++++++++++
 arch/lib/lib-socket.c         | 410 ++++++++++++++++++++++++++++++++++++++++++
 arch/lib/lib.c                | 294 ++++++++++++++++++++++++++++++
 arch/lib/lib.h                |  21 +++
 9 files changed, 1186 insertions(+)
 create mode 100644 arch/lib/include/sim-assert.h
 create mode 100644 arch/lib/include/sim-init.h
 create mode 100644 arch/lib/include/sim-printf.h
 create mode 100644 arch/lib/include/sim-types.h
 create mode 100644 arch/lib/include/sim.h
 create mode 100644 arch/lib/lib-device.c
 create mode 100644 arch/lib/lib-socket.c
 create mode 100644 arch/lib/lib.c
 create mode 100644 arch/lib/lib.h

diff --git a/arch/lib/include/sim-assert.h b/arch/lib/include/sim-assert.h
new file mode 100644
index 0000000..974122c
--- /dev/null
+++ b/arch/lib/include/sim-assert.h
@@ -0,0 +1,23 @@
+/*
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#ifndef SIM_ASSERT_H
+#define SIM_ASSERT_H
+
+#include "sim-printf.h"
+
+#define lib_assert(v) {							\
+		while (!(v)) {						\
+			lib_printf("Assert failed %s:%u \"" #v "\"\n",	\
+				__FILE__, __LINE__);			\
+			char *p = 0;					\
+			*p = 1;						\
+		}							\
+	}
+
+
+#endif /* SIM_ASSERT_H */
diff --git a/arch/lib/include/sim-init.h b/arch/lib/include/sim-init.h
new file mode 100644
index 0000000..e871a59
--- /dev/null
+++ b/arch/lib/include/sim-init.h
@@ -0,0 +1,134 @@
+/*
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#ifndef SIM_INIT_H
+#define SIM_INIT_H
+
+#include <linux/socket.h>
+#include "sim-types.h"
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct _IO_FILE;
+typedef struct _IO_FILE FILE;
+
+struct SimExported {
+	struct SimTask *(*task_create)(void *priv, unsigned long pid);
+	void (*task_destroy)(struct SimTask *task);
+	void *(*task_get_private)(struct SimTask *task);
+
+	int (*sock_socket)(int domain, int type, int protocol,
+			struct SimSocket **socket);
+	int (*sock_close)(struct SimSocket *socket);
+	ssize_t (*sock_recvmsg)(struct SimSocket *socket, struct msghdr *msg,
+				int flags);
+	ssize_t (*sock_sendmsg)(struct SimSocket *socket,
+				const struct msghdr *msg, int flags);
+	int (*sock_getsockname)(struct SimSocket *socket,
+				struct sockaddr *name, int *namelen);
+	int (*sock_getpeername)(struct SimSocket *socket,
+				struct sockaddr *name, int *namelen);
+	int (*sock_bind)(struct SimSocket *socket, const struct sockaddr *name,
+			int namelen);
+	int (*sock_connect)(struct SimSocket *socket,
+			const struct sockaddr *name, int namelen,
+			int flags);
+	int (*sock_listen)(struct SimSocket *socket, int backlog);
+	int (*sock_shutdown)(struct SimSocket *socket, int how);
+	int (*sock_accept)(struct SimSocket *socket,
+			struct SimSocket **newSocket, int flags);
+	int (*sock_ioctl)(struct SimSocket *socket, int request, char *argp);
+	int (*sock_setsockopt)(struct SimSocket *socket, int level,
+			int optname,
+			const void *optval, int optlen);
+	int (*sock_getsockopt)(struct SimSocket *socket, int level,
+			int optname,
+			void *optval, int *optlen);
+
+	void (*sock_poll)(struct SimSocket *socket, void *ret);
+	void (*sock_pollfreewait)(void *polltable);
+
+	struct SimDevice *(*dev_create)(const char *ifname, void *priv,
+					enum SimDevFlags flags);
+	void (*dev_destroy)(struct SimDevice *dev);
+	void *(*dev_get_private)(struct SimDevice *task);
+	void (*dev_set_address)(struct SimDevice *dev,
+				unsigned char buffer[6]);
+	void (*dev_set_mtu)(struct SimDevice *dev, int mtu);
+	struct SimDevicePacket (*dev_create_packet)(struct SimDevice *dev,
+						int size);
+	void (*dev_rx)(struct SimDevice *dev, struct SimDevicePacket packet);
+
+	void (*sys_iterate_files)(const struct SimSysIterator *iter);
+	int (*sys_file_read)(const struct SimSysFile *file, char *buffer,
+			int size, int offset);
+	int (*sys_file_write)(const struct SimSysFile *file,
+			const char *buffer, int size, int offset);
+};
+
+struct SimImported {
+	int (*vprintf)(struct SimKernel *kernel, const char *str,
+		va_list args);
+	void *(*malloc)(struct SimKernel *kernel, unsigned long size);
+	void (*free)(struct SimKernel *kernel, void *buffer);
+	void *(*memcpy)(struct SimKernel *kernel, void *dst, const void *src,
+			unsigned long size);
+	void *(*memset)(struct SimKernel *kernel, void *dst, char value,
+			unsigned long size);
+	int (*atexit)(struct SimKernel *kernel, void (*function)(void));
+	int (*access)(struct SimKernel *kernel, const char *pathname,
+		int mode);
+	char *(*getenv)(struct SimKernel *kernel, const char *name);
+	int (*mkdir)(struct SimKernel *kernel, const char *pathname,
+		mode_t mode);
+	int (*open)(struct SimKernel *kernel, const char *pathname, int flags);
+	int (*__fxstat)(struct SimKernel *kernel, int ver, int fd, void *buf);
+	int (*fseek)(struct SimKernel *kernel, FILE *stream, long offset,
+		int whence);
+	void (*setbuf)(struct SimKernel *kernel, FILE *stream, char *buf);
+	FILE *(*fdopen)(struct SimKernel *kernel, int fd, const char *mode);
+	long (*ftell)(struct SimKernel *kernel, FILE *stream);
+	int (*fclose)(struct SimKernel *kernel, FILE *fp);
+	size_t (*fread)(struct SimKernel *kernel, void *ptr, size_t size,
+			size_t nmemb, FILE *stream);
+	size_t (*fwrite)(struct SimKernel *kernel, const void *ptr, size_t size,
+			 size_t nmemb, FILE *stream);
+
+	unsigned long (*random)(struct SimKernel *kernel);
+	void *(*event_schedule_ns)(struct SimKernel *kernel, __u64 ns,
+				void (*fn)(void *context), void *context,
+				void (*pre_fn)(void));
+	void (*event_cancel)(struct SimKernel *kernel, void *event);
+	__u64 (*current_ns)(struct SimKernel *kernel);
+
+	struct SimTask *(*task_start)(struct SimKernel *kernel,
+				void (*callback)(void *),
+				void *context);
+	void (*task_wait)(struct SimKernel *kernel);
+	struct SimTask *(*task_current)(struct SimKernel *kernel);
+	int (*task_wakeup)(struct SimKernel *kernel, struct SimTask *task);
+	void (*task_yield)(struct SimKernel *kernel);
+
+	void (*dev_xmit)(struct SimKernel *kernel, struct SimDevice *dev,
+			unsigned char *data, int len);
+	void (*signal_raised)(struct SimKernel *kernel, struct SimTask *task,
+			int sig);
+	void (*poll_event)(int flag, void *context);
+};
+
+typedef void (*SimInit)(struct SimExported *, const struct SimImported *,
+			struct SimKernel *kernel);
+void sim_init(struct SimExported *exported, const struct SimImported *imported,
+	struct SimKernel *kernel);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* SIM_INIT_H */
diff --git a/arch/lib/include/sim-printf.h b/arch/lib/include/sim-printf.h
new file mode 100644
index 0000000..2bf8245
--- /dev/null
+++ b/arch/lib/include/sim-printf.h
@@ -0,0 +1,13 @@
+/*
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#ifndef SIM_PRINTF_H
+#define SIM_PRINTF_H
+
+void lib_printf(const char *str, ...);
+
+#endif /* SIM_PRINTF_H */
diff --git a/arch/lib/include/sim-types.h b/arch/lib/include/sim-types.h
new file mode 100644
index 0000000..d50b99b
--- /dev/null
+++ b/arch/lib/include/sim-types.h
@@ -0,0 +1,53 @@
+/*
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#ifndef SIM_TYPES_H
+#define SIM_TYPES_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#define LIBOS_API_VERSION     2
+
+struct SimTask;
+struct SimDevice;
+struct SimSocket;
+struct SimKernel;
+struct SimSysFile;
+
+enum SimDevFlags {
+	SIM_DEV_NOARP         = (1 << 0),
+	SIM_DEV_POINTTOPOINT  = (1 << 1),
+	SIM_DEV_MULTICAST     = (1 << 2),
+	SIM_DEV_BROADCAST     = (1 << 3),
+};
+
+struct SimDevicePacket {
+	void *buffer;
+	void *token;
+};
+
+enum SimSysFileFlags {
+	SIM_SYS_FILE_READ  = 1 << 0,
+	SIM_SYS_FILE_WRITE = 1 << 1,
+};
+
+struct SimSysIterator {
+	void (*report_start_dir)(const struct SimSysIterator *iter,
+				const char *dirname);
+	void (*report_end_dir)(const struct SimSysIterator *iter);
+	void (*report_file)(const struct SimSysIterator *iter,
+			const char *filename,
+			int flags, struct SimSysFile *file);
+};
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* SIM_TYPES_H */
diff --git a/arch/lib/include/sim.h b/arch/lib/include/sim.h
new file mode 100644
index 0000000..b30d7e8
--- /dev/null
+++ b/arch/lib/include/sim.h
@@ -0,0 +1,51 @@
+/*
+ * library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#ifndef SIM_H
+#define SIM_H
+
+#include <stdarg.h>
+#include <linux/types.h>
+
+#include "sim-types.h"
+
+/* API called from within linux kernel. Forwards to SimImported. */
+int lib_vprintf(const char *str, va_list args);
+void *lib_malloc(unsigned long size);
+void lib_free(void *buffer);
+void *lib_memcpy(void *dst, const void *src, unsigned long size);
+void *lib_memset(void *dst, char value, unsigned long size);
+unsigned long lib_random(void);
+void *lib_event_schedule_ns(__u64 ns, void (*fn) (void *context),
+			    void *context);
+void lib_event_cancel(void *event);
+__u64 lib_current_ns(void);
+
+struct SimTask *lib_task_start(void (*callback) (void *), void *context);
+void lib_task_wait(void);
+void lib_task_yield(void);
+struct SimTask *lib_task_current(void);
+/* returns 1 if task was woken up, 0 if it was already running. */
+int lib_task_wakeup(struct SimTask *task);
+struct SimTask *lib_task_create(void *priv, unsigned long pid);
+void lib_task_destroy(struct SimTask *task);
+void *lib_task_get_private(struct SimTask *task);
+
+void lib_dev_xmit(struct SimDevice *dev, unsigned char *data, int len);
+struct SimDevicePacket lib_dev_create_packet(struct SimDevice *dev, int size);
+void lib_dev_rx(struct SimDevice *device, struct SimDevicePacket packet);
+
+void lib_signal_raised(struct SimTask *task, int sig);
+
+void lib_poll_event(int flag, void *context);
+void lib_softirq_wakeup(void);
+void lib_update_jiffies(void);
+void *lib_dev_get_private(struct SimDevice *);
+void lib_proc_net_initialize(void);
+
+#endif /* SIM_H */
diff --git a/arch/lib/lib-device.c b/arch/lib/lib-device.c
new file mode 100644
index 0000000..1efa6460
--- /dev/null
+++ b/arch/lib/lib-device.c
@@ -0,0 +1,187 @@
+/*
+ * virtual net_device feature for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include "sim-init.h"
+#include "sim.h"
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/ethtool.h>
+
+struct SimDevice {
+	struct net_device dev;
+	void *priv;
+};
+
+static netdev_tx_t
+kernel_dev_xmit(struct sk_buff *skb,
+		struct net_device *dev)
+{
+	int err;
+
+	netif_stop_queue(dev);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
+		if (unlikely(err)) {
+			pr_err("checksum error (%d)\n", err);
+			return 0;
+		}
+	}
+
+	lib_dev_xmit((struct SimDevice *)dev, skb->data, skb->len);
+	dev_kfree_skb(skb);
+	netif_wake_queue(dev);
+	return 0;
+}
+
+static u32 always_on(struct net_device *dev)
+{
+	return 1;
+}
+
+
+static const struct ethtool_ops lib_ethtool_ops = {
+	.get_link		= always_on,
+};
+
+static const struct net_device_ops lib_dev_ops = {
+	.ndo_start_xmit		= kernel_dev_xmit,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
+static void lib_dev_setup(struct net_device *dev)
+{
+	dev->mtu                = (16 * 1024) + 20 + 20 + 12;
+	dev->hard_header_len    = ETH_HLEN;     /* 14   */
+	dev->addr_len           = ETH_ALEN;     /* 6    */
+	dev->tx_queue_len       = 0;
+	dev->type               = ARPHRD_ETHER;
+	dev->flags              = 0;
+	/* dev->priv_flags        &= ~IFF_XMIT_DST_RELEASE; */
+	dev->features           = 0
+				  | NETIF_F_HIGHDMA
+				  | NETIF_F_NETNS_LOCAL;
+	/* disabled  NETIF_F_TSO NETIF_F_SG  NETIF_F_FRAGLIST NETIF_F_LLTX */
+	dev->ethtool_ops        = &lib_ethtool_ops;
+	dev->header_ops         = &eth_header_ops;
+	dev->netdev_ops         = &lib_dev_ops;
+	dev->destructor         = &free_netdev;
+}
+
+
+struct SimDevice *lib_dev_create(const char *ifname, void *priv,
+				 enum SimDevFlags flags)
+{
+	int err;
+	struct SimDevice *dev =
+		(struct SimDevice *)alloc_netdev(sizeof(struct SimDevice),
+						 ifname, NET_NAME_UNKNOWN,
+						 &lib_dev_setup);
+	ether_setup((struct net_device *)dev);
+
+	if (flags & SIM_DEV_NOARP)
+		dev->dev.flags |= IFF_NOARP;
+	if (flags & SIM_DEV_POINTTOPOINT)
+		dev->dev.flags |= IFF_POINTOPOINT;
+	if (flags & SIM_DEV_MULTICAST)
+		dev->dev.flags |= IFF_MULTICAST;
+	if (flags & SIM_DEV_BROADCAST) {
+		dev->dev.flags |= IFF_BROADCAST;
+		memset(dev->dev.broadcast, 0xff, 6);
+	}
+	dev->priv = priv;
+	err = register_netdev(&dev->dev);
+	return dev;
+}
+void lib_dev_destroy(struct SimDevice *dev)
+{
+	unregister_netdev(&dev->dev);
+	/* XXX */
+	free_netdev(&dev->dev);
+}
+void *lib_dev_get_private(struct SimDevice *dev)
+{
+	return dev->priv;
+}
+
+void lib_dev_set_mtu(struct SimDevice *dev, int mtu)
+{
+	/* called by ns-3 to synchronize the kernel mtu with */
+	/* the simulation mtu */
+	dev->dev.mtu = mtu;
+}
+
+static int lib_ndo_change_mtu(struct net_device *dev,
+			      int new_mtu)
+{
+	/* called by kernel to change the mtu when the user */
+	/* asks for it. */
+	/* XXX should forward the set call to ns-3 and wait for */
+	/* ns-3 to notify of the change in the function above */
+	/* but I am way too tired to do this now. */
+	return 0;
+}
+
+void lib_dev_set_address(struct SimDevice *dev, unsigned char buffer[6])
+{
+	/* called by ns-3 to synchronize the kernel address with */
+	/* the simulation address. */
+	struct sockaddr sa;
+
+	sa.sa_family = dev->dev.type;
+	lib_memcpy(&sa.sa_data, buffer, 6);
+	dev->dev.netdev_ops->ndo_set_mac_address(&dev->dev, &sa);
+	/* Note that we don't call   dev_set_mac_address (&dev->dev, &sa); */
+	/* because this function expects to be called from within */
+	/* the netlink layer so, it expects to hold */
+	/* the netlink lock during the execution of the associated notifiers */
+}
+static int get_hack_size(int size)
+{
+	/* Note: this hack is coming from nsc */
+	/* Bit of a hack... */
+	/* Note that the size allocated here effects the offered window
+	   somewhat. I've got this heuristic here to try and match up with
+	   what we observe on the emulation network and by looking at the
+	   driver code of the eepro100. In both cases we allocate enough
+	   space for our packet, which  is the important thing. The amount
+	   of slack at the end can make linux decide the grow the window
+	   differently. This is quite subtle, but the code in question is
+	   in the tcp_grow_window function. It checks skb->truesize, which
+	   is the size of the skbuff allocated for the incoming data
+	   packet -- what we are allocating right now! */
+	if (size < 1200)
+		return size + 36;
+	else if (size <= 1500)
+		return 1536;
+	else
+		return size + 36;
+}
+struct SimDevicePacket lib_dev_create_packet(struct SimDevice *dev, int size)
+{
+	struct SimDevicePacket packet;
+	int len = get_hack_size(size);
+	struct sk_buff *skb = __dev_alloc_skb(len, __GFP_WAIT);
+
+	packet.token = skb;
+	packet.buffer = skb_put(skb, len);
+	return packet;
+}
+void lib_dev_rx(struct SimDevice *device, struct SimDevicePacket packet)
+{
+	struct sk_buff *skb = packet.token;
+	struct net_device *dev = &device->dev;
+
+	skb->protocol = eth_type_trans(skb, dev);
+	/* Do the TCP checksum (FIXME: should be configurable) */
+	skb->ip_summed = CHECKSUM_PARTIAL;
+
+	netif_rx(skb);
+}
diff --git a/arch/lib/lib-socket.c b/arch/lib/lib-socket.c
new file mode 100644
index 0000000..d9be5fc
--- /dev/null
+++ b/arch/lib/lib-socket.c
@@ -0,0 +1,410 @@
+/*
+ * socket feature for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include "sim-init.h"
+#include "sim.h"
+#include <linux/net.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/poll.h>
+#include <linux/wait.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/inet_connection_sock.h>
+
+struct SimSocket {};
+
+static struct iovec *copy_iovec(const struct iovec *input, int len)
+{
+	int size = sizeof(struct iovec) * len;
+	struct iovec *output = lib_malloc(size);
+
+	if (!output)
+		return NULL;
+	lib_memcpy(output, input, size);
+	return output;
+}
+
+int lib_sock_socket(int domain, int type, int protocol,
+		    struct SimSocket **socket)
+{
+	struct socket **kernel_socket = (struct socket **)socket;
+	int flags;
+
+	/* from net/socket.c */
+	flags = type & ~SOCK_TYPE_MASK;
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
+		return -EINVAL;
+	type &= SOCK_TYPE_MASK;
+
+	int retval = sock_create(domain, type, protocol, kernel_socket);
+	/* XXX: SCTP code never look at flags args, but file flags instead. */
+	struct file *fp = lib_malloc(sizeof(struct file));
+	(*kernel_socket)->file = fp;
+	fp->f_cred = lib_malloc(sizeof(struct cred));
+	return retval;
+}
+int lib_sock_close(struct SimSocket *socket)
+{
+	struct socket *kernel_socket = (struct socket *)socket;
+
+	sock_release(kernel_socket);
+	return 0;
+}
+static size_t iov_size(const struct user_msghdr *msg)
+{
+	size_t i;
+	size_t size = 0;
+
+	for (i = 0; i < msg->msg_iovlen; i++)
+		size += msg->msg_iov[i].iov_len;
+	return size;
+}
+ssize_t lib_sock_recvmsg(struct SimSocket *socket,
+			struct user_msghdr *msg,
+			int flags)
+{
+	struct socket *kernel_socket = (struct socket *)socket;
+	struct msghdr msg_sys;
+	struct cmsghdr *user_cmsgh = msg->msg_control;
+	size_t user_cmsghlen = msg->msg_controllen;
+	int retval;
+
+	msg_sys.msg_name = msg->msg_name;
+	msg_sys.msg_namelen = msg->msg_namelen;
+	msg_sys.msg_control = msg->msg_control;
+	msg_sys.msg_controllen = msg->msg_controllen;
+	msg_sys.msg_flags = flags;
+
+	iov_iter_init(&msg_sys.msg_iter, READ,
+		msg->msg_iov, msg->msg_iovlen, iov_size(msg));
+
+	retval = sock_recvmsg(kernel_socket, &msg_sys, iov_size(msg), flags);
+
+	msg->msg_name = msg_sys.msg_name;
+	msg->msg_namelen = msg_sys.msg_namelen;
+	msg->msg_control = user_cmsgh;
+	msg->msg_controllen = user_cmsghlen - msg_sys.msg_controllen;
+	return retval;
+}
+ssize_t lib_sock_sendmsg(struct SimSocket *socket,
+			const struct user_msghdr *msg,
+			int flags)
+{
+	struct socket *kernel_socket = (struct socket *)socket;
+	struct iovec *kernel_iov = copy_iovec(msg->msg_iov, msg->msg_iovlen);
+	struct msghdr msg_sys;
+	int retval;
+
+	msg_sys.msg_name = msg->msg_name;
+	msg_sys.msg_namelen = msg->msg_namelen;
+	msg_sys.msg_control = msg->msg_control;
+	msg_sys.msg_controllen = msg->msg_controllen;
+	msg_sys.msg_flags = flags;
+
+	iov_iter_init(&msg_sys.msg_iter, WRITE,
+		kernel_iov, msg->msg_iovlen, iov_size(msg));
+
+	retval = sock_sendmsg(kernel_socket, &msg_sys);
+	lib_free(kernel_iov);
+	return retval;
+}
+int lib_sock_getsockname(struct SimSocket *socket, struct sockaddr *name,
+			 int *namelen)
+{
+	struct socket *sock = (struct socket *)socket;
+	int retval = sock->ops->getname(sock, name, namelen, 0);
+
+	return retval;
+}
+int lib_sock_getpeername(struct SimSocket *socket, struct sockaddr *name,
+			 int *namelen)
+{
+	struct socket *sock = (struct socket *)socket;
+	int retval = sock->ops->getname(sock, name, namelen, 1);
+
+	return retval;
+}
+int lib_sock_bind(struct SimSocket *socket, const struct sockaddr *name,
+		  int namelen)
+{
+	struct socket *sock = (struct socket *)socket;
+	struct sockaddr_storage address;
+
+	memcpy(&address, name, namelen);
+	int retval =
+		sock->ops->bind(sock, (struct sockaddr *)&address, namelen);
+	return retval;
+}
+int lib_sock_connect(struct SimSocket *socket, const struct sockaddr *name,
+		     int namelen, int flags)
+{
+	struct socket *sock = (struct socket *)socket;
+	struct sockaddr_storage address;
+
+	memcpy(&address, name, namelen);
+	/* XXX: SCTP code never look at flags args, but file flags instead. */
+	sock->file->f_flags = flags;
+	int retval = sock->ops->connect(sock, (struct sockaddr *)&address,
+					namelen, flags);
+	return retval;
+}
+int lib_sock_listen(struct SimSocket *socket, int backlog)
+{
+	struct socket *sock = (struct socket *)socket;
+	int retval = sock->ops->listen(sock, backlog);
+
+	return retval;
+}
+int lib_sock_shutdown(struct SimSocket *socket, int how)
+{
+	struct socket *sock = (struct socket *)socket;
+	int retval = sock->ops->shutdown(sock, how);
+
+	return retval;
+}
+int lib_sock_accept(struct SimSocket *socket, struct SimSocket **new_socket,
+		    int flags)
+{
+	struct socket *sock, *newsock;
+	int err;
+
+	sock = (struct socket *)socket;
+
+	/* the fields do not matter here. If we could, */
+	/* we would call sock_alloc but it's not exported. */
+	err = sock_create_lite(0, 0, 0, &newsock);
+	if (err < 0)
+		return err;
+	newsock->type = sock->type;
+	newsock->ops = sock->ops;
+
+	err = sock->ops->accept(sock, newsock, flags);
+	if (err < 0) {
+		sock_release(newsock);
+		return err;
+	}
+	*new_socket = (struct SimSocket *)newsock;
+	return 0;
+}
+int lib_sock_ioctl(struct SimSocket *socket, int request, char *argp)
+{
+	struct socket *sock = (struct socket *)socket;
+	struct sock *sk;
+	struct net *net;
+	int err;
+
+	sk = sock->sk;
+	net = sock_net(sk);
+
+	err = sock->ops->ioctl(sock, request, (long)argp);
+
+	/*
+	 * If this ioctl is unknown try to hand it down
+	 * to the NIC driver.
+	 */
+	if (err == -ENOIOCTLCMD)
+		err = dev_ioctl(net, request, argp);
+	return err;
+}
+int lib_sock_setsockopt(struct SimSocket *socket, int level, int optname,
+			const void *optval, int optlen)
+{
+	struct socket *sock = (struct socket *)socket;
+	char *coptval = (char *)optval;
+	int err;
+
+	if (level == SOL_SOCKET)
+		err = sock_setsockopt(sock, level, optname, coptval, optlen);
+	else
+		err = sock->ops->setsockopt(sock, level, optname, coptval,
+					    optlen);
+	return err;
+}
+int lib_sock_getsockopt(struct SimSocket *socket, int level, int optname,
+			void *optval, int *optlen)
+{
+	struct socket *sock = (struct socket *)socket;
+	int err;
+
+	if (level == SOL_SOCKET)
+		err = sock_getsockopt(sock, level, optname, optval, optlen);
+	else
+		err =
+			sock->ops->getsockopt(sock, level, optname, optval,
+					      optlen);
+	return err;
+}
+
+int lib_sock_canrecv(struct SimSocket *socket)
+{
+	struct socket *sock = (struct socket *)socket;
+	struct inet_connection_sock *icsk;
+
+	switch (sock->sk->sk_state) {
+	case TCP_CLOSE:
+		if (SOCK_STREAM == sock->sk->sk_type)
+			return 1;
+	case TCP_ESTABLISHED:
+		return sock->sk->sk_receive_queue.qlen > 0;
+	case TCP_SYN_SENT:
+	case TCP_SYN_RECV:
+	case TCP_LAST_ACK:
+	case TCP_CLOSING:
+		return 0;
+	case TCP_FIN_WAIT1:
+	case TCP_FIN_WAIT2:
+	case TCP_TIME_WAIT:
+	case TCP_CLOSE_WAIT:
+		return 1;
+	case TCP_LISTEN:
+	{
+		icsk = inet_csk(sock->sk);
+		return !reqsk_queue_empty(&icsk->icsk_accept_queue);
+	}
+
+	default:
+		break;
+	}
+
+	return 0;
+}
+int lib_sock_cansend(struct SimSocket *socket)
+{
+	struct socket *sock = (struct socket *)socket;
+
+	return sock_writeable(sock->sk);
+}
+
+/**
+ * Struct used to pass pool table context between DCE and Kernel and back from
+ * Kernel to DCE
+ *
+ * When calling sock_poll we provide in ret field the wanted eventmask, and in
+ * the opaque field the DCE poll table
+ *
+ * if a corresponding event occurs later, the PollEvent will be called by kernel
+ * with the DCE poll table in context variable, then we will able to wake up the
+ * thread blocked in poll call.
+ *
+ * Back from sock_poll method the kernel change ret field with the response from
+ * poll return of the corresponding kernel socket, and in opaque field there is
+ * a reference to the kernel poll table we will use this reference to remove us
+ * from the file wait queue when ending the DCE poll call or when ending the DCE
+ * process which is currently polling.
+ *
+ */
+struct poll_table_ref {
+	int ret;
+	void *opaque;
+};
+
+/* Because the poll main loop code is in NS3/DCE we have only on entry
+   in our kernel poll table */
+struct lib_ptable_entry {
+	wait_queue_t wait;
+	wait_queue_head_t *wait_address;
+	int eventMask;  /* Poll wanted event mask. */
+	void *opaque;   /* Pointeur to DCE poll table */
+};
+
+static int lib_pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct lib_ptable_entry *entry =
+		(struct lib_ptable_entry *)wait->private;
+
+	/* Filter only wanted events */
+	if (key && !((unsigned long)key & entry->eventMask))
+		return 0;
+
+	lib_poll_event((unsigned long)key, entry->opaque);
+	return 1;
+}
+
+static void lib_pollwait(struct file *filp, wait_queue_head_t *wait_address,
+			 poll_table *p)
+{
+	struct poll_wqueues *pwq = container_of(p, struct poll_wqueues, pt);
+	struct lib_ptable_entry *entry =
+		(struct lib_ptable_entry *)
+		lib_malloc(sizeof(struct lib_ptable_entry));
+	struct poll_table_ref *fromDCE =  (struct poll_table_ref *)pwq->table;
+
+	if (!entry)
+		return;
+
+	entry->opaque = fromDCE->opaque; /* Copy DCE poll table reference */
+	entry->eventMask = fromDCE->ret; /* Copy poll mask of wanted events. */
+
+	pwq->table = (struct poll_table_page *)entry;
+
+	init_waitqueue_func_entry(&entry->wait, lib_pollwake);
+	entry->wait.private = entry;
+	entry->wait_address = wait_address;
+	add_wait_queue(wait_address, &entry->wait);
+}
+
+void dce_poll_initwait(struct poll_wqueues *pwq)
+{
+	init_poll_funcptr(&pwq->pt, lib_pollwait);
+	pwq->polling_task = current;
+	pwq->triggered = 0;
+	pwq->error = 0;
+	pwq->table = NULL;
+	pwq->inline_index = 0;
+}
+
+/* call poll on socket ... */
+void lib_sock_poll(struct SimSocket *socket, struct poll_table_ref *ret)
+{
+	struct socket *sock = (struct socket *)socket;
+	/* Provide a fake file structure */
+	struct file zero;
+	poll_table *pwait = 0;
+	struct poll_wqueues *ptable = 0;
+
+	lib_memset(&zero, 0, sizeof(struct file));
+
+	if (ret->opaque) {
+		ptable =
+			(struct poll_wqueues *)lib_malloc(sizeof(struct
+								 poll_wqueues));
+		if (!ptable)
+			return;
+
+		dce_poll_initwait(ptable);
+
+		pwait = &(ptable->pt);
+		/* Pass the DCE pool table to lib_pollwait function */
+		ptable->table = (struct poll_table_page *)ret;
+	}
+
+	ret->ret = sock->ops->poll(&zero, sock, pwait);
+	/* Pass back the kernel poll table to DCE in order to DCE to */
+	/* remove from wait queue */
+	/* using lib_sock_pollfreewait method below */
+	ret->opaque = ptable;
+}
+
+void lib_sock_pollfreewait(void *polltable)
+{
+	struct poll_wqueues *ptable = (struct poll_wqueues *)polltable;
+
+	if (ptable && ptable->table) {
+		struct lib_ptable_entry *entry =
+			(struct lib_ptable_entry *)ptable->table;
+		remove_wait_queue(entry->wait_address, &entry->wait);
+		lib_free(entry);
+	}
+	lib_free(ptable);
+}
+
+
+
+
diff --git a/arch/lib/lib.c b/arch/lib/lib.c
new file mode 100644
index 0000000..52d638e
--- /dev/null
+++ b/arch/lib/lib.c
@@ -0,0 +1,294 @@
+/*
+ * library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/init.h>         /* initcall_t */
+#include <linux/kernel.h>       /* SYSTEM_BOOTING */
+#include <linux/sched.h>        /* struct task_struct */
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <drivers/base/base.h>
+#include <linux/idr.h>
+#include <linux/rcupdate.h>
+#include "sim-init.h"
+#include "sim.h"
+
+enum system_states system_state = SYSTEM_BOOTING;
+/* glues */
+struct task_struct init_task;
+
+struct SimImported g_imported;
+
+
+#define RETURN_void(rettype, v)				     \
+	({						     \
+		(v);					     \
+		lib_softirq_wakeup();			     \
+	})
+
+#define RETURN_nvoid(rettype, v)			     \
+	({						     \
+		rettype x = (v);			     \
+		lib_softirq_wakeup();			     \
+		x;					     \
+	})
+
+#define FORWARDER1(name, type, rettype, t0)			    \
+	extern rettype name(t0);				    \
+	static rettype name ## _forwarder(t0 v0)		    \
+	{							    \
+		lib_update_jiffies();				    \
+		return RETURN_ ## type(rettype, (name(v0)));        \
+	}
+
+#define FORWARDER2(name, type, rettype, t0, t1)				\
+	extern rettype name(t0, t1);					\
+	static rettype name ## _forwarder(t0 v0, t1 v1)			\
+	{								\
+		lib_update_jiffies();					\
+		return RETURN_ ## type(rettype, (name(v0, v1)));	\
+	}
+#define FORWARDER3(name, type, rettype, t0, t1, t2)			\
+	extern rettype name(t0, t1, t2);				\
+	static rettype name ## _forwarder(t0 v0, t1 v1, t2 v2)		\
+	{								\
+		lib_update_jiffies();					\
+		return RETURN_ ## type(rettype, (name(v0, v1, v2)));	\
+	}
+#define FORWARDER4(name, type, rettype, t0, t1, t2, t3)			\
+	extern rettype name(t0, t1, t2, t3);				\
+	static rettype name ## _forwarder(t0 v0, t1 v1, t2 v2, t3 v3)	\
+	{								\
+		lib_update_jiffies();					\
+		return RETURN_ ## type(rettype, (name(v0, v1, v2, v3))); \
+	}
+#define FORWARDER4(name, type, rettype, t0, t1, t2, t3)			\
+	extern rettype name(t0, t1, t2, t3);				\
+	static rettype name ## _forwarder(t0 v0, t1 v1, t2 v2, t3 v3)	\
+	{								\
+		lib_update_jiffies();					\
+		return RETURN_ ## type(rettype, (name(v0, v1, v2, v3))); \
+	}
+#define FORWARDER5(name, type, rettype, t0, t1, t2, t3, t4)		\
+	extern rettype name(t0, t1, t2, t3, t4);			\
+	static rettype name ## _forwarder(t0 v0, t1 v1, t2 v2, t3 v3, t4 v4) \
+	{								\
+		lib_update_jiffies();					\
+		return RETURN_ ## type(rettype, (name(v0, v1, v2, v3, v4))); \
+	}
+
+FORWARDER3(lib_dev_create, nvoid, struct SimDevice *, const char *, void *,
+	   enum SimDevFlags);
+FORWARDER1(lib_dev_destroy, void, void, struct SimDevice *);
+FORWARDER2(lib_dev_set_address, void, void, struct SimDevice *,
+	   unsigned char *);
+FORWARDER2(lib_dev_set_mtu, void, void, struct SimDevice *, int);
+FORWARDER2(lib_dev_create_packet, nvoid, struct SimDevicePacket,
+	   struct SimDevice *, int);
+FORWARDER2(lib_dev_rx, void, void, struct SimDevice *, struct SimDevicePacket);
+
+FORWARDER4(lib_sock_socket, nvoid, int, int, int, int, struct SimSocket **);
+FORWARDER1(lib_sock_close, nvoid, int, struct SimSocket *);
+FORWARDER3(lib_sock_recvmsg, nvoid, ssize_t, struct SimSocket *,
+	   struct msghdr *, int);
+FORWARDER3(lib_sock_sendmsg, nvoid, ssize_t, struct SimSocket *,
+	   const struct msghdr *, int);
+FORWARDER3(lib_sock_getsockname, nvoid, int, struct SimSocket *,
+	   struct sockaddr *, int *);
+FORWARDER3(lib_sock_getpeername, nvoid, int, struct SimSocket *,
+	   struct sockaddr *, int *);
+FORWARDER3(lib_sock_bind, nvoid, int, struct SimSocket *,
+	   const struct sockaddr *, int);
+FORWARDER4(lib_sock_connect, nvoid, int, struct SimSocket *,
+	   const struct sockaddr *, int, int);
+FORWARDER2(lib_sock_listen, nvoid, int, struct SimSocket *, int);
+FORWARDER2(lib_sock_shutdown, nvoid, int, struct SimSocket *, int);
+FORWARDER3(lib_sock_accept, nvoid, int, struct SimSocket *,
+	   struct SimSocket **, int);
+FORWARDER3(lib_sock_ioctl, nvoid, int, struct SimSocket *, int, char *);
+FORWARDER5(lib_sock_setsockopt, nvoid, int, struct SimSocket *, int, int,
+	   const void *, int);
+FORWARDER5(lib_sock_getsockopt, nvoid, int, struct SimSocket *, int, int,
+	   void *, int *);
+
+FORWARDER2(lib_sock_poll, void, void, struct SimSocket *, void *);
+FORWARDER1(lib_sock_pollfreewait, void, void, void *);
+
+FORWARDER1(lib_sys_iterate_files, void, void, const struct SimSysIterator *);
+FORWARDER4(lib_sys_file_read, nvoid, int, const struct SimSysFile *, char *,
+	   int, int);
+FORWARDER4(lib_sys_file_write, nvoid, int, const struct SimSysFile *,
+	   const char *, int, int);
+
+struct SimKernel *g_kernel;
+
+void lib_init(struct SimExported *exported, const struct SimImported *imported,
+	      struct SimKernel *kernel)
+{
+	/* make sure we can call the callbacks */
+	g_imported = *imported;
+	g_kernel = kernel;
+	exported->task_create = lib_task_create;
+	exported->task_destroy = lib_task_destroy;
+	exported->task_get_private = lib_task_get_private;
+	exported->sock_socket = lib_sock_socket_forwarder;
+	exported->sock_close = lib_sock_close_forwarder;
+	exported->sock_recvmsg = lib_sock_recvmsg_forwarder;
+	exported->sock_sendmsg = lib_sock_sendmsg_forwarder;
+	exported->sock_getsockname = lib_sock_getsockname_forwarder;
+	exported->sock_getpeername = lib_sock_getpeername_forwarder;
+	exported->sock_bind = lib_sock_bind_forwarder;
+	exported->sock_connect = lib_sock_connect_forwarder;
+	exported->sock_listen = lib_sock_listen_forwarder;
+	exported->sock_shutdown = lib_sock_shutdown_forwarder;
+	exported->sock_accept = lib_sock_accept_forwarder;
+	exported->sock_ioctl = lib_sock_ioctl_forwarder;
+	exported->sock_setsockopt = lib_sock_setsockopt_forwarder;
+	exported->sock_getsockopt = lib_sock_getsockopt_forwarder;
+
+	exported->sock_poll = lib_sock_poll_forwarder;
+	exported->sock_pollfreewait = lib_sock_pollfreewait_forwarder;
+
+	exported->dev_create = lib_dev_create_forwarder;
+	exported->dev_destroy = lib_dev_destroy_forwarder;
+	exported->dev_get_private = lib_dev_get_private;
+	exported->dev_set_address = lib_dev_set_address_forwarder;
+	exported->dev_set_mtu = lib_dev_set_mtu_forwarder;
+	exported->dev_create_packet = lib_dev_create_packet_forwarder;
+	exported->dev_rx = lib_dev_rx_forwarder;
+
+	exported->sys_iterate_files = lib_sys_iterate_files_forwarder;
+	exported->sys_file_write = lib_sys_file_write_forwarder;
+	exported->sys_file_read = lib_sys_file_read_forwarder;
+
+	pr_notice("%s", linux_banner);
+
+	rcu_init();
+
+	/* in drivers/base/core.c (called normally by drivers/base/init.c) */
+	devices_init();
+	/* in lib/idr.c (called normally by init/main.c) */
+	idr_init_cache();
+	vfs_caches_init(totalram_pages);
+
+	lib_proc_net_initialize();
+
+	/* and, then, call the normal initcalls */
+	initcall_t *call;
+	extern initcall_t __initcall_start[], __initcall_end[];
+
+	call = __initcall_start;
+	do {
+		(*call)();
+		call++;
+	} while (call < __initcall_end);
+
+	/* finally, put the system in RUNNING state. */
+	system_state = SYSTEM_RUNNING;
+}
+
+int lib_vprintf(const char *str, va_list args)
+{
+	return g_imported.vprintf(g_kernel, str, args);
+}
+void *lib_malloc(unsigned long size)
+{
+	return g_imported.malloc(g_kernel, size);
+}
+void lib_free(void *buffer)
+{
+	return g_imported.free(g_kernel, buffer);
+}
+void *lib_memcpy(void *dst, const void *src, unsigned long size)
+{
+	return g_imported.memcpy(g_kernel, dst, src, size);
+}
+void *lib_memset(void *dst, char value, unsigned long size)
+{
+	return g_imported.memset(g_kernel, dst, value, size);
+}
+unsigned long lib_random(void)
+{
+	return g_imported.random(g_kernel);
+}
+void *lib_event_schedule_ns(__u64 ns, void (*fn) (void *context), void *context)
+{
+	return g_imported.event_schedule_ns(g_kernel, ns, fn, context,
+					    lib_update_jiffies);
+}
+void lib_event_cancel(void *event)
+{
+	return g_imported.event_cancel(g_kernel, event);
+}
+__u64 lib_current_ns(void)
+{
+	return g_imported.current_ns(g_kernel);
+}
+struct SimTaskTrampolineContext {
+	void (*callback)(void *);
+	void *context;
+};
+static void lib_task_start_trampoline(void *context)
+{
+	/* we use this trampoline solely for the purpose of executing
+	   lib_update_jiffies prior to calling the callback. */
+	struct SimTaskTrampolineContext *ctx = context;
+	void (*callback)(void *) = ctx->callback;
+	void *callback_context = ctx->context;
+
+	lib_free(ctx);
+	lib_update_jiffies();
+	callback(callback_context);
+}
+struct SimTask *lib_task_start(void (*callback) (void *), void *context)
+{
+	struct SimTaskTrampolineContext *ctx =
+		lib_malloc(sizeof(struct SimTaskTrampolineContext));
+
+	if (!ctx)
+		return NULL;
+	ctx->callback = callback;
+	ctx->context = context;
+	return g_imported.task_start(g_kernel, &lib_task_start_trampoline, ctx);
+}
+void lib_task_wait(void)
+{
+	rcu_sched_qs();
+	g_imported.task_wait(g_kernel);
+	lib_update_jiffies();
+}
+struct SimTask *lib_task_current(void)
+{
+	return g_imported.task_current(g_kernel);
+}
+int lib_task_wakeup(struct SimTask *task)
+{
+	return g_imported.task_wakeup(g_kernel, task);
+}
+void lib_task_yield(void)
+{
+	rcu_idle_enter();
+	g_imported.task_yield(g_kernel);
+	rcu_idle_exit();
+	lib_update_jiffies();
+}
+
+void lib_dev_xmit(struct SimDevice *dev, unsigned char *data, int len)
+{
+	return g_imported.dev_xmit(g_kernel, dev, data, len);
+}
+
+void lib_signal_raised(struct SimTask *task, int sig)
+{
+	g_imported.signal_raised(g_kernel, task, sig);
+}
+
+void lib_poll_event(int flag, void *context)
+{
+	g_imported.poll_event(flag, context);
+}
diff --git a/arch/lib/lib.h b/arch/lib/lib.h
new file mode 100644
index 0000000..abf2a26
--- /dev/null
+++ b/arch/lib/lib.h
@@ -0,0 +1,21 @@
+/*
+ * library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#ifndef LIB_H
+#define LIB_H
+
+#include <linux/sched.h>
+
+struct SimTask {
+	struct list_head head;
+	struct task_struct kernel_task;
+	void *private;
+};
+
+#endif /* LIB_H */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
