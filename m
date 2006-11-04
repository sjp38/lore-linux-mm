Date: Sun, 5 Nov 2006 00:53:23 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/3] add dev_to_node()
Message-ID: <20061104235323.GA1353@lst.de>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net> <20061104225629.GA31437@lst.de> <20061104230648.GB640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061104230648.GB640@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>, Christoph Hellwig <hch@lst.de>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 04, 2006 at 06:06:48PM -0500, Dave Jones wrote:
> On Sat, Nov 04, 2006 at 11:56:29PM +0100, Christoph Hellwig wrote:
> 
> This will break the compile for !NUMA if someone ends up doing a bisect
> and lands here as a bisect point.
> 
> You introduce this nice wrapper..

The dev_to_node wrapper is not enough as we can't assign to (-1) for
the non-NUMA case.  So I added a second macro, set_dev_node for that.

The patch below compiles and works on numa and non-NUMA platforms.


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
