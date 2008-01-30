Date: Wed, 30 Jan 2008 12:03:12 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 3/6] mmu_notifier: invalidate_page callbacks for
	subsystems with rmap
Message-ID: <20080130180312.GV26420@sgi.com>
References: <20080130022909.677301714@sgi.com> <20080130022944.699753910@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130022944.699753910@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is the second part of a patch posted to patch 1/6.


Index: git-linus/mm/rmap.c
===================================================================
--- git-linus.orig/mm/rmap.c	2008-01-30 11:55:56.000000000 -0600
+++ git-linus/mm/rmap.c	2008-01-30 12:01:28.000000000 -0600
@@ -476,8 +476,10 @@ int page_mkclean(struct page *page)
 		struct address_space *mapping = page_mapping(page);
 		if (mapping) {
 			ret = page_mkclean_file(mapping, page);
-			if (unlikely(PageExternalRmap(page)))
+			if (unlikely(PageExternalRmap(page))) {
 				mmu_rmap_notifier(invalidate_page, page);
+				ClearPageExported(page);
+			}
 			if (page_test_dirty(page)) {
 				page_clear_dirty(page);
 				ret = 1;
@@ -980,8 +982,10 @@ int try_to_unmap(struct page *page, int 
 	else
 		ret = try_to_unmap_file(page, migration);
 
-	if (unlikely(PageExternalRmap(page)))
+	if (unlikely(PageExternalRmap(page))) {
 		mmu_rmap_notifier(invalidate_page, page);
+		ClearPageExported(page);
+	}
 
 	if (!page_mapped(page))
 		ret = SWAP_SUCCESS;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
