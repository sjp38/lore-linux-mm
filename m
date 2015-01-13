Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EC6946B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:02:48 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so4790361wgh.6
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:02:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wp8si43400927wjc.125.2015.01.13.11.02.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 11:02:47 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: default hierarchy interface for memory fix
Date: Tue, 13 Jan 2015 14:02:39 -0500
Message-Id: <1421175759-14350-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Document and rationalize where the default hierarchy interface differs
from the traditional memory cgroups interface.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/unified-hierarchy.txt | 80 +++++++++++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 4f4563277864..643af9bb9a07 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -327,6 +327,86 @@ supported and the interface files "release_agent" and
 - use_hierarchy is on by default and the cgroup file for the flag is
   not created.
 
+- The original lower boundary, the soft limit, is defined as a limit
+  that is per default unset.  As a result, the set of cgroups that
+  global reclaim prefers is opt-in, rather than opt-out.  The costs
+  for optimizing these mostly negative lookups are so high that the
+  implementation, despite its enormous size, does not even provide the
+  basic desirable behavior.  First off, the soft limit has no
+  hierarchical meaning.  All configured groups are organized in a
+  global rbtree and treated like equal peers, regardless where they
+  are located in the hierarchy.  This makes subtree delegation
+  impossible.  Second, the soft limit reclaim pass is so aggressive
+  that it not just introduces high allocation latencies into the
+  system, but also impacts system performance due to overreclaim, to
+  the point where the feature becomes self-defeating.
+
+  The memory.low boundary on the other hand is a top-down allocated
+  reserve.  A cgroup enjoys reclaim protection when it and all its
+  ancestors are below their low boundaries, which makes delegation of
+  subtrees possible.  Secondly, new cgroups have no reserve per
+  default and in the common case most cgroups are eligible for the
+  preferred reclaim pass.  This allows the new low boundary to be
+  efficiently implemented with just a minor addition to the generic
+  reclaim code, without the need for out-of-band data structures and
+  reclaim passes.  Because the generic reclaim code considers all
+  cgroups except for the ones running low in the preferred first
+  reclaim pass, overreclaim of individual groups is eliminated as
+  well, resulting in much better overall workload performance.
+
+- The original high boundary, the hard limit, is defined as a strict
+  limit that can not budge, even if the OOM killer has to be called.
+  But this generally goes against the goal of making the most out of
+  the available memory.  The memory consumption of workloads varies
+  during runtime, and that requires users to overcommit.  But doing
+  that with a strict upper limit requires either a fairly accurate
+  prediction of the working set size or adding slack to the limit.
+  Since working set size estimation is hard and error prone, and
+  getting it wrong results in OOM kills, most users tend to err on the
+  side of a looser limit and end up wasting precious resources.
+
+  The memory.high boundary on the other hand can be set much more
+  conservatively.  When hit, it throttles allocations by forcing them
+  into direct reclaim to work off the excess, but it never invokes the
+  OOM killer.  As a result, a high boundary that is chosen too
+  aggressively will not terminate the processes, but instead it will
+  lead to gradual performance degradation.  The user can monitor this
+  and make corrections until the minimal memory footprint that still
+  gives acceptable performance is found.
+
+  In extreme cases, with many concurrent allocations and a complete
+  breakdown of reclaim progress within the group, the high boundary
+  can be exceeded.  But even then it's mostly better to satisfy the
+  allocation from the slack available in other groups or the rest of
+  the system than killing the group.  Otherwise, memory.max is there
+  to limit this type of spillover and ultimately contain buggy or even
+  malicious applications.
+
+- The original control file names are unwieldy and inconsistent in
+  many different ways.  For example, the upper boundary hit count is
+  exported in the memory.failcnt file, but an OOM event count has to
+  be manually counted by listening to memory.oom_control events, and
+  lower boundary / soft limit events have to be counted by first
+  setting a threshold for that value and then counting those events.
+  Also, usage and limit files encode their units in the filename.
+  That makes the filenames very long, even though this is not
+  information that a user needs to be reminded of every time they type
+  out those names.
+
+  To address these naming issues, as well as to signal clearly that
+  the new interface carries a new configuration model, the naming
+  conventions in it necessarily differ from the old interface.
+
+- The original limit files indicate the state of an unset limit with a
+  Very High Number, and a configured limit can be unset by echoing -1
+  into those files.  But that very high number is implementation and
+  architecture dependent and not very descriptive.  And while -1 can
+  be understood as an underflow into the highest possible value, -2 or
+  -10M etc. do not work, so it's not consistent.
+
+  memory.low and memory.high will indicate "none" if the boundary is
+  not configured, and a configured boundary can be unset by writing
+  "none" into these files as well.
 
 5. Planned Changes
 
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
