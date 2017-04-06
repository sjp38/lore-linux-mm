Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 498746B0430
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:05:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so37234627pgh.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:05:13 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0065.outbound.protection.outlook.com. [104.47.41.65])
        by mx.google.com with ESMTPS id b199si1962822pfb.213.2017.04.06.07.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 07:05:12 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <f46ff1e1-1cc7-1907-74a0-e2709fa1e5fb@amd.com>
Date: Thu, 6 Apr 2017 09:05:03 -0500
MIME-Version: 1.0
In-Reply-To: <20170317101737.icdois7sdmtutt6b@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedo.suse.de

Hi Boris,

On 03/17/2017 05:17 AM, Borislav Petkov wrote:
> On Thu, Mar 16, 2017 at 11:25:36PM +0100, Paolo Bonzini wrote:
>> The kvmclock memory is initially zero so there is no need for the
>> hypervisor to allocate anything; the point of these patches is just to
>> access the data in a natural way from Linux source code.
>
> I realize that.
>
>> I also don't really like the patch as is (plus it fails modpost), but
>> IMO reusing __change_page_attr and __split_large_page is the right thing
>> to do.
>
> Right, so teaching pageattr.c about memblock could theoretically come
> around and bite us later when a page allocated with memblock gets freed
> with free_page().
>
> And looking at this more, we have all this kernel pagetable preparation
> code down the init_mem_mapping() call and the pagetable setup in
> arch/x86/mm/init_{32,64}.c
>
> And that code even does some basic page splitting. Oh and it uses
> alloc_low_pages() which knows whether to do memblock reservation or the
> common __get_free_pages() when slabs are up.
>

I looked into arch/x86/mm/init_{32,64}.c and as you pointed the file contains
routines to do basic page splitting. I think it sufficient for our usage.

I should be able to drop the memblock patch from the series and update the
Patch 15 [1] to use the kernel_physical_mapping_init().

The kernel_physical_mapping_init() creates the page table mapping using
default KERNEL_PAGE attributes, I tried to extend the function by passing
'bool enc' flags to hint whether to clr or set _PAGE_ENC when splitting the
pages. The code did not looked clean hence I dropped that idea. Instead,
I took the below approach. I did some runtime test and it seem to be working okay.

[1] http://marc.info/?l=linux-mm&m=148846773731212&w=2

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 7df5f4c..de16ef4 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -15,6 +15,7 @@
  #include <linux/mm.h>
  #include <linux/dma-mapping.h>
  #include <linux/swiotlb.h>
+#include <linux/mem_encrypt.h>
  
  #include <asm/tlbflush.h>
  #include <asm/fixmap.h>
@@ -22,6 +23,8 @@
  #include <asm/bootparam.h>
  #include <asm/cacheflush.h>
  
+#include "mm_internal.h"
+
  extern pmdval_t early_pmd_flags;
  int __init __early_make_pgtable(unsigned long, pmdval_t);
  void __init __early_pgtable_flush(void);
@@ -258,6 +261,72 @@ static void sme_free(struct device *dev, size_t size, void *vaddr,
         swiotlb_free_coherent(dev, size, vaddr, dma_handle);
  }
  
+static int __init early_set_memory_enc_dec(resource_size_t paddr,
+                                          unsigned long size, bool enc)
+{
+       pte_t *kpte;
+       int level;
+       unsigned long vaddr, vaddr_end, vaddr_next;
+
+       vaddr = (unsigned long)__va(paddr);
+       vaddr_next = vaddr;
+       vaddr_end = vaddr + size;
+
+       /*
+        * We are going to change the physical page attribute from C=1 to C=0.
+        * Flush the caches to ensure that all the data with C=1 is flushed to
+        * memory. Any caching of the vaddr after function returns will
+        * use C=0.
+        */
+       clflush_cache_range(__va(paddr), size);
+
+       for (; vaddr < vaddr_end; vaddr = vaddr_next) {
+               kpte = lookup_address(vaddr, &level);
+               if (!kpte || pte_none(*kpte) )
+                       return 1;
+
+               if (level == PG_LEVEL_4K) {
+                       pte_t new_pte;
+                       unsigned long pfn = pte_pfn(*kpte);
+                       pgprot_t new_prot = pte_pgprot(*kpte);
+
+                       if (enc)
+                               pgprot_val(new_prot) |= _PAGE_ENC;
+                       else
+                               pgprot_val(new_prot) &= ~_PAGE_ENC;
+
+                       new_pte = pfn_pte(pfn, canon_pgprot(new_prot));
+                       pr_info("  pte %016lx -> 0x%016lx\n", pte_val(*kpte),
+                               pte_val(new_pte));
+                       set_pte_atomic(kpte, new_pte);
+                       vaddr_next = (vaddr & PAGE_MASK) + PAGE_SIZE;
+                       continue;
+               }
+
+               /*
+                * virtual address is part of large page, create the page
+                * table mapping to use smaller pages (4K). The virtual and
+                * physical address must be aligned to PMD level.
+                */
+               kernel_physical_mapping_init(__pa(vaddr & PMD_MASK),
+                                            __pa((vaddr_end & PMD_MASK) + PMD_SIZE),
+                                            0);
+       }
+
+       __flush_tlb_all();
+       return 0;
+}
+
+int __init early_set_memory_decrypted(resource_size_t paddr, unsigned long size)
+{
+       return early_set_memory_enc_dec(paddr, size, false);
+}
+
+int __init early_set_memory_encrypted(resource_size_t paddr, unsigned long size)
+{
+       return early_set_memory_enc_dec(paddr, size, true);
+}
+

> So what would be much cleaner, IMHO, is if one would reuse that code to
> change init_mm.pgd mappings early without copying pageattr.c.
>
> init_mem_mapping() gets called before kvm_guest_init() in setup_arch()
> so the guest would simply fixup its pagetable right there.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
