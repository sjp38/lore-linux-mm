Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 784BE6B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 23:09:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F39B4I002898
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Apr 2010 12:09:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3357845DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:09:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 159BF45DE50
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:09:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 61966E08001
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:09:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 177601DB8015
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:09:10 +0900 (JST)
Date: Thu, 15 Apr 2010 12:05:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][BUGFIX][PATCH 1/2] memcg: fix charge bypass route of
 migration
Message-Id: <20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I'd like to wait until next mmotm comes out. (So, [RFC]) I'll rebase
This patch is based on
 mmotm-2010/04/05
 +
 mm-migration-take-a-reference-to-the-anon_vma-before-migrating.patch
 mm-migration-do-not-try-to-migrate-unmapped-anonymous-pages.patch
 mm-share-the-anon_vma-ref-counts-between-ksm-and-page-migration.patch
 mm-migration-allow-the-migration-of-pageswapcache-pages.patch
 memcg-fix-prepare-migration.patch

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is an additonal fix to memcg-fix-prepare-migration.patch

Now, try_charge can bypass charge if TIF_MEMDIE at el are marked on the caller.
In this case, the charge is bypassed. This makes accounts corrupted.
(PageCgroup will be marked as PCG_USED even if bypassed, and css->refcnt
 can leak.)

This patch clears passed "*memcg" in bypass route.

Because usual page allocater passes memcg=NULL, this patch only affects
some special case as
  - move account
  - migration
  - swapin.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: mmotm-temp/mm/memcontrol.c
===================================================================
--- mmotm-temp.orig/mm/memcontrol.c
+++ mmotm-temp/mm/memcontrol.c
@@ -1606,8 +1606,12 @@ static int __mem_cgroup_try_charge(struc
 	 * MEMDIE process.
 	 */
 	if (unlikely(test_thread_flag(TIF_MEMDIE)
-		     || fatal_signal_pending(current)))
+		     || fatal_signal_pending(current))) {
+		/* Showing we skipped charge */
+		if (memcg)
+			*memcg = NULL;
 		goto bypass;
+	}
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -2523,7 +2527,6 @@ int mem_cgroup_prepare_migration(struct 
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
 		css_put(&mem->css);
 	}
-	*ptr = mem;
 	return ret;
 }
 


  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
