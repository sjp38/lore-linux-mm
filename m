Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E1C3C6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 07:45:08 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so63803410wiw.0
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 04:45:08 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id ju8si25372542wid.83.2015.06.23.04.45.06
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 04:45:07 -0700 (PDT)
Date: Tue, 23 Jun 2015 14:44:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Fix MAP_POPULATE and mlock() for DAX
Message-ID: <20150623114453.GA8603@node.dhcp.inet.fi>
References: <1434493710-11138-1-git-send-email-toshi.kani@hp.com>
 <20150620194612.GA5268@node.dhcp.inet.fi>
 <1435006555.11808.210.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435006555.11808.210.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, willy@linux.intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Mon, Jun 22, 2015 at 02:55:55PM -0600, Toshi Kani wrote:
> On Sat, 2015-06-20 at 22:46 +0300, Kirill A. Shutemov wrote:
> > On Tue, Jun 16, 2015 at 04:28:30PM -0600, Toshi Kani wrote:
> > > DAX has the following issues in a shared or read-only private
> > > mmap'd file.
> > >  - mmap(MAP_POPULATE) does not pre-fault
> > >  - mlock() fails with -ENOMEM
> > > 
> > > DAX uses VM_MIXEDMAP for mmap'd files, which do not have struct
> > > page associated with the ranges.  Both MAP_POPULATE and mlock()
> > > call __mm_populate(), which in turn calls __get_user_pages().
> > > Because __get_user_pages() requires a valid page returned from
> > > follow_page_mask(), MAP_POPULATE and mlock(), i.e. FOLL_POPULATE,
> > > fail in the first page.
> > > 
> > > Change __get_user_pages() to proceed FOLL_POPULATE when the
> > > translation is set but its page does not exist (-EFAULT), and
> > > @pages is not requested.  With that, MAP_POPULATE and mlock()
> > > set translations to the requested range and complete successfully.
> > > 
> > > MAP_POPULATE still provides a major performance improvement to
> > > DAX as it will avoid page faults during initial access to the
> > > pages.
> > > 
> > > mlock() continues to set VM_LOCKED to vma and populate the range.
> > > Since there is no struct page, the range is pinned without marking
> > > pages mlocked.
> > > 
> > > Note, MAP_POPULATE and mlock() already work for a write-able
> > > private mmap'd file on DAX since populate_vma_page_range() breaks
> > > COW, which allocates page caches.
> > 
> > I don't think that's true in all cases.
> > 
> > We would fail to break COW for mlock() if the mapping is populated with
> > read-only entries by the mlock() time. In this case follow_page_mask()
> > would fail with -EFAULT and faultin_page() will never executed.
> 
> No, mlock() always breaks COW as populate_vma_page_range() sets
> FOLL_WRITE in case of write-able private mmap.
> 
>   /*
>    * We want to touch writable mappings with a write fault in order
>    * to break COW, except for shared mappings because these don't COW
>    * and we would not want to dirty them for nothing.
>    */
>   if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
>            gup_flags |= FOLL_WRITE;

Okay, you're right it should work.

What about doing this in more generic way? The totally untested patch
below tries to make GUP work on DAX and other pfn maps when struct page
is not required.

Any comments?

diff --git a/mm/gup.c b/mm/gup.c
index 222d57e335f9..03645f400748 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -33,6 +33,30 @@ static struct page *no_page_table(struct vm_area_struct *vma,
 	return NULL;
 }
 
+static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, unsigned int flags)
+{
+	/* No page to get reference */
+	if (flags & FOLL_GET)
+		return -EFAULT;
+
+	if (flags & FOLL_TOUCH) {
+		pte_t entry = *pte;
+
+		if (flags & FOLL_WRITE)
+			entry = pte_mkdirty(entry);
+		entry = pte_mkyoung(entry);
+
+		if (!pte_same(*pte, entry)) {
+			set_pte_at(vma->vm_mm, address, pte, entry);
+			update_mmu_cache(vma, address, pte);
+		}
+	}
+
+	/* Proper page table entry exists, but no corresponding struct page */
+	return -EEXIST;
+}
+
 static struct page *follow_page_pte(struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
@@ -74,10 +98,21 @@ retry:
 
 	page = vm_normal_page(vma, address, pte);
 	if (unlikely(!page)) {
-		if ((flags & FOLL_DUMP) ||
-		    !is_zero_pfn(pte_pfn(pte)))
-			goto bad_page;
-		page = pte_page(pte);
+		if (flags & FOLL_DUMP) {
+			/* Avoid special (like zero) pages in core dumps */
+			page = ERR_PTR(-EFAULT);
+			goto out;
+		}
+
+		if (is_zero_pfn(pte_pfn(pte))) {
+			page = pte_page(pte);
+		} else {
+			int ret;
+
+			ret = follow_pfn_pte(vma, address, ptep, flags);
+			page = ERR_PTR(ret);
+			goto out;
+		}
 	}
 
 	if (flags & FOLL_GET)
@@ -115,12 +150,9 @@ retry:
 			unlock_page(page);
 		}
 	}
+out:
 	pte_unmap_unlock(ptep, ptl);
 	return page;
-bad_page:
-	pte_unmap_unlock(ptep, ptl);
-	return ERR_PTR(-EFAULT);
-
 no_page:
 	pte_unmap_unlock(ptep, ptl);
 	if (!pte_none(pte))
@@ -490,9 +522,15 @@ retry:
 				goto next_page;
 			}
 			BUG();
-		}
-		if (IS_ERR(page))
+		} else if (PTR_ERR(page) == -EEXIST) {
+			/*
+			 * Proper page table entry exists, but no corresponding
+			 * struct page.
+			 */
+			goto next_page;
+		} else if (IS_ERR(page)) {
 			return i ? i : PTR_ERR(page);
+		}
 		if (pages) {
 			pages[i] = page;
 			flush_anon_page(vma, page, start);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
