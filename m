Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5996C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A8F12086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A8F12086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367246B0006; Fri,  9 Aug 2019 03:45:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF516B0007; Fri,  9 Aug 2019 03:45:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 208596B0008; Fri,  9 Aug 2019 03:45:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id F17AA6B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 03:45:40 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id s17so32988573ybg.15
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 00:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/VHRUY+DXfPpmqKgC4rYAop9p4HtmpgmApwNSS+7/Dg=;
        b=XXTzQHx3w8+bMVYKFdeik7CnvsFEvfkW9T4kmPyOCTROjwzNuSAAHjXruh3q0X39oj
         Yq7EWGZb5Ng9BzgJgHKDeXokEGlO/qFmcS4YHVIfd4LX6uUqOoCOg6fTntwFyi9bbeXF
         NsmpAQR1CEwqbP/u76xUZ92QdykbO7TgOyE2lc8rK4N0IbIHcJ8d+dLyVq5EOCjXTQlO
         rbJQlC2VJe7aPcoBKqv9WqaTky+R0Is7PmD6IMnYl04VXWiUkJoJsHbNeH/V9c2tPEUb
         x5qjAR2rDFuZ+YasOHrXpr1lGfC8AtzbLFbPCFlBs1Zl2oU6X9ymo8JPLHnI3B33DOG2
         5DWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXzfK6TrQABbusd2rcUFeurjdBC/6t0RxBioRytIzTnCQG0K+UF
	uwCyvoJcrkT3hB4DvP7SPhh/f/3UFnr1T5d+7IXwuPO1H2GWwiJsQP8B+R16MOxvcfEtnENrkRN
	J+W7D0WPXKROH/DLR7QLmZdkyrPJKZgyRYSejPCVoMDvM/x2EektKIffzNHjWqOVUSQ==
X-Received: by 2002:a81:9889:: with SMTP id p131mr8814321ywg.127.1565336740772;
        Fri, 09 Aug 2019 00:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOq1fDXCg8Qf8DUbwZ07ENw3RxB+gl8puvijbP9DOJDW4Y1SNSKm5K6GiK+MuaqZeF5AAs
X-Received: by 2002:a81:9889:: with SMTP id p131mr8814282ywg.127.1565336739636;
        Fri, 09 Aug 2019 00:45:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565336739; cv=none;
        d=google.com; s=arc-20160816;
        b=Q3ydF27eeBvwF8wJsvmG+3QHgR+OAvUXNQgRRuL7XyIr4zip7qk6W7f+BTXzB5Nak2
         9tLShdjR9wJHCzMLGhGsIG8ovdEcH1seXjkg0w6CksipPJSn4Dew+tgFXWszlGmJvX1x
         kc1v5NG6qvzoAPXv/Pk1OmVDwG8c80SP2ODq3bad5HsiWKUg1AGI0STZofsgtoJ8hJkt
         0dSEdmhq54tULwnr2TxbtRVu6+n14cxRqg6snQGDePHYzcwyR+BeJsdWhLbBAnzxEcCu
         UsMhI6Ddl+15yzF0xIisA/34CXUD48RN1d2Ioki8JzRhjISszUeZ2xLAcdLL/4X4kvUt
         0fyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=/VHRUY+DXfPpmqKgC4rYAop9p4HtmpgmApwNSS+7/Dg=;
        b=gefO6JxzjAk1JgbzqrghFtwKF6o3NvPxqYbxlQC1fo7bD9GtARXfj4PPi8jkF8yVGo
         sYayepF0C2cC/84qLB4hAZkk/GFRF/Ra7E8nSNk31kG4BL7JJ/b/fQxomusMoGl5Z+yy
         UNIIEpxpWqwIP3vOUV6hsBdH4EXKJbvNGi5g4AVN6oesN+hazUpmPSOhbeH7QOqEvAGv
         2XfYzOWbsezgASznHTK1JPAxEenOGghklI76cZ6hPfogr2BnxXngo1/wWO7YzV30sKna
         6tEzLThkMxUfvY3D9fWdEdL6B0dpm7MpQtMPCkaT3zz3hozoQYv8g7YaxufrJ+9+4+ku
         uK4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v2si33037240ybo.248.2019.08.09.00.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 00:45:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x797i6KU131658;
	Fri, 9 Aug 2019 03:45:38 -0400
Received: from ppma02dal.us.ibm.com (a.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.10])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u93rxt5xg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 03:45:38 -0400
Received: from pps.filterd (ppma02dal.us.ibm.com [127.0.0.1])
	by ppma02dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x797hiui004382;
	Fri, 9 Aug 2019 07:45:37 GMT
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by ppma02dal.us.ibm.com with ESMTP id 2u51w66ww8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 07:45:37 +0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x797jaiM61341998
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 07:45:36 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F3B9E6A047;
	Fri,  9 Aug 2019 07:45:35 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 01B246A051;
	Fri,  9 Aug 2019 07:45:33 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.36.73])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 07:45:33 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v5 1/4] nvdimm: Consider probe return -EOPNOTSUPP as success
Date: Fri,  9 Aug 2019 13:15:17 +0530
Message-Id: <20190809074520.27115-2-aneesh.kumar@linux.ibm.com>
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

This patch add -EOPNOTSUPP as return from probe callback to
indicate we were not able to initialize a namespace due to pfn superblock
feature/version mismatch. We want to consider this a probe success so that
we can create new namesapce seed and there by avoid marking the failed
namespace as the seed namespace.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/bus.c  |  2 +-
 drivers/nvdimm/pmem.c | 26 ++++++++++++++++++++++----
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 798c5c4aea9c..16c35e6446a7 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -95,7 +95,7 @@ static int nvdimm_bus_probe(struct device *dev)
 	rc = nd_drv->probe(dev);
 	debug_nvdimm_unlock(dev);
 
-	if (rc == 0)
+	if (rc == 0 || rc == -EOPNOTSUPP)
 		nd_region_probe_success(nvdimm_bus, dev);
 	else
 		nd_region_disable(nvdimm_bus, dev);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 4c121dd03dd9..3f498881dd28 100644
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

