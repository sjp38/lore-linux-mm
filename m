Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CE1B16B0291
	for <linux-mm@kvack.org>; Tue,  4 May 2010 14:26:55 -0400 (EDT)
Date: Tue, 4 May 2010 21:22:36 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Message-ID: <20100504182236.GA14141@redhat.com>
References: <cover.1257349249.git.mst@redhat.com> <200911061529.17500.rusty@rustcorp.com.au> <20091108113516.GA19016@redhat.com> <200911091647.29655.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911091647.29655.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

> virtio: put last_used and last_avail index into ring itself.
> 
> Generally, the other end of the virtio ring doesn't need to see where
> you're up to in consuming the ring.  However, to completely understand
> what's going on from the outside, this information must be exposed.
> For example, if you want to save and restore a virtio_ring, but you're
> not the consumer because the kernel is using it directly.
> 
> Fortunately, we have room to expand: the ring is always a whole number
> of pages and there's hundreds of bytes of padding after the avail ring
> and the used ring, whatever the number of descriptors (which must be a
> power of 2).
> 
> We add a feature bit so the guest can tell the host that it's writing
> out the current value there, if it wants to use that.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I've been looking at this patch some more (more on why
later), and I wonder: would it be better to add some
alignment to the last used index address, so that
if we later add more stuff at the tail, it all
fits in a single cache line?

We use a new feature bit anyway, so layout change should not be
a problem.

Since I raised the question of caches: for used ring,
the ring is not aligned to 64 bit, so on CPUs with 64 bit
or larger cache lines, used entries will often cross
cache line boundaries. Am I right and might it
have been better to align ring entries to cache line boundaries?

What do you think?

> ---
>  drivers/virtio/virtio_ring.c |   23 +++++++++++++++--------
>  include/linux/virtio_ring.h  |   12 +++++++++++-
>  2 files changed, 26 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -71,9 +71,6 @@ struct vring_virtqueue
>  	/* Number we've added since last sync. */
>  	unsigned int num_added;
>  
> -	/* Last used index we've seen. */
> -	u16 last_used_idx;
> -
>  	/* How to notify other side. FIXME: commonalize hcalls! */
>  	void (*notify)(struct virtqueue *vq);
>  
> @@ -278,12 +275,13 @@ static void detach_buf(struct vring_virt
>  
>  static inline bool more_used(const struct vring_virtqueue *vq)
>  {
> -	return vq->last_used_idx != vq->vring.used->idx;
> +	return vring_last_used(&vq->vring) != vq->vring.used->idx;
>  }
>  
>  static void *vring_get_buf(struct virtqueue *_vq, unsigned int *len)
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
> +	struct vring_used_elem *u;
>  	void *ret;
>  	unsigned int i;
>  
> @@ -300,8 +298,11 @@ static void *vring_get_buf(struct virtqu
>  		return NULL;
>  	}
>  
> -	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
> -	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
> +	u = &vq->vring.used->ring[vring_last_used(&vq->vring) % vq->vring.num];
> +	i = u->id;
> +	*len = u->len;
> +	/* Make sure we don't reload i after doing checks. */
> +	rmb();
>  
>  	if (unlikely(i >= vq->vring.num)) {
>  		BAD_RING(vq, "id %u out of range\n", i);
> @@ -315,7 +316,8 @@ static void *vring_get_buf(struct virtqu
>  	/* detach_buf clears data, so grab it now. */
>  	ret = vq->data[i];
>  	detach_buf(vq, i);
> -	vq->last_used_idx++;
> +	vring_last_used(&vq->vring)++;
> +
>  	END_USE(vq);
>  	return ret;
>  }
> @@ -402,7 +404,6 @@ struct virtqueue *vring_new_virtqueue(un
>  	vq->vq.name = name;
>  	vq->notify = notify;
>  	vq->broken = false;
> -	vq->last_used_idx = 0;
>  	vq->num_added = 0;
>  	list_add_tail(&vq->vq.list, &vdev->vqs);
>  #ifdef DEBUG
> @@ -413,6 +414,10 @@ struct virtqueue *vring_new_virtqueue(un
>  
>  	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
>  
> +	/* We publish indices whether they offer it or not: if not, it's junk
> +	 * space anyway.  But calling this acknowledges the feature. */
> +	virtio_has_feature(vdev, VIRTIO_RING_F_PUBLISH_INDICES);
> +
>  	/* No callback?  Tell other side not to bother us. */
>  	if (!callback)
>  		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
> @@ -443,6 +448,8 @@ void vring_transport_features(struct vir
>  		switch (i) {
>  		case VIRTIO_RING_F_INDIRECT_DESC:
>  			break;
> +		case VIRTIO_RING_F_PUBLISH_INDICES:
> +			break;
>  		default:
>  			/* We don't understand this bit. */
>  			clear_bit(i, vdev->features);
> diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
> --- a/include/linux/virtio_ring.h
> +++ b/include/linux/virtio_ring.h
> @@ -29,6 +29,9 @@
>  /* We support indirect buffer descriptors */
>  #define VIRTIO_RING_F_INDIRECT_DESC	28
>  
> +/* We publish our last-seen used index at the end of the avail ring. */
> +#define VIRTIO_RING_F_PUBLISH_INDICES	29
> +
>  /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
>  struct vring_desc
>  {
> @@ -87,6 +90,7 @@ struct vring {
>   *	__u16 avail_flags;
>   *	__u16 avail_idx;
>   *	__u16 available[num];
> + *	__u16 last_used_idx;
>   *
>   *	// Padding to the next align boundary.
>   *	char pad[];
> @@ -95,6 +99,7 @@ struct vring {
>   *	__u16 used_flags;
>   *	__u16 used_idx;
>   *	struct vring_used_elem used[num];
> + *	__u16 last_avail_idx;
>   * };
>   */
>  static inline void vring_init(struct vring *vr, unsigned int num, void *p,
> @@ -111,9 +116,14 @@ static inline unsigned vring_size(unsign
>  {
>  	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
>  		 + align - 1) & ~(align - 1))
> -		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
> +		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num + 2;
>  }
>  
> +/* We publish the last-seen used index at the end of the available ring, and
> + * vice-versa.  These are at the end for backwards compatibility. */
> +#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
> +#define vring_last_avail(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
> +
>  #ifdef __KERNEL__
>  #include <linux/irqreturn.h>
>  struct virtio_device;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
