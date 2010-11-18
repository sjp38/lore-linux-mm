Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B15AE6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 00:35:38 -0500 (EST)
Date: Thu, 18 Nov 2010 12:14:07 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
Message-ID: <20101118041407.GA2408@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.568681101@intel.com>
 <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
 <20101117075128.GA30254@shaohui>
 <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 01:10:50PM -0800, David Rientjes wrote:
> On Wed, 17 Nov 2010, Shaohui Zheng wrote:
> 
> > > Hmm, why can't you use numa=hide to hide a specified quantity of memory 
> > > from the kernel and then use the add_memory() interface to hot-add the 
> > > offlined memory in the desired quantity?  In other words, why do you need 
> > > to track the offlined nodes with a state?
> > > 
> > > The userspace interface would take a desired size of hidden memory to 
> > > hot-add and the node id would be the first_unset_node(node_online_map).
> > Yes, it is a good idea, your solution is what we indeed do in our first 2
> > versions.  We use mem=memsize to hide memory, and we call add_memory interface
> > to hot-add offlined memory with desired quantity, and we can also add to
> > desired nodes(even through the nodes does not exists). it is very flexible
> > solution.
> > 
> > However, this solution was denied since we notice NUMA emulation, we should
> > reuse it.
> > 
> 
> I don't understand why that's a requirement, NUMA emulation is a seperate 
> feature.  Although both are primarily used to test and instrument other VM 
> and kernel code, NUMA emulation is restricted to only being used at boot 
> to fake nodes on smaller machines and can be used to test things like the 
> slab allocator.  The NUMA hotplug emulator that you're developing here is 
> primarily used to test the hotplug callbacks; for that use-case, it seems 
> particularly helpful if nodes can be hotplugged of various sizes and node 
> ids rather than having static characteristics that cannot be changed with 
> a reboot.
> 
I agree with you. the early emulator do the same thing as you said, but there 
is already NUMA emulation to create fake node, our emulator also creates 
fake nodes. We worried about that we will suffer the critiques from the community,
so we drop the original degsin.

I did not know whether other engineers have the same attitude with you. I think 
that I can publish both codes, and let the community to decide which one is prefered.

In my personal opinion, both methods are acceptable for me.

> > Currently, our solution creates static nodes when OS boots, only the node with 
> > state N_HIDDEN can be hot-added with node/probe interface, and we can query 
> > 
> 
> The idea that I've proposed (and you've apparently thought about and even 
> implemented at one point) is much more powerful than that.  We need not 
> query the state of hidden nodes that we've setup at boot but can rather 
> use the amount of hidden memory to setup the nodes in any way that we want 
> at runtime (various sizes, interleaved node ids, etc).

yes, if we select your proposal. we just mark all the nodes as POSSIBLE node.
there is no hidden nodes any more. the node will be created after add memory
to the node first time. 

This is the early patch( Not very formal, it is just an interanl version):

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 454997c..9dc6a02 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -73,6 +73,7 @@
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
+ * node_set_possible(node)		set bit 'node' in node_possible_map
  *
  * for_each_node(node)			for-loop node over node_possible_map
  * for_each_online_node(node)		for-loop node over node_online_map
@@ -432,6 +433,11 @@ static inline void node_set_offline(int nid)
 	node_clear_state(nid, N_ONLINE);
 	nr_online_nodes = num_node_state(N_ONLINE);
 }
+
+static inline void node_set_possible(int nid)
+{
+	node_set_state(nid, N_POSSIBLE);
+}
 #else
 
 static inline int node_state(int node, enum node_states state)
@@ -462,6 +468,7 @@ static inline int num_node_state(enum node_states state)
 
 #define node_set_online(node)	   node_set_state((node), N_ONLINE)
 #define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
+#define node_set_possible(node)	   node_set_state((node), N_POSSIBLE)
 #endif
 
 #define node_online_map 	node_states[N_ONLINE]

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index eb40925..059ebf0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1602,6 +1602,9 @@ config HOTPLUG_CPU
 	  ( Note: power management support will enable this option
 	    automatically on SMP systems. )
 	  Say N if you want to disable CPU hotplug.
+config ARCH_CPU_PROBE_RELEASE
+	def_bool y
+	depends on HOTPLUG_CPU
 
 config COMPAT_VDSO
 	def_bool y
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 550df48..52094bc 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -26,12 +26,11 @@ void __init setup_node_to_cpumask_map(void)
 {
 	unsigned int node, num = 0;
 
-	/* setup nr_node_ids if not done yet */
-	if (nr_node_ids == MAX_NUMNODES) {
-		for_each_node_mask(node, node_possible_map)
-			num = node;
-		nr_node_ids = num + 1;
-	}
+	/* re-setup nr_node_ids, when CONFIG_ARCH_MEMORY_PROBE enabled and mem=XXX
+	specified, nr_node_ids will be set as the maximum value  */
+	for_each_node_mask(node, node_possible_map)
+		num = node;
+	nr_node_ids = num + 1;
 
 	/* allocate the map */
 	for (node = 0; node < nr_node_ids; node++)
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index bd02505..3d0e37c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -327,6 +327,8 @@ static int block_size_init(void)
  * will not need to do it from userspace.  The fake hot-add code
  * as well as ppc64 will do all of their discovery in userspace
  * and will require this interface.
+ *
+ * Parameter format: start_addr, nid
  */
 #ifdef CONFIG_ARCH_MEMORY_PROBE
 static ssize_t
@@ -336,10 +338,26 @@ memory_probe_store(struct class *class, const char *buf, size_t count)
 	int nid;
 	int ret;
 
-	phys_addr = simple_strtoull(buf, NULL, 0);
+	char *p = strchr(buf, ',');
+
+	if (p != NULL && strlen(p+1) > 0) {
+		/* nid specified */
+		*p++ = '\0';
+		nid = simple_strtoul(p, NULL, 0);
+		phys_addr = simple_strtoull(buf, NULL, 0);
+	} else {
+		phys_addr = simple_strtoull(buf, NULL, 0);
+		nid = memory_add_physaddr_to_nid(phys_addr);
+	}
 
-	nid = memory_add_physaddr_to_nid(phys_addr);
-	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid node id %d(0<=nid<%d).\n", nid, nr_node_ids);
+	} else {
+		printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
+		ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+		if (ret)
+			count = ret;
+	}
 
 	if (ret)
 		count = ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8deb9d0..0d7eeea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3946,9 +3946,19 @@ static void __init setup_nr_node_ids(void)
 	unsigned int node;
 	unsigned int highest = 0;
 
+	#ifdef CONFIG_ARCH_MEMORY_PROBE
+	/* grub parameter mem=XXX specified */
+	if (1){
+		int cnt;
+		for (cnt = 0; cnt < MAX_NUMNODES; cnt++)
+			node_set_possible(cnt);
+	}
+	#endif
+
 	for_each_node_mask(node, node_possible_map)
 		highest = node;
 	nr_node_ids = highest + 1;
+	printk(KERN_INFO "setup_nr_node_ids: nr_node_ids : %d.\n", nr_node_ids);
 }
 #else
 static inline void setup_nr_node_ids(void)
-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
