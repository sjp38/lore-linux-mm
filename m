Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F32A6B0055
	for <linux-mm@kvack.org>; Sun, 27 Sep 2009 03:45:14 -0400 (EDT)
Date: Sun, 27 Sep 2009 09:43:03 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090927074302.GA3690@redhat.com>
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090925170158.GA16014@ovro.caltech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090925170158.GA16014@ovro.caltech.edu>
Sender: owner-linux-mm@kvack.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Fri, Sep 25, 2009 at 10:01:58AM -0700, Ira W. Snyder wrote:
> > +	case VHOST_SET_VRING_KICK:
> > +		r = copy_from_user(&f, argp, sizeof f);
> > +		if (r < 0)
> > +			break;
> > +		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
> > +		if (IS_ERR(eventfp))
> > +			return PTR_ERR(eventfp);
> > +		if (eventfp != vq->kick) {
> > +			pollstop = filep = vq->kick;
> > +			pollstart = vq->kick = eventfp;
> > +		} else
> > +			filep = eventfp;
> > +		break;
> > +	case VHOST_SET_VRING_CALL:
> > +		r = copy_from_user(&f, argp, sizeof f);
> > +		if (r < 0)
> > +			break;
> > +		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
> > +		if (IS_ERR(eventfp))
> > +			return PTR_ERR(eventfp);
> > +		if (eventfp != vq->call) {
> > +			filep = vq->call;
> > +			ctx = vq->call_ctx;
> > +			vq->call = eventfp;
> > +			vq->call_ctx = eventfp ?
> > +				eventfd_ctx_fileget(eventfp) : NULL;
> > +		} else
> > +			filep = eventfp;
> > +		break;
> > +	case VHOST_SET_VRING_ERR:
> > +		r = copy_from_user(&f, argp, sizeof f);
> > +		if (r < 0)
> > +			break;
> > +		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
> > +		if (IS_ERR(eventfp))
> > +			return PTR_ERR(eventfp);
> > +		if (eventfp != vq->error) {
> > +			filep = vq->error;
> > +			vq->error = eventfp;
> > +			ctx = vq->error_ctx;
> > +			vq->error_ctx = eventfp ?
> > +				eventfd_ctx_fileget(eventfp) : NULL;
> > +		} else
> > +			filep = eventfp;
> > +		break;
> 
> I'm not sure how these eventfd's save a trip to userspace.
> 
> AFAICT, eventfd's cannot be used to signal another part of the kernel,
> they can only be used to wake up userspace.

Yes, they can.  See irqfd code in virt/kvm/eventfd.c.

> In my system, when an IRQ for kick() comes in, I have an eventfd which
> gets signalled to notify userspace. When I want to send a call(), I have
> to use a special ioctl(), just like lguest does.
> 
> Doesn't this mean that for call(), vhost is just going to signal an
> eventfd to wake up userspace, which is then going to call ioctl(), and
> then we're back in kernelspace. Seems like a wasted userspace
> round-trip.
> 
> Or am I mis-reading this code?

Yes. Kernel can poll eventfd and deliver an interrupt directly
without involving userspace.

