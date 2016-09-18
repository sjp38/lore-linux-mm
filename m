Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADFF26B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 07:30:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so19573369lff.0
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 04:30:23 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id h199si6192764lfg.7.2016.09.18.04.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 04:30:21 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l131so6990770lfl.0
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 04:30:21 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH] mm/mempolicy.c: forbid static or relative flags for local NUMA mode
Date: Sun, 18 Sep 2016 13:29:43 +0200
Message-Id: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kwapulinski.piotr@gmail.com

The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
Return the "invalid argument" from set_mempolicy whenever
any of these flags is passed along with MPOL_LOCAL.
It is consistent with MPOL_PREFERRED passed with empty nodemask.
It also slightly shortens the execution time in paths where these flags
are used e.g. when trying to rebind the NUMA nodes for changes in
cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
the mempolicy structure (/proc/PID/numa_maps).
Isolated tests done.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 mm/mempolicy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2da72a5..27b07d1 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -276,7 +276,9 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 				return ERR_PTR(-EINVAL);
 		}
 	} else if (mode == MPOL_LOCAL) {
-		if (!nodes_empty(*nodes))
+		if (!nodes_empty(*nodes) ||
+		    (flags & MPOL_F_STATIC_NODES) ||
+		    (flags & MPOL_F_RELATIVE_NODES))
 			return ERR_PTR(-EINVAL);
 		mode = MPOL_PREFERRED;
 	} else if (nodes_empty(*nodes))
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
