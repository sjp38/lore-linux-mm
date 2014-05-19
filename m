Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id BD1BD6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 04:57:10 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so3357929eek.36
        for <linux-mm@kvack.org>; Mon, 19 May 2014 01:57:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k46si4246531eew.60.2014.05.19.01.57.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 01:57:09 -0700 (PDT)
Date: Mon, 19 May 2014 09:57:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Avoid unnecessary atomic operations during
 end_page_writeback
Message-ID: <20140519085704.GI23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

If a page is marked for immediate reclaim then it is moved to the tail of
the LRU list. This occurs when the system is under enough memory pressure
for pages under writeback to reach the end of the LRU but we test for
this using atomic operations on every writeback. This patch uses an
optimistic non-atomic test first. It'll miss some pages in rare cases but
the consequences are not severe enough to warrant such a penalty.

While the function does not dominate profiles during a simple dd test the
cost of it is reduced.

73048     0.7428  vmlinux-3.15.0-rc5-mmotm-20140513 end_page_writeback
23740     0.2409  vmlinux-3.15.0-rc5-lessatomic     end_page_writeback

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/filemap.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index bec4b9b..dafb06f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -753,8 +753,17 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (TestClearPageReclaim(page))
+	/*
+	 * TestClearPageReclaim could be used here but it is an atomic
+	 * operation and overkill in this particular case. Failing to
+	 * shuffle a page marked for immediate reclaim is too mild to
+	 * justify taking an atomic operation penalty at the end of
+	 * ever page writeback.
+	 */
+	if (PageReclaim(page)) {
+		ClearPageReclaim(page);
 		rotate_reclaimable_page(page);
+	}
 
 	if (!test_clear_page_writeback(page))
 		BUG();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
