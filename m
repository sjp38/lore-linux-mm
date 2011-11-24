Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C58336B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 07:38:17 -0500 (EST)
Received: by wwf22 with SMTP id 22so536114wwf.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:38:15 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 24 Nov 2011 20:38:14 +0800
Message-ID: <CAJd=RBCJwyo3dQAYmE3oXBBDMDa5GkePfQ_Sct_YUt5=_1-ovw@mail.gmail.com>
Subject: [PATCH] mm: compaction: push isolate search base of compact control
 one pfn ahead
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

After isolated the current pfn will no longer be scanned and isolated if the
next round is necessary, so push the isolate_migratepages search base of the
given compact_control one step ahead.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/compaction.c	Thu Nov 24 20:23:28 2011
+++ b/mm/compaction.c	Thu Nov 24 20:32:41 2011
@@ -365,8 +365,10 @@ static isolate_migrate_t isolate_migrate
 		nr_isolated++;

 		/* Avoid isolating too much */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
+			++low_pfn;
 			break;
+		}
 	}

 	acct_isolated(zone, cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
