Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 068AE6B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so8673094wmf.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si33702119wmi.110.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 20/35] f2fs: Use find_get_pages_tag() for looking up single page
Date: Thu,  1 Jun 2017 11:32:30 +0200
Message-Id: <20170601093245.29238-21-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

__get_first_dirty_index() wants to lookup only the first dirty page
after given index. There's no point in using pagevec_lookup_tag() for
that. Just use find_get_pages_tag() directly.

CC: Jaegeuk Kim <jaegeuk@kernel.org>
CC: linux-f2fs-devel@lists.sourceforge.net
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/f2fs/file.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 61af721329fa..52df1ef66883 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -286,18 +286,19 @@ int f2fs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 static pgoff_t __get_first_dirty_index(struct address_space *mapping,
 						pgoff_t pgofs, int whence)
 {
-	struct pagevec pvec;
+	struct page *page;
 	int nr_pages;
 
 	if (whence != SEEK_DATA)
 		return 0;
 
 	/* find first dirty page index */
-	pagevec_init(&pvec, 0);
-	nr_pages = pagevec_lookup_tag(&pvec, mapping, &pgofs,
-					PAGECACHE_TAG_DIRTY, 1);
-	pgofs = nr_pages ? pvec.pages[0]->index : ULONG_MAX;
-	pagevec_release(&pvec);
+	nr_pages = find_get_pages_tag(mapping, &pgofs, PAGECACHE_TAG_DIRTY,
+				      1, &page);
+	if (!nr_pages)
+		return ULONG_MAX;
+	pgofs = page->index;
+	put_page(page);
 	return pgofs;
 }
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
