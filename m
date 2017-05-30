Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD35E6B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 07:10:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d14so29742593qkb.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 04:10:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m125si12203195qkd.160.2017.05.30.04.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 04:10:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] mm: clear any AS_* errors when returning from filemap_write_and_wait{_range}
Date: Tue, 30 May 2017 07:10:45 -0400
Message-Id: <20170530111046.8069-2-jlayton@redhat.com>
In-Reply-To: <20170530111046.8069-1-jlayton@redhat.com>
References: <20170530111046.8069-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neilb@suse.com>, willy@infradead.org, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Currently we don't clear the address space error when there is a -EIO
error on fsync due to writeback initiation failure. If initiating writes
fails with -EIO and the mapping is already flagged with an AS_EIO or
AS_ENOSPC error, then we can end up returning errors on two fsync calls,
even when a write between them succeeded (or there was no write).

Ensure that we also clear out any mapping errors when initiating
writeback fails with -EIO in filemap_write_and_wait and
filemap_write_and_wait_range.

Suggested-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..39ff92d7ecdd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -488,7 +488,7 @@ EXPORT_SYMBOL(filemap_fdatawait);
 
 int filemap_write_and_wait(struct address_space *mapping)
 {
-	int err = 0;
+	int err;
 
 	if ((!dax_mapping(mapping) && mapping->nrpages) ||
 	    (dax_mapping(mapping) && mapping->nrexceptional)) {
@@ -503,6 +503,8 @@ int filemap_write_and_wait(struct address_space *mapping)
 			int err2 = filemap_fdatawait(mapping);
 			if (!err)
 				err = err2;
+		} else {
+			filemap_check_errors(mapping);
 		}
 	} else {
 		err = filemap_check_errors(mapping);
@@ -525,7 +527,7 @@ EXPORT_SYMBOL(filemap_write_and_wait);
 int filemap_write_and_wait_range(struct address_space *mapping,
 				 loff_t lstart, loff_t lend)
 {
-	int err = 0;
+	int err;
 
 	if ((!dax_mapping(mapping) && mapping->nrpages) ||
 	    (dax_mapping(mapping) && mapping->nrexceptional)) {
@@ -537,6 +539,8 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 						lstart, lend);
 			if (!err)
 				err = err2;
+		} else {
+			filemap_check_errors(mapping);
 		}
 	} else {
 		err = filemap_check_errors(mapping);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
