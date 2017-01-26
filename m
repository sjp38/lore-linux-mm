Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 351656B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so308729890pgf.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:32 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 62si1228503ply.77.2017.01.26.03.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 03/37] page-flags: relax page flag policy for few flags
Date: Thu, 26 Jan 2017 14:57:45 +0300
Message-Id: <20170126115819.58875-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

These flags are in use for filesystems with backing storage: PG_error,
PG_writeback and PG_readahead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d6de32..b85b73cfb1b3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -263,7 +263,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters, PF_ONLY_HEAD)
-PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
+PAGEFLAG(Error, error, PF_NO_TAIL) TESTCLEARFLAG(Error, error, PF_NO_TAIL)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
 	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
@@ -303,15 +303,15 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
-	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
+TESTPAGEFLAG(Writeback, writeback, PF_NO_TAIL)
+	TESTSCFLAG(Writeback, writeback, PF_NO_TAIL)
 PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
 	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
-PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
-	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
+PAGEFLAG(Readahead, reclaim, PF_NO_TAIL)
+	TESTCLEARFLAG(Readahead, reclaim, PF_NO_TAIL)
 
 #ifdef CONFIG_HIGHMEM
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
