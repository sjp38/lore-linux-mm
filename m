Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 020D66B00D5
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 06:51:48 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so4632440wiv.1
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:51:47 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id mc6si39784516wjb.36.2014.11.12.03.51.46
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 03:51:46 -0800 (PST)
Date: Wed, 12 Nov 2014 13:51:38 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [next:master 4308/6262]
 arch/sparc/include/asm/pgtable_64.h:674:2: error: incompatible types when
 returning type 'long unsigned int' but 'pmd_t' was expected
Message-ID: <20141112115138.GA22484@node.dhcp.inet.fi>
References: <201411121624.IT6UfpZO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411121624.IT6UfpZO%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Nov 12, 2014 at 04:23:26PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   ebc7163fafb29c390519378897c201748acc2756
> commit: 3ba93823a8cd96b9408cd738a9dcd774a9423a04 [4308/6262] mm: fix huge zero page accounting in smaps report
> config: sparc64-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 3ba93823a8cd96b9408cd738a9dcd774a9423a04
>   # save the attached .config to linux build tree
>   make.cross ARCH=sparc64 
> 
> All error/warnings:
> 
>    In file included from arch/sparc/include/asm/pgtable.h:4:0,
>                     from include/linux/mm.h:52,
>                     from include/linux/scatterlist.h:6,
>                     from include/linux/dma-mapping.h:9,
>                     from arch/sparc/include/asm/pci_64.h:6,
>                     from arch/sparc/include/asm/pci.h:4,
>                     from include/linux/pci.h:1440,
>                     from drivers/scsi/aic94xx/aic94xx_init.c:30:
>    arch/sparc/include/asm/pgtable_64.h: In function 'pmd_dirty':
> >> arch/sparc/include/asm/pgtable_64.h:674:2: error: incompatible types when returning type 'long unsigned int' but 'pmd_t' was expected
>      return pte_dirty(pte);
>      ^
> --
>    In file included from arch/sparc/include/asm/pgtable.h:4:0,
>                     from include/linux/mm.h:52,
>                     from fs/proc/task_mmu.c:1:
>    arch/sparc/include/asm/pgtable_64.h: In function 'pmd_dirty':
> >> arch/sparc/include/asm/pgtable_64.h:674:2: error: incompatible types when returning type 'long unsigned int' but 'pmd_t' was expected
>      return pte_dirty(pte);
>      ^
>    fs/proc/task_mmu.c: In function 'smaps_pmd_entry':
> >> fs/proc/task_mmu.c:523:2: error: incompatible type for argument 5 of 'smaps_account'
>      smaps_account(mss, page, HPAGE_PMD_SIZE,
>      ^
>    fs/proc/task_mmu.c:450:13: note: expected 'bool' but argument is of type 'pmd_t'
>     static void smaps_account(struct mem_size_stats *mss, struct page *page,
>                 ^
> 
> vim +674 arch/sparc/include/asm/pgtable_64.h
> 
>    668	
>    669	#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>    670	static inline pmd_t pmd_dirty(pmd_t pmd)
>    671	{
>    672		pte_t pte = __pte(pmd_val(pmd));
>    673	
>  > 674		return pte_dirty(pte);
>    675	}
>    676	
>    677	static inline unsigned long pmd_young(pmd_t pmd)

Return type should be 'unsigned long'.

Andrew, please fold this into the patch:

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 90af17ee6184..1ff9e7864168 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -667,7 +667,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline pmd_t pmd_dirty(pmd_t pmd)
+static inline unsigned long pmd_dirty(pmd_t pmd)
 {
        pte_t pte = __pte(pmd_val(pmd));
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
