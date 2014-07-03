Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D526C6B0037
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 17:53:33 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so3032480wiv.4
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:53:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bd1si36883636wjc.5.2014.07.03.14.53.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 14:53:32 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/4] define PAGECACHE_TAG_* as enumeration under include/uapi
Date: Thu,  3 Jul 2014 17:52:12 -0400
Message-Id: <1404424335-30128-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

We need the pagecache tags to be exported to userspace later in this
series for fincore(2), so this patch moves the definition to the new
include file for preparation. We also use the number of pagecache tags,
so this patch also adds it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/fs.h             |  9 +--------
 include/uapi/linux/pagecache.h | 17 +++++++++++++++++
 2 files changed, 18 insertions(+), 8 deletions(-)
 create mode 100644 include/uapi/linux/pagecache.h

diff --git v3.16-rc3.orig/include/linux/fs.h v3.16-rc3/include/linux/fs.h
index e11d60cc867b..ae4a953bd5f3 100644
--- v3.16-rc3.orig/include/linux/fs.h
+++ v3.16-rc3/include/linux/fs.h
@@ -32,6 +32,7 @@
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
+#include <uapi/linux/pagecache.h>
 
 struct export_operations;
 struct hd_geometry;
@@ -446,14 +447,6 @@ struct block_device {
 	struct mutex		bd_fsfreeze_mutex;
 };
 
-/*
- * Radix-tree tags, for tagging dirty and writeback pages within the pagecache
- * radix trees
- */
-#define PAGECACHE_TAG_DIRTY	0
-#define PAGECACHE_TAG_WRITEBACK	1
-#define PAGECACHE_TAG_TOWRITE	2
-
 int mapping_tagged(struct address_space *mapping, int tag);
 
 /*
diff --git v3.16-rc3.orig/include/uapi/linux/pagecache.h v3.16-rc3/include/uapi/linux/pagecache.h
new file mode 100644
index 000000000000..15e879f7395f
--- /dev/null
+++ v3.16-rc3/include/uapi/linux/pagecache.h
@@ -0,0 +1,17 @@
+#ifndef _UAPI_LINUX_PAGECACHE_H
+#define _UAPI_LINUX_PAGECACHE_H
+
+/*
+ * Radix-tree tags, for tagging dirty and writeback pages within the pagecache
+ * radix trees.
+ */
+enum {
+	PAGECACHE_TAG_DIRTY,
+	PAGECACHE_TAG_WRITEBACK,
+	PAGECACHE_TAG_TOWRITE,
+	__NR_PAGECACHE_TAGS,
+};
+
+#define PAGECACHE_TAG_MASK	((1UL << __NR_PAGECACHE_TAGS) - 1)
+
+#endif /* _UAPI_LINUX_PAGECACHE_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
