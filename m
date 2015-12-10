Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 881406B0263
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:37:43 -0500 (EST)
Received: by pfdd184 with SMTP id d184so39744986pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:37:43 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 21si16740868pfq.214.2015.12.09.18.37.42
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:37:42 -0800 (PST)
Subject: [-mm PATCH v2 01/25] pmem, dax: clean up clear_pmem()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:37:15 -0800
Message-ID: <20151210023715.30368.74651.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jeff Moyer <jmoyer@redhat.com>, linux-nvdimm@lists.01.org

Both, __dax_pmd_fault, and clear_pmem() were taking special steps to
clear memory a page at a time to take advantage of non-temporal
clear_page() implementations.  However, x86_64 does not use
non-temporal instructions for clear_page(), and arch_clear_pmem() was
always incurring the cost of __arch_wb_cache_pmem().

Clean up the assumption that doing clear_pmem() a page at a time is more
performant.

Reported-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/pmem.h |    7 +------
 fs/dax.c                    |    4 +---
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
index d8ce3ec816ab..1544fabcd7f9 100644
--- a/arch/x86/include/asm/pmem.h
+++ b/arch/x86/include/asm/pmem.h
@@ -132,12 +132,7 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
 {
 	void *vaddr = (void __force *)addr;
 
-	/* TODO: implement the zeroing via non-temporal writes */
-	if (size == PAGE_SIZE && ((unsigned long)vaddr & ~PAGE_MASK) == 0)
-		clear_page(vaddr);
-	else
-		memset(vaddr, 0, size);
-
+	memset(vaddr, 0, size);
 	__arch_wb_cache_pmem(vaddr, size);
 }
 
diff --git a/fs/dax.c b/fs/dax.c
index 43671b68220e..19492cc65a30 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -641,9 +641,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto fallback;
 
 		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-			int i;
-			for (i = 0; i < PTRS_PER_PMD; i++)
-				clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
+			clear_pmem(kaddr, PMD_SIZE);
 			wmb_pmem();
 			count_vm_event(PGMAJFAULT);
 			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
