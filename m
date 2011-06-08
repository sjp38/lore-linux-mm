Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8C26B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 20:49:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EA28C3EE0BB
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:49:13 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D0CCE45DE68
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:49:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E85A45DE4E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:49:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90AD51DB802C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:49:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 500F41DB803A
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 09:49:13 +0900 (JST)
Date: Wed, 8 Jun 2011 09:42:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110608094219.823c24f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
	<20110606125421.GB30184@cmpxchg.org>
	<20110606144519.1e2e7d86.akpm@linux-foundation.org>
	<20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607084530.GI5247@suse.de>
	<20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607090900.GK5247@suse.de>
	<20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607101857.GM5247@suse.de>
	<20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Wed, 8 Jun 2011 08:40:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 7 Jun 2011 11:18:57 +0100
> Mel Gorman <mgorman@suse.de> wrote:
 
> > I also don't think the ARM punching holes in the memmap is a problem
> > because we'd at least expect the start of the node to be valid.
> > 
> 
> Ok, I'll post a fixed and cleaned one. (above patch has bug ;(
> 
> Thanks,
> -Kame
> 

fixed one here. I found another bug in node hotplug and will post
a fix later.
==

With sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.
But this may scan a pfn which is not on any node and can access
memmap which is not initialized.

This makes page_cgroup_init() for SPARSEMEM node aware and remove
a code to get nid from page->flags. (Then, we'll use valid NID
always.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_cgroup.c |   41 +++++++++++++++++++++++++++++++++--------
 1 file changed, 33 insertions(+), 8 deletions(-)

Index: linux-3.0-rc1/mm/page_cgroup.c
===================================================================
--- linux-3.0-rc1.orig/mm/page_cgroup.c
+++ linux-3.0-rc1/mm/page_cgroup.c
@@ -162,21 +162,25 @@ static void free_page_cgroup(void *addr)
 }
 #endif
 
-static int __meminit init_section_page_cgroup(unsigned long pfn)
+static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 {
 	struct page_cgroup *base, *pc;
 	struct mem_section *section;
 	unsigned long table_size;
 	unsigned long nr;
-	int nid, index;
+	int index;
 
+	/*
+	 * Even if passed 'pfn' is not aligned to section, we need to align
+	 * it to section boundary because of SPARSEMEM pfn calculation.
+	 */
+	pfn = ALIGN(pfn, PAGES_PER_SECTION);
 	nr = pfn_to_section_nr(pfn);
 	section = __nr_to_section(nr);
 
 	if (section->page_cgroup)
 		return 0;
 
-	nid = page_to_nid(pfn_to_page(pfn));
 	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 	base = alloc_page_cgroup(table_size, nid);
 
@@ -228,7 +232,7 @@ int __meminit online_page_cgroup(unsigne
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
 		if (!pfn_present(pfn))
 			continue;
-		fail = init_section_page_cgroup(pfn);
+		fail = init_section_page_cgroup(pfn, nid);
 	}
 	if (!fail)
 		return 0;
@@ -285,14 +289,35 @@ void __init page_cgroup_init(void)
 {
 	unsigned long pfn;
 	int fail = 0;
+	int node;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
-		if (!pfn_present(pfn))
-			continue;
-		fail = init_section_page_cgroup(pfn);
+	for_each_node_state(node, N_HIGH_MEMORY) {
+		unsigned long start_pfn, end_pfn;
+
+		start_pfn = NODE_DATA(node)->node_start_pfn;
+		end_pfn = start_pfn + NODE_DATA(node)->node_spanned_pages;
+		/*
+		 * Because we cannot trust page->flags of page out of node
+		 * boundary, we skip pfn < start_pfn.
+		 */
+		for (pfn = start_pfn;
+		     !fail && (pfn < end_pfn);
+		     pfn = ALIGN(pfn + PAGES_PER_SECTION, PAGES_PER_SECTION)) {
+			if (!pfn_present(pfn))
+				continue;
+			/*
+			 * Nodes can be overlapped
+			 * We know some arch can have nodes layout as
+			 * -------------pfn-------------->
+			 * N0 | N1 | N2 | N0 | N1 | N2 |.....
+			 */
+			if (pfn_to_nid(pfn) != node)
+				continue;
+			fail = init_section_page_cgroup(pfn, node);
+		}
 	}
 	if (fail) {
 		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
