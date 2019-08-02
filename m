Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B55EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D426E2067D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m1L2JM/O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D426E2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60BAD6B0006; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 594816B0008; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4351A6B000A; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEFA6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so66007068qkd.5
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:39:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TC+FvVGBj7qXtMenbMrq0locSq4RPx9eaTkqkGiQRPY=;
        b=Ta7ThbuaqGPexhGCB89g9KbbaqYq/ir8C+clomXr2m25GwFxMyF38eA/VBaqmGyLmu
         26I8BlzAqfoIIxIjrpsIvvhkrWu361MYKPmSDhSnVnOmbmvsIIJMXHNhNYywVQDSAMTv
         3y6oQndUMSvsIjvTCGgQ7ZTxBBmlwCskFOwUJaLHS4faWXQf8w58+VMYdxM/RUw8Hciv
         vxui5/1jD+p/qyjt3iRJ+UmjmkfTjKnACP9li3u2y+KxQlLR5aqwwgrzLZI0DJJoo35d
         ESanHkKEWTVI8Ferz1ABdszsrY1QK9Utlh5otsXqWeudrdomnmM9gMGylScyUYu98tR8
         TGsQ==
X-Gm-Message-State: APjAAAUEhmITliAtMYAoj7sGXuY6NdB1I/YsAkwneACwyg+aycEgtl36
	IMfUSYxZ1ycIpAfvnBUtjoEcz19x31VVZ4uiNxOoziPZBPzJx76G+Ksi0NL3grppk48GfU8dhXf
	iM7OKUNjDT0IxxhDn+IBKBYYfKXIn/jXi+YZS6J8cLBqinlyPPY6IUVsQyrV2u0zgSA==
X-Received: by 2002:a37:a5cb:: with SMTP id o194mr95030267qke.371.1564785588843;
        Fri, 02 Aug 2019 15:39:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZYz4sfelj2ZRcXkYUlji8Jdc5wqCXYZSsusSvQFUgz/rHTPjP/MhxnUUNqAT2LSaBHElV
X-Received: by 2002:a37:a5cb:: with SMTP id o194mr95030239qke.371.1564785588159;
        Fri, 02 Aug 2019 15:39:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564785588; cv=none;
        d=google.com; s=arc-20160816;
        b=N7h7B5Ool38biKkszmy0U+LMyKrpjn5livctMXN2qb6rLOSB/ajTBdMlsHS9Ybf+KU
         0KCamKE9gCWbatq7mDBVaoJlkAuR6r95g0wBalKZkCUevBKI/ExkJdh8tU+6NrcBEKnu
         +ShVR78L2F1hbvC4d/iia6uvlhf62WE5gsQC1W9tcetwu1/LdHhwyRQbDeo92aVbu8EX
         j4BfGwCOJgTKWg/3CHjfvTXU/iO8GXMGMqZ84/dAoZpn5SotB3hxPqfTBKKnpVSww2ZF
         y3AHitdmR04ZmE4bNGqEzdI6XBK8Yqvan6zOxChh+EbYy6nj/eBwatcIpuo2igtF9Fhg
         2rHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TC+FvVGBj7qXtMenbMrq0locSq4RPx9eaTkqkGiQRPY=;
        b=YORKEjETc6POSuHqZSvbc433Gs6qiwGMdc2uwLg7tCpvbeXYpp9dzYm5Ea8pf/AVDE
         2R8Q71p21xiLqkLfGlrd/qBx0FExulMvVyHWBuDB8sx4EZmxZwcdA5JxZEAaSIqVGi/r
         7auUe2jaG4VnNbfMHycmQP0yMPBUt5srhcSPc7BTL8i/MF6u00zFvQ5w7guziHH0awpe
         ju7dO0owv3TtZ3pTxnGPvac/7/ea9uf/Q3S2dbMMeNJUJwAc6dJNK0K7KwuaQbVjTmuA
         vu1QRjAe7eJOnc3kmlK+nAftno400Xlr7lXMfUps8b8HUFs18w1Z14DP5ul21+94Kp1L
         FdNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="m1L2JM/O";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 7si40464324qtw.230.2019.08.02.15.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 15:39:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="m1L2JM/O";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72McvgT004454;
	Fri, 2 Aug 2019 22:39:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=TC+FvVGBj7qXtMenbMrq0locSq4RPx9eaTkqkGiQRPY=;
 b=m1L2JM/OMDW2n0WfQFY3LPGcIeqtXCva5LDPlsHXHDdJuc/MVSopGE/PoYJsSYbxUDjy
 jxnR4Gd1UZcJMjvsEnaYYKKqWE4LhYV2UDumzIkrEK3XmtjQ4mTB8ArgbaEi1WcbPHk8
 sl0k930q2/W7pWSlZpfy+dzLe+LjQl+OBzDc8W6dsZbA/uBf1KvsD3PpYB3k+k+0ytlt
 Sg2ok6ekSZJ4nMoRKfg+1ynJEzeDbmr045oVsVjJBm4UhH4Koik3et1pQuppKrSU41JB
 Dp3fqD5KpB3m//DdkKvtjhdNw+HHiJ/d9UX6k6dyHGdRw2P67qer4H0rQ3ium0NXtf0+ kQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u0ejq4qt3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:42 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72MbhOw062691;
	Fri, 2 Aug 2019 22:39:42 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2u4vsj1upr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:42 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x72Mdd7M022130;
	Fri, 2 Aug 2019 22:39:39 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 15:39:39 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/3] mm, compaction: raise compaction priority after it withdrawns