> PS - you can see my current code at:
> http://www.mmarray.org/~iws/virtio-phys/
> 
> Thanks,
> Ira
> 
> > +	default:
> > +		r = -ENOIOCTLCMD;
> > +	}
> > +
> > +	if (pollstop && vq->handle_kick)
> > +		vhost_poll_stop(&vq->poll);
> > +
> > +	if (ctx)
> > +		eventfd_ctx_put(ctx);
> > +	if (filep)
> > +		fput(filep);
> > +
> > +	if (pollstart && vq->handle_kick)
> > +		vhost_poll_start(&vq->poll, vq->kick);
> > +
> > +	mutex_unlock(&vq->mutex);
> > +
> > +	if (pollstop && vq->handle_kick)
> > +		vhost_poll_flush(&vq->poll);
> > +	return 0;
> > +}
> > +
> > +long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
> > +{
> > +	void __user *argp = (void __user *)arg;
> > +	long r;
> > +
> > +	mutex_lock(&d->mutex);
> > +	/* If you are not the owner, you can become one */
> > +	if (ioctl == VHOST_SET_OWNER) {
> > +		r = vhost_dev_set_owner(d);
> > +		goto done;
> > +	}
> > +
> > +	/* You must be the owner to do anything else */
> > +	r = vhost_dev_check_owner(d);
> > +	if (r)
> > +		goto done;
> > +
> > +	switch (ioctl) {
> > +	case VHOST_SET_MEM_TABLE:
> > +		r = vhost_set_memory(d, argp);
> > +		break;
> > +	default:
> > +		r = vhost_set_vring(d, ioctl, argp);
> > +		break;
> > +	}
> > +done:
> > +	mutex_unlock(&d->mutex);
> > +	return r;
> > +}
> > +
> > +static const struct vhost_memory_region *find_region(struct vhost_memory *mem,
> > +						     __u64 addr, __u32 len)
> > +{
> > +	struct vhost_memory_region *reg;
> > +	int i;
> > +	/* linear search is not brilliant, but we really have on the order of 6
> > +	 * regions in practice */
> > +	for (i = 0; i < mem->nregions; ++i) {
> > +		reg = mem->regions + i;
> > +		if (reg->guest_phys_addr <= addr &&
> > +		    reg->guest_phys_addr + reg->memory_size - 1 >= addr)
> > +			return reg;
> > +	}
> > +	return NULL;
> > +}
> > +
> > +int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
> > +		   struct iovec iov[], int iov_size)
> > +{
> > +	const struct vhost_memory_region *reg;
> > +	struct vhost_memory *mem;
> > +	struct iovec *_iov;
> > +	u64 s = 0;
> > +	int ret = 0;
> > +
> > +	rcu_read_lock();
> > +
> > +	mem = rcu_dereference(dev->memory);
> > +	while ((u64)len > s) {
> > +		u64 size;
> > +		if (ret >= iov_size) {
> > +			ret = -ENOBUFS;
> > +			break;
> > +		}
> > +		reg = find_region(mem, addr, len);
> > +		if (!reg) {
> > +			ret = -EFAULT;
> > +			break;
> > +		}
> > +		_iov = iov + ret;
> > +		size = reg->memory_size - addr + reg->guest_phys_addr;
> > +		_iov->iov_len = min((u64)len, size);
> > +		_iov->iov_base = (void *)
> > +			(reg->userspace_addr + addr - reg->guest_phys_addr);
> > +		s += size;
> > +		addr += size;
> > +		++ret;
> > +	}
> > +
> > +	rcu_read_unlock();
> > +	return ret;
> > +}
> > +
> > +/* Each buffer in the virtqueues is actually a chain of descriptors.  This
> > + * function returns the next descriptor in the chain, or vq->vring.num if we're
> > + * at the end. */
> > +static unsigned next_desc(struct vhost_virtqueue *vq, struct vring_desc *desc)
> > +{
> > +	unsigned int next;
> > +
> > +	/* If this descriptor says it doesn't chain, we're done. */
> > +	if (!(desc->flags & VRING_DESC_F_NEXT))
> > +		return vq->num;
> > +
> > +	/* Check they're not leading us off end of descriptors. */
> > +	next = desc->next;
> > +	/* Make sure compiler knows to grab that: we don't want it changing! */
> > +	/* We will use the result as an index in an array, so most
> > +	 * architectures only need a compiler barrier here. */
> > +	read_barrier_depends();
> > +
> > +	if (next >= vq->num) {
> > +		vq_err(vq, "Desc next is %u > %u", next, vq->num);
> > +		return vq->num;
> > +	}
> > +
> > +	return next;
> > +}
> > +
> > +/* This looks in the virtqueue and for the first available buffer, and converts
> > + * it to an iovec for convenient access.  Since descriptors consist of some
> > + * number of output then some number of input descriptors, it's actually two
> > + * iovecs, but we pack them into one and note how many of each there were.
> > + *
> > + * This function returns the descriptor number found, or vq->num (which
> > + * is never a valid descriptor number) if none was found. */
> > +unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
> > +			   struct iovec iov[],
> > +			   unsigned int *out_num, unsigned int *in_num)
> > +{
> > +	struct vring_desc desc;
> > +	unsigned int i, head;
> > +	u16 last_avail_idx;
> > +	int ret;
> > +
> > +	/* Check it isn't doing very strange things with descriptor numbers. */
> > +	last_avail_idx = vq->last_avail_idx;
> > +	if (get_user(vq->avail_idx, &vq->avail->idx)) {
> > +		vq_err(vq, "Failed to access avail idx at %p\n",
> > +		       &vq->avail->idx);
> > +		return vq->num;
> > +	}
> > +
> > +	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
> > +		vq_err(vq, "Guest moved used index from %u to %u",
> > +		       last_avail_idx, vq->avail_idx);
> > +		return vq->num;
> > +	}
> > +
> > +	/* If there's nothing new since last we looked, return invalid. */
> > +	if (vq->avail_idx == last_avail_idx)
> > +		return vq->num;
> > +
> > +	/* Grab the next descriptor number they're advertising, and increment
> > +	 * the index we've seen. */
> > +	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
> > +		vq_err(vq, "Failed to read head: idx %d address %p\n",
> > +		       last_avail_idx,
> > +		       &vq->avail->ring[last_avail_idx % vq->num]);
> > +		return vq->num;
> > +	}
> > +
> > +	/* If their number is silly, that's an error. */
> > +	if (head >= vq->num) {
> > +		vq_err(vq, "Guest says index %u > %u is available",
> > +		       head, vq->num);
> > +		return vq->num;
> > +	}
> > +
> > +	vq->last_avail_idx++;
> > +
> > +	/* When we start there are none of either input nor output. */
> > +	*out_num = *in_num = 0;
> > +
> > +	i = head;
> > +	do {
> > +		unsigned iov_count = *in_num + *out_num;
> > +		if (copy_from_user(&desc, vq->desc + i, sizeof desc)) {
> > +			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
> > +			       i, vq->desc + i);
> > +			return vq->num;
> > +		}
> > +		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
> > +				     VHOST_NET_MAX_SG - iov_count);
> > +		if (ret < 0) {
> > +			vq_err(vq, "Translation failure %d descriptor idx %d\n",
> > +			       ret, i);
> > +			return vq->num;
> > +		}
> > +		/* If this is an input descriptor, increment that count. */
> > +		if (desc.flags & VRING_DESC_F_WRITE)
> > +			*in_num += ret;
> > +		else {
> > +			/* If it's an output descriptor, they're all supposed
> > +			 * to come before any input descriptors. */
> > +			if (*in_num) {
> > +				vq_err(vq, "Descriptor has out after in: "
> > +				       "idx %d\n", i);
> > +				return vq->num;
> > +			}
> > +			*out_num += ret;
> > +		}
> > +	} while ((i = next_desc(vq, &desc)) != vq->num);
> > +	return head;
> > +}
> > +
> > +/* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
> > +void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> > +{
> > +	vq->last_avail_idx--;
> > +}
> > +
> > +/* After we've used one of their buffers, we tell them about it.  We'll then
> > + * want to send them an interrupt, using vq->call. */
> > +int vhost_add_used(struct vhost_virtqueue *vq,
> > +			  unsigned int head, int len)
> > +{
> > +	struct vring_used_elem *used;
> > +
> > +	/* The virtqueue contains a ring of used buffers.  Get a pointer to the
> > +	 * next entry in that used ring. */
> > +	used = &vq->used->ring[vq->last_used_idx % vq->num];
> > +	if (put_user(head, &used->id)) {
> > +		vq_err(vq, "Failed to write used id");
> > +		return -EFAULT;
> > +	}
> > +	if (put_user(len, &used->len)) {
> > +		vq_err(vq, "Failed to write used len");
> > +		return -EFAULT;
> > +	}
> > +	/* Make sure buffer is written before we update index. */
> > +	wmb();
> > +	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
> > +		vq_err(vq, "Failed to increment used idx");
> > +		return -EFAULT;
> > +	}
> > +	vq->last_used_idx++;
> > +	return 0;
> > +}
> > +
> > +/* This actually sends the interrupt for this virtqueue */
> > +void vhost_trigger_irq(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> > +{
> > +	__u16 flags = 0;
> > +	if (get_user(flags, &vq->avail->flags)) {
> > +		vq_err(vq, "Failed to get flags");
> > +		return;
> > +	}
> > +
> > +	/* If they don't want an interrupt, don't send one, unless empty. */
> > +	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
> > +	    (!vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY) ||
> > +	     vq->avail_idx != vq->last_avail_idx))
> > +		return;
> > +
> > +	/* Send the Guest an interrupt tell them we used something up. */
> > +	if (vq->call_ctx)
> > +		eventfd_signal(vq->call_ctx, 1);
> > +}
> > +
> > +/* And here's the combo meal deal.  Supersize me! */
> > +void vhost_add_used_and_trigger(struct vhost_dev *dev,
> > +				struct vhost_virtqueue *vq,
> > +				unsigned int head, int len)
> > +{
> > +	vhost_add_used(vq, head, len);
> > +	vhost_trigger_irq(dev, vq);
> > +}
> > +
> > +/* OK, now we need to know about added descriptors. */
> > +bool vhost_notify(struct vhost_virtqueue *vq)
> > +{
> > +	int r;
> > +	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
> > +		return false;
> > +	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
> > +	r = put_user(vq->used_flags, &vq->used->flags);
> > +	if (r)
> > +		vq_err(vq, "Failed to disable notification: %d\n", r);
> > +	/* They could have slipped one in as we were doing that: make
> > +	 * sure it's written, tell caller it needs to check again. */
> > +	mb();
> > +	return true;
> > +}
> > +
> > +/* We don't need to be notified again. */
> > +void vhost_no_notify(struct vhost_virtqueue *vq)
> > +{
> > +	int r;
> > +	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
> > +		return;
> > +	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
> > +	r = put_user(vq->used_flags, &vq->used->flags);
> > +	if (r)
> > +		vq_err(vq, "Failed to enable notification: %d\n", r);
> > +}
> > +
> > +int vhost_init(void)
> > +{
> > +	vhost_workqueue = create_workqueue("vhost");
> > +	if (!vhost_workqueue)
> > +		return -ENOMEM;
> > +	return 0;
> > +}
> > +
> > +void vhost_cleanup(void)
> > +{
> > +	destroy_workqueue(vhost_workqueue);
> > +}
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > new file mode 100644
> > index 0000000..8e13d06
> > --- /dev/null
> > +++ b/drivers/vhost/vhost.h
> > @@ -0,0 +1,122 @@
> > +#ifndef _VHOST_H
> > +#define _VHOST_H
> > +
> > +#include <linux/eventfd.h>
> > +#include <linux/vhost.h>
> > +#include <linux/mm.h>
> > +#include <linux/mutex.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/poll.h>
> > +#include <linux/file.h>
> > +#include <linux/skbuff.h>
> > +#include <linux/uio.h>
> > +#include <linux/virtio_config.h>
> > +
> > +struct vhost_device;
> > +
> > +enum {
> > +	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
> > +};
> > +
> > +/* Poll a file (eventfd or socket) */
> > +/* Note: there's nothing vhost specific about this structure. */
> > +struct vhost_poll {
> > +	poll_table                table;
> > +	wait_queue_head_t        *wqh;
> > +	wait_queue_t              wait;
> > +	/* struct which will handle all actual work. */
> > +	struct work_struct        work;
> > +	unsigned long		  mask;
> > +};
> > +
> > +void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> > +		     unsigned long mask);
> > +void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> > +void vhost_poll_stop(struct vhost_poll *poll);
> > +void vhost_poll_flush(struct vhost_poll *poll);
> > +
> > +/* The virtqueue structure describes a queue attached to a device. */
> > +struct vhost_virtqueue {
> > +	struct vhost_dev *dev;
> > +
> > +	/* The actual ring of buffers. */
> > +	struct mutex mutex;
> > +	unsigned int num;
> > +	struct vring_desc __user *desc;
> > +	struct vring_avail __user *avail;
> > +	struct vring_used __user *used;
> > +	struct file *kick;
> > +	struct file *call;
> > +	struct file *error;
> > +	struct eventfd_ctx *call_ctx;
> > +	struct eventfd_ctx *error_ctx;
> > +
> > +	struct vhost_poll poll;
> > +
> > +	/* The routine to call when the Guest pings us, or timeout. */
> > +	work_func_t handle_kick;
> > +
> > +	/* Last available index we saw. */
> > +	u16 last_avail_idx;
> > +
> > +	/* Caches available index value from user. */
> > +	u16 avail_idx;
> > +
> > +	/* Last index we used. */
> > +	u16 last_used_idx;
> > +
> > +	/* Used flags */
> > +	u16 used_flags;
> > +
> > +	struct iovec iov[VHOST_NET_MAX_SG];
> > +	struct iovec hdr[VHOST_NET_MAX_SG];
> > +};
> > +
> > +struct vhost_dev {
> > +	/* Readers use RCU to access memory table pointer.
> > +	 * Writers use mutex below.*/
> > +	struct vhost_memory *memory;
> > +	struct mm_struct *mm;
> > +	struct vhost_virtqueue *vqs;
> > +	int nvqs;
> > +	struct mutex mutex;
> > +	unsigned acked_features;
> > +};
> > +
> > +long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
> > +long vhost_dev_check_owner(struct vhost_dev *);
> > +long vhost_dev_reset_owner(struct vhost_dev *);
> > +void vhost_dev_cleanup(struct vhost_dev *);
> > +long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
> > +
> > +unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
> > +			   struct iovec iov[],
> > +			   unsigned int *out_num, unsigned int *in_num);
> > +void vhost_discard_vq_desc(struct vhost_virtqueue *);
> > +
> > +int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
> > +void vhost_trigger_irq(struct vhost_dev *, struct vhost_virtqueue *);
> > +void vhost_add_used_and_trigger(struct vhost_dev *, struct vhost_virtqueue *,
> > +				unsigned int head, int len);
> > +void vhost_no_notify(struct vhost_virtqueue *);
> > +bool vhost_notify(struct vhost_virtqueue *);
> > +
> > +int vhost_init(void);
> > +void vhost_cleanup(void);
> > +
> > +#define vq_err(vq, fmt, ...) do {                                  \
> > +		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> > +		if ((vq)->error_ctx)                               \
> > +				eventfd_signal((vq)->error_ctx, 1);\
> > +	} while (0)
> > +
> > +enum {
> > +	VHOST_FEATURES = 1 << VIRTIO_F_NOTIFY_ON_EMPTY,
> > +};
> > +
> > +static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
> > +{
> > +	return dev->acked_features & (1 << bit);
> > +}
> > +
> > +#endif
> > diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> > index dec2f18..975df9a 100644
> > --- a/include/linux/Kbuild
> > +++ b/include/linux/Kbuild
> > @@ -360,6 +360,7 @@ unifdef-y += uio.h
> >  unifdef-y += unistd.h
> >  unifdef-y += usbdevice_fs.h
> >  unifdef-y += utsname.h
> > +unifdef-y += vhost.h
> >  unifdef-y += videodev2.h
> >  unifdef-y += videodev.h
> >  unifdef-y += virtio_config.h
> > diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
> > index 0521177..781a8bb 100644
> > --- a/include/linux/miscdevice.h
> > +++ b/include/linux/miscdevice.h
> > @@ -30,6 +30,7 @@
> >  #define HPET_MINOR		228
> >  #define FUSE_MINOR		229
> >  #define KVM_MINOR		232
> > +#define VHOST_NET_MINOR		233
> >  #define MISC_DYNAMIC_MINOR	255
> >  
> >  struct device;
> > diff --git a/include/linux/vhost.h b/include/linux/vhost.h
> > new file mode 100644
> > index 0000000..3f441a9
> > --- /dev/null
> > +++ b/include/linux/vhost.h
> > @@ -0,0 +1,101 @@
> > +#ifndef _LINUX_VHOST_H
> > +#define _LINUX_VHOST_H
> > +/* Userspace interface for in-kernel virtio accelerators. */
> > +
> > +/* vhost is used to reduce the number of system calls involved in virtio.
> > + *
> > + * Existing virtio net code is used in the guest without modification.
> > + *
> > + * This header includes interface used by userspace hypervisor for
> > + * device configuration.
> > + */
> > +
> > +#include <linux/types.h>
> > +#include <linux/compiler.h>
> > +#include <linux/ioctl.h>
> > +#include <linux/virtio_config.h>
> > +#include <linux/virtio_ring.h>
> > +
> > +struct vhost_vring_state {
> > +	unsigned int index;
> > +	unsigned int num;
> > +};
> > +
> > +struct vhost_vring_file {
> > +	unsigned int index;
> > +	int fd;
> > +};
> > +
> > +struct vhost_vring_addr {
> > +	unsigned int index;
> > +	unsigned int padding;
> > +	__u64 user_addr;
> > +};
> > +
> > +struct vhost_memory_region {
> > +	__u64 guest_phys_addr;
> > +	__u64 memory_size; /* bytes */
> > +	__u64 userspace_addr;
> > +	__u64 padding; /* read/write protection? */
> > +};
> > +
> > +struct vhost_memory {
> > +	__u32 nregions;
> > +	__u32 padding;
> > +	struct vhost_memory_region regions[0];
> > +};
> > +
> > +/* ioctls */
> > +
> > +#define VHOST_VIRTIO 0xAF
> > +
> > +/* Features bitmask for forward compatibility.  Transport bits are used for
> > + * vhost specific features. */
> > +#define VHOST_GET_FEATURES	_IOR(VHOST_VIRTIO, 0x00, __u64)
> > +#define VHOST_ACK_FEATURES	_IOW(VHOST_VIRTIO, 0x00, __u64)
> > +
> > +/* Set current process as the (exclusive) owner of this file descriptor.  This
> > + * must be called before any other vhost command.  Further calls to
> > + * VHOST_OWNER_SET fail until VHOST_OWNER_RESET is called. */
> > +#define VHOST_SET_OWNER _IO(VHOST_VIRTIO, 0x01)
> > +/* Give up ownership, and reset the device to default values.
> > + * Allows subsequent call to VHOST_OWNER_SET to succeed. */
> > +#define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
> > +
> > +/* Set up/modify memory layout */
> > +#define VHOST_SET_MEM_TABLE	_IOW(VHOST_VIRTIO, 0x03, struct vhost_memory)
> > +
> > +/* Ring setup. These parameters can not be modified while ring is running
> > + * (bound to a device). */
> > +/* Set number of descriptors in ring */
> > +#define VHOST_SET_VRING_NUM _IOW(VHOST_VIRTIO, 0x10, struct vhost_vring_state)
> > +/* Start of array of descriptors (virtually contiguous) */
> > +#define VHOST_SET_VRING_DESC _IOW(VHOST_VIRTIO, 0x11, struct vhost_vring_addr)
> > +/* Used structure address */
> > +#define VHOST_SET_VRING_USED _IOW(VHOST_VIRTIO, 0x12, struct vhost_vring_addr)
> > +/* Available structure address */
> > +#define VHOST_SET_VRING_AVAIL _IOW(VHOST_VIRTIO, 0x13, struct vhost_vring_addr)
> > +/* Base value where queue looks for available descriptors */
> > +#define VHOST_SET_VRING_BASE _IOW(VHOST_VIRTIO, 0x14, struct vhost_vring_state)
> > +/* Get accessor: reads index, writes value in num */
> > +#define VHOST_GET_VRING_BASE _IOWR(VHOST_VIRTIO, 0x14, struct vhost_vring_state)
> > +
> > +/* The following ioctls use eventfd file descriptors to signal and poll
> > + * for events. */
> > +
> > +/* Set eventfd to poll for added buffers */
> > +#define VHOST_SET_VRING_KICK _IOW(VHOST_VIRTIO, 0x20, struct vhost_vring_file)
> > +/* Set eventfd to signal when buffers have beed used */
> > +#define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vring_file)
> > +/* Set eventfd to signal an error */
> > +#define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
> > +
> > +/* VHOST_NET specific defines */
> > +
> > +/* Attach virtio net device to a raw socket. The socket must be already
> > + * bound to an ethernet device, this device will be used for transmit.
> > + * Pass -1 to unbind from the socket and the transmit device.
> > + * This can be used to stop the device (e.g. for migration). */
> > +#define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, int)
> > +
> > +#endif
> > -- 
> > 1.6.2.5
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
