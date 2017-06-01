Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFB526B036A
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i77so8693333wmh.10
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si20204342wru.100.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 23/35] mm: Use pagevec_lookup_range_tag() in __filemap_fdatawait_range()
Date: Thu,  1 Jun 2017 11:32:33 +0200
Message-Id: <20170601093245.29238-24-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Use pagevec_lookup_range_tag() in __filemap_fdatawait_range() as it is
interested only in pages from given range. Remove unnecessary code
resulting from this.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 56af68f6a375..8039b6bb9c27 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -390,18 +390,13 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
-			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			PAGECACHE_TAG_WRITEBACK,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
+			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
+			&index, end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE))) {
 		unsigned i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
-				continue;
-
 			wait_on_page_writeback(page);
 			if (TestClearPageError(page))
 				ret = -EIO;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
