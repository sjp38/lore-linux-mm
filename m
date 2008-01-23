Message-Id: <20080123044925.061066000@sgi.com>
References: <20080123044924.508382000@sgi.com>
Date: Tue, 22 Jan 2008 20:49:27 -0800
From: travis@sgi.com
Subject: [PATCH 3/3] x86_64: Rebase per cpu variables to zero
Content-Disposition: inline; filename=x86_64_rebase_compat
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  * This also supports further integration of x86_32/64.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/Kconfig                 |    3 +++
 arch/x86/kernel/setup64.c        |    2 +-
 arch/x86/kernel/vmlinux_64.lds.S |    1 +
 kernel/module.c                  |    7 ++++---
 4 files changed, 9 insertions(+), 4 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -107,6 +107,9 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default X86_64
 
+config HAVE_ZERO_BASED_PER_CPU
+	def_bool X86_64
+
 config ARCH_SUPPORTS_OPROFILE
 	bool
 	default y
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -152,7 +152,7 @@ void __init setup_per_cpu_areas(void)
 		}
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
-		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+		memcpy(ptr, __per_cpu_load, __per_cpu_size);
 		/* Relocate the pda */
 		memcpy(ptr, cpu_pda(i), sizeof(struct x8664_pda));
 		cpu_pda(i) = (struct x8664_pda *)ptr;
--- a/arch/x86/kernel/vmlinux_64.lds.S
+++ b/arch/x86/kernel/vmlinux_64.lds.S
@@ -16,6 +16,7 @@ jiffies_64 = jiffies;
 _proxy_pda = 1;
 PHDRS {
 	text PT_LOAD FLAGS(5);	/* R_E */
+	percpu PT_LOAD FLAGS(4);	/* R__ */
 	data PT_LOAD FLAGS(7);	/* RWE */
 	user PT_LOAD FLAGS(7);	/* RWE */
 	data.init PT_LOAD FLAGS(7);	/* RWE */
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -45,6 +45,7 @@
 #include <asm/uaccess.h>
 #include <asm/semaphore.h>
 #include <asm/cacheflush.h>
+#include <asm/sections.h>
 #include <linux/license.h>
 #include <asm/sections.h>
 
@@ -351,7 +352,7 @@ static void *percpu_modalloc(unsigned lo
 		align = PAGE_SIZE;
 	}
 
-	ptr = __per_cpu_start;
+	ptr = __per_cpu_load;
 	for (i = 0; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
 		/* Extra for alignment requirement. */
 		extra = ALIGN((unsigned long)ptr, align) - (unsigned long)ptr;
@@ -386,7 +387,7 @@ static void *percpu_modalloc(unsigned lo
 static void percpu_modfree(void *freeme)
 {
 	unsigned int i;
-	void *ptr = __per_cpu_start + block_size(pcpu_size[0]);
+	void *ptr = __per_cpu_load + block_size(pcpu_size[0]);
 
 	/* First entry is core kernel percpu data. */
 	for (i = 1; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
@@ -437,7 +438,7 @@ static int percpu_modinit(void)
 	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
 			    GFP_KERNEL);
 	/* Static in-kernel percpu data (used). */
-	pcpu_size[0] = -(__per_cpu_end-__per_cpu_start);
+	pcpu_size[0] = -__per_cpu_size;
 	/* Free room. */
 	pcpu_size[1] = PERCPU_ENOUGH_ROOM + pcpu_size[0];
 	if (pcpu_size[1] < 0) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
