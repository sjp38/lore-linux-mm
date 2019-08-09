Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC45C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 057C22086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 057C22086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A476B0007; Fri,  9 Aug 2019 03:45:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90BED6B0008; Fri,  9 Aug 2019 03:45:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FF76B000A; Fri,  9 Aug 2019 03:45:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1E56B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 03:45:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so57036273pla.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 00:45:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vBh7ndphK1zAwismU4hNm+W0DgZu0+OG2oq0WjLVa+w=;
        b=XDO4XB80qXhD8dkkZbf8mn5Dcplkes/m976tacNp73tptUjcBYu30DcFH+Tu3Hcsqm
         KButerb6nes6sK48pJM/N3Gkz4FmBMdhbbtZS6btTgdw6s1pWEsE3B/4/ml6X38IhWNM
         InjXeim5T0FUe2EOrl/Dynts+fwl/jvk+/klgI79sVp0nPssKHrv9mh2V4bpRe4UcqaV
         s7CedJoKHjsGxzXHnIDNGpnGhKSViItyb7t1vcFWTF/gipmHLno5O1qzPqlLp0MSiRcS
         bLOmoauxpuqqjtWg4kZHFzBHTDQWOshtsblPt27ka7vSAcSjRq8YM5RzvQS+GFb3U/dS
         ra7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW6bYwsZfbtcU0d12XYbTu/QHtkSA3nxtytktu5kxqVdI3X2379
	mX2gGX/1tLXl/qfUQ8LYFXjsU67CNlu3+LDpqCPVhc+SmveEV/XDGDnTH3vyAaxwUMxjyJj9HM3
	B5fiNgrjxAYldMGs/TWTEh8ez2GRMWTD0Otsz5xH4zvyksmta6nVwaBCS+VAejXfMhw==
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr8341599pjr.116.1565336742778;
        Fri, 09 Aug 2019 00:45:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8jan7KkkfhDO61IzI5TlfFaDggT3u9Q816+OUVgtUBR/Tjb4FcVhmjKXajdvgNRV9t4SX
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr8341549pjr.116.1565336741996;
        Fri, 09 Aug 2019 00:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565336741; cv=none;
        d=google.com; s=arc-20160816;
        b=MdbFGQWMX/p0ATciB3s+OLCB8vccKeAo2GvBJi7IObU225xmw6JYGTmWcmBNj+smTT
         HmeK2qD4JOnC3dPgpvb9/ZLpoD4s0mO0YlL/rqI7NjnQRC1rYYyvOhgWCZP2th7jX+zf
         t2x3t/+aQ6dTjRYykJKmbx9raeiJv4q4X7Hs0grA564sJzdtspKR1p/PE2l/uaswqgtq
         WpoYhGY9a3JSofzIxO1wZFgrkIedC7EU/ZnCOt8TE1gAr9OQXRhjElnoN7C8gaWhmcZ2
         TVUWYEF2ZLv+JEJ0/gGMhZmskw6hSVOjlTuJzcS1Z+awvLkc6wgxTVkZfhX5BNDOYCpt
         GUxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vBh7ndphK1zAwismU4hNm+W0DgZu0+OG2oq0WjLVa+w=;
        b=RAQpTTmJmn651srtQQ+f00y5yebMyrudxKUFaBgNAT39VS9AOpTTCQgPnNvxFKX3hG
         LY2pfOClc+C71CLShEKfedQ/c+YANHDJxcp2Q+/8ziNvRMksjR1RQjUYZS0uhipl3gpm
         DR/LJ0rMDPExQHvfSjy0KoQyICv1FgTMlo5jFGMotNlxEXUa9TjvZakm7QelV75cogdp
         Q4dF1fZkm3szMKMrYRyXQFbvZOKh+ByXh15OLVIxBmTbBI0uV79Snsj1jQuEXnEpFWd/
         5agZgzduAu5+K4P4HMVHNGjQ29NlsH8EyDQlwYu9FnXlFm7vJn1hMUfJ0yw57GTRHd3U
         kRgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h189si45311141pge.36.2019.08.09.00.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 00:45:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x797hWGx129219;
	Fri, 9 Aug 2019 03:45:41 -0400
Received: from ppma04dal.us.ibm.com (7a.29.35a9.ip4.static.sl-reverse.com [169.53.41.122])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u93rwj3ta-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 03:45:40 -0400
Received: from pps.filterd (ppma04dal.us.ibm.com [127.0.0.1])
	by ppma04dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x797hdn7012259;
	Fri, 9 Aug 2019 07:45:40 GMT
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by ppma04dal.us.ibm.com with ESMTP id 2u51w7cqkf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 07:45:39 +0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x797jcet62194166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 07:45:38 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9C4356A051;
	Fri,  9 Aug 2019 07:45:38 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9DEF66A047;
	Fri,  9 Aug 2019 07:45:36 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.36.73])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 07:45:36 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v5 2/4] mm/nvdimm: Add page size and struct page size to pfn superblock
Date: Fri,  9 Aug 2019 13:15:18 +0530
Message-Id: <20190809074520.27115-3-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090080
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
index 3e7b11cf1aae..37e96811c2fc 100644
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
+	if (le16_to_cpu(pfn_sb->page_struct_size) < sizeof(struct page)) {
+		dev_err(&nd_pfn->dev,
+			"init failed, struct page size mismatch %d\n",
+			le16_to_cpu(pfn_sb->page_struct_size));
+		return -EOPNOTSUPP;
+	}
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
@@ -722,8 +745,10 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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

