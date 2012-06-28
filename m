Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3A4DD6B00A1
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:11 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 29/40] autonuma: retain page last_nid information in khugepaged
Date: Thu, 28 Jun 2012 14:56:09 +0200
Message-Id: <1340888180-15355-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

When pages are collapsed try to keep the last_nid information from one
of the original pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 094f82b..ae20409 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1814,7 +1814,18 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			clear_user_highpage(page, address);
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
 		} else {
+#ifdef CONFIG_AUTONUMA
+			int autonuma_last_nid;
+#endif
 			src_page = pte_page(pteval);
+#ifdef CONFIG_AUTONUMA
+			/* pick the last one, better than nothing */
+			autonuma_last_nid =
+				ACCESS_ONCE(src_page->autonuma_last_nid);
+			if (autonuma_last_nid >= 0)
+				ACCESS_ONCE(page->autonuma_last_nid) =
+					autonuma_last_nid;
+#endif
 			copy_user_highpage(page, src_page, address, vma);
 			VM_BUG_ON(page_mapcount(src_page) != 1);
 			VM_BUG_ON(page_count(src_page) != 2);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
