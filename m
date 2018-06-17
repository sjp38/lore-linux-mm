Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9466B0005
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w6-v6so7700471plp.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a7-v6si9451593pgv.360.2018.06.16.19.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:00:58 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 02/74] radix tree test suite: Enable ubsan
Date: Sat, 16 Jun 2018 18:59:40 -0700
Message-Id: <20180617020052.4759-3-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Add support for the undefined behaviour sanitizer and fix the bugs
that ubsan pointed out.  Nothing major, and all in the test suite,
not the code.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 tools/testing/radix-tree/Makefile |  5 +++--
 tools/testing/radix-tree/main.c   | 20 +++++++++++---------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index db66f8a0d4be..da030a65d6d6 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,7 +1,8 @@
 # SPDX-License-Identifier: GPL-2.0
 
-CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
-LDFLAGS += -fsanitize=address
+CFLAGS += -I. -I../../include -g -Og -Wall -D_LGPL_SOURCE -fsanitize=address \
+	  -fsanitize=undefined
+LDFLAGS += -fsanitize=address -fsanitize=undefined
 LDLIBS+= -lpthread -lurcu
 TARGETS = main idr-test multiorder
 CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 257f3f8aacaa..584a8732f5ce 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -27,20 +27,22 @@ void __gang_check(unsigned long middle, long down, long up, int chunk, int hop)
 		item_check_present(&tree, middle + idx);
 	item_check_absent(&tree, middle + up);
 
-	item_gang_check_present(&tree, middle - down,
-			up + down, chunk, hop);
-	item_full_scan(&tree, middle - down, down + up, chunk);
+	if (chunk > 0) {
+		item_gang_check_present(&tree, middle - down, up + down,
+				chunk, hop);
+		item_full_scan(&tree, middle - down, down + up, chunk);
+	}
 	item_kill_tree(&tree);
 }
 
 void gang_check(void)
 {
-	__gang_check(1 << 30, 128, 128, 35, 2);
-	__gang_check(1 << 31, 128, 128, 32, 32);
-	__gang_check(1 << 31, 128, 128, 32, 100);
-	__gang_check(1 << 31, 128, 128, 17, 7);
-	__gang_check(0xffff0000, 0, 65536, 17, 7);
-	__gang_check(0xfffffffe, 1, 1, 17, 7);
+	__gang_check(1UL << 30, 128, 128, 35, 2);
+	__gang_check(1UL << 31, 128, 128, 32, 32);
+	__gang_check(1UL << 31, 128, 128, 32, 100);
+	__gang_check(1UL << 31, 128, 128, 17, 7);
+	__gang_check(0xffff0000UL, 0, 65536, 17, 7);
+	__gang_check(0xfffffffeUL, 1, 1, 17, 7);
 }
 
 void __big_gang_check(void)
-- 
2.17.1
