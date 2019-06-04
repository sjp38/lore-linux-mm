Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 402E1C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0049522CF8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0049522CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53DCA6B0274; Tue,  4 Jun 2019 05:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ED616B0276; Tue,  4 Jun 2019 05:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38F066B0277; Tue,  4 Jun 2019 05:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0B636B0276
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:14:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so15672154pfa.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=kpoWseBFGA49tbcWqQaBX836YqFXpglIUaPpy4tHJyE=;
        b=LdgC0yA50HsHf1O5j9+27kF//2bPmJ3UZyi1/PelHY2Ya836lPDcuB7yO3FfEmq82Y
         pwJUgfpDAI0fJoECcSVm8lMoWLn5p49iRcw79ttZFeam8btjtJt+LKjLB7s24223YLVx
         vQh62OTgxHLKxPOjXspTa0Fou1JUhcEKifIXv/rYmcUKrkwoJLqvMGLn8zbMFZZNRH3h
         JYk3MHUXUzGQ51dCeCl62O9KfYV56iWoj/R5f9l/Zm3zA2TbTgPqEvpyPxLKjV0yvg53
         a8eLGD/ckBKyEMPm0FGu2a5giQS88PAwIz6CPzFzN4I77IArYDcg3liKIBUIRkiJVD9X
         6/rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWFskMZ9XzDyBCZDbZhueF65vAWcoUUh7RLYWJNclxDLHzXng7K
	oawlAimfTrEJWS1zVfX2E3+lKrbt82+x5Sr+h75/+A1L43VfUkwJMsL6dzCMO+jYKfpwv45es4k
	GodL4yWhy6D2sTkI+SYUH0jw3S8w73p+ZBxztgeb2sMN4Skz6aBLXGqK/F+59os11Yg==
X-Received: by 2002:a17:902:860c:: with SMTP id f12mr35451975plo.127.1559639662472;
        Tue, 04 Jun 2019 02:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfREJZboJPr5xgriPKHFChu+jgMmQKl4wq1XjFaYIu3mCILYLbu/X8bBsPXsyWWUzzG0IQ
X-Received: by 2002:a17:902:860c:: with SMTP id f12mr35451892plo.127.1559639660933;
        Tue, 04 Jun 2019 02:14:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639660; cv=none;
        d=google.com; s=arc-20160816;
        b=EFfZMu4atNbg1lz1rDSUtWGe5kJlQq81SM1A67mOL2OEU+B43VYiSipMfguBlvbhBA
         1cv/8IE3czIReZADF1ae7YyNu751BiXSu/7br3X4HL24W2O+uDNdgDjaav2U2DMtyrq0
         zMnx+pYsMMqqXqJZ1tzmp/z3jVNlnqIpTkg98liktAPcY9bvOeIYfZu/S0kMYvS8goAm
         2UNoi9h5VIv1qBigiLWfAbkYmc4I8hGUHDbRkrxrbaurDW4VEL1KH3PcCHAqBF1MUOHD
         q/smf1gM0HWDl/AYBEIZ1nZjm25ycnaeMZH3JpmOv9ARwFZoDvdS7Pd3SOw24x8p2Nd9
         3TDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=kpoWseBFGA49tbcWqQaBX836YqFXpglIUaPpy4tHJyE=;
        b=ENsmiuToh0C3I+kFDmwrW0VbLmTVfMx1iaLPpXSp+ndIJ6jhlQ5QjTaaY6iZDWCkXX
         aiQGBIIznyrM4fRB1WcFK8QENeda7qAM1HZ25FuuX5gDajd7Sbdl8JFu/j1y4oLrpNtz
         QE+4xfuAy+WcSG+gM7+7G89R0SMkAQ7z9nEgNU1DnHwY4CurIXuGZRJKcMjuQ4iGb1xk
         MjWAh4u9PlS//cqJ8ESmy50aacUnDNZHRxredpz8/iMonPN9ETOFFNjO39qbHdQ8mW9h
         vlR5bxpcu0Baf83qBq7WjlkoXWswI5krNCoqRUJpEpeRhN1rJIIUBQGGsQTF8I0W9keU
         XhNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f11si19924961plr.405.2019.06.04.02.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:14:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497dvp025070
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:14:20 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swkpaxdun-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:14:20 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:14:19 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:14:15 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549EEnU15007958
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:14 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 528DCAC05F;
	Tue,  4 Jun 2019 09:14:14 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6809AC060;
	Tue,  4 Jun 2019 09:14:12 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:12 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 2/6] mm/nvdimm: Add PFN_MIN_VERSION support
Date: Tue,  4 Jun 2019 14:43:53 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0052-0000-0000-000003CB0714
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213037; UDB=6.00637527; IPR=6.00994104;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:14:17
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0053-0000-0000-0000612A42D4
Message-Id: <20190604091357.32213-2-aneesh.kumar@linux.ibm.com>
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
 drivers/nvdimm/pfn_devs.c |  9 +++++++++
 drivers/nvdimm/pmem.c     | 26 ++++++++++++++++++++++----
 3 files changed, 39 insertions(+), 5 deletions(-)

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
index 01f40672507f..00c57805cad3 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -439,6 +439,14 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb), 0))
 		return -ENXIO;
 
+	if (le16_to_cpu(pfn_sb->min_version) > PFN_MIN_VERSION) {
+		dev_err(&nd_pfn->dev,
+			"init failed, superblock min version %d kernel"
+			" support version %d\n",
+			le16_to_cpu(pfn_sb->min_version), PFN_MIN_VERSION);
+		return -EOPNOTSUPP;
+	}
+
 	if (memcmp(pfn_sb->signature, sig, PFN_SIG_LEN) != 0)
 		return -ENODEV;
 
@@ -769,6 +777,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
 	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->min_version = cpu_to_le16(PFN_MIN_VERSION);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index d9d845077b8b..eddc28e8c357 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -496,6 +496,7 @@ static int pmem_attach_disk(struct device *dev,
 
 static int nd_pmem_probe(struct device *dev)
 {
+	int ret;
 	struct nd_namespace_common *ndns;
 
 	ndns = nvdimm_namespace_common_probe(dev);
@@ -511,12 +512,29 @@ static int nd_pmem_probe(struct device *dev)
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

