Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB3C5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98C102086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98C102086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 450D66B0008; Fri,  9 Aug 2019 03:45:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D8F66B000C; Fri,  9 Aug 2019 03:45:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9496B0008; Fri,  9 Aug 2019 03:45:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9F6B6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 03:45:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so56934284plr.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 00:45:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1cpAcPJA1eSwXtvLgTUBIv62UJQ/nuNt1oyOWsb0svY=;
        b=kxFmwuSjKho5It7e06d8VtJNS4cfDhSr55Ilw7Vr1M/q4yxOGE7IAdcah4BkgRmNhg
         1V9IDNqSEiKxHZ7x7Q/SFBmet83WuhblY00+DZCQQOITO+pEYnBDroR7fSwSMpp4jKjm
         YusukXtbkgLAajoI7mA1FLD05kr/uYMCjLREB2eSXZjnLlqiDyyNbz77Ej3jZqQZ6rpi
         GosfcaZtrUQrPJnhtSuSBOTALlbp7CvMb0aWrb5t9lcdWQ7SYJGr1PnMGCaoZU49J/U7
         ExCl7HWY7mJI/Ba5mIsQ9qCJ6QyvGD8x3hC7cioidqbjDyJmc1CTivceamZQQluZKDPK
         eXqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXvtIZD/PvME4cES/guXKj1GkJ4/1UBkkQNk+r6Z8qdWx8HupFu
	XcvrSsBTMyzYZcBFEisvb+coOFInRZf7B+BA2Dluao9eb3sBEyXN0h6XKOJUCvRULfIZ6hljnLo
	hvF/qp33bcD4HhelDfcv00Sl4SON4SBJ9knyB0YQgPjaqgVh55bx0tVafoKX7+SExyA==
X-Received: by 2002:a62:3895:: with SMTP id f143mr19761190pfa.116.1565336746602;
        Fri, 09 Aug 2019 00:45:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq+VflTEgjtYYilH7OTgvDbs/leCW0d/O0lhuJ7YUSnQo/9bCY8KCLoKuSVVcGYQod3ajQ
X-Received: by 2002:a62:3895:: with SMTP id f143mr19761144pfa.116.1565336745767;
        Fri, 09 Aug 2019 00:45:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565336745; cv=none;
        d=google.com; s=arc-20160816;
        b=ZXr6X5vxDM+U4Gz9TsdlY/TkAIisgsj5NYPBP82MMkdUEPVTqS9me8Y3AWT4ouOZlN
         cqpEb4ooQWNycxyHTPyk1A1+hFNBBflv0vqx1LYL4Us9RiLDkjCFrR4VTOw3GX39pNol
         W5hlnGZFB6qHSk7uFSXGp0RMBmjyLv1zNppq5+DNDTebVr6Z6x5xbxVE3EyTev4s9FBS
         jCljIv5LlksxRdNrHv7lnMn4fG9FZCOoMSH8W83mQCd5Z6IycIz/BpjJlFRiopMDxDtx
         y7E7ajA6TdBWXuW2tk2kHKVniEVgYOWPgIxqch1IqqEE9m6fMrfMz4hKsLIs/9MLUpx1
         yrMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1cpAcPJA1eSwXtvLgTUBIv62UJQ/nuNt1oyOWsb0svY=;
        b=rxvM4vvitX7a7mjdGOLV32BSXozzboCTmCHt+J3Rc3+h6gQFvfLWYt2lXSCiRv0Itp
         9JyIXqtoDLwL4GU69u0ex/HOncNzB058cXicaDX2bhPpP6sYBEjILA0uViQEFk8NYHb2
         bUUmCG2Xb4ysyPW0hFkcitAe4mCS4tHyFu/TZWId13XJpif4BMKO+S0ZlQJzHQ3rPpgC
         5d2U/nXH3BK7wl2ydcSutwQtInQxD2ru5/Jbvfe69x1lrRnJIkELoy69qAnDd6OlVwLR
         P7hWLgaLKWIlrt4mNGzgpSp0n4trO50UmxeOE5WoFF/xU3URpW1e8cbalANzd8q4CLmU
         n1gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 11si50160675pla.248.2019.08.09.00.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 00:45:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x797haf3104333;
	Fri, 9 Aug 2019 03:45:44 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u91bbq0x2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 03:45:44 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x797hcSb015938;
	Fri, 9 Aug 2019 07:45:42 GMT
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by ppma01wdc.us.ibm.com with ESMTP id 2u51w73bur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 07:45:42 +0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x797jfIQ33292756
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 07:45:41 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2EA106A051;
	Fri,  9 Aug 2019 07:45:41 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 30E5C6A047;
	Fri,  9 Aug 2019 07:45:39 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.36.73])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 07:45:38 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v5 3/4] mm/nvdimm: Use correct #defines instead of open coding
Date: Fri,  9 Aug 2019 13:15:19 +0530
Message-Id: <20190809074520.27115-4-aneesh.kumar@linux.ibm.com>
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
index a16e52251a30..a9c76df12cb9 100644
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
index 37e96811c2fc..c1d9be609322 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -725,7 +725,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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
index af30cbe7a8ea..20e265a534f8 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -992,10 +992,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
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

