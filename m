Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF67F6B038F
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:48:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b140so2579718wme.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:53 -0800 (PST)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id i63si3616902wmd.135.2017.03.07.07.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:48:52 -0800 (PST)
Received: by mail-wr0-f194.google.com with SMTP id g10so757955wrg.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Date: Tue,  7 Mar 2017 16:48:42 +0100
Message-Id: <20170307154843.32516-4-mhocko@kernel.org>
In-Reply-To: <20170307154843.32516-1-mhocko@kernel.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>

From: Michal Hocko <mhocko@suse.com>

KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
so it relied on the default page allocator behavior for the given set
of flags. This means that small allocations actually never failed.

Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
allocation request size we can map KM_MAYFAIL to it. The allocator will
try as hard as it can to fulfill the request but fails eventually if
the progress cannot be made.

Cc: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index ae08cfd9552a..ac80a4855c83 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -54,6 +54,16 @@ kmem_flags_convert(xfs_km_flags_t flags)
 			lflags &= ~__GFP_FS;
 	}
 
+	/*
+	 * Default page/slab allocator behavior is to retry for ever
+	 * for small allocations. We can override this behavior by using
+	 * __GFP_RETRY_MAYFAIL which will tell the allocator to retry as long
+	 * as it is feasible but rather fail than retry for ever for all
+	 * request sizes.
+	 */
+	if (flags & KM_MAYFAIL)
+		lflags |= __GFP_RETRY_MAYFAIL;
+
 	if (flags & KM_ZERO)
 		lflags |= __GFP_ZERO;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
