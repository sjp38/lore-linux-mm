Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43827C04AA7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:55:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0275B20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:55:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0275B20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3A36B0003; Mon, 13 May 2019 22:55:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954D76B0007; Mon, 13 May 2019 22:55:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86B546B0008; Mon, 13 May 2019 22:55:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51AD26B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:55:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p12so9691593plk.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:55:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Dx/mpYHP5XO/8lKUfLw1Mak2NWloHaAJzjNg9v7Ddig=;
        b=HPaoo/y/EOjx5e0WKdzcAanGVmdQgRvK1EtF6yGAccQVWMqJtGsK/yLoJ6ZNWn7tcx
         3J34f5Mi4WTJJCkFXQO11I1sqxx06SLVPAkWUsc199UH1iDVgSR2LObQHjhYZ0hHVY+q
         3PFDTxa+6pef0sifKZxOXtjsWjCYmTJJ0zlgltyye+SjI7nNhPLODJzEjzNob4uqwiR9
         7he6i5wnFhO3C9jgVopgvNmW12GdMdXCkRcx/Xr2HoEywQCkPjVuzPj5ZslLhapstS5v
         Qi4dMh9l+9E+CmJFeAUvq3kcs/JxhoeiFbtNS/0U7L3+E+IMpBN16cQk8qaThPcdMqo5
         ZPSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUBRysT1ahzZzmA9SOqXNkCqu7aAIDUp55N5Tk3B13nsb2HAdCq
	CDgEXyQjf4mlm2Opy1QYCXVDU+baTQuAI2a/JPRkZkcHxSRsrx+tsxwUAxl+7xF7NKcNe2rDFaU
	fvDxv3cwGXP4JIEJg8sPFsg2KUSPaA7onJtB7NwrBBY3XnP9HBmWdlXHpz5Q/geUt5A==
X-Received: by 2002:a62:d244:: with SMTP id c65mr37979803pfg.173.1557802521952;
        Mon, 13 May 2019 19:55:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO86/oF3+zlHkR88GEI5xoLaS7/bk69K9DIYTUfauQjMU3HV+bdWeunCJUDMf2ccAT/EDc
X-Received: by 2002:a62:d244:: with SMTP id c65mr37979751pfg.173.1557802520954;
        Mon, 13 May 2019 19:55:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557802520; cv=none;
        d=google.com; s=arc-20160816;
        b=k234aMc3MH7VhaEAXJXlgHf/RCXbRKgkuxBQUdWjrllqA5LmNgzJpggWzMKt83StL2
         v5BF2tSXDm5iIEmnFAgZBSepENoPtkwrpxvYYnwD36F+ZJlhYybqK4cgzuDZ8IGBQfEQ
         bmM870+ZAu7y0dUOcb5w4o1lT3W3i986jco7X96tTmmC7pTGExzG/5eOy7BllvcMy3Dm
         KjFcmml9XcdbuYW2dH7eVAszgEwk7SsYKTe7P/M78Mf5C7ST+qgfVUjqh4ElTgbR5twc
         Ex+CPXXi4CHZ0D/eyAroRBrakR9/XH8OAKkyrYOCFDwAZ6KkQsJ8RzOAalP3WCDU+fr1
         nKJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Dx/mpYHP5XO/8lKUfLw1Mak2NWloHaAJzjNg9v7Ddig=;
        b=Y8DQHBpKcNW3fQ7D5eu3BgCweMXowLW1LKWa5oLpbG3b5CCc48NKbQtNIcXLRdBCT/
         3NeVFrofM7QR18Wbac4z5WcBNVAkM+XBsRxOozTKnPkgAKiJvddQtFa5xpytVxh3Ka1O
         cANVFMDULwP4ogh42CL+Jnx1yeEatlpwDZS9AS+Zjub87G7QAJJ1qEu9uPgSVcMRd3kC
         qGA/1eI7FFl8jIanQs9WmOHq2lUk+JWDlwsDqJaaU68OovlfuNI3VbFkOUmZKNSIjXdl
         aQ9nOkagGwE+AXxfgVeiW/xyfB1pX7WiM95a8qt5hZ8S72a06iCqlXJk98O47+W3ko6a
         cE5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i1si730291pfr.5.2019.05.13.19.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:55:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E2kv4n023725;
	Mon, 13 May 2019 22:55:19 -0400
Received: from ppma01dal.us.ibm.com (83.d6.3fa9.ip4.static.sl-reverse.com [169.63.214.131])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sfhg1qep2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 22:55:19 -0400
Received: from pps.filterd (ppma01dal.us.ibm.com [127.0.0.1])
	by ppma01dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x4DKwsxl026198;
	Mon, 13 May 2019 20:59:39 GMT
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by ppma01dal.us.ibm.com with ESMTP id 2sdp14jxs3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 20:59:39 +0000
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E2tHpH24510734
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 02:55:17 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 07C9A136055;
	Tue, 14 May 2019 02:55:17 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 23ADF13604F;
	Tue, 14 May 2019 02:55:15 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.80.221.111])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 02:55:14 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/nvdimm: Use correct alignment when looking at first pfn from a region
Date: Tue, 14 May 2019 08:25:12 +0530
Message-Id: <20190514025512.9670-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=902 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140018
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We already add the start_pad to the resource->start but fails to section
align the start. This make sure with altmap we compute the right first
pfn when start_pad is zero and we are doing an align down of start address.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 kernel/memremap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..23d77b60e728 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -59,9 +59,9 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
 {
 	const struct resource *res = &pgmap->res;
 	struct vmem_altmap *altmap = &pgmap->altmap;
-	unsigned long pfn;
+	unsigned long pfn = PHYS_PFN(res->start);
 
-	pfn = res->start >> PAGE_SHIFT;
+	pfn = SECTION_ALIGN_DOWN(pfn);
 	if (pgmap->altmap_valid)
 		pfn += vmem_altmap_offset(altmap);
 	return pfn;
-- 
2.21.0

