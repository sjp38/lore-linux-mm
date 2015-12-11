Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7CF6B0254
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:30 -0500 (EST)
Received: by pfbg73 with SMTP id g73so59610736pfb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:30 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id w6si9021083pfi.235.2015.12.10.19.20.29
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:29 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 1/5] x86/kvm: On KVM re-enable (e.g. after suspend), update clocks
Date: Thu, 10 Dec 2015 19:20:18 -0800
Message-Id: <861716d768a1da6d1fd257b7972f8df13baf7f85.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

This gets rid of the "did TSC go backwards" logic and just updates
all clocks.  It should work better (no more disabling of fast
timing) and more reliably (all of the clocks are actually updated).

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/kvm/x86.c | 75 +++---------------------------------------------------
 1 file changed, 3 insertions(+), 72 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index eed32283d22c..c88f91f4b1a3 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -123,8 +123,6 @@ module_param(tsc_tolerance_ppm, uint, S_IRUGO | S_IWUSR);
 unsigned int __read_mostly lapic_timer_advance_ns = 0;
 module_param(lapic_timer_advance_ns, uint, S_IRUGO | S_IWUSR);
 
-static bool __read_mostly backwards_tsc_observed = false;
-
 #define KVM_NR_SHARED_MSRS 16
 
 struct kvm_shared_msrs_global {
@@ -1671,7 +1669,6 @@ static void pvclock_update_vm_gtod_copy(struct kvm *kvm)
 					&ka->master_cycle_now);
 
 	ka->use_master_clock = host_tsc_clocksource && vcpus_matched
-				&& !backwards_tsc_observed
 				&& !ka->boot_vcpu_runs_old_kvmclock;
 
 	if (ka->use_master_clock)
@@ -7369,88 +7366,22 @@ int kvm_arch_hardware_enable(void)
 	struct kvm_vcpu *vcpu;
 	int i;
 	int ret;
-	u64 local_tsc;
-	u64 max_tsc = 0;
-	bool stable, backwards_tsc = false;
 
 	kvm_shared_msr_cpu_online();
 	ret = kvm_x86_ops->hardware_enable();
 	if (ret != 0)
 		return ret;
 
-	local_tsc = rdtsc();
-	stable = !check_tsc_unstable();
 	list_for_each_entry(kvm, &vm_list, vm_list) {
 		kvm_for_each_vcpu(i, vcpu, kvm) {
-			if (!stable && vcpu->cpu == smp_processor_id())
+			if (vcpu->cpu == smp_processor_id()) {
 				kvm_make_request(KVM_REQ_CLOCK_UPDATE, vcpu);
-			if (stable && vcpu->arch.last_host_tsc > local_tsc) {
-				backwards_tsc = true;
-				if (vcpu->arch.last_host_tsc > max_tsc)
-					max_tsc = vcpu->arch.last_host_tsc;
+				kvm_make_request(KVM_REQ_MASTERCLOCK_UPDATE,
+						 vcpu);
 			}
 		}
 	}
 
-	/*
-	 * Sometimes, even reliable TSCs go backwards.  This happens on
-	 * platforms that reset TSC during suspend or hibernate actions, but
-	 * maintain synchronization.  We must compensate.  Fortunately, we can
-	 * detect that condition here, which happens early in CPU bringup,
-	 * before any KVM threads can be running.  Unfortunately, we can't
-	 * bring the TSCs fully up to date with real time, as we aren't yet far
-	 * enough into CPU bringup that we know how much real time has actually
-	 * elapsed; our helper function, get_kernel_ns() will be using boot
-	 * variables that haven't been updated yet.
-	 *
-	 * So we simply find the maximum observed TSC above, then record the
-	 * adjustment to TSC in each VCPU.  When the VCPU later gets loaded,
-	 * the adjustment will be applied.  Note that we accumulate
-	 * adjustments, in case multiple suspend cycles happen before some VCPU
-	 * gets a chance to run again.  In the event that no KVM threads get a
-	 * chance to run, we will miss the entire elapsed period, as we'll have
-	 * reset last_host_tsc, so VCPUs will not have the TSC adjusted and may
-	 * loose cycle time.  This isn't too big a deal, since the loss will be
-	 * uniform across all VCPUs (not to mention the scenario is extremely
-	 * unlikely). It is possible that a second hibernate recovery happens
-	 * much faster than a first, causing the observed TSC here to be
-	 * smaller; this would require additional padding adjustment, which is
-	 * why we set last_host_tsc to the local tsc observed here.
-	 *
-	 * N.B. - this code below runs only on platforms with reliable TSC,
-	 * as that is the only way backwards_tsc is set above.  Also note
-	 * that this runs for ALL vcpus, which is not a bug; all VCPUs should
-	 * have the same delta_cyc adjustment applied if backwards_tsc
-	 * is detected.  Note further, this adjustment is only done once,
-	 * as we reset last_host_tsc on all VCPUs to stop this from being
-	 * called multiple times (one for each physical CPU bringup).
-	 *
-	 * Platforms with unreliable TSCs don't have to deal with this, they
-	 * will be compensated by the logic in vcpu_load, which sets the TSC to
-	 * catchup mode.  This will catchup all VCPUs to real time, but cannot
-	 * guarantee that they stay in perfect synchronization.
-	 */
-	if (backwards_tsc) {
-		u64 delta_cyc = max_tsc - local_tsc;
-		backwards_tsc_observed = true;
-		list_for_each_entry(kvm, &vm_list, vm_list) {
-			kvm_for_each_vcpu(i, vcpu, kvm) {
-				vcpu->arch.tsc_offset_adjustment += delta_cyc;
-				vcpu->arch.last_host_tsc = local_tsc;
-				kvm_make_request(KVM_REQ_MASTERCLOCK_UPDATE, vcpu);
-			}
-
-			/*
-			 * We have to disable TSC offset matching.. if you were
-			 * booting a VM while issuing an S4 host suspend....
-			 * you may have some problem.  Solving this issue is
-			 * left as an exercise to the reader.
-			 */
-			kvm->arch.last_tsc_nsec = 0;
-			kvm->arch.last_tsc_write = 0;
-		}
-
-	}
 	return 0;
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
