Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39037C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E51FC2080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E51FC2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFA346B0005; Thu, 20 Jun 2019 05:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A83628E0002; Thu, 20 Jun 2019 05:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D4538E0001; Thu, 20 Jun 2019 05:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69E6D6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p76so2317013ywg.5
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cCTWCJmLM0r4llmHyOPcBCm2p9igblEXyjzvCISLi64=;
        b=QNcCnYHErZiMqNpRL9Uj/0xjkIZmgX1+1xHRpxFzxFCxrz9gCVQzOGwm6grbrXCn2b
         D8EXbM2p9Q599xhkFgtIqoGDZ+wIoyvGtJSN/d6OnEsyUydz8+eXD6KG6Zm6XjZpmqHX
         Xh/1P9l+BB+a/GUWaAPU6F6JFFialjaugMwZ7eBQ/iyLcFlntDXSlyFSJpCBfb7XSRRg
         +qGB4m0jiN9VzTOhrGQrfmGP1OMIOomE7dcDjlfE9wuosRvRU1sYsOSy0Q8hvWs41k3R
         1mbwqKzVzUWwTbp80g4vYchVp0Nailpo4XJ34SBhA0lZ0V7j8cb5F//Kg4BIY8hURzSZ
         V7dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXizFEhXQSR+WffvkQY9jJpy23aOh/OPSfxqLwS3pg6y4oyNUnU
	EJyg6e34kAO51W0tg0WNczLMVEfkOt2U57ZVwnvzw1l071oKr4OaI5crH6WGW+EqOJu0LwuhrSv
	//oxEPrqIdqDxmqmIokgQrM5S5sF7rTxIf1yDxalOhBtemFGka/EN+OtjlrS8pDtKuw==
X-Received: by 2002:a81:4c44:: with SMTP id z65mr3876433ywa.4.1561022237106;
        Thu, 20 Jun 2019 02:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1hA5TjGwA2Ht6BMURzB7v29IcYsyG9v8I7s7cLUTLCcZfEhKORmSSnnMNpTtKKqsSru+b
X-Received: by 2002:a81:4c44:: with SMTP id z65mr3876368ywa.4.1561022235450;
        Thu, 20 Jun 2019 02:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022235; cv=none;
        d=google.com; s=arc-20160816;
        b=a3T4+ChrsS33PL2XMr9jZM32AOYeMgpiTQ5nPxWzCJXP+3BSisu9Bz94oaj4G/7dKm
         l2fJoBAGRNGCB7c3dtrMgot3suENeeOCQdxaxOw+QXkeZ9Lwcm36nnlZfEouQDP2owDx
         t4KSawEN3m06/pbq0O5y7x1c4mr4MkUdzXwB7N1aCfzwQoG2OM5G5n4ypX5zaqe7h1Au
         pBVknQFfE2rfp0MaO890auq1ppA8rAnf/UpT8vD7AVLgXBkYNoeSMeLnoG952rm1H3qb
         v8j7RoL9XqCTAC+zxsZYWbilztQHHLJVL7MGX/H/lIfhXUv3bRVOqHnEgM9833weYzu1
         bMKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cCTWCJmLM0r4llmHyOPcBCm2p9igblEXyjzvCISLi64=;
        b=SxGORZm+VsEN4WKyn7ynFIBljQI96U0b+6PUmuFrHD2sXgCK39hcM2FasqdftRMva3
         6m4gt9Pa/BujCaGB/1DIdKak9StlwEC9BjPZJYbI8TE0S4yOvNkx9sUJ2SiVo1VRwpkD
         euRw3PSOEO/qXLf/lY3TcS0ocA5g/Doarznjo029kTA0ZvSZricg7inPsn7U+hkCagl+
         NIMczLcrgMAoIkNScYKdTwSS2XJujU5w3xstuRWnVNKrJHhxKLBT3YS0nEpGw9rVMc7z
         VEUYzpVOer3J9aAbrL345M6xcnN651dHKBJwMqsJHt5W//r3CUk9uVOCsLP4xwOmAjeA
         FNVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r13si7020494ybm.497.2019.06.20.02.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K9692V122435;
	Thu, 20 Jun 2019 05:17:13 -0400
