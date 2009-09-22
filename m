Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8146B0098
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:54:11 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Fix SLQB on memoryless configurations V3
Date: Tue, 22 Sep 2009 13:54:11 +0100
Message-Id: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Changelog since V2
  o Turned out that allocating per-cpu areas for node ids on ppc64 just
    wasn't stable. This series statically declares the per-node data. This
    wastes memory but it appears to work.

Currently SLQB is not allowed to be configured on PPC and S390 machines as
CPUs can belong to memoryless nodes. SLQB does not deal with this very well
and crashes reliably.

These patches partially fix the memoryless node problem for SLQB. The
machine will boot successfully but is unstable under stress indicating
that SLQB has some serious problems when dealing with pages from remote
nodes. The remote node stability may be linked to the per-cpu stability
problem so should be treated as separate bugs.

Patch 1 statically defines some per-node structures instead of using a fun
        hack with DEFINE_PER_CPU. The per-node areas are not always getting
        initialised by the architecture which led to a crash.

Patch 2 notes that on memoryless configurations, memory is always freed
	remotely but always allocates locally and falls back to the page
	allocator on failure. This effectively is a memory leak. This patch
	records in kmem_cache_cpu what node it considers local to be either
	the real local node or the closest node available.

Patch 3 allows SLQB to be configured on PPC again and S390. These patches
	address most of the memoryless node issues on PPC and the expectation
	is that the remaining bugs in SLQB are to do with remote nodes,
	per-cpu area allocation or both. This patch enables SLQB on S390
	as it has been reported by Heiko Carstens that issues there have
	been independently resolved.

I believe these are ready for merging although it would be preferred if
Nick signed-off.  Christoph has suggested that SLQB should be disabled for
NUMA but I feel if it's disabled, the problem may never be resolved. Hence
I didn't patch accordingly but Pekka or Nick may feel different.

 include/linux/slqb_def.h |    3 ++
 init/Kconfig             |    1 -
 mm/slqb.c                |   52 ++++++++++++++++++++++++++++-----------------
 3 files changed, 35 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
