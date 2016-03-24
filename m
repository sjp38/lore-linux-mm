Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 52E5E6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 05:17:41 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l68so228403048wml.0
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 02:17:41 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id jo9si7994029wjb.100.2016.03.24.02.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Mar 2016 02:17:39 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id u125so4462817wmg.1
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 02:17:39 -0700 (PDT)
Date: Thu, 24 Mar 2016 12:17:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/25] THP-enabled tmpfs/shmem
Message-ID: <20160324091727.GA26796@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603231305560.4946@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Mar 23, 2016 at 01:09:05PM -0700, Hugh Dickins wrote:
> The small files thing formed my first impression.  My second
> impression was similar, when I tried mmap(NULL, size_of_RAM,
> PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0) and
> cycled around the arena touching all the pages (which of
> course has to push a little into swap): that soon OOMed.
> 
> But there I think you probably just have some minor bug to be fixed:
> I spent a little while trying to debug it, but then decided I'd
> better get back to writing to you.  I didn't really understand what
> I was seeing, but when I hacked some stats into shrink_page_list(),
> converting !is_page_cache_freeable(page) to page_cache_references(page)
> to return the difference instead of the bool, a large proportion of
> huge tmpfs pages seemed to have count 1 too high to be freeable at
> that point (and one huge tmpfs page had a count of 3477).

I'll reply to your other points later, but first I wanted to address this
obvious bug.

I cannot really explain page_count() == 3477, but otherwise:

The root cause is that try_to_unmap() doesn't handle PMD-mapped huge
pages, so we hit 'case SWAP_AGAIN' all the time.

The patch below effectively rewrites 17/25: now we split the huge page
before trying to unmap it.

split_huge_page() has its own check similar to is_page_cache_freeable(),
so we woundn't split pages we cannot free later on.

And split_huge_page() for file pages would unmap the page, so we wouldn't
need to go to try_to_unmap() after that.

The patch look rather simple, but I haven't done full validation cycle for
it. Regressions are unlikely, but possible.

At some point we would need to teach try_to_unmap() to handle huge pages.
It would be required for filesystems with backing storage. But I don't see
need for it to get huge tmpfs/shmem work.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9fa9e15594e9..86008f8f1f9b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -473,14 +473,12 @@ void drop_slab(void)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
-	int radix_tree_pins = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
-
 	/*
 	 * A freeable page cache page is referenced only by the caller
 	 * that isolated the page, the page cache radix tree and
 	 * optional buffer heads at page->private.
 	 */
-	return page_count(page) - page_has_private(page) == 1 + radix_tree_pins;
+	return page_count(page) - page_has_private(page) == 2;
 }
 
 static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
@@ -550,6 +548,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * swap_backing_dev_info is bust: it doesn't reflect the
 	 * congestion state of the swapdevs.  Easy to fix, if needed.
 	 */
+	if (!is_page_cache_freeable(page))
+		return PAGE_KEEP;
 	if (!mapping) {
 		/*
 		 * Some data journaling orphaned pages can have
@@ -1055,8 +1055,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			/* Adding to swap updated mapping */
 			mapping = page_mapping(page);
+		} else if (unlikely(PageTransHuge(page))) {
+			/* Split file THP */
+			if (split_huge_page_to_list(page, page_list))
+				goto keep_locked;
 		}
 
+		VM_BUG_ON_PAGE(PageTransHuge(page), page);
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
@@ -1112,15 +1118,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * starts and then write it out here.
 			 */
 			try_to_unmap_flush_dirty();
-
-			if (!is_page_cache_freeable(page))
-				goto keep_locked;
-
-			if (unlikely(PageTransHuge(page))) {
-				if (split_huge_page_to_list(page, page_list))
-					goto keep_locked;
-			}
-
 			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
