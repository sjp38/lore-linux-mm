From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/2] x86: reinstate numa remap for SPARSEMEM on x86 NUMA systems
References: <exportbomb.1211277639@pinky>
Date: Tue, 20 May 2008 11:01:08 +0100
Message-Id: <1211277668.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Recent kernels have been panic'ing trying to allocate memory early in boot,
in __alloc_pages:

  BUG: unable to handle kernel paging request at 00001568
  IP: [<c10407b6>] __alloc_pages+0x33/0x2cc
  *pdpt = 00000000013a5001 *pde = 0000000000000000
  Oops: 0000 [#1] SMP
  Modules linked in:

  Pid: 1, comm: swapper Not tainted (2.6.25 #78)
  EIP: 0060:[<c10407b6>] EFLAGS: 00010246 CPU: 0
  EIP is at __alloc_pages+0x33/0x2cc
  EAX: 00001564 EBX: 000412d0 ECX: 00001564 EDX: 000005c3
  ESI: f78012a0 EDI: 00000001 EBP: 00001564 ESP: f7871e50
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
  Process swapper (pid: 1, ti=f7870000 task=f786f670 task.ti=f7870000)
  Stack: 00000000 f786f670 00000010 00000000 0000b700 000412d0 f78012a0 00000001
         00000000 c105b64d 00000000 000412d0 f78012a0 f7803120 00000000 c105c1c5
         00000010 f7803144 000412d0 00000001 f7803130 f7803120 f78012a0 00000001
  Call Trace:
   [<c105b64d>] kmem_getpages+0x94/0x129
   [<c105c1c5>] cache_grow+0x8f/0x123
   [<c105c689>] ____cache_alloc_node+0xb9/0xe4
   [<c105c999>] kmem_cache_alloc_node+0x92/0xd2
   [<c1018929>] build_sched_domains+0x536/0x70d
   [<c100b63c>] do_flush_tlb_all+0x0/0x3f
   [<c100b63c>] do_flush_tlb_all+0x0/0x3f
   [<c10572d6>] interleave_nodes+0x23/0x5a
   [<c105c44f>] alternate_node_alloc+0x43/0x5b
   [<c1018b47>] arch_init_sched_domains+0x46/0x51
   [<c136e85e>] kernel_init+0x0/0x82
   [<c137ac19>] sched_init_smp+0x10/0xbb
   [<c136e8a1>] kernel_init+0x43/0x82
   [<c10035cf>] kernel_thread_helper+0x7/0x10

Debugging this showed that the NODE_DATA() for nodes other than node 0
were all NULL.  Tracing this back showed that the NODE_DATA() pointers
were being initialised to each nodes remap space.  However under SPARSEMEM
remap is disabled which leads to the pgdat's being placed incorrectly
at kernel virtual address 0.  Leading to the panic when attempting to
allocate memory from these nodes.

Numa remap was disabled in the commit below.  This occured while fixing
problems triggered when attempting to boot x86_32 NUMA SPARSEMEM kernels
on non-numa hardware.

	x86: make NUMA work on 32-bit
	commit 1b000a5dbeb2f34bc03d45ebdf3f6d24a60c3aed

The real problem is believed to be related to other alignment issues in the
regions blocked out from the bootmem allocator for small memory systems,
and has been fixed separately.  Therefore re-enable remap for SPARSMEM,
which fixes pgdat allocation issues.  Testing confirms that SPARSMEM NUMA
kernels will boot correctly with this part of the change reverted.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/mm/discontig_32.c |   34 ++++++----------------------------
 1 files changed, 6 insertions(+), 28 deletions(-)
diff --git a/arch/x86/mm/discontig_32.c b/arch/x86/mm/discontig_32.c
index 914ccf9..026201f 100644
--- a/arch/x86/mm/discontig_32.c
+++ b/arch/x86/mm/discontig_32.c
@@ -164,16 +164,13 @@ static void __init allocate_pgdat(int nid)
 	}
 }
 
-#ifdef CONFIG_DISCONTIGMEM
 /*
- * In the discontig memory model, a portion of the kernel virtual area (KVA)
- * is reserved and portions of nodes are mapped using it. This is to allow
- * node-local memory to be allocated for structures that would normally require
- * ZONE_NORMAL. The memory is allocated with alloc_remap() and callers
- * should be prepared to allocate from the bootmem allocator instead. This KVA
- * mechanism is incompatible with SPARSEMEM as it makes assumptions about the
- * layout of memory that are broken if alloc_remap() succeeds for some of the
- * map and fails for others
+ * In the DISCONTIGMEM and SPARSEMEM memory model, a portion of the kernel
+ * virtual address space (KVA) is reserved and portions of nodes are mapped
+ * using it. This is to allow node-local memory to be allocated for
+ * structures that would normally require ZONE_NORMAL. The memory is
+ * allocated with alloc_remap() and callers should be prepared to allocate
+ * from the bootmem allocator instead.
  */
 static unsigned long node_remap_start_pfn[MAX_NUMNODES];
 static void *node_remap_end_vaddr[MAX_NUMNODES];
@@ -290,25 +287,6 @@ static void init_remap_allocator(int nid)
 		(ulong) pfn_to_kaddr(highstart_pfn
 		   + node_remap_offset[nid] + node_remap_size[nid]));
 }
-#else
-void *alloc_remap(int nid, unsigned long size)
-{
-	return NULL;
-}
-
-static unsigned long calculate_numa_remap_pages(void)
-{
-	return 0;
-}
-
-static void init_remap_allocator(int nid)
-{
-}
-
-void __init remap_numa_kva(void)
-{
-}
-#endif /* CONFIG_DISCONTIGMEM */
 
 extern void setup_bootmem_allocator(void);
 unsigned long __init setup_memory(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
