Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7AA66B069E
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k136-v6so3489878oih.4
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u134-v6si1195132oif.37.2018.05.11.12.09.01
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:01 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 16/40] arm64: mm: Pin down ASIDs for sharing mm with devices
Date: Fri, 11 May 2018 20:06:17 +0100
Message-Id: <20180511190641.23008-17-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, catalin.marinas@arm.com

To enable address space sharing with the IOMMU, introduce mm_context_get()
and mm_context_put(), that pin down a context and ensure that it will keep
its ASID after a rollover.

Pinning is necessary because a device constantly needs a valid ASID,
unlike tasks that only require one when running. Without pinning, we would
need to notify the IOMMU when we're about to use a new ASID for a task,
and it would get complicated when a new task is assigned a shared ASID.
Consider the following scenario with no ASID pinned:

1. Task t1 is running on CPUx with shared ASID (gen=1, asid=1)
2. Task t2 is scheduled on CPUx, gets ASID (1, 2)
3. Task tn is scheduled on CPUy, a rollover occurs, tn gets ASID (2, 1)
   We would now have to immediately generate a new ASID for t1, notify
   the IOMMU, and finally enable task tn. We are holding the lock during
   all that time, since we can't afford having another CPU trigger a
   rollover. The IOMMU issues invalidation commands that can take tens of
   milliseconds.

It gets needlessly complicated. All we wanted to do was schedule task tn,
that has no business with the IOMMU. By letting the IOMMU pin tasks when
needed, we avoid stalling the slow path, and let the pinning fail when
we're out of shareable ASIDs.

After a rollover, the allocator expects at least one ASID to be available
in addition to the reserved ones (one per CPU). So (NR_ASIDS - NR_CPUS -
1) is the maximum number of ASIDs that can be shared with the IOMMU.

Cc: catalin.marinas@arm.com
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: TLC found a bug in my code :) It was a bit silly.

When updating an mm's context after a rollover, we check if the ASID is
pinned. If it is, then we can reuse it. But even then we do need to update
the generation in the reserved_asid map. V1 didn't do that, so what
happened was:

1. A task t1 is running with ASID (gen=1, asid=1) on CPU1 all along.
2. CPU2 triggers a rollover, but since t1 is running it keeps its ASID.
3. ASID 1 is pinned. t1 is scheduled on CPU2. The ASID allocator sees the
   ASID pinned, and skips the update of reserved_asids. t1 now has ASID
   (2, 1)
4. ASID 1 is unpinned. Another rollover. t1 is scheduled on CPU2. Since it
   is still running on CPU1, the allocator should keep reuse its ASID, but
   as it looks for ASID (2, 1) in reserved_asid, it finds (1, 1), and
   concludes that the task needs a new ASID. Woops.

The fix is simple: check and update reserved_asids *before* checking for
pinned ASIDs. The bug was found this afternoon (after a 4h run), and there
probably will be more. I restarted the validation but it might take a
while or never finish -- I had to stop the penultimate run after 2 weeks,
the parameters were too large. The last successful run was with only two
generations and took 4:30 hours (on 4 Xeon E5-2660v4). This bug was found
with 3 generations and a single pinned task.

You can find the asidalloc changes for kernel-tla here, temporarily:
http://jpbrucker.net/git/kernel-tla/commit/?id=b70361
http://jpbrucker.net/git/kernel-tla/commit/?id=f5413d
---
 arch/arm64/include/asm/mmu.h         |  1 +
 arch/arm64/include/asm/mmu_context.h | 11 +++-
 arch/arm64/mm/context.c              | 92 ++++++++++++++++++++++++++--
 3 files changed, 99 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index dd320df0d026..dcf30e43af5e 100644
--- a/arch/arm64/include/asm/mmu.h
+++ b/arch/arm64/include/asm/mmu.h
@@ -27,6 +27,7 @@
 
 typedef struct {
 	atomic64_t	id;
+	unsigned long	pinned;
 	void		*vdso;
 	unsigned long	flags;
 } mm_context_t;
