Date: Wed, 16 Aug 2006 10:42:24 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/1] network memory allocator.
Message-ID: <20060816094224.GA12606@infradead.org>
References: <20060814110359.GA27704@2ka.mipt.ru> <200608152221.22883.arnd@arndb.de> <20060816053545.GB22921@2ka.mipt.ru> <20060816084808.GA7366@infradead.org> <20060816090028.GA25476@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060816090028.GA25476@2ka.mipt.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 16, 2006 at 01:00:31PM +0400, Evgeniy Polyakov wrote:
> On Wed, Aug 16, 2006 at 09:48:08AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > > Doesn't alloc_pages() automatically switches to alloc_pages_node() or
> > > alloc_pages_current()?
> > 
> > That's not what's wanted.  If you have a slow interconnect you always want
> > to allocate memory on the node the network device is attached to.
> 
> There is drawback here - if data was allocated on CPU wheere NIC is
> "closer" and then processed on different CPU it will cost more than 
> in case where buffer was allocated on CPU where it will be processed.
> 
> But from other point of view, most of the adapters preallocate set of
> skbs, and with msi-x help there will be a possibility to bind irq and
> processing to the CPU where data was origianlly allocated.

The case we've benchmarked (spidernet) is the common preallocated case.
For allocate on demand I'd expect the slab allocator to get things right.
We do have the irq on the right node, not through MSI but due to the odd
interreupt architecture of the Cell blades.

> So I would like to know how to determine which node should be used for
> allocation. Changes of __get_user_pages() to alloc_pages_node() are
> trivial.

The patches I have add the node field to struct net_device and use it.
It's set via alloc_netdev_node, a function I add and for the normal case
of PCI adapters the node arguments comes from pcibus_to_node().  It's
arguable we should add a alloc_foodeve_pdev variant that hids that detail,
but I'm not entirely sure about whether it's worth the effort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
