Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F0FE26B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:00 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fl2so5222421pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.14.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 08/43] page-flags: relax page flag policy for few flags
Date: Tue, 25 Oct 2016 03:13:07 +0300
Message-Id: <20161025001342.76126-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 74e4dda91238..a2bef9a41bcf 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -253,7 +253,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
-PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
+PAGEFLAG(Error, error, PF_NO_TAIL) TESTCLEARFLAG(Error, error, PF_NO_TAIL)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
 	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
@@ -293,15 +293,15 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
