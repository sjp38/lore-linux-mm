Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06B8BC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2DA32080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2DA32080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B95D56B0006; Thu, 20 Jun 2019 05:17:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9018E0001; Thu, 20 Jun 2019 05:17:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EABA6B0006; Thu, 20 Jun 2019 05:17:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0F36B0007
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so1228539pla.18
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b8UP/hdXtOmiB+VdIAglrJbzq9xAyBHNji5ed5obDZ4=;
        b=XX9jl77uWnf2rEFNLcnyvjZbQU68jPpYDW0ORM2WL6icTtbs6S1J3XnUBSwFw9IlXU
         O+ZCCAVA7ljvY8NJrhIr2kVQq4nWrVyE0frQpkL1Xh97343InA1USjBsMtGAKXyZeZpe
         dtne3DPFJluW7Fjm1yZNEu/hPr1uNDmqX+XiCs1/YfxfKMxF7RqrcA0sgkKrWD6iPt3c
         yC2gvvduRcMv9RrVdakmD5IPNSLBnlICeSPONzabjH7Z5q4V5zEMmOPYfVPMX1gFv6/g
         AvHcudO3rxA7mwd+FLtAUG7aLfY3M9n9gyEGXC28U6w2f2GwW3ZEAyclgRc2EZoLxaXF
         1KwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVu0JxQfyUee/HJBRBGhokoqjTsYKnzZU61lclwwiUzUPZyrzZD
	0cl4lAyk6Rku+yjuKoVzQjLJJdqY14SFdiajgQT44sbIY8V4HcEl8L5Rh1pCN8dkCmb1F0JKV59
	t0CAitM8wbTY070eoYkbP9i8cd0Prion5viR5rLRonh38QRnqLoYxIqQGfhLjbOOqDQ==
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr30173667plp.59.1561022242847;
        Thu, 20 Jun 2019 02:17:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6shoR+lh3UJ9967AaoSbEUvkkBVSwtZ3FTe2B+2OvFDd/saRP8KsHPd+mBGBaFl6/0cXM
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr30173594plp.59.1561022241682;
        Thu, 20 Jun 2019 02:17:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022241; cv=none;
        d=google.com; s=arc-20160816;
        b=aL59Jsj8XcTaZEmFUzBnxSFsSyFlV894mVT/uiH2hbnW7HDZ2r00eJUDaTCAWr2Ajt
         Z0skvlQDyXwoldgJy8gHTJU1cUDfOJMl44WKxVd1Qg+BtmtPklYXxTcgiH+54MuY5+VB
         EUHWPSzWQKHR2Z+nrJvnLQg3vtqGuXsV2ZXJHX4vzU3TSWEWDGdoHTX1kn6nS04Z1MRk
         o0QhiSZtnLHoYdibPysavqWmzQhRMOMOi+2ngfLrsWOCuj9ha111KD5WuiHJMbtSnKSZ
         zVWt/AE97lEmX0TJlqzpH1h6es0QzwKQnem+8DyUL3HlMO6F9WPwGPExp5li/ruWZgmk
         esOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=b8UP/hdXtOmiB+VdIAglrJbzq9xAyBHNji5ed5obDZ4=;
        b=fmqZsbbYwBdhX9Gt8VdOO0BufyEdWVMicggPp7kOzTf/+pZ4OJkkkdI5gqj//nMrha
         mUOF0+R4HbS+mWprIgPNp0ahrcF/rzHMGlNsFAjI4b3xWzVwQja7U8WkZ0QDgVI9Xs0L
         30p8ZnAaq1XyXgcnqjzOE1hTkQM4PspTH7qh1WDxE/LRAKiaLpblS59uzPHGwcL0MvvP
         NSKv2rDf6CpAfUYnzMVCsFISPVnsFcQ37LmpJhuVKEgV3egQHvHgqdy4TDK+vLubRe75
         qu3xh4n+4yC0T0AX2QxlCtPHOop/zJ22N4oKrx80Q6GsOfdbPkbUoEvVWesNRUeXC26W
         ugOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q19si3814891pjp.24.2019.06.20.02.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K94oBd080645;
	Thu, 20 Jun 2019 05:17:17 -0400
Received: from ppma04dal.us.ibm.com (7a.29.35a9.ip4.static.sl-reverse.com [169.53.41.122])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t84kped58-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 05:17:17 -0400
Received: from pps.filterd (ppma04dal.us.ibm.com [127.0.0.1])
	by ppma04dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5K94k2k009595;
	Thu, 20 Jun 2019 09:17:16 GMT
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by ppma04dal.us.ibm.com with ESMTP id 2t4ra6gqu6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 09:17:16 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9HFJ534996576
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:15 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7F7F9AE05F;
	Thu, 20 Jun 2019 09:17:15 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F3F23AE063;
	Thu, 20 Jun 2019 09:17:13 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:13 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 3/6] mm/nvdimm: Use correct #defines instead of open coding
Date: Thu, 20 Jun 2019 14:46:23 +0530
Message-Id: <20190620091626.31824-4-aneesh.kumar@linux.ibm.com>
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

Use PAGE_SIZE instead of SZ_4K and sizeof(struct page) instead of 64.
If we have a kernel built with different struct page size the previous
patch should handle marking the namespace disabled.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/label.c          | 2 +-
 drivers/nvdimm/namespace_devs.c | 6 +++---
 drivers/nvdimm/pfn_devs.c       | 3 ++-
 drivers/nvdimm/region_devs.c    | 8 ++++----
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
index 73e197babc2f..7ee037063be7 100644
--- a/drivers/nvdimm/label.c
+++ b/drivers/nvdimm/label.c
@@ -355,7 +355,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
 
 	/* check that DPA allocations are page aligned */
 	if ((__le64_to_cpu(nd_label->dpa)
-				| __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
+				| __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
 		return false;
 
 	/* check checksum */
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index a434a5964cb9..007027202542 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -1006,10 +1006,10 @@ static ssize_t __size_store(struct device *dev, unsigned long long val)
 		return -ENXIO;
 	}
 
-	div_u64_rem(val, SZ_4K * nd_region->ndr_mappings, &remainder);
+	div_u64_rem(val, PAGE_SIZE * nd_region->ndr_mappings, &remainder);
 	if (remainder) {
-		dev_dbg(dev, "%llu is not %dK aligned\n", val,
-				(SZ_4K * nd_region->ndr_mappings) / SZ_1K);
+		dev_dbg(dev, "%llu is not %ldK aligned\n", val,
+				(PAGE_SIZE * nd_region->ndr_mappings) / SZ_1K);
 		return -EINVAL;
 	}
 
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index cd722de0ae03..9410d2692913 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -726,7 +726,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + SZ_8K + 64 * npfns, align) - start;
+		offset = ALIGN(start + SZ_8K + sizeof(struct page) * npfns,
+			       align) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
 		offset = ALIGN(start + SZ_8K, align) - start;
 	else
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index 1e74a1c9fdac..b9992499a035 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -997,10 +997,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 		struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
 		struct nvdimm *nvdimm = mapping->nvdimm;
 
-		if ((mapping->start | mapping->size) % SZ_4K) {
-			dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
-					caller, dev_name(&nvdimm->dev), i);
-
+		if ((mapping->start | mapping->size) % PAGE_SIZE) {
+			dev_err(&nvdimm_bus->dev,
+				"%s: %s mapping%d is not %ld aligned\n",
+				caller, dev_name(&nvdimm->dev), i, PAGE_SIZE);
 			return NULL;
 		}
 
-- 
2.21.0

