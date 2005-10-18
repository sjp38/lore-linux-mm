Date: Mon, 17 Oct 2005 17:49:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/2] Page migration via Swap V2: Overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, ak@suse.de, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

In a NUMA system it is often beneficial to be able to move the memory
in use by a process to different nodes in order to enhance performance.
Currently Linux simply does not support this facility.

Page migration is also useful for other purposes:

1. Memory hotplug. Migrating processes off a memory node that is going
   to be disconnected.

2. Remapping of bad pages. These could be detected through soft ECC errors
   and other mechanisms.

Work on page migration has been done in the context of the memory hotplug project
(see https://lists.sourceforge.net/lists/listinfo/lhms-devel). Ray Bryant
has also posted a series of manual page migration patchsets. However, the patches
are complex, and may have impacts on the VM in various places, there are unresolved
issues regarding memory placement during direct migration and thus the functionality
may not be available for some time.

This patchset was done in awareness of the work done there and realizes page
migration via swap. Pages are not directly moved to their target
location but simply swapped out. If the application touches the page later then
a new page is allocated in the desired location.

The advantage of page based swapping is that the necessary changes to the kernel
are minimal. With a fully functional but minimal page migration capability we
will be able to enhance low level code and higher level APIs at the same time.
This will hopefully decrease the time needed to get the code for direct page
migration working and into the kernel trees.

The disadvantage over direct page migration are:

A. Performance: Having to go through swap is slower.

B. The need for swap space: The area to be migrated must fit into swap.

C. Placement of pages at swapin is done under the memory policy in
   effect at that time. This may destroy nodeset relative positioning.

The advantages over direct page migration:

A. More general and less of an impact on the system

B. Uses the proven swap code. No new page behavior that
   may have to be considered in other places of the VM.

C. May be used for additional purposes like suspending an application
   by swapping it out.

The patchset consists of two patches:

1. Page eviction patch

Modifies mm/vmscan.c to add functions to isolate pages from the LRU lists,
swapout lists of pages and return pages to the LRU lists.

2. MPOL_MF_MOVE flag for memory policies.

This implements MPOL_MF_MOVE in addition to MPOL_MF_STRICT. MPOL_MF_STRICT
allows the checking if all pages in a memory area obey the memory policies.
MPOL_MF_MOVE will evict all pages that do not conform to the memory policy.
The system will allocate pages conforming to the policy on swap in.

URLs referring to the discussion regarding the initial version of these
patches.

Page eviction: http://marc.theaimsgroup.com/?l=linux-mm&m=112922756730989&w=2
Numa policy  : http://marc.theaimsgroup.com/?l=linux-mm&m=112922756724715&w=2

Changes from V1:
- Patch against 2.6.14-rc4-mm1
- Remove move_pages() function
- Code cleanup to make it less invasive.
- Fix missing lru_add_drain() invocation from isolate_lru_page()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
