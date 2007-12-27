Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id lBRFWePq003060
	for <linux-mm@kvack.org>; Thu, 27 Dec 2007 21:02:40 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBRFWePT794650
	for <linux-mm@kvack.org>; Thu, 27 Dec 2007 21:02:40 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id lBRFWfia010598
	for <linux-mm@kvack.org>; Thu, 27 Dec 2007 15:32:41 GMT
Date: Thu, 27 Dec 2007 21:02:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20071227153235.GA6443@skywalker>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071225140519.ef8457ff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 25, 2007 at 02:05:19PM -0800, Andrew Morton wrote:
> On Thu, 20 Dec 2007 15:35:41 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > ------------[ cut here ]------------
> > kernel BUG at mm/slab.c:3320!
> > invalid opcode: 0000 [#1] PREEMPT SMP
> > Modules linked in:
> > 
> > Pid: 0, comm: swapper Not tainted (2.6.24-rc5-autokern1 #1)
> > EIP: 0060:[<c0181707>] EFLAGS: 00010046 CPU: 0
> > EIP is at ____cache_alloc_node+0x1c/0x130
> > EAX: ee4005c0 EBX: 00000000 ECX: 00000001 EDX: 000000d0
> > ESI: 00000000 EDI: ee4005c0 EBP: c0408f74 ESP: c0408f54
> >  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> > Process swapper (pid: 0, ti=c0408000 task=c03d5d80 task.ti=c0408000)
> > Stack: c03d5d80 c0408f6c c017ac36 00000001 000000d0 00000000 000000d0 ee4005c0
> >        c0408f88 c0181577 0001080c 00000246 ee4005c0 c0408fa8 c0181a97 c0408fb0
> >        c01395b9 000000d0 0001080c 00099800 c03dccec c0408fd0 c01395b9 c0408fd0
> > Call Trace:
> >  [<c0105e23>] show_trace_log_lvl+0x19/0x2e
> >  [<c0105ee5>] show_stack_log_lvl+0x99/0xa1
> >  [<c010603f>] show_registers+0xb3/0x1e9
> >  [<c0106301>] die+0x11b/0x1fe
> >  [<c02fb654>] do_trap+0x8e/0xa8
> >  [<c01065cd>] do_invalid_op+0x88/0x92
> >  [<c02fb422>] error_code+0x72/0x78
> >  [<c0181577>] alternate_node_alloc+0x5b/0x60
> >  [<c0181a97>] kmem_cache_alloc+0x50/0x120
> >  [<c01395b9>] create_pid_cachep+0x4c/0xec
> >  [<c041ae65>] pidmap_init+0x2f/0x6e
> >  [<c040c715>] start_kernel+0x1ca/0x23e
> >  [<00000000>] 0x0
> >  =======================
> > Code: ff eb 02 31 ff 89 f8 83 c4 10 5b 5e 5f 5d c3 55 89 e5 57 89 c7 56 53 83
> > ec 14 89 55 f0 89 4d ec 8b b4 88 88 02 00 00 85 f6 75 04 <0f> 0b eb fe e8 f3
> > ee ff ff 8d 46 24 89 45 e4 e8 23 97 17 00 8b
> > EIP: [<c0181707>] ____cache_alloc_node+0x1c/0x130 SS:ESP 0068:c0408f54
> > Kernel panic - not syncing: Attempted to kill the idle task!
> 
> ow.
> 
> static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
> 				int nodeid)
> {
> 	struct list_head *entry;
> 	struct slab *slabp;
> 	struct kmem_list3 *l3;
> 	void *obj;
> 	int x;
> 
> 	l3 = cachep->nodelists[nodeid];
> 	BUG_ON(!l3);
> 
> Maybe something got mucked up in our initial preparation of the zonelists.
> 
> I assume this is a recent regression.  Is there any chance you can bisect
> it down to the offending commit?
> 

04231b3002ac53f8a64a7bd142fde3fa4b6808c6 is first bad commit

commit 04231b3002ac53f8a64a7bd142fde3fa4b6808c6
Author: Christoph Lameter <clameter@sgi.com>
Date:   Tue Oct 16 01:25:32 2007 -0700

    Memoryless nodes: Slab support
    
    Slab should not allocate control structures for nodes without memory.  This
    may seem to work right now but its unreliable since not all allocations can
    fall back due to the use of GFP_THISNODE.
    
    Switching a few for_each_online_node's to N_NORMAL_MEMORY will allow us to
    only allocate for nodes that have regular memory.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
    Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
    Acked-by: Bob Picco <bob.picco@hp.com>
    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Cc: Mel Gorman <mel@skynet.ie>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/slab.c b/mm/slab.c
index 1b240a3..368a47d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1568,7 +1568,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_online_node(nid) {
+		for_each_node_state(nid, N_NORMAL_MEMORY) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1944,7 +1944,7 @@ static void __init set_up_list3s(struct kmem_cache *cachep, int index)
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -2075,7 +2075,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep)
 			g_cpucache_up = PARTIAL_L3;
 		} else {
 			int node;
-			for_each_online_node(node) {
+			for_each_node_state(node, N_NORMAL_MEMORY) {
 				cachep->nodelists[node] =
 				    kmalloc_node(sizeof(struct kmem_list3),
 						GFP_KERNEL, node);
@@ -3792,7 +3792,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep)
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_NORMAL_MEMORY) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);



-----------------
git bisect log 

git-bisect start
# good: [bbf25010f1a6b761914430f5fca081ec8c7accd1] Linux 2.6.23
git-bisect good bbf25010f1a6b761914430f5fca081ec8c7accd1
# bad: [c9927c2bf4f45bb85e8b502ab3fb79ad6483c244] Linux 2.6.24-rc1
git-bisect bad c9927c2bf4f45bb85e8b502ab3fb79ad6483c244
# good: [9ac52315d4cf5f561f36dabaf0720c00d3553162] sched: guest CPU accounting: add guest-CPU /proc/<pid>/stat fields
git-bisect good 9ac52315d4cf5f561f36dabaf0720c00d3553162
# bad: [b9ec0339d8e22cadf2d9d1b010b51dc53837dfb0] add consts where appropriate in fs/nls/Kconfig fs/nls/Makefile fs/nls/nls_ascii.c fs/nls/nls_base.c fs/nls/nls_cp1250.c fs/nls/nls_cp1251.c fs/nls/nls_cp1255.c fs/nls/nls_cp437.c fs/nls/nls_cp737.c fs/nls/nls_cp775.c fs/nls/nls_cp850.c fs/nls/nls_cp852.c fs/nls/nls_cp855.c fs/nls/nls_cp857.c fs/nls/nls_cp860.c fs/nls/nls_cp861.c fs/nls/nls_cp862.c fs/nls/nls_cp863.c fs/nls/nls_cp864.c fs/nls/nls_cp865.c fs/nls/nls_cp866.c fs/nls/nls_cp869.c fs/nls/nls_cp874.c fs/nls/nls_cp932.c fs/nls/nls_cp936.c fs/nls/nls_cp949.c fs/nls/nls_cp950.c fs/nls/nls_euc-jp.c fs/nls/nls_iso8859-1.c fs/nls/nls_iso8859-13.c fs/nls/nls_iso8859-14.c fs/nls/nls_iso8859-15.c fs/nls/nls_iso8859-2.c fs/nls/nls_iso8859-3.c fs/nls/nls_iso8859-4.c fs/nls/nls_iso8859-5.c fs/nls/nls_iso8859-6.c fs/nls/nls_iso8859-7.c fs/nls/nls_iso8859-9.c fs/nls/nls_koi8-r.c fs/nls/nls_koi8-ru.c fs/nls/nls_koi8-u.c fs/nls/nls_utf8.c
git-bisect bad b9ec0339d8e22cadf2d9d1b010b51dc53837dfb0
# skip: [ac8842a0391a776dfa8f59cc83582f6feffa913b] [ALSA] hda-codec - Missing support ASUS A7J
git-bisect skip ac8842a0391a776dfa8f59cc83582f6feffa913b
# skip: [4eb4550ab37d351ab0973ccec921a5a2d8560ec7] [ALSA] Workaround for invalid signature read of CS8427
git-bisect skip 4eb4550ab37d351ab0973ccec921a5a2d8560ec7
# bad: [78a26e25ce4837a03ac3b6c32cdae1958e547639] uml: separate timer initialization
git-bisect bad 78a26e25ce4837a03ac3b6c32cdae1958e547639
# good: [4acad72ded8e3f0211bd2a762e23c28229c61a51] [IPV6]: Consolidate the ip6_pol_route_(input|output) pair
git-bisect good 4acad72ded8e3f0211bd2a762e23c28229c61a51
# good: [64da82efae0d7b5f7c478021840fd329f76d965d] Add support for PCMCIA card Sierra WIreless AC850
git-bisect good 64da82efae0d7b5f7c478021840fd329f76d965d
# bad: [0e1e7c7a739562a321fda07c7cd2a97a7114f8f8] Memoryless nodes: Use N_HIGH_MEMORY for cpusets
git-bisect bad 0e1e7c7a739562a321fda07c7cd2a97a7114f8f8
# bad: [0e1e7c7a739562a321fda07c7cd2a97a7114f8f8] Memoryless nodes: Use N_HIGH_MEMORY for cpusets
git-bisect bad 0e1e7c7a739562a321fda07c7cd2a97a7114f8f8
# good: [5fe172370687e03cc6ba8dca990b75db18ff9bb3] mm: debug write deadlocks
git-bisect good 5fe172370687e03cc6ba8dca990b75db18ff9bb3
# skip: [4899f9c852564ce7b6d0ca932ac6674bf471fd28] nfs: convert to new aops
git-bisect skip 4899f9c852564ce7b6d0ca932ac6674bf471fd28
# skip: [a20fa20c549ed569885d871f689a59cfd2f6ff77] With reiserfs no longer using the weird generic_cont_expand, remove it completely.
git-bisect skip a20fa20c549ed569885d871f689a59cfd2f6ff77
# skip: [fb53b3094888be0cf8ddf052277654268904bdf5] smbfs: convert to new aops
git-bisect skip fb53b3094888be0cf8ddf052277654268904bdf5
# skip: [5e6f58a1d7ce2fd5ef099f9aec5b3e3f7ba176b4] fuse: convert to new aops
git-bisect skip 5e6f58a1d7ce2fd5ef099f9aec5b3e3f7ba176b4
# skip: [f7557e8f7ff785d6c2b5bc914cd1675314ff0fcf] reiserfs: use generic_cont_expand_simple
git-bisect skip f7557e8f7ff785d6c2b5bc914cd1675314ff0fcf
# skip: [ae361ff46ba93b2644675d9de19e885185f0d0c1] hostfs: convert to new aops
git-bisect skip ae361ff46ba93b2644675d9de19e885185f0d0c1
# skip: [ba9d8cec6c7165e440f9b2413a0464cf3c12fb25] reiserfs: convert to new aops
git-bisect skip ba9d8cec6c7165e440f9b2413a0464cf3c12fb25
# skip: [205c109a7a96d9a3d8ffe64c4068b70811fef5e8] jffs2: convert to new aops
git-bisect skip 205c109a7a96d9a3d8ffe64c4068b70811fef5e8
# skip: [797b4cffdf79b9ed66759b8d2d5252eba965fb18] reiserfs: use generic write
git-bisect skip 797b4cffdf79b9ed66759b8d2d5252eba965fb18
# skip: [82b9d1d0da8046088b0f505f92a97d12d9804613] ufs: convert to new aops
git-bisect skip 82b9d1d0da8046088b0f505f92a97d12d9804613
# skip: [f87061842877cf822251c65b39cc624cc94046da] qnx4: convert to new aops
git-bisect skip f87061842877cf822251c65b39cc624cc94046da
# skip: [be021ee41a8b65d181fe22799de6be62adf72efb] udf: convert to new aops
git-bisect skip be021ee41a8b65d181fe22799de6be62adf72efb
# good: [55144768e100b68447f44c5e5c9deb155ad661bd] fs: remove some AOP_TRUNCATED_PAGE
git-bisect good 55144768e100b68447f44c5e5c9deb155ad661bd
# bad: [f64dc58c5412233d4d44b0275eaebdc11bde23b3] Memoryless nodes: SLUB support
git-bisect bad f64dc58c5412233d4d44b0275eaebdc11bde23b3
# good: [6eaf806a223e61dc5f2de4ab591f11beb97a8f3b] Memoryless nodes: Fix interleave behavior for memoryless nodes
git-bisect good 6eaf806a223e61dc5f2de4ab591f11beb97a8f3b
# good: [9422ffba4adc82b4b67a3ca6ef51516aa61f8248] Memoryless nodes: No need for kswapd
git-bisect good 9422ffba4adc82b4b67a3ca6ef51516aa61f8248
# bad: [04231b3002ac53f8a64a7bd142fde3fa4b6808c6] Memoryless nodes: Slab support
git-bisect bad 04231b3002ac53f8a64a7bd142fde3fa4b6808c6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
