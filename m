From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 08 Aug 2006 21:34:36 +0200
Message-Id: <20060808193436.1396.71141.sendpatchset@lappy>
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Subject: [RFC][PATCH 7/9] UML eth driver conversion
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Update the driver to make use of the netdev_alloc_skb() API and the
NETIF_F_MEMALLOC feature.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>

---
 arch/um/drivers/net_kern.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/um/drivers/net_kern.c
===================================================================
--- linux-2.6.orig/arch/um/drivers/net_kern.c
+++ linux-2.6/arch/um/drivers/net_kern.c
@@ -43,7 +43,7 @@ static int uml_net_rx(struct net_device 
 	struct sk_buff *skb;
 
 	/* If we can't allocate memory, try again next round. */
-	skb = dev_alloc_skb(dev->mtu);
+	skb = netdev_alloc_skb(dev, dev->mtu);
 	if (skb == NULL) {
 		lp->stats.rx_dropped++;
 		return 0;
@@ -377,6 +377,7 @@ static int eth_configure(int n, void *in
 	dev->ethtool_ops = &uml_net_ethtool_ops;
 	dev->watchdog_timeo = (HZ >> 1);
 	dev->irq = UM_ETH_IRQ;
+	dev->features |= NETIF_F_MEMALLOC;
 
 	rtnl_lock();
 	err = register_netdevice(dev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
