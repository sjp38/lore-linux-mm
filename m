Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 092736B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:43:59 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so8425311pdj.32
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:43:59 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id q6si21066876pbf.214.2014.02.11.19.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 19:43:59 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 09:13:53 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 058B1E005B
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:17:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1C3hjkV64880794
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:45 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1C3hn4W020078
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 2/3] mm: dirty accountable change only apply to non prot numa case
Date: Wed, 12 Feb 2014 09:13:37 +0530
Message-Id: <1392176618-23667-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

So move it within the if loop

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/mprotect.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 7332c1785744..33eab902f10e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -58,6 +58,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				if (pte_numa(ptent))
 					ptent = pte_mknonnuma(ptent);
 				ptent = pte_modify(ptent, newprot);
+				/*
+				 * Avoid taking write faults for pages we
+				 * know to be dirty.
+				 */
+				if (dirty_accountable && pte_dirty(ptent))
+					ptent = pte_mkwrite(ptent);
+				ptep_modify_prot_commit(mm, addr, pte, ptent);
 				updated = true;
 			} else {
 				struct page *page;
@@ -72,22 +79,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					}
 				}
 			}
-
-			/*
-			 * Avoid taking write faults for pages we know to be
-			 * dirty.
-			 */
-			if (dirty_accountable && pte_dirty(ptent)) {
-				ptent = pte_mkwrite(ptent);
-				updated = true;
-			}
-
 			if (updated)
 				pages++;
-
-			/* Only !prot_numa always clears the pte */
-			if (!prot_numa)
-				ptep_modify_prot_commit(mm, addr, pte, ptent);
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
