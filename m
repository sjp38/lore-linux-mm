Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 889706B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:55:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b184so12561787oih.9
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:55:44 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y206si8767777oig.366.2017.07.26.10.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:55:43 -0700 (PDT)
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 1/4] mm: consolidate dax / non-dax checks for writeback
Date: Wed, 26 Jul 2017 13:55:35 -0400
Message-Id: <20170726175538.13885-2-jlayton@kernel.org>
In-Reply-To: <20170726175538.13885-1-jlayton@kernel.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

From: Jeff Layton <jlayton@redhat.com>

We have this complex conditional copied to several places. Turn it into
a helper function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/filemap.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index e1cca770688f..72e46e6f0d9a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -522,12 +522,17 @@ int filemap_fdatawait(struct address_space *mapping)
 }
 EXPORT_SYMBOL(filemap_fdatawait);
 
+static bool mapping_needs_writeback(struct address_space *mapping)
+{
+	return (!dax_mapping(mapping) && mapping->nrpages) ||
+	    (dax_mapping(mapping) && mapping->nrexceptional);
+}
+
 int filemap_write_and_wait(struct address_space *mapping)
 {
 	int err = 0;
 
-	if ((!dax_mapping(mapping) && mapping->nrpages) ||
-	    (dax_mapping(mapping) && mapping->nrexceptional)) {
+	if (mapping_needs_writeback(mapping)) {
 		err = filemap_fdatawrite(mapping);
 		/*
 		 * Even if the above returned error, the pages may be
@@ -566,8 +571,7 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 {
 	int err = 0;
 
-	if ((!dax_mapping(mapping) && mapping->nrpages) ||
-	    (dax_mapping(mapping) && mapping->nrexceptional)) {
+	if (mapping_needs_writeback(mapping)) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
@@ -656,8 +660,7 @@ int file_write_and_wait_range(struct file *file, loff_t lstart, loff_t lend)
 	int err = 0, err2;
 	struct address_space *mapping = file->f_mapping;
 
-	if ((!dax_mapping(mapping) && mapping->nrpages) ||
-	    (dax_mapping(mapping) && mapping->nrexceptional)) {
+	if (mapping_needs_writeback(mapping)) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
