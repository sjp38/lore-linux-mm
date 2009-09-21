Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E83A6B00A3
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 12:10:29 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Date: Mon, 21 Sep 2009 17:10:23 +0100
Message-Id: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Currently SLQB is not allowed to be configured on PPC and S390 machines as
CPUs can belong to memoryless nodes. SLQB does not deal with this very well
and crashes reliably.

These patches fix the problem on PPC64 and it appears to be fairly stable.
At least, basic actions that were previously silently halting the machine
complete successfully. There might still be per-cpu problems as Sachin
reported the stability problems on this machine did not depend on SLQB.

Patch 1 notes that the per-node hack in SLQB only works if every node in
	the system has a CPU of the same ID. If this is not the case,
	the per-node areas are not necessarily allocated. This fix only
	applies to ppc64. It's possible that s390 needs a similar hack. The
	alternative is to statically allocate the per-node structures but
	this is both sub-optimal in terms of performance and memory usage.

Patch 2 notes that on memoryless configurations, memory is always freed
	remotely but always allocates locally and falls back to the page
	allocator on failure. This effectively is a memory leak. This patch
	records in kmem_cache_cpu what node it considers local to be either
	the real local node or the closest node available

Patch 3 allows SLQB to be configured on PPC again. It's not enabled on
	S390 because I can't test for sure on a suitable configuration there.

This is not ready for merging just yet.

It needs signed-off from the powerpc side because it's now allocating more
memory potentially (Ben?). An alternative to this patch is in V1 that
statically declares the per-node structures but this is potentially
sub-optimal but from a performance and memory utilisation perspective.

>From an SLQB side, how does patch 2 now look from a potential list-corruption
point of view (Christoph, Nick, Pekka?). Certainly this version seems a
lot more sensible than the patch in V1 because the per-cpu list is now
always being used for pages from the closest node.

It would also be nice if the S390 guys could retest as well with SLQB to see
if special action with respect to per-cpu areas is still needed.

 arch/powerpc/kernel/setup_64.c |   20 ++++++++++++++++++++
 include/linux/slqb_def.h       |    3 +++
 init/Kconfig                   |    2 +-
 mm/slqb.c                      |   23 +++++++++++++++++------
 4 files changed, 41 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
