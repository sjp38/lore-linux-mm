Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A38176B003A
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:34:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 21:24:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A520A2BB0050
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:34:10 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IBY1dt1835384
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:34:02 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IBY9SK006886
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:34:10 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 6/6] mm/pgtable: Don't accumulate addr during pgd prepopulate pmd
Date: Tue, 18 Jun 2013 19:33:42 +0800
Message-Id: <1371555222-22678-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
