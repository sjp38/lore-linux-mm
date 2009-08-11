Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3DFA96B0055
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 17:29:37 -0400 (EDT)
Date: Wed, 12 Aug 2009 00:28:02 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090811212802.GC26309@redhat.com>
References: <cover.1249992497.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1249992497.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

What it is: vhost net is a character device that can be used to reduce
the number of system calls involved in virtio networking.
Existing virtio net code is used in the guest without modification.

There's similarity with vringfd, with some differences and reduced scope
- uses eventfd for signalling
- structures can be moved around in memory at any time (good for migration)
- support memory table and not just an offset (needed for kvm)

common virtio related code has been put in a separate file vhost.c and
can be made into a separate module if/when more backends appear.  I used
Rusty's lguest.c as the source for developing this part : this supplied
me with witty comments I wouldn't be able to write myself.

What it is not: vhost net is not a bus, and not a generic new system
call. No assumptions are made on how guest performs hypercalls.
Userspace hypervisors are supported as well as kvm.

How it works: Basically, we connect virtio frontend (configured by
userspace) to a backend. The backend could be a network device, or a
tun-like device. In this version I only support raw socket as a backend,
which can be bound to e.g. SR IOV, or to macvlan device.  Backend is
also configured by userspace, including vlan/mac etc.

Status:
This works for me, and I haven't see any crashes.
I have not run any benchmarks yet, compared to userspace, I expect to
see improved latency (as I save up to 4 system calls per packet) but not
bandwidth/CPU (as TSO and interrupt mitigation are not supported).

Features that I plan to look at in the future:
- TSO
- interrupt mitigation
- zero copy

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

v2
---
 MAINTAINERS                |   10 +
 arch/x86/kvm/Kconfig       |    1 +
 drivers/Makefile           |    1 +
 drivers/vhost/Kconfig      |   11 +
 drivers/vhost/Makefile     |    2 +
 drivers/vhost/net.c        |  411 +++++++++++++++++++++++++++
 drivers/vhost/vhost.c      |  663 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h      |  108 +++++++
 include/linux/Kbuild       |    1 +
 include/linux/miscdevice.h |    1 +
 include/linux/vhost.h      |  100 +++++++
 11 files changed, 1309 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/Kconfig
 create mode 100644 drivers/vhost/Makefile
 create mode 100644 drivers/vhost/net.c
 create mode 100644 drivers/vhost/vhost.c
 create mode 100644 drivers/vhost/vhost.h
 create mode 100644 include/linux/vhost.h

diff --git a/MAINTAINERS b/MAINTAINERS
index ebc2691..eb0c1da 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6312,6 +6312,16 @@ S:	Maintained
 F:	Documentation/filesystems/vfat.txt
 F:	fs/fat/
 
+VIRTIO HOST (VHOST)
+P:	Michael S. Tsirkin
+M:	mst@redhat.com
+L:	kvm@vger.kernel.org
+L:	virtualization@lists.osdl.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/vhost/
+F:	include/linux/vhost.h
+
 VIA RHINE NETWORK DRIVER
 P:	Roger Luethi
 M:	rl@hellgate.ch
diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index b84e571..94f44d9 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -64,6 +64,7 @@ config KVM_AMD
 
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
+source drivers/vhost/Kconfig
 source drivers/lguest/Kconfig
 source drivers/virtio/Kconfig
 
diff --git a/drivers/Makefile b/drivers/Makefile
index bc4205d..1551ae1 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -105,6 +105,7 @@ obj-$(CONFIG_HID)		+= hid/
 obj-$(CONFIG_PPC_PS3)		+= ps3/
 obj-$(CONFIG_OF)		+= of/
 obj-$(CONFIG_SSB)		+= ssb/
+obj-$(CONFIG_VHOST_NET)		+= vhost/
 obj-$(CONFIG_VIRTIO)		+= virtio/
 obj-$(CONFIG_VLYNQ)		+= vlynq/
 obj-$(CONFIG_STAGING)		+= staging/
diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
new file mode 100644
index 0000000..d955406
--- /dev/null
+++ b/drivers/vhost/Kconfig
@@ -0,0 +1,11 @@
+config VHOST_NET
+	tristate "Host kernel accelerator for virtio net"
+	depends on NET && EVENTFD
+	---help---
+	  This kernel module can be loaded in host kernel to accelerate
+	  guest networking with virtio_net. Not to be confused with virtio_net
+	  module itself which needs to be loaded in guest kernel.
+
+	  To compile this driver as a module, choose M here: the module will
+	  be called vhost_net.
+
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
new file mode 100644
index 0000000..72dd020
--- /dev/null
+++ b/drivers/vhost/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_VHOST_NET) += vhost_net.o
+vhost_net-y := vhost.o net.o
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
new file mode 100644
index 0000000..a04ffd0
--- /dev/null
+++ b/drivers/vhost/net.c
@@ -0,0 +1,411 @@
+/* Copyright (C) 2009 Red Hat, Inc.
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ *
+ * virtio-net server in host kernel.
+ */
+
+#include <linux/eventfd.h>
+#include <linux/vhost.h>
+#include <linux/virtio_net.h>
+#include <linux/mmu_context.h>
+#include <linux/miscdevice.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
+#include <linux/rcupdate.h>
+#include <linux/file.h>
+
+#include <linux/net.h>
+#include <linux/if_packet.h>
+#include <linux/if_arp.h>
+
+#include <net/sock.h>
+
+#include <asm/mmu_context.h>
+
+#include "vhost.h"
+
+enum {
+	VHOST_NET_VQ_RX = 0,
+	VHOST_NET_VQ_TX = 1,
+	VHOST_NET_VQ_MAX = 2,
+};
+
+struct vhost_net {
+	struct vhost_dev dev;
+	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
+	/* We use a kind of RCU to access sock pointer.
+	 * All readers access it from workqueue,
+	 * which makes it possible to flush the workqueue
+	 * instead of synchronize_rcu. Therefore readers
+	 * do not need rcu_read_lock/rcu_read_unlock.
+	 * Writers use device mutex. */
+	struct socket *sock;
+	struct vhost_poll poll[VHOST_NET_VQ_MAX];
+};
+
+static void handle_tx(struct vhost_net *net)
+{
+	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
+	unsigned head, out, in;
+	struct msghdr msg = {
+		.msg_name = NULL,
+		.msg_namelen = 0,
+		.msg_control = NULL,
+		.msg_controllen = 0,
+		.msg_iov = (struct iovec *)vq->iov + 1,
+		.msg_flags = MSG_DONTWAIT,
+	};
+	size_t len;
+	int err;
+	struct socket *sock = rcu_dereference(net->sock);
+	if (!sock || !sock_writeable(sock->sk))
+		return;
+
+	use_mm(net->dev.mm);
+	mutex_lock(&vq->mutex);
+	for (;;) {
+		head = vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in);
+		if (head == vq->num)
+			break;
+		if (out <= 1 || in) {
+			vq_err(vq, "Unexpected descriptor format for TX: "
+			       "out %d, int %d\n", out, in);
+			break;
+		}
+		/* Sanity check */
+		if (vq->iov->iov_len != sizeof(struct virtio_net_hdr)) {
+			vq_err(vq, "Unexpected header len for TX: "
+			       "%ld expected %zd\n", vq->iov->iov_len,
+			       sizeof(struct virtio_net_hdr));
+			break;
+		}
+		/* Skip header. TODO: support TSO. */
+		msg.msg_iovlen = out - 1;
+		len = iov_length(vq->iov + 1, out - 1);
+		/* TODO: Check specific error and bomb out unless ENOBUFS? */
+		err = sock->ops->sendmsg(NULL, sock, &msg, len);
+		if (err < 0) {
+			vhost_discard_vq_desc(vq);
+			break;
+		}
+		if (err != len)
+			pr_err("Truncated TX packet: "
+			       " len %d != %zd\n", err, len);
+		vhost_add_used_and_trigger(vq, head,
+				     len + sizeof(struct virtio_net_hdr));
+	}
+
+	mutex_unlock(&vq->mutex);
+	unuse_mm(net->dev.mm);
+}
+
+static void handle_rx(struct vhost_net *net)
+{
+	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
+	unsigned head, out, in;
+	struct msghdr msg = {
+		.msg_name = NULL,
+		.msg_namelen = 0,
+		.msg_control = NULL, /* FIXME: get and handle RX aux data. */
+		.msg_controllen = 0,
+		.msg_iov = vq->iov + 1,
+		.msg_flags = MSG_DONTWAIT,
+	};
+
+	struct virtio_net_hdr hdr = {
+		.flags = 0,
+		.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
+
+	size_t len;
+	int err;
+	struct socket *sock = rcu_dereference(net->sock);
+	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+		return;
+
+	use_mm(net->dev.mm);
+	mutex_lock(&vq->mutex);
+
+	for (;;) {
+		head = vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in);
+		if (head == vq->num)
+			break;
+		if (in <= 1 || out) {
+			vq_err(vq, "Unexpected descriptor format for RX: out %d, int %d\n",
+			       out, in);
+			break;
+		}
+		/* Sanity check */
+		if (vq->iov->iov_len != sizeof(struct virtio_net_hdr)) {
+			vq_err(vq, "Unexpected header len for RX: %ld expected %zd\n",
+			       vq->iov->iov_len, sizeof(struct virtio_net_hdr));
+			break;
+		}
+		/* Skip header. TODO: support TSO/mergeable rx buffers. */
+		msg.msg_iovlen = in - 1;
+		len = iov_length(vq->iov + 1, in - 1);
+		err = sock->ops->recvmsg(NULL, sock, &msg,
+					 len, MSG_DONTWAIT | MSG_TRUNC);
+		/* TODO: Check specific error and bomb out unless EAGAIN? */
+		if (err < 0) {
+			vhost_discard_vq_desc(vq);
+			break;
+		}
+		/* TODO: Should check and handle checksum. */
+		if (err > len) {
+			pr_err("Discarded truncated rx packet: "
+			       " len %d > %zd\n", err, len);
+			vhost_discard_vq_desc(vq);
+			continue;
+		}
+		len = err;
+		err = copy_to_user(vq->iov->iov_base, &hdr, sizeof hdr);
+		if (err) {
+			vq_err(vq, "Unable to write vnet_hdr at addr %p: %d\n",
+			       vq->iov->iov_base, err);
+			break;
+		}
+		vhost_add_used_and_trigger(vq, head, len + sizeof hdr);
+	}
+
+	mutex_unlock(&vq->mutex);
+	unuse_mm(net->dev.mm);
+}
+
+static void handle_tx_kick(struct work_struct *work)
+{
+	struct vhost_virtqueue *vq;
+	struct vhost_net *net;
+	vq = container_of(work, struct vhost_virtqueue, poll.work);
+	net = container_of(vq->dev, struct vhost_net, dev);
+	handle_tx(net);
+}
+
+static void handle_rx_kick(struct work_struct *work)
+{
+	struct vhost_virtqueue *vq;
+	struct vhost_net *net;
+	vq = container_of(work, struct vhost_virtqueue, poll.work);
+	net = container_of(vq->dev, struct vhost_net, dev);
+	handle_rx(net);
+}
+
+static void handle_tx_net(struct work_struct *work)
+{
+	struct vhost_net *net;
+	net = container_of(work, struct vhost_net, poll[VHOST_NET_VQ_TX].work);
+	handle_tx(net);
+}
+
+static void handle_rx_net(struct work_struct *work)
+{
+	struct vhost_net *net;
+	net = container_of(work, struct vhost_net, poll[VHOST_NET_VQ_RX].work);
+	handle_rx(net);
+}
+
+static int vhost_net_open(struct inode *inode, struct file *f)
+{
+	struct vhost_net *n = kzalloc(sizeof *n, GFP_KERNEL);
+	int r;
+	if (!n)
+		return -ENOMEM;
+	f->private_data = n;
+	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
+	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
+	r = vhost_dev_init(&n->dev, n->vqs, VHOST_NET_VQ_MAX);
+	if (r < 0) {
+		kfree(n);
+		return r;
+	}
+
+	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
+	return 0;
+}
+
+static struct socket *vhost_net_stop(struct vhost_net *n)
+{
+	struct socket *sock = n->sock;
+	rcu_assign_pointer(n->sock, NULL);
+	if (sock) {
+		vhost_poll_flush(n->poll + VHOST_NET_VQ_TX);
+		vhost_poll_flush(n->poll + VHOST_NET_VQ_RX);
+	}
+	return sock;
+}
+
+static int vhost_net_release(struct inode *inode, struct file *f)
+{
+	struct vhost_net *n = f->private_data;
+	struct socket *sock;
+
+	sock = vhost_net_stop(n);
+	vhost_dev_cleanup(&n->dev);
+	if (sock)
+		fput(sock->file);
+	kfree(n);
+	return 0;
+}
+
+static long vhost_net_set_socket(struct vhost_net *n, int fd)
+{
+	struct {
+		struct sockaddr_ll sa;
+		char  buf[MAX_ADDR_LEN];
+	} uaddr;
+	struct socket *sock, *oldsock = NULL;
+	int uaddr_len = sizeof uaddr, r;
+
+	mutex_lock(&n->dev.mutex);
+	r = vhost_dev_check_owner(&n->dev);
+	if (r)
+		goto done;
+
+	if (fd == -1) {
+		/* Disconnect from socket and device. */
+		oldsock = vhost_net_stop(n);
+		goto done;
+	}
+	
+	sock = sockfd_lookup(fd, &r);
+	if (!sock) {
+		r = -ENOTSOCK;
+		goto done;
+	}
+
+	/* Parameter checking */
+	if (sock->sk->sk_type != SOCK_RAW) {
+		r = -ESOCKTNOSUPPORT;
+		goto done;
+	}
+
+	r = sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
+			       &uaddr_len, 0);
+	if (r)
+		goto done;
+
+	if (uaddr.sa.sll_family != AF_PACKET) {
+		r = -EPFNOSUPPORT;
+		goto done;
+	}
+
+	/* start polling new socket */
+	if (sock == oldsock)
+		goto done;
+
+	if (oldsock) {
+		vhost_poll_stop(n->poll + VHOST_NET_VQ_TX);
+		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+	}
+	oldsock = n->sock;
+	rcu_assign_pointer(n->sock, sock);
+	vhost_poll_start(n->poll + VHOST_NET_VQ_TX, sock->file);
+	vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+done:
+	mutex_unlock(&n->dev.mutex);
+	if (oldsock) {
+		vhost_poll_flush(n->poll + VHOST_NET_VQ_TX);
+		vhost_poll_flush(n->poll + VHOST_NET_VQ_RX);
+		vhost_poll_flush(&n->dev.vqs[VHOST_NET_VQ_TX].poll);
+		vhost_poll_flush(&n->dev.vqs[VHOST_NET_VQ_RX].poll);
+		fput(oldsock->file);
+	}
+	return r;
+}
+
+static long vhost_net_reset_owner(struct vhost_net *n)
+{
+	struct socket *sock = NULL;
+	long r;
+	mutex_lock(&n->dev.mutex);
+	r = vhost_dev_check_owner(&n->dev);
+	if (r)
+		goto done;
+	sock = vhost_net_stop(n);
+	r = vhost_dev_reset_owner(&n->dev);
+done:
+	mutex_unlock(&n->dev.mutex);
+	if (sock)
+		fput(sock->file);
+	return r;
+}
+
+static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
+			    unsigned long arg)
+{
+	struct vhost_net *n = f->private_data;
+	void __user *argp = (void __user *)arg;
+	u32 __user *featurep = argp;
+	int __user *fdp = argp;
+	u32 features;
+	int fd, r;
+	switch (ioctl) {
+	case VHOST_NET_SET_SOCKET:
+		r = get_user(fd, fdp);
+		if (r < 0)
+			return r;
+		return vhost_net_set_socket(n, fd);
+	case VHOST_GET_FEATURES:
+		/* No features for now */
+		features = 0;
+		return put_user(features, featurep);
+	case VHOST_ACK_FEATURES:
+		r = get_user(features, featurep);
+		/* No features for now */
+		if (r < 0)
+			return r;
+		if (features)
+			return -EOPNOTSUPP;
+		return 0;
+	case VHOST_RESET_OWNER:
+		return vhost_net_reset_owner(n);
+	default:
+		return vhost_dev_ioctl(&n->dev, ioctl, arg);
+	}
+}
+
+static struct file_operations vhost_net_fops = {
+	.owner          = THIS_MODULE,
+	.release        = vhost_net_release,
+	.unlocked_ioctl = vhost_net_ioctl,
+	.open           = vhost_net_open,
+};
+
+static struct miscdevice vhost_net_misc = {
+	VHOST_NET_MINOR,
+	"vhost-net",
+	&vhost_net_fops,
+};
+
+int vhost_net_init(void)
+{
+	int r = vhost_init();
+	if (r)
+		goto err_init;
+	r = misc_register(&vhost_net_misc);
+	if (r)
+		goto err_reg;
+	return 0;
+err_reg:
+	vhost_cleanup();
+err_init:
+	return r;
+
+}
+module_init(vhost_net_init);
+
+void vhost_net_exit(void)
+{
+	misc_deregister(&vhost_net_misc);
+	vhost_cleanup();
+}
+module_exit(vhost_net_exit);
+
+MODULE_VERSION("0.0.1");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Michael S. Tsirkin");
+MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
new file mode 100644
index 0000000..6178ec1
--- /dev/null
+++ b/drivers/vhost/vhost.c
@@ -0,0 +1,663 @@
+/* Copyright (C) 2009 Red Hat, Inc.
+ * Copyright (C) 2006 Rusty Russell IBM Corporation
+ *
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * Inspiration, some code, and most witty comments come from
+ * Documentation/lguest/lguest.c, by Rusty Russell
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ *
+ * Generic code for virtio server in host kernel.
+ */
+
+#include <linux/eventfd.h>
+#include <linux/vhost.h>
+#include <linux/virtio_net.h>
+#include <linux/mm.h>
+#include <linux/miscdevice.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
+#include <linux/rcupdate.h>
+#include <linux/poll.h>
+#include <linux/file.h>
+
+#include <linux/net.h>
+#include <linux/if_packet.h>
+#include <linux/if_arp.h>
+
+#include <net/sock.h>
+
+#include <asm/mmu_context.h>
+
+#include "vhost.h"
+
+enum {
+	VHOST_MEMORY_MAX_NREGIONS = 64,
+};
+
+struct workqueue_struct *vhost_workqueue;
+
+static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
+			    poll_table *pt)
+{
+	struct vhost_poll *poll;
+	poll = container_of(pt, struct vhost_poll, table);
+
+	poll->wqh = wqh;
+	add_wait_queue(wqh, &poll->wait);
+}
+
+static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct vhost_poll *poll;
+	poll = container_of(wait, struct vhost_poll, wait);
+	if (!((unsigned long)key & poll->mask))
+		return 0;
+
+	queue_work(vhost_workqueue, &poll->work);
+	return 0;
+}
+
+/* Init poll structure */
+void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
+		     unsigned long mask)
+{
+	INIT_WORK(&poll->work, func);
+	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
+	init_poll_funcptr(&poll->table, vhost_poll_func);
+	poll->mask = mask;
+}
+
+/* Start polling a file. We add ourselves to file's wait queue. The user must
+ * keep a reference to a file until after vhost_poll_stop is called. */
+void vhost_poll_start(struct vhost_poll *poll, struct file *file)
+{
+	unsigned long mask;
+	mask = file->f_op->poll(file, &poll->table);
+	if (mask)
+		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
+}
+
+/* Stop polling a file. After this function returns, it becomes safe to drop the
+ * file reference. You must also flush afterwards. */
+void vhost_poll_stop(struct vhost_poll *poll)
+{
+	remove_wait_queue(poll->wqh, &poll->wait);
+}
+
+/* Flush any work that has been scheduled. When calling this, don't hold any
+ * locks that are also used by the callback. */
+void vhost_poll_flush(struct vhost_poll *poll)
+{
+	flush_work(&poll->work);
+}
+
+long vhost_dev_init(struct vhost_dev *dev, struct vhost_virtqueue *vqs, int nvqs)
+{
+	int i;
+	dev->vqs = vqs;
+	dev->nvqs = nvqs;
+	mutex_init(&dev->mutex);
+
+	for(i = 0; i < dev->nvqs; ++i) {
+		dev->vqs[i].dev = dev;
+		mutex_init(&dev->vqs[i].mutex);
+		if (dev->vqs[i].handle_kick)
+			vhost_poll_init(&dev->vqs[i].poll,
+					dev->vqs[i].handle_kick,
+					POLLIN);
+	}
+	return 0;
+}
+
+/* User should have device mutex */
+long vhost_dev_check_owner(struct vhost_dev *dev)
+{
+	return dev->mm == current->mm ? 0 : -EPERM;
+}
+
+/* User should have device mutex */
+static long vhost_dev_set_owner(struct vhost_dev *dev)
+{
+	if (dev->mm)
+		return -EBUSY;
+	dev->mm = get_task_mm(current);
+	return 0;
+}
+
+/* User should have device mutex */
+long vhost_dev_reset_owner(struct vhost_dev *dev)
+{
+	struct vhost_memory *memory;
+
+	/* Restore memory to default 1:1 mapping. */
+	memory = kmalloc(offsetof(struct vhost_memory, regions) +
+			 2 * sizeof *memory->regions, GFP_KERNEL);
+	if (!memory)
+		return -ENOMEM;
+
+	vhost_dev_cleanup(dev);
+
+	memory->nregions = 2;
+	memory->regions[0].guest_phys_addr = 1;
+	memory->regions[0].userspace_addr = 1;
+	memory->regions[0].memory_size = ~0ULL;
+	memory->regions[1].guest_phys_addr = 0;
+	memory->regions[1].userspace_addr = 0;
+	memory->regions[1].memory_size = 1;
+	dev->memory = memory;
+	return 0;
+}
+
+/* User should have device mutex */
+void vhost_dev_cleanup(struct vhost_dev *dev)
+{
+	int i;
+	for(i = 0; i < dev->nvqs; ++i) {
+		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
+			vhost_poll_stop(&dev->vqs[i].poll);
+			vhost_poll_flush(&dev->vqs[i].poll);
+		}
+		if (dev->vqs[i].error_ctx)
+			eventfd_ctx_put(dev->vqs[i].error_ctx);
+		if (dev->vqs[i].error)
+			fput(dev->vqs[i].error);
+		if (dev->vqs[i].kick)
+			fput(dev->vqs[i].kick);
+		if (dev->vqs[i].call_ctx)
+			eventfd_ctx_put(dev->vqs[i].call_ctx);
+		if (dev->vqs[i].call)
+			fput(dev->vqs[i].call);
+		dev->vqs[i].error_ctx = NULL;
+		dev->vqs[i].error = NULL;
+		dev->vqs[i].kick = NULL;
+		dev->vqs[i].call_ctx = NULL;
+		dev->vqs[i].call = NULL;
+	}
+	/* No one will access memory at this point */
+	kfree(dev->memory);
+	dev->memory = NULL;
+	if (dev->mm)
+		mmput(dev->mm);
+	dev->mm = NULL;
+}
+
+static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
+{
+	struct vhost_memory mem, *newmem, *oldmem;
+	unsigned long size = offsetof(struct vhost_memory, regions);
+	long r;
+	r = copy_from_user(&mem, m, size);
+	if (r)
+		return r;
+	if (mem.padding)
+		return -EOPNOTSUPP;
+	if (mem.nregions > VHOST_MEMORY_MAX_NREGIONS)
+		return -E2BIG;
+	newmem = kmalloc(size + mem.nregions * sizeof *m->regions, GFP_KERNEL);
+	if (!newmem)
+		return -ENOMEM;
+
+	memcpy(newmem, &mem, size);
+	r = copy_from_user(newmem->regions, m->regions,
+			   mem.nregions * sizeof *m->regions);
+	if (r) {
+		kfree(newmem);
+		return r;
+	}
+	oldmem = d->memory;
+	rcu_assign_pointer(d->memory, newmem);
+	synchronize_rcu();
+	kfree(oldmem);
+	return 0;
+}
+
+static int init_used(struct vhost_virtqueue *vq)
+{
+	u16 flags = 0;
+	int r = put_user(flags, &vq->used->flags);
+	if (r)
+		return r;
+	return get_user(vq->last_used_idx, &vq->used->idx);
+}
+
+static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
+{
+	struct file *eventfp, *filep = NULL, *pollstart = NULL, *pollstop = NULL;
+	struct eventfd_ctx *ctx = NULL;
+	u32 __user *idxp = argp;
+	struct vhost_virtqueue *vq;
+	struct vhost_vring_state s;
+	struct vhost_vring_file f;
+	struct vhost_vring_addr a;
+	u32 idx;
+	long r;
+
+	r = get_user(idx, idxp);
+	if (r < 0)
+		return r;
+	if (idx > d->nvqs)
+		return -ENOBUFS;
+
+	vq = d->vqs + idx;
+
+	mutex_lock(&vq->mutex);
+
+	switch (ioctl) {
+	case VHOST_SET_VRING_NUM:
+		r = copy_from_user(&s, argp, sizeof s);
+		if (r < 0)
+			break;
+		if (s.num > 0xffff) {
+			r = -EINVAL;
+			break;
+		}
+		vq->num = s.num;
+		break;
+	case VHOST_SET_VRING_BASE:
+		r = copy_from_user(&s, argp, sizeof s);
+		if (r < 0)
+			break;
+		if (s.num > 0xffff) {
+			r = -EINVAL;
+			break;
+		}
+		vq->last_avail_idx = s.num;
+		break;
+	case VHOST_GET_VRING_BASE:
+		s.index = idx;
+		s.num = vq->last_avail_idx;
+		r = copy_to_user(argp, &s, sizeof s);
+		break;
+	case VHOST_SET_VRING_DESC:
+		r = copy_from_user(&a, argp, sizeof a);
+		if (r < 0)
+			break;
+		if (a.padding) {
+			r = -EOPNOTSUPP;
+			break;
+		}
+		if ((u64)(long)a.user_addr != a.user_addr) {
+			r = -EFAULT;
+			break;
+		}
+		vq->desc = (void __user *)(long)a.user_addr;
+		break;
+	case VHOST_SET_VRING_AVAIL:
+		r = copy_from_user(&a, argp, sizeof a);
+		if (r < 0)
+			break;
+		if (a.padding) {
+			r = -EOPNOTSUPP;
+			break;
+		}
+		if ((u64)(long)a.user_addr != a.user_addr) {
+			r = -EFAULT;
+			break;
+		}
+		vq->avail = (void __user *)(long)a.user_addr;
+		break;
+	case VHOST_SET_VRING_USED:
+		r = copy_from_user(&a, argp, sizeof a);
+		if (r < 0)
+			break;
+		if (a.padding) {
+			r = -EOPNOTSUPP;
+			break;
+		}
+		if ((u64)(long)a.user_addr != a.user_addr) {
+			r = -EFAULT;
+			break;
+		}
+		vq->used = (void __user *)(long)a.user_addr;
+		r = init_used(vq);
+		if (r)
+			break;
+		break;
+	case VHOST_SET_VRING_KICK:
+		r = copy_from_user(&f, argp, sizeof f);
+		if (r < 0)
+			break;
+		eventfp = f.fd == -1 ? NULL: eventfd_fget(f.fd);
+		if (IS_ERR(eventfp))
+			return PTR_ERR(eventfp);
+		if (eventfp != vq->kick) {
+			pollstop = filep = vq->kick;
+			pollstart = vq->kick = eventfp;
+		} else
+			filep = eventfp;
+		break;
+	case VHOST_SET_VRING_CALL:
+		r = copy_from_user(&f, argp, sizeof f);
+		if (r < 0)
+			break;
+		eventfp = f.fd == -1 ? NULL: eventfd_fget(f.fd);
+		if (IS_ERR(eventfp))
+			return PTR_ERR(eventfp);
+		if (eventfp != vq->call) {
+			filep = vq->call;
+			ctx = vq->call_ctx;
+			vq->call = eventfp;
+			vq->call_ctx = eventfp ?
+				eventfd_ctx_fileget(eventfp) : NULL;
+		} else
+			filep = eventfp;
+		break;
+	case VHOST_SET_VRING_ERR:
+		r = copy_from_user(&f, argp, sizeof f);
+		if (r < 0)
+			break;
+		eventfp = f.fd == -1 ? NULL: eventfd_fget(f.fd);
+		if (IS_ERR(eventfp))
+			return PTR_ERR(eventfp);
+		if (eventfp != vq->error) {
+			filep = vq->error;
+			vq->error = eventfp;
+			ctx = vq->error_ctx;
+			vq->error_ctx = eventfp ?
+				eventfd_ctx_fileget(eventfp) : NULL;
+		} else
+			filep = eventfp;
+		break;
+	default:
+		r = -ENOTTY;
+	}
+
+	if (pollstop && vq->handle_kick)
+		vhost_poll_stop(&vq->poll);
+
+	if (ctx)
+		eventfd_ctx_put(ctx);
+	if (filep)
+		fput(filep);
+
+	if (pollstart && vq->handle_kick)
+		vhost_poll_start(&vq->poll, vq->kick);
+
+	mutex_unlock(&vq->mutex);
+
+	if (pollstop && vq->handle_kick)
+		vhost_poll_flush(&vq->poll);
+	return 0;
+}
+
+long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
+{
+	void __user *argp = (void __user *)arg;
+	long r;
+
+	mutex_lock(&d->mutex);
+	if (ioctl == VHOST_SET_OWNER) {
+		r = vhost_dev_set_owner(d);
+		goto done;
+	}
+
+	r = vhost_dev_check_owner(d);
+	if (r)
+		goto done;
+		
+	switch (ioctl) {
+	case VHOST_SET_MEM_TABLE:
+		r = vhost_set_memory(d, argp);
+		break;
+	default:
+		r = vhost_set_vring(d, ioctl, argp);
+		break;
+	}
+done:
+	mutex_unlock(&d->mutex);
+	return r;
+}
+
+static const struct vhost_memory_region *find_region(struct vhost_memory *mem,
+						     __u64 addr, __u32 len)
+{
+	struct vhost_memory_region *reg;
+	int i;
+	/* linear search is not brilliant, but we really have on the order of 6
+	 * regions in practice */
+	for (i = 0; i < mem->nregions; ++i) {
+		reg = mem->regions + i;
+		if (reg->guest_phys_addr <= addr &&
+		    reg->guest_phys_addr + reg->memory_size - 1 >= addr)
+			return reg;
+	}
+	return NULL;
+}
+
+/* FIXME: this does not handle a region that spans multiple
+ * address/len pairs */
+int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
+		   struct iovec iov[], int iov_count, int iov_size,
+		   unsigned *num)
+{
+	const struct vhost_memory_region *reg;
+	struct vhost_memory *mem;
+	struct iovec *_iov;
+	u64 s = 0;
+	int ret = 0;
+
+	rcu_read_lock();
+
+	mem = rcu_dereference(dev->memory);
+	while ((u64)len > s) {
+		u64 size;
+		if (*num + iov_count >= iov_size) {
+			ret = -ENOBUFS;
+			break;
+		}
+		reg = find_region(mem, addr, len);
+		if (!reg) {
+			ret = -EFAULT;
+			break;
+		}
+		_iov = iov + iov_count + *num;
+		size = reg->memory_size - addr + reg->guest_phys_addr;
+		_iov->iov_len = min((u64)len, size);
+		_iov->iov_base = (void *)
+			(reg->userspace_addr + addr - reg->guest_phys_addr);
+		s += size;
+		addr += size;
+		++*num;
+	}
+	
+	rcu_read_unlock();
+	return ret;
+}
+
+/* Each buffer in the virtqueues is actually a chain of descriptors.  This
+ * function returns the next descriptor in the chain, or vq->vring.num if we're
+ * at the end. */
+static unsigned next_desc(struct vhost_virtqueue *vq, struct vring_desc *desc)
+{
+	unsigned int next;
+
+	/* If this descriptor says it doesn't chain, we're done. */
+	if (!(desc->flags & VRING_DESC_F_NEXT))
+		return vq->num;
+
+	/* Check they're not leading us off end of descriptors. */
+	next = desc->next;
+	/* Make sure compiler knows to grab that: we don't want it changing! */
+	/* We will use the result as an index in an array, so most
+	 * architectures only need a compiler barrier here. */
+	read_barrier_depends();
+
+	if (next >= vq->num) {
+		vq_err(vq, "Desc next is %u > %u", next, vq->num);
+		return vq->num;
+	}
+
+	return next;
+}
+
+/* This looks in the virtqueue and for the first available buffer, and converts
+ * it to an iovec for convenient access.  Since descriptors consist of some
+ * number of output then some number of input descriptors, it's actually two
+ * iovecs, but we pack them into one and note how many of each there were.
+ *
+ * This function returns the descriptor number found, or vq->num (which
+ * is never a valid descriptor number) if none was found. */
+unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			   struct iovec iov[],
+			   unsigned int *out_num, unsigned int *in_num)
+{
+	struct vring_desc desc;
+	unsigned int i, head;
+	u16 last_avail_idx, idx;
+
+	/* Check it isn't doing very strange things with descriptor numbers. */
+	last_avail_idx = vq->last_avail_idx;
+	if (get_user(idx, &vq->avail->idx)) {
+		vq_err(vq, "Failed to access avail idx at %p\n",
+		       &vq->avail->idx);
+		return vq->num;
+	}
+	
+	if ((u16)(idx - last_avail_idx) > vq->num) {
+		vq_err(vq, "Guest moved used index from %u to %u",
+		       last_avail_idx, idx);
+		return vq->num;
+	}
+
+	/* If there's nothing new since last we looked, return invalid. */
+	if (idx == last_avail_idx)
+		return vq->num;
+
+	/* Grab the next descriptor number they're advertising, and increment
+	 * the index we've seen. */
+	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
+		vq_err(vq, "Failed to read head: idx %d address %p\n",
+		       idx, &vq->avail->ring[last_avail_idx % vq->num]);
+		return vq->num;
+	}
+
+	/* If their number is silly, that's a fatal mistake. */
+	if (head >= vq->num) {
+		vq_err(vq, "Guest says index %u > %u is available",
+		       head, vq->num);
+		return vq->num;
+	}
+
+	vq->last_avail_idx++;
+
+	/* When we start there are none of either input nor output. */
+	*out_num = *in_num = 0;
+
+	i = head;
+	do {
+		unsigned *num;
+		unsigned iov_count;
+		if (copy_from_user(&desc, vq->desc + i, sizeof desc)) {
+			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
+			       i, vq->desc + i);
+			return vq->num;
+		}
+		/* If this is an input descriptor, increment that count. */
+		if (desc.flags & VRING_DESC_F_WRITE) {
+			num = in_num;
+			iov_count = *out_num;
+		} else {
+			/* If it's an output descriptor, they're all supposed
+			 * to come before any input descriptors. */
+			if (*in_num) {
+				vq_err(vq, "Descriptor has out after in: "
+				       "idx %d\n", i);
+				return vq->num;
+			}
+			num = out_num;
+			iov_count = *in_num;
+		}
+		if (translate_desc(dev, desc.addr, desc.len, iov, iov_count,
+				   VHOST_NET_MAX_SG, num)) {
+			vq_err(vq, "Failed to translate descriptor: idx %d\n",
+			       i);
+			return vq->num;
+		}
+
+		/* If we've got too many, that implies a descriptor loop. */
+		if (*out_num + *in_num > vq->num) {
+			vq_err(vq, "Looped descriptor: idx %d\n", i);
+			return vq->num;
+		}
+	} while ((i = next_desc(vq, &desc)) != vq->num);
+
+	vq->inflight++;
+	return head;
+}
+
+/* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
+void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
+{
+	vq->last_avail_idx--;
+	vq->inflight--;
+}
+
+/* After we've used one of their buffers, we tell them about it.  We'll then
+ * want to send them an interrupt, using vq->call. */
+int vhost_add_used(struct vhost_virtqueue *vq,
+			  unsigned int head, int len)
+{
+	struct vring_used_elem *used;
+
+	/* The virtqueue contains a ring of used buffers.  Get a pointer to the
+	 * next entry in that used ring. */
+	used = &vq->used->ring[vq->last_used_idx % vq->num];
+	if (put_user(head, &used->id)) {
+		vq_err(vq, "Failed to write used id");
+		return -EFAULT;
+	}
+	if (put_user(len, &used->len)) {
+		vq_err(vq, "Failed to write used len");
+		return -EFAULT;
+	}
+	/* Make sure buffer is written before we update index. */
+	wmb();
+	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+		vq_err(vq, "Failed to increment used idx");
+		return -EFAULT;
+	}
+	vq->last_used_idx++;
+	vq->inflight--;
+	return 0;
+}
+
+/* This actually sends the interrupt for this virtqueue */
+void vhost_trigger_irq(struct vhost_virtqueue *vq)
+{
+	__u16 flags = 0;
+	if (get_user(flags, &vq->avail->flags)) {
+		vq_err(vq, "Failed to get flags");
+		return;
+	}
+
+	/* If they don't want an interrupt, don't send one, unless empty. */
+	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) && vq->inflight)
+		return;
+
+	/* Send the Guest an interrupt tell them we used something up. */
+	if (vq->call_ctx)
+		eventfd_signal(vq->call_ctx, 1);
+}
+
+/* And here's the combo meal deal.  Supersize me! */
+void vhost_add_used_and_trigger(struct vhost_virtqueue *vq,
+				unsigned int head, int len)
+{
+	vhost_add_used(vq, head, len);
+	vhost_trigger_irq(vq);
+}
+
+int vhost_init(void)
+{
+	vhost_workqueue = create_workqueue("vhost");
+	if (!vhost_workqueue)
+		return -ENOMEM;
+	return 0;
+}
+
+void vhost_cleanup(void)
+{
+	destroy_workqueue(vhost_workqueue);
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
new file mode 100644
index 0000000..7f7ffcd
--- /dev/null
+++ b/drivers/vhost/vhost.h
@@ -0,0 +1,108 @@
+#ifndef _VHOST_H
+#define _VHOST_H
+
+#include <linux/eventfd.h>
+#include <linux/vhost.h>
+#include <linux/mm.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
+#include <linux/poll.h>
+#include <linux/file.h>
+#include <linux/skbuff.h>
+
+struct vhost_device;
+
+enum {
+	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
+};
+
+/* Poll a file (eventfd or socket) */
+/* Note: there's nothing vhost specific about this structure. */
+struct vhost_poll {
+	poll_table                table;
+	wait_queue_head_t        *wqh;
+	wait_queue_t              wait;
+	/* struct which will handle all actual work. */
+	struct work_struct        work;
+	unsigned long		  mask;
+};
+
+void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
+		     unsigned long mask);
+void vhost_poll_start(struct vhost_poll *poll, struct file *file);
+void vhost_poll_stop(struct vhost_poll *poll);
+void vhost_poll_flush(struct vhost_poll *poll);
+
+/* The virtqueue structure describes a queue attached to a device. */
+struct vhost_virtqueue {
+	struct vhost_dev *dev;
+
+	/* The actual ring of buffers. */
+	struct mutex mutex;
+	unsigned int num;
+	struct vring_desc __user *desc;
+	struct vring_avail __user *avail;
+	struct vring_used __user *used;
+	struct file *kick;
+	struct file *call;
+	struct file *error;
+	struct eventfd_ctx *call_ctx;
+	struct eventfd_ctx *error_ctx;
+
+	struct vhost_poll poll;
+
+	/* The routine to call when the Guest pings us, or timeout. */
+	work_func_t handle_kick;
+
+	/* Last available index we saw. */
+	u16 last_avail_idx;
+
+	/* Last index we used. */
+	u16 last_used_idx;
+
+	/* Outstanding buffers */
+	unsigned int inflight;
+
+	/* Is this blocked? */
+	bool blocked;
+
+	struct iovec iov[VHOST_NET_MAX_SG];
+
+} ____cacheline_aligned;
+
+struct vhost_dev {
+	/* Readers use RCU to access memory table pointer.
+	 * Writers use mutex below.*/
+	struct vhost_memory *memory;
+	struct mm_struct *mm;
+	struct vhost_virtqueue *vqs;
+	int nvqs;
+	struct mutex mutex;
+};
+
+long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
+long vhost_dev_check_owner(struct vhost_dev *);
+long vhost_dev_reset_owner(struct vhost_dev *);
+void vhost_dev_cleanup(struct vhost_dev *);
+long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
+
+unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+			   struct iovec iov[],
+			   unsigned int *out_num, unsigned int *in_num);
+void vhost_discard_vq_desc(struct vhost_virtqueue *);
+
+int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
+void vhost_trigger_irq(struct vhost_virtqueue *);
+void vhost_add_used_and_trigger(struct vhost_virtqueue *,
+				unsigned int head, int len);
+
+int vhost_init(void);
+void vhost_cleanup(void);
+
+#define vq_err(vq, fmt, ...) do {                                  \
+		printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__);       \
+		if ((vq)->error_ctx)                               \
+				eventfd_signal((vq)->error_ctx, 1);\
+	} while (0)
+
+#endif
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index dec2f18..975df9a 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -360,6 +360,7 @@ unifdef-y += uio.h
 unifdef-y += unistd.h
 unifdef-y += usbdevice_fs.h
 unifdef-y += utsname.h
