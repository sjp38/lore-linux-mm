Date: Sat, 19 Jul 2003 21:40:11 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test1-mm2
Message-ID: <38790000.1058676010@[10.10.2.4]>
In-Reply-To: <20030719174350.7dd8ad59.akpm@osdl.org>
References: <20030719174350.7dd8ad59.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Whoever changed this:

-volatile u8 cpu_2_logical_apicid[NR_CPUS] = { [0 ... NR_CPUS-1] = BAD_APICID };
+u8 cpu_2_logical_apicid[NR_CPUS] = { [0 ... NR_CPUS-1] = BAD_APICID };

needs to grep for all occurences through subarch, etc. eg:

mach-bigsmp/mach_apic.h:extern volatile u8 cpu_2_logical_apicid[];
mach-es7000/mach_apic.h:extern volatile u8 cpu_2_logical_apicid[];
mach-numaq/mach_apic.h:extern volatile u8 cpu_2_logical_apicid[];
mach-summit/mach_apic.h:extern volatile u8 cpu_2_logical_apicid[];

There may be other similar problems, but this should fix up those at least.

diff -urN linux-2.6.0-test1-mm2/include/asm-i386/mach-bigsmp/mach_apic.h baddog/include/asm-i386/mach-bigsmp/mach_apic.h
--- linux-2.6.0-test1-mm2/include/asm-i386/mach-bigsmp/mach_apic.h	2003-07-19 20:49:36.000000000 -0700
+++ baddog/include/asm-i386/mach-bigsmp/mach_apic.h	2003-07-19 20:51:58.000000000 -0700
@@ -94,7 +94,7 @@
 	return physid_mask_of_physid(phys_apicid);
 }
 
-extern volatile u8 cpu_2_logical_apicid[];
+extern u8 cpu_2_logical_apicid[];
 /* Mapping from cpu number to logical apicid */
 static inline int cpu_to_logical_apicid(int cpu)
 {
diff -urN linux-2.6.0-test1-mm2/include/asm-i386/mach-es7000/mach_apic.h baddog/include/asm-i386/mach-es7000/mach_apic.h
--- linux-2.6.0-test1-mm2/include/asm-i386/mach-es7000/mach_apic.h	2003-07-19 20:49:36.000000000 -0700
+++ baddog/include/asm-i386/mach-es7000/mach_apic.h	2003-07-19 20:52:20.000000000 -0700
@@ -119,7 +119,7 @@
 	return mask;
 }
 
-extern volatile u8 cpu_2_logical_apicid[];
+extern u8 cpu_2_logical_apicid[];
 /* Mapping from cpu number to logical apicid */
 static inline int cpu_to_logical_apicid(int cpu)
 {
diff -urN linux-2.6.0-test1-mm2/include/asm-i386/mach-numaq/mach_apic.h baddog/include/asm-i386/mach-numaq/mach_apic.h
--- linux-2.6.0-test1-mm2/include/asm-i386/mach-numaq/mach_apic.h	2003-07-19 20:49:36.000000000 -0700
+++ baddog/include/asm-i386/mach-numaq/mach_apic.h	2003-07-19 20:52:43.000000000 -0700
@@ -57,7 +57,7 @@
 }
 
 /* Mapping from cpu number to logical apicid */
-extern volatile u8 cpu_2_logical_apicid[];
+extern u8 cpu_2_logical_apicid[];
 static inline int cpu_to_logical_apicid(int cpu)
 {
 	return (int)cpu_2_logical_apicid[cpu];
diff -urN linux-2.6.0-test1-mm2/include/asm-i386/mach-summit/mach_apic.h baddog/include/asm-i386/mach-summit/mach_apic.h
--- linux-2.6.0-test1-mm2/include/asm-i386/mach-summit/mach_apic.h	2003-07-19 20:49:36.000000000 -0700
+++ baddog/include/asm-i386/mach-summit/mach_apic.h	2003-07-19 20:53:06.000000000 -0700
@@ -77,7 +77,7 @@
 }
 
 /* Mapping from cpu number to logical apicid */
-extern volatile u8 cpu_2_logical_apicid[];
+extern u8 cpu_2_logical_apicid[];
 static inline int cpu_to_logical_apicid(int cpu)
 {
 	return (int)cpu_2_logical_apicid[cpu];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
