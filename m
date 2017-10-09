Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1026B026D
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:14:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q203so26518693wmb.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:14:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si8049624wra.46.2017.10.09.08.14.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:07 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/16] ceph: Use pagevec_lookup_range_nr_tag()
Date: Mon,  9 Oct 2017 17:13:56 +0200
Message-Id: <20171009151359.31984-14-jack@suse.cz>
In-Reply-To: <20171009151359.31984-1-jack@suse.cz>
References: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>

Use new function for looking up pages since nr_pages argument from
pagevec_lookup_range_tag() is going away.

Reviewed-by: "Yan, Zheng" <zyan@redhat.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
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
