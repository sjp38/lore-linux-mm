Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB5BB6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 13:43:18 -0500 (EST)
Message-ID: <4B915074.4020704@kernel.org>
Date: Fri, 05 Mar 2010 10:41:56 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> 	<20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
In-Reply-To: <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/04/2010 09:17 PM, Greg Thelen wrote:
> On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>>> On several systems I am seeing a boot panic if I use mmotm
>>> (stamp-2010-03-02-18-38).  If I remove
>>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen.  I
>>> find that:
>>> * 2.6.33 boots fine.
>>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fine.
>>> * 2.6.33 + mmotm (including
>>> bootmem-avoid-dma32-zone-by-default.patch): panics.
...
> 
> Note: mmotm has been recently updated to stamp-2010-03-04-18-05.  I
> re-tested with 'make defconfig' to confirm the panic with this later
> mmotm.

please check

[PATCH] early_res: double check with updated goal in alloc_memory_core_early

Johannes Weiner pointed out that new early_res replacement for alloc_bootmem_node
change the behavoir about goal.
original bootmem one will try go further regardless of goal.

and it will break his patch about default goal from MAX_DMA to MAX_DMA32...
also broke uncommon machines with <=16M of memory.
(really? our x86 kernel still can run on 16M system?)

so try again with update goal.

Reported-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 mm/bootmem.c |   28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -170,6 +170,28 @@ void __init free_bootmem_late(unsigned l
 }
 
 #ifdef CONFIG_NO_BOOTMEM
+static void * __init ___alloc_memory_core_early(pg_data_t *pgdat, u64 size,
+						 u64 align, u64 goal, u64 limit)
+{
+	void *ptr;
+	unsigned long end_pfn;
+
+	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
+					 goal, limit);
+	if (ptr)
+		return ptr;
+
+	/* check goal according  */
+	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	if ((end_pfn << PAGE_SHIFT) < (goal + size)) {
+		goal = pgdat->node_start_pfn << PAGE_SHIFT;
+		ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
+						 goal, limit);
+	}
+
+	return ptr;
+}
+
 static void __init __free_pages_memory(unsigned long start, unsigned long end)
 {
 	int i;
@@ -836,7 +858,7 @@ void * __init __alloc_bootmem_node(pg_da
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 #ifdef CONFIG_NO_BOOTMEM
-	return __alloc_memory_core_early(pgdat->node_id, size, align,
+	return  ___alloc_memory_core_early(pgdat, size, align,
 					 goal, -1ULL);
 #else
 	return ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
@@ -920,7 +942,7 @@ void * __init __alloc_bootmem_node_nopan
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 #ifdef CONFIG_NO_BOOTMEM
-	ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
+	ptr =  ___alloc_memory_core_early(pgdat, size, align,
 						 goal, -1ULL);
 #else
 	ptr = alloc_arch_preferred_bootmem(pgdat->bdata, size, align, goal, 0);
@@ -980,7 +1002,7 @@ void * __init __alloc_bootmem_low_node(p
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 #ifdef CONFIG_NO_BOOTMEM
-	return __alloc_memory_core_early(pgdat->node_id, size, align,
+	return ___alloc_memory_core_early(pgdat, size, align,
 				goal, ARCH_LOW_ADDRESS_LIMIT);
 #else
 	return ___alloc_bootmem_node(pgdat->bdata, size, align,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