Date: Fri,  2 Aug 2019 15:39:29 -0700
Message-Id: <20190802223930.30971-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190802223930.30971-1-mike.kravetz@oracle.com>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020238
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020238
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>

Mike Kravetz reports that "hugetlb allocations could stall for minutes or hours
when should_compact_retry() would return true more often then it should.
Specifically, this was in the case where compact_result was COMPACT_DEFERRED
and COMPACT_PARTIAL_SKIPPED and no progress was being made."

The problem is that the compaction_withdrawn() test in should_compact_retry()
includes compaction outcomes that are only possible on low compaction priority,
and results in a retry without increasing the priority. This may result in
furter reclaim, and more incomplete compaction attempts.

With this patch, compaction priority is raised when possible, or
should_compact_retry() returns false.

The COMPACT_SKIPPED result doesn't really fit together with the other outcomes
in compaction_withdrawn(), as that's a result caused by insufficient order-0
pages, not due to low compaction priority. With this patch, it is moved to
a new compaction_needs_reclaim() function, and for that outcome we keep the
current logic of retrying if it looks like reclaim will be able to help.

Reported-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/compaction.h | 22 +++++++++++++++++-----
 mm/page_alloc.c            | 16 ++++++++++++----
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..4b898cdbdf05 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -129,11 +129,8 @@ static inline bool compaction_failed(enum compact_result result)
 	return false;
 }
 
-/*
- * Compaction  has backed off for some reason. It might be throttling or
- * lock contention. Retrying is still worthwhile.
- */
-static inline bool compaction_withdrawn(enum compact_result result)
+/* Compaction needs reclaim to be performed first, so it can continue. */
+static inline bool compaction_needs_reclaim(enum compact_result result)
 {
 	/*
 	 * Compaction backed off due to watermark checks for order-0
@@ -142,6 +139,16 @@ static inline bool compaction_withdrawn(enum compact_result result)
 	if (result == COMPACT_SKIPPED)
 		return true;
 
+	return false;
+}
+
+/*
+ * Compaction has backed off for some reason after doing some work or none
+ * at all. It might be throttling or lock contention. Retrying might be still
+ * worthwhile, but with a higher priority if allowed.
+ */
+static inline bool compaction_withdrawn(enum compact_result result)
+{
 	/*
 	 * If compaction is deferred for high-order allocations, it is
 	 * because sync compaction recently failed. If this is the case
@@ -207,6 +214,11 @@ static inline bool compaction_failed(enum compact_result result)
 	return false;
 }
 
+static inline bool compaction_needs_reclaim(enum compact_result result)
+{
+	return false;
+}
+
 static inline bool compaction_withdrawn(enum compact_result result)
 {
 	return true;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d3bb601c461b..af29c05e23aa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3965,15 +3965,23 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (compaction_failed(compact_result))
 		goto check_priority;
 
+	/*
+	 * compaction was skipped because there are not enough order-0 pages
+	 * to work with, so we retry only if it looks like reclaim can help.
+	 */
+	if (compaction_needs_reclaim(compact_result)) {
+		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
+		goto out;
+	}
+
 	/*
 	 * make sure the compaction wasn't deferred or didn't bail out early
 	 * due to locks contention before we declare that we should give up.
-	 * But do not retry if the given zonelist is not suitable for
-	 * compaction.
+	 * But the next retry should use a higher priority if allowed, so
+	 * we don't just keep bailing out endlessly.
 	 */
 	if (compaction_withdrawn(compact_result)) {
-		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
-		goto out;
+		goto check_priority;
 	}
 
 	/*
-- 
2.20.1

