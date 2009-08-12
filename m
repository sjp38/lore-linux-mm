Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4B2A46B0062
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 20:06:11 -0400 (EDT)
Received: by qyk36 with SMTP id 36so3706708qyk.12
        for <linux-mm@kvack.org>; Tue, 11 Aug 2009 17:06:09 -0700 (PDT)
Message-ID: <4A82076A.1060805@gmail.com>
Date: Tue, 11 Aug 2009 20:06:02 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
References: <cover.1249992497.git.mst@redhat.com> <20090811212802.GC26309@redhat.com>
In-Reply-To: <20090811212802.GC26309@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC58D320A83E50A7F668FD556"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC58D320A83E50A7F668FD556
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> What it is: vhost net is a character device that can be used to reduce
> the number of system calls involved in virtio networking.
> Existing virtio net code is used in the guest without modification.
>=20
> There's similarity with vringfd, with some differences and reduced scop=
e
> - uses eventfd for signalling
> - structures can be moved around in memory at any time (good for migrat=
ion)
> - support memory table and not just an offset (needed for kvm)
>=20
> common virtio related code has been put in a separate file vhost.c and
> can be made into a separate module if/when more backends appear.  I use=
d
> Rusty's lguest.c as the source for developing this part : this supplied=

> me with witty comments I wouldn't be able to write myself.
>=20
> What it is not: vhost net is not a bus, and not a generic new system
> call. No assumptions are made on how guest performs hypercalls.
> Userspace hypervisors are supported as well as kvm.
>=20
> How it works: Basically, we connect virtio frontend (configured by
> userspace) to a backend. The backend could be a network device, or a
> tun-like device. In this version I only support raw socket as a backend=
,
> which can be bound to e.g. SR IOV, or to macvlan device.  Backend is
> also configured by userspace, including vlan/mac etc.
>=20
> Status:
> This works for me, and I haven't see any crashes.
> I have not run any benchmarks yet, compared to userspace, I expect to
> see improved latency (as I save up to 4 system calls per packet) but no=
t
> bandwidth/CPU (as TSO and interrupt mitigation are not supported).
>=20
> Features that I plan to look at in the future:
> - TSO
> - interrupt mitigation
> - zero copy

Only a quick review for now.  Will look closer later.

(see inline)

