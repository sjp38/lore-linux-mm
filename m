Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BF59C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CBD322CF8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CBD322CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6279D6B0277; Tue,  4 Jun 2019 05:14:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D8B96B0278; Tue,  4 Jun 2019 05:14:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A0236B0279; Tue,  4 Jun 2019 05:14:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2524C6B0277
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:14:29 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v5so635102ybq.17
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:14:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=DfCc8c1U4s8yOXO1igLbWqvoORiyMSAIleJlok7k80w=;
        b=cRRhTmZYM3IG9kT8N6NRIO84rQBMRRMSCHCWLrRKKVHTs7nov+P/U902/iSmauNMJk
         nk8n5lsW7vz/XSVdOYn0QjTn7ibwgERDdDkkIF6aLjDg8Go4kitzoZnqHZ/a/FSrxSXz
         12RC3aVODKLPz4u9VL87ct5VmPvpYkiSY3OJsJViNOlcGtNGKHxjklfFPZauWnXGPriI
         7f5SGyVYvfeFNORWc/lRYqlMNKVUNQwkGrXptJYY6XDzJIbtgmFiHzDEKQUYSA5S2syX
         pTMwZ+N9oOadOyUG0ej1hAX9ll1xdXeBxglyCbLZEQf/2sWKaRzYT/5NGkEOK9GTh/Av
         G2Yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV4tJkc4o2zMZZN7tcVKTGP6MbNQ/I15c5LF36HN45mFbAIn36E
	sC/YOvihIqjsfawzg/Y3iHJ7zX/HyhZEJJaSnE82Oi3tXnEL01kxvgeUyLz1GUb+7kv4nITQu0V
	FIsgGQCFPTriBOZypjBQAs61zRzLnsXn4j4/Cz7VQP4tnJujhwtCRe7ybjmg0VTIEEA==
X-Received: by 2002:a81:270c:: with SMTP id n12mr6437357ywn.134.1559639668648;
        Tue, 04 Jun 2019 02:14:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM5H8Q6QrMUAdOH/qfu+w7tgozpyBc4fpDkkn0i7ZnPiOg+v2tt7TB2A8GdnhYypY7RFTK
X-Received: by 2002:a81:270c:: with SMTP id n12mr6437338ywn.134.1559639668058;
        Tue, 04 Jun 2019 02:14:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639668; cv=none;
        d=google.com; s=arc-20160816;
        b=eyz5cPCo/bE0aB2uEtV7S7utWcopReRqWyRk0lk8trAJLkmiX1x6hiZxWSURlIzoFt
         wFHczyoHSiamXwDWDajVKYH5Bvj7ndeINsJgfmaNTNAsL659qyu4zyeI0abiLkNKEq/u
         LoavLYvXIZ/8mCuZyNZwbkkEGp6/7aT2GCR5GGqH4Pit9s16hE7VeBJ0WL7ZNMAuB5c1
         QGK+YKj/g8TPWT7C/4XmrExpjBgS2NEd3xfzmrnUIv9jKKa5I1NBg/CC23RHCEn6+z05
         JIJjW4EuKiwRap6yjdTb2ZgWVBRpvQLVapQ5bqVjfBONU86N7ULMHclHNs5Q2XOnjsTq
         q4hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=DfCc8c1U4s8yOXO1igLbWqvoORiyMSAIleJlok7k80w=;
        b=cnl7CQVLy/1KaXoZsmvgQP1+2NvSjE7i+l9FDWJ1H/9A6Cvi/2VU4I8HTz/rbsSBT0
         H12Z7gdCuSAUdwIP8OuorbdJrIDyDd6txWXsVnN6ZFlWgEVglmC0spNpiLmeU5HdJFJ/
         9bv92F5+44bq8t0EwzjSTDXsFw911R7U8of6ehjJTboS7seRXZ+ogdg+PsV8cOiC95Kc
         EevqL525Bj/0hS1EbKatf5Qlvp+Wh1Ysfb1O6q3VGn1E2jsbfMoMzYxIHhAEUiiwRe54
         c5v+1afA6Rxo4b6p7Zs+VfFY7KmO5AylTLmN/7wjOn9j9eCEBVQve6FTG1vdXKPEnuRc
         GVkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t193si317148ywe.54.2019.06.04.02.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:14:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497bWQ072141
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:14:27 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2swjgp0w2a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:14:25 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:14:24 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:14:22 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549ELax33816652
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:22 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CD6FEAC060;
	Tue,  4 Jun 2019 09:14:21 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 54B54AC05F;
	Tue,  4 Jun 2019 09:14:20 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:20 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 6/6] mm/nvdimm: Use correct alignment when looking at first pfn from a region
Date: Tue,  4 Jun 2019 14:43:57 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0060-0000-0000-0000034BD868
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213037; UDB=6.00637528; IPR=6.00994104;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:14:24
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0061-0000-0000-0000499E0C1E
Message-Id: <20190604091357.32213-6-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=728 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We already add the start_pad to the resource->start but fails to section
align the start. This make sure with altmap we compute the right first
pfn when start_pad is zero and we are doing an align down of start address.

vmem_altmap_offset() adjust the section aligned base_pfn offset.
So we need to make sure we account for the same when computing base_pfn.

ie, for altmap_valid case, our pfn_first should be:

pfn_first = altmap->base_pfn + vmem_altmap_offset(altmap);

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 kernel/memremap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 1490e63f69a9..bf488b8658e7 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -60,9 +60,11 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
 	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
-	pfn = res->start >> PAGE_SHIFT;
-	if (pgmap->altmap_valid)
-		pfn += vmem_altmap_offset(altmap);
+	if (pgmap->altmap_valid) {
+		pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
+	} else
+		pfn = PHYS_PFN(res->start);
+
 	return pfn;
 }
 
-- 
2.21.0

