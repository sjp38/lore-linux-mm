Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF01A6B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 10:45:35 -0400 (EDT)
Date: Wed, 26 Aug 2009 07:44:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Message-Id: <20090826074409.606b5124.akpm@linux-foundation.org>
In-Reply-To: <20090826093747.GA10955@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera>
	<_yaHeGjHEzG.A.FIH.7sGlKB@chimera>
	<84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com>
	<20090826082741.GA25955@cmpxchg.org>
	<20090826093747.GA10955@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mel Gorman <mel@skynet.ie>, netdev@vger.kernel.org, linux-mm@kvack.org, Zhu Yi <yi.zhu@intel.com>, James Ketrenos <jketreno@linux.intel.com>, Reinette Chatre <reinette.chatre@intel.com>, linux-wireless@vger.kernel.org, ipw2100-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

(cc IPW maintainers and mailing lists)

On Wed, 26 Aug 2009 10:37:49 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Aug 26, 2009 at 10:27:41AM +0200, Johannes Weiner wrote:
> > [Cc netdev]
> > 
> > On Wed, Aug 26, 2009 at 09:09:44AM +0300, Pekka Enberg wrote:
> > > On Tue, Aug 25, 2009 at 11:34 PM, Rafael J. Wysocki<rjw@sisk.pl> wrote:
> > > > This message has been generated automatically as a part of a report
> > > > of recent regressions.
> > > >
> > > > The following bug entry is on the current list of known regressions
> > > > from 2.6.30. __Please verify if it still should be listed and let me know
> > > > (either way).
> > > >
> > > > Bug-Entry __ __ __ : http://bugzilla.kernel.org/show_bug.cgi?id=14016
> > > > Subject __ __ __ __ : mm/ipw2200 regression
> > > > Submitter __ __ __ : Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> > > > Date __ __ __ __ __ __: 2009-08-15 16:56 (11 days old)
> > > > References __ __ __: http://marc.info/?l=linux-kernel&m=125036437221408&w=4
> > > 
> > > If am reading the page allocator dump correctly, there's plenty of
> > > pages left but we're unable to satisfy an order 6 allocation. There's
> > > no slab allocator involved so the page allocator changes that went
> > > into 2.6.31 seem likely. Mel, ideas?
> > 
> > It's an atomic order-6 allocation, the chances for this to succeed
> > after some uptime become infinitesimal.  The chunks > order-2 are
> > pretty much exhausted on this dump.
> > 
> > 64 pages, presumably 256k, for fw->boot_size while current ipw
> > firmware images have ~188k.  I don't know jack squat about this
> > driver, but given the field name and the struct:
> > 
> > 	struct ipw_fw {
> > 		__le32 ver;
> > 		__le32 boot_size;
> > 		__le32 ucode_size;
> > 		__le32 fw_size;
> > 		u8 data[0];
> > 	};
> > 
> > fw->boot_size alone being that big sounds a bit fishy to me.
> > 
> 
> Agreed. While there are a low number of order-6 pages free in the page
> allocation failure dump, there are not enough for watermarks to be
> satisified. As it's atomic, there is little that can be done from a VM
> perspective and it's the responsibility of the driver. I'm no driver expert
> but I'll have a go at fixing it anyway.
> 
> My reading of this is that the firmware is being loaded from a workqueue and
> I am failing to see any restriction on sleeping in the path. It would appear
> that the driver just used the most convenient *_alloc_coherent function
> available forgetting that it assumes GFP_ATOMIC. Can someone who does know
> which way is up with a driver tell me why the patch below might not
> work?
> 
> Bartlomiej, any chance you could give this a spin? Preferably, you'd
> have preempt enabled and CONFIG_DEBUG_SPINLOCK_SLEEP on as well because
> that combination will complain loudly if we really can't sleep in this
> path.
> 
> =====
> ipw2200: Avoid large GFP_ATOMIC allocation during firmware loading
> 
> ipw2200 uses pci_alloc_consistent() to allocate a large coherent buffer for
> the loading of firmware which is an order-6 allocation of GFP_ATOMIC. At
> system start-up time, this is not a problem. However, the firmware on the
> card can get confused and the corrective action taken is to reload the
> firmware and reinit the card. High-order GFP_ATOMIC allocations of this
> type can and will fail when the system is already up and running.
> 
> As the firmware is loaded from a workqueue, it should be possible for
> the driver to go to sleep. This patch converts the call of
> pci_alloc_consistent() which assumes GFP_ATOMIC to dma_alloc_coherent()
> which can specify its own flags.
> 
> The big downside with this patch is that it uses GFP_REPEAT to avoid the
> driver unloading. There is potential that this will cause a reclaim
> storm as the machine tries to find a free order-6 buffer. A suggested
> alternative for the driver owner is in the comments.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  drivers/net/wireless/ipw2x00/ipw2200.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
> index 44c29b3..f2e251e 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2200.c
> @@ -3167,7 +3167,19 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
>  	u8 *shared_virt;
>  
>  	IPW_DEBUG_TRACE("<< : \n");
> -	shared_virt = pci_alloc_consistent(priv->pci_dev, len, &shared_phys);
> +
> +	/*
> +	 * This is a whopping large allocation, in or around order-6 so
> +	 * dma_alloc_coherent is used to specify the GFP_KERNEL|__GFP_REPEAT
> +	 * flags. Note that this action means the system could go into a
> +	 * reclaim loop until it cannot reclaim any more trying to satisfy
> +	 * the allocation. It would be preferable if one buffer is allocated
> +	 * at driver initialisation and reused when the firmware needs to
> +	 * be reloaded, overwriting the existing firmware each time
> +	 */
> +	shared_virt = dma_alloc_coherent(
> +			priv->pci_dev == NULL ? NULL : &priv->pci_dev->dev, 
> +			len, &shared_phys, GFP_KERNEL|__GFP_REPEAT);
>  
>  	if (!shared_virt)
>  		return -ENOMEM;

Of course, the risk of making a change like this is that we'll then go
and leave it there.

To fix this code properly we should, as you say, stop doing an order-6
allocation altogether.

And right now I think it's doing _two_ order-6 allocations:

	shared_virt = pci_alloc_consistent(priv->pci_dev, len, &shared_phys);

	if (!shared_virt)
		return -ENOMEM;

	memmove(shared_virt, data, len);

whoever allocated `data' is being obnoxious as well.

It is perhaps pretty simple to make the second (GFP_ATOMIC) allocation
go away.  The code is already conveniently structured to do this:

	do {
		chunk = (struct fw_chunk *)(data + offset);
		offset += sizeof(struct fw_chunk);
		/* build DMA packet and queue up for sending */
		/* dma to chunk->address, the chunk->length bytes from data +
		 * offeset*/
		/* Dma loading */
		rc = ipw_fw_dma_add_buffer(priv, shared_phys + offset,
					   le32_to_cpu(chunk->address),
					   le32_to_cpu(chunk->length));
		if (rc) {
			IPW_DEBUG_INFO("dmaAddBuffer Failed\n");
			goto out;
		}

		offset += le32_to_cpu(chunk->length);
	} while (offset < len);

what is the typical/expected value of chunk->length here?  If it's
significantly less than 4096*(2^6), could we convert this function to
use a separate DMAable allocation per fw_chunk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
