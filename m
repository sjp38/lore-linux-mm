Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ECFD56B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 00:42:55 -0500 (EST)
From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Wed, 18 Nov 2009 13:42:43 +0800
Subject: RE: [PATCHv9 3/3] vhost_net: a kernel-level virtio server
Message-ID: <C85CEDA13AB1CF4D9D597824A86D2B901925446AB4@PDSMSX501.ccr.corp.intel.com>
References: <cover.1257786516.git.mst@redhat.com>
 <20091109172230.GD4724@redhat.com>
In-Reply-To: <20091109172230.GD4724@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, "s.hetze@linux-ag.com" <s.hetze@linux-ag.com>, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

Michael,
>From the http://www.linux-kvm.org/page/VhostNet, we can see netperf with TC=
P_STREAM can get more than 4GMb/s for the receive side, and more than 5GMb/=
s for the send side.
Is it the result from the raw socket or through tap?
I want to duplicate such performance with vhost on my side. I can only get =
more than 1GMb/s with following conditions:
1) disabled the GRO feature in the host 10G NIC driver
2) vi->big_packet in guest is false
3) MTU is 1500.
4) raw socket, not the tap
5) using your vhost git tree

Is that the reasonable result with such conditions or maybe I have made som=
e silly mistakes somewhere I don't know yet?
May you kindly describe your test environment/conditions in detail to have =
much better performance in your website (I really need the performance)?

And I have tested the tun support with vhost now, and may you share your /h=
ome/mst/ifup script here?

Thanks
Xiaohui


-----Original Message-----
From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On Behal=
f Of Michael S. Tsirkin
Sent: Tuesday, November 10, 2009 1:23 AM
To: netdev@vger.kernel.org; virtualization@lists.linux-foundation.org; kvm@=
vger.kernel.org; linux-kernel@vger.kernel.org; mingo@elte.hu; linux-mm@kvac=
k.org; akpm@linux-foundation.org; hpa@zytor.com; gregory.haskins@gmail.com;=
 Rusty Russell; s.hetze@linux-ag.com; Daniel Walker; Eric Dumazet
Subject: [PATCHv9 3/3] vhost_net: a kernel-level virtio server

What it is: vhost net is a character device that can be used to reduce
the number of system calls involved in virtio networking.
Existing virtio net code is used in the guest without modification.

There's similarity with vringfd, with some differences and reduced scope
- uses eventfd for signalling
- structures can be moved around in memory at any time (good for
  migration, bug work-arounds in userspace)
- write logging is supported (good for migration)
- support memory table and not just an offset (needed for kvm)

common virtio related code has been put in a separate file vhost.c and
can be made into a separate module if/when more backends appear.  I used
Rusty's lguest.c as the source for developing this part : this supplied
me with witty comments I wouldn't be able to write myself.

What it is not: vhost net is not a bus, and not a generic new system
call. No assumptions are made on how guest performs hypercalls.
Userspace hypervisors are supported as well as kvm.

How it works: Basically, we connect virtio frontend (configured by
userspace) to a backend. The backend could be a network device, or a tap
device.  Backend is also configured by userspace, including vlan/mac
etc.

Status: This works for me, and I haven't see any crashes.
Compared to userspace, people reported improved latency (as I save up to
4 system calls per packet), as well as better bandwidth and CPU
utilization.

Features that I plan to look at in the future:
- mergeable buffers
- zero copy
- scalability tuning: figure out the best threading model to use

Note on RCU usage (this is also documented in vhost.h, near
private_pointer which is the value protected by this variant of RCU):
what is happening is that the rcu_dereference() is being used in a
workqueue item.  The role of rcu_read_lock() is taken on by the start of
execution of the workqueue item, of rcu_read_unlock() by the end of
execution of the workqueue item, and of synchronize_rcu() by
flush_workqueue()/flush_work(). In the future we might need to apply
some gcc attribute or sparse annotation to the function passed to
INIT_WORK(). Paul's ack below is for this RCU usage.

Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 MAINTAINERS                |    9 +
 arch/x86/kvm/Kconfig       |    1 +
 drivers/Makefile           |    1 +
 drivers/vhost/Kconfig      |   11 +
 drivers/vhost/Makefile     |    2 +
 drivers/vhost/net.c        |  648 +++++++++++++++++++++++++++++
 drivers/vhost/vhost.c      |  965 ++++++++++++++++++++++++++++++++++++++++=
++++
 drivers/vhost/vhost.h      |  159 ++++++++
 include/linux/Kbuild       |    1 +
 include/linux/miscdevice.h |    1 +
 include/linux/vhost.h      |  130 ++++++
 11 files changed, 1928 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vhost/Kconfig
 create mode 100644 drivers/vhost/Makefile
 create mode 100644 drivers/vhost/net.c
 create mode 100644 drivers/vhost/vhost.c
 create mode 100644 drivers/vhost/vhost.h
 create mode 100644 include/linux/vhost.h

diff --git a/MAINTAINERS b/MAINTAINERS
index a1a2ace..7d4bfa2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5636,6 +5636,15 @@ S:       Maintained
 F:     Documentation/filesystems/vfat.txt
 F:     fs/fat/

+VIRTIO HOST (VHOST)
+M:     "Michael S. Tsirkin" <mst@redhat.com>
+L:     kvm@vger.kernel.org
+L:     virtualization@lists.osdl.org
+L:     netdev@vger.kernel.org
+S:     Maintained
+F:     drivers/vhost/
+F:     include/linux/vhost.h
+
 VIA RHINE NETWORK DRIVER
 M:     Roger Luethi <rl@hellgate.ch>
 S:     Maintained
diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index b84e571..94f44d9 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -64,6 +64,7 @@ config KVM_AMD

 # OK, it's a little counter-intuitive to do this, but it puts it neatly un=
der
 # the virtualization menu.
+source drivers/vhost/Kconfig
 source drivers/lguest/Kconfig
 source drivers/virtio/Kconfig

diff --git a/drivers/Makefile b/drivers/Makefile
index 6ee53c7..81e3659 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -106,6 +106,7 @@ obj-$(CONFIG_HID)           +=3D hid/
 obj-$(CONFIG_PPC_PS3)          +=3D ps3/
 obj-$(CONFIG_OF)               +=3D of/
 obj-$(CONFIG_SSB)              +=3D ssb/
+obj-$(CONFIG_VHOST_NET)                +=3D vhost/
 obj-$(CONFIG_VIRTIO)           +=3D virtio/
 obj-$(CONFIG_VLYNQ)            +=3D vlynq/
 obj-$(CONFIG_STAGING)          +=3D staging/
diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
new file mode 100644
index 0000000..9f409f4
--- /dev/null
+++ b/drivers/vhost/Kconfig
@@ -0,0 +1,11 @@
+config VHOST_NET
+       tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
+       depends on NET && EVENTFD && EXPERIMENTAL
+       ---help---
+         This kernel module can be loaded in host kernel to accelerate
+         guest networking with virtio_net. Not to be confused with virtio_=
net
+         module itself which needs to be loaded in guest kernel.
+
+         To compile this driver as a module, choose M here: the module wil=
l
+         be called vhost_net.
+
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
new file mode 100644
index 0000000..72dd020
--- /dev/null
+++ b/drivers/vhost/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_VHOST_NET) +=3D vhost_net.o
+vhost_net-y :=3D vhost.o net.o
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
new file mode 100644
index 0000000..22d5fef
--- /dev/null
+++ b/drivers/vhost/net.c
@@ -0,0 +1,648 @@
+/* Copyright (C) 2009 Red Hat, Inc.
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ *
+ * virtio-net server in host kernel.
+ */
+
+#include <linux/compat.h>
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
+#include <linux/if_tun.h>
+
+#include <net/sock.h>
+
+#include "vhost.h"
+
+/* Max number of bytes transferred before requeueing the job.
+ * Using this limit prevents one virtqueue from starving others. */
+#define VHOST_NET_WEIGHT 0x80000
+
+enum {
+       VHOST_NET_VQ_RX =3D 0,
+       VHOST_NET_VQ_TX =3D 1,
+       VHOST_NET_VQ_MAX =3D 2,
+};
+
+enum vhost_net_poll_state {
+       VHOST_NET_POLL_DISABLED =3D 0,
+       VHOST_NET_POLL_STARTED =3D 1,
+       VHOST_NET_POLL_STOPPED =3D 2,
+};
+
+struct vhost_net {
+       struct vhost_dev dev;
+       struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
+       struct vhost_poll poll[VHOST_NET_VQ_MAX];
+       /* Tells us whether we are polling a socket for TX.
+        * We only do this when socket buffer fills up.
+        * Protected by tx vq lock. */
+       enum vhost_net_poll_state tx_poll_state;
+};
+
+/* Pop first len bytes from iovec. Return number of segments used. */
+static int move_iovec_hdr(struct iovec *from, struct iovec *to,
+                         size_t len, int iov_count)
+{
+       int seg =3D 0;
+       size_t size;
+       while (len && seg < iov_count) {
+               size =3D min(from->iov_len, len);
+               to->iov_base =3D from->iov_base;
+               to->iov_len =3D size;
+               from->iov_len -=3D size;
+               from->iov_base +=3D size;
+               len -=3D size;
+               ++from;
+               ++to;
+               ++seg;
+       }
+       return seg;
+}
+
+/* Caller must have TX VQ lock */
+static void tx_poll_stop(struct vhost_net *net)
+{
+       if (likely(net->tx_poll_state !=3D VHOST_NET_POLL_STARTED))
+               return;
+       vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
+       net->tx_poll_state =3D VHOST_NET_POLL_STOPPED;
+}
+
+/* Caller must have TX VQ lock */
+static void tx_poll_start(struct vhost_net *net, struct socket *sock)
+{
+       if (unlikely(net->tx_poll_state !=3D VHOST_NET_POLL_STOPPED))
+               return;
+       vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
+       net->tx_poll_state =3D VHOST_NET_POLL_STARTED;
+}
+
+/* Expects to be always run from workqueue - which acts as
+ * read-size critical section for our kind of RCU. */
+static void handle_tx(struct vhost_net *net)
+{
+       struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_TX];
+       unsigned head, out, in, s;
+       struct msghdr msg =3D {
+               .msg_name =3D NULL,
+               .msg_namelen =3D 0,
+               .msg_control =3D NULL,
+               .msg_controllen =3D 0,
+               .msg_iov =3D vq->iov,
+               .msg_flags =3D MSG_DONTWAIT,
+       };
+       size_t len, total_len =3D 0;
+       int err, wmem;
+       size_t hdr_size;
+       struct socket *sock =3D rcu_dereference(vq->private_data);
+       if (!sock)
+               return;
+
+       wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
+       if (wmem >=3D sock->sk->sk_sndbuf)
+               return;
+
+       use_mm(net->dev.mm);
+       mutex_lock(&vq->mutex);
+       vhost_disable_notify(vq);
+
+       if (wmem < sock->sk->sk_sndbuf * 2)
+               tx_poll_stop(net);
+       hdr_size =3D vq->hdr_size;
+
+       for (;;) {
+               head =3D vhost_get_vq_desc(&net->dev, vq, vq->iov,
+                                        ARRAY_SIZE(vq->iov),
+                                        &out, &in,
+                                        NULL, NULL);
+               /* Nothing new?  Wait for eventfd to tell us they refilled.=
 */
+               if (head =3D=3D vq->num) {
+                       wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
+                       if (wmem >=3D sock->sk->sk_sndbuf * 3 / 4) {
+                               tx_poll_start(net, sock);
+                               set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+                               break;
+                       }
+                       if (unlikely(vhost_enable_notify(vq))) {
+                               vhost_disable_notify(vq);
+                               continue;
+                       }
+                       break;
+               }
+               if (in) {
+                       vq_err(vq, "Unexpected descriptor format for TX: "
+                              "out %d, int %d\n", out, in);
+                       break;
+               }
+               /* Skip header. TODO: support TSO. */
+               s =3D move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
+               msg.msg_iovlen =3D out;
+               len =3D iov_length(vq->iov, out);
+               /* Sanity check */
+               if (!len) {
+                       vq_err(vq, "Unexpected header len for TX: "
+                              "%zd expected %zd\n",
+                              iov_length(vq->hdr, s), hdr_size);
+                       break;
+               }
+               /* TODO: Check specific error and bomb out unless ENOBUFS? =
*/
+               err =3D sock->ops->sendmsg(NULL, sock, &msg, len);
+               if (unlikely(err < 0)) {
+                       vhost_discard_vq_desc(vq);
+                       tx_poll_start(net, sock);
+                       break;
+               }
+               if (err !=3D len)
+                       pr_err("Truncated TX packet: "
+                              " len %d !=3D %zd\n", err, len);
+               vhost_add_used_and_signal(&net->dev, vq, head, 0);
+               total_len +=3D len;
+               if (unlikely(total_len >=3D VHOST_NET_WEIGHT)) {
+                       vhost_poll_queue(&vq->poll);
+                       break;
+               }
+       }
+
+       mutex_unlock(&vq->mutex);
+       unuse_mm(net->dev.mm);
+}
+
+/* Expects to be always run from workqueue - which acts as
+ * read-size critical section for our kind of RCU. */
+static void handle_rx(struct vhost_net *net)
+{
+       struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_RX];
+       unsigned head, out, in, log, s;
+       struct vhost_log *vq_log;
+       struct msghdr msg =3D {
+               .msg_name =3D NULL,
+               .msg_namelen =3D 0,
+               .msg_control =3D NULL, /* FIXME: get and handle RX aux data=
. */
+               .msg_controllen =3D 0,
+               .msg_iov =3D vq->iov,
+               .msg_flags =3D MSG_DONTWAIT,
+       };
+
+       struct virtio_net_hdr hdr =3D {
+               .flags =3D 0,
+               .gso_type =3D VIRTIO_NET_HDR_GSO_NONE
+       };
+
+       size_t len, total_len =3D 0;
+       int err;
+       size_t hdr_size;
+       struct socket *sock =3D rcu_dereference(vq->private_data);
+       if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+               return;
+
+       use_mm(net->dev.mm);
+       mutex_lock(&vq->mutex);
+       vhost_disable_notify(vq);
+       hdr_size =3D vq->hdr_size;
+
+       vq_log =3D unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) =
?
+               vq->log : NULL;
+
+       for (;;) {
+               head =3D vhost_get_vq_desc(&net->dev, vq, vq->iov,
+                                        ARRAY_SIZE(vq->iov),
+                                        &out, &in,
+                                        vq_log, &log);
+               /* OK, now we need to know about added descriptors. */
+               if (head =3D=3D vq->num) {
+                       if (unlikely(vhost_enable_notify(vq))) {
+                               /* They have slipped one in as we were
+                                * doing that: check again. */
+                               vhost_disable_notify(vq);
+                               continue;
+                       }
+                       /* Nothing new?  Wait for eventfd to tell us
+                        * they refilled. */
+                       break;
+               }
+               /* We don't need to be notified again. */
+               if (out) {
+                       vq_err(vq, "Unexpected descriptor format for RX: "
+                              "out %d, int %d\n",
+                              out, in);
+                       break;
+               }
+               /* Skip header. TODO: support TSO/mergeable rx buffers. */
+               s =3D move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
+               msg.msg_iovlen =3D in;
+               len =3D iov_length(vq->iov, in);
+               /* Sanity check */
+               if (!len) {
+                       vq_err(vq, "Unexpected header len for RX: "
+                              "%zd expected %zd\n",
+                              iov_length(vq->hdr, s), hdr_size);
+                       break;
+               }
+               err =3D sock->ops->recvmsg(NULL, sock, &msg,
+                                        len, MSG_DONTWAIT | MSG_TRUNC);
+               /* TODO: Check specific error and bomb out unless EAGAIN? *=
/
+               if (err < 0) {
+                       vhost_discard_vq_desc(vq);
+                       break;
+               }
+               /* TODO: Should check and handle checksum. */
+               if (err > len) {
+                       pr_err("Discarded truncated rx packet: "
+                              " len %d > %zd\n", err, len);
+                       vhost_discard_vq_desc(vq);
+                       continue;
+               }
+               len =3D err;
+               err =3D memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_=
size);
+               if (err) {
+                       vq_err(vq, "Unable to write vnet_hdr at addr %p: %d=
\n",
+                              vq->iov->iov_base, err);
+                       break;
+               }
+               len +=3D hdr_size;
+               vhost_add_used_and_signal(&net->dev, vq, head, len);
+               if (unlikely(vq_log))
+                       vhost_log_write(vq, vq_log, log, len);
+               total_len +=3D len;
+               if (unlikely(total_len >=3D VHOST_NET_WEIGHT)) {
+                       vhost_poll_queue(&vq->poll);
+                       break;
+               }
+       }
+
+       mutex_unlock(&vq->mutex);
+       unuse_mm(net->dev.mm);
+}
+
+static void handle_tx_kick(struct work_struct *work)
+{
+       struct vhost_virtqueue *vq;
+       struct vhost_net *net;
+       vq =3D container_of(work, struct vhost_virtqueue, poll.work);
+       net =3D container_of(vq->dev, struct vhost_net, dev);
+       handle_tx(net);
+}
+
+static void handle_rx_kick(struct work_struct *work)
+{
+       struct vhost_virtqueue *vq;
+       struct vhost_net *net;
+       vq =3D container_of(work, struct vhost_virtqueue, poll.work);
+       net =3D container_of(vq->dev, struct vhost_net, dev);
+       handle_rx(net);
+}
+
+static void handle_tx_net(struct work_struct *work)
+{
+       struct vhost_net *net;
+       net =3D container_of(work, struct vhost_net, poll[VHOST_NET_VQ_TX].=
work);
+       handle_tx(net);
+}
+
+static void handle_rx_net(struct work_struct *work)
+{
+       struct vhost_net *net;
+       net =3D container_of(work, struct vhost_net, poll[VHOST_NET_VQ_RX].=
work);
+       handle_rx(net);
+}
+
+static int vhost_net_open(struct inode *inode, struct file *f)
+{
+       struct vhost_net *n =3D kmalloc(sizeof *n, GFP_KERNEL);
+       int r;
+       if (!n)
+               return -ENOMEM;
+       f->private_data =3D n;
+       n->vqs[VHOST_NET_VQ_TX].handle_kick =3D handle_tx_kick;
+       n->vqs[VHOST_NET_VQ_RX].handle_kick =3D handle_rx_kick;
+       r =3D vhost_dev_init(&n->dev, n->vqs, VHOST_NET_VQ_MAX);
+       if (r < 0) {
+               kfree(n);
+               return r;
+       }
+
+       vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
+       vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
+       n->tx_poll_state =3D VHOST_NET_POLL_DISABLED;
+       return 0;
+}
+
+static void vhost_net_disable_vq(struct vhost_net *n,
+                                struct vhost_virtqueue *vq)
+{
+       if (!vq->private_data)
+               return;
+       if (vq =3D=3D n->vqs + VHOST_NET_VQ_TX) {
+               tx_poll_stop(n);
+               n->tx_poll_state =3D VHOST_NET_POLL_DISABLED;
+       } else
+               vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
+}
+
+static void vhost_net_enable_vq(struct vhost_net *n,
+                               struct vhost_virtqueue *vq)
+{
+       struct socket *sock =3D vq->private_data;
+       if (!sock)
+               return;
+       if (vq =3D=3D n->vqs + VHOST_NET_VQ_TX) {
+               n->tx_poll_state =3D VHOST_NET_POLL_STOPPED;
+               tx_poll_start(n, sock);
+       } else
+               vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
+}
+
+static struct socket *vhost_net_stop_vq(struct vhost_net *n,
+                                       struct vhost_virtqueue *vq)
+{
+       struct socket *sock;
+
+       mutex_lock(&vq->mutex);
+       sock =3D vq->private_data;
+       vhost_net_disable_vq(n, vq);
+       rcu_assign_pointer(vq->private_data, NULL);
+       mutex_unlock(&vq->mutex);
+       return sock;
+}
+
+static void vhost_net_stop(struct vhost_net *n, struct socket **tx_sock,
+                          struct socket **rx_sock)
+{
+       *tx_sock =3D vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_TX);
+       *rx_sock =3D vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_RX);
+}
+
+static void vhost_net_flush_vq(struct vhost_net *n, int index)
+{
+       vhost_poll_flush(n->poll + index);
+       vhost_poll_flush(&n->dev.vqs[index].poll);
+}
+
+static void vhost_net_flush(struct vhost_net *n)
+{
+       vhost_net_flush_vq(n, VHOST_NET_VQ_TX);
+       vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
+}
+
+static int vhost_net_release(struct inode *inode, struct file *f)
+{
+       struct vhost_net *n =3D f->private_data;
+       struct socket *tx_sock;
+       struct socket *rx_sock;
+
+       vhost_net_stop(n, &tx_sock, &rx_sock);
+       vhost_net_flush(n);
+       vhost_dev_cleanup(&n->dev);
+       if (tx_sock)
+               fput(tx_sock->file);
+       if (rx_sock)
+               fput(rx_sock->file);
+       /* We do an extra flush before freeing memory,
+        * since jobs can re-queue themselves. */
+       vhost_net_flush(n);
+       kfree(n);
+       return 0;
+}
+
+static struct socket *get_raw_socket(int fd)
+{
+       struct {
+               struct sockaddr_ll sa;
+               char  buf[MAX_ADDR_LEN];
+       } uaddr;
+       int uaddr_len =3D sizeof uaddr, r;
+       struct socket *sock =3D sockfd_lookup(fd, &r);
+       if (!sock)
+               return ERR_PTR(-ENOTSOCK);
+
+       /* Parameter checking */
+       if (sock->sk->sk_type !=3D SOCK_RAW) {
+               r =3D -ESOCKTNOSUPPORT;
+               goto err;
+       }
+
+       r =3D sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
+                              &uaddr_len, 0);
+       if (r)
+               goto err;
+
+       if (uaddr.sa.sll_family !=3D AF_PACKET) {
+               r =3D -EPFNOSUPPORT;
+               goto err;
+       }
+       return sock;
+err:
+       fput(sock->file);
+       return ERR_PTR(r);
+}
+
+static struct socket *get_tun_socket(int fd)
+{
+       struct file *file =3D fget(fd);
+       struct socket *sock;
+       if (!file)
+               return ERR_PTR(-EBADF);
+       sock =3D tun_get_socket(file);
+       if (IS_ERR(sock))
+               fput(file);
+       return sock;
+}
+
+static struct socket *get_socket(int fd)
+{
+       struct socket *sock;
+       if (fd =3D=3D -1)
+               return NULL;
+       sock =3D get_raw_socket(fd);
+       if (!IS_ERR(sock))
+               return sock;
+       sock =3D get_tun_socket(fd);
+       if (!IS_ERR(sock))
+               return sock;
+       return ERR_PTR(-ENOTSOCK);
+}
+
+static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int=
 fd)