Received: from ppma01dal.us.ibm.com (83.d6.3fa9.ip4.static.sl-reverse.com [169.63.214.131])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t871xrs45-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 05:17:13 -0400
Received: from pps.filterd (ppma01dal.us.ibm.com [127.0.0.1])
	by ppma01dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5K94k2x024184;
	Thu, 20 Jun 2019 09:17:12 GMT
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by ppma01dal.us.ibm.com with ESMTP id 2t75r12xet-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 09:17:12 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9HBam33227140
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:11 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9925AAE060;
	Thu, 20 Jun 2019 09:17:11 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18769AE05C;
	Thu, 20 Jun 2019 09:17:10 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:09 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 1/6] nvdimm: Consider probe return -EOPNOTSUPP as success
Date: Thu, 20 Jun 2019 14:46:21 +0530
Message-Id: <20190620091626.31824-2-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
References: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200068
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
 drivers/nvdimm/bus.c         |  4 ++--
 drivers/nvdimm/nd-core.h     |  3 ++-
 drivers/nvdimm/pmem.c        | 26 ++++++++++++++++++++++----
 drivers/nvdimm/region_devs.c | 19 +++++++++++++++----
 4 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 2dca3034fee0..3b8ffb3966ab 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -92,8 +92,8 @@ static int nvdimm_bus_probe(struct device *dev)
 
 	nvdimm_bus_probe_start(nvdimm_bus);
 	rc = nd_drv->probe(dev);
-	if (rc == 0)
-		nd_region_probe_success(nvdimm_bus, dev);
+	if (rc == 0 || rc == -EOPNOTSUPP)
+		nd_region_probe_success(nvdimm_bus, dev, rc);
 	else
 		nd_region_disable(nvdimm_bus, dev);
 	nvdimm_bus_probe_end(nvdimm_bus);
diff --git a/drivers/nvdimm/nd-core.h b/drivers/nvdimm/nd-core.h
index 391e88de3a29..4e6ffa0d89bb 100644
--- a/drivers/nvdimm/nd-core.h
+++ b/drivers/nvdimm/nd-core.h
@@ -126,7 +126,8 @@ int __init nvdimm_bus_init(void);
 void nvdimm_bus_exit(void);
 void nvdimm_devs_exit(void);
 void nd_region_devs_exit(void);
-void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev);
+void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus,
+			     struct device *dev, int ret);
 struct nd_region;
 void nd_region_create_ns_seed(struct nd_region *nd_region);
 void nd_region_create_btt_seed(struct nd_region *nd_region);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 24d7fe7c74ed..422b11c01301 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -497,6 +497,7 @@ static int pmem_attach_disk(struct device *dev,
 
 static int nd_pmem_probe(struct device *dev)
 {
+	int ret;
 	struct nd_namespace_common *ndns;
 
 	ndns = nvdimm_namespace_common_probe(dev);
@@ -512,12 +513,29 @@ static int nd_pmem_probe(struct device *dev)
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
 
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index 4fed9ce9c2fe..1e74a1c9fdac 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -715,7 +715,7 @@ void nd_mapping_free_labels(struct nd_mapping *nd_mapping)
  * disable the region.
  */
 static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
-		struct device *dev, bool probe)
+					   struct device *dev, bool probe, int ret)
 {
 	struct nd_region *nd_region;
 
@@ -745,6 +745,16 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
 			nd_region_create_ns_seed(nd_region);
 		nvdimm_bus_unlock(dev);
 	}
+
+	if (dev->parent && is_nd_region(dev->parent) &&
+	    !probe && (ret == -EOPNOTSUPP)) {
+		nd_region = to_nd_region(dev->parent);
+		nvdimm_bus_lock(dev);
+		if (nd_region->ns_seed == dev)
+			nd_region_create_ns_seed(nd_region);
+		nvdimm_bus_unlock(dev);
+	}
+
 	if (is_nd_btt(dev) && probe) {
 		struct nd_btt *nd_btt = to_nd_btt(dev);
 
@@ -780,14 +790,15 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
 	}
 }
 
-void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev)
+void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus,
+			     struct device *dev, int ret)
 {
-	nd_region_notify_driver_action(nvdimm_bus, dev, true);
+	nd_region_notify_driver_action(nvdimm_bus, dev, true, ret);
 }
 
 void nd_region_disable(struct nvdimm_bus *nvdimm_bus, struct device *dev)
 {
-	nd_region_notify_driver_action(nvdimm_bus, dev, false);
+	nd_region_notify_driver_action(nvdimm_bus, dev, false, 0);
 }
 
 static ssize_t mappingN(struct device *dev, char *buf, int n)
-- 
2.21.0

