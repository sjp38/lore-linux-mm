Date: Wed, 15 Nov 2006 18:37:01 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/3] add numa node information to struct device
Message-ID: <20061115173701.GB18244@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For node-aware skb allocations we need information about the node
in struct net_device or struct device.  Davem suggested to put
it into struct device which this patch does.

In particular:

 - struct device gets a new int numa_node member if CONFIG_NUMA is set
 - there are two new helpers, dev_to_node and set_dev_node to
   transparently deal with the non-numa case
 - for pci devices the node-info is set to the value we get from
   pcibus_to_node.

Note that for some architectures pcibus_to_node doesn't work yet at the
time we call it currently.  This is harmless and will just mean skb
allocations aren't node-local on this architectures until the
implementation of pcibus_to_node on these architectures have been
updated (There are patches for x86 and x86_64 floating around)


Signed-off-by: Christoph Hellwig <hch@lst.de>
 
Index: linux-2.6/include/linux/device.h
===================================================================
--- linux-2.6.orig/include/linux/device.h	2006-11-05 00:16:09.000000000 +0100
+++ linux-2.6/include/linux/device.h	2006-11-05 00:39:22.000000000 +0100
@@ -347,6 +347,9 @@
 					   BIOS data),reserved for device core*/
 	struct dev_pm_info	power;
 
+#ifdef CONFIG_NUMA
+	int		numa_node;	/* NUMA node this device is close to */
+#endif
 	u64		*dma_mask;	/* dma mask (if dma'able device) */
 	u64		coherent_dma_mask;/* Like dma_mask, but for
 					     alloc_coherent mappings as
@@ -368,6 +371,14 @@
 	void	(*release)(struct device * dev);
 };
 
+#ifdef CONFIG_NUMA
+#define dev_to_node(dev)	((dev)->numa_node)
+#define set_dev_node(dev, node)	((dev)->numa_node = node)
+#else
+#define dev_to_node(dev)	(-1)
+#define set_dev_node(dev, node)	do { } while (0)
+#endif
+
 static inline void *
 dev_get_drvdata (struct device *dev)
 {
Index: linux-2.6/drivers/base/core.c
===================================================================
--- linux-2.6.orig/drivers/base/core.c	2006-11-05 00:16:09.000000000 +0100
+++ linux-2.6/drivers/base/core.c	2006-11-05 00:40:01.000000000 +0100
@@ -381,6 +381,7 @@
 	INIT_LIST_HEAD(&dev->node);
 	init_MUTEX(&dev->sem);
 	device_init_wakeup(dev, 0);
+	set_dev_node(dev, -1);
 }
 
 /**
Index: linux-2.6/drivers/pci/probe.c
===================================================================
--- linux-2.6.orig/drivers/pci/probe.c	2006-11-05 00:16:09.000000000 +0100
+++ linux-2.6/drivers/pci/probe.c	2006-11-05 00:39:55.000000000 +0100
@@ -846,6 +846,7 @@
 	dev->dev.release = pci_release_dev;
 	pci_dev_get(dev);
 
+	set_dev_node(&dev->dev, pcibus_to_node(bus));
 	dev->dev.dma_mask = &dev->dma_mask;
 	dev->dev.coherent_dma_mask = 0xffffffffull;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
