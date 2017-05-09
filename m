Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC752806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c75so1578258qka.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l62si297094qtd.118.2017.05.09.08.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:11 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 11/27] fuse: set mapping error in writepage_locked when it fails
Date: Tue,  9 May 2017 11:49:14 -0400
Message-Id: <20170509154930.29524-12-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

This ensures that we see errors on fsync when writeback fails.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/fuse/file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index ec238fb5a584..07d0efcb050c 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1669,6 +1669,7 @@ static int fuse_writepage_locked(struct page *page)
 err_free:
 	fuse_request_free(req);
 err:
+	mapping_set_error(page->mapping, error);
 	end_page_writeback(page);
 	return error;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
