Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 92B256B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 17:35:50 -0400 (EDT)
Date: Wed, 29 Apr 2009 22:13:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mmotm] memcg: fix mem_cgroup_update_mapped_file_stat oops
Message-ID: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_SPARSEMEM=y CONFIG_CGROUP_MEM_RES_CTLR=y cgroup_disable=memory
bootup is oopsing in mem_cgroup_update_mapped_file_stat().  !SPARSEMEM
is fine because its lookup_page_cgroup() contains an explicit check for
NULL node_page_cgroup, but the SPARSEMEM version was missing a check for
NULL section->page_cgroup.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Should go in as a fix to
memcg-add-file-based-rss-accounting.patch
but it's curious that's the first thing to suffer from this divergence.

Perhaps this is the wrong fix, and there should be an explicit
mem_cgroup_disable() check somewhere else; but it would then seem
dangerous that SPARSEMEM and !SPARSEMEM diverge in this way,
and there are lots of lookup_page_cgroup NULL tests around.

 mm/page_cgroup.c |    2 ++
 1 file changed, 2 insertions(+)

--- 2.6.30-rc3-mm1/mm/page_cgroup.c	2009-04-29 21:01:06.000000000 +0100
+++ mmotm/mm/page_cgroup.c	2009-04-29 21:12:04.000000000 +0100
@@ -99,6 +99,8 @@ struct page_cgroup *lookup_page_cgroup(s
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
 
+	if (!section->page_cgroup)
+		return NULL;
 	return section->page_cgroup + pfn;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
