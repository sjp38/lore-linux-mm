Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m09Ix2lh012990
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 00:29:02 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09Ix1ge913476
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 00:29:02 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m09Ix1SW026388
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 18:59:01 GMT
Date: Thu, 10 Jan 2008 00:28:59 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080109185859.GD11852@skywalker>
References: <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com> <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com> <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 09:50:56AM -0800, Christoph Lameter wrote:
> On Tue, 8 Jan 2008, Nishanth Aravamudan wrote:
> 
> > Do we (perhaps you already have done so, Christoph), want to validate
> > any other users of numa_node_id() that then make assumptions about the
> > characteristics of the nid? Hrm, that sounds good in theory, but seems
> > hard in practice?
> 
> Hmmm... The main allocs are the slab allocations. If we fallback in 
> kmalloc etc then we are fine for the common case. SLUB falls back 
> correctly. Its just the weird nesting of functions in SLAB that has made 
> this a bit difficult for that allocator.
> 
This patch didn't work. I still see 
------------[ cut here ]------------
kernel BUG at mm/slab.c:3323!
invalid opcode: 0000 [#1] PREEMPT SMP 
Modules linked in:

Pid: 0, comm: swapper Not tainted (2.6.24-rc5-autokern1 #1)
EIP: 0060:[<c01816fa>] EFLAGS: 00010046 CPU: 0
EIP is at ____cache_alloc_node+0x1c/0x130
EAX: e2c005c0 EBX: 00000000 ECX: 00000001 EDX: 000000d0
ESI: 00000000 EDI: e2c005c0 EBP: c03fef68 ESP: c03fef48
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c03fe000 task=c03cbd80 task.ti=c03fe000)
Stack: c03cbd80 c03fef60 c017ac2a 00000001 000000d0 00000000 000000d0 e2c005c0 
       c03fef7c c018156a 0002080c 00099800 00000000 c03fefa8 c0181a90 22222222 
       22222222 00000246 c01395b5 000000d0 e2c005c0 0002080c 00099800 c03d2cec 
Call Trace:
 [<c0105e23>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee5>] show_stack_log_lvl+0x99/0xa1
 [<c010603f>] show_registers+0xb3/0x1e9
 [<c0106301>] die+0x11b/0x1fe
 [<c02f2de4>] do_trap+0x8e/0xa8
 [<c01065cd>] do_invalid_op+0x88/0x92
 [<c02f2bb2>] error_code+0x72/0x78
 [<c018156a>] alternate_node_alloc+0x5b/0x60
 [<c0181a90>] kmem_cache_alloc+0x56/0x272
 [<c01395b5>] create_pid_cachep+0x4c/0xec
 [<c0410e65>] pidmap_init+0x2f/0x6e
 [<c0402715>] start_kernel+0x1ca/0x23e
 [<00000000>] 0x0
 =======================
Code: ff eb 02 31 ff 89 f8 83 c4 10 5b 5e 5f 5d c3 55 89 e5 57 89 c7 56 53 83 ec 14 89 55 f0 89 4d ec 8b b4 88 88 02 00 00 85 f6 75 04 <0f> 0b eb fe e8 f4 ee ff ff 8d 46 24 89 45 e4 e8 c0 0e 17 00 8b 
EIP: [<c01816fa>] ____cache_alloc_node+0x1c/0x130 SS:ESP 0068:c03fef48
Kernel panic - not syncing: Attempted to kill the idle task!
-- 0:conmux-control -- time-stamp -- Jan/09/08 10:21:55 --
-- 0:conmux-control -- time-stamp -- Jan/09/08 10:33:39 --
(bot:conmon-payload) disconnected

diff --git a/mm/slab.c b/mm/slab.c
index 2e338a5..34279d8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2977,6 +2977,9 @@ retry:
 	}
 	l3 = cachep->nodelists[node];
 
+	if (!l3)
+		return NULL;
+
 	BUG_ON(ac->avail > 0 || !l3);
 	spin_lock(&l3->list_lock);
 
@@ -3439,8 +3442,14 @@ __do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
- 	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+ 	if (!objp) {
+		int node_id = numa_node_id();
+		if (likely(cache->nodelists[node_id])) /* fast path */
+ 			objp = ____cache_alloc_node(cache, flags, node_id);
+		else /* this function can do good fallback */
+			objp = __cache_alloc_node(cache, flags, node_id,
+					__builtin_return_address(0));
+	}
 
   out:
 	return objp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
