Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id A6DE66B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 06:45:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 11 Apr 2012 16:12:34 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3BAgSYx2187454
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 16:12:28 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3BGC921027233
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 21:42:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Wed, 11 Apr 2012 16:05:16 +0530
Message-Id: <20120411103516.23245.2700.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 1/2] uprobes/core: Make background page replacement logic account for rss_stat counters
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Background page replacement logic adds a new anonymous page instead of a
filebacked(while inserting a breakpoint) / anonymous page(while removing a
breakpoint). Hence logic should take care to update the rss_stat counters
accordingly. This bug became apparent courtesy commit c3f0327f8e9d7

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/events/uprobes.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 29e881b..c5caeec 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -160,6 +160,11 @@ static int __replace_page(struct vm_area_struct *vma, struct page *page, struct 
 	get_page(kpage);
 	page_add_new_anon_rmap(kpage, vma, addr);
 
+	if (!PageAnon(page)) {
+		dec_mm_counter(mm, MM_FILEPAGES);
+		inc_mm_counter(mm, MM_ANONPAGES);
+	}
+
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
