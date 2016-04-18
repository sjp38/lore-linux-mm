Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D53656B0261
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:41:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q8so124233804lfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:41:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si778667wmh.40.2016.04.18.14.35.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:53 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 15/18] dax: Allow DAX code to replace exceptional entries
Date: Mon, 18 Apr 2016 23:35:38 +0200
Message-Id: <1461015341-20153-16-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently we forbid page_cache_tree_insert() to replace exceptional radix
tree entries for DAX inodes. However to make DAX faults race free we will
lock radix tree entries and when hole is created, we need to replace
such locked radix tree entry with a hole page. So modify
page_cache_tree_insert() to allow that.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/dax.h |  1 +
 mm/filemap.c        | 18 +++++++++++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/dax.h b/include/linux/dax.h
index bef5c44f71b3..fd4aeae65ed7 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -3,6 +3,7 @@
 
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/radix-tree.h>
 #include <asm/pgtable.h>
 
 /* We use lowest available exceptional entry bit for locking */
diff --git a/mm/filemap.c b/mm/filemap.c
index f2479af09da9..3effd5c8f2f6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -597,14 +597,18 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 
-		if (WARN_ON(dax_mapping(mapping)))
-			return -EINVAL;
-
-		if (shadowp)
-			*shadowp = p;
 		mapping->nrexceptional--;
-		if (node)
-			workingset_node_shadows_dec(node);
+		if (!dax_mapping(mapping)) {
+			if (shadowp)
+				*shadowp = p;
+			if (node)
+				workingset_node_shadows_dec(node);
+		} else {
+			/* DAX can replace empty locked entry with a hole */
+			WARN_ON_ONCE(p !=
+				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
+					 RADIX_DAX_ENTRY_LOCK));
+		}
 	}
 	radix_tree_replace_slot(slot, page);
 	mapping->nrpages++;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
