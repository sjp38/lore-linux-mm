Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4496E6B00A9
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:27 -0400 (EDT)
Received: from int-mx06.intmail.prod.int.phx2.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.19])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKGUxP026324
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:30 -0400
Date: Tue, 25 Aug 2009 16:16:35 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090825131634.GA13949@redhat.com>
References: <cover.1250693417.git.mst@redhat.com> <20090819150309.GC4236@redhat.com> <200908252140.41295.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908252140.41295.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

Thanks for the comments, I'll work on them ASAP.
Answers to questions and more comments below.

On Tue, Aug 25, 2009 at 09:40:40PM +0930, Rusty Russell wrote:
> On Thu, 20 Aug 2009 12:33:09 am Michael S. Tsirkin wrote:
> > What it is: vhost net is a character device that can be used to reduce
> > the number of system calls involved in virtio networking.
> > Existing virtio net code is used in the guest without modification.
> 
> ...
> 
> > +config VHOST_NET
> > +	tristate "Host kernel accelerator for virtio net"
> > +	depends on NET && EVENTFD
> > +	---help---
> > +	  This kernel module can be loaded in host kernel to accelerate
> > +	  guest networking with virtio_net. Not to be confused with virtio_net
> > +	  module itself which needs to be loaded in guest kernel.
> > +
> > +	  To compile this driver as a module, choose M here: the module will
> > +	  be called vhost_net.
> 
> Just want to note that the patch explanation and the Kconfig help text are
> exceptional examples of reader-oriented text.  Nice!

High praise indeed from the author of the lguest Quest :).

> > +		/* Sanity check */
> > +		if (vq->iov->iov_len != sizeof(struct virtio_net_hdr)) {
> > +			vq_err(vq, "Unexpected header len for TX: "
> > +			       "%ld expected %zd\n", vq->iov->iov_len,
> > +			       sizeof(struct virtio_net_hdr));
> > +			break;
> > +		}
> 
> OK, this check, which is in the qemu version, is *wrong*.  There should be
> no assumption on sg boundaries.  For example, the guest should be able to
> put the virtio_net_hdr in the front of the skbuf data if there is room.
> 
> You should try to explicitly "consume" sizeof(struct virtio_net_hdr) of the
> iov, and if fail, do this message.  You can skip the out <= 1 test then,
> too.
> 
> Anyway, I really prefer vq->iov[0]. to vq->iov-> here.

I'll fix that. Probably should fix qemu as well.

