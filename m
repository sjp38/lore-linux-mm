Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24D6628024E
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so83888897pab.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id bm5si1150675pad.46.2016.09.15.04.55.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 19/41] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if huge page cache enabled
Date: Thu, 15 Sep 2016 14:55:01 +0300
Message-Id: <20160915115523.29737-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index 23ddf4b46a9b..ebf4f312a642 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
