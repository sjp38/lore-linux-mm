Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D28E96B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:38 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so258944381ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:38 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id k40si41545998iod.92.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 02/33] tools: Add WARN_ON_ONCE
Date: Mon, 28 Nov 2016 13:50:06 -0800
Message-Id: <1480369871-5271-3-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

The radix tree uses its own buggy WARN_ON_ONCE.  Replace it with the
definition from asm-generic/bug.h

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/include/asm/bug.h                | 11 +++++++++++
 tools/testing/radix-tree/Makefile      |  2 +-
 tools/testing/radix-tree/linux/bug.h   |  2 +-
 tools/testing/radix-tree/linux/types.h |  2 --
 4 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/tools/include/asm/bug.h b/tools/include/asm/bug.h
index 9e5f484..beda1a8 100644
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
index f2e07f2..3c338dc 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,5 +1,5 @@
 
-CFLAGS += -I. -g -O2 -Wall -D_LGPL_SOURCE
+CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
diff --git a/tools/testing/radix-tree/linux/bug.h b/tools/testing/radix-tree/linux/bug.h
index ccbe444..23b8ed5 100644
--- a/tools/testing/radix-tree/linux/bug.h
+++ b/tools/testing/radix-tree/linux/bug.h
@@ -1 +1 @@
-#define WARN_ON_ONCE(x)		assert(x)
+#include "asm/bug.h"
diff --git a/tools/testing/radix-tree/linux/types.h b/tools/testing/radix-tree/linux/types.h
index faa0b6f..8491d89 100644
--- a/tools/testing/radix-tree/linux/types.h
+++ b/tools/testing/radix-tree/linux/types.h
@@ -6,8 +6,6 @@
 #define __rcu
 #define __read_mostly
 
-#define BITS_PER_LONG (sizeof(long) * 8)
-
 static inline void INIT_LIST_HEAD(struct list_head *list)
 {
 	list->next = list;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
