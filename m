Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 40E5C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 11:08:49 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id b13so3420914wgh.8
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 08:08:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lr5si5322053wjb.138.2014.03.06.08.08.45
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 08:08:46 -0800 (PST)
Date: Thu, 06 Mar 2014 11:08:33 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53189d8e.657ac20a.4cb5.ffff927eSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5317FA3B.8060900@oracle.com>
References: <53126861.7040107@oracle.com>
 <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5314E0CD.6070308@oracle.com>
 <5314F661.30202@oracle.com>
 <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com>
 <531657DC.4050204@oracle.com>
 <1393976967-lnmm5xcs@n-horiguchi@ah.jp.nec.com>
 <5317FA3B.8060900@oracle.com>
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Wed, Mar 05, 2014 at 11:31:55PM -0500, Sasha Levin wrote:
...
> > Sorry, I didn't write it but I also run it as root on VM, so condition is
> > the same. It might depend on kernel config, so I'm now trying the config
> > you previously gave me, but it doesn't boot correctly on my environment
> > (panic in initialization). I may need some time to get over this.
> 
> I'd be happy to help with anything off-list, it shouldn't be too difficult
> to get that kernel to boot :)

Thanks. I did reproduce this on my kernel although it's only once and
I needed many trials due to hitting other bugs.

And I found my patch was totally wrong because it should check
!pte_present(), not pte_present().
I'm testing fixed one (see below), and the problem seems not to reproduce
in my environment at least for now.
But I'm not 100% sure, so I need your double checking.

> I've also reverted the page walker series for now, it makes it impossible
> to test anything else since it seems that hitting one of the issues is quite
> easy.

OK. Sorry for the bother.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 6 Mar 2014 07:08:24 -0500
Subject: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks

Page table walker doesn't check non-present hugetlb entry in common path,
so hugetlb_entry() callbacks must check it. The reason for this behavior
is that some callers want to handle it in its own way.

However, some callers don't check it now, which causes unpredictable result,
for example when we have a race between migrating hugepage and reading
/proc/pid/numa_maps. This patch fixes it by adding pte_present checks on
buggy callbacks.

This bug exists for long and got visible by introducing hugepage migration.

ChangeLog v2:
- fix if condition (check pte_present() instead of pte_present())

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.12+
---
 fs/proc/task_mmu.c | 3 +++
 mm/mempolicy.c     | 6 +++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f819d0d4a0e8..762026098381 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1301,6 +1301,9 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
 	if (pte_none(*pte))
 		return 0;
 
+	if (!pte_present(*pte))
+		return 0;
+
 	page = pte_page(*pte);
 	if (!page)
 		return 0;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b2155b8adbae..494f401bbf6c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -524,8 +524,12 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
 	unsigned long flags = qp->flags;
 	int nid;
 	struct page *page;
+	pte_t entry;
 
-	page = pte_page(huge_ptep_get(pte));
+	entry = huge_ptep_get(pte);
+	if (!pte_present(entry))
+		return 0;
+	page = pte_page(entry);
 	nid = page_to_nid(page);
 	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 		return 0;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
