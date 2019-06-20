Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0191C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 890F120656
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 890F120656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26EAA6B0007; Thu, 20 Jun 2019 05:17:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F7528E0002; Thu, 20 Jun 2019 05:17:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024678E0001; Thu, 20 Jun 2019 05:17:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C44666B0007
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:26 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k10so2275167ywb.18
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e1zy3OSTMJEjL28icNKgsrl2qCV0weeSv2VKY2lvutw=;
        b=Vw8msa94us8pSIOJiqIwDKaKZ5lpEUCfzUgdGHWuQtwWheOcRLc/yuvUaCEdm2cw4H
         IuvGqXjNXm1ky+KXWYAlkvLH+HsBR2I3Y6xSn8ODQIIQ4yucOMRRCTiDuq8I4vwcQql3
         9J4kAd6XkqrMgZfFm0UI5FXFmX+tLG1bjFOTZvotMoGiz6LDxW6CVxz5jyVLgvg/CcKp
         wGUfq7f+KOf8joae6KRtzGTseYm/x9bAy/XNnjjg3hA6d3kpiVCO/oKec5EcArUdOOF2
         IKyHeoWEmLqn741WTiuHN5HHNEnGvCxMhMZbO6vCCJZP3LsIVVL7nvny1frjoVt8SoqK
         7jnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVPCvvZCr1mv3ZWtaqJO46r9MP4122ypO43IqiW8hJznnUEvwEh
	6e55k74hJo7QHU3ljhGudAEkqx1ENKsFV2bVQEKI0OyzKzYMluX+irAD2X4lot5ZxOzKzegcxAI
	UK1Mtjb2+LBYoVr1Mq9+e+76KOpRmwltqkxSzKMXifbwo/kAEMuXj0foku1hwjdIvIA==
X-Received: by 2002:a81:a50e:: with SMTP id u14mr57397625ywg.124.1561022246554;
        Thu, 20 Jun 2019 02:17:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLeKZ6ZGoPkFBwy+Y3ZGiQYG6ny8yQaGD6KQegV5E5+ASb2VkoCYMkAWEUADG6zsjTXcXK
X-Received: by 2002:a81:a50e:: with SMTP id u14mr57397605ywg.124.1561022245954;
        Thu, 20 Jun 2019 02:17:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022245; cv=none;
        d=google.com; s=arc-20160816;
        b=WobOCMQTLo85OPgCvKX+OC0mLgDgdR72n5shxAkKSdcfsaLP4LLLGhRdC6BkS7MlWS
         jVXNMq9ie/B447y5KFTlwbuJbzJfPh3XWr9ls7JoVCO13T0BzGJklKX1/bQTtYKU0guh
         83yvNlP5LXaaoBC/1bIOs48FzuJdh8u2426eX4JXjp+nOx/enfCEdeYFprCS9/sm27b5
         JvpRPcNLyr18HiuEdnrEMI0vs+NFjY/3WfTotMFE3VyzcnECtKVRvF4uNvqFam4ZYZ++
         C1MnxtbcdD3Bk//A+P8Mtq6H5zj/bh5+BIlyGpAOgcK3Y9FXL5UiFE7/ejDvvi4uCzA6
         v0/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e1zy3OSTMJEjL28icNKgsrl2qCV0weeSv2VKY2lvutw=;
        b=DS1JKBYxKRmhlBZH0NlaV/8yV+eAET8SZ4y5Wc8lpFbewhkqvYrlxTu7Z0NrrH6iRf
         V5ISdS3NLxAjRZmXgC1B8RRwImbH8d74txTk0azQWD4PXnHZqexgiUC/kD+SecoHyu4B
         XJqrJnChFfXIpP8weZ1EucxaCtkWOOvHhq5z9rO3PxStXiQ53KIa+u1Bdkostm4M5drJ
         MZgXKLRNF8k9SlPjL4QyNRZl6rXB5TVC5PxJLwS0aJh4/Ob8G7bxCf94Nrw6UdSteSlY
         o5zNCo5EbYc2fvUxYNriqCyz+2SzerSSegPGXo0WTzr0qEVmbTs0cYSUzK+lm9MJzPD0
         R80A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j62si7336753ywa.445.2019.06.20.02.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K94a1m146189;
	Thu, 20 Jun 2019 05:17:14 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t85ymbm00-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 05:17:14 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5K94kWQ032608;
	Thu, 20 Jun 2019 09:17:14 GMT
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by ppma01wdc.us.ibm.com with ESMTP id 2t4ra70ntr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 09:17:14 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9HDaN33489158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:13 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 834BEAE062;
	Thu, 20 Jun 2019 09:17:13 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0D4FCAE060;
	Thu, 20 Jun 2019 09:17:12 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:11 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 2/6] mm/nvdimm: Add page size and struct page size to pfn superblock
Date: Thu, 20 Jun 2019 14:46:22 +0530
Message-Id: <20190620091626.31824-3-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
References: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is needed so that we don't wrongly initialize a namespace
which doesn't have enough space reserved for holding struct pages
with the current kernel.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn.h      |  5 ++++-
 drivers/nvdimm/pfn_devs.c | 27 ++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index 7381673b7b70..acb19517f678 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -29,7 +29,10 @@ struct nd_pfn_sb {
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
 	/* minor-version-3 guarantee the padding and flags are zero */
-	u8 padding[4000];
+	/* minor-version-4 record the page size and struct page size */
+	__le32 page_size;
+	__le16 page_struct_size;
+	u8 padding[3994];
 	__le64 checksum;
 };
 
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 2537aa338bd0..cd722de0ae03 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -460,6 +460,15 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (__le16_to_cpu(pfn_sb->version_minor) < 2)
 		pfn_sb->align = 0;
 
+	if (__le16_to_cpu(pfn_sb->version_minor) < 4) {
+		/*
+		 * For a large part we use PAGE_SIZE. But we
+		 * do have some accounting code using SZ_4K.
+		 */
+		pfn_sb->page_struct_size = cpu_to_le16(64);
+		pfn_sb->page_size = cpu_to_le32(PAGE_SIZE);
+	}
+
 	switch (le32_to_cpu(pfn_sb->mode)) {
 	case PFN_MODE_RAM:
 	case PFN_MODE_PMEM:
@@ -475,6 +484,20 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 		align = 1UL << ilog2(offset);
 	mode = le32_to_cpu(pfn_sb->mode);
 
+	if (le32_to_cpu(pfn_sb->page_size) != PAGE_SIZE) {
+		dev_err(&nd_pfn->dev,
+			"init failed, page size mismatch %d\n",
+			le32_to_cpu(pfn_sb->page_size));
+		return -EOPNOTSUPP;
+	}
+
+	if (le16_to_cpu(pfn_sb->page_struct_size) != sizeof(struct page)) {
+		dev_err(&nd_pfn->dev,
+			"init failed, struct page size mismatch %d\n",
+			le16_to_cpu(pfn_sb->page_struct_size));
+		return -EOPNOTSUPP;
+	}
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
@@ -723,8 +746,10 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
-	pfn_sb->version_minor = cpu_to_le16(3);
+	pfn_sb->version_minor = cpu_to_le16(4);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
+	pfn_sb->page_struct_size = cpu_to_le16(sizeof(struct page));
+	pfn_sb->page_size = cpu_to_le32(PAGE_SIZE);
 	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
 	pfn_sb->checksum = cpu_to_le64(checksum);
 
-- 
2.21.0

