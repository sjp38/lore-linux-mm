Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 85ED76B00C1
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 18:08:02 -0400 (EDT)
Message-ID: <516F1D3C.1060804@sr71.net>
Date: Wed, 17 Apr 2013 15:07:56 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of do_huge_linear_fault()
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com> <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com> <51631206.3060605@sr71.net> <20130417143842.1A76CE0085@blue.fi.intel.com>
In-Reply-To: <20130417143842.1A76CE0085@blue.fi.intel.com>
Content-Type: multipart/mixed;
 boundary="------------000600020701070109090502"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------000600020701070109090502
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 04/17/2013 07:38 AM, Kirill A. Shutemov wrote:
>> > Ugh.  This is essentially a copy-n-paste of code in __do_fault(),
>> > including the comments.  Is there no way to consolidate the code so that
>> > there's less duplication here?
> I've looked into it once again and it seems there's not much space for
> consolidation. Code structure looks very similar, but there are many
> special cases for thp: fallback path, pte vs. pmd, etc. I don't see how we
> can consolidate them in them in sane way.
> I think copy is more maintainable :(

I took the two copies, put them each in a file, changed some of the
_very_ trivial stuff to match (foo=1 vs foo=true) and diffed them.
They're very similar lengths (in lines):

 185  __do_fault
 197  do_huge_linear_fault

If you diff them:

 1 file changed, 68 insertions(+), 56 deletions(-)

That means that of 185 lines in __do_fault(), 129 (70%) of them were
copied *VERBATIM*.  Not similar in structure or appearance.  Bit-for-bit
the same.

I took a stab at consolidating them.  I think we could add a
VM_FAULT_FALLBACK flag to explicitly indicate that we need to do a
huge->small fallback, as well as a FAULT_FLAG_TRANSHUGE to indicate that
a given fault has not attempted to be handled by a huge page.  If we
call __do_fault() with FAULT_FLAG_TRANSHUGE and we get back
VM_FAULT_FALLBACK or VM_FAULT_OOM, then we clear FAULT_FLAG_TRANSHUGE
and retry in handle_mm_fault().

I only went about 1/4 of the way in to __do_fault().  If went and spent
another hour or two, I'm pretty convinced I could push this even further.

Are you still sure you can't do _any_ better than a verbatim copy of 129
lines?



--------------000600020701070109090502
Content-Type: text/x-patch;
 name="extend-__do_fault.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="extend-__do_fault.patch"

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..d408b5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -879,6 +879,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
+#define VM_FAULT_FALLBACK 0x0800	/* large page fault failed, fall back to small */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index 494526a..9aced3a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3229,6 +3229,40 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma, unsigned long addr)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+	    (vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK)) {
+		return false;
+	}
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end) {
+		return false;
+	}
+	return true;
+}
+
+static struct page *alloc_fault_page_vma(gfp_t flags, vm_area_struct *vma,
+		unsigned long address, unsigned int flags)
+{
+	int try_huge_pages = flags & FAULT_FLAG_TRANSHUGE;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	if (try_huge_pages) {
+		return alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+				vma, haddr, numa_node_id(), 0);
+	}
+	return alloc_page_vma(flags, vma, address);
+}
+
+static inline void __user *align_fault_address(unsigned long address, unsigned int flags)
+{
+	if (flags & FAULT_FLAG_TRANSHUGE)
+		return (void __user *)address & HPAGE_PMD_MASK;
+	return (void __user *)(address & PAGE_MASK);
+}
+
 /*
  * __do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3256,17 +3290,21 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_fault vmf;
 	int ret;
 	int page_mkwrite = 0;
+	int try_huge_pages = !!(flags & FAULT_FLAG_TRANSHUGE);
+
+	if (try_huge_pages && !transhuge_vma_suitable(vma)) {
+		return VM_FAULT_FALLBACK;
+	}
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
 	 * on the file cache page. This will reduce lock holding time.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
-
 		if (unlikely(anon_vma_prepare(vma)))
 			return VM_FAULT_OOM;
 
-		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		cow_page = alloc_fault_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 		if (!cow_page)
 			return VM_FAULT_OOM;
 
@@ -3277,7 +3315,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		cow_page = NULL;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.virtual_address = align_fault_address(address, flags);
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
@@ -3714,7 +3752,6 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
-
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
@@ -3726,6 +3763,9 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
+	/* We will try a single shot (only if enabled an possible)
+	 * to do a transparent huge page */
+	flags |= FAULT_FLAG_TRANSHUGE;
 retry:
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
@@ -3738,6 +3778,11 @@ retry:
 		if (!vma->vm_ops)
 			return do_huge_pmd_anonymous_page(mm, vma, address,
 							  pmd, flags);
+		ret = __do_fault(mm, vma, address, pmd, ...)
+		if (ret & (VM_FAULT_OOM | VM_FAULT_FALLBACK)) {
+			flags &= ~FAULT_FLAG_TRANSHUGE;
+			goto retry;
+		}
 	} else {
 		pmd_t orig_pmd = *pmd;
 		int ret;

--------------000600020701070109090502--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
