Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 390066B00FC
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:54:53 -0400 (EDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp [192.51.44.35])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P2YJNi004173
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 11:34:19 +0900
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P2Xiij004894
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 11:33:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BAA3145DE55
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:33:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 883E845DE51
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:33:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48F3D1DB803C
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:33:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF389EF8003
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:33:42 +0900 (JST)
Date: Tue, 25 Aug 2009 11:31:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][preview][patch 2/2] memcg: uncharge at truncate/unmap in
 batched manner
Message-Id: <20090825113127.04d46f9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds hook to start batched uncharge into
  - unmap
  - truncate

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: linux-2.6.31-rc7/mm/memory.c
===================================================================
--- linux-2.6.31-rc7.orig/mm/memory.c
+++ linux-2.6.31-rc7/mm/memory.c
@@ -907,6 +907,7 @@ static unsigned long unmap_page_range(st
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	mem_cgroup_uncharge_batch_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -919,6 +920,7 @@ static unsigned long unmap_page_range(st
 						zap_work, details);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
+	mem_cgroup_uncharge_batch_end();
 
 	return addr;
 }
Index: linux-2.6.31-rc7/mm/truncate.c
===================================================================
--- linux-2.6.31-rc7.orig/mm/truncate.c
+++ linux-2.6.31-rc7/mm/truncate.c
@@ -231,6 +231,7 @@ void truncate_inode_pages_range(struct a
 			pagevec_release(&pvec);
 			break;
 		}
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -250,6 +251,7 @@ void truncate_inode_pages_range(struct a
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_batch_end();
 	}
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -291,6 +293,7 @@ unsigned long invalidate_mapping_pages(s
 	pagevec_init(&pvec, 0);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t index;
@@ -322,6 +325,7 @@ unlock:
 				break;
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_batch_end();
 		cond_resched();
 	}
 	return ret;
@@ -396,6 +400,7 @@ int invalidate_inode_pages2_range(struct
 	while (next <= end && !wrapped &&
 		pagevec_lookup(&pvec, mapping, next,
 			min(end - next, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		mem_cgroup_uncharge_batch_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index;
@@ -445,6 +450,7 @@ int invalidate_inode_pages2_range(struct
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
