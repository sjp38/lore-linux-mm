Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 364376B038B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:33:43 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so64496529wry.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:43 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t23si9716223wrc.41.2017.03.06.02.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:33:42 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id n11so12957721wma.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:41 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 9/9] bcache: use kvmalloc
Date: Mon,  6 Mar 2017 11:33:27 +0100
Message-Id: <20170306103327.2766-5-mhocko@kernel.org>
In-Reply-To: <20170306103327.2766-1-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103327.2766-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Kent Overstreet <kent.overstreet@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

bcache_device_init uses kmalloc for small requests and vmalloc for those
which are larger than 64 pages. This alone is a strange criterion.
Moreover kmalloc can fallback to vmalloc on the failure. Let's simply
use kvmalloc instead as it knows how to handle the fallback properly

Cc: Kent Overstreet <kent.overstreet@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/bcache/super.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index 85e3f21c2514..e57353e39168 100644
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
