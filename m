Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E48596B03B2
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:54:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so10944224wrd.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:00 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id y186si3320264wmy.130.2017.06.23.01.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:53:59 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id 77so10857469wrb.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:53:59 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Date: Fri, 23 Jun 2017 10:53:42 +0200
Message-Id: <20170623085345.11304-4-mhocko@kernel.org>
In-Reply-To: <20170623085345.11304-1-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

From: Michal Hocko <mhocko@suse.com>

KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
so it relied on the default page allocator behavior for the given set
of flags. This means that small allocations actually never failed.

Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
allocation request size we can map KM_MAYFAIL to it. The allocator will
try as hard as it can to fulfill the request but fails eventually if
the progress cannot be made. It does so without triggering the OOM
killer which can be seen as an improvement because KM_MAYFAIL users
should be able to deal with allocation failures.

Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index d6ea520162b2..4d85992d75b2 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -54,6 +54,16 @@ kmem_flags_convert(xfs_km_flags_t flags)
 			lflags &= ~__GFP_FS;
 	}
 
+	/*
+	 * Default page/slab allocator behavior is to retry for ever
+	 * for small allocations. We can override this behavior by using
+	 * __GFP_RETRY_MAYFAIL which will tell the allocator to retry as long
+	 * as it is feasible but rather fail than retry forever for all
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
