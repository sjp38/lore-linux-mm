Date: Thu, 10 May 2007 16:26:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Request-For-Test] [PATCH] change zonelist order v6 [3/3]
 documentaion
Message-Id: <20070510162649.6410c12f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070510161611.fe1a696b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070510161611.fe1a696b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, apw@shadowen.org, clameter@sgi.com, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

Documentation for numa_zonelist_order.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/kernel-parameters.txt |    5 +++
 Documentation/sysctl/vm.txt         |   46 ++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

Index: linux-2.6.21-mm2/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.21-mm2.orig/Documentation/sysctl/vm.txt
+++ linux-2.6.21-mm2/Documentation/sysctl/vm.txt
@@ -33,6 +33,7 @@ Currently, these files are in /proc/sys/
 - panic_on_oom
 - swap_prefetch
 - stat_interval
+- numa_zonelist_order
 
 ==============================================================
 
@@ -248,3 +249,48 @@ determines the frequency of these consol
 
 The default value is 1 second.
 
+==============================================================
+
+numa_zonelist_order
+
+This sysctl is only for NUMA.
+'where the memory is allocated from' is controlled by zonelists.
+(This documentation ignores ZONE_HIGHMEM/ZONE_DMA32 for simple explanation.
+ you may be able to read ZONE_DMA as ZONE_DMA32...)
+
+In non-NUMA case, a zonelist for GFP_KERNEL is ordered as following.
+ZONE_NORMAL -> ZONE_DMA
+This means that a memory allocation request for GFP_KERNEL will
+get memory from ZONE_DMA only when ZONE_NORMAL is not available.
+
+In NUMA case, you can think of following 2 types of order.
+Assume 2 node NUMA and below is zonelist of Node(0)'s GFP_KERNEL
+
+(A) Node(0) ZONE_NORMAL -> Node(0) ZONE_DMA -> Node(1) ZONE_NORMAL
+(B) Node(0) ZONE_NORMAL -> Node(1) ZONE_NORMAL -> Node(0) ZONE_DMA.
+
+Type(A) offers the best locality for processes on Node(0), but ZONE_DMA
+will be used before ZONE_NORMAL exhaustion. This increases possibility of
+out-of-memory(OOM) of ZONE_DMA because ZONE_DMA is tend to be small.
+
+Type(B) cannot offer the best locality but is more robust against OOM of
+the DMA zone.
+
+Type(A) is called as "Node" order. Type (B) is "Zone" order.
+
+"Node order" orders the zonelists by node, then by zone within each node.
+Specify "[Nn]ode" for zone order
+
+"Zone Order" orders the zonelists by zone type, then by node within each
+zone.  Specify "[Zz]one"for zode order.
+
+Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
+will select "node" order in following case.
+(1) if the DMA zone does not exist or
+(2) if the DMA zone comprises greater than 50% of the available memory or
+(3) if any node's DMA zone comprises greater than 60% of its local memory and
+    the amount of local memory is big enough.
+
+Otherwise, "zone" order will be selected. Default order is recommended unless
+this is causing problems for your system/application.
+
Index: linux-2.6.21-mm2/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.21-mm2.orig/Documentation/kernel-parameters.txt
+++ linux-2.6.21-mm2/Documentation/kernel-parameters.txt
@@ -1231,6 +1231,11 @@ and is between 256 and 4096 characters. 
 
 	nowb		[ARM]
 
+	numa_zonelist_order= [KNL, BOOT] Select zonelist order for NUMA.
+			one of ['zone', 'node', 'default'] can be specified
+			This can be set from sysctl after boot.
+			See Documentation/sysctl/vm.txt for details.
+
 	nr_uarts=	[SERIAL] maximum number of UARTs to be registered.
 
 	opl3=		[HW,OSS]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
