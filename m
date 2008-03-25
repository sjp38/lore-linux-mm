Message-Id: <20080325220651.964533000@polaris-admin.engr.sgi.com>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 15:06:58 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 08/10] net: remove NR_CPUS arrays in net/core/dev.c v2
Content-Disposition: inline; filename=nr_cpus-in-net_core_dev
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Patrick McHardy <kaber@trash.net>
List-ID: <linux-mm.kvack.org>

Remove the fixed size channels[NR_CPUS] array in
net/core/dev.c and dynamically allocate array based on
nr_cpu_ids.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Mike Travis <travis@sgi.com>
---
v2: fixed logic error in netdev_dma_register().
---
 net/core/dev.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

--- linux.trees.git.orig/net/core/dev.c
+++ linux.trees.git/net/core/dev.c
@@ -162,7 +162,7 @@ struct net_dma {
 	struct dma_client client;
 	spinlock_t lock;
 	cpumask_t channel_mask;
-	struct dma_chan *channels[NR_CPUS];
+	struct dma_chan **channels;
 };
 
 static enum dma_state_client
@@ -2444,7 +2444,7 @@ static struct netif_rx_stats *softnet_ge
 {
 	struct netif_rx_stats *rc = NULL;
 
-	while (*pos < NR_CPUS)
+	while (*pos < nr_cpu_ids)
 		if (cpu_online(*pos)) {
 			rc = &per_cpu(netdev_rx_stat, *pos);
 			break;
@@ -4316,7 +4316,7 @@ netdev_dma_event(struct dma_client *clie
 	spin_lock(&net_dma->lock);
 	switch (state) {
 	case DMA_RESOURCE_AVAILABLE:
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < nr_cpu_ids; i++)
 			if (net_dma->channels[i] == chan) {
 				found = 1;
 				break;
@@ -4331,7 +4331,7 @@ netdev_dma_event(struct dma_client *clie
 		}
 		break;
 	case DMA_RESOURCE_REMOVED:
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < nr_cpu_ids; i++)
 			if (net_dma->channels[i] == chan) {
 				found = 1;
 				pos = i;
@@ -4358,6 +4358,13 @@ netdev_dma_event(struct dma_client *clie
  */
 static int __init netdev_dma_register(void)
 {
+	net_dma.channels = kzalloc(nr_cpu_ids * sizeof(struct net_dma),
+								GFP_KERNEL);
+	if (unlikely(!net_dma.channels)) {
+		printk(KERN_NOTICE
+				"netdev_dma: no memory for net_dma.channels\n");
+		return -ENOMEM;
+	}
 	spin_lock_init(&net_dma.lock);
 	dma_cap_set(DMA_MEMCPY, net_dma.client.cap_mask);
 	dma_async_client_register(&net_dma.client);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
