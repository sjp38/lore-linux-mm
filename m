Date: Fri, 20 Oct 2006 10:18:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006 09:39:55 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 19 Oct 2006, KAMEZAWA Hiroyuki wrote:
> 
> > For make patches simple, pfn_valid() uses sparsemem's logic. 
> 
> Hmm... pfn_valid is much less costly if you use ia64's scheme.
> You can simply probe without having to walk tables.
> 
Yes. but it seems to need per-arch implementation (in page fault handler).
like this (from ia64)
==
#ifdef CONFIG_VIRTUAL_MEM_MAP
        /*
         * If fault is in region 5 and we are in the kernel, we may already
         * have the mmap_sem (pfn_valid macro is called during mmap). There
         * is no vma for region 5 addr's anyway, so skip getting the semaphore
         * and go directly to the exception handling code.
         */

        if ((REGION_NUMBER(address) == 5) && !user_mode(regs))
                goto bad_area_no_up;
#endif
==

Maybe extra optimization patch can be discussed after this generic code is settled.


> > This patch maps sparsemem's *sparse* memmap into contiguous virtual address range
> > starting from virt_memmap_start.
> 
> Could you make that a static address instead of a variable? Also we 
> already have vmem_map (ia64 specific) and mem_map. The logic here is the 
> same as FLATMEM. Why not use the definitions for FLATMEM?
It depends on how #ifdef looks. Here, I just wanted to throw this stuff into
SPARSEMEM subsystem.

>  
> > * memmap is allocated per SECTION_SIZE, so there will be some of RESERVED pages.
> > * no holes in MAX_ORDER range. so HOLE_IN_ZONE=n here.
> 
> Good. Had a patch here to do the same but I do not have time to get to 
> it. Surely wish that this will become the default config and that we can 
> get rid of at least some of the memory models.
> 
> > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > +extern struct page *virt_memmap_start;
> 
> extern struct page[] would be better performance wise. Use the definitions 
> for FLATMEM?
Okay. will make it as array. or some constant value.

> 
> > +		if (pte_none(*pte))
> > +			set_pte(pte, pfn_pte(__pa(map) >> PAGE_SHIFT, PAGE_KERNEL));
> 
> Would it be possible to add support for larger page sizes? On x86_64 we 
> probably would like to use 2MB pages and it may be good to have 
> configurable page size on ia64.
> 
> The virtual memmap has the potential of becoming the default for x86_64 
> and many other platforms that already map memory. There is no performance 
> difference between FLATMEM and this virtual memmap approach if there are 
> already mappings in play.
> 
Hmm, adding CONFIG_HAVE_ARCH_LARGE_KERNEL_PAGE_MAPPING will be good ?
We can add per-arch patches afterwards.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
