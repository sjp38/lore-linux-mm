Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8993C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79648217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:28:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79648217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12B7B6B000A; Wed, 22 May 2019 04:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DB736B000C; Wed, 22 May 2019 04:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0D346B000D; Wed, 22 May 2019 04:28:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB4F76B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:28:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a90so947712plc.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 01:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=SwfZ5gHinL+ZGl3v5/D4Rf/RJsHj9sBvxpFwbDB8eOk=;
        b=Jkpt9Pc9gfQ6kzmJxqb2ReDN4ldPjyUaFIdgdeZPR5/Apg6KBMsbhmb85nuINu4KF7
         gK6Fox7Ya4Ov4E7xMTKIoeCQZSuxEgjX72zsz9WoJOP2nkudaTpBoCXGDU90I6472VrD
         nclUjwxjwYkilOud8gut0fAlLDJmk/V0wbesRfD7jUuqb2DUmn+bcPwsE+Bwv0luv9+Y
         UkItSw6++0WLTj9BjXuQhXT+/B5zu8bh+4MUuBlm324j75EEh5yTkYik6IA74bAa36MC
         StEeUCODWFhQxdWuEo1y3ELskp6Z13GB2iQShK+WpCSoORJx6Mke6UbVgdukmGaRVvN1
         JArg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV7sbPyxPrwxpWRBNQZ5KjQ8KbeQbK/ntM8mMiWu6Ns96NTCzQD
	uh3oY6ZTAiXqjrwBvoukMiMk/uohyFJkQMLbu4QvSnx0KI+YukRVc+ICHd7b4cPy6IUAvJ4Xh3S
	wYypp7uO9wqPDaTAulv7YtCDfAeih+vvzpWNbGL6zEBzZAIUDtMm6fjeUpkctVKU2lQ==
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr43222211pgd.6.1558513704404;
        Wed, 22 May 2019 01:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlM/nmfQou0zxFPdN3i0hapEmK8qBNS2v9FI+kSagYIXhI81cVO8C58ZkbAIcb33ZpMLPu
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr43222139pgd.6.1558513703652;
        Wed, 22 May 2019 01:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558513703; cv=none;
        d=google.com; s=arc-20160816;
        b=QhDrd/A+uxcPeCMHu8zDBCjokNMbLPS9Sh3YlDuk2yDPEU8ekaWb/UjgDi0ffGl1i8
         WWkS+Cn/cNUVW9xyQiAnR4ovBko6mIrxbNw6LlCD3LK1hcG1ZPA6qS+72tUemfR3Eitu
         fIBdhIAcN/P3ZCJAAyOEKMr1Kyg0scmAZ+y1vuGfSqYkXMDUK0Wgx26sURn4l7YnLTk5
         kDDAgF4Q9Mdsane9spttDyOZgB73D+ZwLxXhQlJlrj6Gmu6tSAD/oGAqKXVk5Yj69pYZ
         v2ltrhfEtVK3Y22v2XMS4YepVIem9vEXk+t9syQYtyTAYYT3i0l9bv/T+WnsQLDb/Q21
         OMlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=SwfZ5gHinL+ZGl3v5/D4Rf/RJsHj9sBvxpFwbDB8eOk=;
        b=CV57piPAenZbfNrnlKyFzxVJY43pK4GBbvqfL1H/Z136wifstfU34Zi/mamarwiol8
         EFcNPwZbkefBZ4475+f+fZdYbk8yJQ8d6r9xSl8ORLnAkjAc7Zj1iHlgl5EsR7ElUNF4
         wVgRIa1rr9UZyZQoHxv7xENUoj49b5VQcQlwMUDJdiY976wSJ6AZHLyyUjJawGOkKoZ/
         rNf2kxoAXHNGutzGXOVXjSYHPBBoOoex+8S7t6DomnSlBj7xpQgePX2TErMV5TNTfsFM
         v8u469/HJxtcjMgsHfdc43SdV6rfFxKVTB1ipaqA4AjqCl3ln63XPpZ0RGUsHZp9qaQn
         Lgdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r185si24476581pgr.10.2019.05.22.01.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 01:28:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M8SF6E136849;
	Wed, 22 May 2019 04:28:22 -0400
