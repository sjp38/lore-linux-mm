Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 519A4C04AA7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:56:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12F9320879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:56:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12F9320879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9FCE6B0005; Mon, 13 May 2019 22:56:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B51BB6B0007; Mon, 13 May 2019 22:56:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A673F6B0008; Mon, 13 May 2019 22:56:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86BFB6B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:56:21 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id r23so28908885ywg.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:56:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=O/i9cBDW/c3/DTzqO/75pJS98hOvLlSt3jzDVukGCIs=;
        b=k20SvspdXSqCE9T2nDWuh39hOQHg1HFo6TCQeeqoz1p8DQjid8l4724U9W/OzNRqx3
         T+hSowpYUE8iRkhUIWFSPl8Na72iZH67qkq3w2tFV7/aFEoQlTw4STTAO4f4z9Q/dlvu
         OU+X6EEyl1umgugRUyUOrZ1tOKzrNfxCVJCeYDW7NI8Utzn9Hm4KzmOBqpyogOZNnv4o
         bgI1R5josBpI3xILK/2mvNo5VaCKzvmcDPsgcr5nRs2wVpc3chEFbW1x8vwp9XDqm/Ax
         Y7JcgF5IfQvYUalszegKKUJ3Ef8+bdDOg80/RBriuSNq6rF8tPqroEw/dSnCzNmC0FCQ
         7iVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXp/VqrqlA2ar+FOrlvO6vjKDC3bbD8laJ4ygS1Hm612kPdcRt4
	FxMESqu8rkGxcwss6VEpyzOTwSYO8FKqlUWJO5QoS6UgZ3OJesFhFiqtdkAjnlsucGzHbRU76WN
	WsbVZNXQVdEllnYdi7rrm2RNGviTbZeCymJ/GFG+OZAAZ7lOwSpg1BSAJ4E11+x/fZA==
X-Received: by 2002:a25:ba4c:: with SMTP id z12mr15120357ybj.344.1557802581310;
        Mon, 13 May 2019 19:56:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzarUH+0jEvP1AmoGudwRPC1JMJdgkNp/rCF8u8ryZocwL0Fk3S3+SJiL3GLXGHffA7RvZ1
X-Received: by 2002:a25:ba4c:: with SMTP id z12mr15120334ybj.344.1557802580163;
        Mon, 13 May 2019 19:56:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557802580; cv=none;
        d=google.com; s=arc-20160816;
        b=nClpp94niY6CqrM4vvuRy8SiwCojaL9JNvUnj+oiT1mDx1yzzk1wghQFCrkqfkIDub
         F/UFzVb5jByigi+gy50X1/VMKg5JHLbfPJdMEbXYtBOEfI2VeUAOrIw3h1rnmm+q0Qxf
         2ILTNBGnPPCOxicnRMjev4A6l5uNsr8a64KFD6BuG4HBgyuVlrVr1hUeS8aEOkLqqcS0
         rTnHU5fv1huyNj7RCQGwWAxFRtHAhNGwYCB3p33bBvRdYn0KPtqnHChOn/EkaT76MOOx
         nocNn+MkQGhQmrL75tsHBqME1G7wCe5YCZW9j9ml0O9aCX133ShyBJKgYFp4NmbU+67m
         uF9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=O/i9cBDW/c3/DTzqO/75pJS98hOvLlSt3jzDVukGCIs=;
        b=InZDBg9VioXjElNjAthZ6JqcNsotxN9aep3dYBHu+16Av0FDVuoWKT4xYP67RNJwww
         1M85vgxLM8/l+2gp1GX2bdwQgsUO0DR7NIbxY6/a9EcHkngkncK4QRxRSrBuwr+kK3sR
         2/A+GsQAVTvqJOjry4gOAxx1G34cabeitdnGhkL+FU4xyN/yg4mRs3pOWT5UCXZVZwPB
         zm7oK2zbty1VK+lrai0QgQayGsskL0DRQc8h/FJxxPEMjYGWFyOFeZapB5q/Vh/6GxCw
         PcDyhrF2zCEs/I/21soIRvoiC3t1eq+UCXrcCjBDroM1KIMMX8BwdYgUBsk4eq4EAHcp
         QE1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s185si694596ywf.287.2019.05.13.19.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:56:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E2kXcJ092420
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:56:19 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sfh3kg9c7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:56:19 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 03:56:19 +0100
Received: from b03cxnp08026.gho.boulder.ibm.com (9.17.130.18)
	by e36.co.us.ibm.com (192.168.1.136) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 03:56:16 +0100
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E2uFLW8585602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 02:56:16 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D168C6A054;
	Tue, 14 May 2019 02:56:15 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 889AF6A04F;
	Tue, 14 May 2019 02:56:08 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.80.221.111])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 02:56:08 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
Date: Tue, 14 May 2019 08:26:04 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19051402-0020-0000-0000-00000EE86D1E
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01202997; UDB=6.00631418; IPR=6.00983915;
 MB=3.00026876; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 02:56:18
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051402-0021-0000-0000-000065D0C496
Message-Id: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=946 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140018
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The nfpn related change is needed to fix the kernel message

"number of pfns truncated from 2617344 to 163584"

The change makes sure the nfpns stored in the superblock is right value.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn_devs.c    | 6 +++---
 drivers/nvdimm/region_devs.c | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 347cab166376..6751ff0296ef 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + reserve + 64 * npfns,
-				max(nd_pfn->align, PMD_SIZE)) - start;
+		offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
+			       max(nd_pfn->align, PMD_SIZE)) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
 		offset = ALIGN(start + reserve, nd_pfn->align) - start;
 	else
@@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index b4ef7d9ff22e..2d8facea5a03 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -994,10 +994,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 		struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
 		struct nvdimm *nvdimm = mapping->nvdimm;
 
-		if ((mapping->start | mapping->size) % SZ_4K) {
-			dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
-					caller, dev_name(&nvdimm->dev), i);
-
+		if ((mapping->start | mapping->size) % PAGE_SIZE) {
+			dev_err(&nvdimm_bus->dev,
+				"%s: %s mapping%d is not 4K aligned\n",
+				caller, dev_name(&nvdimm->dev), i);
 			return NULL;
 		}
 
-- 
2.21.0

