Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 389226B0271
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r136so86558wmf.4
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si2267443edk.533.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/15] ceph: Use pagevec_lookup_range_nr_tag()
Date: Thu, 14 Sep 2017 15:18:17 +0200
Message-Id: <20170914131819.26266-14-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>

Use new function for looking up pages since nr_pages argument from
pagevec_lookup_range_tag() is going away.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ceph/addr.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index e57e9d37bf2d..87789c477381 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -869,11 +869,9 @@ static int ceph_writepages_start(struct address_space *mapping,
 		max_pages = wsize >> PAGE_SHIFT;
 
 get_more_pages:
-		pvec_pages = min_t(unsigned, PAGEVEC_SIZE,
-				   max_pages - locked_pages);
-		pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
+		pvec_pages = pagevec_lookup_range_nr_tag(&pvec, mapping, &index,
 						end, PAGECACHE_TAG_DIRTY,
-						pvec_pages);
+						max_pages - locked_pages);
 		dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
 		if (!pvec_pages && !locked_pages)
 			break;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
