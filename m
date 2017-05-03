Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 858886B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 19:41:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b28so610510wrb.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 16:41:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 93si427734wrq.153.2017.05.03.16.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 16:41:52 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43Nd80T113510
	for <linux-mm@kvack.org>; Wed, 3 May 2017 19:41:50 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a7rcw99wv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 May 2017 19:41:50 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 3 May 2017 19:41:50 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH] mm, vmstat: Remove spurious WARN() during zoneinfo print
Date: Wed,  3 May 2017 18:41:45 -0500
In-Reply-To: <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
Message-Id: <1493854905-10918-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

After "mm, vmstat: print non-populated zones in zoneinfo",
/proc/zoneinfo will show unpopulated zones.

A memoryless node, having no populated zones at all, was previously
ignored, but will now trigger the WARN() in is_zone_first_populated().

Remove this warning, as its only purpose was to warn of a situation that
has since been enabled.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---

Aside: The "per-node stats" are still printed under the first populated
zone, but that's not necessarily the first stanza any more. I'm not sure
which criteria is more important with regard to not breaking parsers, but 
it looks a little weird to the eye.

 mm/vmstat.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index f5fa1bd..76f7367 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1359,8 +1359,6 @@ static bool is_zone_first_populated(pg_data_t *pgdat, struct zone *zone)
 			return zone == compare;
 	}
 
-	/* The zone must be somewhere! */
-	WARN_ON_ONCE(1);
 	return false;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
