Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D51076B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:52:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z5so8441428pfe.16
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:52:49 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i127si604972pgc.100.2018.02.26.05.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 05:52:48 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v3 0/3] mm: improve zone->lock scalability
Date: Mon, 26 Feb 2018 21:53:43 +0800
Message-Id: <20180226135346.7208-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

Patch 1/3 is a small cleanup suggested by Matthew Wilcox which doesn't
affect scalability or performance;
Patch 2/3 moves some code in free_pcppages_bulk() outside of zone->lock
and has Mel Gorman's ack;
Patch 3/3 uses prefetch in free_pcppages_bulk() outside of zone->lock to
speedup page merging under zone->lock but Mel Gorman has some concerns.

For details, please see their changelogs.

Changes from v2:
Patch 1/3 is newly added;
Patch 2/3 is patch 1/2 in v2 and doesn't have any change except resolving
conflicts due to the newly added patch 1/3;
Patch 3/3 is patch 2/2 in v2 and only has some changelog updates on
concerns part.

v1 and v2 was here:
https://lkml.org/lkml/2018/1/23/879

Aaron Lu (3):
  mm/free_pcppages_bulk: update pcp->count inside
  mm/free_pcppages_bulk: do not hold lock when picking pages to free
  mm/free_pcppages_bulk: prefetch buddy while not holding lock

 mm/page_alloc.c | 56 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 35 insertions(+), 21 deletions(-)

-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
