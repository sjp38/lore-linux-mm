Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2E1676B007E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 11:00:20 -0400 (EDT)
From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [Linaro-mm-sig] [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Sat, 9 Jul 2011 16:57:07 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <alpine.LFD.2.00.1107061034200.14596@xanadu.home> <201107061659.45253.arnd@arndb.de>
In-Reply-To: <201107061659.45253.arnd@arndb.de>
MIME-Version: 1.0
Message-Id: <201107091657.07925.jkrzyszt@tis.icnet.pl>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-media@vger.kernel.org, Guennadi Liakhovetski <g.liakhovetski@gmx.de>, Marin Mitov <mitov@issp.bas.bg>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

On Wed, 6 Jul 2011 at 16:59:45 Arnd Bergmann wrote:
> On Wednesday 06 July 2011, Nicolas Pitre wrote:
> > On Wed, 6 Jul 2011, Russell King - ARM Linux wrote:
> > > Another issue is that when a platform has restricted DMA regions,
> > > they typically don't fall into the highmem zone.  As the
> > > dmabounce code allocates from the DMA coherent allocator to
> > > provide it with guaranteed DMA-able memory, that would be rather
> > > inconvenient.
> > 
> > Do we encounter this in practice i.e. do those platforms requiring
> > large contiguous allocations motivating this work have such DMA
> > restrictions?
> 
> You can probably find one or two of those, but we don't have to
> optimize for that case. I would at least expect the maximum size of
> the allocation to be smaller than the DMA limit for these, and
> consequently mandate that they define a sufficiently large
> CONSISTENT_DMA_SIZE for the crazy devices, or possibly add a hack to
> unmap some low memory and call
> dma_declare_coherent_memory() for the device.

Once found that Russell has dropped his "ARM: DMA: steal memory for DMA 
coherent mappings" for now, let me get back to this idea of a hack that 
would allow for safely calling dma_declare_coherent_memory() in order to 
assign a device with a block of contiguous memory for exclusive use. 
Assuming there should be no problem with successfully allocating a large 
continuous block of coherent memory at boot time with 
dma_alloc_coherent(), this block could be reserved for the device. The 
only problem is with the dma_declare_coherent_memory() calling 
ioremap(), which was designed with a device's dedicated physical memory 
in mind, but shouldn't be called on a memory already mapped.

There were three approaches proposed, two of them in August 2010:
http://www.spinics.net/lists/linux-media/msg22179.html,
http://www.spinics.net/lists/arm-kernel/msg96318.html,
and a third one in January 2011:
http://www.spinics.net/lists/linux-arch/msg12637.html.

As far as I can understand the reason why both of the first two were 
NAKed, it was suggested that videobuf-dma-contig shouldn't use coherent 
if all it requires is a contiguous memory, and a new API should be 
invented, or dma_pool API extended, for providing contiguous memory. The 
CMA was pointed out as a new work in progress contiguous memory API. Now 
it turns out it's not, it's only a helper to ensure that 
dma_alloc_coherent() always succeeds, and videobuf2-dma-contig is still 
going to allocate buffers from coherent memory.

(CCing both authors, Marin Mitov and Guennadi Liakhovetski, and their 
main opponent, FUJITA Tomonori)

The third solution was not discussed much after it was pointed out as 
being not very different from those two in terms of the above mentioned 
rationale.

All three solutions was different from now suggested method of unmapping 
some low memory and then calling dma_declare_coherent_memory() which 
ioremaps it in that those tried to reserve some boot time allocated 
coherent memory, already mapped correctly, without (io)remapping it.

If there are still problems with the CMA on one hand, and a need for a 
hack to handle "crazy devices" is still seen, regardless of CMA 
available and working or not, on the other, maybe we should get back to 
the idea of adopting coherent API to new requirements, review those 
three proposals again and select one which seems most acceptable to 
everyone? Being a submitter of the third, I'll be happy to refresh it if 
selected.

Thanks,
Janusz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
