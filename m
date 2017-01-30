Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8DB56B0268
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:50:02 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so60370142wjc.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:02 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id d21si15818321wrc.113.2017.01.30.01.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:50:01 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id ip10so7002350wjb.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:01 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 8/9] bcache: use kvmalloc
Date: Mon, 30 Jan 2017 10:49:39 +0100
Message-Id: <20170130094940.13546-9-mhocko@kernel.org>
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
References: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Kent Overstreet <kent.overstreet@gmail.com>

From: Michal Hocko <mhocko@suse.com>

bcache_device_init uses kmalloc for small requests and vmalloc for those
which are larger than 64 pages. This alone is a strange criterion.
Moreover kmalloc can fallback to vmalloc on the failure. Let's simply
use kvmalloc instead as it knows how to handle the fallback properly

Cc: Kent Overstreet <kent.overstreet@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/bcache/super.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index 3a19cbc8b230..4cb6b88a1465 100644
--- a/drivers/md/bcache/super.c
+++ b/drivers/md/bcache/super.c
@@ -767,16 +767,12 @@ static int bcache_device_init(struct bcache_device *d, unsigned block_size,
 	}
 
 	n = d->nr_stripes * sizeof(atomic_t);
-	d->stripe_sectors_dirty = n < PAGE_SIZE << 6
-		? kzalloc(n, GFP_KERNEL)
-		: vzalloc(n);
+	d->stripe_sectors_dirty = kvzalloc(n, GFP_KERNEL);
 	if (!d->stripe_sectors_dirty)
 		return -ENOMEM;
 
 	n = BITS_TO_LONGS(d->nr_stripes) * sizeof(unsigned long);
-	d->full_dirty_stripes = n < PAGE_SIZE << 6
-		? kzalloc(n, GFP_KERNEL)
-		: vzalloc(n);
+	d->full_dirty_stripes = kvzalloc(n, GFP_KERNEL);
 	if (!d->full_dirty_stripes)
 		return -ENOMEM;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
