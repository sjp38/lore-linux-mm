Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A79C56B003B
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 23:52:12 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so10825329pad.7
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 20:52:12 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id pm5si383146pbc.140.2014.04.01.20.52.10
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 20:52:11 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/1] doc, mempolicy: Fix wrong document in numa_memory_policy.txt
Date: Wed, 2 Apr 2014 11:53:02 +0800
Message-ID: <1396410782-26208-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rdunlap@infradead.org, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com, guz.fnst@cn.fujitsu.com

In document numa_memory_policy.txt, the following examples for flag
MPOL_F_RELATIVE_NODES are incorrect.

	For example, consider a task that is attached to a cpuset with
	mems 2-5 that sets an Interleave policy over the same set with
	MPOL_F_RELATIVE_NODES.  If the cpuset's mems change to 3-7, the
	interleave now occurs over nodes 3,5-6.  If the cpuset's mems
	then change to 0,2-3,5, then the interleave occurs over nodes
	0,3,5.

According to the comment of the patch adding flag MPOL_F_RELATIVE_NODES,
the nodemasks the user specifies should be considered relative to the
current task's mems_allowed.
(https://lkml.org/lkml/2008/2/29/428)

And according to numa_memory_policy.txt, if the user's nodemask includes
nodes that are outside the range of the new set of allowed nodes, then
the remap wraps around to the beginning of the nodemask and, if not already
set, sets the node in the mempolicy nodemask.

So in the example, if the user specifies 2-5, for a task whose mems_allowed
is 3-7, the nodemasks should be remapped the third, fourth, fifth, sixth
node in mems_allowed.  like the following:

	mems_allowed:       3  4  5  6  7

	relative index:     0  1  2  3  4
	                    5

So the nodemasks should be remapped to 3,5-7, but not 3,5-6.

And for a task whose mems_allowed is 0,2-3,5, the nodemasks should be
remapped to 0,2-3,5, but not 0,3,5.

	mems_allowed:       0  2  3  5

        relative index:     0  1  2  3
                            4  5


Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 Documentation/vm/numa_memory_policy.txt | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/numa_memory_policy.txt b/Documentation/vm/numa_memory_policy.txt
index 4e7da65..badb050 100644
--- a/Documentation/vm/numa_memory_policy.txt
+++ b/Documentation/vm/numa_memory_policy.txt
@@ -174,7 +174,6 @@ Components of Memory Policies
 	allocation fails, the kernel will search other nodes, in order of
 	increasing distance from the preferred node based on information
 	provided by the platform firmware.
-	containing the cpu where the allocation takes place.
 
 	    Internally, the Preferred policy uses a single node--the
 	    preferred_node member of struct mempolicy.  When the internal
@@ -275,9 +274,9 @@ Components of Memory Policies
 	    For example, consider a task that is attached to a cpuset with
 	    mems 2-5 that sets an Interleave policy over the same set with
 	    MPOL_F_RELATIVE_NODES.  If the cpuset's mems change to 3-7, the
-	    interleave now occurs over nodes 3,5-6.  If the cpuset's mems
+	    interleave now occurs over nodes 3,5-7.  If the cpuset's mems
 	    then change to 0,2-3,5, then the interleave occurs over nodes
-	    0,3,5.
+	    0,2-3,5.
 
 	    Thanks to the consistent remapping, applications preparing
 	    nodemasks to specify memory policies using this flag should
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
