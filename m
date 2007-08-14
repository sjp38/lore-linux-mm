Date: Tue, 14 Aug 2007 02:00:41 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070814000041.GL3406@bingen.suse.de>
References: <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com> <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com> <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com> <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com> <20070813234322.GJ3406@bingen.suse.de> <Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 03:54:34PM -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > On Mon, Aug 13, 2007 at 03:38:10PM -0700, Christoph Lameter wrote:
> > > I just did a grep for GFP_DMA and I still see a large list of GFP_DMA 
> > > kmallocs???
> > 
> > I converted all of those that applied to x86.
> 
> Converted to what?

Hmm, do you actually read my emails? I spelled that out at least two
times now. It's converted to a new dma page allocator that specifies
an address mask.

> 
> drivers/net/tokenring/3c359.c:	xl_priv->xl_tx_ring = kmalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) + 7, GFP_DMA | GFP_KERNEL) ; 
> drivers/net/tokenring/3c359.c:	xl_priv->xl_rx_ring = kmalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) +7, GFP_DMA | GFP_KERNEL) ; 
> 
> Tokenring not supported on x86?

It can be easily converted to a page allocation.

The only tricky part were skbs in a few drivers, but luckily they are only
needed for bouncing which can be done without a skb too. For RX it adds
one copy, but we can live with that because they're only slow devices.

Right now it is a little inefficient because it's one page per packet
even though two would fit, but these devices have all tiny RX rings
so it's not that big a waste.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
