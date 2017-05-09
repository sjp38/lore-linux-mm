Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB8B2806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w5so1459417qtw.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 201si407994qko.98.2017.05.09.08.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:49:59 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 08/27] dax: set errors in mapping when writeback fails
Date: Tue,  9 May 2017 11:49:11 -0400
Message-Id: <20170509154930.29524-9-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

Jan's description for this patch is much better than mine, so I'm
quoting it verbatim here:

DAX currently doesn't set errors in the mapping when cache flushing
fails in dax_writeback_mapping_range(). Since this function can get
called only from fsync(2) or sync(2), this is actually as good as it can
currently get since we correctly propagate the error up from
dax_writeback_mapping_range() to filemap_fdatawrite(). However in the
future better writeback error handling will enable us to properly report
these errors on fsync(2) even if there are multiple file descriptors
open against the file or if sync(2) gets called before fsync(2). So
convert DAX to using standard error reporting through the mapping.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-and-Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>
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
