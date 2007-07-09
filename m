Message-ID: <4691E64F.5070506@yahoo.com.au>
Date: Mon, 09 Jul 2007 17:39:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
References: <1183952874.3388.349.camel@localhost.localdomain>	 <1183962981.5961.3.camel@localhost.localdomain> <1183963544.5961.6.camel@localhost.localdomain>
In-Reply-To: <1183963544.5961.6.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> Use mmu_gather for fork() instead of flush_tlb_mm()
> 
> This patch uses an mmu_gather for copying page tables instead of
> flush_tlb_mm(). This allows archs like ppc32 with hash table to
> avoid walking the page tables a second time to invalidate hash
> entries, and to only flush PTEs that have actually been changed
> from RW to RO.
> 
> Note that this contain a small change to the mmu gather stuff,
> it must not call free_pages_and_swap_cache() if no page have been
> queued up for freeing (if we are only invalidating PTEs). Calling
> it on fork can deadlock (I haven't dug why but it looks like a
> good idea to test anyway if we're going to use the mmu_gather for
> more than just removing pages).
> 
> If the patch gets accepted, I will split that bit from the rest
> of the patch and send it separately.
> 
> The main possible issue I see is with huge pages. Arch code might
> have relied on flush_tlb_mm() and might not cope with
> tlb_remove_tlb_entry() called for huge PTEs.
> 
> Other possible issues are if archs make assumptions about
> flush_tlb_mm() being called in fork for different unrelated reasons.
> 
> Ah also, we could probably improve the tracking of start/end, in
> the case of lock breaking, the outside function will still finish
> the batch with the entire range. It doesn't matter on ppc and x86
> I think though.

Would it be better off to start off with a new API for this? The
mmu gather I think is traditionally entirely for dealing with
page removal...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
