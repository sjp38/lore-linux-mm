Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6A28C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D7372184E
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:10:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7372184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF508E00B8; Wed,  6 Feb 2019 07:10:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 285688E00B6; Wed,  6 Feb 2019 07:10:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14D898E00B8; Wed,  6 Feb 2019 07:10:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C341B8E00B6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:10:41 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a9so4778663pla.2
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:10:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=ejrM/R9eeplk9uFxz2XWIrvDnzfU1UrbJSgB2j/O9l0=;
        b=kxxina+P0EQ1yH1D7SesBg8OWnMJhauh1IqQLCNulr1/UvgrVxuxnAtomg0ikVGzcG
         xTX9xe5XjJnQ21UXXjkpDL1VHuGNLD+y4J43z4vuKQVwasJpGK2G3hr64N7a58IVP+Ap
         Q7RokaN+uatYJWvdRKq5W8whWTbFffapSW+URXOWfBGwYZ637MR0hmHA0MDE/RDs7WMt
         Fm79ks0gCiKgxbVFiprMT+I88aWzX1JX6J2HSRe64Iihru8YYeiow4risCBCxgbxI1uB
         lYQc4HLK60HNMb/SqtWPYI7btR2aj2VRdfWm9mdgPAWufR3kyBRSLtC/RVhzKIPBRyhg
         SZHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYsND16CfqfpGvN6Y+wIwzUsA/9M7CMLlIPQJV47gXqmNRhR+K6
	eZvk03ahUdlNg/CFIXou7H+zFbOuU65AHHnZD5dp3pir3FKi6gWiC9cl9fTd+rSNDlgDuKH9gZm
	i5ul9qRqKjwIKjsP97sO3W5NYoTkvSBgLdVcZiKw8GtKjwjWKAnKlZybavKhjITEjEQ==
X-Received: by 2002:a17:902:bcc7:: with SMTP id o7mr10522690pls.281.1549455041386;
        Wed, 06 Feb 2019 04:10:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibdam0y14M1ERNMvnscEomxEbZCaZv6J1V4/8CdzUdLsd2BMYT2DjtoxMTGpVrQIhglJWFB
X-Received: by 2002:a17:902:bcc7:: with SMTP id o7mr10522609pls.281.1549455040445;
        Wed, 06 Feb 2019 04:10:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455040; cv=none;
        d=google.com; s=arc-20160816;
        b=z2Ht8CMGIbQGBBE/L9RjB1lwYSlRb8ZzGE3jltCqMxmskfbda7fJI8AuGrQNauYtGt
         RfYSkU+9/RUkVNVx5eA1EG/zQ1oLMBZ5YTibKD4RhZDqmraKg9Ffv3LIDMPPu1FyYP7x
         asuFBn32d+sq3h3lMKfB9KaCxN2KqIQU1RawcfvyTUbNxMbU9LI+UnFYFL7V480jXKJh
         69OmRvUY8rBHGfhMTLe1dBC4q0pToorLWaqCqag5cNWQW0fGB4oIF1tTjV11iUdKW3c0
         Waf1VGIHu1oRhqQYu3MPgXPZ6aIxsS1qjdycCc2K26KoKxP2DJdxfvEiq9Jqhi7z8y4E
         WqDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=ejrM/R9eeplk9uFxz2XWIrvDnzfU1UrbJSgB2j/O9l0=;
        b=PwETZaCXOYwPDO+eIc7jVwzHx5P1wNXZsmjVEHvCvykTKAbK4iVVmL/z6A2we/KcVh
         QJk+nmZO22drJz/Jk7SpKhnSomMf7u3Q1DXTdqRYjWfpFHjz4GIiXGykFpKbIUUc63qt
         G3jG4LVs9daNbFrXc5tksJVjaDroE2MPG0FnOp5O6o6JMVZx6wFBGcAmF4dnW+tZcuLP
         xYFMp2GLvU6t8tqhAOl8BDJKJ8hDAleAVm7BeMqlOB9GEzEtG9g/uQzCkn/nqumrYc5y
         9zqGmykuPBqi3zI0Ohi23Nct6Qf1CP1L67o19hHHYLbu2yaMWIUF647HNKpeaYqzEfbs
         8KUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5si5665551plo.422.2019.02.06.04.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:10:40 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x16C5MJR132272
	for <linux-mm@kvack.org>; Wed, 6 Feb 2019 07:10:39 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qfxsm245x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:10:39 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 6 Feb 2019 12:10:36 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Feb 2019 12:10:34 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x16CAX7C8913254
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 6 Feb 2019 12:10:33 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E72A44204F;
	Wed,  6 Feb 2019 12:10:32 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 80CD042070;
	Wed,  6 Feb 2019 12:10:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  6 Feb 2019 12:10:31 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 06 Feb 2019 14:10:30 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/2] memblock: split checks whether a region should be skipped to a helper function
Date: Wed,  6 Feb 2019 14:10:25 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
References: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19020612-0016-0000-0000-000002531D6C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020612-0017-0000-0000-000032AD2650
Message-Id: <1549455025-17706-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-06_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902060096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The __next_mem_range() and __next_mem_range_rev() duplucate the code that
checks whether a region should be skipped because of node or flags
incompatibility.

Split this code into a helper function.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/memblock.c | 53 +++++++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 28 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index af5fe8e..f87d3ae 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -958,6 +958,29 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
 	*idx = ULLONG_MAX;
 }
 
+static bool should_skip_region(struct memblock_region *m, int nid, int flags)
+{
+	int m_nid = memblock_get_region_node(m);
+
+	/* only memory regions are associated with nodes, check it */
+	if (nid != NUMA_NO_NODE && nid != m_nid)
+		return true;
+
+	/* skip hotpluggable memory regions if needed */
+	if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
+		return true;
+
+	/* if we want mirror memory skip non-mirror memory regions */
+	if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
+		return true;
+
+	/* skip nomap memory unless we were asked for it explicitly */
+	if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
+		return true;
+
+	return false;
+}
+
 /**
  * __next__mem_range - next function for for_each_free_mem_range() etc.
  * @idx: pointer to u64 loop variable
@@ -1005,20 +1028,7 @@ void __init_memblock __next_mem_range(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 		int	    m_nid = memblock_get_region_node(m);
 
-		/* only memory regions are associated with nodes, check it */
-		if (nid != NUMA_NO_NODE && nid != m_nid)
-			continue;
-
-		/* skip hotpluggable memory regions if needed */
-		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
-			continue;
-
-		/* if we want mirror memory skip non-mirror memory regions */
-		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
-			continue;
-
-		/* skip nomap memory unless we were asked for it explicitly */
-		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
+		if (should_skip_region(m, nid, flags))
 			continue;
 
 		if (!type_b) {
@@ -1122,20 +1132,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 		int m_nid = memblock_get_region_node(m);
 
-		/* only memory regions are associated with nodes, check it */
-		if (nid != NUMA_NO_NODE && nid != m_nid)
-			continue;
-
-		/* skip hotpluggable memory regions if needed */
-		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
-			continue;
-
-		/* if we want mirror memory skip non-mirror memory regions */
-		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
-			continue;
-
-		/* skip nomap memory unless we were asked for it explicitly */
-		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
+		if (should_skip_region(m, nid, flags))
 			continue;
 
 		if (!type_b) {
-- 
2.7.4

