Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD5E6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 07:14:37 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so14781570qeb.14
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 04:14:36 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id s5si25424910qck.4.2013.12.05.04.14.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 04:14:35 -0800 (PST)
Message-ID: <52A07BBE.7060507@ti.com>
Date: Thu, 5 Dec 2013 15:12:30 +0200
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org> <529F5047.50309@ti.com> <20131204160730.GQ3158@htj.dyndns.org> <529F5C55.1020707@ti.com>
In-Reply-To: <529F5C55.1020707@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Tejun,
On 12/04/2013 06:46 PM, Santosh Shilimkar wrote:
> On Wednesday 04 December 2013 11:07 AM, Tejun Heo wrote:
>> Hello,
>>
>> On Wed, Dec 04, 2013 at 10:54:47AM -0500, Santosh Shilimkar wrote:
>>> Well as you know there are architectures still using bootmem even after
>>> this series. Changing MAX_NUMNODES to NUMA_NO_NODE is too invasive and
>>> actually should be done in a separate series. As commented, the best
>>> time to do that would be when all remaining architectures moves to
>>> memblock.
>>>
>>> Just to give you perspective, look at the patch end of the email which
>>> Grygorrii cooked up. It doesn't cover all the users of MAX_NUMNODES
>>> and we are bot even sure whether the change is correct and its
>>> impact on the code which we can't even tests. I would really want to
>>> avoid touching all the architectures and keep the scope of the series
>>> to core code as we aligned initially.
>>>
>>> May be you have better idea to handle this change so do
>>> let us know how to proceed with it. With such a invasive change the
>>> $subject series can easily get into circles again :-(
>>
>> But we don't have to use MAX_NUMNODES for the new interface, no?  Or
>> do you think that it'd be more confusing because it ends up mixing the
>> two?
> The issue is memblock code already using MAX_NUMNODES. Please
> look at __next_free_mem_range() and __next_free_mem_range_rev().
> The new API use the above apis and hence use MAX_NUMNODES. If the
> usage of these constant was consistent across bootmem and memblock
> then we wouldn't have had the whole confusion.

I'll try to provide more technical details here.
As Santosh mentioned in previous e-mails, it's not easy to simply
get rid of using MAX_NUMNODES:
1) we introduce new interface memblock_allocX 
2) our interface uses memblock APIs __next_free_mem_range_rev()
   and __next_free_mem_range()
3) __next_free_mem_range_rev() and __next_free_mem_range() use MAX_NUMNODES
4) _next_free_mem_range_rev() and __next_free_mem_range() are used standalone,
   outside of our interface as part of *for_each_free_mem_range* or for_each_mem_pfn_range ..

The point [4] leads to necessity to find and correct all places where memmblock APIs
are used and where it's expected to get MAX_NUMNODES as input parameter.
The major problem is that simple "grep" will not work, because memmblock APIs calls
are hidden inside other MM modules and it's not always clear
what will be passed as input parameters to APIs of these MM modules
(for example sparse_memory_present_with_active_regions() or sparse.c).

As result, WIP patch, I did, and which was posted by Santosh illustrates
the probable size and complexity of the change.

> 
> It kinda really bothers me this patchset is expanding the usage
>> of the wrong constant with only very far-out plan to fix that.  All
>> archs converting to nobootmem will take a *long* time, that is, if
>> that happens at all.  I don't really care about the order of things
>> happening but "this is gonna be fixed when everyone moves off
>> MAX_NUMNODES" really isn't good enough.

Sorry, but question here is not "Do or not to do?", but rather 'how to do?",
taking into account complexity and state of the current MM code.
For example. would it be ok if I'll workaround the issue as in the attached patch?

Thanks for any advice.

Regards,
- grygorii

