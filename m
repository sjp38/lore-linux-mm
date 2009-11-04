Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 000596B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 07:12:58 -0500 (EST)
Date: Wed, 4 Nov 2009 14:10:09 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091104121009.GF8398@redhat.com>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <878wema6o0.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878wema6o0.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 12:08:47PM +0100, Andi Kleen wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> Haven't really read the whole thing, just noticed something at a glance.
> 
> > +/* Expects to be always run from workqueue - which acts as
> > + * read-size critical section for our kind of RCU. */
> > +static void handle_tx(struct vhost_net *net)
> > +{
> > +	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> > +	unsigned head, out, in, s;
> > +	struct msghdr msg = {
> > +		.msg_name = NULL,
> > +		.msg_namelen = 0,
> > +		.msg_control = NULL,
> > +		.msg_controllen = 0,
> > +		.msg_iov = vq->iov,
> > +		.msg_flags = MSG_DONTWAIT,
> > +	};
> > +	size_t len, total_len = 0;
> > +	int err, wmem;
> > +	size_t hdr_size;
> > +	struct socket *sock = rcu_dereference(vq->private_data);
> > +	if (!sock)
> > +		return;
> > +
> > +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> > +	if (wmem >= sock->sk->sk_sndbuf)
> > +		return;
> > +
> > +	use_mm(net->dev.mm);
> 
> I haven't gone over all this code in detail, but that isolated reference count
> use looks suspicious. What prevents the mm from going away before
> you increment, if it's not the current one?

We take a reference to it before we start any virtqueues,
and stop all virtqueues before we drop the reference:
/* Caller should have device mutex */
static long vhost_dev_set_owner(struct vhost_dev *dev)
{
        /* Is there an owner already? */
        if (dev->mm)
                return -EBUSY;
        /* No owner, become one */
        dev->mm = get_task_mm(current);
        return 0;
}

And 
vhost_dev_cleanup:
....

        if (dev->mm)
                mmput(dev->mm);
        dev->mm = NULL;
}


Fine?

> -Andi 
> 
> -- 
> ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
