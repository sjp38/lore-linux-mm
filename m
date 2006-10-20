Date: Fri, 20 Oct 2006 10:35:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <20061020103534.35a92813.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0610190940140.8072@schroedinger.engr.sgi.com>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610190940140.8072@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006 09:41:19 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 19 Oct 2006, KAMEZAWA Hiroyuki wrote:
> 
> > +config ARCH_VMEMMAP_SPARSEMEM_SUPPORT
> > +	def_bool y
> > +	depends on PGTABLE_4 && ARCH_SPARSEMEM_ENABLE
> 
> Why do you need to depend on 4 level page tables?
> 
It's based on how big page-table can map. (I'm sorry if my calculation is wrong..)

Maximun phyisical address size of Itanium2 looks 50bits. Then, we need
sizeof (struct page) * (50 - PAGE_SHIFT) size of virtual address space.

#define PTRS_PER_PTD_SHIFT      (PAGE_SHIFT-3)
#define PTRS_PER_PTE    (__IA64_UL(1) << (PTRS_PER_PTD_SHIFT))
#define PMD_SHIFT       (PAGE_SHIFT + (PTRS_PER_PTD_SHIFT))
#define PUD_SHIFT       (PMD_SHIFT + (PTRS_PER_PTD_SHIFT))

#ifdef CONFIG_PGTABLE_4
#define PGDIR_SHIFT             (PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
#else
#define PGDIR_SHIFT             (PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
#endif

Then, considering PAGE_SHIFT=14 case, 
4-level-page-table mapsize:(1 << (4 * PAGE_SHIFT - 9) -> (1 << 47)
3-level-page-table mapsize:(1 << (3 * PAGE_SHIFT - 6) -> (1 << 36)

we need 4 level.


> > +#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_VMEMMAP_SPARSEMEM)
> >  unsigned long vmalloc_end = VMALLOC_END_INIT;
> 
> I'd rather stop tinkering around with vmalloc_end. See my patches that I 
> posted last week to realize virtual memmap.
Okay, I'll look into.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
