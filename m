Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B3BCC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA10320C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="r+8pq2FH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA10320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46FEC6B000A; Mon,  5 Aug 2019 21:48:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FC0A6B000C; Mon,  5 Aug 2019 21:48:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29DEF6B000D; Mon,  5 Aug 2019 21:48:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E281D6B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id g4so965589qkk.1
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WvV50/BsA1642B3kVRC1Mg6PgZqRAFj/+Pth1rANcxA=;
        b=UpfuQy22OW0JLWwWq4Cammyc917n2v3In/Tu9B1xfTbIA7MNBpk5YnH9xansZqCYNO
         LrEAGzQWrBmOs+JkZ+7xUNgQndNOMERFTo4J9VhfITihspT8CfElLTSKqqbkseefrYol
         95gHpnNauSFdYv8d548i0HFkk8YFF9oW+wEU91bcgRBF+DTCMkm1bPc2WK04I1ROiHHO
         6YeKpsVCbreR4rfy2eUI1WjBv1iTXKRnB5TbW8ufij0MVWTv1nxjFotQMmIZT/+1yvGR
         TKzKsTnzsTzuf7AS5aoHuQN0ZlARdTbWi6/wNgd8/vnqeaCeAw+OcnC5lB/tdVtE7Xmm
         NBOA==
X-Gm-Message-State: APjAAAVISYy1ZvYasZ2Xo/45/gd1HETNkAieOFOLFqL925qdw9uCbf+W
	U5l5sq+WibpGS5LABEvMgNGRtPhAWIM5lFmFV/paWUc+zHK2dKlVt7TZs+dBPrHMQcoQUnNNOwg
	VD2g6Zde2rXqD450oH5ehXVc5ttD8zXEFlKIUEkNs7itpSlP9vBq4KE9teTpXsm3SnQ==
X-Received: by 2002:aed:3742:: with SMTP id i60mr942251qtb.376.1565056094690;
        Mon, 05 Aug 2019 18:48:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweHTtZwQ0fCgJLwdtyq+HMLcjSWq8gnk+nlNKCcjXIXidFkHBnWZU1XbgYDiAR79C5cgY1
X-Received: by 2002:aed:3742:: with SMTP id i60mr942122qtb.376.1565056091241;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056091; cv=none;
        d=google.com; s=arc-20160816;
        b=BriIVkW32rNmCJNrn2D78GIT2GIzRbO2tB/f8LX4FIrgVxOekjcNNLyQpaGb8lpwgB
         /0KLv+hhdkXE6YGjyxv05fOc8Mw/mUEtB/eJAyysMlfEqzj/3pbEpL58v4ZMR5AQYBju
         Vt2A5uswUR2M4epT0GLXGGuhMf6HqiMmgk9XvHkJ07xfpzoiLyGEGjf6ck6K1E9j+V/N
         UjzhkPdZK8DRB7dK4qas2ul0+ljWjLfVy5iePZtZvsGhmMuDabRvOvSc2Ycx0oM7014d
         ke9ow3M7ZjxWlWqe6P8xbV9FjIIOtGfAROrb1nE+ckxx3OBqgZcGGeVBSc0AAZHtFKWJ
         6dkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WvV50/BsA1642B3kVRC1Mg6PgZqRAFj/+Pth1rANcxA=;
        b=lB7CDWJagGNIw+ge4b8OaSYQJ//VCuL7HBU/5OzeCj7NPNbhjehv5O1hZpsgZjJlzi
         RaJ+UxUq1oGWhLJR2i8XQzh236yHEEiQQ9sKdzgZQB21iLppBJRX94FQTWsi+tUp31AI
         8mtt1eyqKgITo76d0rAs1/5Zb1Ipg9oolVACTxl60N8v+g+RA49KqmLxJXIae2vylfET
         UjG1SkyQYgMJo95bQu2NMoS9QToefvoOJFhCzgMC3neuoDDFsBckYG7dG96wWwUiAg3n
         FRxvYfbBbxj2ZhTbB+IdXPLnfBPj/SkVQ6U0LhbTjeEvec11ItRQBVP4BOwYHyE/wZN9
         FUXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r+8pq2FH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o187si47711780qke.37.2019.08.05.18.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r+8pq2FH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761iAp9078264;
	Tue, 6 Aug 2019 01:48:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=WvV50/BsA1642B3kVRC1Mg6PgZqRAFj/+Pth1rANcxA=;
 b=r+8pq2FH8dpZq16OOdFBYhF3ZAl5enxyqlIZuDeucd7zEAYYbD98Gg6I8ZLzVsxriR4S
 wX4V+MeZ/v/Y62jbj0j2JBj2FKHTyLY6MAewgOybJO02N3xoJQuiu9qKI7nao42sIpMy
 FbvcSncFp1Cit1vGQoEKjASjMMuRoXTr+v6qqjFkXUwPueTZ/MteDWzYQSwd5EoWgH6V
 qNwZxuBTy7f+WIzk5vUKNt6hztBZw5Cyne7iKViGuOOuVjpHgCluoMbQDov4rr3fKPK5
 n2xrOCCfUl8y8L+C6VDusSQUxii0AKR5ulJ3XSIT4ZuXk9zkQJWlL2zpX3eRDSeFK5Zs nA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2u51ptts13-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:04 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761m4br162751;
	Tue, 6 Aug 2019 01:48:04 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2u4ycubsmd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:04 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x761lvhP025251;
	Tue, 6 Aug 2019 01:47:57 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 18:47:57 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 3/4] mm, compaction: raise compaction priority after it withdrawns
Date: Mon,  5 Aug 2019 18:47:43 -0700
Message-Id: <20190806014744.15446-4-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806014744.15446-1-mike.kravetz@oracle.com>
References: <20190806014744.15446-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060020
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060019
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>

Mike Kravetz reports that "hugetlb allocations could stall for minutes
or hours when should_compact_retry() would return true more often then
it should.  Specifically, this was in the case where compact_result was
COMPACT_DEFERRED and COMPACT_PARTIAL_SKIPPED and no progress was being
made."

The problem is that the compaction_withdrawn() test in
should_compact_retry() includes compaction outcomes that are only possible
on low compaction priority, and results in a retry without increasing the
priority. This may result in furter reclaim, and more incomplete compaction
attempts.

With this patch, compaction priority is raised when possible, or
should_compact_retry() returns false.

The COMPACT_SKIPPED result doesn't really fit together with the other
outcomes in compaction_withdrawn(), as that's a result caused by
insufficient order-0 pages, not due to low compaction priority. With this
patch, it is moved to a new compaction_needs_reclaim() function, and for
that outcome we keep the current logic of retrying if it looks like reclaim
will be able to help.

Reported-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
v2 - Commit message reformatted to avoid line wrap.  Added SOB.

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

