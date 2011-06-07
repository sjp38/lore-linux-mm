Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F36446B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 21:04:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 90E483EE0C1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:04:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7045745DED5
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:04:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 467D145DED2
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:04:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A2D8E78008
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:04:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0589E78005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:04:06 +0900 (JST)
Date: Tue, 7 Jun 2011 09:57:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110606144519.1e2e7d86.akpm@linux-foundation.org>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
	<20110606125421.GB30184@cmpxchg.org>
	<20110606144519.1e2e7d86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Mon, 6 Jun 2011 14:45:19 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Hopefully he can test this one for us as well, thanks.
> 

A  patch with better description (of mine) is here.
Anyway, I felt I needed a fix for ARM special case.

==
fix-init-page_cgroup-for-sparsemem-taking-care-of-broken-page-flags.patch
Even with SPARSEMEM, there are some magical memmap.

If a Node is not aligned to SECTION, memmap of pfn which is out of
Node's range is not initialized. And page->flags contains 0.

If Node(0) doesn't exist, NODE_DATA(pfn_to_nid(pfn)) causes error.

In another case, for example, ARM frees memmap which is never be used
even under SPARSEMEM. In that case, page->flags will contain broken
value.

This patch does a strict check on nid which is obtained by
pfn_to_page() and use proper NID for page_cgroup allocation.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/page_cgroup.c |   36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

Index: linux-3.0-rc1/mm/page_cgroup.c
===================================================================
--- linux-3.0-rc1.orig/mm/page_cgroup.c
+++ linux-3.0-rc1/mm/page_cgroup.c
@@ -168,6 +168,7 @@ static int __meminit init_section_page_c
 	struct mem_section *section;
 	unsigned long table_size;
 	unsigned long nr;
+	unsigned long tmp;
 	int nid, index;
 
 	nr = pfn_to_section_nr(pfn);
@@ -175,8 +176,41 @@ static int __meminit init_section_page_c
 
 	if (section->page_cgroup)
 		return 0;
+	/*
+	 * check Node-ID. Because we get 'pfn' which is obtained by calculation,
+	 * the pfn may "not exist" or "alreay freed". Even if pfn_valid() returns
+	 * true, page->flags may contain broken value and pfn_to_nid() returns
+	 * bad value.
+	 * (See CONFIG_ARCH_HAS_HOLES_MEMORYMODEL and ARM's free_memmap())
+	 * So, we need to do careful check, here.
+	 */
+	for (tmp = pfn;
+	     tmp < pfn + PAGES_PER_SECTION;
+	     tmp += MAX_ORDER_NR_PAGES, nid = -1) {
+		struct page *page;
+
+		if (!pfn_valid(tmp))
+			continue;
+
+		page = pfn_to_page(tmp);
+		nid = page_to_nid(page);
 
-	nid = page_to_nid(pfn_to_page(pfn));
+		/*
+		 * If 'page' isn't initialized or freed, it may contains broken
+		 * information.
+		 */
+		if (!node_state(nid, N_NORMAL_MEMORY))
+			continue;
+		if (page_to_pfn(pfn_to_page(tmp)) != tmp)
+			continue;
+		/*
+		 * The page seems valid and this 'nid' is safe to access,
+ 		 * at least.
+ 		 */
+		break;
+	}
+	if (nid == -1)
+		return 0;
 	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 	base = alloc_page_cgroup(table_size, nid);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
