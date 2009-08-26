Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B40516B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 08:18:59 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 26 Aug 2009 21:48:58 +0930
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <200908261147.17838.rusty@rustcorp.com.au> <20090826065501.7ab677b9@mjolnir.ossman.eu>
In-Reply-To: <20090826065501.7ab677b9@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908262148.59664.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009 02:25:01 pm Pierre Ossman wrote:
> On Wed, 26 Aug 2009 11:47:17 +0930
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > On Fri, 14 Aug 2009 05:55:48 am Pierre Ossman wrote:
> > > On Wed, 12 Aug 2009 15:01:52 +0930
> > > Rusty Russell <rusty@rustcorp.com.au> wrote:
> > > > Subject: virtio: net refill on out-of-memory
> > ... 
> > > Patch applied. Now we wait. :)
> > 
> > Any results?
> > 
> 
> It's been up for 12 days, so I'd say it works. But there is nothing in
> dmesg, which suggests I haven't triggered the condition yet.

No, that's totally expected.  I wouldn't expect a GFP_ATOMIC order 0 alloc
failure to be noted, and the patch doesn't add any printks.

Dave, can you push this to Linus ASAP?

Thanks,
Rusty.

Subject: virtio: net refill on out-of-memory

If we run out of memory, use keventd to fill the buffer.  There's a
report of this happening: "Page allocation failures in guest",
Message-ID: <20090713115158.0a4892b0@mjolnir.ossman.eu>

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   61 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 46 insertions(+), 15 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -71,6 +71,9 @@ struct virtnet_info
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
 
+	/* Work struct for refilling if we run low on memory. */
+	struct delayed_work refill;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 };
@@ -274,19 +277,22 @@ drop:
 	dev_kfree_skb(skb);
 }
 
-static void try_fill_recv_maxbufs(struct virtnet_info *vi)
+static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
 	int num, err, i;
+	bool oom = false;
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 	for (;;) {
 		struct virtio_net_hdr *hdr;
 
 		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
-		if (unlikely(!skb))
+		if (unlikely(!skb)) {
+			oom = true;
 			break;
+		}
 
 		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, MAX_PACKET_LEN);
@@ -297,7 +303,7 @@ static void try_fill_recv_maxbufs(struct
 		if (vi->big_packets) {
 			for (i = 0; i < MAX_SKB_FRAGS; i++) {
 				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-				f->page = get_a_page(vi, GFP_ATOMIC);
+				f->page = get_a_page(vi, gfp);
 				if (!f->page)
 					break;
 
@@ -326,31 +332,35 @@ static void try_fill_recv_maxbufs(struct
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
 	vi->rvq->vq_ops->kick(vi->rvq);
+	return !oom;
 }
 
-static void try_fill_recv(struct virtnet_info *vi)
+/* Returns false if we couldn't fill entirely (OOM). */
+static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct scatterlist sg[1];
 	int err;
+	bool oom = false;
 
-	if (!vi->mergeable_rx_bufs) {
-		try_fill_recv_maxbufs(vi);
-		return;
-	}
+	if (!vi->mergeable_rx_bufs)
+		return try_fill_recv_maxbufs(vi, gfp);
 
 	for (;;) {
 		skb_frag_t *f;
 
 		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
-		if (unlikely(!skb))
+		if (unlikely(!skb)) {
+			oom = true;
 			break;
+		}
 
 		skb_reserve(skb, NET_IP_ALIGN);
 
 		f = &skb_shinfo(skb)->frags[0];
-		f->page = get_a_page(vi, GFP_ATOMIC);
+		f->page = get_a_page(vi, gfp);
 		if (!f->page) {
+			oom = true;
 			kfree_skb(skb);
 			break;
 		}
@@ -374,6 +384,7 @@ static void try_fill_recv(struct virtnet
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
 	vi->rvq->vq_ops->kick(vi->rvq);
+	return !oom;
 }
 
 static void skb_recv_done(struct virtqueue *rvq)
@@ -386,6 +397,23 @@ static void skb_recv_done(struct virtque
 	}
 }
 
+static void refill_work(struct work_struct *work)
+{
+	struct virtnet_info *vi;
+	bool still_empty;
+
+	vi = container_of(work, struct virtnet_info, refill.work);
+	napi_disable(&vi->napi);
+	try_fill_recv(vi, GFP_KERNEL);
+	still_empty = (vi->num == 0);
+	napi_enable(&vi->napi);
+
+	/* In theory, this can happen: if we don't get any buffers in
+	 * we will *never* try to fill again. */
+	if (still_empty)
+		schedule_delayed_work(&vi->refill, HZ/2);
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
@@ -401,10 +429,10 @@ again:
 		received++;
 	}
 
-	/* FIXME: If we oom and completely run out of inbufs, we need
-	 * to start a timer trying to fill more. */
-	if (vi->num < vi->max / 2)
-		try_fill_recv(vi);
+	if (vi->num < vi->max / 2) {
+		if (!try_fill_recv(vi, GFP_ATOMIC))
+			schedule_delayed_work(&vi->refill, 0);
+	}
 
 	/* Out of packets? */
 	if (received < budget) {
@@ -894,6 +922,7 @@ static int virtnet_probe(struct virtio_d
 	vi->vdev = vdev;
 	vdev->priv = vi;
 	vi->pages = NULL;
+	INIT_DELAYED_WORK(&vi->refill, refill_work);
 
 	/* If they give us a callback when all buffers are done, we don't need
 	 * the timer. */
@@ -942,7 +971,7 @@ static int virtnet_probe(struct virtio_d
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi);
+	try_fill_recv(vi, GFP_KERNEL);
 
 	/* If we didn't even get one input buffer, we're useless. */
 	if (vi->num == 0) {
@@ -959,6 +988,7 @@ static int virtnet_probe(struct virtio_d
 
 unregister:
 	unregister_netdev(dev);
+	cancel_delayed_work_sync(&vi->refill);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free:
@@ -987,6 +1017,7 @@ static void virtnet_remove(struct virtio
 	BUG_ON(vi->num != 0);
 
 	unregister_netdev(vi->dev);
+	cancel_delayed_work_sync(&vi->refill);
 
 	vdev->config->del_vqs(vi->vdev);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
