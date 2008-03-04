From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 04/10] Pageflags: Use proper page flag functions in Xen
Date: Mon, 03 Mar 2008 16:04:56 -0800
Message-ID: <20080304000733.017773882@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763096AbYCDAIu@vger.kernel.org>
Content-Disposition: inline; filename=xen
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Xen uses bitops to manipulate page flags. Make it use proper page flag
functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86/xen/mmu.c         |    4 ++--
 include/linux/page-flags.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/x86/xen/mmu.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/mmu.c	2008-03-03 15:45:09.207335791 -0800
+++ linux-2.6/arch/x86/xen/mmu.c	2008-03-03 15:48:09.469801962 -0800
@@ -425,7 +425,7 @@ static void xen_do_pin(unsigned level, u
 
 static int pin_page(struct page *page, enum pt_level level)
 {
-	unsigned pgfl = test_and_set_bit(PG_pinned, &page->flags);
+	unsigned pgfl = TestSetPagePinned(page);
 	int flush;
 
 	if (pgfl)
@@ -506,7 +506,7 @@ void __init xen_mark_init_mm_pinned(void
 
 static int unpin_page(struct page *page, enum pt_level level)
 {
-	unsigned pgfl = test_and_clear_bit(PG_pinned, &page->flags);
+	unsigned pgfl = TestClearPagePinned(page);
 
 	if (pgfl && !PageHighMem(page)) {
 		void *pt = lowmem_page_address(page);
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-03-03 15:46:15.848254180 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-03-03 15:48:09.469801962 -0800
@@ -155,7 +155,7 @@ PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, 
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
-PAGEFLAG(Pinned, pinned)		/* Xen pinned pagetable */
+PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned) /* Xen pagetable */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)

-- 
