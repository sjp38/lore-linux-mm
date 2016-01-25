Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C0E386B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:03:29 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so56986935wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:03:29 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id e6si27357868wjs.198.2016.01.25.02.03.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 02:03:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 7C5D398AAB
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:03:25 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/2] mm: filemap: Avoid unnecessary calls to lock_page when waiting for IO to complete during a read
Date: Mon, 25 Jan 2016 10:03:24 +0000
Message-Id: <1453716204-20409-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
References: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

In the generic read paths the kernel looks up a page in the page cache
and if it's up to date, it is used. If not, the page lock is acquired to
wait for IO to complete and then check the page.  If multiple processes
are waiting on IO, they all serialise against the lock and duplicate the
checks. This is unnecessary.

The page lock in itself does not give any guarantees to the callers about
the page state as it can be immediately truncated or reclaimed after the
page is unlocked. It's sufficient to wait_on_page_locked and then continue
if the page is up to date on wakeup.

It is possible that a truncated but up-to-date page is returned but the
reference taken during read prevents it disappearing underneath the caller
and the data is still valid if PageUptodate.

The overall impact is small as even if processes serialise on the lock,
the lock section is tiny once the IO is complete. Profiles indicated that
unlock_page and friends are generally a tiny portion of a read-intensive
workload.  An artifical test was created that had instances of dd access
a cache-cold file on an ext4 filesystem and measure how long the read took.

paralleldd
                                    4.4.0                 4.4.0
                                  vanilla             avoidlock
Amean    Elapsd-1          5.28 (  0.00%)        5.15 (  2.50%)
Amean    Elapsd-4          5.29 (  0.00%)        5.17 (  2.12%)
Amean    Elapsd-7          5.28 (  0.00%)        5.18 (  1.78%)
Amean    Elapsd-12         5.20 (  0.00%)        5.33 ( -2.50%)
Amean    Elapsd-21         5.14 (  0.00%)        5.21 ( -1.41%)
Amean    Elapsd-30         5.30 (  0.00%)        5.12 (  3.38%)
Amean    Elapsd-48         5.78 (  0.00%)        5.42 (  6.21%)
Amean    Elapsd-79         6.78 (  0.00%)        6.62 (  2.46%)
Amean    Elapsd-110        9.09 (  0.00%)        8.99 (  1.15%)
Amean    Elapsd-128       10.60 (  0.00%)       10.43 (  1.66%)

The impact is small but intuitively, it makes sense to avoid unnecessary
calls to lock_page.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/filemap.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index aa38593d0cd5..235ee2b0b5da 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1649,6 +1649,15 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 					index, last_index - index);
 		}
 		if (!PageUptodate(page)) {
+			/*
+			 * See comment in do_read_cache_page on why
+			 * wait_on_page_locked is used to avoid unnecessarily
+			 * serialisations and why it's safe.
+			 */
+			wait_on_page_locked(page);
+			if (PageUptodate(page))
+				goto page_ok;
+
 			if (inode->i_blkbits == PAGE_CACHE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
@@ -2321,12 +2330,52 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	if (PageUptodate(page))
 		goto out;
 
+	/*
+	 * Page is not up to date and may be locked due one of the following
+	 * case a: Page is being filled and the page lock is held
+	 * case b: Read/write error clearing the page uptodate status
+	 * case c: Truncation in progress (page locked)
+	 * case d: Reclaim in progress
+	 *
+	 * Case a, the page will be up to date when the page is unlocked.
+	 *    There is no need to serialise on the page lock here as the page
+	 *    is pinned so the lock gives no additional protection. Even if the
+	 *    the page is truncated, the data is still valid if PageUptodate as
+	 *    it's a race vs truncate race.
+	 * Case b, the page will not be up to date
+	 * Case c, the page may be truncated but in itself, the data may still
+	 *    be valid after IO completes as it's a read vs truncate race. The
+	 *    operation must restart if the page is not uptodate on unlock but
+	 *    otherwise serialising on page lock to stabilise the mapping gives
+	 *    no additional guarantees to the caller as the page lock is
+	 *    released before return.
+	 * Case d, similar to truncation. If reclaim holds the page lock, it
+	 *    will be a race with remove_mapping that determines if the mapping
+	 *    is valid on unlock but otherwise the data is valid and there is
+	 *    no need to serialise with page lock.
+	 *
+	 * As the page lock gives no additional guarantee, we optimistically
+	 * wait on the page to be unlocked and check if it's up to date and
+	 * use the page if it is. Otherwise, the page lock is required to
+	 * distinguish between the different cases. The motivation is that we
+	 * avoid spurious serialisations and wakeups when multiple processes
+	 * wait on the same page for IO to complete.
+	 */
+	wait_on_page_locked(page);
+	if (PageUptodate(page))
+		goto out;
+
+	/* Distinguish between all the cases under the safety of the lock */
 	lock_page(page);
+
+	/* Case c or d, restart the operation */
 	if (!page->mapping) {
 		unlock_page(page);
 		page_cache_release(page);
 		goto repeat;
 	}
+
+	/* Someone else locked and filled the page in a very small window */
 	if (PageUptodate(page)) {
 		unlock_page(page);
 		goto out;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