+{
+       struct socket *sock, *oldsock;
+       struct vhost_virtqueue *vq;
+       int r;
+
+       mutex_lock(&n->dev.mutex);
+       r =3D vhost_dev_check_owner(&n->dev);
+       if (r)
+               goto err;
+
+       if (index >=3D VHOST_NET_VQ_MAX) {
+               r =3D -ENOBUFS;
+               goto err;
+       }
+       vq =3D n->vqs + index;
+       mutex_lock(&vq->mutex);
+       sock =3D get_socket(fd);
+       if (IS_ERR(sock)) {
+               r =3D PTR_ERR(sock);
+               goto err;
+       }
+
+       /* start polling new socket */
+       oldsock =3D vq->private_data;
+       if (sock =3D=3D oldsock)
+               goto done;
+
+       vhost_net_disable_vq(n, vq);
+       rcu_assign_pointer(vq->private_data, sock);
+       vhost_net_enable_vq(n, vq);
+       mutex_unlock(&vq->mutex);
+done:
+       mutex_unlock(&n->dev.mutex);
+       if (oldsock) {
+               vhost_net_flush_vq(n, index);
+               fput(oldsock->file);
+       }
+       return r;
+err:
+       mutex_unlock(&n->dev.mutex);
+       return r;
+}
+
+static long vhost_net_reset_owner(struct vhost_net *n)
+{
+       struct socket *tx_sock =3D NULL;
+       struct socket *rx_sock =3D NULL;
+       long err;
+       mutex_lock(&n->dev.mutex);
+       err =3D vhost_dev_check_owner(&n->dev);
+       if (err)
+               goto done;
+       vhost_net_stop(n, &tx_sock, &rx_sock);
+       vhost_net_flush(n);
+       err =3D vhost_dev_reset_owner(&n->dev);
+done:
+       mutex_unlock(&n->dev.mutex);
+       if (tx_sock)
+               fput(tx_sock->file);
+       if (rx_sock)
+               fput(rx_sock->file);
+       return err;
+}
+
+static void vhost_net_set_features(struct vhost_net *n, u64 features)
+{
+       size_t hdr_size =3D features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
+               sizeof(struct virtio_net_hdr) : 0;
+       int i;
+       mutex_lock(&n->dev.mutex);
+       n->dev.acked_features =3D features;
+       smp_wmb();
+       for (i =3D 0; i < VHOST_NET_VQ_MAX; ++i) {
+               mutex_lock(&n->vqs[i].mutex);
+               n->vqs[i].hdr_size =3D hdr_size;
+               mutex_unlock(&n->vqs[i].mutex);
+       }
+       mutex_unlock(&n->dev.mutex);
+       vhost_net_flush(n);
+}
+
+static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
+                           unsigned long arg)
+{
+       struct vhost_net *n =3D f->private_data;
+       void __user *argp =3D (void __user *)arg;
+       u32 __user *featurep =3D argp;
+       struct vhost_vring_file backend;
+       u64 features;
+       int r;
+       switch (ioctl) {
+       case VHOST_NET_SET_BACKEND:
+               r =3D copy_from_user(&backend, argp, sizeof backend);
+               if (r < 0)
+                       return r;
+               return vhost_net_set_backend(n, backend.index, backend.fd);
+       case VHOST_GET_FEATURES:
+               features =3D VHOST_FEATURES;
+               return put_user(features, featurep);
+       case VHOST_SET_FEATURES:
+               r =3D get_user(features, featurep);
+               /* No features for now */
+               if (r < 0)
+                       return r;
+               if (features & ~VHOST_FEATURES)
+                       return -EOPNOTSUPP;
+               vhost_net_set_features(n, features);
+               return 0;
+       case VHOST_RESET_OWNER:
+               return vhost_net_reset_owner(n);
+       default:
+               r =3D vhost_dev_ioctl(&n->dev, ioctl, arg);
+               vhost_net_flush(n);
+               return r;
+       }
+}
+
+#ifdef CONFIG_COMPAT
+static long vhost_net_compat_ioctl(struct file *f, unsigned int ioctl,
+                                  unsigned long arg)
+{
+       return vhost_net_ioctl(f, ioctl, (unsigned long)compat_ptr(arg));
+}
+#endif
+
+const static struct file_operations vhost_net_fops =3D {
+       .owner          =3D THIS_MODULE,
+       .release        =3D vhost_net_release,
+       .unlocked_ioctl =3D vhost_net_ioctl,
+#ifdef CONFIG_COMPAT
+       .compat_ioctl   =3D vhost_net_compat_ioctl,
+#endif
+       .open           =3D vhost_net_open,
+};
+
+static struct miscdevice vhost_net_misc =3D {
+       VHOST_NET_MINOR,
+       "vhost-net",
+       &vhost_net_fops,
+};
+
+int vhost_net_init(void)
+{
+       int r =3D vhost_init();
+       if (r)
+               goto err_init;
+       r =3D misc_register(&vhost_net_misc);
+       if (r)
+               goto err_reg;
+       return 0;
+err_reg:
+       vhost_cleanup();
+err_init:
+       return r;
+
+}
+module_init(vhost_net_init);
+
+void vhost_net_exit(void)
+{
+       misc_deregister(&vhost_net_misc);
+       vhost_cleanup();
+}
+module_exit(vhost_net_exit);
+
+MODULE_VERSION("0.0.1");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Michael S. Tsirkin");
+MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
new file mode 100644
index 0000000..97233d5
--- /dev/null
+++ b/drivers/vhost/vhost.c
@@ -0,0 +1,965 @@
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
+#include <linux/highmem.h>
+
+#include <linux/net.h>
+#include <linux/if_packet.h>
+#include <linux/if_arp.h>
+
+#include <net/sock.h>
+
+#include "vhost.h"
+
+enum {
+       VHOST_MEMORY_MAX_NREGIONS =3D 64,
+       VHOST_MEMORY_F_LOG =3D 0x1,
+};
+
+static struct workqueue_struct *vhost_workqueue;
+
+static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
+                           poll_table *pt)
+{
+       struct vhost_poll *poll;
+       poll =3D container_of(pt, struct vhost_poll, table);
+
+       poll->wqh =3D wqh;
+       add_wait_queue(wqh, &poll->wait);
+}
+
+static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
+                            void *key)
+{
+       struct vhost_poll *poll;
+       poll =3D container_of(wait, struct vhost_poll, wait);
+       if (!((unsigned long)key & poll->mask))
+               return 0;
+
+       queue_work(vhost_workqueue, &poll->work);
+       return 0;
+}
+
+/* Init poll structure */
+void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
+                    unsigned long mask)
+{
+       INIT_WORK(&poll->work, func);
+       init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
+       init_poll_funcptr(&poll->table, vhost_poll_func);
+       poll->mask =3D mask;
+}
+
+/* Start polling a file. We add ourselves to file's wait queue. The caller=
 must
+ * keep a reference to a file until after vhost_poll_stop is called. */
+void vhost_poll_start(struct vhost_poll *poll, struct file *file)
+{
+       unsigned long mask;
+       mask =3D file->f_op->poll(file, &poll->table);
+       if (mask)
+               vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
+}
+
+/* Stop polling a file. After this function returns, it becomes safe to dr=
op the
+ * file reference. You must also flush afterwards. */
+void vhost_poll_stop(struct vhost_poll *poll)
+{
+       remove_wait_queue(poll->wqh, &poll->wait);
+}
+
+/* Flush any work that has been scheduled. When calling this, don't hold a=
ny
+ * locks that are also used by the callback. */
+void vhost_poll_flush(struct vhost_poll *poll)
+{
+       flush_work(&poll->work);
+}
+
+void vhost_poll_queue(struct vhost_poll *poll)
+{
+       queue_work(vhost_workqueue, &poll->work);
+}
+
+static void vhost_vq_reset(struct vhost_dev *dev,
+                          struct vhost_virtqueue *vq)
+{
+       vq->num =3D 1;
+       vq->desc =3D NULL;
+       vq->avail =3D NULL;
+       vq->used =3D NULL;
+       vq->last_avail_idx =3D 0;
+       vq->avail_idx =3D 0;
+       vq->last_used_idx =3D 0;
+       vq->used_flags =3D 0;
+       vq->used_flags =3D 0;
+       vq->log_used =3D false;
+       vq->log_addr =3D -1ull;
+       vq->hdr_size =3D 0;
+       vq->private_data =3D NULL;
+       vq->log_base =3D NULL;
+       vq->error_ctx =3D NULL;
+       vq->error =3D NULL;
+       vq->kick =3D NULL;
+       vq->call_ctx =3D NULL;
+       vq->call =3D NULL;
+}
+
+long vhost_dev_init(struct vhost_dev *dev,
+                   struct vhost_virtqueue *vqs, int nvqs)
+{
+       int i;
+       dev->vqs =3D vqs;
+       dev->nvqs =3D nvqs;
+       mutex_init(&dev->mutex);
+       dev->log_ctx =3D NULL;
+       dev->log_file =3D NULL;
+       dev->memory =3D NULL;
+       dev->mm =3D NULL;
+
+       for (i =3D 0; i < dev->nvqs; ++i) {
+               dev->vqs[i].dev =3D dev;
+               mutex_init(&dev->vqs[i].mutex);
+               vhost_vq_reset(dev, dev->vqs + i);
+               if (dev->vqs[i].handle_kick)
+                       vhost_poll_init(&dev->vqs[i].poll,
+                                       dev->vqs[i].handle_kick,
+                                       POLLIN);
+       }
+       return 0;
+}
+
+/* Caller should have device mutex */
+long vhost_dev_check_owner(struct vhost_dev *dev)
+{
+       /* Are you the owner? If not, I don't think you mean to do that */
+       return dev->mm =3D=3D current->mm ? 0 : -EPERM;
+}
+
+/* Caller should have device mutex */
+static long vhost_dev_set_owner(struct vhost_dev *dev)
+{
+       /* Is there an owner already? */
+       if (dev->mm)
+               return -EBUSY;
+       /* No owner, become one */
+       dev->mm =3D get_task_mm(current);
+       return 0;
+}
+
+/* Caller should have device mutex */
+long vhost_dev_reset_owner(struct vhost_dev *dev)
+{
+       struct vhost_memory *memory;
+
+       /* Restore memory to default 1:1 mapping. */
+       memory =3D kmalloc(offsetof(struct vhost_memory, regions) +
+                        2 * sizeof *memory->regions, GFP_KERNEL);
+       if (!memory)
+               return -ENOMEM;
+
+       vhost_dev_cleanup(dev);
+
+       memory->nregions =3D 2;
+       memory->regions[0].guest_phys_addr =3D 1;
+       memory->regions[0].userspace_addr =3D 1;
+       memory->regions[0].memory_size =3D ~0ULL;
+       memory->regions[1].guest_phys_addr =3D 0;
+       memory->regions[1].userspace_addr =3D 0;
+       memory->regions[1].memory_size =3D 1;
+       dev->memory =3D memory;
+       return 0;
+}
+
+/* Caller should have device mutex */
+void vhost_dev_cleanup(struct vhost_dev *dev)
+{
+       int i;
+       for (i =3D 0; i < dev->nvqs; ++i) {
+               if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
+                       vhost_poll_stop(&dev->vqs[i].poll);
+                       vhost_poll_flush(&dev->vqs[i].poll);
+               }
+               if (dev->vqs[i].error_ctx)
+                       eventfd_ctx_put(dev->vqs[i].error_ctx);
+               if (dev->vqs[i].error)
+                       fput(dev->vqs[i].error);
+               if (dev->vqs[i].kick)
+                       fput(dev->vqs[i].kick);
+               if (dev->vqs[i].call_ctx)
+                       eventfd_ctx_put(dev->vqs[i].call_ctx);
+               if (dev->vqs[i].call)
+                       fput(dev->vqs[i].call);
+               vhost_vq_reset(dev, dev->vqs + i);
+       }
+       if (dev->log_ctx)
+               eventfd_ctx_put(dev->log_ctx);
+       dev->log_ctx =3D NULL;
+       if (dev->log_file)
+               fput(dev->log_file);
+       dev->log_file =3D NULL;
+       /* No one will access memory at this point */
+       kfree(dev->memory);
+       dev->memory =3D NULL;
+       if (dev->mm)
+               mmput(dev->mm);
+       dev->mm =3D NULL;
+}
+
+static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __us=
er *m)
+{
+       struct vhost_memory mem, *newmem, *oldmem;
+       unsigned long size =3D offsetof(struct vhost_memory, regions);
+       long r;
+       r =3D copy_from_user(&mem, m, size);
+       if (r)
+               return r;
+       if (mem.padding)
+               return -EOPNOTSUPP;
+       if (mem.nregions > VHOST_MEMORY_MAX_NREGIONS)
+               return -E2BIG;
+       newmem =3D kmalloc(size + mem.nregions * sizeof *m->regions, GFP_KE=
RNEL);
+       if (!newmem)
+               return -ENOMEM;
+
+       memcpy(newmem, &mem, size);
+       r =3D copy_from_user(newmem->regions, m->regions,
+                          mem.nregions * sizeof *m->regions);
+       if (r) {
+               kfree(newmem);
+               return r;
+       }
+       oldmem =3D d->memory;
+       rcu_assign_pointer(d->memory, newmem);
+       synchronize_rcu();
+       kfree(oldmem);
+       return 0;
+}
+
+static int init_used(struct vhost_virtqueue *vq,
+                    struct vring_used __user *used)
+{
+       int r =3D put_user(vq->used_flags, &used->flags);
+       if (r)
+               return r;
+       return get_user(vq->last_used_idx, &used->idx);
+}
+
+static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *a=
rgp)
+{
+       struct file *eventfp, *filep =3D NULL,
+                   *pollstart =3D NULL, *pollstop =3D NULL;
+       struct eventfd_ctx *ctx =3D NULL;
+       u32 __user *idxp =3D argp;
+       struct vhost_virtqueue *vq;
+       struct vhost_vring_state s;
+       struct vhost_vring_file f;
+       struct vhost_vring_addr a;
+       u32 idx;
+       long r;
+
+       r =3D get_user(idx, idxp);
+       if (r < 0)
+               return r;
+       if (idx > d->nvqs)
+               return -ENOBUFS;
+
+       vq =3D d->vqs + idx;
+
+       mutex_lock(&vq->mutex);
+
+       switch (ioctl) {
+       case VHOST_SET_VRING_NUM:
+               r =3D copy_from_user(&s, argp, sizeof s);
+               if (r < 0)
+                       break;
+               if (!s.num || s.num > 0xffff || (s.num & (s.num - 1))) {
+                       r =3D -EINVAL;
+                       break;
+               }
+               vq->num =3D s.num;
+               break;
+       case VHOST_SET_VRING_BASE:
+               r =3D copy_from_user(&s, argp, sizeof s);
+               if (r < 0)
+                       break;
+               if (s.num > 0xffff) {
+                       r =3D -EINVAL;
+                       break;
+               }
+               vq->last_avail_idx =3D s.num;
+               /* Forget the cached index value. */
+               vq->avail_idx =3D vq->last_avail_idx;
+               break;
+       case VHOST_GET_VRING_BASE:
+               s.index =3D idx;
+               s.num =3D vq->last_avail_idx;
+               r =3D copy_to_user(argp, &s, sizeof s);
+               break;
+       case VHOST_SET_VRING_ADDR:
+               r =3D copy_from_user(&a, argp, sizeof a);
+               if (r < 0)
+                       break;
+               if (a.flags & ~(0x1 << VHOST_VRING_F_LOG)) {
+                       r =3D -EOPNOTSUPP;
+                       break;
+               }
+               if ((u64)(unsigned long)a.desc_user_addr !=3D a.desc_user_a=
ddr ||
+                   (u64)(unsigned long)a.used_user_addr !=3D a.used_user_a=
ddr ||
+                   (u64)(unsigned long)a.avail_user_addr !=3D a.avail_user=
_addr) {
+                       r =3D -EFAULT;
+                       break;
+               }
+               if ((a.avail_user_addr & (sizeof *vq->avail->ring - 1)) ||
+                   (a.used_user_addr & (sizeof *vq->used->ring - 1)) ||
+                   (a.log_guest_addr & (sizeof *vq->used->ring - 1))) {
+                       r =3D -EINVAL;
+                       break;
+               }
+               r =3D init_used(vq, (struct vring_used __user *)a.used_user=
_addr);
+               if (r)
+                       break;
+               vq->log_used =3D !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
+               vq->desc =3D (void __user *)(unsigned long)a.desc_user_addr=
;
+               vq->avail =3D (void __user *)(unsigned long)a.avail_user_ad=
dr;
+               vq->log_addr =3D a.log_guest_addr;
+               vq->used =3D (void __user *)(unsigned long)a.used_user_addr=
;
+               break;
+       case VHOST_SET_VRING_KICK:
+               r =3D copy_from_user(&f, argp, sizeof f);
+               if (r < 0)
+                       break;
+               eventfp =3D f.fd =3D=3D -1 ? NULL : eventfd_fget(f.fd);
+               if (IS_ERR(eventfp))
+                       return PTR_ERR(eventfp);
+               if (eventfp !=3D vq->kick) {
+                       pollstop =3D filep =3D vq->kick;
+                       pollstart =3D vq->kick =3D eventfp;
+               } else
+                       filep =3D eventfp;
+               break;
+       case VHOST_SET_VRING_CALL:
+               r =3D copy_from_user(&f, argp, sizeof f);
+               if (r < 0)
+                       break;
+               eventfp =3D f.fd =3D=3D -1 ? NULL : eventfd_fget(f.fd);
+               if (IS_ERR(eventfp))
+                       return PTR_ERR(eventfp);
+               if (eventfp !=3D vq->call) {
+                       filep =3D vq->call;
+                       ctx =3D vq->call_ctx;
+                       vq->call =3D eventfp;
+                       vq->call_ctx =3D eventfp ?
+                               eventfd_ctx_fileget(eventfp) : NULL;
+               } else
+                       filep =3D eventfp;
+               break;
+       case VHOST_SET_VRING_ERR:
+               r =3D copy_from_user(&f, argp, sizeof f);
+               if (r < 0)
+                       break;
+               eventfp =3D f.fd =3D=3D -1 ? NULL : eventfd_fget(f.fd);
+               if (IS_ERR(eventfp))
+                       return PTR_ERR(eventfp);
+               if (eventfp !=3D vq->error) {
+                       filep =3D vq->error;
+                       vq->error =3D eventfp;
+                       ctx =3D vq->error_ctx;
+                       vq->error_ctx =3D eventfp ?
+                               eventfd_ctx_fileget(eventfp) : NULL;
+               } else
+                       filep =3D eventfp;
+               break;
+       default:
+               r =3D -ENOIOCTLCMD;
+       }
+
+       if (pollstop && vq->handle_kick)
+               vhost_poll_stop(&vq->poll);
+
+       if (ctx)
+               eventfd_ctx_put(ctx);
+       if (filep)
+               fput(filep);
+
+       if (pollstart && vq->handle_kick)
+               vhost_poll_start(&vq->poll, vq->kick);
+
+       mutex_unlock(&vq->mutex);
+
+       if (pollstop && vq->handle_kick)
+               vhost_poll_flush(&vq->poll);
+       return r;
+}
+
+long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned lon=
g arg)
+{
+       void __user *argp =3D (void __user *)arg;
+       struct file *eventfp, *filep =3D NULL;
+       struct eventfd_ctx *ctx =3D NULL;
+       u64 p;
+       long r;
+       int i, fd;
+
+       mutex_lock(&d->mutex);
+       /* If you are not the owner, you can become one */
+       if (ioctl =3D=3D VHOST_SET_OWNER) {
+               r =3D vhost_dev_set_owner(d);
+               goto done;
+       }
+
+       /* You must be the owner to do anything else */
+       r =3D vhost_dev_check_owner(d);
+       if (r)
+               goto done;
+
+       switch (ioctl) {
+       case VHOST_SET_MEM_TABLE:
+               r =3D vhost_set_memory(d, argp);
+               break;
+       case VHOST_SET_LOG_BASE:
+               r =3D copy_from_user(&p, argp, sizeof p);
+               if (r < 0)
+                       break;
+               if ((u64)(unsigned long)p !=3D p) {
+                       r =3D -EFAULT;
+                       break;
+               }
+               for (i =3D 0; i < d->nvqs; ++i) {
+                       mutex_lock(&d->vqs[i].mutex);
+                       d->vqs[i].log_base =3D (void __user *)(unsigned lon=
g)p;
+                       mutex_unlock(&d->vqs[i].mutex);
+               }
+               break;
+       case VHOST_SET_LOG_FD:
+               r =3D get_user(fd, (int __user *)argp);
+               if (r < 0)
+                       break;
+               eventfp =3D fd =3D=3D -1 ? NULL : eventfd_fget(fd);
+               if (IS_ERR(eventfp)) {
+                       r =3D PTR_ERR(eventfp);
+                       break;
+               }
+               if (eventfp !=3D d->log_file) {
+                       filep =3D d->log_file;
+                       ctx =3D d->log_ctx;
+                       d->log_ctx =3D eventfp ?
+                               eventfd_ctx_fileget(eventfp) : NULL;
+               } else
+                       filep =3D eventfp;
+               for (i =3D 0; i < d->nvqs; ++i) {
+                       mutex_lock(&d->vqs[i].mutex);
+                       d->vqs[i].log_ctx =3D d->log_ctx;
+                       mutex_unlock(&d->vqs[i].mutex);
+               }
+               if (ctx)
+                       eventfd_ctx_put(ctx);
+               if (filep)
+                       fput(filep);
+               break;
+       default:
+               r =3D vhost_set_vring(d, ioctl, argp);
+               break;
+       }
+done:
+       mutex_unlock(&d->mutex);
+       return r;
+}
+
+static const struct vhost_memory_region *find_region(struct vhost_memory *=
mem,
+                                                    __u64 addr, __u32 len)
+{
+       struct vhost_memory_region *reg;
+       int i;
+       /* linear search is not brilliant, but we really have on the order =
of 6
+        * regions in practice */
+       for (i =3D 0; i < mem->nregions; ++i) {
+               reg =3D mem->regions + i;
+               if (reg->guest_phys_addr <=3D addr &&
+                   reg->guest_phys_addr + reg->memory_size - 1 >=3D addr)
+                       return reg;
+       }
+       return NULL;
+}
+
+/* TODO: This is really inefficient.  We need something like get_user()
+ * (instruction directly accesses the data, with an exception table entry
+ * returning -EFAULT). See Documentation/x86/exception-tables.txt.
+ */
+static int set_bit_to_user(int nr, void __user *addr)
+{
+       unsigned long log =3D (unsigned long)addr;
+       struct page *page;
+       void *base;
+       int bit =3D nr + (log % PAGE_SIZE) * 8;
+       int r;
+       r =3D get_user_pages_fast(log, 1, 1, &page);
+       if (r)
+               return r;
+       base =3D kmap_atomic(page, KM_USER0);
+       set_bit(bit, base);
+       kunmap_atomic(base, KM_USER0);
+       set_page_dirty_lock(page);
+       put_page(page);
+       return 0;
+}
+
+static int log_write(void __user *log_base,
+                    u64 write_address, u64 write_length)
+{
+       int r;
+       if (!write_length)
+               return 0;
+       write_address /=3D VHOST_PAGE_SIZE;
+       for (;;) {
+               u64 base =3D (u64)(unsigned long)log_base;
+               u64 log =3D base + write_address / 8;
+               int bit =3D write_address % 8;
+               if ((u64)(unsigned long)log !=3D log)
+                       return -EFAULT;
+               r =3D set_bit_to_user(bit, (void __user *)(unsigned long)lo=
g);
+               if (r < 0)
+                       return r;
+               if (write_length <=3D VHOST_PAGE_SIZE)
+                       break;
+               write_length -=3D VHOST_PAGE_SIZE;
+               write_address +=3D VHOST_PAGE_SIZE;
+       }
+       return r;
+}
+
+int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
+                   unsigned int log_num, u64 len)
+{
+       int i, r;
+
+       /* Make sure data written is seen before log. */
+       wmb();
+       for (i =3D 0; i < log_num; ++i) {
+               u64 l =3D min(log[i].len, len);
+               r =3D log_write(vq->log_base, log[i].addr, l);
+               if (r < 0)
+                       return r;
+               len -=3D l;
+               if (!len)
+                       return 0;
+       }
+       if (vq->log_ctx)
+               eventfd_signal(vq->log_ctx, 1);
+       /* Length written exceeds what we have stored. This is a bug. */
+       BUG();
+       return 0;
+}
+
+int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
+                  struct iovec iov[], int iov_size)
+{
+       const struct vhost_memory_region *reg;
+       struct vhost_memory *mem;
+       struct iovec *_iov;
+       u64 s =3D 0;
+       int ret =3D 0;
+
+       rcu_read_lock();
+
+       mem =3D rcu_dereference(dev->memory);
+       while ((u64)len > s) {
+               u64 size;
+               if (ret >=3D iov_size) {
+                       ret =3D -ENOBUFS;
+                       break;
+               }
+               reg =3D find_region(mem, addr, len);
+               if (!reg) {
+                       ret =3D -EFAULT;
+                       break;
+               }
+               _iov =3D iov + ret;
+               size =3D reg->memory_size - addr + reg->guest_phys_addr;
+               _iov->iov_len =3D min((u64)len, size);
+               _iov->iov_base =3D (void *)(unsigned long)
+                       (reg->userspace_addr + addr - reg->guest_phys_addr)=
;
+               s +=3D size;
+               addr +=3D size;
+               ++ret;
+       }
+
+       rcu_read_unlock();
+       return ret;
+}
+
+/* Each buffer in the virtqueues is actually a chain of descriptors.  This
+ * function returns the next descriptor in the chain,
+ * or -1U if we're at the end. */
+static unsigned next_desc(struct vring_desc *desc)
+{
+       unsigned int next;
+
+       /* If this descriptor says it doesn't chain, we're done. */
+       if (!(desc->flags & VRING_DESC_F_NEXT))
+               return -1U;
+
+       /* Check they're not leading us off end of descriptors. */
+       next =3D desc->next;
+       /* Make sure compiler knows to grab that: we don't want it changing=
! */
+       /* We will use the result as an index in an array, so most
+        * architectures only need a compiler barrier here. */
+       read_barrier_depends();
+
+       return next;
+}
+
+static unsigned get_indirect(struct vhost_dev *dev, struct vhost_virtqueue=
 *vq,
+                            struct iovec iov[], unsigned int iov_size,
+                            unsigned int *out_num, unsigned int *in_num,
+                            struct vhost_log *log, unsigned int *log_num,
+                            struct vring_desc *indirect)
+{
+       struct vring_desc desc;
+       unsigned int i =3D 0, count, found =3D 0;
+       int ret;
+
+       /* Sanity check */
+       if (indirect->len % sizeof desc) {
+               vq_err(vq, "Invalid length in indirect descriptor: "
+                      "len 0x%llx not multiple of 0x%zx\n",
+                      (unsigned long long)indirect->len,
+                      sizeof desc);
+               return -EINVAL;
+       }
+
+       ret =3D translate_desc(dev, indirect->addr, indirect->len, vq->indi=
rect,
+                            ARRAY_SIZE(vq->indirect));
+       if (ret < 0) {
+               vq_err(vq, "Translation failure %d in indirect.\n", ret);
+               return ret;
+       }
+
+       /* We will use the result as an address to read from, so most
+        * architectures only need a compiler barrier here. */
+       read_barrier_depends();
+
+       count =3D indirect->len / sizeof desc;
+       /* Buffers are chained via a 16 bit next field, so
+        * we can have at most 2^16 of these. */
+       if (count > USHORT_MAX + 1) {
+               vq_err(vq, "Indirect buffer length too big: %d\n",
+                      indirect->len);
+               return -E2BIG;
+       }
+
+       do {
+               unsigned iov_count =3D *in_num + *out_num;
+               if (++found > count) {
+                       vq_err(vq, "Loop detected: last one at %u "
+                              "indirect size %u\n",
+                              i, count);
+                       return -EINVAL;
+               }
+               if (memcpy_fromiovec((unsigned char *)&desc, vq->indirect,
+                                    sizeof desc)) {
+                       vq_err(vq, "Failed indirect descriptor: idx %d, %zx=
\n",
+                              i, (size_t)indirect->addr + i * sizeof desc)=
;
+                       return -EINVAL;
+               }
+               if (desc.flags & VRING_DESC_F_INDIRECT) {
+                       vq_err(vq, "Nested indirect descriptor: idx %d, %zx=
\n",
+                              i, (size_t)indirect->addr + i * sizeof desc)=
;
+                       return -EINVAL;
+               }
+
+               ret =3D translate_desc(dev, desc.addr, desc.len, iov + iov_=
count,
+                                    iov_size - iov_count);
+               if (ret < 0) {
+                       vq_err(vq, "Translation failure %d indirect idx %d\=
n",
+                              ret, i);
+                       return ret;
+               }
+               /* If this is an input descriptor, increment that count. */
+               if (desc.flags & VRING_DESC_F_WRITE) {
+                       *in_num +=3D ret;
+                       if (unlikely(log)) {
+                               log[*log_num].addr =3D desc.addr;
+                               log[*log_num].len =3D desc.len;
+                               ++*log_num;
+                       }
+               } else {
+                       /* If it's an output descriptor, they're all suppos=
ed
+                        * to come before any input descriptors. */
+                       if (*in_num) {
+                               vq_err(vq, "Indirect descriptor "
+                                      "has out after in: idx %d\n", i);
+                               return -EINVAL;
+                       }
+                       *out_num +=3D ret;
+               }
+       } while ((i =3D next_desc(&desc)) !=3D -1);
+       return 0;
+}
+
+/* This looks in the virtqueue and for the first available buffer, and con=
verts
+ * it to an iovec for convenient access.  Since descriptors consist of som=
e
+ * number of output then some number of input descriptors, it's actually t=
wo
+ * iovecs, but we pack them into one and note how many of each there were.
+ *
+ * This function returns the descriptor number found, or vq->num (which
+ * is never a valid descriptor number) if none was found. */
+unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *=
vq,
+                          struct iovec iov[], unsigned int iov_size,
+                          unsigned int *out_num, unsigned int *in_num,
+                          struct vhost_log *log, unsigned int *log_num)
+{
+       struct vring_desc desc;
+       unsigned int i, head, found =3D 0;
+       u16 last_avail_idx;
+       int ret;
+
+       /* Check it isn't doing very strange things with descriptor numbers=
. */
+       last_avail_idx =3D vq->last_avail_idx;
+       if (get_user(vq->avail_idx, &vq->avail->idx)) {
+               vq_err(vq, "Failed to access avail idx at %p\n",
+                      &vq->avail->idx);
+               return vq->num;
+       }
+
+       if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
+               vq_err(vq, "Guest moved used index from %u to %u",
+                      last_avail_idx, vq->avail_idx);
+               return vq->num;
+       }
+
+       /* If there's nothing new since last we looked, return invalid. */
+       if (vq->avail_idx =3D=3D last_avail_idx)
+               return vq->num;
+
+       /* Only get avail ring entries after they have been exposed by gues=
t. */
+       rmb();
+
+       /* Grab the next descriptor number they're advertising, and increme=
nt
+        * the index we've seen. */
+       if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
+               vq_err(vq, "Failed to read head: idx %d address %p\n",
+                      last_avail_idx,
+                      &vq->avail->ring[last_avail_idx % vq->num]);
+               return vq->num;
+       }
+
+       /* If their number is silly, that's an error. */
+       if (head >=3D vq->num) {
+               vq_err(vq, "Guest says index %u > %u is available",
+                      head, vq->num);
+               return vq->num;
+       }
+
+       /* When we start there are none of either input nor output. */
+       *out_num =3D *in_num =3D 0;
+       if (unlikely(log))
+               *log_num =3D 0;
+
+       i =3D head;
+       do {
+               unsigned iov_count =3D *in_num + *out_num;
+               if (i >=3D vq->num) {
+                       vq_err(vq, "Desc index is %u > %u, head =3D %u",
+                              i, vq->num, head);
+                       return vq->num;
+               }
+               if (++found > vq->num) {
+                       vq_err(vq, "Loop detected: last one at %u "
+                              "vq size %u head %u\n",
+                              i, vq->num, head);
+                       return vq->num;
+               }
+               ret =3D copy_from_user(&desc, vq->desc + i, sizeof desc);
+               if (ret) {
+                       vq_err(vq, "Failed to get descriptor: idx %d addr %=
p\n",
+                              i, vq->desc + i);
+                       return vq->num;
+               }
+               if (desc.flags & VRING_DESC_F_INDIRECT) {
+                       ret =3D get_indirect(dev, vq, iov, iov_size,
+                                          out_num, in_num,
+                                          log, log_num, &desc);
+                       if (ret < 0) {
+                               vq_err(vq, "Failure detected "
+                                      "in indirect descriptor at idx %d\n"=
, i);
+                               return vq->num;
+                       }
+                       continue;
+               }
+
+               ret =3D translate_desc(dev, desc.addr, desc.len, iov + iov_=
count,
+                                    iov_size - iov_count);
+               if (ret < 0) {
+                       vq_err(vq, "Translation failure %d descriptor idx %=
d\n",
+                              ret, i);
+                       return vq->num;
+               }
+               if (desc.flags & VRING_DESC_F_WRITE) {
+                       /* If this is an input descriptor,
+                        * increment that count. */
+                       *in_num +=3D ret;
+                       if (unlikely(log)) {
+                               log[*log_num].addr =3D desc.addr;
+                               log[*log_num].len =3D desc.len;
+                               ++*log_num;
+                       }
+               } else {
+                       /* If it's an output descriptor, they're all suppos=
ed
+                        * to come before any input descriptors. */
+                       if (*in_num) {
+                               vq_err(vq, "Descriptor has out after in: "
+                                      "idx %d\n", i);
+                               return vq->num;
+                       }
+                       *out_num +=3D ret;
+               }
+       } while ((i =3D next_desc(&desc)) !=3D -1);
+
+       /* On success, increment avail index. */
+       vq->last_avail_idx++;
+       return head;
+}
+
+/* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
+void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
+{
+       vq->last_avail_idx--;
+}
+
+/* After we've used one of their buffers, we tell them about it.  We'll th=
en
+ * want to notify the guest, using eventfd. */
+int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
+{
+       struct vring_used_elem *used;
+
+       /* The virtqueue contains a ring of used buffers.  Get a pointer to=
 the
+        * next entry in that used ring. */
+       used =3D &vq->used->ring[vq->last_used_idx % vq->num];
+       if (put_user(head, &used->id)) {
+               vq_err(vq, "Failed to write used id");
+               return -EFAULT;
+       }
+       if (put_user(len, &used->len)) {
+               vq_err(vq, "Failed to write used len");
+               return -EFAULT;
+       }
+       /* Make sure buffer is written before we update index. */
+       wmb();
+       if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+               vq_err(vq, "Failed to increment used idx");
+               return -EFAULT;
+       }
+       if (unlikely(vq->log_used)) {
+               /* Make sure data is seen before log. */
+               wmb();
+               log_write(vq->log_base, vq->log_addr + sizeof *vq->used->ri=
ng *
+                         (vq->last_used_idx % vq->num),
+                         sizeof *vq->used->ring);
+               log_write(vq->log_base, vq->log_addr, sizeof *vq->used->rin=
g);
+               if (vq->log_ctx)
+                       eventfd_signal(vq->log_ctx, 1);
+       }
+       vq->last_used_idx++;
+       return 0;
+}
+
+/* This actually signals the guest, using eventfd. */
+void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
+       __u16 flags =3D 0;
+       if (get_user(flags, &vq->avail->flags)) {
+               vq_err(vq, "Failed to get flags");
+               return;
+       }
+
+       /* If they don't want an interrupt, don't signal, unless empty. */
+       if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
+           (vq->avail_idx !=3D vq->last_avail_idx ||
+            !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
+               return;
+
+       /* Signal the Guest tell them we used something up. */
+       if (vq->call_ctx)
+               eventfd_signal(vq->call_ctx, 1);
+}
+
+/* And here's the combo meal deal.  Supersize me! */
+void vhost_add_used_and_signal(struct vhost_dev *dev,
+                              struct vhost_virtqueue *vq,
+                              unsigned int head, int len)
+{
+       vhost_add_used(vq, head, len);
+       vhost_signal(dev, vq);
+}
+
+/* OK, now we need to know about added descriptors. */
+bool vhost_enable_notify(struct vhost_virtqueue *vq)
+{
+       u16 avail_idx;
+       int r;
+       if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
+               return false;
+       vq->used_flags &=3D ~VRING_USED_F_NO_NOTIFY;
+       r =3D put_user(vq->used_flags, &vq->used->flags);
+       if (r) {
+               vq_err(vq, "Failed to enable notification at %p: %d\n",
+                      &vq->used->flags, r);
+               return false;
+       }
+       /* They could have slipped one in as we were doing that: make
+        * sure it's written, then check again. */
+       mb();
+       r =3D get_user(avail_idx, &vq->avail->idx);
+       if (r) {
+               vq_err(vq, "Failed to check avail idx at %p: %d\n",
+                      &vq->avail->idx, r);
+               return false;
+       }
+
+       return avail_idx !=3D vq->last_avail_idx;
+}
+
+/* We don't need to be notified again. */
+void vhost_disable_notify(struct vhost_virtqueue *vq)
+{
+       int r;
+       if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
+               return;
+       vq->used_flags |=3D VRING_USED_F_NO_NOTIFY;
+       r =3D put_user(vq->used_flags, &vq->used->flags);
+       if (r)
+               vq_err(vq, "Failed to enable notification at %p: %d\n",
+                      &vq->used->flags, r);
+}
+
+int vhost_init(void)
+{
+       vhost_workqueue =3D create_singlethread_workqueue("vhost");
+       if (!vhost_workqueue)
+               return -ENOMEM;
+       return 0;
+}
+
+void vhost_cleanup(void)
+{
+       destroy_workqueue(vhost_workqueue);
+}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
new file mode 100644
index 0000000..d1f0453
--- /dev/null
+++ b/drivers/vhost/vhost.h
@@ -0,0 +1,159 @@
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
+#include <linux/uio.h>
+#include <linux/virtio_config.h>
+#include <linux/virtio_ring.h>
+
+struct vhost_device;
+
+enum {
+       /* Enough place for all fragments, head, and virtio net header. */
+       VHOST_NET_MAX_SG =3D MAX_SKB_FRAGS + 2,
+};
+
+/* Poll a file (eventfd or socket) */
+/* Note: there's nothing vhost specific about this structure. */
+struct vhost_poll {
+       poll_table                table;
+       wait_queue_head_t        *wqh;
+       wait_queue_t              wait;
+       /* struct which will handle all actual work. */
+       struct work_struct        work;
+       unsigned long             mask;
+};
+
+void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
+                    unsigned long mask);
+void vhost_poll_start(struct vhost_poll *poll, struct file *file);
+void vhost_poll_stop(struct vhost_poll *poll);
+void vhost_poll_flush(struct vhost_poll *poll);
+void vhost_poll_queue(struct vhost_poll *poll);
+
+struct vhost_log {
+       u64 addr;
+       u64 len;
+};
+
+/* The virtqueue structure describes a queue attached to a device. */
+struct vhost_virtqueue {
+       struct vhost_dev *dev;
+
+       /* The actual ring of buffers. */
+       struct mutex mutex;
+       unsigned int num;
+       struct vring_desc __user *desc;
+       struct vring_avail __user *avail;
+       struct vring_used __user *used;
+       struct file *kick;
+       struct file *call;
+       struct file *error;
+       struct eventfd_ctx *call_ctx;
+       struct eventfd_ctx *error_ctx;
+       struct eventfd_ctx *log_ctx;
+
+       struct vhost_poll poll;
+
+       /* The routine to call when the Guest pings us, or timeout. */
+       work_func_t handle_kick;
+
+       /* Last available index we saw. */
+       u16 last_avail_idx;
+
+       /* Caches available index value from user. */
+       u16 avail_idx;
+
+       /* Last index we used. */
+       u16 last_used_idx;
+
+       /* Used flags */
+       u16 used_flags;
+
+       /* Log writes to used structure. */
+       bool log_used;
+       u64 log_addr;
+
+       struct iovec indirect[VHOST_NET_MAX_SG];
+       struct iovec iov[VHOST_NET_MAX_SG];
+       struct iovec hdr[VHOST_NET_MAX_SG];
+       size_t hdr_size;
+       /* We use a kind of RCU to access private pointer.
+        * All readers access it from workqueue, which makes it possible to
+        * flush the workqueue instead of synchronize_rcu. Therefore reader=
s do
+        * not need to call rcu_read_lock/rcu_read_unlock: the beginning of
+        * work item execution acts instead of rcu_read_lock() and the end =
of
+        * work item execution acts instead of rcu_read_lock().
+        * Writers use virtqueue mutex. */
+       void *private_data;
+       /* Log write descriptors */
+       void __user *log_base;
+       struct vhost_log log[VHOST_NET_MAX_SG];
+};
+
+struct vhost_dev {
+       /* Readers use RCU to access memory table pointer
+        * log base pointer and features.
+        * Writers use mutex below.*/
+       struct vhost_memory *memory;
+       struct mm_struct *mm;
+       struct mutex mutex;
+       unsigned acked_features;
+       struct vhost_virtqueue *vqs;
+       int nvqs;
+       struct file *log_file;
+       struct eventfd_ctx *log_ctx;
+};
+
+long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int n=
vqs);
+long vhost_dev_check_owner(struct vhost_dev *);
+long vhost_dev_reset_owner(struct vhost_dev *);
+void vhost_dev_cleanup(struct vhost_dev *);
+long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long=
 arg);
