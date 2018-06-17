Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D77846B0290
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b5-v6so6241374pfi.5
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f7-v6si13257137plj.122.2018.06.16.19.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:32 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 63/74] dax: Hash on XArray instead of mapping
Date: Sat, 16 Jun 2018 19:00:41 -0700
Message-Id: <20180617020052.4759-64-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Since the XArray is embedded in the struct address_space, its address
contains exactly as much entropy as the address of the mapping.  This
patch is purely preparatory for later patches which will simplify the
wait/wake interfaces.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/dax.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 157762fe2ba1..b7f54e386da8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -116,7 +116,7 @@ static int dax_is_empty_entry(void *entry)
  * DAX page cache entry locking
  */
 struct exceptional_entry_key {
-	struct address_space *mapping;
+	struct xarray *xa;
 	pgoff_t entry_start;
 };
 
@@ -125,7 +125,7 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
-static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
+static wait_queue_head_t *dax_entry_waitqueue(struct xarray *xa,
 		pgoff_t index, void *entry, struct exceptional_entry_key *key)
 {
 	unsigned long hash;
@@ -138,21 +138,21 @@ static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
 	if (dax_is_pmd_entry(entry))
 		index &= ~PG_PMD_COLOUR;
 
-	key->mapping = mapping;
+	key->xa = xa;
 	key->entry_start = index;
 
-	hash = hash_long((unsigned long)mapping ^ index, DAX_WAIT_TABLE_BITS);
+	hash = hash_long((unsigned long)xa ^ index, DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
-static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mode,
-				       int sync, void *keyp)
+static int wake_exceptional_entry_func(wait_queue_entry_t *wait,
+		unsigned int mode, int sync, void *keyp)
 {
 	struct exceptional_entry_key *key = keyp;
 	struct wait_exceptional_entry_queue *ewait =
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
-	if (key->mapping != ewait->key.mapping ||
+	if (key->xa != ewait->key.xa ||
 	    key->entry_start != ewait->key.entry_start)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
@@ -163,13 +163,13 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
  * The important information it's conveying is whether the entry at
  * this index used to be a PMD entry.
  */
-static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
+static void dax_wake_mapping_entry_waiter(struct xarray *xa,
 		pgoff_t index, void *entry, bool wake_all)
 {
 	struct exceptional_entry_key key;
 	wait_queue_head_t *wq;
 
-	wq = dax_entry_waitqueue(mapping, index, entry, &key);
+	wq = dax_entry_waitqueue(xa, index, entry, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -246,7 +246,8 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 			return entry;
 		}
 
-		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
+		wq = dax_entry_waitqueue(&mapping->i_pages, index, entry,
+				&ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		xa_unlock_irq(&mapping->i_pages);
@@ -270,7 +271,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 	}
 	unlock_slot(mapping, slot);
 	xa_unlock_irq(&mapping->i_pages);
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	dax_wake_mapping_entry_waiter(&mapping->i_pages, index, entry, false);
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
@@ -290,7 +291,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 		return;
 
 	/* We have to wake up next waiter for the page cache entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	dax_wake_mapping_entry_waiter(&mapping->i_pages, index, entry, false);
 }
 
 static unsigned long dax_entry_size(void *entry)
@@ -423,7 +424,8 @@ struct page *dax_lock_page(unsigned long pfn)
 			break;
 		}
 
-		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
+		wq = dax_entry_waitqueue(&mapping->i_pages, index, entry,
+				&ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 				TASK_UNINTERRUPTIBLE);
 		xa_unlock_irq(&mapping->i_pages);
@@ -556,8 +558,8 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 			dax_disassociate_entry(entry, mapping, false);
 			radix_tree_delete(&mapping->i_pages, index);
 			mapping->nrexceptional--;
-			dax_wake_mapping_entry_waiter(mapping, index, entry,
-					true);
+			dax_wake_mapping_entry_waiter(&mapping->i_pages,
+					index, entry, true);
 		}
 
 		entry = dax_make_locked(0, size_flag | DAX_EMPTY);
-- 
2.17.1