>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>=20
> v2
> ---
>  MAINTAINERS                |   10 +
>  arch/x86/kvm/Kconfig       |    1 +
>  drivers/Makefile           |    1 +
>  drivers/vhost/Kconfig      |   11 +
>  drivers/vhost/Makefile     |    2 +
>  drivers/vhost/net.c        |  411 +++++++++++++++++++++++++++
>  drivers/vhost/vhost.c      |  663 ++++++++++++++++++++++++++++++++++++=
++++++++
>  drivers/vhost/vhost.h      |  108 +++++++
>  include/linux/Kbuild       |    1 +
>  include/linux/miscdevice.h |    1 +
>  include/linux/vhost.h      |  100 +++++++
>  11 files changed, 1309 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/vhost/Kconfig
>  create mode 100644 drivers/vhost/Makefile
>  create mode 100644 drivers/vhost/net.c
>  create mode 100644 drivers/vhost/vhost.c
>  create mode 100644 drivers/vhost/vhost.h
>  create mode 100644 include/linux/vhost.h
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ebc2691..eb0c1da 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6312,6 +6312,16 @@ S:	Maintained
>  F:	Documentation/filesystems/vfat.txt
>  F:	fs/fat/
> =20
> +VIRTIO HOST (VHOST)
> +P:	Michael S. Tsirkin
> +M:	mst@redhat.com
> +L:	kvm@vger.kernel.org
> +L:	virtualization@lists.osdl.org
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/vhost/
> +F:	include/linux/vhost.h
> +
>  VIA RHINE NETWORK DRIVER
>  P:	Roger Luethi
>  M:	rl@hellgate.ch
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index b84e571..94f44d9 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -64,6 +64,7 @@ config KVM_AMD
> =20
>  # OK, it's a little counter-intuitive to do this, but it puts it neatl=
y under
>  # the virtualization menu.
> +source drivers/vhost/Kconfig
>  source drivers/lguest/Kconfig
>  source drivers/virtio/Kconfig
> =20
> diff --git a/drivers/Makefile b/drivers/Makefile
> index bc4205d..1551ae1 100644
> --- a/drivers/Makefile
> +++ b/drivers/Makefile
> @@ -105,6 +105,7 @@ obj-$(CONFIG_HID)		+=3D hid/
>  obj-$(CONFIG_PPC_PS3)		+=3D ps3/
>  obj-$(CONFIG_OF)		+=3D of/
>  obj-$(CONFIG_SSB)		+=3D ssb/
> +obj-$(CONFIG_VHOST_NET)		+=3D vhost/
>  obj-$(CONFIG_VIRTIO)		+=3D virtio/
>  obj-$(CONFIG_VLYNQ)		+=3D vlynq/
>  obj-$(CONFIG_STAGING)		+=3D staging/
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> new file mode 100644
> index 0000000..d955406
> --- /dev/null
> +++ b/drivers/vhost/Kconfig
> @@ -0,0 +1,11 @@
> +config VHOST_NET
> +	tristate "Host kernel accelerator for virtio net"
> +	depends on NET && EVENTFD
> +	---help---
> +	  This kernel module can be loaded in host kernel to accelerate
> +	  guest networking with virtio_net. Not to be confused with virtio_ne=
t
> +	  module itself which needs to be loaded in guest kernel.
> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called vhost_net.
> +
> diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
> new file mode 100644
> index 0000000..72dd020
> --- /dev/null
> +++ b/drivers/vhost/Makefile
> @@ -0,0 +1,2 @@
> +obj-$(CONFIG_VHOST_NET) +=3D vhost_net.o
> +vhost_net-y :=3D vhost.o net.o
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> new file mode 100644
> index 0000000..a04ffd0
> --- /dev/null
> +++ b/drivers/vhost/net.c
> @@ -0,0 +1,411 @@
> +/* Copyright (C) 2009 Red Hat, Inc.
> + * Author: Michael S. Tsirkin <mst@redhat.com>
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + *
> + * virtio-net server in host kernel.
> + */
> +
> +#include <linux/eventfd.h>
> +#include <linux/vhost.h>
> +#include <linux/virtio_net.h>
> +#include <linux/mmu_context.h>
> +#include <linux/miscdevice.h>
> +#include <linux/module.h>
> +#include <linux/mutex.h>
> +#include <linux/workqueue.h>
> +#include <linux/rcupdate.h>
> +#include <linux/file.h>
> +
> +#include <linux/net.h>
> +#include <linux/if_packet.h>
> +#include <linux/if_arp.h>
> +
> +#include <net/sock.h>
> +
> +#include <asm/mmu_context.h>
> +
> +#include "vhost.h"
> +
> +enum {
> +	VHOST_NET_VQ_RX =3D 0,
> +	VHOST_NET_VQ_TX =3D 1,
> +	VHOST_NET_VQ_MAX =3D 2,
> +};
> +
> +struct vhost_net {
> +	struct vhost_dev dev;
> +	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
> +	/* We use a kind of RCU to access sock pointer.
> +	 * All readers access it from workqueue,
> +	 * which makes it possible to flush the workqueue
> +	 * instead of synchronize_rcu. Therefore readers
> +	 * do not need rcu_read_lock/rcu_read_unlock.
> +	 * Writers use device mutex. */

This seems odd.  If you have the flush to act as a sync-barrier, why do
you also need rcu_dereference(sock)?  At first blush, it seems
gratuitous.  Can you talk about this aspect of the design in more detail?=


> +	struct socket *sock;
> +	struct vhost_poll poll[VHOST_NET_VQ_MAX];
> +};
> +
> +static void handle_tx(struct vhost_net *net)
> +{
> +	struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_TX];
> +	unsigned head, out, in;
> +	struct msghdr msg =3D {
> +		.msg_name =3D NULL,
> +		.msg_namelen =3D 0,
> +		.msg_control =3D NULL,
> +		.msg_controllen =3D 0,
> +		.msg_iov =3D (struct iovec *)vq->iov + 1,
> +		.msg_flags =3D MSG_DONTWAIT,
> +	};
> +	size_t len;
> +	int err;
> +	struct socket *sock =3D rcu_dereference(net->sock);
> +	if (!sock || !sock_writeable(sock->sk))
> +		return;
> +
> +	use_mm(net->dev.mm);
> +	mutex_lock(&vq->mutex);
> +	for (;;) {
> +		head =3D vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in);
> +		if (head =3D=3D vq->num)
> +			break;
> +		if (out <=3D 1 || in) {
> +			vq_err(vq, "Unexpected descriptor format for TX: "
> +			       "out %d, int %d\n", out, in);
> +			break;
> +		}
> +		/* Sanity check */
> +		if (vq->iov->iov_len !=3D sizeof(struct virtio_net_hdr)) {
> +			vq_err(vq, "Unexpected header len for TX: "
> +			       "%ld expected %zd\n", vq->iov->iov_len,
> +			       sizeof(struct virtio_net_hdr));
> +			break;
> +		}
> +		/* Skip header. TODO: support TSO. */
> +		msg.msg_iovlen =3D out - 1;
> +		len =3D iov_length(vq->iov + 1, out - 1);
> +		/* TODO: Check specific error and bomb out unless ENOBUFS? */
> +		err =3D sock->ops->sendmsg(NULL, sock, &msg, len);
> +		if (err < 0) {
> +			vhost_discard_vq_desc(vq);
> +			break;
> +		}
> +		if (err !=3D len)
> +			pr_err("Truncated TX packet: "
> +			       " len %d !=3D %zd\n", err, len);
> +		vhost_add_used_and_trigger(vq, head,
> +				     len + sizeof(struct virtio_net_hdr));
> +	}
> +
> +	mutex_unlock(&vq->mutex);
> +	unuse_mm(net->dev.mm);
> +}
> +
> +static void handle_rx(struct vhost_net *net)
> +{
> +	struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_RX];
> +	unsigned head, out, in;
> +	struct msghdr msg =3D {
> +		.msg_name =3D NULL,
> +		.msg_namelen =3D 0,
> +		.msg_control =3D NULL, /* FIXME: get and handle RX aux data. */
> +		.msg_controllen =3D 0,
> +		.msg_iov =3D vq->iov + 1,
> +		.msg_flags =3D MSG_DONTWAIT,
> +	};
> +
> +	struct virtio_net_hdr hdr =3D {
> +		.flags =3D 0,
> +		.gso_type =3D VIRTIO_NET_HDR_GSO_NONE
> +	};
> +
> +	size_t len;
> +	int err;
> +	struct socket *sock =3D rcu_dereference(net->sock);
> +	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
> +		return;
> +
> +	use_mm(net->dev.mm);
> +	mutex_lock(&vq->mutex);
> +
> +	for (;;) {
> +		head =3D vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in);
> +		if (head =3D=3D vq->num)
> +			break;
> +		if (in <=3D 1 || out) {
> +			vq_err(vq, "Unexpected descriptor format for RX: out %d, int %d\n",=

> +			       out, in);
> +			break;
> +		}
> +		/* Sanity check */
> +		if (vq->iov->iov_len !=3D sizeof(struct virtio_net_hdr)) {
> +			vq_err(vq, "Unexpected header len for RX: %ld expected %zd\n",
> +			       vq->iov->iov_len, sizeof(struct virtio_net_hdr));
> +			break;
> +		}
> +		/* Skip header. TODO: support TSO/mergeable rx buffers. */
> +		msg.msg_iovlen =3D in - 1;
> +		len =3D iov_length(vq->iov + 1, in - 1);
> +		err =3D sock->ops->recvmsg(NULL, sock, &msg,
> +					 len, MSG_DONTWAIT | MSG_TRUNC);
> +		/* TODO: Check specific error and bomb out unless EAGAIN? */
> +		if (err < 0) {
> +			vhost_discard_vq_desc(vq);
> +			break;
> +		}
> +		/* TODO: Should check and handle checksum. */
> +		if (err > len) {
> +			pr_err("Discarded truncated rx packet: "
> +			       " len %d > %zd\n", err, len);
> +			vhost_discard_vq_desc(vq);
> +			continue;
> +		}
> +		len =3D err;
> +		err =3D copy_to_user(vq->iov->iov_base, &hdr, sizeof hdr);
> +		if (err) {
> +			vq_err(vq, "Unable to write vnet_hdr at addr %p: %d\n",
> +			       vq->iov->iov_base, err);
> +			break;
> +		}
> +		vhost_add_used_and_trigger(vq, head, len + sizeof hdr);
> +	}
> +
> +	mutex_unlock(&vq->mutex);
> +	unuse_mm(net->dev.mm);
> +}
> +
> +static void handle_tx_kick(struct work_struct *work)
> +{
> +	struct vhost_virtqueue *vq;
> +	struct vhost_net *net;
> +	vq =3D container_of(work, struct vhost_virtqueue, poll.work);
> +	net =3D container_of(vq->dev, struct vhost_net, dev);
> +	handle_tx(net);
> +}
> +
> +static void handle_rx_kick(struct work_struct *work)
> +{
> +	struct vhost_virtqueue *vq;
> +	struct vhost_net *net;
> +	vq =3D container_of(work, struct vhost_virtqueue, poll.work);
> +	net =3D container_of(vq->dev, struct vhost_net, dev);
> +	handle_rx(net);
> +}
> +
> +static void handle_tx_net(struct work_struct *work)
> +{
> +	struct vhost_net *net;
> +	net =3D container_of(work, struct vhost_net, poll[VHOST_NET_VQ_TX].wo=
rk);
> +	handle_tx(net);
> +}
> +
> +static void handle_rx_net(struct work_struct *work)
> +{
> +	struct vhost_net *net;
> +	net =3D container_of(work, struct vhost_net, poll[VHOST_NET_VQ_RX].wo=
rk);
> +	handle_rx(net);
> +}
> +
> +static int vhost_net_open(struct inode *inode, struct file *f)
> +{
> +	struct vhost_net *n =3D kzalloc(sizeof *n, GFP_KERNEL);
> +	int r;
> +	if (!n)
> +		return -ENOMEM;
> +	f->private_data =3D n;
> +	n->vqs[VHOST_NET_VQ_TX].handle_kick =3D handle_tx_kick;
> +	n->vqs[VHOST_NET_VQ_RX].handle_kick =3D handle_rx_kick;
> +	r =3D vhost_dev_init(&n->dev, n->vqs, VHOST_NET_VQ_MAX);
> +	if (r < 0) {
> +		kfree(n);
> +		return r;
> +	}
> +
> +	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
> +	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
> +	return 0;
> +}
> +
> +static struct socket *vhost_net_stop(struct vhost_net *n)
> +{
> +	struct socket *sock =3D n->sock;
> +	rcu_assign_pointer(n->sock, NULL);
> +	if (sock) {
> +		vhost_poll_flush(n->poll + VHOST_NET_VQ_TX);
> +		vhost_poll_flush(n->poll + VHOST_NET_VQ_RX);
> +	}
> +	return sock;
> +}
> +
> +static int vhost_net_release(struct inode *inode, struct file *f)
> +{
> +	struct vhost_net *n =3D f->private_data;
> +	struct socket *sock;
> +
> +	sock =3D vhost_net_stop(n);
> +	vhost_dev_cleanup(&n->dev);
> +	if (sock)
> +		fput(sock->file);
> +	kfree(n);
> +	return 0;
> +}
> +
> +static long vhost_net_set_socket(struct vhost_net *n, int fd)
> +{
> +	struct {
> +		struct sockaddr_ll sa;
> +		char  buf[MAX_ADDR_LEN];
> +	} uaddr;
> +	struct socket *sock, *oldsock =3D NULL;
> +	int uaddr_len =3D sizeof uaddr, r;
> +
> +	mutex_lock(&n->dev.mutex);
> +	r =3D vhost_dev_check_owner(&n->dev);
> +	if (r)
> +		goto done;
> +
> +	if (fd =3D=3D -1) {
> +		/* Disconnect from socket and device. */
> +		oldsock =3D vhost_net_stop(n);
> +		goto done;
> +	}
> +=09
> +	sock =3D sockfd_lookup(fd, &r);
> +	if (!sock) {
> +		r =3D -ENOTSOCK;
> +		goto done;
> +	}
> +
> +	/* Parameter checking */
> +	if (sock->sk->sk_type !=3D SOCK_RAW) {
> +		r =3D -ESOCKTNOSUPPORT;
> +		goto done;
> +	}
> +
> +	r =3D sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
> +			       &uaddr_len, 0);
> +	if (r)
> +		goto done;
> +
> +	if (uaddr.sa.sll_family !=3D AF_PACKET) {
> +		r =3D -EPFNOSUPPORT;
> +		goto done;
> +	}
> +
> +	/* start polling new socket */
> +	if (sock =3D=3D oldsock)
> +		goto done;
> +
> +	if (oldsock) {
> +		vhost_poll_stop(n->poll + VHOST_NET_VQ_TX);
> +		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
> +	}
> +	oldsock =3D n->sock;
> +	rcu_assign_pointer(n->sock, sock);
> +	vhost_poll_start(n->poll + VHOST_NET_VQ_TX, sock->file);
> +	vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
> +done:
> +	mutex_unlock(&n->dev.mutex);
> +	if (oldsock) {
> +		vhost_poll_flush(n->poll + VHOST_NET_VQ_TX);
> +		vhost_poll_flush(n->poll + VHOST_NET_VQ_RX);
> +		vhost_poll_flush(&n->dev.vqs[VHOST_NET_VQ_TX].poll);
> +		vhost_poll_flush(&n->dev.vqs[VHOST_NET_VQ_RX].poll);
> +		fput(oldsock->file);
> +	}
> +	return r;
> +}
> +
> +static long vhost_net_reset_owner(struct vhost_net *n)
> +{
> +	struct socket *sock =3D NULL;
> +	long r;
> +	mutex_lock(&n->dev.mutex);
> +	r =3D vhost_dev_check_owner(&n->dev);
> +	if (r)
> +		goto done;
> +	sock =3D vhost_net_stop(n);
> +	r =3D vhost_dev_reset_owner(&n->dev);
> +done:
> +	mutex_unlock(&n->dev.mutex);
> +	if (sock)
> +		fput(sock->file);
> +	return r;
> +}
> +
> +static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
> +			    unsigned long arg)
> +{
> +	struct vhost_net *n =3D f->private_data;
> +	void __user *argp =3D (void __user *)arg;
> +	u32 __user *featurep =3D argp;
> +	int __user *fdp =3D argp;
> +	u32 features;
> +	int fd, r;
> +	switch (ioctl) {
> +	case VHOST_NET_SET_SOCKET:
> +		r =3D get_user(fd, fdp);
> +		if (r < 0)
> +			return r;
> +		return vhost_net_set_socket(n, fd);
> +	case VHOST_GET_FEATURES:
> +		/* No features for now */
> +		features =3D 0;
> +		return put_user(features, featurep);
> +	case VHOST_ACK_FEATURES:
> +		r =3D get_user(features, featurep);
> +		/* No features for now */
> +		if (r < 0)
> +			return r;
> +		if (features)
> +			return -EOPNOTSUPP;
> +		return 0;
> +	case VHOST_RESET_OWNER:
> +		return vhost_net_reset_owner(n);
> +	default:
> +		return vhost_dev_ioctl(&n->dev, ioctl, arg);
> +	}
> +}
> +
> +static struct file_operations vhost_net_fops =3D {
> +	.owner          =3D THIS_MODULE,
> +	.release        =3D vhost_net_release,
> +	.unlocked_ioctl =3D vhost_net_ioctl,
> +	.open           =3D vhost_net_open,
> +};
> +
> +static struct miscdevice vhost_net_misc =3D {
> +	VHOST_NET_MINOR,
> +	"vhost-net",
> +	&vhost_net_fops,
> +};
> +
> +int vhost_net_init(void)
> +{
> +	int r =3D vhost_init();
> +	if (r)
> +		goto err_init;
> +	r =3D misc_register(&vhost_net_misc);
> +	if (r)
> +		goto err_reg;
> +	return 0;
> +err_reg:
> +	vhost_cleanup();
> +err_init:
> +	return r;
> +
> +}
> +module_init(vhost_net_init);
> +
> +void vhost_net_exit(void)
> +{
> +	misc_deregister(&vhost_net_misc);
> +	vhost_cleanup();
> +}
> +module_exit(vhost_net_exit);
> +
> +MODULE_VERSION("0.0.1");
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Michael S. Tsirkin");
> +MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> new file mode 100644
> index 0000000..6178ec1
> --- /dev/null
> +++ b/drivers/vhost/vhost.c
> @@ -0,0 +1,663 @@
> +/* Copyright (C) 2009 Red Hat, Inc.
> + * Copyright (C) 2006 Rusty Russell IBM Corporation
> + *
> + * Author: Michael S. Tsirkin <mst@redhat.com>
> + *
> + * Inspiration, some code, and most witty comments come from
> + * Documentation/lguest/lguest.c, by Rusty Russell
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + *
> + * Generic code for virtio server in host kernel.
> + */
> +
> +#include <linux/eventfd.h>
> +#include <linux/vhost.h>
> +#include <linux/virtio_net.h>
> +#include <linux/mm.h>
> +#include <linux/miscdevice.h>
> +#include <linux/mutex.h>
> +#include <linux/workqueue.h>
> +#include <linux/rcupdate.h>
> +#include <linux/poll.h>
> +#include <linux/file.h>
> +
> +#include <linux/net.h>
> +#include <linux/if_packet.h>
> +#include <linux/if_arp.h>
> +
> +#include <net/sock.h>
> +
> +#include <asm/mmu_context.h>
> +
> +#include "vhost.h"
> +
> +enum {
> +	VHOST_MEMORY_MAX_NREGIONS =3D 64,
> +};
> +
> +struct workqueue_struct *vhost_workqueue;
> +
> +static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,=