+
+unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+                          struct iovec iov[], unsigned int iov_count,
+                          unsigned int *out_num, unsigned int *in_num,
+                          struct vhost_log *log, unsigned int *log_num);
+void vhost_discard_vq_desc(struct vhost_virtqueue *);
+
+int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
+void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue =
*,
+                              unsigned int head, int len);
+void vhost_disable_notify(struct vhost_virtqueue *);
+bool vhost_enable_notify(struct vhost_virtqueue *);
+
+int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
+                   unsigned int log_num, u64 len);
+
+int vhost_init(void);
+void vhost_cleanup(void);
+
+#define vq_err(vq, fmt, ...) do {                                  \
+               pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
+               if ((vq)->error_ctx)                               \
+                               eventfd_signal((vq)->error_ctx, 1);\
+       } while (0)
+
+enum {
+       VHOST_FEATURES =3D (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
+                        (1 << VIRTIO_RING_F_INDIRECT_DESC) |
+                        (1 << VHOST_F_LOG_ALL) |
+                        (1 << VHOST_NET_F_VIRTIO_NET_HDR),
+};
+
+static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
+{
+       unsigned acked_features =3D rcu_dereference(dev->acked_features);
+       return acked_features & (1 << bit);
+}
+
+#endif
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 1feed71..e210194 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -361,6 +361,7 @@ unifdef-y +=3D uio.h
 unifdef-y +=3D unistd.h
 unifdef-y +=3D usbdevice_fs.h
 unifdef-y +=3D utsname.h
+unifdef-y +=3D vhost.h
 unifdef-y +=3D videodev2.h
 unifdef-y +=3D videodev.h
 unifdef-y +=3D virtio_config.h
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index adaf3c1..8b5f7cc 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,6 +30,7 @@
 #define HPET_MINOR             228
 #define FUSE_MINOR             229
 #define KVM_MINOR              232
+#define VHOST_NET_MINOR                233
 #define MISC_DYNAMIC_MINOR     255

 struct device;
diff --git a/include/linux/vhost.h b/include/linux/vhost.h
new file mode 100644
index 0000000..e847f1e
--- /dev/null
+++ b/include/linux/vhost.h
@@ -0,0 +1,130 @@
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
+       unsigned int index;
+       unsigned int num;
+};
+
+struct vhost_vring_file {
+       unsigned int index;
+       int fd; /* Pass -1 to unbind from file. */
+
+};
+
+struct vhost_vring_addr {
+       unsigned int index;
+       /* Option flags. */
+       unsigned int flags;
+       /* Flag values: */
+       /* Whether log address is valid. If set enables logging. */
+#define VHOST_VRING_F_LOG 0
+
+       /* Start of array of descriptors (virtually contiguous) */
+       __u64 desc_user_addr;
+       /* Used structure address. Must be 32 bit aligned */
+       __u64 used_user_addr;
+       /* Available structure address. Must be 16 bit aligned */
+       __u64 avail_user_addr;
+       /* Logging support. */
+       /* Log writes to used structure, at offset calculated from specifie=
d
+        * address. Address must be 32 bit aligned. */
+       __u64 log_guest_addr;
+};
+
+struct vhost_memory_region {
+       __u64 guest_phys_addr;
+       __u64 memory_size; /* bytes */
+       __u64 userspace_addr;
+       __u64 flags_padding; /* No flags are currently specified. */
+};
+
+/* All region addresses and sizes must be 4K aligned. */
+#define VHOST_PAGE_SIZE 0x1000
+
+struct vhost_memory {
+       __u32 nregions;
+       __u32 padding;
+       struct vhost_memory_region regions[0];
+};
+
+/* ioctls */
+
+#define VHOST_VIRTIO 0xAF
+
+/* Features bitmask for forward compatibility.  Transport bits are used fo=
r
+ * vhost specific features. */
+#define VHOST_GET_FEATURES     _IOR(VHOST_VIRTIO, 0x00, __u64)
+#define VHOST_SET_FEATURES     _IOW(VHOST_VIRTIO, 0x00, __u64)
+
+/* Set current process as the (exclusive) owner of this file descriptor.  =
This
+ * must be called before any other vhost command.  Further calls to
+ * VHOST_OWNER_SET fail until VHOST_OWNER_RESET is called. */
+#define VHOST_SET_OWNER _IO(VHOST_VIRTIO, 0x01)
+/* Give up ownership, and reset the device to default values.
+ * Allows subsequent call to VHOST_OWNER_SET to succeed. */
+#define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
+
+/* Set up/modify memory layout */
+#define VHOST_SET_MEM_TABLE    _IOW(VHOST_VIRTIO, 0x03, struct vhost_memor=
y)
+
+/* Write logging setup. */
+/* Memory writes can optionally be logged by setting bit at an offset
+ * (calculated from the physical address) from specified log base.
+ * The bit is set using an atomic 32 bit operation. */
+/* Set base address for logging. */
+#define VHOST_SET_LOG_BASE _IOW(VHOST_VIRTIO, 0x04, __u64)
+/* Specify an eventfd file descriptor to signal on log write. */
+#define VHOST_SET_LOG_FD _IOW(VHOST_VIRTIO, 0x07, int)
+
+/* Ring setup. */
+/* Set number of descriptors in ring. This parameter can not
+ * be modified while ring is running (bound to a device). */
+#define VHOST_SET_VRING_NUM _IOW(VHOST_VIRTIO, 0x10, struct vhost_vring_st=
ate)
+/* Set addresses for the ring. */
+#define VHOST_SET_VRING_ADDR _IOW(VHOST_VIRTIO, 0x11, struct vhost_vring_a=
ddr)
+/* Base value where queue looks for available descriptors */
+#define VHOST_SET_VRING_BASE _IOW(VHOST_VIRTIO, 0x12, struct vhost_vring_s=
tate)
+/* Get accessor: reads index, writes value in num */
+#define VHOST_GET_VRING_BASE _IOWR(VHOST_VIRTIO, 0x12, struct vhost_vring_=
state)
+
+/* The following ioctls use eventfd file descriptors to signal and poll
+ * for events. */
+
+/* Set eventfd to poll for added buffers */
+#define VHOST_SET_VRING_KICK _IOW(VHOST_VIRTIO, 0x20, struct vhost_vring_f=
ile)
+/* Set eventfd to signal when buffers have beed used */
+#define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vring_f=
ile)
+/* Set eventfd to signal an error */
+#define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_fi=
le)
+
+/* VHOST_NET specific defines */
+
+/* Attach virtio net ring to a raw socket, or tap device.
+ * The socket must be already bound to an ethernet device, this device wil=
l be
+ * used for transmit.  Pass fd -1 to unbind from the socket and the transm=
it
+ * device.  This can be used to stop the ring (e.g. for migration). */
+#define VHOST_NET_SET_BACKEND _IOW(VHOST_VIRTIO, 0x30, struct vhost_vring_=
file)
+
+/* Feature bits */
+/* Log all write descriptors. Can be changed while device is active. */
+#define VHOST_F_LOG_ALL 26
+/* vhost-net should add virtio_net_hdr for RX, and strip for TX packets. *=
/
+#define VHOST_NET_F_VIRTIO_NET_HDR 27
+
+#endif
--
1.6.5.2.143.g8cc62
--
To unsubscribe from this list: send the line "unsubscribe kvm" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
