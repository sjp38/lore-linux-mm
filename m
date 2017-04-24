Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30E6E6B03A3
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j130so41527544qkj.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k31si18023156qtf.53.2017.04.24.06.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 18/20] mm: clean up error handling in write_one_page
Date: Mon, 24 Apr 2017 09:22:57 -0400
Message-Id: <20170424132259.8680-19-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

Don't try to check PageError since that's potentially racy and not
necessarily going to be set after writepage errors out.

Instead, sample the mapping error early on, and use that value to tell
us whether we got a writeback error since then.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/page-writeback.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index de0dbf12e2c1..1643456881b4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2373,11 +2373,12 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 int write_one_page(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	int ret = 0;
+	int ret = 0, ret2;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 1,
 	};
+	errseq_t since = filemap_sample_wb_error(mapping);
 
 	BUG_ON(!PageLocked(page));
 
@@ -2386,16 +2387,14 @@ int write_one_page(struct page *page)
 	if (clear_page_dirty_for_io(page)) {
 		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
-		if (ret == 0) {
+		if (ret == 0)
 			wait_on_page_writeback(page);
-			if (PageError(page))
-				ret = -EIO;
-		}
 		put_page(page);
 	} else {
 		unlock_page(page);
 	}
-	return ret;
+	ret2 = filemap_check_wb_error(mapping, since);
+	return ret ? : ret2;
 }
 EXPORT_SYMBOL(write_one_page);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
