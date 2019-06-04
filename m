Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DF38C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:15:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1C5222CF8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:15:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1C5222CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ACB76B0271; Tue,  4 Jun 2019 05:15:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7842B6B0273; Tue,  4 Jun 2019 05:15:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 674366B0274; Tue,  4 Jun 2019 05:15:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 305EB6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:15:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u7so15689175pfh.17
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:15:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=yguVnoaVzkDkIEIYhWjcYSoglpBtVHAkjKX1ZneHBVg=;
        b=fysQx5WriUqsVG5sWokHFYE4/wQUSpxh5U2UDI/Adj7sZHc97rIywHUU8kO+TVSQ8U
         YwxVUXPzycdaRSYkeANqG1RGMlqlOH/vP4921aapyRTezl0euXxNk6SVp1BmPeLF8ue0
         BDHWcAIuok9RVvs4pIIf5CKG6yKTFiDLnpFvxDGTjrc6CoTws+bnMu5Blj1gZ4o/fNiN
         jlwu6FPICQ3isQPlhSKstrehY1mpX46xretNRIXiNrTEog2O5e4Rx2VZAMpyYc0UHCjF
         gF2OkTB/la3E2Jh/CsOWLk3b/ZE3MpnT4tfK6zWPHNVHM2ZRN3fxw7B7gkwMEcxhoDba
         Kecg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUhYywGS5SsiUGAK3qT4Ld58EPcn41tNu0BaGoJaGzsZPK0D92y
	IPQtRtx7gnGlPU0cQTvc1KvuKHvQtsAvyAmwXI9rKZ55IS/u0XM5O2a2bvMH9nJZrq+q2N9ALBG
	jY2b1914m0jRZBP5ssCe7h6lrnq2uOnTlrZZP/K66Dg/oEnKGItoh9R0FdYghYeZxZQ==
X-Received: by 2002:a17:902:8546:: with SMTP id d6mr27122151plo.207.1559639737626;
        Tue, 04 Jun 2019 02:15:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBSN034MPZ4IYakp7ZOsaGmjg/C80thyvFtkW+fjDmpAlOmXW+ck2bzZQpc2j8fBTPEln1
X-Received: by 2002:a17:902:8546:: with SMTP id d6mr27122099plo.207.1559639736688;
        Tue, 04 Jun 2019 02:15:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639736; cv=none;
        d=google.com; s=arc-20160816;
        b=dDce5yvoEVsFWF2WP8UMbzM2u6BZ4v6TyrbsgYsCJgucAFJsukFv2WFz1xdayvsAni
         sZ5DPh+IlQoCBzHNyvDO224MtOK4YlbA9vQvdNKQZCt3omC0NYUQrOUMJdvWkxfVvOg8
         7FNkV2gyay+6spMxxpSmywJOrim0PkAsazI76W1iQ/CWsBq775jmXlgQgLaYdHaEo2Qp
         /iix+J31l3ekyn9l9on1Y5hDyGAusrgF38nFLQbg6p+5rgf9of/lHm1Dc31lx8iLs6na
         rxz1FWvqpKIa2c9xelGTpHI8AI+/V5kr/xQEdPvAPsqaMViLpINjBMJw+JSaTEb7dUam
         FlKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=yguVnoaVzkDkIEIYhWjcYSoglpBtVHAkjKX1ZneHBVg=;
        b=uS6cq1yj0XiYrt7LnWCpdv2mOpJRqe/A8I4Q2kzWFeURGi7Hx67ONreMI/6+xI5XHt
         nKN9ebGz3U5XXT7OHb+r78QoxBujWEug8qOGpM+QeXpCmK7It9CICSjJuzSJsMdvbxvQ
         OMlUQoY9wBQ7+Q9goexh6xPAhfTIzSeYx6YN2sO9IwiXveNxcoXUxUJFKBEhEHHAelUd
         GMzQw5//IPY+VkCGmy6StuTYnxIbZcWqa2kUe2jFGrneiNkB4DtjtW4kO7DIQmbtIh2M
         sZ6hAFIEocM8unjq78CF/RZDByvQNkQxjrj97Xo/EIX4zGzaNzeMgpJ6lgUexIywJLRG
         LKCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b7si20391972pgk.553.2019.06.04.02.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:15:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497iD6101210
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:15:36 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swksswp13-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:15:35 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:15:34 +0100
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:15:31 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549EG1W19136674
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:16 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 30FF8AC059;
	Tue,  4 Jun 2019 09:14:16 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B5B11AC06C;
	Tue,  4 Jun 2019 09:14:14 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:14 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 3/6] mm/nvdimm: Add page size and struct page size to pfn superblock
Date: Tue,  4 Jun 2019 14:43:54 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0060-0000-0000-0000034BD878
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213038; UDB=6.00637528; IPR=6.00994105;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:15:33
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0061-0000-0000-0000499E0CF1
Message-Id: <20190604091357.32213-3-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is needed so that we don't wrongly initialize a namespace
which doesn't have enough space reserved for holding struct pages
with the current kernel.

We also increment PFN_MIN_VERSION to make sure that older kernel
won't initialize namespace created with newer kernel.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn.h      |  7 +++++--
 drivers/nvdimm/pfn_devs.c | 27 ++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index 5fd29242745a..ba11738ca8a2 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -25,7 +25,7 @@
  * kernel should fail to initialize that namespace.
  */
 
-#define PFN_MIN_VERSION 0
+#define PFN_MIN_VERSION 1
 
 struct nd_pfn_sb {
 	u8 signature[PFN_SIG_LEN];
@@ -43,7 +43,10 @@ struct nd_pfn_sb {
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
 	__le16 min_version;
-	u8 padding[3998];
+	/* minor-version-3 record the page size and struct page size */
+	__le16 page_struct_size;
+	__le32 page_size;
+	u8 padding[3992];
 	__le64 checksum;
 };
 
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 00c57805cad3..e01eee9efafe 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -467,6 +467,15 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (__le16_to_cpu(pfn_sb->version_minor) < 2)
 		pfn_sb->align = 0;
 
+	if (__le16_to_cpu(pfn_sb->version_minor) < 3) {
+		/*
+		 * For a large part we use PAGE_SIZE. But we
+		 * do have some accounting code using SZ_4K.
+		 */
+		pfn_sb->page_struct_size = cpu_to_le16(64);
+		pfn_sb->page_size = cpu_to_le32(SZ_4K);
+	}
+
 	switch (le32_to_cpu(pfn_sb->mode)) {
 	case PFN_MODE_RAM:
 	case PFN_MODE_PMEM:
@@ -482,6 +491,20 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
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
@@ -776,11 +799,13 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
-	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->version_minor = cpu_to_le16(3);
 	pfn_sb->min_version = cpu_to_le16(PFN_MIN_VERSION);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
+	pfn_sb->page_struct_size = cpu_to_le16(sizeof(struct page));
+	pfn_sb->page_size = cpu_to_le32(PAGE_SIZE);
 	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
 	pfn_sb->checksum = cpu_to_le64(checksum);
 
-- 
2.21.0

