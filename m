From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:20:47 -0500
Message-Id: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 0/8] Mem Policy: More Reference Counting/Fallback Fixes and Misc Cleanups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, clameter@sgi.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH/RFC 00/08 Mem Policy: Reference Counting/Fallback Fixes and
		Miscellaneous mempolicy cleanup

Against: 2.6.24-rc2-mm1

  Note:  These patches are based atop Mel Gorman's "twozonelist"
  series.  Patch 5 depends on the elimination of the external
  zonelist attached to MPOL_BIND policies.  Patch 8 updates the
  mempolicy documentation to reflect a change introduced by Mel's
  patches.  I will rebase and repost less the 'RFC' and to resolve
  any comments after Mel's patches go into -mm.

Patch 1 takes mmap_sem for write when installing task memory policy.
Suggested by and originally posted by Christoph Lameter.

Patch 2 fixes a problem with fallback when a get_policy() vm_op returns
NULL.  Currently does not follow vma->task->system default policy path.

Patch 3 marks shared policies as such.  Only shared policies require 
unref after lookup.

Patch 4 just documents the mempolicy reference semantics assumed by this
series for the set and get policy vm_ops where the prototypes are defined.

Patch 5 contains the actual rework of mempolicy reference counting.  This
patch backs out the code that performed unref on all mempolicy other that
current task's and system default, and performs unref only when needed--
effectively only on shared policies.  Also updates the numa_memory_policy.txt
document to describe the memory policy reference counting semantics as I
currently understand them.

Patches 6 and 7 are cleanups of the internal usage of MPOL_DEFAULT and
MPOL_PREFERRED.

Patch 8 updates the memory policy documentation to reflect the fact that,
with Mel's twozonelist series, MPOL_BIND now searches the allowed nodes
in distance order.

This series in currently an RFC.  The patches in in this series build, boot
and survive memtoy testing on an x86_64 numa platform.  I have also tested with
instrumentation to track and report the reference counts.  So far, my testing
shows that the patches are working as I expect.

Lee Schermerhorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
