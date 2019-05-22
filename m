Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5A6CC072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:27:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BAE21841
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BAE21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 328B86B0008; Wed, 22 May 2019 04:27:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D82A6B000A; Wed, 22 May 2019 04:27:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1793C6B000C; Wed, 22 May 2019 04:27:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3C056B0008
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:53 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a90so947038plc.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 01:27:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=vI7PeKSqAKLLXfk0D6JsmO6VGJtlc2FvUpFvOX5yWxc=;
        b=ohEVFt0sMGCryPu3RhjIAe3hjAYhKEaUhP1nMUoU0X+ooischHZGqoKztC1unT6Tru
         zAYtPJX3Sn/4rDn3duYvHJr3RsMNOfhQ2CYV3prAWjTRP9a1G24RNpxqUb8bGvUWg9ez
         4jhslTcannjlUmSY0NKKhlEjoUX7bpktOIDQYWKj/es85ZaU5HMax5nw3G3yUl6kbO4x
         puBnsLNOY8qKSSnRrOfxv7CcLVYTZGMv4TCdeADX2U3IYEUlxWtSS7Pdg+OPhvcB1adB
         efJ5g9IY/bin7hXCzt7o9+LVGegMRb+FqFihPz73M1Q54sCHfj1p7kO2B8sbg0Ys219A
         Mk2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW8OeUZHseimJAvjVoRhHzJOTNhgM4FdNaqeFRSKN6YkYLZnVkO
	YCTDfwV+m5vHbcEkWB7uY3nBUeBOcxHsFUZRPAnM4+vKghjOy7wPDp8yhraSxExn/POQgJVpBg0
	5S5RKydlrjCcc4Dsb0tUN3I9+0pM4Wp2kXi9WAJsvSmos4Tv5SPnFH0PKwk9eS/5K+A==
X-Received: by 2002:a62:3605:: with SMTP id d5mr73580437pfa.28.1558513673509;
        Wed, 22 May 2019 01:27:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF1bMRtPizuAYi5Cadu2BZ+Kk0DxyDR6q2Up0J8/E8Gs8ChA9XIB+gzMqUBbqKibS7nOXx
X-Received: by 2002:a62:3605:: with SMTP id d5mr73580344pfa.28.1558513672750;
        Wed, 22 May 2019 01:27:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558513672; cv=none;
        d=google.com; s=arc-20160816;
        b=Cl4Oz4lHht3Vs5Qzf1lYJCmimcxH8byW8l8VEfx7VuUXm1MP9Nk9H7gms/Q6omGkqz
         IzK3lY+eu3tmAL2T5F6lEIdpdJhBbCVOqpuR+/B03nMKzr4Hu64wgUDAsFJkdEcE0R1s
         oJLQoetYIO0f4f21XNTKdv/QQ6ntI4ymuH7URMivtLFFr5wFtdPjeipTp0Wrkn+Rh+/w
         TQghtyde2vVQ6TaY5KWk/z0LvHNOXVbyvUS/9jPtGLQBbrhTedUCmehVSAuVHJl8mekU
         uXH03w8fWf7FrMI+F2QOxamoPaOFELaXbELdDdnQH4UKpjEfq0Eoxngt0imUV8yPHpb6
         t4lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=vI7PeKSqAKLLXfk0D6JsmO6VGJtlc2FvUpFvOX5yWxc=;
        b=eSD6L1EZrSft7k/3E8ctf6CZ742lAHOazDMHixNkAj3OqkqfCVfMoxBth+NDFaap4M
         J2mXd/33rB29gR8LMwIyCaU8MYqsoI7GMBDmEfVC2/rc1BHCvyvfHuCTxyRkr/aM8LBu
         eArdRZ3NsHjuxZuNrpOYf51yq2ekN9T9YLrW1avgoSNHPKReIurNcWwGEMiTdR8fTxS7
         tEIrObXp12lIadegsbB+j8rQWw6otbVGHB96aygjKg17F5NlOmyVDbbdu5WfC3HXAI9a
         8KU+M2pB/1dP7oab9OOfMfpkBYP5XcwhdLX52BAFLqic5ijjNIicsqoES5La9iLxBsiw
         QOkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y10si10483541pfp.167.2019.05.22.01.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 01:27:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M8Ro4K102482
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:52 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sn205tjkn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:51 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 09:27:13 +0100
Received: from b03cxnp08026.gho.boulder.ibm.com (9.17.130.18)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 09:27:10 +0100
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M8R9H212583204
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 08:27:09 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6C6DAC6057;
	Wed, 22 May 2019 08:27:09 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C00EAC605B;
	Wed, 22 May 2019 08:27:07 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.87])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 08:27:07 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH V2 2/3] mm/nvdimm: Add page size and struct page size to pfn superblock
Date: Wed, 22 May 2019 13:57:00 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
References: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19052208-0012-0000-0000-00001739F84E
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206885; UDB=6.00633780; IPR=6.00987860;
 MB=3.00026999; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 08:27:12
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052208-0013-0000-0000-0000575C5264
Message-Id: <20190522082701.6817-2-aneesh.kumar@linux.ibm.com>
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

This is needed so that we don't wrongly initialize a namespace
which doesn't have enough space reserved for holding struct pages
with the current kernel.

We also increment PFN_MIN_VERSION to make sure that older kernel
won't initialize namespace created with newer kernel.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/pfn.h      |  7 +++++--
 drivers/nvdimm/pfn_devs.c | 19 ++++++++++++++++++-
 2 files changed, 23 insertions(+), 3 deletions(-)

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
index a2268cf262f5..39fa8cf8ef58 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -466,6 +466,15 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
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
@@ -481,6 +490,12 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 		align = 1UL << ilog2(offset);
 	mode = le32_to_cpu(pfn_sb->mode);
 
+	if (le32_to_cpu(pfn_sb->page_size) != PAGE_SIZE)
+		return -EOPNOTSUPP;
+
+	if (le16_to_cpu(pfn_sb->page_struct_size) != sizeof(struct page))
+		return -EOPNOTSUPP;
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
@@ -775,11 +790,13 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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