> > +		/* Sanity check */
> > +		if (vq->iov->iov_len != sizeof(struct virtio_net_hdr)) {
> > +			vq_err(vq, "Unexpected header len for RX: "
> > +			       "%ld expected %zd\n",
> > +			       vq->iov->iov_len, sizeof(struct virtio_net_hdr));
> > +			break;
> 
> Here too.
> 
> > +	u32 __user *featurep = argp;
> > +	int __user *fdp = argp;
> > +	u32 features;
> > +	int fd, r;
> > +	switch (ioctl) {
> > +	case VHOST_NET_SET_SOCKET:
> > +		r = get_user(fd, fdp);
> > +		if (r < 0)
> > +			return r;
> > +		return vhost_net_set_socket(n, fd);
> > +	case VHOST_GET_FEATURES:
> > +		/* No features for now */
> > +		features = 0;
> > +		return put_user(features, featurep);
> 
> We may well get more than 32 feature bits, at least for virtio_net, which will
> force us to do some trickery in virtio_pci.  I'd like to avoid that here,
> though it's kind of ugly.  We'd need VHOST_GET_FEATURES (and ACK) to take a
> struct like:
> 
> 	u32 feature_size;
> 	u32 features[];

Do you feel just making it 64 bit won't be enough?  How about 128 bit?

> > +int vhost_net_init(void)
> 
> static?
> 
> > +void vhost_net_exit(void)
> 
> static?

Good catch.

> > +/* Start polling a file. We add ourselves to file's wait queue. The user must
> > + * keep a reference to a file until after vhost_poll_stop is called. */
> 
> I experienced minor confusion from the comments in this file.  Where you said
> "user" I think "caller".  No biggie though.
> 
> > +	memory->nregions = 2;
> > +	memory->regions[0].guest_phys_addr = 1;
> > +	memory->regions[0].userspace_addr = 1;
> > +	memory->regions[0].memory_size = ~0ULL;
> > +	memory->regions[1].guest_phys_addr = 0;
> > +	memory->regions[1].userspace_addr = 0;
> > +	memory->regions[1].memory_size = 1;
> 
> Not sure I understand why there are two regions to start?

We are trying to cover a whole 2^64 range here.  It's size does not fit
in a single 64 bit length value.  I could special case 0 length to mean
2^64, but decided against it.

> > +	case VHOST_SET_VRING_BASE:
> > +		r = copy_from_user(&s, argp, sizeof s);
> > +		if (r < 0)
> > +			break;
> > +		if (s.num > 0xffff) {
> > +			r = -EINVAL;
> > +			break;
> > +		}
> > +		vq->last_avail_idx = s.num;
> > +		break;
> > +	case VHOST_GET_VRING_BASE:
> > +		s.index = idx;
> > +		s.num = vq->last_avail_idx;
> > +		r = copy_to_user(argp, &s, sizeof s);
> > +		break;
> 
> Ah, this is my fault.  I didn't expose the last_avail_idx in the ring
> because the other side doesn't need it; but without it the ring state is not
> fully observable from outside (no external save / restore!).
> 
> I have a patch which published these indices (we have room), see:
> 	http://ozlabs.org/~rusty/kernel/rr-2009-08-12-1/virtio:ring-publish-indices.patch
> 
> Perhaps we should use that mechanism instead?  We don't actually have to
> offer the feature (we don't care about the guest state), but it's nice as
> documentation.  I've been waiting for an excuse to use that patch.

Good idea and might be handy for optimizations as well, and I
would have used it if it was there.  I'd like to support existing guests
in vhost though, so I think we need to support this ioctl for now.

> > +long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
> > +{
> > +	void __user *argp = (void __user *)arg;
> > +	long r;
> > +
> > +	mutex_lock(&d->mutex);
> > +	if (ioctl == VHOST_SET_OWNER) {
> > +		r = vhost_dev_set_owner(d);
> > +		goto done;
> > +	}
> > +
> > +	r = vhost_dev_check_owner(d);
> 
> You can do a VHOST_SET_OWNER without being the owner?

Only if no one else is the owner.  It has a mutual exclusion
mechanism.

> So really,
> the -EPERM from all the vhost_dev_check_owner() is not a security thing,
> but a "I don't think you mean to do that" thing?

Mostly that.  I started by assuming that an open fd can't be
passed around at all, but talking with management guys here,
they really like being able to open fds and pass them around
through unix domain sockets.

Since using this fd from multiple processes does not work well,
I decided to make this explicit in the interface.  I find it quite
possible that there's no security thing here, but this is just a simpler
model to think about than guessing whether some crash is exploitable or
not.

> If so, a comment above it might help?

Yes.

> > +static const struct vhost_memory_region *find_region(struct vhost_memory *mem,
> > +						     __u64 addr, __u32 len)
> > +{
> > +	struct vhost_memory_region *reg;
> > +	int i;
> > +	/* linear search is not brilliant, but we really have on the order of 6
> > +	 * regions in practice */
> 
> Ah, you actually mean "this code has been carefully cache-optimized for the
> common case" :)
> 
> > +/* FIXME: this does not handle a region that spans multiple
> > + * address/len pairs */
> > +int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
> > +		   struct iovec iov[], int iov_count, int iov_size,
> > +		   unsigned *num)
> > +{
> > +	const struct vhost_memory_region *reg;
> > +	struct vhost_memory *mem;
> > +	struct iovec *_iov;
> > +	u64 s = 0;
> > +	int ret = 0;
> 
> Would this be neater if it returned the num iovecs used?  And offsetting
> iov in the caller, rather than passing iov_count?

iov_size would have to be tweaked instead as well.

> > +	/* If their number is silly, that's a fatal mistake. */
> > +	if (head >= vq->num) {
> > +		vq_err(vq, "Guest says index %u > %u is available",
> > +		       head, vq->num);
> > +		return vq->num;
> > +	}
> 
> Not a fatal mistake in this code/
> 
> > +	vq->inflight++;
> 
> vq->inflight was a brain fart in the old lguest code.  See
> commit ebf9a5a99c1a464afe0b4dfa64416fc8b273bc5c.

I wondered about that. OK.

> Also, see other fixes to the lguest launcher since then which might
> be relevant to this code:
> 	lguest: get more serious about wmb() in example Launcher code
> 	lguest: clean up length-used value in example launcher

I'll go over them, thanks!
I did look over barriers, but this is tricky stuff.

> > +	/* If they don't want an interrupt, don't send one, unless empty. */
> > +	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) && vq->inflight)
> > +		return;
> 
> And I wouldn't support notify on empty at all, TBH.

If I don't, virtio net in guest uses a timer, which might be expensive.
Will need to check what this does.

>  It should
> definitely be conditional on the guest accepting the NOTIFY_ON_EMPTY
> feature.

Good point.

> > +/* The virtqueue structure describes a queue attached to a device. */
> > +struct vhost_virtqueue {
> ...
> > +} ____cacheline_aligned;
> 
> Really?  I'd want to see numbers on this one.  False sharing vs. more cache
> utilization.

I don't yet want to focus on micro optimizations.  What's your guess?
That it's better without? I'll kill it then ...


> > +#define vq_err(vq, fmt, ...) do {                                  \
> > +		printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__);       \
> > +		if ((vq)->error_ctx)                               \
> > +				eventfd_signal((vq)->error_ctx, 1);\
> > +	} while (0)
> 
> Mmm... guests should not be able to create unlimited printks in the host.

Yes, but handy for debugging :)
I guess I'll just make it use pr_debug instead?

> But really, nothing major to object to in here...
> 
> Thanks!
> Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
