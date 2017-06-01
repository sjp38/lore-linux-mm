Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 60A1D6B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:34:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d127so8642219wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:34:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si33439438wmj.93.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 24/35] mm: Use pagevec_lookup_range_tag() in write_cache_pages()
Date: Thu,  1 Jun 2017 11:32:34 +0200
Message-Id: <20170601093245.29238-25-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Use pagevec_lookup_range_tag() in write_cache_pages() as it is
interested only in pages from given range. Remove unnecessary code
resulting from this.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 143c1c25d680..c77c387465ec 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2194,30 +2194,14 @@ int write_cache_pages(struct address_space *mapping,
 	while (!done && (index <= end)) {
 		int i;
 
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+				tag, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end) {
-				/*
-				 * can't be range_cyclic (1st pass) because
-				 * end == -1 in that case.
-				 */
-				done = 1;
-				break;
-			}
-
 			done_index = page->index;
 
 			lock_page(page);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