> +			    poll_table *pt)
> +{
> +	struct vhost_poll *poll;
> +	poll =3D container_of(pt, struct vhost_poll, table);
> +
> +	poll->wqh =3D wqh;
> +	add_wait_queue(wqh, &poll->wait);
> +}
> +
> +static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sy=
nc, void *key)
> +{
> +	struct vhost_poll *poll;
> +	poll =3D container_of(wait, struct vhost_poll, wait);
> +	if (!((unsigned long)key & poll->mask))
> +		return 0;
> +
> +	queue_work(vhost_workqueue, &poll->work);
> +	return 0;
> +}
> +
> +/* Init poll structure */
> +void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> +		     unsigned long mask)
> +{
> +	INIT_WORK(&poll->work, func);
> +	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
> +	init_poll_funcptr(&poll->table, vhost_poll_func);
> +	poll->mask =3D mask;
> +}
> +
> +/* Start polling a file. We add ourselves to file's wait queue. The us=
er must
> + * keep a reference to a file until after vhost_poll_stop is called. *=
/
> +void vhost_poll_start(struct vhost_poll *poll, struct file *file)
> +{
> +	unsigned long mask;
> +	mask =3D file->f_op->poll(file, &poll->table);
> +	if (mask)
> +		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
> +}
> +
> +/* Stop polling a file. After this function returns, it becomes safe t=
o drop the
> + * file reference. You must also flush afterwards. */
> +void vhost_poll_stop(struct vhost_poll *poll)
> +{
> +	remove_wait_queue(poll->wqh, &poll->wait);
> +}
> +
> +/* Flush any work that has been scheduled. When calling this, don't ho=
ld any
> + * locks that are also used by the callback. */
> +void vhost_poll_flush(struct vhost_poll *poll)
> +{
> +	flush_work(&poll->work);
> +}
> +
> +long vhost_dev_init(struct vhost_dev *dev, struct vhost_virtqueue *vqs=
, int nvqs)
> +{
> +	int i;
> +	dev->vqs =3D vqs;
> +	dev->nvqs =3D nvqs;
> +	mutex_init(&dev->mutex);
> +
> +	for(i =3D 0; i < dev->nvqs; ++i) {
> +		dev->vqs[i].dev =3D dev;
> +		mutex_init(&dev->vqs[i].mutex);
> +		if (dev->vqs[i].handle_kick)
> +			vhost_poll_init(&dev->vqs[i].poll,
> +					dev->vqs[i].handle_kick,
> +					POLLIN);
> +	}
> +	return 0;
> +}
> +
> +/* User should have device mutex */
> +long vhost_dev_check_owner(struct vhost_dev *dev)
> +{
> +	return dev->mm =3D=3D current->mm ? 0 : -EPERM;
> +}
> +
> +/* User should have device mutex */
> +static long vhost_dev_set_owner(struct vhost_dev *dev)
> +{
> +	if (dev->mm)
> +		return -EBUSY;
> +	dev->mm =3D get_task_mm(current);
> +	return 0;
> +}
> +
> +/* User should have device mutex */
> +long vhost_dev_reset_owner(struct vhost_dev *dev)
> +{
> +	struct vhost_memory *memory;
> +
> +	/* Restore memory to default 1:1 mapping. */
> +	memory =3D kmalloc(offsetof(struct vhost_memory, regions) +
> +			 2 * sizeof *memory->regions, GFP_KERNEL);
> +	if (!memory)
> +		return -ENOMEM;
> +
> +	vhost_dev_cleanup(dev);
> +
> +	memory->nregions =3D 2;
> +	memory->regions[0].guest_phys_addr =3D 1;
> +	memory->regions[0].userspace_addr =3D 1;
> +	memory->regions[0].memory_size =3D ~0ULL;
> +	memory->regions[1].guest_phys_addr =3D 0;
> +	memory->regions[1].userspace_addr =3D 0;
> +	memory->regions[1].memory_size =3D 1;
> +	dev->memory =3D memory;
> +	return 0;
> +}
> +
> +/* User should have device mutex */
> +void vhost_dev_cleanup(struct vhost_dev *dev)
> +{
> +	int i;
> +	for(i =3D 0; i < dev->nvqs; ++i) {
> +		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
> +			vhost_poll_stop(&dev->vqs[i].poll);
> +			vhost_poll_flush(&dev->vqs[i].poll);
> +		}
> +		if (dev->vqs[i].error_ctx)
> +			eventfd_ctx_put(dev->vqs[i].error_ctx);
> +		if (dev->vqs[i].error)
> +			fput(dev->vqs[i].error);
> +		if (dev->vqs[i].kick)
> +			fput(dev->vqs[i].kick);
> +		if (dev->vqs[i].call_ctx)
> +			eventfd_ctx_put(dev->vqs[i].call_ctx);
> +		if (dev->vqs[i].call)
> +			fput(dev->vqs[i].call);
> +		dev->vqs[i].error_ctx =3D NULL;
> +		dev->vqs[i].error =3D NULL;
> +		dev->vqs[i].kick =3D NULL;
> +		dev->vqs[i].call_ctx =3D NULL;
> +		dev->vqs[i].call =3D NULL;
> +	}
> +	/* No one will access memory at this point */
> +	kfree(dev->memory);
> +	dev->memory =3D NULL;
> +	if (dev->mm)
> +		mmput(dev->mm);
> +	dev->mm =3D NULL;
> +}
> +
> +static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory =
__user *m)
> +{
> +	struct vhost_memory mem, *newmem, *oldmem;
> +	unsigned long size =3D offsetof(struct vhost_memory, regions);
> +	long r;
> +	r =3D copy_from_user(&mem, m, size);
> +	if (r)
> +		return r;
> +	if (mem.padding)
> +		return -EOPNOTSUPP;
> +	if (mem.nregions > VHOST_MEMORY_MAX_NREGIONS)
> +		return -E2BIG;
> +	newmem =3D kmalloc(size + mem.nregions * sizeof *m->regions, GFP_KERN=
EL);
> +	if (!newmem)
> +		return -ENOMEM;
> +
> +	memcpy(newmem, &mem, size);
> +	r =3D copy_from_user(newmem->regions, m->regions,
> +			   mem.nregions * sizeof *m->regions);
> +	if (r) {
> +		kfree(newmem);
> +		return r;
> +	}
> +	oldmem =3D d->memory;
> +	rcu_assign_pointer(d->memory, newmem);
> +	synchronize_rcu();
> +	kfree(oldmem);
> +	return 0;
> +}
> +
> +static int init_used(struct vhost_virtqueue *vq)
> +{
> +	u16 flags =3D 0;
> +	int r =3D put_user(flags, &vq->used->flags);
> +	if (r)
> +		return r;
> +	return get_user(vq->last_used_idx, &vq->used->idx);
> +}
> +
> +static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __use=
r *argp)
> +{
> +	struct file *eventfp, *filep =3D NULL, *pollstart =3D NULL, *pollstop=
 =3D NULL;
> +	struct eventfd_ctx *ctx =3D NULL;
> +	u32 __user *idxp =3D argp;
> +	struct vhost_virtqueue *vq;
> +	struct vhost_vring_state s;
> +	struct vhost_vring_file f;
> +	struct vhost_vring_addr a;
> +	u32 idx;
> +	long r;
> +
> +	r =3D get_user(idx, idxp);
> +	if (r < 0)
> +		return r;
> +	if (idx > d->nvqs)
> +		return -ENOBUFS;
> +
> +	vq =3D d->vqs + idx;
> +
> +	mutex_lock(&vq->mutex);
> +
> +	switch (ioctl) {
> +	case VHOST_SET_VRING_NUM:
> +		r =3D copy_from_user(&s, argp, sizeof s);
> +		if (r < 0)
> +			break;
> +		if (s.num > 0xffff) {
> +			r =3D -EINVAL;
> +			break;
> +		}
> +		vq->num =3D s.num;
> +		break;
> +	case VHOST_SET_VRING_BASE:
> +		r =3D copy_from_user(&s, argp, sizeof s);
> +		if (r < 0)
> +			break;
> +		if (s.num > 0xffff) {
> +			r =3D -EINVAL;
> +			break;
> +		}
> +		vq->last_avail_idx =3D s.num;
> +		break;
> +	case VHOST_GET_VRING_BASE:
> +		s.index =3D idx;
> +		s.num =3D vq->last_avail_idx;
> +		r =3D copy_to_user(argp, &s, sizeof s);
> +		break;
> +	case VHOST_SET_VRING_DESC:
> +		r =3D copy_from_user(&a, argp, sizeof a);
> +		if (r < 0)
> +			break;
> +		if (a.padding) {
> +			r =3D -EOPNOTSUPP;
> +			break;
> +		}
> +		if ((u64)(long)a.user_addr !=3D a.user_addr) {
> +			r =3D -EFAULT;
> +			break;
> +		}
> +		vq->desc =3D (void __user *)(long)a.user_addr;
> +		break;
> +	case VHOST_SET_VRING_AVAIL:
> +		r =3D copy_from_user(&a, argp, sizeof a);
> +		if (r < 0)
> +			break;
> +		if (a.padding) {
> +			r =3D -EOPNOTSUPP;
> +			break;
> +		}
> +		if ((u64)(long)a.user_addr !=3D a.user_addr) {
> +			r =3D -EFAULT;
> +			break;
> +		}
> +		vq->avail =3D (void __user *)(long)a.user_addr;
> +		break;
> +	case VHOST_SET_VRING_USED:
> +		r =3D copy_from_user(&a, argp, sizeof a);
> +		if (r < 0)
> +			break;
> +		if (a.padding) {
> +			r =3D -EOPNOTSUPP;
> +			break;
> +		}
> +		if ((u64)(long)a.user_addr !=3D a.user_addr) {
> +			r =3D -EFAULT;
> +			break;
> +		}
> +		vq->used =3D (void __user *)(long)a.user_addr;
> +		r =3D init_used(vq);
> +		if (r)
> +			break;
> +		break;
> +	case VHOST_SET_VRING_KICK:
> +		r =3D copy_from_user(&f, argp, sizeof f);
> +		if (r < 0)
> +			break;
> +		eventfp =3D f.fd =3D=3D -1 ? NULL: eventfd_fget(f.fd);
> +		if (IS_ERR(eventfp))
> +			return PTR_ERR(eventfp);
> +		if (eventfp !=3D vq->kick) {
> +			pollstop =3D filep =3D vq->kick;
> +			pollstart =3D vq->kick =3D eventfp;
> +		} else
> +			filep =3D eventfp;
> +		break;
> +	case VHOST_SET_VRING_CALL:
> +		r =3D copy_from_user(&f, argp, sizeof f);
> +		if (r < 0)
> +			break;
> +		eventfp =3D f.fd =3D=3D -1 ? NULL: eventfd_fget(f.fd);
> +		if (IS_ERR(eventfp))
> +			return PTR_ERR(eventfp);
> +		if (eventfp !=3D vq->call) {
> +			filep =3D vq->call;
> +			ctx =3D vq->call_ctx;
> +			vq->call =3D eventfp;
> +			vq->call_ctx =3D eventfp ?
> +				eventfd_ctx_fileget(eventfp) : NULL;
> +		} else
> +			filep =3D eventfp;
> +		break;
> +	case VHOST_SET_VRING_ERR:
> +		r =3D copy_from_user(&f, argp, sizeof f);
> +		if (r < 0)
> +			break;
> +		eventfp =3D f.fd =3D=3D -1 ? NULL: eventfd_fget(f.fd);
> +		if (IS_ERR(eventfp))
> +			return PTR_ERR(eventfp);
> +		if (eventfp !=3D vq->error) {
> +			filep =3D vq->error;
> +			vq->error =3D eventfp;
> +			ctx =3D vq->error_ctx;
> +			vq->error_ctx =3D eventfp ?
> +				eventfd_ctx_fileget(eventfp) : NULL;
> +		} else
> +			filep =3D eventfp;
> +		break;
> +	default:
> +		r =3D -ENOTTY;
> +	}
> +
> +	if (pollstop && vq->handle_kick)
> +		vhost_poll_stop(&vq->poll);
> +
> +	if (ctx)
> +		eventfd_ctx_put(ctx);
> +	if (filep)
> +		fput(filep);
> +
> +	if (pollstart && vq->handle_kick)
> +		vhost_poll_start(&vq->poll, vq->kick);
> +
> +	mutex_unlock(&vq->mutex);
> +
> +	if (pollstop && vq->handle_kick)
> +		vhost_poll_flush(&vq->poll);
> +	return 0;
> +}
> +
> +long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned=
 long arg)
