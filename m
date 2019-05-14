Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48106C04AA7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:54:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11ACE20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:54:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11ACE20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A57E6B0003; Mon, 13 May 2019 22:54:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 955926B0005; Mon, 13 May 2019 22:54:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 843DA6B0007; Mon, 13 May 2019 22:54:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7D56B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:54:05 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id h186so28864456ywc.6
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=DYthXOITgd4+jGY/7nfH4nRfeWr9cB7x6dv87md5CSc=;
        b=XrANg427wRxBIaqKuVcxRMq4YDuBnBqA5U9f7/O9rsgn2tuGbk/X+rfaXwnjw3YqAx
         eNSrDqK6aVdnTTb2+VRKWRpGvoXg+BIyXpbBwz9+0sp+n0KbdyofMd9+AHF1cfzdq8fp
         ZVuU3/+zsKKuEvvg+yZIXKM32JKqUEL6dLy+qzkeBPSUtjK8QCJpJ2IgfnQAIz3DLW00
         1UPAF/qwtcqUopPJyxs0yvpjqfsF0uOyM/ugmK8rG/OmfzyygKD+4Pjt7LDW4wWC8zvL
         QlfB5sgIuw4Kcnm3AQ6vUvLKPrRE8kde5LbYA+YLY60/z+ui7XwDjnHjtvAdzYW4IzCU
         KgLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW3ltm6m/xVkUwjK804rr5mxZe3w6VSLPXhZvV8srdbaqjBqgsh
	1ljmQypiFL0t0jhJF/lAuWEhn9cavHC44fJm2A2vxgtgEMzspzJ3+qKQnkfRmSB1siCXPwAh5pg
	n+nS2PvFKnmBErzVWCV135fWY4RgN29SHM5PAo83fU8CfrJstddLa89LJK91mSxP9jQ==
X-Received: by 2002:a81:7bc2:: with SMTP id w185mr14841020ywc.17.1557802445089;
        Mon, 13 May 2019 19:54:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQYlvqvDDzAq6O2wMl7T74aNM3uy9b77I8g7SNM4fBNJLgOWGBZnPVbEdMgw3lmz5AyJUF
X-Received: by 2002:a81:7bc2:: with SMTP id w185mr14840993ywc.17.1557802443863;
        Mon, 13 May 2019 19:54:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557802443; cv=none;
        d=google.com; s=arc-20160816;
        b=1Ai3xvjIMmQIhi9xpBiKhAz+QIlu1JYPsYkZeg4p5i+Yff8O9G6cWSyI2BhyeSg7Ca
         VSprync9diyHoLdrlja5Msnk7H+JxDCWgtVWVdvWnc67zg6tfepOy4c8cZrCm6fIEICn
         YJMIdIC0152/YJ9PFDdNz782IBfmrePOvV8s80YP9/F0PCFpmjrdUJmnEIGbZyHivH13
         BdQzWQc7RG8uml4q1LMv6sSInjtkfFsauo+bIICC+aSq9+rhGu4oaIYxMYLJ1VH4dt2V
         yTu2jaifRwzwJYE4vMyziDR46RgVEvTKo9ZYKp/Glp4adTwXH6K7IHNO9wTFXYm+2vwu
         bkKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=DYthXOITgd4+jGY/7nfH4nRfeWr9cB7x6dv87md5CSc=;
        b=SAQkNBt0h19bJQGR7r8bCkR8rY231G41piEkYjOZ3/pvh20vo2+kp57G6yGYBIUPJG
         ij/vNeg0bI3BfQO8ucgMoB9XFDK2hEZHCSL8ikbl9bmwU2QDOQ8YwVePmXEoOogCWmjr
         I7+ppwg3gzTyiXAJEAth6KjjzZmv5kkRk2kaDonf/A7w71iK3LJPxnVcZG18wbj7kYGU
         4Z/rroRhC4A7H4DJFim9dVPY/3Uja1dHY68/i1FepIhgKGmZ/5/9STARjyC+0u+Eq329
         rPoVHz2thy+KLQlc16DaXCcVdAQLIxPVOobaF97uKAeVkm0q6jRx0pbBG9WV55qLjiYa
         pYOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y6si4180713yby.448.2019.05.13.19.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:54:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E2kZ9V166352;
	Mon, 13 May 2019 22:54:01 -0400
Received: from ppma01dal.us.ibm.com (83.d6.3fa9.ip4.static.sl-reverse.com [169.63.214.131])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sfm55j3kx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 22:54:01 -0400
Received: from pps.filterd (ppma01dal.us.ibm.com [127.0.0.1])
	by ppma01dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x4DKuVpX024890;
	Mon, 13 May 2019 20:58:21 GMT
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by ppma01dal.us.ibm.com with ESMTP id 2sdp14jxm2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 20:58:21 +0000
Received: from b01ledav001.gho.pok.ibm.com (b01ledav001.gho.pok.ibm.com [9.57.199.106])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E2rxdV33423552
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 02:53:59 GMT
Received: from b01ledav001.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 936F92805C;
	Tue, 14 May 2019 02:53:59 +0000 (GMT)
Received: from b01ledav001.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8BB6028058;
	Tue, 14 May 2019 02:53:57 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.80.221.111])
	by b01ledav001.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 02:53:57 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH] mm/nvdimm: Fix kernel crash on devm_mremap_pages_release
Date: Tue, 14 May 2019 08:23:54 +0530
Message-Id: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140018
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we initialize the namespace, if we support altmap, we don't initialize all the
backing struct page where as while releasing the namespace we look at some of
these uninitilized struct page. This results in a kernel crash as below.

kernel BUG at include/linux/mm.h:1034!
cpu 0x2: Vector: 700 (Program Check) at [c00000024146b870]
    pc: c0000000003788f8: devm_memremap_pages_release+0x258/0x3a0
    lr: c0000000003788f4: devm_memremap_pages_release+0x254/0x3a0
    sp: c00000024146bb00
   msr: 800000000282b033
  current = 0xc000000241382f00
  paca    = 0xc00000003fffd680   irqmask: 0x03   irq_happened: 0x01
    pid   = 4114, comm = ndctl
 c0000000009bf8c0 devm_action_release+0x30/0x50
 c0000000009c0938 release_nodes+0x268/0x2d0
 c0000000009b95b4 device_release_driver_internal+0x164/0x230
 c0000000009b638c unbind_store+0x13c/0x190
 c0000000009b4f44 drv_attr_store+0x44/0x60
 c00000000058ccc0 sysfs_kf_write+0x70/0xa0
 c00000000058b52c kernfs_fop_write+0x1ac/0x290
 c0000000004a415c __vfs_write+0x3c/0x70
 c0000000004a85ac vfs_write+0xec/0x200
 c0000000004a8920 ksys_write+0x80/0x130
 c00000000000bee4 system_call+0x5c/0x70

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 mm/page_alloc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59661106da16..892eabe1ec13 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5740,8 +5740,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 #ifdef CONFIG_ZONE_DEVICE
 	/*
-	 * Honor reservation requested by the driver for this ZONE_DEVICE
-	 * memory. We limit the total number of pages to initialize to just
+	 * We limit the total number of pages to initialize to just
 	 * those that might contain the memory mapping. We will defer the
 	 * ZONE_DEVICE page initialization until after we have released
 	 * the hotplug lock.
@@ -5750,8 +5749,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (!altmap)
 			return;
 
-		if (start_pfn == altmap->base_pfn)
-			start_pfn += altmap->reserve;
 		end_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
 	}
 #endif
-- 
2.21.0

