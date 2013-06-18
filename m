Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5506B6B003A
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 19:53:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 05:17:12 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id F411A3940057
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:22:58 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5INr7ri14483506
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:23:07 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5INqvte024827
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:52:58 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 6/6] mm/pgtable: Don't accumulate addr during pgd prepopulate pmd
Date: Wed, 19 Jun 2013 07:52:43 +0800
Message-Id: <1371599563-6424-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v2 - > v3:
   * add Michal's Reviewed-by

The old codes accumulate addr to get right pmd, however,
currently pmds are preallocated and transfered as a parameter,
there is unnecessary to accumulate addr variable any more, this
patch remove it.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 arch/x86/mm/pgtable.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 17fda6a..dfa537a 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -240,7 +240,6 @@ static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
 {
 	pud_t *pud;
-	unsigned long addr;
 	int i;
 
 	if (PREALLOCATED_PMDS == 0) /* Work around gcc-3.4.x bug */
@@ -248,8 +247,7 @@ static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
 
 	pud = pud_offset(pgd, 0);
 
- 	for (addr = i = 0; i < PREALLOCATED_PMDS;
-	     i++, pud++, addr += PUD_SIZE) {
+	for (i = 0; i < PREALLOCATED_PMDS; i++, pud++) {
 		pmd_t *pmd = pmds[i];
 
 		if (i >= KERNEL_PGD_BOUNDARY)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
