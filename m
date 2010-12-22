Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A9DA86B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 05:32:57 -0500 (EST)
Date: Wed, 22 Dec 2010 11:32:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: + thp-compound_trans_order.patch added to -mm tree
Message-ID: <20101222103252.GJ26084@random.random>
References: <201012152358.oBFNwLn7013706@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201012152358.oBFNwLn7013706@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello Andrew,

here an incremental cleanup for this patch (it'd become
thp-compound_trans_order-fix.patch):

=====
Subject: thp: memcg: remove unnecessary compound_trans_order

From: Andrea Arcangeli <aarcange@redhat.com>

In these places PageTransHuge must not go away under memcg, as the page is
owned by the thread handling it. Add VM_BUG_ON and remove a superflous
page_size variable.

compound_trans_order for now remains for memory-failure.c, which later has to
be fixed to implement a safe compound_head too, that isn't safe right now.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1027,10 +1027,6 @@ mem_cgroup_get_reclaim_stat_from_page(st
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
-	int page_size = PAGE_SIZE;
-
-	if (PageTransHuge(page))
-		page_size <<= compound_trans_order(page);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2287,8 +2283,10 @@ static int mem_cgroup_charge_common(stru
 	int ret;
 	int page_size = PAGE_SIZE;
 
-	if (PageTransHuge(page))
-		page_size <<= compound_trans_order(page);
+	if (PageTransHuge(page)) {
+		page_size <<= compound_order(page);
+		VM_BUG_ON(!PageTransHuge(page));
+	}
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -2559,8 +2557,10 @@ __mem_cgroup_uncharge_common(struct page
 	if (PageSwapCache(page))
 		return NULL;
 
-	if (PageTransHuge(page))
-		page_size <<= compound_trans_order(page);
+	if (PageTransHuge(page)) {
+		page_size <<= compound_order(page);
+		VM_BUG_ON(!PageTransHuge(page));
+	}
 
 	count = page_size >> PAGE_SHIFT;
 	/*


On Wed, Dec 15, 2010 at 03:58:21PM -0800, Andrew Morton wrote:
> 
> The patch titled
>      thp: compound_trans_order
> has been added to the -mm tree.  Its filename is
>      thp-compound_trans_order.patch
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
