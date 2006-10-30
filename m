Date: Mon, 30 Oct 2006 14:33:57 -0800 (PST)
Message-Id: <20061030.143357.130208425.davem@davemloft.net>
Subject: Re: [PATCH 2/3] add dev_to_node()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20061030141501.GC7164@lst.de>
References: <20061030141501.GC7164@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Oct 2006 15:15:01 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: hch@lst.de
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Davem suggested to get the node-affinity information directly from
> struct device instead of having the caller extreact it from the
> pci_dev.  This patch adds dev_to_node() to the topology API for that.
> The implementation is rather ugly as we need to compare the bus
> operations which we can't do inline in a header without pulling all
> kinds of mess in.
> 
> Thus provide an out of line dev_to_node for ppc and let everyone else
> use the dummy variant in asm-generic.h for now.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

It may be a bit much to be calling all the way through up to the PCI
layer just to pluck out a simple integer, don't you think?  The PCI
bus pointer comparison is just a symptom of how silly this is.

Especially since this will be used for every packet allocation a
device makes.

So, please add some sanity to this situation and just put the node
into the generic struct device. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
