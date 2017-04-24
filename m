Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42FE46B0315
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:23:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y80so41399132qka.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:23:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si18039904qtg.132.2017.04.24.06.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:23:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 06/20] dax: set errors in mapping when writeback fails
Date: Mon, 24 Apr 2017 09:22:45 -0400
Message-Id: <20170424132259.8680-7-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

In order to get proper error codes from fsync, we must set an error in
the mapping range when writeback fails.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/dax.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 85abd741253d..9b6b04030c3f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -901,8 +901,10 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 			ret = dax_writeback_one(bdev, mapping, indices[i],
 					pvec.pages[i]);
-			if (ret < 0)
+			if (ret < 0) {
+				mapping_set_error(mapping, ret);
 				return ret;
+			}
 		}
 	}
 	return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
