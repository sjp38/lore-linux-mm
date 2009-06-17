Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 34A606B005D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:28:24 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8208582C2E4
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:45:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Fo1LTunjvNnp for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 20:45:33 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0412E82C4D8
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:45:18 -0400 (EDT)
Message-Id: <20090617203444.007576712@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:43 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 06/19] this_cpu_ptr: Straight transformations
Content-Disposition: inline; filename=this_cpu_ptr_straight_transforms
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Use this_cpu_ptr and __this_cpu_ptr in locations where straight
transformations are possible because per_cpu_ptr is used with
either smp_processor_id() or raw_smp_processor_id().

cc: David Howells <dhowells@redhat.com>
cc: Tejun Heo <tj@kernel.org>
cc: Ingo Molnar <mingo@elte.hu>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 drivers/infiniband/hw/ehca/ehca_irq.c |    3 +--
 drivers/net/chelsio/sge.c             |    5 ++---
 drivers/net/loopback.c                |    2 +-
 fs/ext4/mballoc.c                     |    2 +-
 4 files changed, 5 insertions(+), 7 deletions(-)

Index: linux-2.6/drivers/net/chelsio/sge.c
===================================================================
--- linux-2.6.orig/drivers/net/chelsio/sge.c	2009-06-15 17:23:25.000000000 -0500
+++ linux-2.6/drivers/net/chelsio/sge.c	2009-06-15 17:53:41.000000000 -0500
@@ -1378,7 +1378,7 @@ static void sge_rx(struct sge *sge, stru
 	}
 	__skb_pull(skb, sizeof(*p));
 
-	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
+	st = this_cpu_ptr(sge->port_stats[p->iff]);
 
 	skb->protocol = eth_type_trans(skb, adapter->port[p->iff].dev);
 	if ((adapter->flags & RX_CSUM_ENABLED) && p->csum == 0xffff &&
@@ -1780,8 +1780,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 {
 	struct adapter *adapter = dev->ml_priv;
 	struct sge *sge = adapter->sge;
-	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port],
-						smp_processor_id());
+	struct sge_port_stats *st = this_cpu_ptr(sge->port_stats[dev->if_port]);
 	struct cpl_tx_pkt *cpl;
 	struct sk_buff *orig_skb = skb;
 	int ret;
Index: linux-2.6/drivers/net/loopback.c
===================================================================
--- linux-2.6.orig/drivers/net/loopback.c	2009-06-15 17:23:25.000000000 -0500
+++ linux-2.6/drivers/net/loopback.c	2009-06-15 17:54:41.000000000 -0500
@@ -80,7 +80,7 @@ static int loopback_xmit(struct sk_buff 
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = dev->ml_priv;
-	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
+	lb_stats = this_cpu_ptr(pcpu_lstats);
 
 	len = skb->len;
 	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
Index: linux-2.6/fs/ext4/mballoc.c
===================================================================
--- linux-2.6.orig/fs/ext4/mballoc.c	2009-06-15 17:22:07.000000000 -0500
+++ linux-2.6/fs/ext4/mballoc.c	2009-06-15 17:53:41.000000000 -0500
@@ -4182,7 +4182,7 @@ static void ext4_mb_group_or_file(struct
 	 * per cpu locality group is to reduce the contention between block
 	 * request from multiple CPUs.
 	 */
-	ac->ac_lg = per_cpu_ptr(sbi->s_locality_groups, raw_smp_processor_id());
+	ac->ac_lg = __this_cpu_ptr(sbi->s_locality_groups);
 
 	/* we're going to use group allocation */
 	ac->ac_flags |= EXT4_MB_HINT_GROUP_ALLOC;
Index: linux-2.6/drivers/infiniband/hw/ehca/ehca_irq.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/ehca/ehca_irq.c	2009-06-15 17:22:07.000000000 -0500
+++ linux-2.6/drivers/infiniband/hw/ehca/ehca_irq.c	2009-06-15 17:53:41.000000000 -0500
@@ -826,8 +826,7 @@ static void __cpuinit take_over_work(str
 		cq = list_entry(cct->cq_list.next, struct ehca_cq, entry);
 
 		list_del(&cq->entry);
-		__queue_comp_task(cq, per_cpu_ptr(pool->cpu_comp_tasks,
-						  smp_processor_id()));
+		__queue_comp_task(cq, this_cpu_ptr(pool->cpu_comp_tasks));
 	}
 
 	spin_unlock_irqrestore(&cct->task_lock, flags_cct);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
