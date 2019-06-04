Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFB1C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53AA322CBD
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53AA322CBD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3D736B0273; Tue,  4 Jun 2019 05:14:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEEBC6B0274; Tue,  4 Jun 2019 05:14:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB63D6B0276; Tue,  4 Jun 2019 05:14:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A89516B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:14:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o135so887847ywo.16
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=uHQOzTIkv8fvCjT6NRsoq9W8F2Km2qYgIp3prs4rNoM=;
        b=bMGubwQCahxBNDSD9+XhB3lqQCiHQVREIDFOLrfuJfVQzRFv0/A2zRdy2hlFVyajwm
         H1dvcqkr+463IWNOdQZiWlT3ZSclsLu0rehSbXbJuUNC+whMti9mQZl5+3xxuCijmOic
         9qWRUKtGfgNgC/S8wIQPdMrCQb1i6OFuQdzbl4fD1EHWN/qINctE7o2m9EyC3p2c/CGF
         TACKbB+Bv1nSeb+RhjNjSq/kH/bCPZGjgPBkHn9/nhlYudA073Hdfgw9bdcQO0UXw/W+
         m96ONF1IkQLOPSz77pmSY66ExKLSYCkuRuA0KL5nWDwsy0mbH5Kqmz+m1QxH6Bj9rnru
         k0lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWSjxkJhiMZmQqOpkE1V3GDHB29IxczVXCUX4PatGR13WX1lcHq
	4vcXTkO3/bFE6Y6QNGsUJb7HhEGTsKVuyc2mOZeFPpA/rzcAE5svPBzoRyQbS+vLpcvWWagLvkv
	WziSJWR4gCvZb2Ldpu0EzsEAjPo2dJgH8ZRDmEA9ti3nSrMD5cA3NUhBYJXQDLsOpZA==
X-Received: by 2002:a81:480f:: with SMTP id v15mr3096002ywa.144.1559639662448;
        Tue, 04 Jun 2019 02:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznxdRtsqPMJxeVL83ulFa9g0aNiZgC3gRmOCD1YFl4pt3aigaUA4Ucj3dYi7otf9LTSXmm
X-Received: by 2002:a81:480f:: with SMTP id v15mr3095984ywa.144.1559639661797;
        Tue, 04 Jun 2019 02:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639661; cv=none;
        d=google.com; s=arc-20160816;
        b=r9gZK7ZkNlckeTFWr/rflckZZwJw3WZu1XEgaNvlM8ulQQxvx9UFh82SLmZjN/rMBq
         Q0oLeMCH/lZPaZQt+wJQ3jAdhwbzisKZMkAupFutaVi1fI6DyxMr+E0kx6Vbv76108aI
         Lk0PVtO0M15J3RMKHrbaOAatcifHxoD9Klzd7Z0+eQrn5H4ODaXR6l4HaovhZ/+Y5a2l
         0cjZSK7G6IE81XXfA2dBX5NU8x77Cgc/Tf8jucceaot4/Nsvkoghu/aZlSFNa2PsPMK+
         L5dvtijXLdthiQJ8+c09mh1+6MtZheyqRXciYoYeNUFIXoh4BZZJTTBTFtWDrKIsv6cA
         sJuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=uHQOzTIkv8fvCjT6NRsoq9W8F2Km2qYgIp3prs4rNoM=;
        b=AJnJA8G6pKOLo5EM5dDg7Wzp8ZIrdENlt0Kj+c9nyzHRzGxjbQ+iZGVcoSZ/KG6Dej
         4917kUArktmElMeujOWNS5hqQLQ7qBf3goQyU4iN7b78sXWyVhPXEZ9Kgs/PLfWxMUx8
         NWSySrZkzWheqMy26UoFFPoDd2ypXP//RHgF9QPmf/NltfECJxZeEPkk7KyCiLxbFtVB
         T/+QV6ek2XFrLvt6KjPBAAEJc5TO+TjHP+OaMkfbQc9UltZdedtVrffvv3k7PdFFzR6+
         pG53R5ph0tG6h0lqXg8t4PWswQn2GTar2tvQRfNtPETvsrZFLHA3R2oFURfjqCFpNQKF
         U/bA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e132si4869299ybe.235.2019.06.04.02.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497bge073127
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:14:21 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swjwvqxnj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:14:21 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:14:20 +0100
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
	by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:14:19 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549EIIh37487078
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:18 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 102A4AC05B;
	Tue,  4 Jun 2019 09:14:18 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 944AFAC05F;
	Tue,  4 Jun 2019 09:14:16 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:16 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 4/6] mm/nvdimm: Use correct #defines instead of opencoding
Date: Tue,  4 Jun 2019 14:43:55 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0040-0000-0000-000004F8624C
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213037; UDB=6.00637528; IPR=6.00994104;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:14:20
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0041-0000-0000-000009048050
Message-Id: <20190604091357.32213-4-aneesh.kumar@linux.ibm.com>
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

The nfpn related change is needed to fix the kernel message

"number of pfns truncated from 2617344 to 163584"

The change makes sure the nfpns stored in the superblock is right value.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/label.c          | 2 +-
 drivers/nvdimm/namespace_devs.c | 6 +++---
 drivers/nvdimm/pfn_devs.c       | 6 +++---
 drivers/nvdimm/region_devs.c    | 8 ++++----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
index edf278067e72..c5f28c48bde4 100644
--- a/drivers/nvdimm/label.c
+++ b/drivers/nvdimm/label.c
@@ -363,7 +363,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
 
 	/* check that DPA allocations are page aligned */
 	if ((__le64_to_cpu(nd_label->dpa)
-				| __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
+				| __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
 		return false;
 
 	/* check checksum */
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index d0214644e334..c4c5a191b1d6 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -1014,10 +1014,10 @@ static ssize_t __size_store(struct device *dev, unsigned long long val)
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
index e01eee9efafe..d137f52f46ee 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -778,8 +778,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + reserve + 64 * npfns,
-				max(nd_pfn->align, PMD_SIZE)) - start;
+		offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
+			       max(nd_pfn->align, PMD_SIZE)) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
 		offset = ALIGN(start + reserve, nd_pfn->align) - start;
 	else
@@ -791,7 +791,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index fcf3d8828540..139d7b45b337 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -1005,10 +1005,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
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

