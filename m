Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C745E6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 01:27:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x7so2905753pfd.19
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 22:27:51 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b60-v6si2536498plc.830.2018.02.28.22.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 22:27:50 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v4 0/3] mm: improve zone->lock scalability
Date: Thu,  1 Mar 2018 14:28:42 +0800
Message-Id: <20180301062845.26038-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

Patch 1/3 is a small cleanup suggested by Matthew Wilcox which doesn't
affect scalability or performance;
Patch 2/3 moves some code in free_pcppages_bulk() outside of zone->lock
and has Mel Gorman's ack;
Patch 3/3 uses prefetch in free_pcppages_bulk() outside of zone->lock to
speedup page merging under zone->lock but Mel Gorman has some concerns.

For details, please see their changelogs.

v4:
Address David Rientjes' comments to not update pcp->count in front of
free_pcppages_bulk() in patch 1/3.
Reword code comments in patch 2/3 as suggested by David Rientjes.

v3:
Added patch 1/3 to update pcp->count inside of free_pcppages_bulk();
Rebase to v4.16-rc2.

v2 & v1:
https://lkml.org/lkml/2018/1/23/879

Aaron Lu (3):
  mm/free_pcppages_bulk: update pcp->count inside
  mm/free_pcppages_bulk: do not hold lock when picking pages to free
  mm/free_pcppages_bulk: prefetch buddy while not holding lock

 mm/page_alloc.c | 62 +++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 22 deletions(-)

-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
