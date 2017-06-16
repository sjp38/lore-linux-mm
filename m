Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0275A83294
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:22 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o21so42429993qtb.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l126si2666014qkf.355.2017.06.16.12.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:21 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 06/22] mm: clear AS_EIO/AS_ENOSPC when writeback initiation fails
Date: Fri, 16 Jun 2017 15:34:11 -0400
Message-Id: <20170616193427.13955-7-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

filemap_write_and_wait{_range} will return an error if writeback
initiation fails, but won't clear errors in the address_space. This is
particularly problematic on DAX, as it's effectively synchronous. Ensure
that we clear the AS_EIO/AS_ENOSPC flags when filemap_fdatawrite returns
an error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 37f286df7c95..c349a5d3a34b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -517,6 +517,9 @@ int filemap_write_and_wait(struct address_space *mapping)
 			int err2 = filemap_fdatawait(mapping);
 			if (!err)
 				err = err2;
+		} else {
+			/* Clear any previously stored errors */
+			filemap_check_errors(mapping);
 		}
 	} else {
 		err = filemap_check_errors(mapping);
@@ -551,6 +554,9 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 						lstart, lend);
 			if (!err)
 				err = err2;
+		} else {
+			/* Clear any previously stored errors */
+			filemap_check_errors(mapping);
 		}
 	} else {
 		err = filemap_check_errors(mapping);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
