Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9078D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:33:40 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577721Ab1C1JdS (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:33:18 +0200
Date: Mon, 28 Mar 2011 11:33:18 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 2/4] xen/balloon: Simplify HVM integration
Message-ID: <20110328093318.GG13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Simplify HVM integration proposed by Stefano Stabellini
in 53d5522cad291a0e93a385e0594b6aea6b54a071.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 61665b2..42a0ba0 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -246,7 +246,7 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 		set_phys_to_machine(pfn, frame_list[i]);
 
 		/* Link back into the page tables if not highmem. */
-		if (!xen_hvm_domain() && !PageHighMem(page)) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
@@ -293,7 +293,7 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
 
 		scrub_page(page);
 
-		if (!xen_hvm_domain() && !PageHighMem(page)) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
 				__pte_ma(0), 0);
@@ -429,7 +429,7 @@ EXPORT_SYMBOL(free_xenballooned_pages);
 
 static int __init balloon_init(void)
 {
- 	unsigned long pfn, nr_pages, extra_pfn_end;
+	unsigned long pfn, extra_pfn_end;
 	struct page *page;
 
 	if (!xen_domain())
@@ -437,11 +437,7 @@ static int __init balloon_init(void)
 
 	pr_info("xen/balloon: Initialising balloon driver.\n");
 
- 	if (xen_pv_domain())
- 		nr_pages = xen_start_info->nr_pages;
- 	else
- 		nr_pages = max_pfn;
- 	balloon_stats.current_pages = min(nr_pages, max_pfn);
+	balloon_stats.current_pages = xen_pv_domain() ? min(xen_start_info->nr_pages, max_pfn) : max_pfn;
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
