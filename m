Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B43CE6B006C
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:49:41 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so4589657wiv.0
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:49:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si364669wia.2.2014.10.02.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:49:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] Single zone pcpclists drain
Date: Thu,  2 Oct 2014 17:48:56 +0200
Message-Id: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Xishi Qiu <qiuxishi@huawei.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This small series is an optimization of pcplists draining. In many cases, it
is sufficient to drain pcplists of a single zone, and draining all zones is
a waste of cycles, and then it results in more pcplists refilling.

Patch 1 introduces "struct zone *" parameter to drain_local_pages() and
drain_all_pages(), where NULL value means that all zones are drained as usual.
Remaining patches convert existing callers to single zone drain where
appropriate. One might wonder why compaction is not touched, and the answer
is that it will be posted later, as it's a larger change.

Vlastimil Babka (4):
  mm: introduce single zone pcplists drain
  mm, page_isolation: drain single zone pcplists
  mm, cma: drain single zone pcplists
  mm, memory_hotplug/failure: drain single zone pcplists

 include/linux/gfp.h |  4 +--
 mm/memory-failure.c |  4 +--
 mm/memory_hotplug.c |  4 +--
 mm/page_alloc.c     | 81 ++++++++++++++++++++++++++++++++++++-----------------
 mm/page_isolation.c |  2 +-
 5 files changed, 63 insertions(+), 32 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
