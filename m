Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 977D96B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 01:17:37 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv8 3/3] vhost_net: a kernel-level virtio server
Date: Mon, 9 Nov 2009 16:47:29 +1030
References: <cover.1257349249.git.mst@redhat.com> <200911061529.17500.rusty@rustcorp.com.au> <20091108113516.GA19016@redhat.com>
In-Reply-To: <20091108113516.GA19016@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911091647.29655.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 8 Nov 2009 10:05:16 pm Michael S. Tsirkin wrote:
> On Fri, Nov 06, 2009 at 03:29:17PM +1030, Rusty Russell wrote:
> > > +/* Caller must have TX VQ lock */
> > > +static void tx_poll_stop(struct vhost_net *net)
> > > +{
> > > +	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> > > +		return;
> > 
> > likely?  Really?
> 
> Hmm ... yes. tx poll stop is called on each packet (as long as we do not
> fill up 1/2 backend queue), the first call will stop polling
> the rest checks state and does nothing.
> 
> This is because we normally do not care when the message has left the
> queue in backend device: we tell backend to send it and forget. We only
> start polling when backend tx queue fills up.

OK, good.

> > > +static void vhost_net_set_features(struct vhost_net *n, u64 features)
> > > +{
> > > +	size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> > > +		sizeof(struct virtio_net_hdr) : 0;
> > > +	int i;
> > > +	mutex_lock(&n->dev.mutex);
> > > +	n->dev.acked_features = features;
> > 
> > Why is this called "acked_features"?  Not just "features"?  I expected
> > to see code which exposed these back to userspace, and didn't.
> 
> Not sure how do you mean. Userspace sets them, why
> does it want to get them exposed back?

There's something about the 'acked' which rubs me the wrong way.
"enabled_features" is perhaps a better term than "acked_features"; "acked"
seems more a user point-of-view, "enabled" seems more driver POV?

set_features matches your ioctl names, but it sounds like a fn name :(

It's marginal.  And 'features' is shorter than both.

> > > +	switch (ioctl) {
> > > +	case VHOST_SET_VRING_NUM:
> > 
> > I haven't looked at your userspace implementation, but does a generic
> > VHOST_SET_VRING_STATE & VHOST_GET_VRING_STATE with a struct make more
> > sense?  It'd be simpler here,
> 
> Not by much though, right?
> 
> > but not sure if it'd be simpler to use?
> 
> The problem is with VHOST_SET_VRING_BASE as well. I want it to be
> separate because I want to make it possible to relocate e.g. used ring
> to another address while ring is running. This would be a good debugging
> tool (you look at kernel's used ring, check descriptor, then update
> guest's used ring) and also possibly an extra way to do migration.  And
> it's nicer to have vring size separate as well, because it is
> initialized by host and never changed, right?

Actually, this looks wrong to me:

+	case VHOST_SET_VRING_BASE:
...
+		vq->avail_idx = vq->last_avail_idx = s.num;

The last_avail_idx is part of the state of the driver.  It needs to be saved
and restored over susp/resume.  The only reason it's not in the ring itself
is because I figured the other side doesn't need to see it (which is true, but
missed debugging opportunities as well as man-in-the-middle issues like this
one).  I had a patch which put this field at the end of the ring, I might
resurrect it to avoid this problem.  This is backwards compatible with all
implementations.  See patch at end.

I would drop avail_idx altogether: get_user is basically free, and simplifies
a lot.  As most state is in the ring, all you need is an ioctl to save/restore
the last_avail_idx.

> We could merge DESC, AVAIL, USED, and it will reduce the amount of code
> in userspace. With both base, size and fds separate, it seemed a bit
> more symmetrical to have desc/avail/used separate as well.
> What's your opinion?

Well, DESC, AVAIL, and USED could easily be turned into SET/GET_LAYOUT.

> > For future reference, this is *exactly* the kind of thing which would have
> > been nice as a followup patch.  Easy to separate, easy to review, not critical
> > to the core.
> 
> Yes. It's not too late to split it out though: should I do it yet?

Only if you're feeling enthused.  It's lightly reviewed now.

Cheers,
Rusty.

virtio: put last_used and last_avail index into ring itself.

Generally, the other end of the virtio ring doesn't need to see where
you're up to in consuming the ring.  However, to completely understand
what's going on from the outside, this information must be exposed.
For example, if you want to save and restore a virtio_ring, but you're
not the consumer because the kernel is using it directly.

Fortunately, we have room to expand: the ring is always a whole number
of pages and there's hundreds of bytes of padding after the avail ring
and the used ring, whatever the number of descriptors (which must be a
power of 2).

We add a feature bit so the guest can tell the host that it's writing
out the current value there, if it wants to use that.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c |   23 +++++++++++++++--------
 include/linux/virtio_ring.h  |   12 +++++++++++-
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -71,9 +71,6 @@ struct vring_virtqueue
 	/* Number we've added since last sync. */
 	unsigned int num_added;
 
-	/* Last used index we've seen. */
-	u16 last_used_idx;
-
 	/* How to notify other side. FIXME: commonalize hcalls! */
 	void (*notify)(struct virtqueue *vq);
 
@@ -278,12 +275,13 @@ static void detach_buf(struct vring_virt
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vq->last_used_idx != vq->vring.used->idx;
+	return vring_last_used(&vq->vring) != vq->vring.used->idx;
 }
 
 static void *vring_get_buf(struct virtqueue *_vq, unsigned int *len)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
+	struct vring_used_elem *u;
 	void *ret;
 	unsigned int i;
 
@@ -300,8 +298,11 @@ static void *vring_get_buf(struct virtqu
 		return NULL;
 	}
 
-	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
-	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
+	u = &vq->vring.used->ring[vring_last_used(&vq->vring) % vq->vring.num];
+	i = u->id;
+	*len = u->len;
+	/* Make sure we don't reload i after doing checks. */
+	rmb();
 
 	if (unlikely(i >= vq->vring.num)) {
 		BAD_RING(vq, "id %u out of range\n", i);
@@ -315,7 +316,8 @@ static void *vring_get_buf(struct virtqu
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	vq->last_used_idx++;
+	vring_last_used(&vq->vring)++;
+
 	END_USE(vq);
 	return ret;
 }
@@ -402,7 +404,6 @@ struct virtqueue *vring_new_virtqueue(un
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
-	vq->last_used_idx = 0;
 	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
@@ -413,6 +414,10 @@ struct virtqueue *vring_new_virtqueue(un
 
 	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
 
+	/* We publish indices whether they offer it or not: if not, it's junk
+	 * space anyway.  But calling this acknowledges the feature. */
+	virtio_has_feature(vdev, VIRTIO_RING_F_PUBLISH_INDICES);
+
 	/* No callback?  Tell other side not to bother us. */
 	if (!callback)
 		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
@@ -443,6 +448,8 @@ void vring_transport_features(struct vir
 		switch (i) {
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
+		case VIRTIO_RING_F_PUBLISH_INDICES:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -29,6 +29,9 @@
 /* We support indirect buffer descriptors */
 #define VIRTIO_RING_F_INDIRECT_DESC	28
 
+/* We publish our last-seen used index at the end of the avail ring. */
+#define VIRTIO_RING_F_PUBLISH_INDICES	29
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc
 {
@@ -87,6 +90,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 last_used_idx;
  *
  *	// Padding to the next align boundary.
  *	char pad[];
@@ -95,6 +99,7 @@ struct vring {
  *	__u16 used_flags;
  *	__u16 used_idx;
  *	struct vring_used_elem used[num];
+ *	__u16 last_avail_idx;
  * };
  */
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
@@ -111,9 +116,14 @@ static inline unsigned vring_size(unsign
 {
 	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
 		 + align - 1) & ~(align - 1))
-		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
+		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num + 2;
 }
 
+/* We publish the last-seen used index at the end of the available ring, and
+ * vice-versa.  These are at the end for backwards compatibility. */
+#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
+#define vring_last_avail(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
+
 #ifdef __KERNEL__
 #include <linux/irqreturn.h>
 struct virtio_device;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
