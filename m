Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 581056007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 09:15:12 -0500 (EST)
Date: Wed, 2 Dec 2009 14:15:05 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] hugetlb: Abort a hugepage pool resize if a signal is
	pending
Message-ID: <20091202141504.GE1457@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If a user asks for a hugepage pool resize but specified a large number, the
machine can begin trashing. In response, they might hit ctrl-c but signals
are ignored and the pool resize continues until it fails an allocation. This
can take a considerable amount of time so this patch aborts a pool resize
if a signal is pending.

[dave@linux.vnet.ibm.com: His idea]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/hugetlb.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index af02ee8..a952cb8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1238,6 +1238,9 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
 		if (!ret)
 			goto out;
 
+		/* Bail for signals. Probably ctrl-c from user */
+		if (signal_pending(current))
+			goto out;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
