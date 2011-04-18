Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF73900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:18:15 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C26343EE0AE
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B6045DE93
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 861D245DE91
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 76080E08001
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31A981DB803B
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:18:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/3] tile: replace mm->cpu_vm_mask with mm_cpumask()
In-Reply-To: <20110418211455.9359.A69D9226@jp.fujitsu.com>
References: <20110418211455.9359.A69D9226@jp.fujitsu.com>
Message-Id: <20110418211914.9361.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Apr 2011 21:18:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Chris Metcalf <cmetcalf@tilera.com>

We plan to change mm->cpu_vm_mask definition later. Thus, this patch convert
it into proper macro.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/include/asm/mmu_context.h |    4 ++--
 arch/tile/kernel/tlb.c              |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

tile is one of last two cpu_vm_mask direct access users. I hope convert it
even if anyone refuse [path 3/3].

Chris, I couldn't get cross compiler for tile. thus I hope you check it carefully.
Thanks.

diff --git a/arch/tile/include/asm/mmu_context.h b/arch/tile/include/asm/mmu_context.h
index 9bc0d07..15fb246 100644
--- a/arch/tile/include/asm/mmu_context.h
+++ b/arch/tile/include/asm/mmu_context.h
@@ -100,8 +100,8 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		__get_cpu_var(current_asid) = asid;
 
 		/* Clear cpu from the old mm, and set it in the new one. */
-		cpumask_clear_cpu(cpu, &prev->cpu_vm_mask);
-		cpumask_set_cpu(cpu, &next->cpu_vm_mask);
+		cpumask_clear_cpu(cpu, mm_cpumask(prev));
+		cpumask_set_cpu(cpu, mm_cpumask(next));
 
 		/* Re-load page tables */
 		install_page_table(next->pgd, asid);
diff --git a/arch/tile/kernel/tlb.c b/arch/tile/kernel/tlb.c
index 2dffc10..a5f241c 100644
--- a/arch/tile/kernel/tlb.c
+++ b/arch/tile/kernel/tlb.c
@@ -34,13 +34,13 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	HV_Remote_ASID asids[NR_CPUS];
 	int i = 0, cpu;
-	for_each_cpu(cpu, &mm->cpu_vm_mask) {
+	for_each_cpu(cpu, mm_cpumask(mm)) {
 		HV_Remote_ASID *asid = &asids[i++];
 		asid->y = cpu / smp_topology.width;
 		asid->x = cpu % smp_topology.width;
 		asid->asid = per_cpu(current_asid, cpu);
 	}
-	flush_remote(0, HV_FLUSH_EVICT_L1I, &mm->cpu_vm_mask,
+	flush_remote(0, HV_FLUSH_EVICT_L1I, mm_cpumask(mm),
 		     0, 0, 0, NULL, asids, i);
 }
 
@@ -54,8 +54,8 @@ void flush_tlb_page_mm(const struct vm_area_struct *vma, struct mm_struct *mm,
 {
 	unsigned long size = hv_page_size(vma);
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask,
-		     va, size, size, &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, cache, mm_cpumask(mm),
+		     va, size, size, mm_cpumask(mm), NULL, 0);
 }
 
 void flush_tlb_page(const struct vm_area_struct *vma, unsigned long va)
@@ -70,8 +70,8 @@ void flush_tlb_range(const struct vm_area_struct *vma,
 	unsigned long size = hv_page_size(vma);
 	struct mm_struct *mm = vma->vm_mm;
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask, start, end - start, size,
-		     &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, cache, mm_cpumask(mm), start, end - start, size,
+		     mm_cpumask(mm), NULL, 0);
 }
 
 void flush_tlb_all(void)
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
