Message-Id: <20080117223546.853364000@sgi.com>
References: <20080117223546.419383000@sgi.com>
Date: Thu, 17 Jan 2008 14:35:49 -0800
From: travis@sgi.com
Subject: [PATCH 3/3] x86: Change bios_cpu_apicid to percpu data variable fixup
Content-Disposition: inline; filename=change-bios_cpu_apicid-to-percpu-fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change static bios_cpu_apicid array to a per_cpu data variable.
This includes using a static array used during initialization
similar to the way x86_cpu_to_apicid[] is handled.

There is one early use of bios_cpu_apicid in apic_is_clustered_box().
The other reference in cpu_present_to_apicid() is called after
smp_set_apicids() has setup the percpu version of bios_cpu_apicid.


Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - Removed extraneous casts
    - Add slight optimization to apic_is_clustered_box()
      [don't reference x86_bios_cpu_apicid_early_ptr each pass.]
---
 arch/x86/kernel/apic_64.c  |    6 +++---
 arch/x86/kernel/setup64.c  |    3 +++
 arch/x86/kernel/setup_64.c |    1 +
 3 files changed, 7 insertions(+), 3 deletions(-)

--- a/arch/x86/kernel/apic_64.c
+++ b/arch/x86/kernel/apic_64.c
@@ -1191,9 +1191,9 @@ __cpuinit int apic_is_clustered_box(void
 
 	/* Problem:  Partially populated chassis may not have CPUs in some of
 	 * the APIC clusters they have been allocated.  Only present CPUs have
-	 * x86_bios_cpu_apicid entries, thus causing zeroes in the bitmap.  Since
-	 * clusters are allocated sequentially, count zeros only if they are
-	 * bounded by ones.
+	 * x86_bios_cpu_apicid entries, thus causing zeroes in the bitmap.
+	 * Since clusters are allocated sequentially, count zeros only if
+	 * they are bounded by ones.
 	 */
 	clusters = 0;
 	zeros = 0;
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -96,6 +96,8 @@ void __init setup_percpu_maps(void)
 		if (per_cpu_offset(cpu)) {
 			per_cpu(x86_cpu_to_apicid, cpu) =
 						x86_cpu_to_apicid_init[cpu];
+			per_cpu(x86_bios_cpu_apicid, cpu) =
+						x86_bios_cpu_apicid_init[cpu];
 #ifdef CONFIG_NUMA
 			per_cpu(x86_cpu_to_node_map, cpu) =
 						x86_cpu_to_node_map_init[cpu];
@@ -108,6 +110,7 @@ void __init setup_percpu_maps(void)
 
 	/* indicate the early static arrays are gone */
 	x86_cpu_to_apicid_early_ptr = NULL;
+	x86_bios_cpu_apicid_early_ptr = NULL;
 #ifdef CONFIG_NUMA
 	x86_cpu_to_node_map_early_ptr = NULL;
 #endif
--- a/arch/x86/kernel/setup_64.c
+++ b/arch/x86/kernel/setup_64.c
@@ -390,6 +390,7 @@ void __init setup_arch(char **cmdline_p)
 #ifdef CONFIG_SMP
 	/* setup to use the early static init tables during kernel startup */
 	x86_cpu_to_apicid_early_ptr = (void *)&x86_cpu_to_apicid_init;
+	x86_bios_cpu_apicid_early_ptr = (void *)&x86_bios_cpu_apicid_init;
 #ifdef CONFIG_NUMA
 	x86_cpu_to_node_map_early_ptr = (void *)&x86_cpu_to_node_map_init;
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
