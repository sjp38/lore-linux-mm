Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7DD48D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:32:48 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577721Ab1C1Jcb (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:32:31 +0200
Date: Mon, 28 Mar 2011 11:32:31 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 1/4] xen/balloon: Use PageHighMem() for high memory page detection
Message-ID: <20110328093231.GF13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Replace pfn < max_low_pfn by !PageHighMem() in increase_reservation().
It makes more clearer what is going on.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 043af8a..61665b2 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -246,7 +246,7 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 		set_phys_to_machine(pfn, frame_list[i]);
 
 		/* Link back into the page tables if not highmem. */
-		if (!xen_hvm_domain() && pfn < max_low_pfn) {
+		if (!xen_hvm_domain() && !PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
