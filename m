Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 793916B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 07:32:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c74so22889149wme.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:34 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id t19si17962186wmt.106.2016.06.06.04.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 04:32:30 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id m124so14617357wme.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Date: Mon,  6 Jun 2016 13:32:16 +0200
Message-Id: <1465212736-14637-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
so it relied on the default page allocator behavior for the given set
of flags. This means that small allocations actually never failed.

Now that we have __GFP_RETRY_HARD flags which works independently on the
allocation request size we can map KM_MAYFAIL to it. The allocator will
try as hard as it can to fulfill the request but fails eventually if
the progress cannot be made.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index 689f746224e7..34e6b062ce0e 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -54,6 +54,9 @@ kmem_flags_convert(xfs_km_flags_t flags)
 			lflags &= ~__GFP_FS;
 	}
 
+	if (flags & KM_MAYFAIL)
+		lflags |= __GFP_RETRY_HARD;
+
 	if (flags & KM_ZERO)
 		lflags |= __GFP_ZERO;
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
