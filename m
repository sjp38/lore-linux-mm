Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C53E66B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 02:44:24 -0400 (EDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 04/10] percpu: cleanup percpu array definitions
Date: Wed, 24 Jun 2009 15:45:18 +0900
Message-Id: <1245825924-30412-5-git-send-email-tj@kernel.org>
In-Reply-To: <1245825924-30412-1-git-send-email-tj@kernel.org>
References: <1245825924-30412-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@elte.hu, kyle@mcmartin.ca, cl@linux-foundation.org, Jesper.Nilsson@axis.com, benh@kernel.crashing.org, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org
Cc: Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Currently, the following three different ways to define percpu arrays
are in use.

1. DEFINE_PER_CPU(elem_type[array_len], array_name);
2. DEFINE_PER_CPU(elem_type, array_name[array_len]);
3. DEFINE_PER_CPU(elem_type, array_name)[array_len];

Unify to #1 which correctly separates the roles of the two parameters
and thus allows more flexibility in the way percpu variables are
defined.

[ Impact: cleanup ]

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: David S. Miller <davem@davemloft.net>
---
 arch/ia64/kernel/smp.c               |    2 +-
 arch/ia64/sn/kernel/setup.c          |    2 +-
 arch/powerpc/mm/stab.c               |    2 +-
 arch/powerpc/platforms/ps3/smp.c     |    2 +-
 arch/x86/kernel/cpu/cpu_debug.c      |    4 ++--
 arch/x86/kernel/cpu/mcheck/mce_amd.c |    2 +-
 arch/x86/kernel/cpu/perf_counter.c   |    2 +-
 drivers/xen/events.c                 |    4 ++--
 mm/quicklist.c                       |    2 +-
 mm/slub.c                            |    4 ++--
 net/ipv4/syncookies.c                |    2 +-
 net/ipv6/syncookies.c                |    2 +-
 12 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index f0c521b..94cf78b 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -58,7 +58,7 @@ static struct local_tlb_flush_counts {
 	unsigned int count;
 } __attribute__((__aligned__(32))) local_tlb_flush_counts[NR_CPUS];
 
