From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Re: 2.5.74-mm3
Date: Wed, 9 Jul 2003 11:05:59 +0200
References: <20030708223548.791247f5.akpm@osdl.org>
In-Reply-To: <20030708223548.791247f5.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4r9C/SkEkjvjI2z"
Message-Id: <200307091106.00781.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_4r9C/SkEkjvjI2z
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> -cpumask_t-1.patch
> -gcc-bug-workaround.patch
> -sparse-apic-fix.patch
> -nuke-cpumask_arith.patch
> -p4-clockmod-cpumask-fix.patch
>
>  Folded into cpumask_t-1.patch

This gives following compile error when compiling the kernel with APM support 
for UP:

arch/i386/kernel/apm.c: In function `apm_bios_call':
arch/i386/kernel/apm.c:600: error: incompatible types in assignment
arch/i386/kernel/apm.c: In function `apm_bios_call_simple':
arch/i386/kernel/apm.c:643: error: incompatible types in assignment

The attached patch fixes this...

Best regards
  Thomas Schlichter

--Boundary-00=_4r9C/SkEkjvjI2z
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix_up_apm.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="fix_up_apm.diff"

--- linux-2.5.74-mm3/arch/i386/kernel/apm.c.orig	Wed Jul  9 10:25:46 2003
+++ linux-2.5.74-mm3/arch/i386/kernel/apm.c	Wed Jul  9 10:40:42 2003
@@ -508,13 +508,12 @@
  
 #ifdef CONFIG_SMP
 
-static cpumask_t apm_save_cpus(void)
+static inline void apm_save_cpus(cpumask_t *mask)
 {
-	cpumask_t x = current->cpus_allowed;
+	*mask = current->cpus_allowed;
 	/* Some bioses don't like being called from CPU != 0 */
 	set_cpus_allowed(current, cpumask_of_cpu(0));
 	BUG_ON(smp_processor_id() != 0);
-	return x;
 }
 
 static inline void apm_restore_cpus(cpumask_t mask)
@@ -528,7 +527,7 @@
  *	No CPU lockdown needed on a uniprocessor
  */
  
-#define apm_save_cpus()	0
+#define apm_save_cpus(x) 	(void)(x)
 #define apm_restore_cpus(x)	(void)(x)
 
 #endif
@@ -597,7 +596,7 @@
 	int			cpu;
 	struct desc_struct	save_desc_40;
 
-	cpus = apm_save_cpus();
+	apm_save_cpus(&cpus);
 	
 	cpu = get_cpu();
 	save_desc_40 = cpu_gdt_table[cpu][0x40 / 8];
@@ -640,7 +639,7 @@
 	struct desc_struct	save_desc_40;
 
 
-	cpus = apm_save_cpus();
+	apm_save_cpus(&cpus);
 	
 	cpu = get_cpu();
 	save_desc_40 = cpu_gdt_table[cpu][0x40 / 8];
@@ -918,7 +917,8 @@
 #endif
 	if (apm_info.realmode_power_off)
 	{
-		(void)apm_save_cpus();
+		cpumask_t dummy;
+		apm_save_cpus(&dummy);
 		machine_real_restart(po_bios_call, sizeof(po_bios_call));
 	}
 	else

--Boundary-00=_4r9C/SkEkjvjI2z--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
