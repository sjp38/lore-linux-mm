Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0LMG4m4074524
	for <linux-mm@kvack.org>; Fri, 21 Jan 2005 17:16:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0LMG47I322152
	for <linux-mm@kvack.org>; Fri, 21 Jan 2005 15:16:04 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0LMG3dE032039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2005 15:16:03 -0700
Subject: [patch] [rfc] kill ugly get_memcfg_numa #define
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 21 Jan 2005 14:16:01 -0800
Message-Id: <E1Cs74T-0004YD-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mbligh@aracnet.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I've been confused by this:

      #define get_memcfg_numa get_memcfg_numa_flat

for the last time.  Later in the same file, there's this function:

	static inline void get_memcfg_numa(void)
	{
	#ifdef CONFIG_X86_NUMAQ
	        if (get_memcfg_numaq())
	                return;
	#elif CONFIG_ACPI_SRAT
	        if (get_memcfg_from_srat())
	                return;
	#endif

	        get_memcfg_numa_flat();
	}

Every time I look at it, my brain takes a few seconds to process
what is going on and figure out how it isn't a recursive definition.
That's added up to a large amount of time over the years.

So, make it safe to include asm/numaq.h and asm/srat.h from
anywhere, and give them null definitions for their get_memcfg_*()
functions when the config options are off.

This also gets rid of the multi-level #define that caused a little
stink on the mailing list recently.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/include/asm-i386/mmzone.h |   17 +++++------------
 memhotplug-dave/include/asm-i386/numaq.h  |    9 ++++++++-
 memhotplug-dave/include/asm-i386/srat.h   |   11 +++++++++--
 3 files changed, 22 insertions(+), 15 deletions(-)

diff -puN include/asm-i386/mmzone.h~A1-kill-get_memcfg_numa-define include/asm-i386/mmzone.h
--- memhotplug/include/asm-i386/mmzone.h~A1-kill-get_memcfg_numa-define	2005-01-21 11:01:29.000000000 -0800
+++ memhotplug-dave/include/asm-i386/mmzone.h	2005-01-21 11:01:29.000000000 -0800
@@ -3,30 +3,26 @@
  *
  */
 
 #ifndef _ASM_MMZONE_H_
 #define _ASM_MMZONE_H_
 
 #include <asm/smp.h>
 
 #ifdef CONFIG_DISCONTIGMEM
 
-#ifdef CONFIG_NUMA
-	#ifdef CONFIG_X86_NUMAQ
-		#include <asm/numaq.h>
-	#else	/* summit or generic arch */
-		#include <asm/srat.h>
-	#endif
-#else /* !CONFIG_NUMA */
-	#define get_memcfg_numa get_memcfg_numa_flat
+#include <asm/numaq.h> /* for get_memcfg_numaq() */
+#include <asm/srat.h>  /* for get_memcfg_from_srat() */
+
+#ifndef CONFIG_NUMA
 	#define get_zholes_size(n) (0)
-#endif /* CONFIG_NUMA */
+#endif /* !CONFIG_NUMA */
 
 extern struct pglist_data *node_data[];
 #define NODE_DATA(nid)		(node_data[nid])
 
 /*
  * generic node memory support, the following assumptions apply:
  *
  * 1) memory comes in 256Mb contigious chunks which are either present or not
  * 2) we will not have more than 64Gb in total
  *
@@ -125,23 +121,20 @@ static inline int pfn_valid(int pfn)
 #endif
 
 extern int get_memcfg_numa_flat(void );
 /*
  * This allows any one NUMA architecture to be compiled
  * for, and still fall back to the flat function if it
  * fails.
  */
 static inline void get_memcfg_numa(void)
 {
-#ifdef CONFIG_X86_NUMAQ
 	if (get_memcfg_numaq())
 		return;
-#elif CONFIG_ACPI_SRAT
 	if (get_memcfg_from_srat())
 		return;
-#endif
 
 	get_memcfg_numa_flat();
 }
 
 #endif /* CONFIG_DISCONTIGMEM */
 #endif /* _ASM_MMZONE_H_ */
diff -puN include/asm-i386/numaq.h~A1-kill-get_memcfg_numa-define include/asm-i386/numaq.h
--- memhotplug/include/asm-i386/numaq.h~A1-kill-get_memcfg_numa-define	2005-01-21 11:01:29.000000000 -0800
+++ memhotplug-dave/include/asm-i386/numaq.h	2005-01-21 11:01:29.000000000 -0800
@@ -19,21 +19,28 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
  * Send feedback to <gone@us.ibm.com>
  */
 
 #ifndef NUMAQ_H
 #define NUMAQ_H
 
-#ifdef CONFIG_X86_NUMAQ
+#ifndef CONFIG_X86_NUMAQ
+
+static inline int get_memcfg_numaq(void)
+{
+	return 0;
+}
+
+#else /* CONFIG_X86_NUMAQ */
 
 extern int get_memcfg_numaq(void);
 
 /*
  * SYS_CFG_DATA_PRIV_ADDR, struct eachquadmem, and struct sys_cfg_data are the
  */
 #define SYS_CFG_DATA_PRIV_ADDR		0x0009d000 /* place for scd in private quad space */
 
 /*
  * Communication area for each processor on lynxer-processor tests.
diff -puN include/asm-i386/srat.h~A1-kill-get_memcfg_numa-define include/asm-i386/srat.h
--- memhotplug/include/asm-i386/srat.h~A1-kill-get_memcfg_numa-define	2005-01-21 11:01:29.000000000 -0800
+++ memhotplug-dave/include/asm-i386/srat.h	2005-01-21 11:01:29.000000000 -0800
@@ -21,17 +21,24 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
  * Send feedback to Pat Gaughen <gone@us.ibm.com>
  */
 
 #ifndef _ASM_SRAT_H_
 #define _ASM_SRAT_H_
 
 #ifndef CONFIG_ACPI_SRAT
-#error CONFIG_ACPI_SRAT not defined, and srat.h header has been included
-#endif
+
+static inline int get_memcfg_from_srat(void)
+{
+	return 0;
+}
+
+#else /* CONFIG_ACPI_SRAT */
 
 extern int get_memcfg_from_srat(void);
 extern unsigned long *get_zholes_size(int);
 
+#endif /* CONFIG_ACPI_SRAT */
+
 #endif /* _ASM_SRAT_H_ */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
