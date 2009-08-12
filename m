Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC6F6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 01:32:00 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 12 Aug 2009 15:01:52 +0930
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <4A811545.5090209@redhat.com> <200908121249.51973.rusty@rustcorp.com.au>
In-Reply-To: <200908121249.51973.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908121501.53167.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Aug 2009 12:49:51 pm Rusty Russell wrote:
> On Tue, 11 Aug 2009 04:22:53 pm Avi Kivity wrote:
> > On 08/11/2009 09:32 AM, Pierre Ossman wrote:
> > > I doesn't get out of it though, or at least the virtio net driver
> > > wedges itself.
> 
> There's a fixme to retry when this happens, but this is the first report
> I've received.  I'll check it out.

Subject: virtio: net refill on out-of-memory

If we run out of memory, use keventd to fill the buffer.  There's a
report of this happening: "Page allocation failures in guest",
Message-ID: <20090713115158.0a4892b0@mjolnir.ossman.eu>

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -71,6 +71,9 @@ struct virtnet_info
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
 
+	/* Work struct for refilling if we run low on memory. */
+	struct work_struct refill;
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
@@ -386,6 +397,26 @@ static void skb_recv_done(struct virtque
 	}
 }
 
+static void refill_work(struct work_struct *work)
+{
+	struct virtnet_info *vi;
+	bool still_empty;
+
+	vi = container_of(work, struct virtnet_info, refill);
+	napi_disable(&vi->napi);
+	try_fill_recv(vi, GFP_KERNEL);
+	still_empty = (vi->num == 0);
+	napi_enable(&vi->napi);
+
+	/* In theory, this can happen: if we don't get any buffers in
+	 * we will *never* try to fill again.  Sleeping in keventd if
+	 * bad, but that is worse. */
+	if (still_empty) {
+		msleep(100);
+		schedule_work(&vi->refill);
+	}
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
@@ -401,10 +432,10 @@ again:
 		received++;
 	}
 
-	/* FIXME: If we oom and completely run out of inbufs, we need
-	 * to start a timer trying to fill more. */
-	if (vi->num < vi->max / 2)
-		try_fill_recv(vi);
+	if (vi->num < vi->max / 2) {
+		if (!try_fill_recv(vi, GFP_ATOMIC))
+			schedule_work(&vi->refill);
+	}
 
 	/* Out of packets? */
 	if (received < budget) {
@@ -894,6 +925,7 @@ static int virtnet_probe(struct virtio_d
 	vi->vdev = vdev;
 	vdev->priv = vi;
 	vi->pages = NULL;
+	INIT_WORK(&vi->refill, refill_work);
 
 	/* If they give us a callback when all buffers are done, we don't need
 	 * the timer. */
@@ -942,7 +974,7 @@ static int virtnet_probe(struct virtio_d
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi);
+	try_fill_recv(vi, GFP_KERNEL);
 
 	/* If we didn't even get one input buffer, we're useless. */
 	if (vi->num == 0) {
@@ -959,6 +991,7 @@ static int virtnet_probe(struct virtio_d
 
 unregister:
 	unregister_netdev(dev);
+	cancel_work_sync(&vi->refill);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free:
@@ -987,6 +1020,7 @@ static void virtnet_remove(struct virtio
 	BUG_ON(vi->num != 0);
 
 	unregister_netdev(vi->dev);
+	cancel_work_sync(&vi->refill);
 
 	vdev->config->del_vqs(vi->vdev);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
