From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Tue, 24 Jul 2007 11:40:12 +1000
Message-ID: <200707241140.12945.nickpiggin@yahoo.com.au>
References: <49416494.6040009@goop.org> <200707241052.13825.nickpiggin@yahoo.com.au> <4941C568.4070207@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758222AbYLLCSI@vger.kernel.org>
In-Reply-To: <4941C568.4070207@goop.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-Id: linux-mm.kvack.org

On Friday 12 December 2008 12:59, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > Hi,
> >
> > On Friday 12 December 2008 06:05, Jeremy Fitzhardinge wrote:
> >> Hi Nick,
> >>
> >> In Xen when we're killing the lazy vmalloc aliases, we're only concerned
> >> about the pagetable references to the mapped pages, not the TLB entries.
> >
> > Hm? Why is that? Why wouldn't it matter if some page table page gets
> > written to via a stale TLB?
>
> No.  Well, yes, it would, but Xen itself will do whatever tlb flushes
> are necessary to keep it safe (it must, since it doesn't trust guest
> kernels).  It's fairly clever about working out which cpus need flushing
> and if other flushes have already done the job.

OK. Yeah, then the problem is simply that the guest may reuse that virtual
memory for another vmap.


> >> For the most part eliminating the TLB flushes would be a performance
> >> optimisation, but there's at least one case where we need to shoot down
> >> aliases in an interrupt-disabled section, so the TLB shootdown IPIs
> >> would potentially deadlock.
> >
> > So... 2.6.28 is deadlocky for you?
>
> No.  The deadlock is in the new dom0 code I'm working on.  I haven't
> posted it yet (well, it hasn't been merged).

OK, good.


> In this case, I'm swizzling the physical pages underlying a piece of
> guest pseudo-physical memory so that it is physically contiguous and/or
> under the device limit, so I can set up DMA buffers, swiotlb memory,
> etc.  This requires removing the mappings to the old pages and replacing
> them with new mappings, but I need to make sure the old pages have no
> other aliases before I can release them back to Xen.  (This can all
> happen in dma_alloc_coherent in a device driver with interrupts
> disabled, so the IPI causes deadlock warnings.)
>
> The TLB is irrelevant because Xen will make sure any stale entries are
> flushed appropriately before giving those pages out to any other domain.

OK.


> >> I'm wondering what your thoughts are about this approach?
> >
> > Doesn't work, because that's allowing virtual addresses to be reused
> > before they have TLBs flushed.
>
> Right, I see.  It's a question of flush on unmap or flush on map.

Yes. And flushing on unmap is easier of course, because we know exactly
what we've just unmapped.


> > You could have a xen specific function which goes through the lazy maps
> > and unmaps their page tables, but leaves them in the virtual address
> > allocator (so a subsequent lazy flush will still do the TLB flush before
> > allowing the addresses to be reused).
>
> Yes, that would work.

That would be my preferred approach.
