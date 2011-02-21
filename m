Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D14668D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 10:48:46 -0500 (EST)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH] hugetlbfs: correct handling of negative input to /proc/sys/vm/nr_hugepages
Date: Mon, 21 Feb 2011 16:47:49 +0100
Message-Id: <1298303270-3184-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Petr Holasek <pholasek@redhat.com>, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

When user insert negative value into /proc/sys/vm/nr_hugepages it will result
in the setting a random number of HugePages in system (can be easily showed
at /proc/meminfo output). This patch fixes the wrong behavior so that the
negative input will result in nr_hugepages value unchanged.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 mm/hugetlb.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bb0b7c1..f99d7a8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1872,8 +1872,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 	unsigned long tmp;
 	int ret;
 
-	if (!write)
-		tmp = h->max_huge_pages;
+	tmp = h->max_huge_pages;
 
 	if (write && h->order >= MAX_ORDER)
 		return -EINVAL;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
