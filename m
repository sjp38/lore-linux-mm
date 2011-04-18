Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F655900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:15:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2412D3EE081
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E44145DE9F
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB30945DE8A
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDD771DB8038
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB6CE1DB802C
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:15:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/3] mn10300: replace mm->cpu_vm_mask with mm_cpumask
In-Reply-To: <20110418211455.9359.A69D9226@jp.fujitsu.com>
References: <20110418211455.9359.A69D9226@jp.fujitsu.com>
Message-Id: <20110418211626.935D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Apr 2011 21:15:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>

We plant to change mm->cpu_vm_mask definition later. Thus this
patch convert it into mm_cpumask().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
---
 arch/mn10300/kernel/smp.c |    2 +-
 arch/mn10300/mm/tlb-smp.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

mn10300 is one of last two cpu_vm_mask direct access users.

diff --git a/arch/mn10300/kernel/smp.c b/arch/mn10300/kernel/smp.c
index 83fb279..6d59726 100644
--- a/arch/mn10300/kernel/smp.c
+++ b/arch/mn10300/kernel/smp.c
@@ -986,7 +986,7 @@ int __cpu_disable(void)
 		return -EBUSY;
 
 	migrate_irqs();
-	cpu_clear(cpu, current->active_mm->cpu_vm_mask);
+	cpu_clear(cpu, mm_cpumask(current->active_mm));
 	return 0;
 }
 
diff --git a/arch/mn10300/mm/tlb-smp.c b/arch/mn10300/mm/tlb-smp.c
index 0b6a5ad..9d357b4 100644
--- a/arch/mn10300/mm/tlb-smp.c
+++ b/arch/mn10300/mm/tlb-smp.c
@@ -146,7 +146,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	cpumask_t cpu_mask;
 
 	preempt_disable();
-	cpu_mask = mm->cpu_vm_mask;
+	cpu_mask = mm_cpumask(mm);
 	cpu_clear(smp_processor_id(), cpu_mask);
 
 	local_flush_tlb();
@@ -165,7 +165,7 @@ void flush_tlb_current_task(void)
 	cpumask_t cpu_mask;
 
 	preempt_disable();
-	cpu_mask = mm->cpu_vm_mask;
+	cpu_mask = mm_cpumask(mm);
 	cpu_clear(smp_processor_id(), cpu_mask);
 
 	local_flush_tlb();
@@ -186,7 +186,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	cpumask_t cpu_mask;
 
 	preempt_disable();
-	cpu_mask = mm->cpu_vm_mask;
+	cpu_mask = mm_cpumask(mm);
 	cpu_clear(smp_processor_id(), cpu_mask);
 
 	local_flush_tlb_page(mm, va);
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
