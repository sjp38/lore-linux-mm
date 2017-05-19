Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B01632806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 10:40:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p74so57164661pfd.11
        for <linux-mm@kvack.org>; Fri, 19 May 2017 07:40:47 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id o61si110425plb.81.2017.05.19.07.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 07:40:46 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id s62so10011133pgc.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 07:40:46 -0700 (PDT)
From: Firo Yang <firogm@gmail.com>
Subject: [PATCH] mm, vmstat: Fix NULL pointer dereference during pagetypeinfo print
Date: Fri, 19 May 2017 22:39:36 +0800
Message-Id: <20170519143936.21209-1-firogm@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, mhocko@suse.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Firo Yang <firogm@gmail.com>

During showing the pagetypeinfo, we forgot to save the found page
and dereference a invalid page address from the stack.

To fix it, save and reference the page address returned by
pfn_to_online_page().

Signed-off-by: Firo Yang <firogm@gmail.com>
---
 mm/vmstat.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index c432e58..6dae6b2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1223,7 +1223,8 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
 
-		if (!pfn_to_online_page(pfn))
+		page = pfn_to_online_page(pfn);
+		if (!page)
 			continue;
 
 		/* Watch for unexpected holes punched in the memmap */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
