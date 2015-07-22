Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2CB9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:13:23 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so96806751wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:13:22 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id pd7si1954549wjb.51.2015.07.22.04.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 04:13:21 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so96805338wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:13:20 -0700 (PDT)
Date: Wed, 22 Jul 2015 14:13:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4 3/6] mm: gup: Add mm_lock_present()
Message-ID: <20150722111317.GB8630@node.dhcp.inet.fi>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-4-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437508781-28655-4-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 03:59:38PM -0400, Eric B Munson wrote:
> The upcoming mlock(MLOCK_ONFAULT) implementation will need a way to
> request that all present pages in a range are locked without faulting in
> pages that are not present.  This logic is very close to what the
> __mm_populate() call handles without faulting pages so the patch pulls
> out the pieces that can be shared and adds mm_lock_present() to gup.c.
> The following patch will call it from do_mlock() when MLOCK_ONFAULT is
> specified.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/gup.c | 172 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 157 insertions(+), 15 deletions(-)

I don't like that you've copy-pasted a lot of code. I think it can be
solved with new foll flags.

Totally untested patch below split out mlock part of FOLL_POPULATE into
new FOLL_MLOCK flag. FOLL_POPULATE | FOLL_MLOCK will do what currently
FOLL_POPULATE does. The new MLOCK_ONFAULT can use just FOLL_MLOCK. It will
not trigger fault in.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c3a2b37365f6..c3834cddfcc7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2002,6 +2002,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
 #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
+#define FOLL_MLOCK	0x1000	/* mlock the page if the VMA is VM_LOCKED */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/gup.c b/mm/gup.c
index a798293fc648..4c7ff23947b9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -129,7 +129,7 @@ retry:
 		 */
 		mark_page_accessed(page);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		/*
 		 * The preliminary mapping check is mainly to avoid the
 		 * pointless overhead of lock_page on the ZERO_PAGE
@@ -299,6 +299,9 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	unsigned int fault_flags = 0;
 	int ret;
 
+	/* mlock present pages, but not fault in new one */
+	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
+		return -ENOENT;
 	/* For mm_populate(), just skip the stack guard page. */
 	if ((*flags & FOLL_POPULATE) &&
 			(stack_guard_page_start(vma, address) ||
@@ -890,7 +893,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
-	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
+	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8f9a334a6c66..9eeb3bd304fc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1306,7 +1306,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  pmd, _pmd,  1))
 			update_mmu_cache_pmd(vma, addr, pmd);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