> +{
> +	void __user *argp =3D (void __user *)arg;
> +	long r;
> +
> +	mutex_lock(&d->mutex);
> +	if (ioctl =3D=3D VHOST_SET_OWNER) {
> +		r =3D vhost_dev_set_owner(d);
> +		goto done;
> +	}
> +
> +	r =3D vhost_dev_check_owner(d);
> +	if (r)
> +		goto done;
> +	=09
> +	switch (ioctl) {
> +	case VHOST_SET_MEM_TABLE:
> +		r =3D vhost_set_memory(d, argp);
> +		break;
> +	default:
> +		r =3D vhost_set_vring(d, ioctl, argp);
> +		break;
> +	}
> +done:
> +	mutex_unlock(&d->mutex);
> +	return r;
> +}
> +
> +static const struct vhost_memory_region *find_region(struct vhost_memo=
ry *mem,
> +						     __u64 addr, __u32 len)
> +{
> +	struct vhost_memory_region *reg;
> +	int i;
> +	/* linear search is not brilliant, but we really have on the order of=
 6
> +	 * regions in practice */
> +	for (i =3D 0; i < mem->nregions; ++i) {
> +		reg =3D mem->regions + i;
> +		if (reg->guest_phys_addr <=3D addr &&
> +		    reg->guest_phys_addr + reg->memory_size - 1 >=3D addr)
> +			return reg;
> +	}
> +	return NULL;
> +}
> +
> +/* FIXME: this does not handle a region that spans multiple
> + * address/len pairs */
> +int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
> +		   struct iovec iov[], int iov_count, int iov_size,
> +		   unsigned *num)
> +{
> +	const struct vhost_memory_region *reg;
> +	struct vhost_memory *mem;
> +	struct iovec *_iov;
> +	u64 s =3D 0;
> +	int ret =3D 0;
> +
> +	rcu_read_lock();
> +
> +	mem =3D rcu_dereference(dev->memory);
> +	while ((u64)len > s) {
> +		u64 size;
> +		if (*num + iov_count >=3D iov_size) {
> +			ret =3D -ENOBUFS;
> +			break;
> +		}
> +		reg =3D find_region(mem, addr, len);
> +		if (!reg) {
> +			ret =3D -EFAULT;
> +			break;
> +		}
> +		_iov =3D iov + iov_count + *num;
> +		size =3D reg->memory_size - addr + reg->guest_phys_addr;
> +		_iov->iov_len =3D min((u64)len, size);
> +		_iov->iov_base =3D (void *)
> +			(reg->userspace_addr + addr - reg->guest_phys_addr);
> +		s +=3D size;
> +		addr +=3D size;
> +		++*num;
> +	}
> +=09
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
> +/* Each buffer in the virtqueues is actually a chain of descriptors.  =
This
> + * function returns the next descriptor in the chain, or vq->vring.num=
 if we're
> + * at the end. */
> +static unsigned next_desc(struct vhost_virtqueue *vq, struct vring_des=
c *desc)
> +{
> +	unsigned int next;
> +
> +	/* If this descriptor says it doesn't chain, we're done. */
> +	if (!(desc->flags & VRING_DESC_F_NEXT))
> +		return vq->num;
> +
> +	/* Check they're not leading us off end of descriptors. */
> +	next =3D desc->next;
> +	/* Make sure compiler knows to grab that: we don't want it changing! =
*/
> +	/* We will use the result as an index in an array, so most
> +	 * architectures only need a compiler barrier here. */
> +	read_barrier_depends();
> +
> +	if (next >=3D vq->num) {
> +		vq_err(vq, "Desc next is %u > %u", next, vq->num);
> +		return vq->num;
> +	}
> +
> +	return next;
> +}
> +
> +/* This looks in the virtqueue and for the first available buffer, and=
 converts
> + * it to an iovec for convenient access.  Since descriptors consist of=
 some
> + * number of output then some number of input descriptors, it's actual=
ly two
> + * iovecs, but we pack them into one and note how many of each there w=
ere.
> + *
> + * This function returns the descriptor number found, or vq->num (whic=
h
> + * is never a valid descriptor number) if none was found. */
> +unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtque=
ue *vq,
> +			   struct iovec iov[],
> +			   unsigned int *out_num, unsigned int *in_num)
> +{
> +	struct vring_desc desc;
> +	unsigned int i, head;
> +	u16 last_avail_idx, idx;
> +
> +	/* Check it isn't doing very strange things with descriptor numbers. =
*/
> +	last_avail_idx =3D vq->last_avail_idx;
> +	if (get_user(idx, &vq->avail->idx)) {
> +		vq_err(vq, "Failed to access avail idx at %p\n",
> +		       &vq->avail->idx);
> +		return vq->num;
> +	}
> +=09
> +	if ((u16)(idx - last_avail_idx) > vq->num) {
> +		vq_err(vq, "Guest moved used index from %u to %u",
> +		       last_avail_idx, idx);
> +		return vq->num;
> +	}
> +
> +	/* If there's nothing new since last we looked, return invalid. */
> +	if (idx =3D=3D last_avail_idx)
> +		return vq->num;
> +
> +	/* Grab the next descriptor number they're advertising, and increment=

> +	 * the index we've seen. */
> +	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
> +		vq_err(vq, "Failed to read head: idx %d address %p\n",
> +		       idx, &vq->avail->ring[last_avail_idx % vq->num]);
> +		return vq->num;
> +	}
> +
> +	/* If their number is silly, that's a fatal mistake. */
> +	if (head >=3D vq->num) {
> +		vq_err(vq, "Guest says index %u > %u is available",
> +		       head, vq->num);
> +		return vq->num;
> +	}
> +
> +	vq->last_avail_idx++;
> +
> +	/* When we start there are none of either input nor output. */
> +	*out_num =3D *in_num =3D 0;
> +
> +	i =3D head;
> +	do {
> +		unsigned *num;
> +		unsigned iov_count;
> +		if (copy_from_user(&desc, vq->desc + i, sizeof desc)) {
> +			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
> +			       i, vq->desc + i);
> +			return vq->num;
> +		}
> +		/* If this is an input descriptor, increment that count. */
> +		if (desc.flags & VRING_DESC_F_WRITE) {
> +			num =3D in_num;
> +			iov_count =3D *out_num;
> +		} else {
> +			/* If it's an output descriptor, they're all supposed
> +			 * to come before any input descriptors. */
> +			if (*in_num) {
> +				vq_err(vq, "Descriptor has out after in: "
> +				       "idx %d\n", i);
> +				return vq->num;
> +			}
> +			num =3D out_num;
> +			iov_count =3D *in_num;
> +		}
> +		if (translate_desc(dev, desc.addr, desc.len, iov, iov_count,
> +				   VHOST_NET_MAX_SG, num)) {
> +			vq_err(vq, "Failed to translate descriptor: idx %d\n",
> +			       i);
> +			return vq->num;
> +		}
> +
> +		/* If we've got too many, that implies a descriptor loop. */
> +		if (*out_num + *in_num > vq->num) {
> +			vq_err(vq, "Looped descriptor: idx %d\n", i);
> +			return vq->num;
> +		}
> +	} while ((i =3D next_desc(vq, &desc)) !=3D vq->num);
> +
> +	vq->inflight++;
> +	return head;
> +}
> +
> +/* Reverse the effect of vhost_get_vq_desc. Useful for error handling.=
 */
