From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 1/4] Make the per cpu reserve configurable
Date: Mon, 29 Sep 2008 12:35:01 -0700
Message-ID: <20080929193515.737110249@quilx.com>
References: <20080929193500.470295078@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_configurable_percpu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

The per cpu reserve from which loadable modules allocate their percpu sections
is currently fixed at 8000 bytes.

Add a new kernel parameter

	percpu=<dynamically allocatable percpu bytes>

The per cpu reserve area will be used in following patches by the
per cpu allocator.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/ia64/include/asm/percpu.h |    1 +
 include/linux/percpu.h         |    7 ++++++-
 init/main.c                    |   13 +++++++++++++
 3 files changed, 20 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2008-09-25 08:39:19.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2008-09-29 13:08:25.000000000 -0500
@@ -34,6 +34,7 @@
 #define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
 #define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
 
+extern unsigned int percpu_reserve;
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
 #ifndef PERCPU_ENOUGH_ROOM
 #ifdef CONFIG_MODULES
@@ -43,7 +44,7 @@
 #endif
 
 #define PERCPU_ENOUGH_ROOM						\
-	(__per_cpu_end - __per_cpu_start + PERCPU_MODULE_RESERVE)
+	(__per_cpu_end - __per_cpu_start + percpu_reserve)
 #endif	/* PERCPU_ENOUGH_ROOM */
 
 /*
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c	2008-09-25 08:39:19.000000000 -0500
+++ linux-2.6/init/main.c	2008-09-29 13:09:13.000000000 -0500
@@ -253,6 +253,16 @@
 
 early_param("loglevel", loglevel);
 
+unsigned int percpu_reserve = PERCPU_MODULE_RESERVE;
+
+static int __init init_percpu_reserve(char *str)
+{
+	get_option(&str, &percpu_reserve);
+	return 0;
+}
+
+early_param("percpu", init_percpu_reserve);
+
 /*
  * Unknown boot options get handed to init, unless they look like
  * failed parameters
@@ -397,6 +407,9 @@
 
 	/* Copy section for each CPU (we discard the original) */
 	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
+	printk(KERN_INFO "percpu area: %d bytes total, %d available.\n",
+			size, size - (__per_cpu_end - __per_cpu_start));
+
 	ptr = alloc_bootmem_pages(size * nr_possible_cpus);
 
 	for_each_possible_cpu(i) {
Index: linux-2.6/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.orig/Documentation/kernel-parameters.txt	2008-09-25 08:39:19.000000000 -0500
+++ linux-2.6/Documentation/kernel-parameters.txt	2008-09-29 13:05:36.000000000 -0500
@@ -1643,6 +1643,13 @@
 			Format: { 0 | 1 }
 			See arch/parisc/kernel/pdc_chassis.c
 
+	percpu=		Configure the number of percpu bytes that can be
+			dynamically allocated. This is used for per cpu
+			variables of modules and other dynamic per cpu data
+			structures. Creation of per cpu structures after boot
+			may fail if this is set too low.
+			Default is 8000 bytes.
+
 	pf.		[PARIDE]
 			See Documentation/paride.txt.
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
