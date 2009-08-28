Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F4846B007E
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:27:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S4RbXV008908
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 13:27:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C31D345DE51
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:27:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D07E45DE4D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:27:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 715B9E08001
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:27:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD26EE0800B
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:27:33 +0900 (JST)
Date: Fri, 28 Aug 2009 13:25:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] memcg: unmap, truncate, invalidate uncharege in
 batch
Message-Id: <20090828132542.37d712ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


We can do batched uncharge when
	- invalidate/truncte file
	- unmap range of pages.

This means we don't do "batched" uncharge in memory reclaim path.
I think it's reasonable.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory.c   |    2 ++
 mm/truncate.c |    6 ++++++
 2 files changed, 8 insertions(+)

Index: mmotm-2.6.31-Aug27/mm/memory.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/mm/memory.c
+++ mmotm-2.6.31-Aug27/mm/memory.c
@@ -909,6 +909,7 @@ static unsigned long unmap_page_range(st
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	mem_cgroup_uncharge_batch_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -921,6 +922,7 @@ static unsigned long unmap_page_range(st
 						zap_work, details);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
+	mem_cgroup_uncharge_batch_end();
 
 	return addr;
 }
Index: mmotm-2.6.31-Aug27/mm/truncate.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/mm/truncate.c
+++ mmotm-2.6.31-Aug27/mm/truncate.c
@@ -272,6 +272,7 @@ void truncate_inode_pages_range(struct a
 			pagevec_release(&pvec);
 			break;
 		}
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -286,6 +287,7 @@ void truncate_inode_pages_range(struct a
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_batch_end();
 	}
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -327,6 +329,7 @@ unsigned long invalidate_mapping_pages(s
 	pagevec_init(&pvec, 0);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t index;
@@ -354,6 +357,7 @@ unsigned long invalidate_mapping_pages(s
 				break;
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_batch_end();
 		cond_resched();
 	}
 	return ret;
@@ -428,6 +432,7 @@ int invalidate_inode_pages2_range(struct
 	while (next <= end && !wrapped &&
 		pagevec_lookup(&pvec, mapping, next,
 			min(end - next, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index;
@@ -477,6 +482,7 @@ int invalidate_inode_pages2_range(struct
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_batch_end();
 		cond_resched();
 	}
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
