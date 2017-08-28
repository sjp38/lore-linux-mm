Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD5E6B0292
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 09:34:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p37so713582wrc.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:34:17 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 89si364994edq.95.2017.08.28.06.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 06:34:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 8A10C1C1969
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:34:15 +0100 (IST)
Date: Mon, 28 Aug 2017 14:34:15 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, madvise: Ensure poisoned pages are removed from per-cpu
 lists
Message-ID: <20170828133414.7qro57jbepdcyz5x@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Wendy Wang reported off-list that a RAS HWPOISON-SOFT test case failed and
bisected it to the commit 479f854a207c ("mm, page_alloc: defer debugging
checks of pages allocated from the PCP"). The problem is that a page that
was poisoned with madvise() is reused. The commit removed a check that
would trigger if DEBUG_VM was enabled but re-enabling the check only
fixes the problem as a side-effect by printing a bad_page warning and
recovering.

The root of the problem is that a madvise() can leave a poisoned on
the per-cpu list.  This patch drains all per-cpu lists after pages are
poisoned so that they will not be reused. Wendy reports that the test case
in question passes with this patch applied.  While this could be done in
a targeted fashion, it is over-complicated for such a rare operation.

Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
Reported-and-tested-by: Wang, Wendy <wendy.wang@intel.com>
Cc: stable@kernel.org
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/madvise.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index 23ed525bc2bc..4d7d1e5ddba9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -613,6 +613,7 @@ static int madvise_inject_error(int behavior,
 		unsigned long start, unsigned long end)
 {
 	struct page *page;
+	struct zone *zone;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -646,6 +647,11 @@ static int madvise_inject_error(int behavior,
 		if (ret)
 			return ret;
 	}
+
+	/* Ensure that all poisoned pages are removed from per-cpu lists */
+	for_each_populated_zone(zone)
+		drain_all_pages(zone);
+
 	return 0;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
