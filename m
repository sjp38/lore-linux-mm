Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id DB2F26B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 05:28:54 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so1896480qcx.28
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 02:28:54 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id u5si53843400qed.99.2013.12.03.02.28.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 02:28:54 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 3 Dec 2013 05:28:53 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1D9DFC90041
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 05:28:49 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB3ASo7T6947306
	for <linux-mm@kvack.org>; Tue, 3 Dec 2013 10:28:50 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB3ASo2C025035
	for <linux-mm@kvack.org>; Tue, 3 Dec 2013 05:28:50 -0500
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC] mm readahead: Fix the readahead fail in case of empty numa node
Date: Tue,  3 Dec 2013 16:06:17 +0530
Message-Id: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

On a cpu with an empty numa node, readahead fails because max_sane_readahead
returns zero. The reason is we look into number of inactive + free pages 
available on the current node.

The following patch tries to fix the behaviour by checking for potential
empty numa node cases.
The rationale for the patch is, readahead may be worth doing on a remote
node instead of incuring costly disk faults later.

I still feel we may have to sanitize the nr below, (for e.g., nr/8)
to avoid serious consequences of malicious application trying to do
a big readahead on a empty numa node causing unnecessary load on remote nodes.
( or it may even be that current behaviour is right in not going ahead with
readahead to avoid the memory load on remote nodes).

please let me know any comments/suggestions.

---8<---
Currently, max_sane_readahead returns zero on the cpu with empty numa node,
fix this by checking for potential empty numa node case during calculation.

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 mm/readahead.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 7cdbb44..7597368 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -243,8 +243,11 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
-		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
+	unsigned long numa_free_page;
+	numa_free_page = (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
+			   + node_page_state(numa_node_id(), NR_FREE_PAGES));
+
+	return numa_free_page ? min(nr, numa_free_page / 2) : nr;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
