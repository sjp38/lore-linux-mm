Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC4A26B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 07:10:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d14so29742676qkb.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 04:10:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b190si12347590qke.275.2017.05.30.04.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 04:10:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] dax: set errors in mapping when writeback fails
Date: Tue, 30 May 2017 07:10:46 -0400
Message-Id: <20170530111046.8069-3-jlayton@redhat.com>
In-Reply-To: <20170530111046.8069-1-jlayton@redhat.com>
References: <20170530111046.8069-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neilb@suse.com>, willy@infradead.org, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

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
index c22eaf162f95..441280e15d5b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -856,8 +856,10 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 			ret = dax_writeback_one(bdev, dax_dev, mapping,
 					indices[i], pvec.pages[i]);
-			if (ret < 0)
+			if (ret < 0) {
+				mapping_set_error(mapping, ret);
 				goto out;
+			}
 		}
 	}
 out:
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
