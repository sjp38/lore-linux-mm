Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F10F3C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5521321773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:32:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5521321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9F2A8E0011; Tue, 12 Feb 2019 04:32:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C283D8E0008; Tue, 12 Feb 2019 04:32:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC9278E0011; Tue, 12 Feb 2019 04:32:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6614F8E0008
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:32:47 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so1748679plp.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:32:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ap3x9QxJYzvusgBi+s1HI/tEQk7C8VZLszd7/QSbDrM=;
        b=Qbl+kdLOuZt04ikzZlwotMhGMh6pMgnEm61SVZPTbmc2vUWHhdgSqE14IJ6j08drOa
         0Z7ZCMO7xmYNAvDD9byfBiv5z6Q2/vabhkwZVtkZ8RaJRigGSmBo+s6tjMiVsQjn1NW8
         memKVFk/p4AdLBUHSS1JBzXXn2FtNnf5ssPSr791MH+kzd/fIdQq7vQjCyTz+MpQjr1+
         6949QCowRFYJSaCkPlJByqK1Gnop2eYuDVnRUyE9jOalLs1JSADnu3mrm6R/LFgIxPWQ
         7czDdWtSvW6XNkpilX42ZYN+eHy2L7HfCrVEjzuk8Ec66vNQ7RU9YYStQRUY9JW+vtVg
         I40Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYLBkfXwIA8KWoXLIZxa6AJysVybftT/XQ4UAUh5oXSFwgzelAX
	ii51lvTmKSc/VZGGsRlTUMynkNZTELUVKSbObfbvXSgpIWTZujZltihbwxjVtaCFxifcHChXtwy
	eTvEO6FJ5LF3QUuL95aQHoEYAUXUG12s7U+rZbfbaxLNPSJ0OvkGDv22JB+rX9UUqhQ==
X-Received: by 2002:a63:c946:: with SMTP id y6mr2789774pgg.109.1549963966997;
        Tue, 12 Feb 2019 01:32:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZnIrBLzEDiAgOkXxhpKr6Rqh7+nNMplvMZnZWcqQmJNKBRh+Hm5U/S+wQE2I+TxTorwUfY
X-Received: by 2002:a63:c946:: with SMTP id y6mr2789712pgg.109.1549963966052;
        Tue, 12 Feb 2019 01:32:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549963966; cv=none;
        d=google.com; s=arc-20160816;
        b=lZNLKgEtG6GSZeRPWEtlhYz3tuL2kJJ77n5q5BrRwA3NGAjkWqh9bUdj8KIbNJtCK1
         lk+Z5VVzyzNlwheiZPevaxwN6yqmOGsxFTtzEx3diMKvipJp9tqKJ0zs5VfJ2NCDTyFT
         bOA9hOC1rKFRVewIDvHUd4v32jAJ7jpsVrd1CHJvUg12UVIxO/Qg+Mw31TGisVw8yxpx
         et3M/lVy7a35V0+qn9hgxNOrA6xZyFkNI8fcWcZVx/zO8iwrsa2nWTgfLIx5kpMcAK3H
         KkpHzvNwOMEYUg2aaEQXavRECgOncIxf4ziANTqCZ/t4GA8ovNdrdRfa95hSCloQjdtW
         WBSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ap3x9QxJYzvusgBi+s1HI/tEQk7C8VZLszd7/QSbDrM=;
        b=sUycsJbvj/Wc1vAD5TEUnN/usWCKJPfi54wxnhr4EIjRcwjNCDub4e27uV17WqyX/Z
         3EPoIjb0MhJ0QKw8dBHrtP+BTpwcblVT2kfkVRLLFlzQ7rvZeX9VCDjd3WZDm8G85+Tn
         NIqaq4y3WZSdTQGHcU/KL1fYX0C4oHGSviR4l0zsVyn6OcZc7ruQG6cSbnSEHqZ0s9oA
         f2yWJG9WCCLDfhS0KRAyOgL7hlUC8KWNIhWxA8iSjdJ7NYpDeD2n5XfqvB4TBcZen7Dx
         mQcAUUyBN7ovNCqZACr3YEosgQOuq0RVv/Tqzhx1VRe22fGzbA3A9c/cWBeIflu7WyBz
         O2Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h2si11597638pgq.310.2019.02.12.01.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 01:32:46 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1C9NtHL023005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:32:45 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qktkttmr9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:32:45 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Feb 2019 09:32:42 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 09:32:40 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1C9We1P852386
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Feb 2019 09:32:40 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0848842047;
	Tue, 12 Feb 2019 09:32:40 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 94E484203F;
	Tue, 12 Feb 2019 09:32:38 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.59.139])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Feb 2019 09:32:38 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 12 Feb 2019 11:32:37 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "'David S . Miller'" <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] sparc64: simplify reduce_memory() function
Date: Tue, 12 Feb 2019 11:32:36 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19021209-0028-0000-0000-0000034791C3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021209-0029-0000-0000-00002405B092
Message-Id: <1549963956-28269-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=697 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The reduce_memory() function clampls the available memory to a limit
defined by the "mem=" command line parameter. It takes into account the
amount of already reserved memory and excludes it from the limit
calculations.

Rather than traverse memblocks and remove them by hand, use
memblock_reserved_size() to account the reserved memory and
memblock_enforce_memory_limit() to clamp the available memory.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sparc/mm/init_64.c | 42 ++----------------------------------------
 1 file changed, 2 insertions(+), 40 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index b4221d3..478b818 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2261,19 +2261,6 @@ static unsigned long last_valid_pfn;
 static void sun4u_pgprot_init(void);
 static void sun4v_pgprot_init(void);
 
-static phys_addr_t __init available_memory(void)
-{
-	phys_addr_t available = 0ULL;
-	phys_addr_t pa_start, pa_end;
-	u64 i;
-
-	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &pa_start,
-				&pa_end, NULL)
-		available = available + (pa_end  - pa_start);
-
-	return available;
-}
-
 #define _PAGE_CACHE_4U	(_PAGE_CP_4U | _PAGE_CV_4U)
 #define _PAGE_CACHE_4V	(_PAGE_CP_4V | _PAGE_CV_4V)
 #define __DIRTY_BITS_4U	 (_PAGE_MODIFIED_4U | _PAGE_WRITE_4U | _PAGE_W_4U)
@@ -2287,33 +2274,8 @@ static phys_addr_t __init available_memory(void)
  */
 static void __init reduce_memory(phys_addr_t limit_ram)
 {
-	phys_addr_t avail_ram = available_memory();
-	phys_addr_t pa_start, pa_end;
-	u64 i;
-
-	if (limit_ram >= avail_ram)
-		return;
-
-	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &pa_start,
-				&pa_end, NULL) {
-		phys_addr_t region_size = pa_end - pa_start;
-		phys_addr_t clip_start = pa_start;
-
-		avail_ram = avail_ram - region_size;
-		/* Are we consuming too much? */
-		if (avail_ram < limit_ram) {
-			phys_addr_t give_back = limit_ram - avail_ram;
-
-			region_size = region_size - give_back;
-			clip_start = clip_start + give_back;
-		}
-
-		memblock_remove(clip_start, region_size);
-
-		if (avail_ram <= limit_ram)
-			break;
-		i = 0UL;
-	}
+	limit_ram += memblock_reserved_size();
+	memblock_enforce_memory_limit(limit_ram);
 }
 
 void __init paging_init(void)
-- 
2.7.4

