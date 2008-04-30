Message-Id: <20080430044321.451211400@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:43:02 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [11/11] e1000: Avoid vmalloc through virtualizable compound page
Content-Disposition: inline; filename=vcp_e1000_buffers
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Switch all the uses of vmalloc in the e1000 driver to virtualizable compounds.
This will result in the use of regular memory for the ring buffers etc
avoiding page tables.

Cc: netdev@vger.kernel.org
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 drivers/net/e1000/e1000_main.c |   23 +++++++++++------------
 drivers/net/e1000e/netdev.c    |   12 ++++++------
 2 files changed, 17 insertions(+), 18 deletions(-)

Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c	2008-04-25 16:02:34.973649656 -0700
+++ linux-2.6/drivers/net/e1000e/netdev.c	2008-04-29 16:47:03.583706293 -0700
@@ -1103,7 +1103,7 @@ int e1000e_setup_tx_resources(struct e10
 	int err = -ENOMEM, size;
 
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = __alloc_vcompound(GFP_KERNEL, get_order(size));
 	if (!tx_ring->buffer_info)
 		goto err;
 	memset(tx_ring->buffer_info, 0, size);
@@ -1122,7 +1122,7 @@ int e1000e_setup_tx_resources(struct e10
 
 	return 0;
 err:
-	vfree(tx_ring->buffer_info);
+	__free_vcompound(tx_ring->buffer_info);
 	ndev_err(adapter->netdev,
 	"Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
@@ -1141,7 +1141,7 @@ int e1000e_setup_rx_resources(struct e10
 	int i, size, desc_len, err = -ENOMEM;
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = __alloc_vcompound(GFP_KERNEL, get_order(size));
 	if (!rx_ring->buffer_info)
 		goto err;
 	memset(rx_ring->buffer_info, 0, size);
@@ -1177,7 +1177,7 @@ err_pages:
 		kfree(buffer_info->ps_pages);
 	}
 err:
-	vfree(rx_ring->buffer_info);
+	__free_vcompound(rx_ring->buffer_info);
 	ndev_err(adapter->netdev,
 	"Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
@@ -1224,7 +1224,7 @@ void e1000e_free_tx_resources(struct e10
 
 	e1000_clean_tx_ring(adapter);
 
-	vfree(tx_ring->buffer_info);
+	__free_vcompound(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
 
 	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
@@ -1251,7 +1251,7 @@ void e1000e_free_rx_resources(struct e10
 		kfree(rx_ring->buffer_info[i].ps_pages);
 	}
 
-	vfree(rx_ring->buffer_info);
+	__free_vcompound(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
 	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c	2008-04-24 22:36:01.033639755 -0700
+++ linux-2.6/drivers/net/e1000/e1000_main.c	2008-04-29 16:47:03.583706293 -0700
@@ -1604,14 +1604,13 @@ e1000_setup_tx_resources(struct e1000_ad
 	int size;
 
 	size = sizeof(struct e1000_buffer) * txdr->count;
-	txdr->buffer_info = vmalloc(size);
+	txdr->buffer_info = __alloc_vcompound(GFP_KERNEL | __GFP_ZERO,
+							get_order(size));
 	if (!txdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(txdr->buffer_info, 0, size);
-
 	/* round up to nearest 4K */
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
@@ -1620,7 +1619,7 @@ e1000_setup_tx_resources(struct e1000_ad
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if (!txdr->desc) {
 setup_tx_desc_die:
-		vfree(txdr->buffer_info);
+		__free_vcompound(txdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
@@ -1648,7 +1647,7 @@ setup_tx_desc_die:
 			DPRINTK(PROBE, ERR,
 				"Unable to allocate aligned memory "
 				"for the transmit descriptor ring\n");
-			vfree(txdr->buffer_info);
+			__free_vcompound(txdr->buffer_info);
 			return -ENOMEM;
 		} else {
 			/* Free old allocation, new allocation was successful */
@@ -1821,7 +1820,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	int size, desc_len;
 
 	size = sizeof(struct e1000_buffer) * rxdr->count;
-	rxdr->buffer_info = vmalloc(size);
+	rxdr->buffer_info = __alloc_vcompound(GFP_KERNEL, get_order(size));
 	if (!rxdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
@@ -1832,7 +1831,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	rxdr->ps_page = kcalloc(rxdr->count, sizeof(struct e1000_ps_page),
 	                        GFP_KERNEL);
 	if (!rxdr->ps_page) {
-		vfree(rxdr->buffer_info);
+		__free_vcompound(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
@@ -1842,7 +1841,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	                            sizeof(struct e1000_ps_page_dma),
 	                            GFP_KERNEL);
 	if (!rxdr->ps_page_dma) {
-		vfree(rxdr->buffer_info);
+		__free_vcompound(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
@@ -1865,7 +1864,7 @@ e1000_setup_rx_resources(struct e1000_ad
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
 setup_rx_desc_die:
-		vfree(rxdr->buffer_info);
+		__free_vcompound(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
 		kfree(rxdr->ps_page_dma);
 		return -ENOMEM;
@@ -2170,7 +2169,7 @@ e1000_free_tx_resources(struct e1000_ada
 
 	e1000_clean_tx_ring(adapter, tx_ring);
 
-	vfree(tx_ring->buffer_info);
+	__free_vcompound(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
 
 	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
@@ -2278,9 +2277,9 @@ e1000_free_rx_resources(struct e1000_ada
 
 	e1000_clean_rx_ring(adapter, rx_ring);
 
-	vfree(rx_ring->buffer_info);
+	__free_vcompound(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
-	kfree(rx_ring->ps_page);
+	__free_vcompound(rx_ring->ps_page);
 	rx_ring->ps_page = NULL;
 	kfree(rx_ring->ps_page_dma);
 	rx_ring->ps_page_dma = NULL;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
