Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 409DB6B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:14:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so24868176wmd.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:14:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si8049607wra.46.2017.10.09.08.14.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:06 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/16] ceph: Use pagevec_lookup_range_tag()
Date: Mon,  9 Oct 2017 17:13:46 +0200
Message-Id: <20171009151359.31984-4-jack@suse.cz>
In-Reply-To: <20171009151359.31984-1-jack@suse.cz>
References: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org

We want only pages from given range in ceph_writepages_start(). Use
pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
unnecessary code.

CC: Ilya Dryomov <idryomov@gmail.com>
CC: "Yan, Zheng" <zyan@redhat.com>
CC: ceph-devel@vger.kernel.org
Reviewed-by: "Yan, Zheng" <zyan@redhat.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ceph/addr.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index b3e3edc09d80..e57e9d37bf2d 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -871,13 +871,10 @@ static int ceph_writepages_start(struct address_space *mapping,
 get_more_pages:
 		pvec_pages = min_t(unsigned, PAGEVEC_SIZE,
 				   max_pages - locked_pages);
-		if (end - index < (u64)(pvec_pages - 1))
-			pvec_pages = (unsigned)(end - index) + 1;
-
-		pvec_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-						PAGECACHE_TAG_DIRTY,
+		pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
+						end, PAGECACHE_TAG_DIRTY,
 						pvec_pages);
-		dout("pagevec_lookup_tag got %d\n", pvec_pages);
+		dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
 		if (!pvec_pages && !locked_pages)
 			break;
 		for (i = 0; i < pvec_pages && locked_pages < max_pages; i++) {
@@ -895,16 +892,6 @@ static int ceph_writepages_start(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
-			if (page->index > end) {
-				dout("end of range %p\n", page);
-				/* can't be range_cyclic (1st pass) because
-				 * end == -1 in that case. */
-				stop = true;
-				if (ceph_wbc.head_snapc)
-					done = true;
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
