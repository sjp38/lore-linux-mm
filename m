Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E2DEE6B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so8666743wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w96si7202909wrc.60.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 26/35] afs: Use find_get_pages_range_tag()
Date: Thu,  1 Jun 2017 11:32:36 +0200
Message-Id: <20170601093245.29238-27-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Use find_get_pages_range_tag() in afs_writepages_region() as we are
interested only in pages from given range. Remove unnecessary code after
this conversion.

CC: David Howells <dhowells@redhat.com>
CC: linux-afs@lists.infradead.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/afs/write.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/afs/write.c b/fs/afs/write.c
index 2d2fccd5044b..630f2a42fae7 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -497,20 +497,13 @@ static int afs_writepages_region(struct address_space *mapping,
 	_enter(",,%lx,%lx,", index, end);
 
 	do {
-		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
-				       1, &page);
+		n = find_get_pages_range_tag(mapping, &index, end,
+					PAGECACHE_TAG_DIRTY, 1, &page);
 		if (!n)
 			break;
 
 		_debug("wback %lx", page->index);
 
-		if (page->index > end) {
-			*_next = index;
-			put_page(page);
-			_leave(" = 0 [%lx]", *_next);
-			return 0;
-		}
-
 		/* at this point we hold neither mapping->tree_lock nor lock on
 		 * the page itself: the page may be truncated or invalidated
 		 * (changing page->mapping to NULL), or even swizzled back from
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
