Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2F618D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 15:17:34 -0500 (EST)
Message-ID: <4D6419C0.8080804@redhat.com>
Date: Tue, 22 Feb 2011 21:17:04 +0100
From: Petr Holasek <pholasek@redhat.com>
MIME-Version: 1.0
Subject: [PATCH v2] hugetlbfs: correct handling of negative input to /proc/sys/vm/nr_hugepages
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Petr Holasek <pholasek@redhat.com>, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

When user insert negative value into /proc/sys/vm/nr_hugepages it will 
result
in the setting a random number of HugePages in system (can be easily showed
at /proc/meminfo output). This patch fixes the wrong behavior so that the
negative input will result in nr_hugepages value unchanged.

v2: same fix was also done in hugetlb_overcommit_handler function
     as suggested by reviewers.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
  mm/hugetlb.c |    6 ++----
  1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bb0b7c1..06de5aa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1872,8 +1872,7 @@ static int hugetlb_sysctl_handler_common(bool 
obey_mempolicy,
      unsigned long tmp;
      int ret;

-    if (!write)
-        tmp = h->max_huge_pages;
+    tmp = h->max_huge_pages;

      if (write && h->order >= MAX_ORDER)
          return -EINVAL;
@@ -1938,8 +1937,7 @@ int hugetlb_overcommit_handler(struct ctl_table 
*table, int write,
      unsigned long tmp;
      int ret;

-    if (!write)
-        tmp = h->nr_overcommit_huge_pages;
+    tmp = h->nr_overcommit_huge_pages;

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
