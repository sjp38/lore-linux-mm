Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDC606B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 05:45:35 -0400 (EDT)
Date: Thu, 27 Aug 2009 10:45:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Message-ID: <20090827094539.GA21183@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <_yaHeGjHEzG.A.FIH.7sGlKB@chimera> <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com> <20090826082741.GA25955@cmpxchg.org> <20090826093747.GA10955@csn.ul.ie> <20090826074409.606b5124.akpm@linux-foundation.org> <1251364289.3704.176.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251364289.3704.176.camel@debian>
Sender: owner-linux-mm@kvack.org
To: Zhu Yi <yi.zhu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 27, 2009 at 05:11:29PM +0800, Zhu Yi wrote:
> On Wed, 2009-08-26 at 22:44 +0800, Andrew Morton wrote:
> > 
> > It is perhaps pretty simple to make the second (GFP_ATOMIC) allocation
> > go away.  The code is already conveniently structured to do this:
> > 
> >         do {
> >                 chunk = (struct fw_chunk *)(data + offset);
> >                 offset += sizeof(struct fw_chunk);
> >                 /* build DMA packet and queue up for sending */
> >                 /* dma to chunk->address, the chunk->length bytes from
> > data +
> >                  * offeset*/
> >                 /* Dma loading */
> >                 rc = ipw_fw_dma_add_buffer(priv, shared_phys + offset,
> > 
> > le32_to_cpu(chunk->address),
> > 
> > le32_to_cpu(chunk->length));
> >                 if (rc) {
> >                         IPW_DEBUG_INFO("dmaAddBuffer Failed\n");
> >                         goto out;
> >                 }
> > 
> >                 offset += le32_to_cpu(chunk->length);
> >         } while (offset < len);
> > 
> > what is the typical/expected value of chunk->length here?  If it's
> > significantly less than 4096*(2^6), could we convert this function to
> > use a separate DMAable allocation per fw_chunk?
> 
> Unfortunately, the largest chunk size for the latest 3.1 firmware is
> 0x20040, which also requires order 6 page allocation. I'll try to use
> the firmware DMA command block (64 slots) to handle the image (each for
> 4k, totally 256k).
> 

That would be preferable as trying to make alloc-6 atomic allocations isn't
going to pan out. As I noted, doing it as GFP_KERNEL is possible but it'll
manifest as weird stalls periodically when the driver is loaded due to
reclaim and if the system is swapless, it might not work at all if memory
is mostly anonymous.

If the DMA command block doesn't work out, what is the feasibility of holding
onto the order-6 allocation once the module is loaded instead of allocing
for the duration of the firmware loading and then freeing it again?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
