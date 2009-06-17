Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3BBBF6B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:28:19 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C5DEA82C527
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:45:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Q8i8n-mxFW9t for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 19:45:23 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1AB6582C52E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:45:17 -0400 (EDT)
Message-Id: <20090617203444.152778985@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:44 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 07/19] this_cpu_ptr: Elimninate get/put_cpu
Content-Disposition: inline; filename=this_cpu_ptr_eliminate_get_put_cpu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Maciej Sosnowski <maciej.sosnowski@intel.com>, Dan Williams <dan.j.williams@intel.com>, Eric Biederman <ebiederm@aristanetworks.com>, Stephen Hemminger <shemminger@vyatta.com>, David L Stevens <dlstevens@us.ibm.com>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

There are cases where we can use this_cpu_ptr and as the result
of using this_cpu_ptr() we no longer need to determine the
current executing cpu.

In those places no get/put_cpu combination is needed anymore.
The local cpu variable can be eliminated.

Preemption still needs to be disabled and enabled since the
modifications of the per cpu variables is not atomic. There may
be multiple per cpu variables modified and those must all
be from the same processor.

Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Acked-by: Dan Williams <dan.j.williams@intel.com>
cc: Eric Biederman <ebiederm@aristanetworks.com>
cc: Stephen Hemminger <shemminger@vyatta.com>
cc: David L Stevens <dlstevens@us.ibm.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 drivers/dma/dmaengine.c |   36 +++++++++++++-----------------------
 drivers/net/veth.c      |    7 +++----
 2 files changed, 16 insertions(+), 27 deletions(-)

Index: linux-2.6/drivers/dma/dmaengine.c
===================================================================
--- linux-2.6.orig/drivers/dma/dmaengine.c	2009-06-04 13:38:15.000000000 -0500
+++ linux-2.6/drivers/dma/dmaengine.c	2009-06-04 14:19:43.000000000 -0500
@@ -326,14 +326,7 @@ arch_initcall(dma_channel_table_init);
  */
 struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
 {
-	struct dma_chan *chan;
-	int cpu;
-
-	cpu = get_cpu();
-	chan = per_cpu_ptr(channel_table[tx_type], cpu)->chan;
-	put_cpu();
-
-	return chan;
+	return this_cpu_read(channel_table[tx_type]->chan);
 }
 EXPORT_SYMBOL(dma_find_channel);
 
@@ -803,7 +796,6 @@ dma_async_memcpy_buf_to_buf(struct dma_c
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, src, len, DMA_TO_DEVICE);
@@ -822,10 +814,10 @@ dma_async_memcpy_buf_to_buf(struct dma_c
 	tx->callback = NULL;
 	cookie = tx->tx_submit(tx);
 
-	cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
+	preempt_disable();
+	__this_cpu_add(chan->local->bytes_transferred, len);
+	__this_cpu_inc(chan->local->memcpy_count);
+	preempt_enable();
 
 	return cookie;
 }
@@ -852,7 +844,6 @@ dma_async_memcpy_buf_to_pg(struct dma_ch
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, kdata, len, DMA_TO_DEVICE);
@@ -869,10 +860,10 @@ dma_async_memcpy_buf_to_pg(struct dma_ch
 	tx->callback = NULL;
 	cookie = tx->tx_submit(tx);
 
-	cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
+	preempt_disable();
+	__this_cpu_add(chan->local->bytes_transferred, len);
+	__this_cpu_inc(chan->local->memcpy_count);
+	preempt_enable();
 
 	return cookie;
 }
@@ -901,7 +892,6 @@ dma_async_memcpy_pg_to_pg(struct dma_cha
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_page(dev->dev, src_pg, src_off, len, DMA_TO_DEVICE);
@@ -919,10 +909,10 @@ dma_async_memcpy_pg_to_pg(struct dma_cha
 	tx->callback = NULL;
 	cookie = tx->tx_submit(tx);
 
-	cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
+	preempt_disable();
+	__this_cpu_add(chan->local->bytes_transferred, len);
+	__this_cpu_inc(chan->local->memcpy_count);
+	preempt_enable();
 
 	return cookie;
 }
Index: linux-2.6/drivers/net/veth.c
===================================================================
--- linux-2.6.orig/drivers/net/veth.c	2009-06-04 13:38:15.000000000 -0500
+++ linux-2.6/drivers/net/veth.c	2009-06-04 14:18:00.000000000 -0500
@@ -153,7 +153,7 @@ static int veth_xmit(struct sk_buff *skb
 	struct net_device *rcv = NULL;
 	struct veth_priv *priv, *rcv_priv;
 	struct veth_net_stats *stats, *rcv_stats;
-	int length, cpu;
+	int length;
 
 	skb_orphan(skb);
 
@@ -161,9 +161,8 @@ static int veth_xmit(struct sk_buff *skb
 	rcv = priv->peer;
 	rcv_priv = netdev_priv(rcv);
 
-	cpu = smp_processor_id();
-	stats = per_cpu_ptr(priv->stats, cpu);
-	rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
+	stats = this_cpu_ptr(priv->stats);
+	rcv_stats = this_cpu_ptr(rcv_priv->stats);
 
 	if (!(rcv->flags & IFF_UP))
 		goto tx_drop;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
