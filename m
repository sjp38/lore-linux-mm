Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 374516B0269
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x70so87504710pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y62si17971548pgy.100.2016.10.24.17.14.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if huge page cache enabled
Date: Tue, 25 Oct 2016 03:13:17 +0300
Message-Id: <20161025001342.76126-19-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to do IO a huge page a time. So we need BIO_MAX_PAGES to be
at least HPAGE_PMD_NR. For x86-64, it's 512 pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 block/bio.c         | 3 ++-
 include/linux/bio.h | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/block/bio.c b/block/bio.c
index db85c5753a76..a69062bda3e0 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -44,7 +44,8 @@
  */
 #define BV(x) { .nr_vecs = x, .name = "biovec-"__stringify(x) }
 static struct biovec_slab bvec_slabs[BVEC_POOL_NR] __read_mostly = {
-	BV(1), BV(4), BV(16), BV(64), BV(128), BV(BIO_MAX_PAGES),
+	BV(1), BV(4), BV(16), BV(64), BV(128),
+	{ .nr_vecs = BIO_MAX_PAGES, .name ="biovec-max_pages" },
 };
 #undef BV
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 97cb48f03dc7..19d0fae9cdd0 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -38,7 +38,11 @@
 #define BIO_BUG_ON
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+#define BIO_MAX_PAGES		(HPAGE_PMD_NR > 256 ? HPAGE_PMD_NR : 256)
+#else
 #define BIO_MAX_PAGES		256
+#endif
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