-static DEFINE_PER_CPU(unsigned short, shadow_flush_counts[NR_CPUS]) ____cacheline_aligned;
+static DEFINE_PER_CPU(unsigned short [NR_CPUS], shadow_flush_counts) ____cacheline_aligned;
 
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index e456f06..ece1bf9 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -71,7 +71,7 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 
-DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
+DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeid_to_nasid);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
diff --git a/arch/powerpc/mm/stab.c b/arch/powerpc/mm/stab.c
index 98cd1dc..6e9b69c 100644
--- a/arch/powerpc/mm/stab.c
+++ b/arch/powerpc/mm/stab.c
@@ -31,7 +31,7 @@ struct stab_entry {
 
 #define NR_STAB_CACHE_ENTRIES 8
 static DEFINE_PER_CPU(long, stab_cache_ptr);
-static DEFINE_PER_CPU(long, stab_cache[NR_STAB_CACHE_ENTRIES]);
+static DEFINE_PER_CPU(long [NR_STAB_CACHE_ENTRIES], stab_cache);
 
 /*
  * Create a segment table entry for the given esid/vsid pair.
diff --git a/arch/powerpc/platforms/ps3/smp.c b/arch/powerpc/platforms/ps3/smp.c
index f6e04bc..51ffde4 100644
--- a/arch/powerpc/platforms/ps3/smp.c
+++ b/arch/powerpc/platforms/ps3/smp.c
@@ -37,7 +37,7 @@
   */
 
 #define MSG_COUNT 4
-static DEFINE_PER_CPU(unsigned int, ps3_ipi_virqs[MSG_COUNT]);
+static DEFINE_PER_CPU(unsigned int [MSG_COUNT], ps3_ipi_virqs);
 
 static void do_message_pass(int target, int msg)
 {
diff --git a/arch/x86/kernel/cpu/cpu_debug.c b/arch/x86/kernel/cpu/cpu_debug.c
index 6b2a52d..dca325c 100644
--- a/arch/x86/kernel/cpu/cpu_debug.c
+++ b/arch/x86/kernel/cpu/cpu_debug.c
@@ -30,8 +30,8 @@
 #include <asm/apic.h>
 #include <asm/desc.h>
 
-static DEFINE_PER_CPU(struct cpu_cpuX_base, cpu_arr[CPU_REG_ALL_BIT]);
-static DEFINE_PER_CPU(struct cpu_private *, priv_arr[MAX_CPU_FILES]);
+static DEFINE_PER_CPU(struct cpu_cpuX_base [CPU_REG_ALL_BIT], cpu_arr);
+static DEFINE_PER_CPU(struct cpu_private * [MAX_CPU_FILES], priv_arr);
 static DEFINE_PER_CPU(int, cpu_priv_count);
 
 static DEFINE_MUTEX(cpu_debug_lock);
diff --git a/arch/x86/kernel/cpu/mcheck/mce_amd.c b/arch/x86/kernel/cpu/mcheck/mce_amd.c
index ddae216..bd2a2fa 100644
--- a/arch/x86/kernel/cpu/mcheck/mce_amd.c
+++ b/arch/x86/kernel/cpu/mcheck/mce_amd.c
@@ -69,7 +69,7 @@ struct threshold_bank {
 	struct threshold_block	*blocks;
 	cpumask_var_t		cpus;
 };
-static DEFINE_PER_CPU(struct threshold_bank *, threshold_banks[NR_BANKS]);
+static DEFINE_PER_CPU(struct threshold_bank * [NR_BANKS], threshold_banks);
 
 #ifdef CONFIG_SMP
 static unsigned char shared_bank[NR_BANKS] = {
diff --git a/arch/x86/kernel/cpu/perf_counter.c b/arch/x86/kernel/cpu/perf_counter.c
index 76dfef2..4946288 100644
--- a/arch/x86/kernel/cpu/perf_counter.c
+++ b/arch/x86/kernel/cpu/perf_counter.c
@@ -862,7 +862,7 @@ amd_pmu_disable_counter(struct hw_perf_counter *hwc, int idx)
 	x86_pmu_disable_counter(hwc, idx);
 }
 
-static DEFINE_PER_CPU(u64, prev_left[X86_PMC_IDX_MAX]);
+static DEFINE_PER_CPU(u64 [X86_PMC_IDX_MAX], prev_left);
 
 /*
  * Set the next IRQ period, based on the hwc->period_left value.
diff --git a/drivers/xen/events.c b/drivers/xen/events.c
index 891d2e9..ab581fa 100644
--- a/drivers/xen/events.c
+++ b/drivers/xen/events.c
@@ -47,10 +47,10 @@
 static DEFINE_SPINLOCK(irq_mapping_update_lock);
 
 /* IRQ <-> VIRQ mapping. */
-static DEFINE_PER_CPU(int, virq_to_irq[NR_VIRQS]) = {[0 ... NR_VIRQS-1] = -1};
+static DEFINE_PER_CPU(int [NR_VIRQS], virq_to_irq) = {[0 ... NR_VIRQS-1] = -1};
 
 /* IRQ <-> IPI mapping */
-static DEFINE_PER_CPU(int, ipi_to_irq[XEN_NR_IPIS]) = {[0 ... XEN_NR_IPIS-1] = -1};
+static DEFINE_PER_CPU(int [XEN_NR_IPIS], ipi_to_irq) = {[0 ... XEN_NR_IPIS-1] = -1};
 
 /* Interrupt types. */
 enum xen_irq_type {
diff --git a/mm/quicklist.c b/mm/quicklist.c
index e66d07d..6eedf7e 100644
--- a/mm/quicklist.c
+++ b/mm/quicklist.c
@@ -19,7 +19,7 @@
 #include <linux/module.h>
 #include <linux/quicklist.h>
 
-DEFINE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
+DEFINE_PER_CPU(struct quicklist [CONFIG_NR_QUICK], quicklist);
 
 #define FRACTION_OF_NODE_MEM	16
 
diff --git a/mm/slub.c b/mm/slub.c
index ce62b77..23bb79a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2086,8 +2086,8 @@ init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
  */
 #define NR_KMEM_CACHE_CPU 100
 
-static DEFINE_PER_CPU(struct kmem_cache_cpu,
-				kmem_cache_cpu)[NR_KMEM_CACHE_CPU];
+static DEFINE_PER_CPU(struct kmem_cache_cpu [NR_KMEM_CACHE_CPU],
+		      kmem_cache_cpu);
 
 static DEFINE_PER_CPU(struct kmem_cache_cpu *, kmem_cache_cpu_free);
 static DECLARE_BITMAP(kmem_cach_cpu_free_init_once, CONFIG_NR_CPUS);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index cd2b97f..84d90f2 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -37,7 +37,7 @@ __initcall(init_syncookies);
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-static DEFINE_PER_CPU(__u32, cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], cookie_scratch);
 
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8c25139..23d0d6d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -74,7 +74,7 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	return child;
 }
 
-static DEFINE_PER_CPU(__u32, cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], cookie_scratch);
 
 static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
