Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB53LGrk027065
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 12:21:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1857E45DE57
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:21:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDAF945DE55
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:21:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC5581DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:21:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A6961DB803B
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:21:15 +0900 (JST)
Date: Fri, 5 Dec 2008 12:20:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG ?] failed to boot on IA64 with CONFIG_DISCONTIGMEM=y
Message-Id: <20081205122024.3fcc1d0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49389B69.9010902@cn.fujitsu.com>
References: <49389B69.9010902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 05 Dec 2008 11:09:29 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Kernel version: 2.6.28-rc7
> Arch: IA64
> Memory model: DISCONTIGMEM
> 
> ELILO boot: Uncompressing Linux... done
> Loading file initrd-2.6.28-rc7-lizf.img...done
> (frozen)
> 
> 
> Booted successfully with cgroup_disable=memory, here is the dmesg:
> 

thx, will dig into...Maybe you're the first person using DISCONTIGMEM with
empty_node after page_cgroup-alloc-at-boot.

How about this ?
-Kame
==

From: kamezawa.hiroyu@jp.fujitsu.com

page_cgroup should ignore empty-nodes.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/page_cgroup.c |    3 +++
 1 file changed, 3 insertions(+)

Index: mmotm-2.6.28-Dec03/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Dec03/mm/page_cgroup.c
@@ -51,6 +51,9 @@ static int __init alloc_node_page_cgroup
 	start_pfn = NODE_DATA(nid)->node_start_pfn;
 	nr_pages = NODE_DATA(nid)->node_spanned_pages;
 
+	if (!nr_pages)
+		return;
+
 	table_size = sizeof(struct page_cgroup) * nr_pages;
 
 	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
