Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 787576B0008
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:00:13 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q12-v6so18037574plr.17
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:00:13 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u10si5748859pgr.221.2018.04.05.12.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:00:12 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 4/4] mm/docs: describe memory.low refinements
Date: Thu, 5 Apr 2018 19:59:21 +0100
Message-ID: <20180405185921.4942-4-guro@fb.com>
In-Reply-To: <20180405185921.4942-1-guro@fb.com>
References: <20180405185921.4942-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org

Refine cgroup v2 docs after latest memory.low changes.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-doc@vger.kernel.org
---
 Documentation/cgroup-v2.txt | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index f728e55602b2..7ee462b8a6ac 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1006,10 +1006,17 @@ PAGE_SIZE multiple when read back.
 	A read-write single value file which exists on non-root
 	cgroups.  The default is "0".
 
-	Best-effort memory protection.  If the memory usages of a
-	cgroup and all its ancestors are below their low boundaries,
-	the cgroup's memory won't be reclaimed unless memory can be
-	reclaimed from unprotected cgroups.
+	Best-effort memory protection.  If the memory usage of a
+	cgroup is within its effective low boundary, the cgroup's
+	memory won't be reclaimed unless memory can be reclaimed
+	from unprotected cgroups.
+
+	Effective low boundary is limited by memory.low values of
+	all ancestor cgroups. If there is memory.low overcommitment
+	(child cgroup or cgroups are requiring more protected memory,
+	than parent will allow), then each child cgroup will get
+	the part of parent's protection proportional to the its
+	actual memory usage below memory.low.
 
 	Putting more memory than generally available under this
 	protection is discouraged.
@@ -2008,17 +2015,8 @@ system performance due to overreclaim, to the point where the feature
 becomes self-defeating.
 
 The memory.low boundary on the other hand is a top-down allocated
-reserve.  A cgroup enjoys reclaim protection when it and all its
-ancestors are below their low boundaries, which makes delegation of
-subtrees possible.  Secondly, new cgroups have no reserve per default
-and in the common case most cgroups are eligible for the preferred
-reclaim pass.  This allows the new low boundary to be efficiently
-implemented with just a minor addition to the generic reclaim code,
-without the need for out-of-band data structures and reclaim passes.
-Because the generic reclaim code considers all cgroups except for the
-ones running low in the preferred first reclaim pass, overreclaim of
-individual groups is eliminated as well, resulting in much better
-overall workload performance.
+reserve.  A cgroup enjoys reclaim protection when it's within its low,
+which makes delegation of subtrees possible.
 
 The original high boundary, the hard limit, is defined as a strict
 limit that can not budge, even if the OOM killer has to be called.
-- 
2.14.3
