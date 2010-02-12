Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0A562001A
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:06 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 12/12] mm: Check the anon_vma is still valid in rmap_walk_anon()
Date: Fri, 12 Feb 2010 12:00:59 +0000
Message-Id: <1265976059-7459-13-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Despite the additional locking added around rmap_walk_anon, bad
references still manage to trigger on ppc64. The most likely cause is a
use-after-free but it's not clear if it's due to a locking problem or
something ppc64 specific. This patch somewhat works around the problem
by checking the contents of the anon_vma make sense before using it but
it needs reviewing by eyes familiar with the page migration code to try
spot where the real problem lies.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/rmap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index fb695d3..462ac86 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1237,6 +1237,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		goto out_rcu_unlock;
+	if (!anon_vma->head.next)
+		goto out_rcu_unlock;
 	spin_lock(&anon_vma->lock);
 
 	/*
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
