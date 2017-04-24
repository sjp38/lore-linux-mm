Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19D5D6B0317
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v1so38900013qtg.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q34si18003085qte.281.2017.04.24.06.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:00 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 07/20] nilfs2: set the mapping error when calling SetPageError on writeback
Date: Mon, 24 Apr 2017 09:22:46 -0400
Message-Id: <20170424132259.8680-8-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

In a later patch, we're going to want to make the fsync codepath not do
a TestClearPageError call as that can override the error set in the
address space. To do that though, we need to ensure that filesystems
that are relying on the PG_error bit for reporting writeback errors
also set an error in the address space.

Ensure that this is set in nilfs2.

Cc: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nilfs2/segment.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index febed1217b3f..612d4b446793 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1745,6 +1745,7 @@ static void nilfs_end_page_io(struct page *page, int err)
 	} else {
 		__set_page_dirty_nobuffers(page);
 		SetPageError(page);
+		mapping_set_error(page_mapping(page), err);
 	}
 
 	end_page_writeback(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
