Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4806B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:55:10 -0500 (EST)
Received: by wmuu63 with SMTP id u63so92945324wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:10 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id b130si26117453wmf.119.2015.11.24.03.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 03:55:09 -0800 (PST)
Received: by wmec201 with SMTP id c201so204956413wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] 2 zone_pages_reclaimable fixes
Date: Tue, 24 Nov 2015 12:54:58 +0100
Message-Id: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
Johannes had a valid point [1] that zone_pages_reclaimable should contain
isolated pages as well. This is what the first patch does. While I was
there I've realized that the current logic of this function allows for
a large overestimation of the reclaimable memory with anon >> nr_swap_pages
which would be visible especially when the swap is getting short on space.
I think this is a bug and this is fixed in the second patch.

I do not have any particular workload which would show significant misbehavior
because of the current implementation though. We mostly just happen to scan
longer than necessary because zone_reclaimable would keep us looping longer
but I still think it makes sense to fix this regardless.

[1] http://lkml.kernel.org/r/20151123182447.GF13000%40cmpxchg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
