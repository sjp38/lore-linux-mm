Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1D2BC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:31:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3FAB20B1F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3FAB20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F6E8E00BF; Wed,  6 Feb 2019 07:31:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61DCC8E00AA; Wed,  6 Feb 2019 07:31:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 535808E00BF; Wed,  6 Feb 2019 07:31:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE418E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:31:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so5125337pfg.1
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:31:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=872hdIH0CF7nnCJLjAht/7TwxzUt8oTUKDdda0W887o=;
        b=k6Gqz5M1aCdjQIY7cje11fS39iv+3j95j/S0hC8HplIp3MkzWh6JxyFcN7XcPfl1c6
         fPDNsDT7eefAA9JeVdEB7G026cisCJfpaZ4hvdSfQIZwSlYgkolBTD33oI+mFRflKiIF
         7l1Q5xTFcRXIdf7+Z4N42fgXWxN3oMB1zVHgyF3vlBxHMpaSRDu156c89wM5YzXqfnjq
         q0Bi00DzIHE8olggRXzdQCrT3tNYislLUgrCYllftGqHFWlo0UYfuhVoc336QpB4WA7E
         evYTMEVAeODfMumEr6O4q72Z4Y/wlCKfl1VD2U/fJ35y2nBbzzIwYI2wgZG73ABOtZcd
         3SoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAub1XLsytgD1p4b/4VR1wucB62L3zDjLUBaXuAWkFqYKHRpDbp17
	gubD7jOsywrg2HKPc2ntmGjS3pigptayEu3X2gkbI63OLUiJJwOjDlYVF8MPkEaE/eMl6JLpIRu
	NEvORHf+iih67+JO6VZyCC32lhyxYlj9pqU2LimSaZQETcXdGa7xPMuM+fCXnMKf4jA==
X-Received: by 2002:a63:30c8:: with SMTP id w191mr9620351pgw.120.1549456308638;
        Wed, 06 Feb 2019 04:31:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IanmJ6N6FTweMSFZA76VzU1lr205SFF9qMJcpS1yAvo318sD091bInhUJ8DBWDgC3yrHA3Q
X-Received: by 2002:a63:30c8:: with SMTP id w191mr9620291pgw.120.1549456307705;
        Wed, 06 Feb 2019 04:31:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549456307; cv=none;
        d=google.com; s=arc-20160816;
        b=SiTeIRjLZc9K+1KSxN5etTgHlBCHLFFTtqyoWSPcUOMaJ+zDEqKDOciRnoIbEdm1O+
         MZJ1bUe3wsVB+0PjOML5deKbVYSkTLXUau4gn/NrE02xCkN+1CbguxqijP9XdbOF6Nkt
         ojsGXwt22613zZAMZIje3+AMDERGsKmib+ojodEGldeWPqs8GNrknrb/M2Zcr3bBkWCC
         wUt6u7kIGma+A44ooGU//Ko7JxsGW7FHXlR45NDIorFK3rlGJ8VsNFjYbMr9wvCO5Eib
         ps3bD7t/nmLGJTqlG2+OfJY/3ey/4uR+8Ba4lL/NKnS552iPm1ALZtLj1kTMFA4UL9LX
         Z9eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=872hdIH0CF7nnCJLjAht/7TwxzUt8oTUKDdda0W887o=;
        b=NnsT6Yc5dRSNDWgMqmYmzN1RwGWGPfR7HufIZaF3lms4yL3BK0NYDWCtpFFGjyWGQp
         Vzu6LHD+v7eOOhK69LJqk3O9mXaJRIySrW/4gsfkC33PBuJ8pzKB+i2pcPqR3fkwur7M
         s4cmE+XFOiU/e8HSw1F0HXe3CxClEqU762DIjyLgZH/QUr/MTslbB6cztNeENJrobvxc
         pVzSb0RQpSbTTomzJb0ymLBh2K7I/3Rv2nDQ3jX+s4/u7dK2VhMo7tZbncOTIeNGdYx0
         LKkcMD3oN6+gfYAJS+lSIouImKJx8NtvuYG7ZsobdiYt7fjv5JIfmwAK/OfFJMcRGfaP
         RLEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m1si5993473pfi.286.2019.02.06.04.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:31:47 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x16CUpTo062808
	for <linux-mm@kvack.org>; Wed, 6 Feb 2019 07:31:47 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qfxsm37yb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:31:46 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 6 Feb 2019 12:31:44 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Feb 2019 12:31:42 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x16CVfxs9306546
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 6 Feb 2019 12:31:41 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6325A48B3;
	Wed,  6 Feb 2019 12:10:30 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 70F68A48AE;
	Wed,  6 Feb 2019 12:10:29 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  6 Feb 2019 12:10:29 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 06 Feb 2019 14:10:28 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/2] memblock: remove memblock_{set,clear}_region_flags
Date: Wed,  6 Feb 2019 14:10:24 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
References: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19020612-4275-0000-0000-0000030C2305
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020612-4276-0000-0000-0000381A283D
Message-Id: <1549455025-17706-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-06_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=884 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902060099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memblock API provides dedicated helpers to set or clear a flag on a
memory region, e.g. memblock_{mark,clear}_hotplug().

The memblock_{set,clear}_region_flags() functions are used only by the
memblock internal function that adjusts the region flags.
Drop these functions and use open-coded implementation instead.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h | 12 ------------
 mm/memblock.c            |  9 ++++++---
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 71c9e32..32a9a6b 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -317,18 +317,6 @@ void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
 	for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved,	\
 			       nid, flags, p_start, p_end, p_nid)
 
-static inline void memblock_set_region_flags(struct memblock_region *r,
-					     enum memblock_flags flags)
-{
-	r->flags |= flags;
-}
-
-static inline void memblock_clear_region_flags(struct memblock_region *r,
-					       enum memblock_flags flags)
-{
-	r->flags &= ~flags;
-}
-
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_set_node(phys_addr_t base, phys_addr_t size,
 		      struct memblock_type *type, int nid);
diff --git a/mm/memblock.c b/mm/memblock.c
index 0151a5b..af5fe8e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -851,11 +851,14 @@ static int __init_memblock memblock_setclr_flag(phys_addr_t base,
 	if (ret)
 		return ret;
 
-	for (i = start_rgn; i < end_rgn; i++)
+	for (i = start_rgn; i < end_rgn; i++) {
+		struct memblock_region *r = &type->regions[i];
+
 		if (set)
-			memblock_set_region_flags(&type->regions[i], flag);
+			r->flags |= flag;
 		else
-			memblock_clear_region_flags(&type->regions[i], flag);
+			r->flags &= ~flag;
+	}
 
 	memblock_merge_regions(type);
 	return 0;
-- 
2.7.4

