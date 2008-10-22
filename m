Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9M1hZ9D010452
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Oct 2008 10:43:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 959B12AC027
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:43:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DDA912C044
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:43:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52A301DB803B
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:43:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 040671DB803A
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:43:35 +0900 (JST)
Date: Wed, 22 Oct 2008 10:42:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX] memcg: fix page_cgroup allocation
Message-Id: <20081022104259.fb068b8b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021183738.d3c995b9.akpm@linux-foundation.org>
References: <20081022102404.e1f3565a.kamezawa.hiroyu@jp.fujitsu.com>
	<20081021183738.d3c995b9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 18:37:38 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Didn't the linux/cgroup.h -> linux/cgroup_subsys..h inclusion already
> declare this for us?
> 
you're right, I'm wrong. fixed one is here. (confirmed by make mm/page_cgroup.i)

Regards,
-Kame
==
page_cgroup_init() is called from mem_cgroup_init(). But at this
point, we cannot call alloc_bootmem().
(and this caused panic at boot.)

This patch moves page_cgroup_init() to init/main.c.

Time table is following:
==
  parse_args(). # we can trust mem_cgroup_subsys.disabled bit after this.
  ....
  cgroup_init_early()  # "early" init of cgroup.
  ....
  setup_arch()         # memmap is allocated.
  ...
  page_cgroup_init();
  mem_init();   # we cannot call alloc_bootmem after this.
  ....
  cgroup_init() # mem_cgroup is initialized.
==

Before page_cgroup_init(), mem_map must be initialized. So, 
I added page_cgroup_init() to init/main.c directly.

(*) maybe this is not very clean but cgroup_init_early() is too early
    and we have to use vmalloc instead of alloc_bootmem() in cgroup_init().
    usage of vmalloc area in x86-32 is important and we should avoid
    vmalloc() in x86-32. So, we want to use alloc_bootmem() from
    sutaible place.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 init/main.c      |    2 ++
 mm/memcontrol.c  |    1 -
 mm/page_cgroup.c |   33 ++++++++++++++++++++++++++-------
 3 files changed, 28 insertions(+), 8 deletions(-)

Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -62,6 +62,7 @@
 #include <linux/signal.h>
 #include <linux/idr.h>
 #include <linux/ftrace.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -647,6 +648,7 @@ asmlinkage void __init start_kernel(void
 	vmalloc_init();
 	vfs_caches_init_early();
 	cpuset_init_early();
+	page_cgroup_init();
 	mem_init();
 	enable_debug_pagealloc();
 	cpu_hotplug_init();
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c
+++ linux-2.6/mm/memcontrol.c
@@ -1088,7 +1088,6 @@ mem_cgroup_create(struct cgroup_subsys *
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
-		page_cgroup_init();
 		mem = &init_mem_cgroup;
 	} else {
 		mem = mem_cgroup_alloc();
Index: linux-2.6/mm/page_cgroup.c
===================================================================
--- linux-2.6.orig/mm/page_cgroup.c
+++ linux-2.6/mm/page_cgroup.c
@@ -4,7 +4,10 @@
 #include <linux/bit_spinlock.h>
 #include <linux/page_cgroup.h>
 #include <linux/hash.h>
+#include <linux/slab.h>
 #include <linux/memory.h>
+#include <linux/cgroup.h>
+
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
@@ -66,6 +69,9 @@ void __init page_cgroup_init(void)
 
 	int nid, fail;
 
+	if (mem_cgroup_subsys.disabled)
+		return;
+
 	for_each_online_node(nid)  {
 		fail = alloc_node_page_cgroup(nid);
 		if (fail)
@@ -106,9 +112,14 @@ int __meminit init_section_page_cgroup(u
 	nid = page_to_nid(pfn_to_page(pfn));
 
 	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-	base = kmalloc_node(table_size, GFP_KERNEL, nid);
-	if (!base)
-		base = vmalloc_node(table_size, nid);
+	if (slab_is_available()) {
+		base = kmalloc_node(table_size, GFP_KERNEL, nid);
+		if (!base)
+			base = vmalloc_node(table_size, nid);
+	} else {
+		base = __alloc_bootmem_node_nopanic(NODE_DATA(nid), table_size,
+				PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	}
 
 	if (!base) {
 		printk(KERN_ERR "page cgroup allocation failure\n");
@@ -135,11 +146,16 @@ void __free_page_cgroup(unsigned long pf
 	if (!ms || !ms->page_cgroup)
 		return;
 	base = ms->page_cgroup + pfn;
-	ms->page_cgroup = NULL;
-	if (is_vmalloc_addr(base))
+	if (is_vmalloc_addr(base)) {
 		vfree(base);
-	else
-		kfree(base);
+		ms->page_cgroup = NULL;
+	} else {
+		struct page *page = virt_to_page(base);
+		if (!PageReserved(page)) { /* Is bootmem ? */
+			kfree(base);
+			ms->page_cgroup = NULL;
+		}
+	}
 }
 
 int online_page_cgroup(unsigned long start_pfn,
@@ -213,6 +229,9 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
+	if (mem_cgroup_subsys.disabled)
+		return;
+
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
 		if (!pfn_present(pfn))
 			continue;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
