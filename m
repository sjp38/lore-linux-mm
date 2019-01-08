Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCDE58E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 14:32:14 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so2592475pgc.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 11:32:14 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q19si10188068pfh.138.2019.01.08.11.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 11:32:13 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 94/97] mm/page-writeback.c: don't break integrity writeback on ->writepage() error
Date: Tue,  8 Jan 2019 14:29:43 -0500
Message-Id: <20190108192949.122407-94-sashal@kernel.org>
In-Reply-To: <20190108192949.122407-1-sashal@kernel.org>
References: <20190108192949.122407-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Brian Foster <bfoster@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Brian Foster <bfoster@redhat.com>

[ Upstream commit 3fa750dcf29e8606e3969d13d8e188cc1c0f511d ]

write_cache_pages() is used in both background and integrity writeback
scenarios by various filesystems.  Background writeback is mostly
concerned with cleaning a certain number of dirty pages based on various
mm heuristics.  It may not write the full set of dirty pages or wait for
I/O to complete.  Integrity writeback is responsible for persisting a set
of dirty pages before the writeback job completes.  For example, an
fsync() call must perform integrity writeback to ensure data is on disk
before the call returns.

write_cache_pages() unconditionally breaks out of its processing loop in
the event of a ->writepage() error.  This is fine for background
writeback, which had no strict requirements and will eventually come
around again.  This can cause problems for integrity writeback on
filesystems that might need to clean up state associated with failed page
writeouts.  For example, XFS performs internal delayed allocation
accounting before returning a ->writepage() error, where applicable.  If
the current writeback happens to be associated with an unmount and
write_cache_pages() completes the writeback prematurely due to error, the
filesystem is unmounted in an inconsistent state if dirty+delalloc pages
still exist.

To handle this problem, update write_cache_pages() to always process the
full set of pages for integrity writeback regardless of ->writepage()
errors.  Save the first encountered error and return it to the caller once
complete.  This facilitates XFS (or any other fs that expects integrity
writeback to process the entire set of dirty pages) to clean up its
internal state completely in the event of persistent mapping errors.
Background writeback continues to exit on the first error encountered.

[akpm@linux-foundation.org: fix typo in comment]
Link: http://lkml.kernel.org/r/20181116134304.32440-1-bfoster@redhat.com
Signed-off-by: Brian Foster <bfoster@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page-writeback.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 84ae9bf5858a..ea4fd3af3b4b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2156,6 +2156,7 @@ int write_cache_pages(struct address_space *mapping,
 {
 	int ret = 0;
 	int done = 0;
+	int error;
 	struct pagevec pvec;
 	int nr_pages;
 	pgoff_t uninitialized_var(writeback_index);
@@ -2236,25 +2237,31 @@ int write_cache_pages(struct address_space *mapping,
 				goto continue_unlock;
 
 			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
-			ret = (*writepage)(page, wbc, data);
-			if (unlikely(ret)) {
-				if (ret == AOP_WRITEPAGE_ACTIVATE) {
+			error = (*writepage)(page, wbc, data);
+			if (unlikely(error)) {
+				/*
+				 * Handle errors according to the type of
+				 * writeback. There's no need to continue for
+				 * background writeback. Just push done_index
+				 * past this page so media errors won't choke
+				 * writeout for the entire file. For integrity
+				 * writeback, we must process the entire dirty
+				 * set regardless of errors because the fs may
+				 * still have state to clear for each page. In
+				 * that case we continue processing and return
+				 * the first error.
+				 */
+				if (error == AOP_WRITEPAGE_ACTIVATE) {
 					unlock_page(page);
-					ret = 0;
-				} else {
-					/*
-					 * done_index is set past this page,
-					 * so media errors will not choke
-					 * background writeout for the entire
-					 * file. This has consequences for
-					 * range_cyclic semantics (ie. it may
-					 * not be suitable for data integrity
-					 * writeout).
-					 */
+					error = 0;
+				} else if (wbc->sync_mode != WB_SYNC_ALL) {
+					ret = error;
 					done_index = page->index + 1;
 					done = 1;
 					break;
 				}
+				if (!ret)
+					ret = error;
 			}
 
 			/*
-- 
2.19.1
