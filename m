Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D7A066B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 10:24:43 -0400 (EDT)
Received: by dadq36 with SMTP id q36so2312080dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 07:24:43 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] mm: fix devision by 0 in percpu_pagelist_fraction
Date: Sat, 28 Apr 2012 16:25:31 +0200
Message-Id: <1335623131-15728-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rohit.seth@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

percpu_pagelist_fraction_sysctl_handler() has only considered -EINVAL as a possible error
from proc_dointvec_minmax(). If any other error is returned, it would proceed to divide by
zero since percpu_pagelist_fraction wasn't getting initialized at any point. For example,
writing 0 bytes into the proc file would trigger the issue.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b951de..1e00729 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -106,7 +106,7 @@ unsigned long totalreserve_pages __read_mostly;
  */
 unsigned long dirty_balance_reserve __read_mostly;
 
-int percpu_pagelist_fraction;
+int percpu_pagelist_fraction = 8;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
 #ifdef CONFIG_PM_SLEEP
@@ -5271,7 +5271,7 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret == -EINVAL))
+	if (!write || (ret < 0))
 		return ret;
 	for_each_populated_zone(zone) {
 		for_each_possible_cpu(cpu) {
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
