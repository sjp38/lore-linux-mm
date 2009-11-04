Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 033956B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 06:09:15 -0500 (EST)
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
From: Andi Kleen <andi@firstfloor.org>
References: <cover.1257267892.git.mst@redhat.com>
	<20091103172422.GD5591@redhat.com>
Date: Wed, 04 Nov 2009 12:08:47 +0100
In-Reply-To: <20091103172422.GD5591@redhat.com> (Michael S. Tsirkin's message of "Tue, 3 Nov 2009 19:24:23 +0200")
Message-ID: <878wema6o0.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

"Michael S. Tsirkin" <mst@redhat.com> writes:

Haven't really read the whole thing, just noticed something at a glance.

> +/* Expects to be always run from workqueue - which acts as
> + * read-size critical section for our kind of RCU. */
> +static void handle_tx(struct vhost_net *net)
> +{
> +	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> +	unsigned head, out, in, s;
> +	struct msghdr msg = {
> +		.msg_name = NULL,
> +		.msg_namelen = 0,
> +		.msg_control = NULL,
> +		.msg_controllen = 0,
> +		.msg_iov = vq->iov,
> +		.msg_flags = MSG_DONTWAIT,
> +	};
> +	size_t len, total_len = 0;
> +	int err, wmem;
> +	size_t hdr_size;
> +	struct socket *sock = rcu_dereference(vq->private_data);
> +	if (!sock)
> +		return;
> +
> +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> +	if (wmem >= sock->sk->sk_sndbuf)
> +		return;
> +
> +	use_mm(net->dev.mm);

I haven't gone over all this code in detail, but that isolated reference count
use looks suspicious. What prevents the mm from going away before
you increment, if it's not the current one?

-Andi 

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
