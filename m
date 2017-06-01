Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48EAD6B0374
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so8699624wml.4
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r20si22209734wmd.15.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 34/35] mm: Make find_get_entries_tag() update index
Date: Thu,  1 Jun 2017 11:32:44 +0200
Message-Id: <20170601093245.29238-35-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Make find_get_entries_tag() update 'start' to index the next page for
iteration.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c                | 3 +--
 include/linux/pagemap.h | 2 +-
 mm/filemap.c            | 8 ++++++--
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index c204445a69b0..4b295c544fd4 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -841,7 +841,7 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	while (!done) {
-		pvec.nr = find_get_entries_tag(mapping, start_index,
+		pvec.nr = find_get_entries_tag(mapping, &start_index,
 				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
 				pvec.pages, indices);
 
@@ -859,7 +859,6 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 			if (ret < 0)
 				goto out;
 		}
-		start_index = indices[pvec.nr - 1] + 1;
 	}
 out:
 	put_dax(dax_dev);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index df128a56f44b..1dc7e54ec32a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -365,7 +365,7 @@ static inline unsigned find_get_pages_tag(struct address_space *mapping,
 	return find_get_pages_range_tag(mapping, index, (pgoff_t)-1, tag,
 					nr_pages, pages);
 }
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
+unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
 			int tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index e55100459710..3eb05c91c07a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1731,7 +1731,7 @@ EXPORT_SYMBOL(find_get_pages_range_tag);
  * Like find_get_entries, except we only return entries which are tagged with
  * @tag.
  */
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
+unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
 			int tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices)
 {
@@ -1744,7 +1744,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
-				   &iter, start, tag) {
+				   &iter, *start, tag) {
 		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
@@ -1786,6 +1786,10 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			break;
 	}
 	rcu_read_unlock();
+
+	if (ret)
+		*start = indices[ret - 1] + 1;
+
 	return ret;
 }
 EXPORT_SYMBOL(find_get_entries_tag);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
