Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCDB6B026D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ra7so45300pab.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y62si17971548pgy.100.2016.10.24.17.14.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 19/43] brd: make it handle huge pages
Date: Tue, 25 Oct 2016 03:13:18 +0300
Message-Id: <20161025001342.76126-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Do not assume length of bio segment is never larger than PAGE_SIZE.
With huge pages it's HPAGE_PMD_SIZE (2M on x86-64).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/block/brd.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 0c76d4016eeb..4214163350d2 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -202,12 +202,15 @@ static int copy_to_brd_setup(struct brd_device *brd, sector_t sector, size_t n)
 	size_t copy;
 
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
+	n -= copy;
 	if (!brd_insert_page(brd, sector))
 		return -ENOSPC;
-	if (copy < n) {
+	while (n) {
 		sector += copy >> SECTOR_SHIFT;
 		if (!brd_insert_page(brd, sector))
 			return -ENOSPC;
+		copy = min_t(size_t, n, PAGE_SIZE);
+		n -= copy;
 	}
 	return 0;
 }
@@ -242,6 +245,7 @@ static void copy_to_brd(struct brd_device *brd, const void *src,
 	size_t copy;
 
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
+	n -= copy;
 	page = brd_lookup_page(brd, sector);
 	BUG_ON(!page);
 
@@ -249,10 +253,11 @@ static void copy_to_brd(struct brd_device *brd, const void *src,
 	memcpy(dst + offset, src, copy);
 	kunmap_atomic(dst);
 
-	if (copy < n) {
+	while (n) {
 		src += copy;
 		sector += copy >> SECTOR_SHIFT;
-		copy = n - copy;
+		copy = min_t(size_t, n, PAGE_SIZE);
+		n -= copy;
 		page = brd_lookup_page(brd, sector);
 		BUG_ON(!page);
 
@@ -274,6 +279,7 @@ static void copy_from_brd(void *dst, struct brd_device *brd,
 	size_t copy;
 
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
+	n -= copy;
 	page = brd_lookup_page(brd, sector);
 	if (page) {
 		src = kmap_atomic(page);
@@ -282,10 +288,11 @@ static void copy_from_brd(void *dst, struct brd_device *brd,
 	} else
 		memset(dst, 0, copy);
 
-	if (copy < n) {
+	while (n) {
 		dst += copy;
 		sector += copy >> SECTOR_SHIFT;
-		copy = n - copy;
+		copy = min_t(size_t, n, PAGE_SIZE);
+		n -= copy;
 		page = brd_lookup_page(brd, sector);
 		if (page) {
 			src = kmap_atomic(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
