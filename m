Date: Wed, 18 Sep 2002 20:59:29 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Three little fixes for 2.5.36-mm1 (discontigmem)
Message-ID: <379836976.1032382769@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, colpatch@us.ibm.com
List-ID: <linux-mm.kvack.org>

Three little fixes for 2.5.36-mm1.

1. numa_node_id is defined in both asm/mmzone.h and linux/mmzone.h
	I remove the former, seems like the right thing to do now
	that we have a generic topology patch
2. The topo patch for i386 uses a (potentially) uninitialised
	variable that gcc whines about (correctly).
3. kswapd carefully typecasts it's argument to the correct pointer
	type ... then forgets to use it.

M.

diff -urN -X /home/mbligh/.diff.exclude virgin/include/asm-i386/mmzone.h numafixes/include/asm-i386/mmzone.h
--- virgin/include/asm-i386/mmzone.h	Wed Sep 18 20:41:12 2002
+++ numafixes/include/asm-i386/mmzone.h	Wed Sep 18 20:43:23 2002
@@ -19,10 +19,6 @@
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_X86_NUMAQ */
 
-#ifdef CONFIG_NUMA
-#define numa_node_id() _cpu_to_node(smp_processor_id())
-#endif /* CONFIG_NUMA */
-
 extern struct pglist_data *node_data[];
 
 /*
diff -urN -X /home/mbligh/.diff.exclude virgin/include/asm-i386/topology.h numafixes/include/asm-i386/topology.h
--- virgin/include/asm-i386/topology.h	Wed Sep 18 20:41:12 2002
+++ numafixes/include/asm-i386/topology.h	Wed Sep 18 20:50:40 2002
@@ -65,7 +65,7 @@
 static inline unsigned long
__node_to_cpu_mask(int node)
 {
 	int i, cpu, logical_apicid = node << 4;
-	unsigned long mask;
+	unsigned long mask = 0UL;
 
 	for(i = 1; i < 16; i <<= 1)
 		/* check to see if the cpu is in the system */
diff -urN -X /home/mbligh/.diff.exclude virgin/include/asm-ppc64/mmzone.h numafixes/include/asm-ppc64/mmzone.h
--- virgin/include/asm-ppc64/mmzone.h	Tue Sep 17 17:59:18 2002
+++ numafixes/include/asm-ppc64/mmzone.h	Wed Sep 18 20:43:47 2002
@@ -68,7 +68,6 @@
         return node;
 }
 
-#define numa_node_id()	__cpu_to_node(smp_processor_id())
 #endif /* CONFIG_NUMA */
 
 /*
diff -urN -X /home/mbligh/.diff.exclude virgin/mm/vmscan.c numafixes/mm/vmscan.c
--- virgin/mm/vmscan.c	Wed Sep 18 20:41:12 2002
+++ numafixes/mm/vmscan.c	Wed Sep 18 20:48:47
2002
@@ -749,7 +749,7 @@
 	DEFINE_WAIT(wait);
 
 	daemonize();
-	set_cpus_allowed(tsk, __node_to_cpu_mask(p->node_id));
+	set_cpus_allowed(tsk, __node_to_cpu_mask(pgdat->node_id));
 	sprintf(tsk->comm, "kswapd%d", pgdat->node_id);
 	sigfillset(&tsk->blocked);
 	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