Received: from ppma01dal.us.ibm.com (83.d6.3fa9.ip4.static.sl-reverse.com [169.63.214.131])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2smyuj7gaf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 22 May 2019 04:28:21 -0400
Received: from pps.filterd (ppma01dal.us.ibm.com [127.0.0.1])
	by ppma01dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x4M4G3D1005567;
	Wed, 22 May 2019 04:19:20 GMT
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by ppma01dal.us.ibm.com with ESMTP id 2smks6s7um-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 22 May 2019 04:19:20 +0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M8R7ZL18874872
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 08:27:07 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 44734C6057;
	Wed, 22 May 2019 08:27:07 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9844DC6059;
	Wed, 22 May 2019 08:27:05 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.87])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 08:27:05 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH V2 1/3] mm/nvdimm: Add PFN_MIN_VERSION support
Date: Wed, 22 May 2019 13:56:59 +0530
Message-Id: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows us to make changes in a backward incompatible way. I have
kept the PFN_MIN_VERSION in this patch '0' because we are not introducing
any incompatible changes in this patch. We also may want to backport this
to older kernels.

The error looks like

  dax0.1: init failed, superblock min version 1, kernel support version 0

and the namespace is marked disabled

$ndctl list -Ni
[
  {
    "dev":"namespace0.0",
    "mode":"fsdax",
    "map":"mem",
    "size":10737418240,
    "uuid":"9605de6d-cefa-4a87-99cd-dec28b02cffe",
    "state":"disabled"
  }
]

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn.h      |  9 ++++++++-
 drivers/nvdimm/pfn_devs.c |  8 ++++++++
 drivers/nvdimm/pmem.c     | 26 ++++++++++++++++++++++----
 3 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index dde9853453d3..5fd29242745a 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -20,6 +20,12 @@
 #define PFN_SIG_LEN 16
 #define PFN_SIG "NVDIMM_PFN_INFO\0"
 #define DAX_SIG "NVDIMM_DAX_INFO\0"
+/*
+ * increment this when we are making changes such that older
+ * kernel should fail to initialize that namespace.
+ */
+
+#define PFN_MIN_VERSION 0
 
 struct nd_pfn_sb {
 	u8 signature[PFN_SIG_LEN];
@@ -36,7 +42,8 @@ struct nd_pfn_sb {
 	__le32 end_trunc;
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
-	u8 padding[4000];
+	__le16 min_version;
+	u8 padding[3998];
 	__le64 checksum;
 };
 
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 01f40672507f..a2268cf262f5 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -439,6 +439,13 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb), 0))
 		return -ENXIO;
 
+	if (le16_to_cpu(pfn_sb->min_version) > PFN_MIN_VERSION) {
+		dev_err(&nd_pfn->dev,
+			"init failed, superblock min version %ld kernel support version %ld\n",
+			le16_to_cpu(pfn_sb->min_version), PFN_MIN_VERSION);
+		return -EOPNOTSUPP;
+	}
+
 	if (memcmp(pfn_sb->signature, sig, PFN_SIG_LEN) != 0)
 		return -ENODEV;
 
@@ -769,6 +776,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
 	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->min_version = cpu_to_le16(PFN_MIN_VERSION);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 845c5b430cdd..406427c064d9 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -490,6 +490,7 @@ static int pmem_attach_disk(struct device *dev,
 
 static int nd_pmem_probe(struct device *dev)
 {
+	int ret;
 	struct nd_namespace_common *ndns;
 
 	ndns = nvdimm_namespace_common_probe(dev);
@@ -505,12 +506,29 @@ static int nd_pmem_probe(struct device *dev)
 	if (is_nd_pfn(dev))
 		return pmem_attach_disk(dev, ndns);
 
-	/* if we find a valid info-block we'll come back as that personality */
-	if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
-			|| nd_dax_probe(dev, ndns) == 0)
+	ret = nd_btt_probe(dev, ndns);
+	if (ret == 0)
 		return -ENXIO;
+	else if (ret == -EOPNOTSUPP)
+		return ret;
 
-	/* ...otherwise we're just a raw pmem device */
+	ret = nd_pfn_probe(dev, ndns);
+	if (ret == 0)
+		return -ENXIO;
+	else if (ret == -EOPNOTSUPP)
+		return ret;
+
+	ret = nd_dax_probe(dev, ndns);
+	if (ret == 0)
+		return -ENXIO;
+	else if (ret == -EOPNOTSUPP)
+		return ret;
+	/*
+	 * We have two failure conditions here, there is no
+	 * info reserver block or we found a valid info reserve block
+	 * but failed to initialize the pfn superblock.
+	 * Don't create a raw pmem disk for the second case.
+	 */
 	return pmem_attach_disk(dev, ndns);
 }
 
-- 
2.21.0

