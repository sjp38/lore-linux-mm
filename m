Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6DA3A6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:51:37 -0500 (EST)
Date: Tue, 24 Nov 2009 16:51:13 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 6/9] ksm: mem cgroup charge swapin copy
In-Reply-To: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

But ksm swapping does require one small change in mem cgroup handling.
When do_swap_page()'s call to ksm_might_need_to_copy() does indeed
substitute a duplicate page to accommodate a different anon_vma (or a
different index), that page escaped mem cgroup accounting, because of
the !PageSwapCache check in mem_cgroup_try_charge_swapin().

That was returning success without charging, on the assumption that
pte_same() would fail after, which is not the case here.  Originally I
proposed that success, so that an unshrinkable mem cgroup at its limit
would not fail unnecessarily; but that's a minor point, and there are
plenty of other places where we may fail an overallocation which might
later prove unnecessary.  So just go ahead and do what all the other
exceptions do: proceed to charge current mm.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/memcontrol.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- ksm5/mm/memcontrol.c	2009-11-14 10:17:02.000000000 +0000
+++ ksm6/mm/memcontrol.c	2009-11-22 20:40:37.000000000 +0000
@@ -1862,11 +1862,12 @@ int mem_cgroup_try_charge_swapin(struct
 		goto charge_cur_mm;
 	/*
 	 * A racing thread's fault, or swapoff, may have already updated
-	 * the pte, and even removed page from swap cache: return success
-	 * to go on to do_swap_page()'s pte_same() test, which should fail.
+	 * the pte, and even removed page from swap cache: in those cases
+	 * do_swap_page()'s pte_same() test will fail; but there's also a
+	 * KSM case which does need to charge the page.
 	 */
 	if (!PageSwapCache(page))
-		return 0;
+		goto charge_cur_mm;
 	mem = try_get_mem_cgroup_from_swapcache(page);
 	if (!mem)
 		goto charge_cur_mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
