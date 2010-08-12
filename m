Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AACAB6B02A6
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 04:02:04 -0400 (EDT)
Date: Thu, 12 Aug 2010 16:59:41 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC] [PATCH 2/4] dio: add page locking for direct I/O
Message-ID: <20100812075941.GD6112@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Basically it is user's responsibility to take care of race condition
related to direct I/O, but some events which are out of user's control
(such as memory failure) can happen at any time. So we need to lock and
set/clear PG_writeback flags in dierct I/O code to protect from data loss.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/direct-io.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index 7600aac..0d0810d 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -439,7 +439,10 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio)
 			struct page *page = bvec[page_no].bv_page;
 
 			if (dio->rw == READ && !PageCompound(page))
-				set_page_dirty_lock(page);
+				set_page_dirty(page);
+			if (dio->rw & WRITE)
+				end_page_writeback(page);
+			unlock_page(page);
 			page_cache_release(page);
 		}
 		bio_put(bio);
@@ -702,11 +705,14 @@ submit_page_section(struct dio *dio, struct page *page,
 {
 	int ret = 0;
 
+	lock_page(page);
+
 	if (dio->rw & WRITE) {
 		/*
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		set_page_writeback(page);
 	}
 
 	/*
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
