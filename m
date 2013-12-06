Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 70F856B0055
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:12:33 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so731374pbb.4
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:12:33 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id ku6si60836789pbc.96.2013.12.06.01.12.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 01:12:32 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 6 Dec 2013 19:12:26 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id F21AD2BB002D
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 20:12:20 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB69C8K17668088
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 20:12:08 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB69CKCL006323
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 20:12:20 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/6] sched/numa: fix set cpupid on page migration twice
Date: Fri,  6 Dec 2013 17:12:11 +0800
Message-Id: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over 
the cpupid at page migration time, there is unnecessary to set it again 
in migrate_misplaced_transhuge_page, this patch fix it.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/migrate.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index bb94004..fdb70f7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1736,8 +1736,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!new_page)
 		goto out_fail;
 
-	page_cpupid_xchg_last(new_page, page_cpupid_last(page));
-
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
 		put_page(new_page);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