diff --git a/arch/arm64/include/asm/mmu_context.h b/arch/arm64/include/asm/mmu_context.h
index 39ec0b8a689e..0eb3f8cc3c9b 100644
--- a/arch/arm64/include/asm/mmu_context.h
+++ b/arch/arm64/include/asm/mmu_context.h
@@ -168,7 +168,13 @@ static inline void cpu_replace_ttbr1(pgd_t *pgdp)
 #define destroy_context(mm)		do { } while(0)
 void check_and_switch_context(struct mm_struct *mm, unsigned int cpu);
 
-#define init_new_context(tsk,mm)	({ atomic64_set(&(mm)->context.id, 0); 0; })
+static inline int
+init_new_context(struct task_struct *tsk, struct mm_struct *mm)
+{
+	atomic64_set(&mm->context.id, 0);
+	mm->context.pinned = 0;
+	return 0;
+}
 
 #ifdef CONFIG_ARM64_SW_TTBR0_PAN
 static inline void update_saved_ttbr0(struct task_struct *tsk,
@@ -241,6 +247,9 @@ switch_mm(struct mm_struct *prev, struct mm_struct *next,
 void verify_cpu_asid_bits(void);
 void post_ttbr_update_workaround(void);
 
+unsigned long mm_context_get(struct mm_struct *mm);
+void mm_context_put(struct mm_struct *mm);
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* !__ASM_MMU_CONTEXT_H */
diff --git a/arch/arm64/mm/context.c b/arch/arm64/mm/context.c
index 301417ae2ba8..e605adbad92c 100644
--- a/arch/arm64/mm/context.c
+++ b/arch/arm64/mm/context.c
@@ -37,6 +37,10 @@ static DEFINE_PER_CPU(atomic64_t, active_asids);
 static DEFINE_PER_CPU(u64, reserved_asids);
 static cpumask_t tlb_flush_pending;
 
+static unsigned long max_pinned_asids;
+static unsigned long nr_pinned_asids;
+static unsigned long *pinned_asid_map;
+
 #define ASID_MASK		(~GENMASK(asid_bits - 1, 0))
 #define ASID_FIRST_VERSION	(1UL << asid_bits)
 
@@ -88,13 +92,16 @@ void verify_cpu_asid_bits(void)
 	}
 }
 
