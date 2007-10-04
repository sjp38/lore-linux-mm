Message-Id: <20071004040003.082188692@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:41 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [06/18] Vcompound: Update page address determination
Content-Disposition: inline; filename=vcompound_page_address
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Make page_address() correctly determine the address of a potentially
virtually mapped compound page.

There are 3 cases to consider:

1. !HASHED_PAGE_VIRTUAL && !WANT_PAGE_VIRTUAL

Call vmalloc_address() directly from the page_address function
defined in mm.h.

2. HASHED_PAGE_VIRTUAL

Modify page_address() in highmem.c to call vmalloc_address().

3. WANT_PAGE_VIRTUAL

set_page_address() is used to set up the virtual addresses of
all pages that are part of the virtual compound.

Cc: apw@shadowen.org
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    9 ++++++++-
 mm/highmem.c       |   10 ++++++++--
 2 files changed, 16 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2007-10-03 19:39:52.000000000 -0700
+++ linux-2.6/include/linux/mm.h	2007-10-03 19:40:29.000000000 -0700
@@ -605,7 +605,14 @@ void page_address_init(void);
 #endif
 
 #if !defined(HASHED_PAGE_VIRTUAL) && !defined(WANT_PAGE_VIRTUAL)
-#define page_address(page) lowmem_page_address(page)
+
+static inline void *page_address(struct page *page)
+{
+	if (unlikely(PageVcompound(page)))
+		return vmalloc_address(page);
+	return lowmem_page_address(page);
+}
+
 #define set_page_address(page, address)  do { } while(0)
 #define page_address_init()  do { } while(0)
 #endif
Index: linux-2.6/mm/highmem.c
===================================================================
--- linux-2.6.orig/mm/highmem.c	2007-10-03 19:39:25.000000000 -0700
+++ linux-2.6/mm/highmem.c	2007-10-03 19:40:29.000000000 -0700
@@ -265,8 +265,11 @@ void *page_address(struct page *page)
 	void *ret;
 	struct page_address_slot *pas;
 
-	if (!PageHighMem(page))
+	if (!PageHighMem(page)) {
+		if (PageVcompound(page))
+			return vmalloc_address(page);
 		return lowmem_page_address(page);
+	}
 
 	pas = page_slot(page);
 	ret = NULL;
@@ -294,7 +297,10 @@ void set_page_address(struct page *page,
 	struct page_address_slot *pas;
 	struct page_address_map *pam;
 
-	BUG_ON(!PageHighMem(page));
+	if (!PageHighMem(page)) {
+		BUG_ON(!PageVcompound(page));
+		return;
+	}
 
 	pas = page_slot(page);
 	if (virtual) {		/* Add */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