+unifdef-y += vhost.h
 unifdef-y += videodev2.h
 unifdef-y += videodev.h
 unifdef-y += virtio_config.h
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index 0521177..781a8bb 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,6 +30,7 @@
 #define HPET_MINOR		228
 #define FUSE_MINOR		229
 #define KVM_MINOR		232
+#define VHOST_NET_MINOR		233
 #define MISC_DYNAMIC_MINOR	255
 
 struct device;
diff --git a/include/linux/vhost.h b/include/linux/vhost.h
new file mode 100644
index 0000000..9ec6d5f
--- /dev/null
+++ b/include/linux/vhost.h
@@ -0,0 +1,100 @@
+#ifndef _LINUX_VHOST_H
+#define _LINUX_VHOST_H
+/* Userspace interface for in-kernel virtio accelerators. */
+
+/* vhost is used to reduce the number of system calls involved in virtio.
+ *
+ * Existing virtio net code is used in the guest without modification.
+ *
+ * This header includes interface used by userspace hypervisor for
+ * device configuration.
+ */
+
+#include <linux/types.h>
+#include <linux/compiler.h>
+#include <linux/ioctl.h>
+#include <linux/virtio_config.h>
+#include <linux/virtio_ring.h>
+
+struct vhost_vring_state {
+	unsigned int index;
+	unsigned int num;
+};
+
+struct vhost_vring_file {
+	unsigned int index;
+	int fd;
+};
+
+struct vhost_vring_addr {
+	unsigned int index;
+	unsigned int padding;
+	__u64 user_addr;
+};
+
+struct vhost_memory_region {
+	__u64 guest_phys_addr;
+	__u64 memory_size; /* bytes */
+	__u64 userspace_addr;
+	__u64 padding; /* read/write protection? */
+};
+
+struct vhost_memory {
+	__u32 nregions;
+	__u32 padding;
+	struct vhost_memory_region regions[0];
+};
+
+/* ioctls */
+
+#define VHOST_VIRTIO 0xAF
+
+/* Features bitmask for forward compatibility. Transport bits must be zero. */
+#define VHOST_GET_FEATURES	_IOR(VHOST_VIRTIO, 0x00, __u32)
+#define VHOST_ACK_FEATURES	_IOW(VHOST_VIRTIO, 0x00, __u32)
+
+/* Set current process as the (exclusive) owner of this file descriptor.  This
+ * must be called before any other vhost command.  Further calls to
+ * VHOST_OWNER_SET fail until VHOST_OWNER_RESET is called. */
+#define VHOST_SET_OWNER _IO(VHOST_VIRTIO, 0x01)
+/* Give up ownership, and reset the device to default values.
+ * Allows subsequent call to VHOST_OWNER_SET to succeed. */
+#define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
+
+/* Set up/modify memory layout */
+#define VHOST_SET_MEM_TABLE	_IOW(VHOST_VIRTIO, 0x03, struct vhost_memory)
+
+/* Ring setup. These parameters can not be modified while ring is running
+ * (bound to a device). */
+/* Set number of descriptors in ring */
+#define VHOST_SET_VRING_NUM _IOW(VHOST_VIRTIO, 0x10, struct vhost_vring_state)
+/* Start of array of descriptors (virtually contiguous) */
+#define VHOST_SET_VRING_DESC _IOW(VHOST_VIRTIO, 0x11, struct vhost_vring_addr)
+/* Used structure address */
+#define VHOST_SET_VRING_USED _IOW(VHOST_VIRTIO, 0x12, struct vhost_vring_addr)
+/* Available structure address */
+#define VHOST_SET_VRING_AVAIL _IOW(VHOST_VIRTIO, 0x13, struct vhost_vring_addr)
+/* Base value where queue looks for available descriptors */
+#define VHOST_SET_VRING_BASE _IOW(VHOST_VIRTIO, 0x14, struct vhost_vring_state)
+/* Get accessor: reads index, writes value in num */
+#define VHOST_GET_VRING_BASE _IOWR(VHOST_VIRTIO, 0x14, struct vhost_vring_state)
+
+/* The following ioctls use eventfd file descriptors to signal and poll
+ * for events. */
+
+/* Set eventfd to poll for added buffers */
+#define VHOST_SET_VRING_KICK _IOW(VHOST_VIRTIO, 0x20, struct vhost_vring_file)
+/* Set eventfd to signal when buffers have beed used */
+#define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vring_file)
+/* Set eventfd to signal an error */
+#define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
+
+/* VHOST_NET specific defines */
+
+/* Attach virtio net device to a raw socket. The socket must be already
+ * bound to an ethernet device, this device will be used for transmit.
+ * Pass -1 to unbind from the socket and the transmit device.
+ * This can be used to stop the device (e.g. for migration). */
+#define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, int)
+
+#endif
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
