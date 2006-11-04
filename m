Date: Sat, 4 Nov 2006 18:06:48 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2/3] add dev_to_node()
Message-ID: <20061104230648.GB640@redhat.com>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net> <20061104225629.GA31437@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061104225629.GA31437@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 04, 2006 at 11:56:29PM +0100, Christoph Hellwig wrote:

This will break the compile for !NUMA if someone ends up doing a bisect
and lands here as a bisect point.

You introduce this nice wrapper..

 > +#ifdef CONFIG_NUMA
 > +#define dev_to_node(dev)	((dev)->numa_node)
 > +#else
 > +#define dev_to_node(dev)	(-1)
 > +#endif
 > +
 >  static inline void *
 >  dev_get_drvdata (struct device *dev)
 >  {


And then don't use it here..

 > Index: linux-2.6/drivers/base/core.c
 > ===================================================================
 > --- linux-2.6.orig/drivers/base/core.c	2006-10-23 17:21:44.000000000 +0200
 > +++ linux-2.6/drivers/base/core.c	2006-11-02 12:48:12.000000000 +0100
 > @@ -381,6 +381,7 @@
 >  	INIT_LIST_HEAD(&dev->node);
 >  	init_MUTEX(&dev->sem);
 >  	device_init_wakeup(dev, 0);
 > +	dev->numa_node = -1;
 >  }
 >  
 >  /**

and here.

 > Index: linux-2.6/drivers/pci/probe.c
 > ===================================================================
 > --- linux-2.6.orig/drivers/pci/probe.c	2006-10-23 17:21:46.000000000 +0200
 > +++ linux-2.6/drivers/pci/probe.c	2006-11-02 12:47:35.000000000 +0100
 > @@ -846,6 +846,7 @@
 >  	dev->dev.release = pci_release_dev;
 >  	pci_dev_get(dev);
 >  
 > +	dev->dev.numa_node = pcibus_to_node(bus);
 >  	dev->dev.dma_mask = &dev->dma_mask;
 >  	dev->dev.coherent_dma_mask = 0xffffffffull;


	Dave


-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
