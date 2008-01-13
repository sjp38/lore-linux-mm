Message-Id: <20080113183454.680306000@sgi.com>
References: <20080113183453.973425000@sgi.com>
Date: Sun, 13 Jan 2008 10:34:58 -0800
From: travis@sgi.com
Subject: [PATCH 05/10] x86: Change NR_CPUS arrays in smpboot_64
Content-Disposition: inline; filename=NR_CPUS-arrays-in-smpboot_64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	task_struct *idle_thread_array[NR_CPUS];

This is only done if CONFIG_HOTPLUG_CPU is defined
as otherwise, the array is removed after initialization
anyways.

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/kernel/smpboot_64.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -111,10 +111,20 @@ DEFINE_PER_CPU(int, cpu_state) = { 0 };
  * a new thread. Also avoids complicated thread destroy functionality
  * for idle threads.
  */
+#ifdef CONFIG_HOTPLUG_CPU
+/*
+ * Needed only for CONFIG_HOTPLUG_CPU because __cpuinitdata is
+ * removed after init for !CONFIG_HOTPLUG_CPU.
+ */
+static DEFINE_PER_CPU(struct task_struct *, idle_thread_array);
+#define get_idle_for_cpu(x)     (per_cpu(idle_thread_array, x))
+#define set_idle_for_cpu(x,p)   (per_cpu(idle_thread_array, x) = (p))
+#else
 struct task_struct *idle_thread_array[NR_CPUS] __cpuinitdata ;
-
 #define get_idle_for_cpu(x)     (idle_thread_array[(x)])
 #define set_idle_for_cpu(x,p)   (idle_thread_array[(x)] = (p))
+#endif
+
 
 /*
  * Currently trivial. Write the real->protected mode

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
