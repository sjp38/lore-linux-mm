Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B0B46B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 18:02:15 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D821D82C770
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 18:06:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QX-ctF09P2HR for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 18:06:49 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2A7F082C7D4
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 18:06:27 -0400 (EDT)
Message-Id: <20091001174120.883128108@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:40 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 07/19] this_cpu_ptr: Eliminate get/put_cpu
Content-Disposition: inline; filename=this_cpu_ptr_eliminate_get_put_cpu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Maciej Sosnowski <maciej.sosnowski@intel.com>, Dan Williams <dan.j.williams@intel.com>, Tejun Heo <tj@kernel.org>, Eric Biederman <ebiederm@aristanetworks.com>, Stephen Hemminger <shemminger@vyatta.com>, David L Stevens <dlstevens@us.ibm.com>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

There are cases where we can use this_cpu_ptr and as the result
of using this_cpu_ptr() we no longer need to determine the
currently executing cpu.

In those places no get/put_cpu combination is needed anymore.
The local cpu variable can be eliminated.

Preemption still needs to be disabled and enabled since the
modifications of the per cpu variables is not atomic. There may
be multiple per cpu variables modified and those must all
be from the same processor.

Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Acked-by: Dan Williams <dan.j.williams@intel.com>
Acked-by: Tejun Heo <tj@kernel.org>
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
--- linux-2.6.orig/drivers/dma/dmaengine.c	2009-09-28 10:08:09.000000000 -0500
+++ linux-2.6/drivers/dma/dmaengine.c	2009-09-29 09:01:54.000000000 -0500
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
 
@@ -847,7 +840,6 @@ dma_async_memcpy_buf_to_buf(struct dma_c
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, src, len, DMA_TO_DEVICE);
@@ -866,10 +858,10 @@ dma_async_memcpy_buf_to_buf(struct dma_c
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
@@ -896,7 +888,6 @@ dma_async_memcpy_buf_to_pg(struct dma_ch
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, kdata, len, DMA_TO_DEVICE);
@@ -913,10 +904,10 @@ dma_async_memcpy_buf_to_pg(struct dma_ch
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
@@ -945,7 +936,6 @@ dma_async_memcpy_pg_to_pg(struct dma_cha
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
-	int cpu;
 	unsigned long flags;
 
 	dma_src = dma_map_page(dev->dev, src_pg, src_off, len, DMA_TO_DEVICE);
@@ -963,10 +953,10 @@ dma_async_memcpy_pg_to_pg(struct dma_cha
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
--- linux-2.6.orig/drivers/net/veth.c	2009-09-17 17:54:16.000000000 -0500
+++ linux-2.6/drivers/net/veth.c	2009-09-29 09:01:54.000000000 -0500
@@ -153,7 +153,7 @@ static netdev_tx_t veth_xmit(struct sk_b
 	struct net_device *rcv = NULL;
 	struct veth_priv *priv, *rcv_priv;
 	struct veth_net_stats *stats, *rcv_stats;
-	int length, cpu;
+	int length;
 
 	skb_orphan(skb);
 
@@ -161,9 +161,8 @@ static netdev_tx_t veth_xmit(struct sk_b
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
