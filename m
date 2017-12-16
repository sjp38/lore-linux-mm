Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7384403D8
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so10009252pfi.15
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h8si832869pgc.795.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 0/8] Restructure struct page
Date: Sat, 16 Dec 2017 08:44:17 -0800
Message-Id: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This series does not attempt any grand restructuring as I proposed last
week.  Instead, it cures the worst of the indentitis, fixes the
documentation and reduces the ifdeffery.  The only layout change is
compound_dtor and compound_order are each reduced to one byte.  At
least, that's my intent.  

Here's a diff from pahole's output:

--- old-struct-page	2017-12-16 09:58:09.653936791 -0500
+++ new-struct-page	2017-12-16 09:58:32.009832964 -0500
@@ -11,17 +11,15 @@
 	};                                               /*    16     8 */
 	union {
 		long unsigned int  counters;             /*           8 */
+		unsigned int       active;               /*           4 */
 		struct {
-			union {
-				atomic_t _mapcount;      /*           4 */
-				unsigned int active;     /*           4 */
-				struct {
-					unsigned int inuse:16; /*    24:16  4 */
-					unsigned int objects:15; /*    24: 1  4 */
-					unsigned int frozen:1; /*    24: 0  4 */
-				};                       /*           4 */
-				int units;               /*           4 */
-			};                               /*    24     4 */
+			unsigned int inuse:16;           /*    24:16  4 */
+			unsigned int objects:15;         /*    24: 1  4 */
+			unsigned int frozen:1;           /*    24: 0  4 */
+		};                                       /*           4 */
+		int                units;                /*           4 */
+		struct {
+			atomic_t   _mapcount;            /*    24     4 */
 			atomic_t   _refcount;            /*    28     4 */
 		};                                       /*           8 */
 	};                                               /*    24     8 */
@@ -36,8 +34,8 @@
 		struct callback_head callback_head;      /*          16 */
 		struct {
 			long unsigned int compound_head; /*    32     8 */
-			unsigned int compound_dtor;      /*    40     4 */
-			unsigned int compound_order;     /*    44     4 */
+			unsigned char compound_dtor;     /*    40     1 */
+			unsigned char compound_order;    /*    41     1 */
 		};                                       /*          16 */
 		struct {
 			long unsigned int __pad;         /*    32     8 */

Matthew Wilcox (8):
  mm: Align struct page more aesthetically
  mm: De-indent struct page
  mm: Remove misleading alignment claims
  mm: Improve comment on page->mapping
  mm: Introduce _slub_counter_t
  mm: Store compound_dtor / compound_order as bytes
  mm: Document how to use struct page
  mm: Remove reference to PG_buddy

 include/linux/mm_types.h | 153 ++++++++++++++++++++++-------------------------
 1 file changed, 73 insertions(+), 80 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
