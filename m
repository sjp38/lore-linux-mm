Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id BE0B86B000E
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:59 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 10:52:58 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3207619D8045
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:55 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LHqqOL262946
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:54 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LHqpgE012014
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:52 -0700
Subject: [PATCH 5/5] fix kvm's use of __pa() on percpu areas
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 09:52:50 -0800
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
In-Reply-To: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
Message-Id: <20130121175250.1AAC7981@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


In short, it is illegal to call __pa() on an address holding
a percpu variable.  The times when this actually matters are
pretty obscure (certain 32-bit NUMA systems), but it _does_
happen.  It is important to keep KVM guests working on these
systems because the real hardware is getting harder and
harder to find.

This bug manifested first by me seeing a plain hang at boot
after this message:

	CPU 0 irqstacks, hard=f3018000 soft=f301a000

or, sometimes, it would actually make it out to the console:

[    0.000000] BUG: unable to handle kernel paging request at ffffffff

I eventually traced it down to the KVM async pagefault code.
This can be worked around by disabling that code either at
compile-time, or on the kernel command-line.

The kvm async pagefault code was injecting page faults in
to the guest which the guest misinterpreted because its
"reason" was not being properly sent from the host.

The guest passes a physical address of an per-cpu async page
fault structure via an MSR to the host.  Since __pa() is
broken on percpu data, the physical address it sent was
bascially bogus and the host went scribbling on random data.
The guest never saw the real reason for the page fault (it
was injected by the host), assumed that the kernel had taken
a _real_ page fault, and panic()'d.  The behavior varied,
though, depending on what got corrupted by the bad write.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

 linux-2.6.git-dave/arch/x86/kernel/kvm.c      |    9 +++++----
 linux-2.6.git-dave/arch/x86/kernel/kvmclock.c |    4 ++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff -puN arch/x86/kernel/kvm.c~fix-kvm-__pa-use-on-percpu-areas arch/x86/kernel/kvm.c
--- linux-2.6.git/arch/x86/kernel/kvm.c~fix-kvm-__pa-use-on-percpu-areas	2013-01-17 10:22:26.914436992 -0800
+++ linux-2.6.git-dave/arch/x86/kernel/kvm.c	2013-01-17 10:22:26.922437062 -0800
@@ -289,9 +289,9 @@ static void kvm_register_steal_time(void
 
 	memset(st, 0, sizeof(*st));
 
-	wrmsrl(MSR_KVM_STEAL_TIME, (__pa(st) | KVM_MSR_ENABLED));
+	wrmsrl(MSR_KVM_STEAL_TIME, (slow_virt_to_phys(st) | KVM_MSR_ENABLED));
 	printk(KERN_INFO "kvm-stealtime: cpu %d, msr %lx\n",
-		cpu, __pa(st));
+		cpu, slow_virt_to_phys(st));
 }
 
 static DEFINE_PER_CPU(unsigned long, kvm_apic_eoi) = KVM_PV_EOI_DISABLED;
@@ -316,7 +316,7 @@ void __cpuinit kvm_guest_cpu_init(void)
 		return;
 
 	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
-		u64 pa = __pa(&__get_cpu_var(apf_reason));
+		u64 pa = slow_virt_to_phys(&__get_cpu_var(apf_reason));
 
 #ifdef CONFIG_PREEMPT
 		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
@@ -332,7 +332,8 @@ void __cpuinit kvm_guest_cpu_init(void)
 		/* Size alignment is implied but just to make it explicit. */
 		BUILD_BUG_ON(__alignof__(kvm_apic_eoi) < 4);
 		__get_cpu_var(kvm_apic_eoi) = 0;
-		pa = __pa(&__get_cpu_var(kvm_apic_eoi)) | KVM_MSR_ENABLED;
+		pa = slow_virt_to_phys(&__get_cpu_var(kvm_apic_eoi))
+			| KVM_MSR_ENABLED;
 		wrmsrl(MSR_KVM_PV_EOI_EN, pa);
 	}
 
diff -puN arch/x86/kernel/kvmclock.c~fix-kvm-__pa-use-on-percpu-areas arch/x86/kernel/kvmclock.c
--- linux-2.6.git/arch/x86/kernel/kvmclock.c~fix-kvm-__pa-use-on-percpu-areas	2013-01-17 10:22:26.918437028 -0800
+++ linux-2.6.git-dave/arch/x86/kernel/kvmclock.c	2013-01-17 10:22:26.922437062 -0800
@@ -162,8 +162,8 @@ int kvm_register_clock(char *txt)
 	int low, high, ret;
 	struct pvclock_vcpu_time_info *src = &hv_clock[cpu].pvti;
 
-	low = (int)__pa(src) | 1;
-	high = ((u64)__pa(src) >> 32);
+	low = (int)slow_virt_to_phys(src) | 1;
+	high = ((u64)slow_virt_to_phys(src) >> 32);
 	ret = native_write_msr_safe(msr_kvm_system_time, low, high);
 	printk(KERN_INFO "kvm-clock: cpu %d, msr %x:%x, %s\n",
 	       cpu, high, low, txt);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
