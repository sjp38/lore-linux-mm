Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47A2428073C
	for <linux-mm@kvack.org>; Tue,  9 May 2017 14:12:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g12so2026239wrg.15
        for <linux-mm@kvack.org>; Tue, 09 May 2017 11:12:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y186si1672481wme.81.2017.05.09.11.12.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 11:12:37 -0700 (PDT)
Date: Tue, 9 May 2017 20:12:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170509181234.GA4397@dhcp22.suse.cz>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Fri 05-05-17 13:03:07, Pavel Tatashin wrote:
> Changelog:
> 	v2 - v3
> 	- Addressed David's comments about one change per patch:
> 		* Splited changes to platforms into 4 patches
> 		* Made "do not zero vmemmap_buf" as a separate patch
> 	v1 - v2
> 	- Per request, added s390 to deferred "struct page" zeroing
> 	- Collected performance data on x86 which proofs the importance to
> 	  keep memset() as prefetch (see below).
> 
> When deferred struct page initialization feature is enabled, we get a
> performance gain of initializing vmemmap in parallel after other CPUs are
> started. However, we still zero the memory for vmemmap using one boot CPU.
> This patch-set fixes the memset-zeroing limitation by deferring it as well.

I like the idea of postponing the zeroing from the allocation to the
init time. To be honest the improvement looks much larger than I would
expect (Btw. this should be a part of the changelog rather than a
outside link).

The implementation just looks too large to what I would expect. E.g. do
we really need to add zero argument to the large part of the memblock
API? Wouldn't it be easier to simply export memblock_virt_alloc_internal
(or its tiny wrapper memblock_virt_alloc_core) and move the zeroing
outside to its 2 callers? A completely untested scratched version at the
end of the email.

Also it seems that this is not 100% correct either as it only cares
about VMEMMAP while DEFERRED_STRUCT_PAGE_INIT might be enabled also for
SPARSEMEM. This would suggest that we would zero out pages twice,
right?

A similar concern would go to the memory hotplug patch which will
fall back to the slab/page allocator IIRC. On the other hand
__init_single_page is shared with the hotplug code so again we would
initialize 2 times.

So I suspect more changes are needed. I will have a closer look tomorrow.

>  arch/powerpc/mm/init_64.c |    4 +-
>  arch/s390/mm/vmem.c       |    5 ++-
>  arch/sparc/mm/init_64.c   |   26 +++++++----------------
>  arch/x86/mm/init_64.c     |    3 +-
>  include/linux/bootmem.h   |    3 ++
>  include/linux/mm.h        |   15 +++++++++++--
>  mm/memblock.c             |   46 ++++++++++++++++++++++++++++++++++++------
>  mm/page_alloc.c           |    3 ++
>  mm/sparse-vmemmap.c       |   48 +++++++++++++++++++++++++++++---------------
>  9 files changed, 103 insertions(+), 50 deletions(-)


The bootmem API change mentioned above.

 include/linux/bootmem.h |  3 +++
 mm/memblock.c           | 41 ++++++++++++++++++++++++++---------------
 mm/sparse-vmemmap.c     |  2 +-
 3 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 962164d36506..c9a08463d9a8 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -160,6 +160,9 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
 
 /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
+void * memblock_virt_alloc_core(phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid);
 void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t min_addr,
 		phys_addr_t max_addr, int nid);
diff --git a/mm/memblock.c b/mm/memblock.c
index b049c9b2dba8..eab7da94f873 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1271,8 +1271,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  *
  * The memory block is aligned on SMP_CACHE_BYTES if @align == 0.
  *
- * The phys address of allocated boot memory block is converted to virtual and
- * allocated memory is reset to 0.
+ * The function has to be zeroed out explicitly.
  *
  * In addition, function sets the min_count to 0 using kmemleak_alloc for
  * allocated boot memory block, so that it is never reported as leaks.
@@ -1280,15 +1279,18 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  * RETURNS:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
-static void * __init memblock_virt_alloc_internal(
+static inline void * __init memblock_virt_alloc_internal(
 				phys_addr_t size, phys_addr_t align,
 				phys_addr_t min_addr, phys_addr_t max_addr,
-				int nid)
+				int nid, void *caller)
 {
 	phys_addr_t alloc;
 	void *ptr;
 	ulong flags = choose_memblock_flags();
 
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, caller);
 	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
 		nid = NUMA_NO_NODE;
 
@@ -1334,7 +1336,6 @@ static void * __init memblock_virt_alloc_internal(
 	return NULL;
 done:
 	ptr = phys_to_virt(alloc);
-	memset(ptr, 0, size);
 
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
@@ -1347,6 +1348,14 @@ static void * __init memblock_virt_alloc_internal(
 	return ptr;
 }
 
+void * __init memblock_virt_alloc_core(phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid)
+{
+	return memblock_virt_alloc_internal(size, align, min_addr, max_addr, nid,
+			(void *)_RET_IP_);
+}
+
 /**
  * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1369,11 +1378,14 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
 {
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
-	return memblock_virt_alloc_internal(size, align, min_addr,
-					     max_addr, nid);
+	void *ptr;
+
+	ptr = memblock_virt_alloc_internal(size, align, min_addr,
+					     max_addr, nid, (void *)_RET_IP_);
+	if (ptr)
+		memset(ptr, 0, size);
+
+	return ptr;
 }
 
 /**
@@ -1401,13 +1413,12 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
-					   min_addr, max_addr, nid);
-	if (ptr)
+					   min_addr, max_addr, nid, (void *)_RET_IP_);
+	if (ptr) {
+		memset(ptr, 0, size);
 		return ptr;
+	}
 
 	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
 	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index a56c3989f773..4e060f0f9fe5 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -41,7 +41,7 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long align,
 				unsigned long goal)
 {
-	return memblock_virt_alloc_try_nid(size, align, goal,
+	return memblock_virt_alloc_core(size, align, goal,
 					    BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
