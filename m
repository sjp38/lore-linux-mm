Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 476258D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:42:26 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EcRZu010469
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:38:27 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EgKfw1310724
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:42:20 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EgJml007404
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:42:20 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:02:38 +0530
Message-Id: <20110401143238.15455.69361.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 1/26]  1: mm: replace_page() loses static attribute
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


User bkpt will use background page replacement approach to insert/delete
breakpoints. Background page replacement approach is based on
replace_page. Hence replace_page() loses its static attribute.
This is a precursor to moving replace_page() to mm/memory.c

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
---
 include/linux/mm.h |    2 ++
 mm/ksm.c           |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7606d7d..089bda4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1008,6 +1008,8 @@ void account_page_writeback(struct page *page);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+int replace_page(struct vm_area_struct *vma, struct page *page,
+					struct page *kpage, pte_t orig_pte);
 
 /* Is the vma a continuation of the stack vma above it? */
 static inline int vma_stack_continue(struct vm_area_struct *vma, unsigned long addr)
diff --git a/mm/ksm.c b/mm/ksm.c
index 1bbe785..f444158 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -760,7 +760,7 @@ out:
  *
  * Returns 0 on success, -EFAULT on failure.
  */
-static int replace_page(struct vm_area_struct *vma, struct page *page,
+int replace_page(struct vm_area_struct *vma, struct page *page,
 			struct page *kpage, pte_t orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
