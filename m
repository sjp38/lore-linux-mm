Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64BEC828FF
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:07 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so5463773pac.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k84si10104810pfa.56.2016.08.12.11.38.48
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 19/41] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if huge page cache enabled
Date: Fri, 12 Aug 2016 21:38:02 +0300
Message-Id: <1471027104-115213-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to do IO a huge page a time. So we need BIO_MAX_PAGES to be
at least HPAGE_PMD_NR. For x86-64, it's 512 pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/bio.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 583c10810e32..c7104a77e0db 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -40,7 +40,11 @@
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
