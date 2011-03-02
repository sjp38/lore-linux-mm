Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1878B8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:38:39 -0500 (EST)
Received: by gwj15 with SMTP id 15so3205265gwj.8
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:38:36 -0800 (PST)
From: Liu Yuan <namei.unix@gmail.com>
Subject: [RFC PATCH 5/5] mm: Add readpages accounting
Date: Wed,  2 Mar 2011 16:38:10 +0800
Message-Id: <1299055090-23976-5-git-send-email-namei.unix@gmail.com>
In-Reply-To: <no>
References: <no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

From: Liu Yuan <tailai.ly@taobao.com>

The _readpages_ counter simply counts how many pages the kernel
really request from the disk, either by readahead module or
aop->readpage() when readahead window equals 0.

This counter is request-centric and doesnot check read errors
since the read requests are issued to the block layer already.

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 mm/filemap.c   |    1 +
 mm/readahead.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 5388b2a..d638391 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1137,6 +1137,7 @@ readpage:
 		 */
 		ClearPageError(page);
 		/* Start the actual read. The read will unlock the page. */
+		page_cache_acct_readpages(mapping->host->i_sb, 1);
 		error = mapping->a_ops->readpage(filp, page);
 
 		if (unlikely(error)) {
diff --git a/mm/readahead.c b/mm/readahead.c
index 77506a2..483acb8 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -112,6 +112,8 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	unsigned page_idx;
 	int ret;
 
+	page_cache_acct_readpages(mapping->host->i_sb, nr_pages);
+
 	if (mapping->a_ops->readpages) {
 		ret = mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
 		/* Clean up the remaining pages */
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
