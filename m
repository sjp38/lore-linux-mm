Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 669AC6B026C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:34:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so3504170pfg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:34:51 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 62si41746891pfi.104.2016.10.19.12.34.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 12:34:50 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 13/16] dax: move put_(un)locked_mapping_entry() in dax.c
Date: Wed, 19 Oct 2016 13:34:32 -0600
Message-Id: <1476905675-32581-14-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

No functional change.

The static functions put_locked_mapping_entry() and
put_unlocked_mapping_entry() will soon be used in error cases in
grab_mapping_entry(), so move their definitions above this function.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 50 +++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index c45cc4d..0582c7c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -382,6 +382,31 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	}
 }
 
+static void put_locked_mapping_entry(struct address_space *mapping,
+				     pgoff_t index, void *entry)
+{
+	if (!radix_tree_exceptional_entry(entry)) {
+		unlock_page(entry);
+		put_page(entry);
+	} else {
+		dax_unlock_mapping_entry(mapping, index);
+	}
+}
+
+/*
+ * Called when we are done with radix tree entry we looked up via
+ * get_unlocked_mapping_entry() and which we didn't lock in the end.
+ */
+static void put_unlocked_mapping_entry(struct address_space *mapping,
+				       pgoff_t index, void *entry)
+{
+	if (!radix_tree_exceptional_entry(entry))
+		return;
+
+	/* We have to wake up next waiter for the radix tree entry lock */
+	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+}
+
 /*
  * Find radix tree entry at given index. If it points to a page, return with
  * the page locked. If it points to the exceptional entry, return with the
@@ -486,31 +511,6 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
 }
 
-static void put_locked_mapping_entry(struct address_space *mapping,
-				     pgoff_t index, void *entry)
-{
-	if (!radix_tree_exceptional_entry(entry)) {
-		unlock_page(entry);
-		put_page(entry);
-	} else {
-		dax_unlock_mapping_entry(mapping, index);
-	}
-}
-
-/*
- * Called when we are done with radix tree entry we looked up via
- * get_unlocked_mapping_entry() and which we didn't lock in the end.
- */
-static void put_unlocked_mapping_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
-{
-	if (!radix_tree_exceptional_entry(entry))
-		return;
-
-	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
-}
-
 /*
  * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
  * entry to get unlocked before deleting it.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
