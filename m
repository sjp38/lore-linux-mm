Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9126B00E8
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 15:34:13 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/3] Hatchet job for SLQB on memoryless configurations
Date: Fri, 18 Sep 2009 20:34:08 +0100
Message-Id: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Currently SLQB is not allowed to be configured on PPC and S390 machines as
CPUs can belong to memoryless nodes. SLQB does not deal with this very well
and crashes reliably.

This patch partially fixes the problem on at least one machine and allows
SLQB to boot although I'm not sure if it's actually stable. It's doubtful
this is the solution even in the short-term. This is a hatchet job due to
my lack of familiarity with SLQB. While SLQB is handy to get to grips with,
someone more familiar may be able to identify a proper fix faster assuming
this helps point the direction of the real problem.

Patch 1 statically defines some per-node structures instead of using a fun
	hack with DEFINE_PER_CPU. The problem was that the per-node structures
	appeared to be getting corrupted (different values each boot on
	struct fields, particularly the lock), possibly because the active
	node IDs are higher than the highest CPU id. It's not known why
	this is a problem at the moment and could do with further explanation.

Patch 2 noticed that on memoryless nodes, slab objects always gets freed to
	the remote list while the allocation side always looked at the per-cpu
	lists. Lists grew in an unbounded fashion and the machine OOM'd. This
	patch checks if the remote page is being freed to a memoryless node
	and if so, the page is treated as if it's local. This needs further
	thinking from someone familiar with SLQB.

Patch 3 allows SLQB to be configured on PPC and S390 again.

This patchset is not intended for merging. It's to help point out where the
real problems might be so a proper fix can be hashed out.

 init/Kconfig |    1 -
 mm/slqb.c    |   23 +++++++++++++----------
 2 files changed, 13 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
