Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA5E76B0397
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:25:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so57668559pge.5
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:25:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y7si2209630pgb.374.2017.02.10.09.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:25:06 -0800 (PST)
Date: Fri, 10 Feb 2017 09:24:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 12/37] brd: make it handle huge pages
Message-ID: <20170210172401.GB2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-13-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-13-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:54PM +0300, Kirill A. Shutemov wrote:
> Do not assume length of bio segment is never larger than PAGE_SIZE.
> With huge pages it's HPAGE_PMD_SIZE (2M on x86-64).

I don't think we even need hugepages for BRD to be buggy.  I think there are
already places which allocate compound pages (not in highmem, obviously ...)
and put them in biovecs.  So this is pure and simple a bugfix.

That said, I find the current code in brd a bit inelegant, and I don't
think this patch helps... indeed, I think it's buggy:

> @@ -202,12 +202,15 @@ static int copy_to_brd_setup(struct brd_device *brd, sector_t sector, size_t n)
>  	size_t copy;
>  
>  	copy = min_t(size_t, n, PAGE_SIZE - offset);
> +	n -= copy;
>  	if (!brd_insert_page(brd, sector))
>  		return -ENOSPC;
> -	if (copy < n) {
> +	while (n) {
>  		sector += copy >> SECTOR_SHIFT;
>  		if (!brd_insert_page(brd, sector))
>  			return -ENOSPC;
> +		copy = min_t(size_t, n, PAGE_SIZE);
> +		n -= copy;
>  	}

We're decrementing 'n' to 0, then testing it, so we never fill in the
last page ... right?

Anyway, here's my effort.  Untested.

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 3adc32a3153b..0802a6abcd81 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -202,12 +202,14 @@ static int copy_to_brd_setup(struct brd_device *brd, sector_t sector, size_t n)
 	size_t copy;
 
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
-	if (!brd_insert_page(brd, sector))
-		return -ENOSPC;
-	if (copy < n) {
-		sector += copy >> SECTOR_SHIFT;
+	for (;;) {
 		if (!brd_insert_page(brd, sector))
 			return -ENOSPC;
+		n -= copy;
+		if (!n)
+			break;
+		sector += copy >> SECTOR_SHIFT;
+		copy = min_t(size_t, n, PAGE_SIZE);
 	}
 	return 0;
 }
@@ -239,26 +241,23 @@ static void copy_to_brd(struct brd_device *brd, const void *src,
 	struct page *page;
 	void *dst;
 	unsigned int offset = (sector & (PAGE_SECTORS-1)) << SECTOR_SHIFT;
-	size_t copy;
+	size_t copy = min_t(size_t, n, PAGE_SIZE - offset);
 
-	copy = min_t(size_t, n, PAGE_SIZE - offset);
-	page = brd_lookup_page(brd, sector);
-	BUG_ON(!page);
-
-	dst = kmap_atomic(page);
-	memcpy(dst + offset, src, copy);
-	kunmap_atomic(dst);
-
-	if (copy < n) {
-		src += copy;
-		sector += copy >> SECTOR_SHIFT;
-		copy = n - copy;
+	for (;;) {
 		page = brd_lookup_page(brd, sector);
 		BUG_ON(!page);
 
 		dst = kmap_atomic(page);
-		memcpy(dst, src, copy);
+		memcpy(dst + offset, src, copy);
 		kunmap_atomic(dst);
+
+		n -= copy;
+		if (!n)
+			break;
+		src += copy;
+		sector += copy >> SECTOR_SHIFT;
+		offset = 0;
+		copy = min_t(size_t, n, PAGE_SIZE);
 	}
 }
 
@@ -271,28 +270,24 @@ static void copy_from_brd(void *dst, struct brd_device *brd,
 	struct page *page;
 	void *src;
 	unsigned int offset = (sector & (PAGE_SECTORS-1)) << SECTOR_SHIFT;
-	size_t copy;
+	size_t copy = min_t(size_t, n, PAGE_SIZE - offset);
 
-	copy = min_t(size_t, n, PAGE_SIZE - offset);
-	page = brd_lookup_page(brd, sector);
-	if (page) {
-		src = kmap_atomic(page);
-		memcpy(dst, src + offset, copy);
-		kunmap_atomic(src);
-	} else
-		memset(dst, 0, copy);
-
-	if (copy < n) {
-		dst += copy;
-		sector += copy >> SECTOR_SHIFT;
-		copy = n - copy;
+	for (;;) {
 		page = brd_lookup_page(brd, sector);
 		if (page) {
 			src = kmap_atomic(page);
-			memcpy(dst, src, copy);
+			memcpy(dst, src + offset, copy);
 			kunmap_atomic(src);
 		} else
 			memset(dst, 0, copy);
+
+		n -= copy;
+		if (!n)
+			break;
+		dst += copy;
+		sector += copy >> SECTOR_SHIFT;
+		offset = 0;
+		copy = min_t(size_t, n, PAGE_SIZE);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
