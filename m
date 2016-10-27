Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8090B6B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 12:31:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b75so10582543lfg.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 09:31:10 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id g37si5211928ljg.40.2016.10.27.09.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 09:31:08 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id i187so1566999lfe.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 09:31:08 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v3 0/1] mm/mempolicy.c: forbid static or relative flags for local NUMA mode
Date: Thu, 27 Oct 2016 18:30:37 +0200
Message-Id: <20161027163037.4089-1-kwapulinski.piotr@gmail.com>
In-Reply-To: <20160927132532.12110-1-kwapulinski.piotr@gmail.com>
References: <20160927132532.12110-1-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@suse.com, liangchen.linux@gmail.com, mgorman@techsingularity.net, dave.hansen@linux.intel.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kwapulinski.piotr@gmail.com

The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy
or mbind.
Return the "invalid argument" from set_mempolicy and mbind whenever
any of these flags is passed along with MPOL_LOCAL.
It is consistent with MPOL_PREFERRED passed with empty nodemask.
It slightly shortens the execution time in paths where these flags
are used e.g. when trying to rebind the NUMA nodes for changes in
cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
the mempolicy structure (/proc/PID/numa_maps).
Isolated tests done.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
Changes since V2:
Information from Documentation/vm/numa_memory_policy.txt removed.
Please let me know what else I should do to let this patch to be
accepted.
---
 mm/mempolicy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b859af..266893e 100644
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
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
