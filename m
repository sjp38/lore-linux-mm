Date: Mon, 27 Aug 2007 14:34:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
Message-Id: <20070827143459.82bdeddd.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
	<20070827133347.424f83a6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
	<20070827140440.d2109ea5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 14:20:57 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> kmap_atomic() does:
> 
> void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
> {
>         enum fixed_addresses idx;
>         unsigned long vaddr;
> 
>         /* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
>         pagefault_disable();
> 
>         idx = type + KM_TYPE_NR*smp_processor_id();
>         BUG_ON(!pte_none(*(kmap_pte-idx)));
> 
>         if (!PageHighMem(page))
>                 return page_address(page);
> 
>         vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>         set_pte(kmap_pte-idx, mk_pte(page, prot));
>         arch_flush_lazy_mmu_mode();
> 
>         return (void*) vaddr;
> }
> 
> Move the check for highmem to the beginning of the function? Why 
> should kmap_atomic fail for a non highmem page?

For test coverage, mainly.  If someone is testing highmem-enabled code on
a 512MB machine, we want them to get told about any highmem-handling bugs,
even though they don't have highmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
