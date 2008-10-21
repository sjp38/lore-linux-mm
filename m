Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L8w2jN007856
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 17:58:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50F542AC025
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:58:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29BAB12C046
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:58:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DEB5E1DB8042
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:58:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ACED1DB8040
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:58:01 +0900 (JST)
Date: Tue, 21 Oct 2008 17:57:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FD943D.5090709@cn.fujitsu.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD7EEF.3070803@cn.fujitsu.com>
	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD82E3.9050502@cn.fujitsu.com>
	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD943D.5090709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 16:35:09 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Tue, 21 Oct 2008 15:21:07 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> >> dmesg is attached.
> >>
> > Thanks....I think I caught some. (added Mel Gorman to CC:)
> > 
> > NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> > 
> > So, If there is a hole between zone, node->spanned_pages doesn't mean
> > length of node's memmap....(then, some hole can be skipped.)
> > 
> > OMG....Could you try this ? 
> > 
> 
> No luck, the same bug still exists. :(
> 
This is a little fixed one..

please..
-Kame
==
NODE_DATA(nid)->node_spanned_pages doesn't means width of node's memory.

alloc_node_page_cgroup() misunderstand it. This patch tries to use
the same algorithm as alloc_node_mem_map() for allocating page_cgroup()
for node.

Changelog:
 - fixed range of initialization loop.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/page_cgroup.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

Index: linux-2.6.27/mm/page_cgroup.c
===================================================================
--- linux-2.6.27.orig/mm/page_cgroup.c
+++ linux-2.6.27/mm/page_cgroup.c
@@ -9,6 +9,8 @@
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
+	if (!pfn_valid(pfn))
+		return;
 	pc->flags = 0;
 	pc->mem_cgroup = NULL;
 	pc->page = pfn_to_page(pfn);
@@ -41,10 +43,18 @@ static int __init alloc_node_page_cgroup
 {
 	struct page_cgroup *base, *pc;
 	unsigned long table_size;
-	unsigned long start_pfn, nr_pages, index;
+	unsigned long start, end, start_pfn, nr_pages, index;
 
+	/*
+	 * Instead of allocating page_cgroup for [start, end)
+	 * We allocate page_cgroup to the same size of mem_map.
+	 * See page_alloc.c::alloc_node_mem_map()
+	 */
 	start_pfn = NODE_DATA(nid)->node_start_pfn;
-	nr_pages = NODE_DATA(nid)->node_spanned_pages;
+	start = start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
+	end = start_pfn	+ NODE_DATA(nid)->node_spanned_pages;
+	end = ALIGN(end, MAX_ORDER_NR_PAGES);
+	nr_pages = end - start;
 
 	table_size = sizeof(struct page_cgroup) * nr_pages;
 
@@ -52,11 +62,12 @@ static int __init alloc_node_page_cgroup
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 	if (!base)
 		return -ENOMEM;
+
 	for (index = 0; index < nr_pages; index++) {
 		pc = base + index;
-		__init_page_cgroup(pc, start_pfn + index);
+		__init_page_cgroup(pc, start + index);
 	}
-	NODE_DATA(nid)->node_page_cgroup = base;
+	NODE_DATA(nid)->node_page_cgroup = base + start_pfn - start;
 	total_usage += table_size;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
