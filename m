Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 579C5C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C454C2173E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:21:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C454C2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D82A6B0003; Wed, 22 May 2019 02:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189C86B0006; Wed, 22 May 2019 02:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04F6D6B0007; Wed, 22 May 2019 02:21:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3B046B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:12 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id t141so1057692ywe.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 23:21:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=rDhCH59MNuzThhgCtp6sXNBsgY+rxc19SMctO58eL0k=;
        b=kb6L/EyTSSyz32FABuWaShSW3jx13ouTd2rdUFnP79MsH+mimXb8vyD8IKWwr1uMa/
         /Of/Ymlku5YJtIc9/cmBsTVvGDTMa5v/baT7KzS869SnsBn01DyFI8FZnJuiwVGNb7oP
         Z+oCW2zeWjgvgofCxOgMaTMVTQIWlFG+Ih01CtY68lSXEacRGTfdZq9/25un8y0Q7Var
         rPtQROMHDnmMBeMjnOJjyHGVsHJ9mDJ8xHHJc9DNf81png5qHlaf0Kwp0tW+No3aaLuj
         zF2GFItuZjz0uyCnj9jzB2DfA8tkHmCst4TnSjN6EnfN+fGAwHids/2SoL69M/tMMPt6
         Jv4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUFBkdTg7ZaXOEsYJs/4TOwLFotED5p5Me66ttkJgocpeIQ89oP
	s0S4yhnnCQSzpDYNl2Me6FCcTcb1TQm2Vmn7f2MpfAdVg28uRTlltWbtyT/ViwMEKuoggJ2IZUX
	+XBra0NMPXoZ34Ag+abt2Qoj1nP0VQy/D6qszFK67xfWAWKkT8cQXQFKs2AGn/HuuJg==
X-Received: by 2002:a0d:d742:: with SMTP id z63mr38822015ywd.286.1558506072565;
        Tue, 21 May 2019 23:21:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKd+PRk4rjGEOh11zSZZCBeq9JWgawYxkqPX6gxSbsqjOIZybbzjWySSGF8X6l29o0zBBi
X-Received: by 2002:a0d:d742:: with SMTP id z63mr38821995ywd.286.1558506071715;
        Tue, 21 May 2019 23:21:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558506071; cv=none;
        d=google.com; s=arc-20160816;
        b=iggXu32MpVozISwGSxxk/om+TGdgCnPnt3wLjXB2QX639Ot6dGsRB9JaZM6OTua31G
         6s20Gp4gL5uvCYF5h5YswxPK4HlyB39Rf+loM8qfbhtUlMRKf2Qe0yDRrNyQ2o88XfTP
         XG9ubSVibaEmrUunmGg58y4hrbTv5J/lCIka6Ov7AI2AWNOACpHvXbrCLgi0zSojU8f3
         SXyF2Csdh/p0zucklWDSHapayvtFbDsaPOhnccIJUpiSf2OESNZacMenPWuSIr2VsE58
         bHbgw6rB2GD5nMoUvovZAc9G3Y3N8Z/7fxFeS0f/FyvvyY+UySGnc76zDEfTCBXFO2UE
         vD3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=rDhCH59MNuzThhgCtp6sXNBsgY+rxc19SMctO58eL0k=;
        b=rPMfOyUCpLFLwJTbfb5T2Jwtjf2ZqCymTbiIJxjGEXzHS/1KbXkwLg0tzi+vumc3HI
         vPg/TXkn7nPQuHnNfsS1gLFqrTeh9AWC9N504DxXI/IfpcVCFN6ijRqC9EwbeouqaJDU
         BcKQxXjGgYt3zG+OI94fkVB37ys9itB9emiuorAANOOI9CSGt2rXwXl+ITRybPTLP7z2
         gIcBFlm2/Z5hQkxjOBMFk2M1A1oG/F2EBLhS9EKPcGRWKMHr3NTn61zwrMnLqgWJDpEG
         RMWwNmpotOP3QxKkGYgwroyE380cTEaJH7whoZfQ/0PC1uiCDDFVK/WXBoqdq6oBDTjp
         8sCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a206si6816050ywb.14.2019.05.21.23.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 23:21:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M6HJGx047322
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:11 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2smyx6jr73-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:10 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 07:21:10 +0100
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
	by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 07:21:07 +0100
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M6L6eh35193030
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 06:21:06 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 23E37112066;
	Wed, 22 May 2019 06:21:06 +0000 (GMT)
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A7CA3112063;
	Wed, 22 May 2019 06:21:04 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.87])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 06:21:04 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH 1/3] mm/nvdimm: Add PFN_MIN_VERSION support
Date: Wed, 22 May 2019 11:50:55 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19052206-0040-0000-0000-000004F2D313
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206843; UDB=6.00633755; IPR=6.00987819;
 MB=3.00026997; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 06:21:08
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052206-0041-0000-0000-000008FEE6E3
Message-Id: <20190522062057.26581-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows us to make changes in a backward incompatible way. I have
kept the PFN_MIN_VERSION in this patch '0' because we are not introducing
any incompatible changes in this patch. We also may want to backport this
to older kernels.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn.h      |  9 ++++++++-
 drivers/nvdimm/pfn_devs.c |  4 ++++
 drivers/nvdimm/pmem.c     | 26 ++++++++++++++++++++++----
 3 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index dde9853453d3..1b10ae5773b6 100644
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
+	__le16 min_verison;
+	u8 padding[3998];
 	__le64 checksum;
 };
 
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 01f40672507f..3250de70a7b3 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -439,6 +439,9 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (nvdimm_read_bytes(ndns, SZ_4K, pfn_sb, sizeof(*pfn_sb), 0))
 		return -ENXIO;
 
+	if (le16_to_cpu(pfn_sb->min_version > PFN_MIN_VERSION))
+		return -EOPNOTSUPP;
+
 	if (memcmp(pfn_sb->signature, sig, PFN_SIG_LEN) != 0)
 		return -ENODEV;
 
@@ -769,6 +772,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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