> +void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> +{
> +	vq->last_avail_idx--;
> +	vq->inflight--;
> +}
> +
> +/* After we've used one of their buffers, we tell them about it.  We'l=
l then
> + * want to send them an interrupt, using vq->call. */
> +int vhost_add_used(struct vhost_virtqueue *vq,
> +			  unsigned int head, int len)
> +{
> +	struct vring_used_elem *used;
> +
> +	/* The virtqueue contains a ring of used buffers.  Get a pointer to t=
he
> +	 * next entry in that used ring. */
> +	used =3D &vq->used->ring[vq->last_used_idx % vq->num];
> +	if (put_user(head, &used->id)) {
> +		vq_err(vq, "Failed to write used id");
> +		return -EFAULT;
> +	}
> +	if (put_user(len, &used->len)) {
> +		vq_err(vq, "Failed to write used len");
> +		return -EFAULT;
> +	}
> +	/* Make sure buffer is written before we update index. */
> +	wmb();
> +	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
> +		vq_err(vq, "Failed to increment used idx");
> +		return -EFAULT;
> +	}
> +	vq->last_used_idx++;
> +	vq->inflight--;
> +	return 0;
> +}
> +
> +/* This actually sends the interrupt for this virtqueue */
> +void vhost_trigger_irq(struct vhost_virtqueue *vq)
> +{
> +	__u16 flags =3D 0;
> +	if (get_user(flags, &vq->avail->flags)) {
> +		vq_err(vq, "Failed to get flags");
> +		return;
> +	}
> +
> +	/* If they don't want an interrupt, don't send one, unless empty. */
> +	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) && vq->inflight)
> +		return;
> +
> +	/* Send the Guest an interrupt tell them we used something up. */
> +	if (vq->call_ctx)
> +		eventfd_signal(vq->call_ctx, 1);
> +}
> +
> +/* And here's the combo meal deal.  Supersize me! */
> +void vhost_add_used_and_trigger(struct vhost_virtqueue *vq,
> +				unsigned int head, int len)
> +{
> +	vhost_add_used(vq, head, len);
> +	vhost_trigger_irq(vq);
> +}
> +
> +int vhost_init(void)
> +{
> +	vhost_workqueue =3D create_workqueue("vhost");
> +	if (!vhost_workqueue)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +void vhost_cleanup(void)
> +{
> +	destroy_workqueue(vhost_workqueue);
> +}
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> new file mode 100644
> index 0000000..7f7ffcd
> --- /dev/null
> +++ b/drivers/vhost/vhost.h
> @@ -0,0 +1,108 @@
> +#ifndef _VHOST_H
> +#define _VHOST_H
> +
> +#include <linux/eventfd.h>
> +#include <linux/vhost.h>
> +#include <linux/mm.h>
> +#include <linux/mutex.h>
> +#include <linux/workqueue.h>
> +#include <linux/poll.h>
> +#include <linux/file.h>
> +#include <linux/skbuff.h>
> +
> +struct vhost_device;
> +
> +enum {
> +	VHOST_NET_MAX_SG =3D MAX_SKB_FRAGS + 2,
> +};
> +
> +/* Poll a file (eventfd or socket) */
> +/* Note: there's nothing vhost specific about this structure. */
> +struct vhost_poll {
> +	poll_table                table;
> +	wait_queue_head_t        *wqh;
> +	wait_queue_t              wait;
> +	/* struct which will handle all actual work. */
> +	struct work_struct        work;
> +	unsigned long		  mask;
> +};
> +
> +void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> +		     unsigned long mask);
> +void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> +void vhost_poll_stop(struct vhost_poll *poll);
> +void vhost_poll_flush(struct vhost_poll *poll);
> +
> +/* The virtqueue structure describes a queue attached to a device. */
> +struct vhost_virtqueue {
> +	struct vhost_dev *dev;
> +
> +	/* The actual ring of buffers. */
> +	struct mutex mutex;
> +	unsigned int num;
> +	struct vring_desc __user *desc;
> +	struct vring_avail __user *avail;
> +	struct vring_used __user *used;
> +	struct file *kick;
> +	struct file *call;
> +	struct file *error;
> +	struct eventfd_ctx *call_ctx;
> +	struct eventfd_ctx *error_ctx;
> +
> +	struct vhost_poll poll;
> +
> +	/* The routine to call when the Guest pings us, or timeout. */
> +	work_func_t handle_kick;
> +
> +	/* Last available index we saw. */
> +	u16 last_avail_idx;
> +
> +	/* Last index we used. */
> +	u16 last_used_idx;
> +
> +	/* Outstanding buffers */
> +	unsigned int inflight;
> +
> +	/* Is this blocked? */
> +	bool blocked;
> +
> +	struct iovec iov[VHOST_NET_MAX_SG];
> +
> +} ____cacheline_aligned;
> +
> +struct vhost_dev {
> +	/* Readers use RCU to access memory table pointer.
> +	 * Writers use mutex below.*/
> +	struct vhost_memory *memory;
> +	struct mm_struct *mm;
> +	struct vhost_virtqueue *vqs;
> +	int nvqs;
> +	struct mutex mutex;
> +};
> +
> +long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, i=
nt nvqs);
> +long vhost_dev_check_owner(struct vhost_dev *);
> +long vhost_dev_reset_owner(struct vhost_dev *);
> +void vhost_dev_cleanup(struct vhost_dev *);
> +long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned =
long arg);
> +
> +unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue =
*,
> +			   struct iovec iov[],
> +			   unsigned int *out_num, unsigned int *in_num);
> +void vhost_discard_vq_desc(struct vhost_virtqueue *);
> +
> +int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int le=
n);
> +void vhost_trigger_irq(struct vhost_virtqueue *);
> +void vhost_add_used_and_trigger(struct vhost_virtqueue *,
> +				unsigned int head, int len);
> +
> +int vhost_init(void);
> +void vhost_cleanup(void);
> +
> +#define vq_err(vq, fmt, ...) do {                                  \
> +		printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__);       \
> +		if ((vq)->error_ctx)                               \
> +				eventfd_signal((vq)->error_ctx, 1);\
> +	} while (0)
> +
> +#endif
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index dec2f18..975df9a 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -360,6 +360,7 @@ unifdef-y +=3D uio.h
>  unifdef-y +=3D unistd.h
>  unifdef-y +=3D usbdevice_fs.h
>  unifdef-y +=3D utsname.h
> +unifdef-y +=3D vhost.h
>  unifdef-y +=3D videodev2.h
>  unifdef-y +=3D videodev.h
>  unifdef-y +=3D virtio_config.h
> diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
> index 0521177..781a8bb 100644
> --- a/include/linux/miscdevice.h
> +++ b/include/linux/miscdevice.h
> @@ -30,6 +30,7 @@
>  #define HPET_MINOR		228
>  #define FUSE_MINOR		229
>  #define KVM_MINOR		232
> +#define VHOST_NET_MINOR		233

