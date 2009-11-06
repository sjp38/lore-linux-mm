Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA376B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 23:59:23 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv8 3/3] vhost_net: a kernel-level virtio server
Date: Fri, 6 Nov 2009 15:29:17 +1030
References: <cover.1257349249.git.mst@redhat.com> <20091104155724.GD32673@redhat.com>
In-Reply-To: <20091104155724.GD32673@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911061529.17500.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 02:27:24 am Michael S. Tsirkin wrote:
> What it is: vhost net is a character device that can be used to reduce
> the number of system calls involved in virtio networking.

Hi Michael,

   Now everyone else has finally kicked all the tires and it seems to pass,
I've done a fairly complete review.  Generally, it's really nice; just one
bug and a few minor suggestions for polishing.

> +/* Caller must have TX VQ lock */
> +static void tx_poll_stop(struct vhost_net *net)
> +{
> +	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> +		return;

likely?  Really?

> +	for (;;) {
> +		head = vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in,
> +					 NULL, NULL);

Danger!  You need an arg to vhost_get_vq_desc to tell it the max desc size
you can handle.  Otherwise, it's only limited by ring size, and a malicious
guest can overflow you here, and below:

> +		/* Skip header. TODO: support TSO. */
> +		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
...
> +
> +	use_mm(net->dev.mm);
> +	mutex_lock(&vq->mutex);
> +	vhost_no_notify(vq);

I prefer a name like "vhost_disable_notify()".

> +		/* OK, now we need to know about added descriptors. */
> +		if (head == vq->num && vhost_notify(vq))
> +			/* They could have slipped one in as we were doing that:
> +			 * check again. */
> +			continue;
> +		/* Nothing new?  Wait for eventfd to tell us they refilled. */
> +		if (head == vq->num)
> +			break;
> +		/* We don't need to be notified again. */
> +		vhost_no_notify(vq);

Similarly, vhost_enable_notify.  This one is particularly misleading since
it doesn't actually notify anything!

In particular, this code would be neater as:

	if (head == vq->num) {
		if (vhost_enable_notify(vq)) {
			/* Try again, they could have slipped one in. */
			continue;
		}
		/* Nothing more to do. */
		break;
	}
	vhost_disable_notify(vq);

Now, AFAICT vhost_notify()/enable_notify() would be better rewritten to
return true only when there's more pending.  Saves a loop around here most
of the time.  Also, the vhost_no_notify/vhost_disable_notify() can be moved
out of the loop entirely.  (It could be under an if (unlikely(enabled)), not
sure if it's worth it).

> +		len = err;
> +		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_size);

That unsigned char * arg to memcpy_toiovec is annoying.  A patch might be
nice, separate from this effort.

> +static int vhost_net_open(struct inode *inode, struct file *f)
> +{
> +	struct vhost_net *n = kzalloc(sizeof *n, GFP_KERNEL);
> +	int r;
> +	if (!n)
> +		return -ENOMEM;
> +	f->private_data = n;
> +	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
> +	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;

I have a personal dislike of calloc for structures.  In userspace, it's
because valgrind can't spot uninitialized fields.  These days a similar
argument applies in the kernel, because we have KMEMCHECK now.  If someone
adds a field to the struct and forgets to initialize it, we can spot it.

> +static void vhost_net_enable_vq(struct vhost_net *n, int index)
> +{
> +	struct socket *sock = n->vqs[index].private_data;

OK, I can't help but this that presenting the vqs as an array doesn't buy
us very much.  Esp. if you change vhost_dev_init to take a NULL-terminated
varargs.  I think readability would improve.  It means passing a vq around
rather than an index.

Not completely sure it'll be a win tho.

> +static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
> +{
> +	struct socket *sock, *oldsock = NULL;
...
> +	sock = get_socket(fd);
> +	if (IS_ERR(sock)) {
> +		r = PTR_ERR(sock);
> +		goto done;
> +	}
> +
> +	/* start polling new socket */
> +	oldsock = vq->private_data;
...
> +done:
> +	mutex_unlock(&n->dev.mutex);
> +	if (oldsock) {
> +		vhost_net_flush_vq(n, index);
> +		fput(oldsock->file);

I dislike this style; I prefer multiple different goto points, one for when
oldsock is set, and one for when it's not.

That way, gcc warns us about uninitialized variables if we get it wrong.

> +static long vhost_net_reset_owner(struct vhost_net *n)
> +{
> +	struct socket *tx_sock = NULL;
> +	struct socket *rx_sock = NULL;
> +	long r;

This should be called "err", since that's what it is.

> +static void vhost_net_set_features(struct vhost_net *n, u64 features)
> +{
> +	size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> +		sizeof(struct virtio_net_hdr) : 0;
> +	int i;
> +	mutex_lock(&n->dev.mutex);
> +	n->dev.acked_features = features;

Why is this called "acked_features"?  Not just "features"?  I expected
to see code which exposed these back to userspace, and didn't.

> +	case VHOST_GET_FEATURES:
> +		features = VHOST_FEATURES;
> +		return put_user(features, featurep);
> +	case VHOST_ACK_FEATURES:
> +		r = get_user(features, featurep);
> +		/* No features for now */
> +		if (r < 0)
> +			return r;
> +		if (features & ~VHOST_FEATURES)
> +			return -EOPNOTSUPP;
> +		vhost_net_set_features(n, features);

OK, from the userspace POV it's "get features" then "ack features".  But
I think "VHOST_SET_FEATURES" is more consistent, despite this usage.

> +	switch (ioctl) {
> +	case VHOST_SET_VRING_NUM:

I haven't looked at your userspace implementation, but does a generic
VHOST_SET_VRING_STATE & VHOST_GET_VRING_STATE with a struct make more
sense?  It'd be simpler here, but not sure if it'd be simpler to use?

(Not the fd-setting ioctls of course)

> +	case VHOST_SET_VRING_LOG:
> +		r = copy_from_user(&a, argp, sizeof a);
> +		if (r < 0)
> +			break;
> +		if (a.padding) {
> +			r = -EOPNOTSUPP;
> +			break;
> +		}
> +		if (a.user_addr == VHOST_VRING_LOG_DISABLE) {
> +			vq->log_used = false;
> +			break;
> +		}
> +		if (a.user_addr & (sizeof *vq->used->ring - 1)) {
> +			r = -EINVAL;
> +			break;
> +		}
> +		vq->log_used = true;
> +		vq->log_addr = a.user_addr;
> +		break;

For future reference, this is *exactly* the kind of thing which would have
been nice as a followup patch.  Easy to separate, easy to review, not critical
to the core.

> +/* TODO: This is really inefficient.  We need something like get_user()
> + * (instruction directly accesses the data, with an exception table entry
> + * returning -EFAULT). See Documentation/x86/exception-tables.txt.
> + */
> +static int set_bit_to_user(int nr, void __user *addr)
> +{

I guess we won't be dealing with many contiguous pages, otherwise we could
get a cheap speedup making this set_bits_to_user(int nr, int num_bits...).

> +/* Each buffer in the virtqueues is actually a chain of descriptors.  This
> + * function returns the next descriptor in the chain,
> + * or -1 if we're at the end. */
> +static unsigned next_desc(struct vring_desc *desc)
> +{
> +	unsigned int next;
> +
> +	/* If this descriptor says it doesn't chain, we're done. */
> +	if (!(desc->flags & VRING_DESC_F_NEXT))
> +		return -1;

Hmm, prefer s/-1/-1U/ in comment, here, and below.  Clarifies a bit.

> +/* After we've used one of their buffers, we tell them about it.  We'll then
> + * want to send them an interrupt, using vq->call. */

This comment has too much cut & paste:
	... want to notify the guest, using the eventfd */

> +/* This actually sends the interrupt for this virtqueue */
> +void vhost_trigger_irq(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> +{

Rename vhost_notify_eventfd() or something, and fix comments?

> +enum {
> +	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,

+2?  Believable, but is it correct?

> +/* Poll a file (eventfd or socket) */
> +/* Note: there's nothing vhost specific about this structure. */
> +struct vhost_poll {

This comment really helped while reading the code.  Kudos!

Thanks!
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