+#define asid_gen_match(asid) \
+	(!(((asid) ^ atomic64_read(&asid_generation)) >> asid_bits))
+
 static void flush_context(unsigned int cpu)
 {
 	int i;
 	u64 asid;
 
 	/* Update the list of reserved ASIDs and the ASID bitmap. */
-	bitmap_clear(asid_map, 0, NUM_USER_ASIDS);
+	bitmap_copy(asid_map, pinned_asid_map, NUM_USER_ASIDS);
 
 	for_each_possible_cpu(i) {
 		asid = atomic64_xchg_relaxed(&per_cpu(active_asids, i), 0);
@@ -158,6 +165,14 @@ static u64 new_context(struct mm_struct *mm, unsigned int cpu)
 		if (check_update_reserved_asid(asid, newasid))
 			return newasid;
 
+		/*
+		 * If it is pinned, we can keep using it. Note that reserved
+		 * takes priority, because even if it is also pinned, we need to
+		 * update the generation into the reserved_asids.
+		 */
+		if (mm->context.pinned)
+			return newasid;
+
 		/*
 		 * We had a valid ASID in a previous life, so try to re-use
 		 * it if possible.
@@ -213,8 +228,7 @@ void check_and_switch_context(struct mm_struct *mm, unsigned int cpu)
 	 *   because atomic RmWs are totally ordered for a given location.
 	 */
 	old_active_asid = atomic64_read(&per_cpu(active_asids, cpu));
-	if (old_active_asid &&
-	    !((asid ^ atomic64_read(&asid_generation)) >> asid_bits) &&
+	if (old_active_asid && asid_gen_match(asid) &&
 	    atomic64_cmpxchg_relaxed(&per_cpu(active_asids, cpu),
 				     old_active_asid, asid))
 		goto switch_mm_fastpath;
@@ -222,7 +236,7 @@ void check_and_switch_context(struct mm_struct *mm, unsigned int cpu)
 	raw_spin_lock_irqsave(&cpu_asid_lock, flags);
 	/* Check that our ASID belongs to the current generation. */
 	asid = atomic64_read(&mm->context.id);
-	if ((asid ^ atomic64_read(&asid_generation)) >> asid_bits) {
+	if (!asid_gen_match(asid)) {
 		asid = new_context(mm, cpu);
 		atomic64_set(&mm->context.id, asid);
 	}
@@ -245,6 +259,63 @@ void check_and_switch_context(struct mm_struct *mm, unsigned int cpu)
 		cpu_switch_mm(mm->pgd, mm);
 }
 
+unsigned long mm_context_get(struct mm_struct *mm)
+{
+	unsigned long flags;
+	u64 asid;
+
+	raw_spin_lock_irqsave(&cpu_asid_lock, flags);
+
+	asid = atomic64_read(&mm->context.id);
+
+	if (mm->context.pinned) {
+		mm->context.pinned++;
+		asid &= ~ASID_MASK;
+		goto out_unlock;
+	}
+
+	if (nr_pinned_asids >= max_pinned_asids) {
+		asid = 0;
+		goto out_unlock;
+	}
+
+	if (!asid_gen_match(asid)) {
+		/*
+		 * We went through one or more rollover since that ASID was
+		 * used. Ensure that it is still valid, or generate a new one.
+		 * The cpu argument isn't used by new_context.
+		 */
+		asid = new_context(mm, 0);
+		atomic64_set(&mm->context.id, asid);
+	}
+
+	asid &= ~ASID_MASK;
+
+	nr_pinned_asids++;
+	__set_bit(asid2idx(asid), pinned_asid_map);
+	mm->context.pinned++;
+
+out_unlock:
+	raw_spin_unlock_irqrestore(&cpu_asid_lock, flags);
+
+	return asid;
+}
+
+void mm_context_put(struct mm_struct *mm)
+{
+	unsigned long flags;
+	u64 asid = atomic64_read(&mm->context.id) & ~ASID_MASK;
+
+	raw_spin_lock_irqsave(&cpu_asid_lock, flags);
+
+	if (--mm->context.pinned == 0) {
+		__clear_bit(asid2idx(asid), pinned_asid_map);
+		nr_pinned_asids--;
+	}
+
+	raw_spin_unlock_irqrestore(&cpu_asid_lock, flags);
+}
+
 /* Errata workaround post TTBRx_EL1 update. */
 asmlinkage void post_ttbr_update_workaround(void)
 {
@@ -269,6 +340,19 @@ static int asids_init(void)
 		panic("Failed to allocate bitmap for %lu ASIDs\n",
 		      NUM_USER_ASIDS);
 
+	pinned_asid_map = kzalloc(BITS_TO_LONGS(NUM_USER_ASIDS)
+				  * sizeof(*pinned_asid_map), GFP_KERNEL);
+	if (!pinned_asid_map)
+		panic("Failed to allocate pinned bitmap\n");
+
+	/*
+	 * We assume that an ASID is always available after a rollover. This
+	 * means that even if all CPUs have a reserved ASID, there still is at
+	 * least one slot available in the asid map.
+	 */
+	max_pinned_asids = NUM_USER_ASIDS - num_possible_cpus() - 2;
+	nr_pinned_asids = 0;
+
 	pr_info("ASID allocator initialised with %lu entries\n", NUM_USER_ASIDS);
 	return 0;
 }
-- 
2.17.0