---
 include/linux/bootmem.h |    8 ++++----
 mm/memblock.c           |   25 ++++++++++++++++++-------
 mm/percpu.c             |    2 +-
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 9e67fe4..84e778d 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -171,20 +171,20 @@ void __memblock_free_late(phys_addr_t base, phys_addr_t size);
 
 #define memblock_virt_alloc(x) \
 	memblock_virt_alloc_try_nid(x, 0, BOOTMEM_LOW_LIMIT, \
-				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+				     BOOTMEM_ALLOC_ACCESSIBLE, NUMA_NO_NODE)
 #define memblock_virt_alloc_align(x, align) \
 	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
-				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+				     BOOTMEM_ALLOC_ACCESSIBLE, NUMA_NO_NODE)
 #define memblock_virt_alloc_nopanic(x) \
 	memblock_virt_alloc_try_nid_nopanic(x, 0, \
 					     BOOTMEM_LOW_LIMIT, \
 					     BOOTMEM_ALLOC_ACCESSIBLE, \
-					     MAX_NUMNODES)
+					     NUMA_NO_NODE)
 #define memblock_virt_alloc_align_nopanic(x, align) \
 	memblock_virt_alloc_try_nid_nopanic(x, align, \
 					     BOOTMEM_LOW_LIMIT, \
 					     BOOTMEM_ALLOC_ACCESSIBLE, \
-					     MAX_NUMNODES)
+					     NUMA_NO_NODE)
 #define memblock_virt_alloc_node(x, nid) \
 	memblock_virt_alloc_try_nid(x, 0, BOOTMEM_LOW_LIMIT, \
 				     BOOTMEM_ALLOC_ACCESSIBLE, nid)
diff --git a/mm/memblock.c b/mm/memblock.c
index 1503300..cae02a1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -945,7 +945,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * The @min_addr limit is dropped if it can not be satisfied and the allocation
  * will fall back to memory below @min_addr.
@@ -970,16 +970,27 @@ static void * __init _memblock_virt_alloc_try_nid_nopanic(
 	phys_addr_t alloc;
 	void *ptr;
 
+	/*
+	 * TODO: this is WA as we should get NUMA_NO_NODE as input parameter
+	 * to work with any node, but there are no guarantee that we always will
+	 * Remove it once memblock core is converted to use NUMA_NO_NODE.
+	 */
+	nid = (nid == MAX_NUMNODES) ? NUMA_NO_NODE : nid;
+
 	if (WARN_ON_ONCE(slab_is_available())) {
-		if (nid == MAX_NUMNODES)
-			return kzalloc(size, GFP_NOWAIT);
-		else
-			return kzalloc_node(size, GFP_NOWAIT, nid);
+		return kzalloc_node(size, GFP_NOWAIT, nid);
 	}
 
 	if (!align)
 		align = SMP_CACHE_BYTES;
 
+	/*
+	 * TODO: this is WA as we get NUMA_NO_NODE as input parameter, but
+	 * memblock core still uses MAX_NUMNODES.
+	 * Remove it once memblock core is converted to use NUMA_NO_NODE.
+	 */
+	nid = (nid == NUMA_NO_NODE) ? MAX_NUMNODES : nid;
+
 	/* align @size to avoid excessive fragmentation on reserved array */
 	size = round_up(size, align);
 
@@ -1028,7 +1039,7 @@ error:
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
  * additional debug information (including caller info), if enabled.
@@ -1056,7 +1067,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  * @max_addr: the upper bound of the memory region from where the allocation
  *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
- * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
  * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
diff --git a/mm/percpu.c b/mm/percpu.c
index f74902c..55a798e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1853,7 +1853,7 @@ static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
 	return  memblock_virt_alloc_try_nid_nopanic(size, align,
 						     __pa(MAX_DMA_ADDRESS),
 						     BOOTMEM_ALLOC_ACCESSIBLE,
-						     MAX_NUMNODES);
+						     NUMA_NO_NODE);
 }
 
 static void __init pcpu_dfl_fc_free(void *ptr, size_t size)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
