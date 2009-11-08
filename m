Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 079AF6B007E
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 06:38:11 -0500 (EST)
Date: Sun, 8 Nov 2009 13:35:16 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv8 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091108113516.GA19016@redhat.com>
References: <cover.1257349249.git.mst@redhat.com> <20091104155724.GD32673@redhat.com> <200911061529.17500.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911061529.17500.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 03:29:17PM +1030, Rusty Russell wrote:
> On Thu, 5 Nov 2009 02:27:24 am Michael S. Tsirkin wrote:
> > What it is: vhost net is a character device that can be used to reduce
> > the number of system calls involved in virtio networking.
> 
> Hi Michael,
> 
>    Now everyone else has finally kicked all the tires and it seems to pass,
> I've done a fairly complete review.  Generally, it's really nice; just one
> bug and a few minor suggestions for polishing.

Thanks for the review! I'll add more polishing and repost.
Answers to some questions below.

> > +/* Caller must have TX VQ lock */
> > +static void tx_poll_stop(struct vhost_net *net)
> > +{
> > +	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> > +		return;
> 
> likely?  Really?

Hmm ... yes. tx poll stop is called on each packet (as long as we do not
fill up 1/2 backend queue), the first call will stop polling
the rest checks state and does nothing.

This is because we normally do not care when the message has left the
queue in backend device: we tell backend to send it and forget. We only
start polling when backend tx queue fills up.

Makes sense?

> > +	for (;;) {
> > +		head = vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in,
> > +					 NULL, NULL);
> 
> Danger!  You need an arg to vhost_get_vq_desc to tell it the max desc size
> you can handle.  Otherwise, it's only limited by ring size, and a malicious
> guest can overflow you here, and below:

In fact, I think this is not a bug.  This happens to work correctly
(even with malicious guests) because vhost_get_vq_desc is hard-coded to
check VHOST_NET_MAX_SG, so in fact no overflow is possible.  I agree
that it's mich nicer to pass iovec size to vhost_get_vq_desc.

> 
> > +		/* Skip header. TODO: support TSO. */
> > +		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
> ...
> > +
> > +	use_mm(net->dev.mm);
> > +	mutex_lock(&vq->mutex);
> > +	vhost_no_notify(vq);
> 
> I prefer a name like "vhost_disable_notify()".

Good idea.

> > +		/* OK, now we need to know about added descriptors. */
> > +		if (head == vq->num && vhost_notify(vq))
> > +			/* They could have slipped one in as we were doing that:
> > +			 * check again. */
> > +			continue;
> > +		/* Nothing new?  Wait for eventfd to tell us they refilled. */
> > +		if (head == vq->num)
> > +			break;
> > +		/* We don't need to be notified again. */
> > +		vhost_no_notify(vq);
> 
> Similarly, vhost_enable_notify.  This one is particularly misleading since
> it doesn't actually notify anything!

Good idea.


> 
> In particular, this code would be neater as:
> 
> 	if (head == vq->num) {
> 		if (vhost_enable_notify(vq)) {
> 			/* Try again, they could have slipped one in. */
> 			continue;
> 		}
> 		/* Nothing more to do. */
> 		break;
> 	}
> 	vhost_disable_notify(vq);
> 
> Now, AFAICT vhost_notify()/enable_notify() would be better rewritten to
> return true only when there's more pending.  Saves a loop around here most
> of the time.

OKay, I'll look into this. It kind of annoys me that we would do
get_user for the same value twice: once in vhost_enable_notify and once
in vhost_get_vq_desc.  OTOH, all the loop does is call vhost_get_vq_desc
again.

>  Also, the vhost_no_notify/vhost_disable_notify() can be moved
> out of the loop entirely.

I don't think it can, if we enabled notification and then see more
descriptors in queue, we want to disable notification again. But it can
be
>  (It could be under an if (unlikely(enabled)), not
> sure if it's worth it).

 		if (unlikely(vhost_enable_notify(vq))) {
 			/* Try again, they have slipped one in. */
 			vhost_disable_notify(vq);
 			continue;
 		}

> 
> > +		len = err;
> > +		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_size);
> 
> That unsigned char * arg to memcpy_toiovec is annoying.  A patch might be
> nice, separate from this effort.

Sounds good.

> > +static int vhost_net_open(struct inode *inode, struct file *f)
> > +{
> > +	struct vhost_net *n = kzalloc(sizeof *n, GFP_KERNEL);
> > +	int r;
> > +	if (!n)
> > +		return -ENOMEM;
> > +	f->private_data = n;
> > +	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
> > +	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
> 
> I have a personal dislike of calloc for structures.

You mean zalloc?

> In userspace, it's because valgrind can't spot uninitialized fields.
> These days a similar argument applies in the kernel, because we have
> KMEMCHECK now.  If someone adds a field to the struct and forgets to
> initialize it, we can spot it.

OK.

> > +static void vhost_net_enable_vq(struct vhost_net *n, int index)
> > +{
> > +	struct socket *sock = n->vqs[index].private_data;
> 
> OK, I can't help but this that presenting the vqs as an array doesn't buy
> us very much.  Esp. if you change vhost_dev_init to take a NULL-terminated
> varargs.  I think readability would improve.  It means passing a vq around
> rather than an index.
> 
> Not completely sure it'll be a win tho.

Hmm, varargs sounds a bit complex. But I agree readability for
vhost_net_enable_vq and friends would benefit from passing a vq around
rather than an index.  I'll try it out and do it if it's a win.

> > +static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
> > +{
> > +	struct socket *sock, *oldsock = NULL;
> ...
> > +	sock = get_socket(fd);
> > +	if (IS_ERR(sock)) {
> > +		r = PTR_ERR(sock);
> > +		goto done;
> > +	}
> > +
> > +	/* start polling new socket */
> > +	oldsock = vq->private_data;
> ...
> > +done:
> > +	mutex_unlock(&n->dev.mutex);
> > +	if (oldsock) {
> > +		vhost_net_flush_vq(n, index);
> > +		fput(oldsock->file);
> 
> I dislike this style; I prefer multiple different goto points, one for when
> oldsock is set, and one for when it's not.
> 
> That way, gcc warns us about uninitialized variables if we get it wrong.

OK.

> > +static long vhost_net_reset_owner(struct vhost_net *n)
> > +{
> > +	struct socket *tx_sock = NULL;
> > +	struct socket *rx_sock = NULL;
> > +	long r;
> 
> This should be called "err", since that's what it is.

OK.

> > +static void vhost_net_set_features(struct vhost_net *n, u64 features)
> > +{
> > +	size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> > +		sizeof(struct virtio_net_hdr) : 0;
> > +	int i;
> > +	mutex_lock(&n->dev.mutex);
> > +	n->dev.acked_features = features;
> 
> Why is this called "acked_features"?  Not just "features"?  I expected
> to see code which exposed these back to userspace, and didn't.

Not sure how do you mean. Userspace sets them, why
does it want to get them exposed back?

> > +	case VHOST_GET_FEATURES:
> > +		features = VHOST_FEATURES;
> > +		return put_user(features, featurep);
> > +	case VHOST_ACK_FEATURES:
> > +		r = get_user(features, featurep);
> > +		/* No features for now */
> > +		if (r < 0)
> > +			return r;
> > +		if (features & ~VHOST_FEATURES)
> > +			return -EOPNOTSUPP;
> > +		vhost_net_set_features(n, features);
> 
> OK, from the userspace POV it's "get features" then "ack features".  But
> I think "VHOST_SET_FEATURES" is more consistent, despite this usage.

OK.

> > +	switch (ioctl) {
> > +	case VHOST_SET_VRING_NUM:
> 
> I haven't looked at your userspace implementation, but does a generic
> VHOST_SET_VRING_STATE & VHOST_GET_VRING_STATE with a struct make more
> sense?  It'd be simpler here,

Not by much though, right?

> but not sure if it'd be simpler to use?

The problem is with VHOST_SET_VRING_BASE as well. I want it to be
separate because I want to make it possible to relocate e.g. used ring
to another address while ring is running. This would be a good debugging
tool (you look at kernel's used ring, check descriptor, then update
guest's used ring) and also possibly an extra way to do migration.  And
it's nicer to have vring size separate as well, because it is
initialized by host and never changed, right?

We could merge DESC, AVAIL, USED, and it will reduce the amount of code
in userspace. With both base, size and fds separate, it seemed a bit
more symmetrical to have desc/avail/used separate as well.
What's your opinion?


> (Not the fd-setting ioctls of course)
> 
> > +	case VHOST_SET_VRING_LOG:
> > +		r = copy_from_user(&a, argp, sizeof a);
> > +		if (r < 0)
> > +			break;
> > +		if (a.padding) {
> > +			r = -EOPNOTSUPP;
> > +			break;
> > +		}
> > +		if (a.user_addr == VHOST_VRING_LOG_DISABLE) {
> > +			vq->log_used = false;
> > +			break;
> > +		}
> > +		if (a.user_addr & (sizeof *vq->used->ring - 1)) {
> > +			r = -EINVAL;
> > +			break;
> > +		}
> > +		vq->log_used = true;
> > +		vq->log_addr = a.user_addr;
> > +		break;
> 
> For future reference, this is *exactly* the kind of thing which would have
> been nice as a followup patch.  Easy to separate, easy to review, not critical
> to the core.

Yes. It's not too late to split it out though: should I do it yet?

> > +/* TODO: This is really inefficient.  We need something like get_user()
> > + * (instruction directly accesses the data, with an exception table entry
> > + * returning -EFAULT). See Documentation/x86/exception-tables.txt.
> > + */
> > +static int set_bit_to_user(int nr, void __user *addr)
> > +{
> 
> I guess we won't be dealing with many contiguous pages, otherwise we could
> get a cheap speedup making this set_bits_to_user(int nr, int num_bits...).

No idea. Let's keep it as simple as possible for now?

> > +/* Each buffer in the virtqueues is actually a chain of descriptors.  This
> > + * function returns the next descriptor in the chain,
> > + * or -1 if we're at the end. */
> > +static unsigned next_desc(struct vring_desc *desc)
> > +{
> > +	unsigned int next;
> > +
> > +	/* If this descriptor says it doesn't chain, we're done. */
> > +	if (!(desc->flags & VRING_DESC_F_NEXT))
> > +		return -1;
> 
> Hmm, prefer s/-1/-1U/ in comment, here, and below.  Clarifies a bit.

Good idea.

> > +/* After we've used one of their buffers, we tell them about it.  We'll then
> > + * want to send them an interrupt, using vq->call. */
> 
> This comment has too much cut & paste:

I tried to cut and paste as many comments as possible, this
made it easy to audit the code by comparing it with lguest,
and made them much more witty. But yes, this is definitely going
overboard as we do not have vq->call at all :)

> 	... want to notify the guest, using the eventfd */
> 
> > +/* This actually sends the interrupt for this virtqueue */
> > +void vhost_trigger_irq(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> > +{
> 
> Rename vhost_notify_eventfd() or something, and fix comments?

Sounds good. Since I'm renaming vhost_notify to vhost_enable_notify,
this one can just become vhost_notify.

> > +enum {
> > +	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
> 
> +2?  Believable, but is it correct?

+ 1 is for skb head, + 1 is for virtio net header.
I'll add a comment.

> > +/* Poll a file (eventfd or socket) */
> > +/* Note: there's nothing vhost specific about this structure. */
> > +struct vhost_poll {
> 
> This comment really helped while reading the code.  Kudos!
> 
> Thanks!
> Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
