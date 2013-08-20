Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 915376B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 02:55:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 20 Aug 2013 12:15:10 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 78D471258051
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:24:56 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7K6uZPJ46203036
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:26:38 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7K6t74a020300
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:25:08 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/4] mm/pgtable: Fix continue to preallocate pmds even if failure occurrence
Date: Tue, 20 Aug 2013 14:54:53 +0800
Message-Id: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
 * remove failed.

preallocate_pmds will continue to preallocate pmds even if failure
occurrence, and then free all the preallocate pmds if there is
failure, this patch fix it by stop preallocate if failure occurrence
and go to free path.

Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 arch/x86/mm/pgtable.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index dfa537a..65c2106 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -196,21 +196,18 @@ static void free_pmds(pmd_t *pmds[])
 static int preallocate_pmds(pmd_t *pmds[])
 {
 	int i;
-	bool failed = false;
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
 		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
 		if (pmd == NULL)
-			failed = true;
+			goto err;
 		pmds[i] = pmd;
 	}
 
-	if (failed) {
-		free_pmds(pmds);
-		return -ENOMEM;
-	}
-
 	return 0;
+err:
+	free_pmds(pmds);
+	return -ENOMEM;
 }
 
 /*
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
