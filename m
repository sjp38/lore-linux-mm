Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A22676B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 03:10:58 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n148Attd032325
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Feb 2009 17:10:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FF1D45DE53
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:10:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5057045DE52
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:10:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 363601DB8060
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:10:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DE64C1DB805F
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 17:10:54 +0900 (JST)
Date: Wed, 4 Feb 2009 17:09:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use __GFP_NOWARN in page cgroup allocation
Message-Id: <20090204170944.c93772d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, heiko.carstens@de.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This was recommended in
"kmalloc-return-null-instead-of-link-failure.patch added to -mm tree" thread
in the last month.
Thanks,
-Kame
=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

page_cgroup's page allocation at init/memory hotplug uses kmalloc() and
vmalloc(). If kmalloc() failes, vmalloc() is used.

This is because vmalloc() is very limited resource on 32bit systems.
We want to use kmalloc() first.

But in this kind of call, __GFP_NOWARN should be specified.

Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.29-Feb03/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.29-Feb03.orig/mm/page_cgroup.c
+++ mmotm-2.6.29-Feb03/mm/page_cgroup.c
@@ -114,7 +114,8 @@ static int __init_refok init_section_pag
 		nid = page_to_nid(pfn_to_page(pfn));
 		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 		if (slab_is_available()) {
-			base = kmalloc_node(table_size, GFP_KERNEL, nid);
+			base = kmalloc_node(table_size,
+					GFP_KERNEL | __GFP_NOWARN, nid);
 			if (!base)
 				base = vmalloc_node(table_size, nid);
 		} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
