Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6799CC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F396F21976
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F396F21976
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53CFB6B0271; Tue,  4 Jun 2019 05:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ED926B0273; Tue,  4 Jun 2019 05:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B4716B0274; Tue,  4 Jun 2019 05:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 162B76B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:14:18 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d205so19117166ywe.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=b2waML7tUSvmlU1YGL+N0av9auW8WPFKosUBIWaxKCo=;
        b=ObU4Hc+j9zoAj4TprUmEoZ286AqYAWW2wrOyyxyKYQ20fi+snkzWKfpRTZD7aGoiRf
         4atvTqG0xZM8hHj5umlvvbK13V2+zgldGSyIUni9kCBhzDJT8XD7lB5h1k0MuJRqHrCv
         vv2NmQ0z0zfVKcTbhdZD0qonaXgtmY2SzvSQoSGu0fI75E4lMR7MnzPy8iWNHMnlZH8x
         fHONBriT12FU5zYJud6i7BSo3mgTCBlufiYTEjcw+Dj4MIz59wXXUuO2vbBu2Igs3IjC
         cdLTxM9KLL6nAbdux44WtkYOtBdH0uk66K7DVhzswtS0JMbCFvsRSo6dZ/bSp2ttG+5S
         Kzlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUcd4iWDbOA8ArwtYs2Ye5fRxtLTVlmf9AwyAhXPomZEROcKhqI
	RGIYGWGN2Qr33HfOu374j+wfypQckJ9ghCzb46bybA22Eq1wjxoIXJ3rYEapYPfRqxTsh+dYK8o
	YTr78Sb/o3kU0Nwftew+wmETdwtxVvUefoRHGOulY5BgjPGWNLBV9Qpl479/O/6z3eA==
X-Received: by 2002:a25:4ac9:: with SMTP id x192mr13562114yba.135.1559639657741;
        Tue, 04 Jun 2019 02:14:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF/xwi6DLSaIK7k4ZU/FMrgS8b27pfVIqxQbDiFBl2AX48gMyWK58sq1wjF7hAUgJqrqGw
X-Received: by 2002:a25:4ac9:: with SMTP id x192mr13562086yba.135.1559639656656;
        Tue, 04 Jun 2019 02:14:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639656; cv=none;
        d=google.com; s=arc-20160816;
        b=hfJW2Dgz7I6k8GKiNL5nAqPtIsriSGTdvPdvkryTaF8BX8pJOHsA94icEYYs7u/HrM
         tb1ZdkRoHNJCYfAi1TF7AgD8b8wimmfPbKyxipTtsZ5sAgahwkdpMJKI31CTxpHslLee
         zbQkXuvfP656fYgsj9vyTfQJ8EBiQKQlZ75wwjHZHw/GkYz2HcCEkt3NooETrW87QAoT
         b022Iqsx6q0XYRErb9Wdc3gWmp6siHyamkQ54ZpO2F00y7kTONvapkYDiZmer5T4Rj74
         MIAgn7PZIFXLnHtB9PG7ke3enJ5H1CSfPgsCSTQhv4A00DxZ6Nq0nJRLrrqS7Nw8s8mn
         drEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=b2waML7tUSvmlU1YGL+N0av9auW8WPFKosUBIWaxKCo=;
        b=Hk7BmTm8nmBMjg+lAxR0LKiM0gP+ghQvVk+nOTx/vf1yaMQxqIXevibIEXomAPyl4O
         VzSsE5AaiR8BWWHPmYVkzhvS05277FQ8kTf5oAlRK+trKD7UBAOKutx3os9tEzLwc2rL
         OWfSqj/MZPqd1FjhtmYUhThrCFVet02iS3WxHLriqsGs2V+c5rJY6dPThFRgAjKugWEM
         DzJYQwJvoAXNGC5Fs/MFxGvvXTl3bIj9J5HWuVoHO4302CpqTxsoW03sS1jCf/FUnX3E
         IpxfaCoHDuzBM97iGch897qchN6yaJUFylkUvd9NXuL/Url+djkrO/NiEbFBc5XVIVAO
         88Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 186si5251441ybq.289.2019.06.04.02.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:14:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497XcC021735;
	Tue, 4 Jun 2019 05:14:14 -0400
Received: from ppma01dal.us.ibm.com (83.d6.3fa9.ip4.static.sl-reverse.com [169.63.214.131])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swmk13qrd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 04 Jun 2019 05:14:14 -0400
Received: from pps.filterd (ppma01dal.us.ibm.com [127.0.0.1])
	by ppma01dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5438biT009398;
	Tue, 4 Jun 2019 03:19:16 GMT
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by ppma01dal.us.ibm.com with ESMTP id 2suh097pgp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 04 Jun 2019 03:19:16 +0000
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549ECGC36372878
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:12 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7058EAC05F;
	Tue,  4 Jun 2019 09:14:12 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 00CE0AC059;
	Tue,  4 Jun 2019 09:14:10 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:10 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 1/6] nvdimm: Consider probe return -EOPNOTSUPP as success
Date: Tue,  4 Jun 2019 14:43:52 +0530
Message-Id: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With following patches we add EOPNOTSUPP as return from probe callback to
indicate we were not able to initialize a namespace due to pfn superblock
feature/version mismatch. We want to consider this a probe success so that
we can create new namesapce seed and there by avoid marking the failed
namespace as the seed namespace.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/bus.c         |  4 ++--
 drivers/nvdimm/nd-core.h     |  3 ++-
 drivers/nvdimm/region_devs.c | 19 +++++++++++++++----
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 2eb6a6cfe9e4..792b3e90453b 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -100,8 +100,8 @@ static int nvdimm_bus_probe(struct device *dev)
 
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
index e5ffd5733540..9e67a79fb6d5 100644
--- a/drivers/nvdimm/nd-core.h
+++ b/drivers/nvdimm/nd-core.h
@@ -134,7 +134,8 @@ int __init nvdimm_bus_init(void);
 void nvdimm_bus_exit(void);
 void nvdimm_devs_exit(void);
 void nd_region_devs_exit(void);
-void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev);
+void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus,
+			     struct device *dev, int ret);
 struct nd_region;
 void nd_region_create_ns_seed(struct nd_region *nd_region);
 void nd_region_create_btt_seed(struct nd_region *nd_region);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index b4ef7d9ff22e..fcf3d8828540 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -723,7 +723,7 @@ void nd_mapping_free_labels(struct nd_mapping *nd_mapping)
  * disable the region.
  */
 static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
-		struct device *dev, bool probe)
+					   struct device *dev, bool probe, int ret)
 {
 	struct nd_region *nd_region;
 
@@ -753,6 +753,16 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
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
 
@@ -788,14 +798,15 @@ static void nd_region_notify_driver_action(struct nvdimm_bus *nvdimm_bus,
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

