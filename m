Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7A16B03AE
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:45:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so5276754wrb.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:45:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g203si10063290wme.130.2017.06.19.05.45.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 05:45:41 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] dax: Fix inefficiency in dax_writeback_mapping_range()
Date: Mon, 19 Jun 2017 14:45:31 +0200
Message-Id: <20170619124531.21491-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, stable@vger.kernel.org

dax_writeback_mapping_range() fails to update iteration index when
searching radix tree for entries needing cache flushing. Thus each
pagevec worth of entries is searched starting from the start which is
inefficient and prone to livelocks. Update index properly.

CC: stable@vger.kernel.org
Fixes: 9973c98ecfda3a1dfcab981665b5f1e39bcde64a
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/dax.c b/fs/dax.c
index 2a6889b3585f..9187f3b07f3e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -859,6 +859,7 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 			if (ret < 0)
 				goto out;
 		}
+		start_index = indices[pvec.nr - 1] + 1;
 	}
 out:
 	put_dax(dax_dev);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
