Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFC746B026E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so133709927pfz.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m8si17919501pfa.203.2016.10.24.17.14.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 01/43] tools: Add WARN_ON_ONCE
Date: Tue, 25 Oct 2016 03:13:00 +0300
Message-Id: <20161025001342.76126-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

The radix tree uses its own buggy WARN_ON_ONCE.  Replace it with the
definition from asm-generic/bug.h

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 tools/include/asm/bug.h              | 11 +++++++++++
 tools/testing/radix-tree/Makefile    |  2 +-
 tools/testing/radix-tree/linux/bug.h |  2 +-
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/tools/include/asm/bug.h b/tools/include/asm/bug.h
index 9e5f4846967f..beda1a884b50 100644
--- a/tools/include/asm/bug.h
+++ b/tools/include/asm/bug.h
@@ -12,6 +12,17 @@
 	unlikely(__ret_warn_on);		\
 })
 
+#define WARN_ON_ONCE(condition) ({			\
+	static int __warned;				\
+	int __ret_warn_once = !!(condition);		\
+							\
+	if (unlikely(__ret_warn_once && !__warned)) {	\
+		__warned = true;			\
+		WARN_ON(1);				\
+	}						\
+	unlikely(__ret_warn_once);			\
+})
+
 #define WARN_ONCE(condition, format...)	({	\
 	static int __warned;			\
 	int __ret_warn_once = !!(condition);	\
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index f2e07f2fd4b4..3c338dc3b162 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,5 +1,5 @@
 
-CFLAGS += -I. -g -O2 -Wall -D_LGPL_SOURCE
+CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
diff --git a/tools/testing/radix-tree/linux/bug.h b/tools/testing/radix-tree/linux/bug.h
index ccbe444977df..23b8ed52f8c8 100644
--- a/tools/testing/radix-tree/linux/bug.h
+++ b/tools/testing/radix-tree/linux/bug.h
@@ -1 +1 @@
-#define WARN_ON_ONCE(x)		assert(x)
+#include "asm/bug.h"
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
