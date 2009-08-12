Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 811166B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 02:56:29 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 12 Aug 2009 16:26:30 +0930
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <200908121501.53167.rusty@rustcorp.com.au> <4A825601.60000@redhat.com>
In-Reply-To: <4A825601.60000@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908121626.31531.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Aug 2009 03:11:21 pm Avi Kivity wrote:
> > +	/* In theory, this can happen: if we don't get any buffers in
> > +	 * we will*never*  try to fill again.  Sleeping in keventd if
> > +	 * bad, but that is worse. */
> > +	if (still_empty) {
> > +		msleep(100);
> > +		schedule_work(&vi->refill);
> > +	}
> > +}
> > + 
> 
> schedule_delayed_work()?

Hmm, might as well, although this is v. unlikely to happen.

Thanks,
Rusty.

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -72,7 +72,7 @@ struct virtnet_info
 	struct sk_buff_head send;
 
 	/* Work struct for refilling if we run low on memory. */
-	struct work_struct refill;
+	struct delayed_work refill;
 	
 	/* Chain pages by the private ptr. */
 	struct page *pages;
@@ -402,19 +402,16 @@ static void refill_work(struct work_stru
 	struct virtnet_info *vi;
 	bool still_empty;
 
-	vi = container_of(work, struct virtnet_info, refill);
+	vi = container_of(work, struct virtnet_info, refill.work);
 	napi_disable(&vi->napi);
 	try_fill_recv(vi, GFP_KERNEL);
 	still_empty = (vi->num == 0);
 	napi_enable(&vi->napi);
 
 	/* In theory, this can happen: if we don't get any buffers in
-	 * we will *never* try to fill again.  Sleeping in keventd if
-	 * bad, but that is worse. */
-	if (still_empty) {
-		msleep(100);
-		schedule_work(&vi->refill);
-	}
+	 * we will *never* try to fill again. */
+	if (still_empty)
+		schedule_delayed_work(&vi->refill, HZ/2);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
@@ -434,7 +431,7 @@ again:
 
 	if (vi->num < vi->max / 2) {
 		if (!try_fill_recv(vi, GFP_ATOMIC))
-			schedule_work(&vi->refill);
+			schedule_delayed_work(&vi->refill, 0);
 	}
 
 	/* Out of packets? */
@@ -925,7 +922,7 @@ static int virtnet_probe(struct virtio_d
 	vi->vdev = vdev;
 	vdev->priv = vi;
 	vi->pages = NULL;
-	INIT_WORK(&vi->refill, refill_work);
+	INIT_DELAYED_WORK(&vi->refill, refill_work);
 
 	/* If they give us a callback when all buffers are done, we don't need
 	 * the timer. */
@@ -991,7 +988,7 @@ static int virtnet_probe(struct virtio_d
 
 unregister:
 	unregister_netdev(dev);
-	cancel_work_sync(&vi->refill);
+	cancel_delayed_work_sync(&vi->refill);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free:
@@ -1020,7 +1017,7 @@ static void virtnet_remove(struct virtio
 	BUG_ON(vi->num != 0);
 
 	unregister_netdev(vi->dev);
-	cancel_work_sync(&vi->refill);
+	cancel_delayed_work_sync(&vi->refill);
 
 	vdev->config->del_vqs(vi->vdev);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