Would recommend using DYNAMIC-MINOR.

>  #define MISC_DYNAMIC_MINOR	255
> =20
>  struct device;
> diff --git a/include/linux/vhost.h b/include/linux/vhost.h
> new file mode 100644
> index 0000000..9ec6d5f
> --- /dev/null
> +++ b/include/linux/vhost.h
> @@ -0,0 +1,100 @@
> +#ifndef _LINUX_VHOST_H
> +#define _LINUX_VHOST_H
> +/* Userspace interface for in-kernel virtio accelerators. */
> +
> +/* vhost is used to reduce the number of system calls involved in virt=
io.
> + *
> + * Existing virtio net code is used in the guest without modification.=

> + *
> + * This header includes interface used by userspace hypervisor for
> + * device configuration.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/compiler.h>
> +#include <linux/ioctl.h>
> +#include <linux/virtio_config.h>
> +#include <linux/virtio_ring.h>
> +
> +struct vhost_vring_state {
> +	unsigned int index;
> +	unsigned int num;
> +};
> +
> +struct vhost_vring_file {
> +	unsigned int index;
> +	int fd;
> +};
> +
> +struct vhost_vring_addr {
> +	unsigned int index;
> +	unsigned int padding;
> +	__u64 user_addr;
> +};
> +
> +struct vhost_memory_region {
> +	__u64 guest_phys_addr;
> +	__u64 memory_size; /* bytes */
> +	__u64 userspace_addr;
> +	__u64 padding; /* read/write protection? */
> +};
> +
> +struct vhost_memory {
> +	__u32 nregions;
> +	__u32 padding;
> +	struct vhost_memory_region regions[0];
> +};
> +
> +/* ioctls */
> +
> +#define VHOST_VIRTIO 0xAF
> +
> +/* Features bitmask for forward compatibility. Transport bits must be =
zero. */
> +#define VHOST_GET_FEATURES	_IOR(VHOST_VIRTIO, 0x00, __u32)
> +#define VHOST_ACK_FEATURES	_IOW(VHOST_VIRTIO, 0x00, __u32)
> +
> +/* Set current process as the (exclusive) owner of this file descripto=
r.  This
> + * must be called before any other vhost command.  Further calls to
> + * VHOST_OWNER_SET fail until VHOST_OWNER_RESET is called. */
> +#define VHOST_SET_OWNER _IO(VHOST_VIRTIO, 0x01)
> +/* Give up ownership, and reset the device to default values.
> + * Allows subsequent call to VHOST_OWNER_SET to succeed. */
> +#define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
> +
> +/* Set up/modify memory layout */
> +#define VHOST_SET_MEM_TABLE	_IOW(VHOST_VIRTIO, 0x03, struct vhost_memo=
ry)
> +
> +/* Ring setup. These parameters can not be modified while ring is runn=
ing
> + * (bound to a device). */
> +/* Set number of descriptors in ring */
> +#define VHOST_SET_VRING_NUM _IOW(VHOST_VIRTIO, 0x10, struct vhost_vrin=
g_state)
> +/* Start of array of descriptors (virtually contiguous) */
> +#define VHOST_SET_VRING_DESC _IOW(VHOST_VIRTIO, 0x11, struct vhost_vri=
ng_addr)
> +/* Used structure address */
> +#define VHOST_SET_VRING_USED _IOW(VHOST_VIRTIO, 0x12, struct vhost_vri=
ng_addr)
> +/* Available structure address */
> +#define VHOST_SET_VRING_AVAIL _IOW(VHOST_VIRTIO, 0x13, struct vhost_vr=
ing_addr)
> +/* Base value where queue looks for available descriptors */
> +#define VHOST_SET_VRING_BASE _IOW(VHOST_VIRTIO, 0x14, struct vhost_vri=
ng_state)
> +/* Get accessor: reads index, writes value in num */
> +#define VHOST_GET_VRING_BASE _IOWR(VHOST_VIRTIO, 0x14, struct vhost_vr=
ing_state)
> +
> +/* The following ioctls use eventfd file descriptors to signal and pol=
l
> + * for events. */
> +
> +/* Set eventfd to poll for added buffers */
> +#define VHOST_SET_VRING_KICK _IOW(VHOST_VIRTIO, 0x20, struct vhost_vri=
ng_file)
> +/* Set eventfd to signal when buffers have beed used */
> +#define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vri=
ng_file)
> +/* Set eventfd to signal an error */
> +#define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vrin=
g_file)
> +
> +/* VHOST_NET specific defines */
> +
> +/* Attach virtio net device to a raw socket. The socket must be alread=
y
> + * bound to an ethernet device, this device will be used for transmit.=

> + * Pass -1 to unbind from the socket and the transmit device.
> + * This can be used to stop the device (e.g. for migration). */
> +#define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, int)
> +
> +#endif



--------------enigC58D320A83E50A7F668FD556
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCB2oACgkQP5K2CMvXmqF1WACfZobJn+s79rWJ5uYgEo9c4pIb
UG4An1xTGZQn2HN0bm6+6VeV3xUAhCme
=RPVQ
-----END PGP SIGNATURE-----

--------------enigC58D320A83E50A7F668FD556--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
