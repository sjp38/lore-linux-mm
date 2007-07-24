From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Tue, 24 Jul 2007 10:52:13 +1000
Message-ID: <200707241052.13825.nickpiggin@yahoo.com.au>
References: <49416494.6040009@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757903AbYLLBaW@vger.kernel.org>
In-Reply-To: <49416494.6040009@goop.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-Id: linux-mm.kvack.org

Hi,

On Friday 12 December 2008 06:05, Jeremy Fitzhardinge wrote:
> Hi Nick,
>
> In Xen when we're killing the lazy vmalloc aliases, we're only concerned
> about the pagetable references to the mapped pages, not the TLB entries.

Hm? Why is that? Why wouldn't it matter if some page table page gets
written to via a stale TLB?


> For the most part eliminating the TLB flushes would be a performance
> optimisation, but there's at least one case where we need to shoot down
> aliases in an interrupt-disabled section, so the TLB shootdown IPIs
> would potentially deadlock.

So... 2.6.28 is deadlocky for you?


> I'm wondering what your thoughts are about this approach?

Doesn't work, because that's allowing virtual addresses to be reused
before they have TLBs flushed.

You could have a xen specific function which goes through the lazy maps
and unmaps their page tables, but leaves them in the virtual address
allocator (so a subsequent lazy flush will still do the TLB flush before
allowing the addresses to be reused).


> I'm not super-happy with the changes to __purge_vmap_area_lazy(), but
> given that we need a tri-state policy selection there, adding an enum is
> clearer than adding another boolean argument.
>
> It also raises the question of how many callers of vm_unmap_aliases()
> really care about flushing the tlbs. Presumably if we're shooting down
> some stray vmalloc mappings then nobody is actually using them at the
> time, and any corresponding TLB entries are residual. Or does leaving
> them around leave open the possibility of unwanted speculative
> references which could violate memory type rules?  Perhaps callers who
> care about that could arrange their own tlb flush?

The whole lazy flush requires the TLB flush because the core vmalloc
code needs to flush before reallocating. So it can't really go into
the caller.

PAT needs the TLBs flushed, definitely.

I'm surprised that Xen doesn't... but let's hear it :)
