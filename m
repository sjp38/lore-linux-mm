Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59B1F6B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so6497404pfp.1
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x12-v6si3238894plo.28.2018.04.14.07.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 14/63] xarray: Add xas_create_range
Date: Sat, 14 Apr 2018 07:12:27 -0700
Message-Id: <20180414141316.7167-15-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This hopefully temporary function is useful for users who have not yet
been converted to multi-index entries.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  2 ++
 lib/xarray.c           | 22 ++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 6f764705382b..b158433b1924 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -761,6 +761,8 @@ void xas_init_tags(const struct xa_state *);
 bool xas_nomem(struct xa_state *, gfp_t);
 void xas_pause(struct xa_state *);
 
+void xas_create_range(struct xa_state *, unsigned long max);
+
 /**
  * xas_reload() - Refetch an entry from the xarray.
  * @xas: XArray operation state.
diff --git a/lib/xarray.c b/lib/xarray.c
index 7574bafbc6ff..653ab0555673 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -626,6 +626,28 @@ void *xas_create(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_create);
 
+/**
+ * xas_create_range() - Ensure that stores to this range will succeed
+ * @xas: XArray operation state.
+ * @max: The highest index to create a slot for.
+ *
+ * Creates all of the slots in the range between the current position of
+ * @xas and @max.  This is for the benefit of users who have not yet been
+ * converted to multi-index entries.
+ *
+ * The implementation is naive.
+ */
+void xas_create_range(struct xa_state *xas, unsigned long max)
+{
+	XA_STATE(tmp, xas->xa, xas->xa_index);
+
+	do {
+		xas_create(&tmp);
+		xas_set(&tmp, tmp.xa_index + XA_CHUNK_SIZE);
+	} while (tmp.xa_index < max);
+}
+EXPORT_SYMBOL_GPL(xas_create_range);
+
 static void store_siblings(struct xa_state *xas, void *entry, void *curr,
 				int *countp, int *valuesp)
 {
-- 
2.17.0
