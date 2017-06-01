Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFD9C6B03B6
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k15so8719699wmh.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29si16872654wre.37.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 16/35] ceph: Use pagevec_lookup_range_tag()
Date: Thu,  1 Jun 2017 11:32:26 +0200
Message-Id: <20170601093245.29238-17-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

We want only pages from given range in ceph_writepages_start(). Use
pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
unnecessary code.

CC: Ilya Dryomov <idryomov@gmail.com>
CC: "Yan, Zheng" <zyan@redhat.com>
CC: ceph-devel@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ceph/addr.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 1e71e6ca5ddf..0b7e56ae3b8c 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -841,21 +841,16 @@ static int ceph_writepages_start(struct address_space *mapping,
 		struct page **pages = NULL, **data_pages;
 		mempool_t *pool = NULL;	/* Becomes non-null if mempool used */
 		struct page *page;
-		int want;
 		u64 offset = 0, len = 0;
 
 		max_pages = max_pages_ever;
 
 get_more_pages:
 		first = -1;
-		want = min(end - index,
-			   min((pgoff_t)PAGEVEC_SIZE,
-			       max_pages - (pgoff_t)locked_pages) - 1)
-			+ 1;
-		pvec_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-						PAGECACHE_TAG_DIRTY,
-						want);
-		dout("pagevec_lookup_tag got %d\n", pvec_pages);
+		pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
+						end, PAGECACHE_TAG_DIRTY,
+						PAGEVEC_SIZE);
+		dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
 		if (!pvec_pages && !locked_pages)
 			break;
 		for (i = 0; i < pvec_pages && locked_pages < max_pages; i++) {
@@ -873,12 +868,6 @@ static int ceph_writepages_start(struct address_space *mapping,
 				unlock_page(page);
 				break;
 			}
-			if (!wbc->range_cyclic && page->index > end) {
-				dout("end of range %p\n", page);
-				done = 1;
-				unlock_page(page);
-				break;
-			}
 			if (strip_unit_end && (page->index > strip_unit_end)) {
 				dout("end of strip unit %p\n", page);
 				unlock_page(page);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
