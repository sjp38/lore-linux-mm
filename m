Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C2D7A6B00EA
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:22:16 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:21:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 4/6] uprobes: change register_for_each_vma() to take
	mm->mmap_sem for writing
Message-ID: <20120405222146.GD19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Change register_for_each_vma() to take mm->mmap_sem for writing.
This is a bit unfortunate but hopefully not too bad, this is the
slow path anyway.

This is needed to ensure that find_active_uprobe() can not race
with uprobe_register() which adds the new bp at the same bp_vaddr,
after find_uprobe() fails and before is_swbp_at_addr_fast() checks
the memory.

IOW, this is needed to ensure that if find_active_uprobe() returns
NULL but is_swbp == true, we can safely assume that it was the
"normal" int3 and we should send SIGTRAP.
---
 kernel/events/uprobes.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 054c00f..2af458d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -838,12 +838,12 @@ static int register_for_each_vma(struct uprobe *uprobe, bool is_register)
 		}
 
 		mm = vi->mm;
-		down_read(&mm->mmap_sem);
+		down_write(&mm->mmap_sem);
 		vma = find_vma(mm, (unsigned long)vi->vaddr);
 		if (!vma || !valid_vma(vma, is_register)) {
 			list_del(&vi->probe_list);
 			kfree(vi);
-			up_read(&mm->mmap_sem);
+			up_write(&mm->mmap_sem);
 			mmput(mm);
 			continue;
 		}
@@ -852,7 +852,7 @@ static int register_for_each_vma(struct uprobe *uprobe, bool is_register)
 						vaddr != vi->vaddr) {
 			list_del(&vi->probe_list);
 			kfree(vi);
-			up_read(&mm->mmap_sem);
+			up_write(&mm->mmap_sem);
 			mmput(mm);
 			continue;
 		}
@@ -862,7 +862,7 @@ static int register_for_each_vma(struct uprobe *uprobe, bool is_register)
 		else
 			remove_breakpoint(uprobe, mm, vi->vaddr);
 
-		up_read(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
 		mmput(mm);
 		if (is_register) {
 			if (ret && ret == -EEXIST)
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
