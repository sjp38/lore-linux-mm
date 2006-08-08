From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 08 Aug 2006 21:34:05 +0200
Message-Id: <20060808193405.1396.14701.sendpatchset@lappy>
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Subject: [RFC][PATCH 4/9] e100 driver conversion
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
 drivers/net/e100.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -1763,7 +1763,7 @@ static inline void e100_start_receiver(s
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
-	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
+	if(!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
@@ -2143,7 +2143,7 @@ static int e100_loopback_test(struct nic
 
 	e100_start_receiver(nic, NULL);
 
-	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
+	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
 		err = -ENOMEM;
 		goto err_loopback_none;
 	}
@@ -2573,6 +2573,7 @@ static int __devinit e100_probe(struct p
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
+	netdev->features |= NETIF_F_MEMALLOC;
 	strcpy(netdev->name, pci_name(pdev));
 
 	nic = netdev_priv(netdev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
