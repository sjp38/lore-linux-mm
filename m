Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DCD496B0062
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:08:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG381mR025863
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:08:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A7F8E45DE79
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:07:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF2245DE57
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:07:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 01CB91DB805E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:07:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D32151DB8055
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:07:27 +0900 (JST)
Date: Wed, 16 Dec 2009 12:04:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 4/11] mm accessor for kvm
Message-Id: <20091216120423.13636fe3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Use mm_accessor in /kvm layer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 security/tomoyo/common.c |    4 ++--
 virt/kvm/kvm_main.c      |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: mmotm-mm-accessor/virt/kvm/kvm_main.c
===================================================================
--- mmotm-mm-accessor.orig/virt/kvm/kvm_main.c
+++ mmotm-mm-accessor/virt/kvm/kvm_main.c
@@ -843,18 +843,18 @@ pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t 
 	if (unlikely(npages != 1)) {
 		struct vm_area_struct *vma;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		vma = find_vma(current->mm, addr);
 
 		if (vma == NULL || addr < vma->vm_start ||
 		    !(vma->vm_flags & VM_PFNMAP)) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm);
 			get_page(bad_page);
 			return page_to_pfn(bad_page);
 		}
 
 		pfn = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 		BUG_ON(!kvm_is_mmio_pfn(pfn));
 	} else
 		pfn = page_to_pfn(page[0]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
