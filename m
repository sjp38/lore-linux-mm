Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DAD0C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51DBA20656
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51DBA20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D441C6B000A; Thu, 20 Jun 2019 05:17:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C818F8E0002; Thu, 20 Jun 2019 05:17:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A87968E0001; Thu, 20 Jun 2019 05:17:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 801526B000A
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:28 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v6so2155965ybs.1
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MXhN7XD92t/uhXxVMfs9t2OCruaXQWR8bVP9PSxooJM=;
        b=S/aaH4XIEfpgTaIiRdFSPx4LVyTYTpY+8x3Rp2lUteHdnnV173XCdIAgnwuft7CVpi
         8/aZAjxGNblGgrRJ871hZnwQY0F5VmyQ29wPl4RQOQFarF8DO2XGtHjICZrnr1bjKKgJ
         t+UwIGTqLQ5PmngBm5weCPfbiPgaeR1e3otPcmEmz2HQnsmioH2FHNj96x4cq+KBFMOa
         V+y4tBztabh5kj+laaNCLbu6ZU6IDAuapvVm7bWdTuMIx6h7z9fweowAdKRNlE1h0kC7
         2+/D8Pop4fNOUX0VFIu1HGZAshNLaqkeRf8jCP4v992yNbeI3/o+AHdnh3Mp8weVViw1
         6L+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXv4/YFl1CeZUjo1J+LeVdzmZ1mbekKnyUHqUygHyNJkls1/hKs
	gI51UXqe3yn7UdCPnv/T2roVRKunSWFDlH5pswLNgcd/+FHzpX0S1pKpsi7C7ZBDbfGrmKmSx9j
	GdwsSH6kpbNiJQoPXpuihNnYrF8s5PX7E/qQwmtgbUo7vvD8NiVa9IIca6y/xmaPHBg==
X-Received: by 2002:a25:d108:: with SMTP id i8mr11460831ybg.1.1561022248235;
        Thu, 20 Jun 2019 02:17:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypf60hwC7xQtyy6yxZbk9RpuDVPtlnMM2ORFZ+AG0oyH4aN3DwO+0RcQrtOeKYuG31ngaj
X-Received: by 2002:a25:d108:: with SMTP id i8mr11460814ybg.1.1561022247493;
        Thu, 20 Jun 2019 02:17:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022247; cv=none;
        d=google.com; s=arc-20160816;
        b=ZnoGpI0d26dqlbPUJy34TPCmJz7NwuqRngX0YD9eediFiTrFTZha7NptzZTqoRYIRj
         SFfMLJZljEulyTeLhNc67HTtkiO3vU1s+ArQ+HRfbKFl4w0CxxsFsLme33fCYC1npqNT
         f6N8RLHdvG0Cgka9g7V9vgEY6AfciyDdqWpNovZ7Jl7t21Vc8dc+a+Pl3CDEcWvHcJCB
         Lyidb3FO7dnzJKPTTKpaWmG6vkSiGbrubKM8l5/EHKpeLzxWn3KKAXeouHgc40JYvlI9
         K0XwAPOAq9GslfBjfP3Mr3HCZDr3aSxtjaMX+wvDynyEYbVIrXFpR9kvcrAMnpme+k4k
         J5cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MXhN7XD92t/uhXxVMfs9t2OCruaXQWR8bVP9PSxooJM=;
        b=BFsX3mSGulQjd3oaoR0b1PsPyga5GqeiU1NwmwDZpBvietnFH1Hnu4rb7F9Ojgpdri
         G782cSAbzNu2RIuL6uu9leMn9SVxN1013izlo+AMgv1cxE+9dX+k7NLG/V+HuRX8k5q8
         KG1ZbyPdLyxc8OvKRTjREdwghSil08Mzae1+6Abt8QT5aUhL8icCD1oKXKqnl4meBWPa
         TuO5fuAOj2JfpYPj2QKhx/vsOWMqRoUnEYRXKob4F6c5h3n8lCnJmN94MypofAWh8NWc
         MRci65o0zoi136Ncb0UFJHf+FbYieKfqTKxIPKfUHgIO5a+PvAFdL2oCSoXQVq6SDdee
         vlrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s66si7240506ywd.357.2019.06.20.02.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K94S3o020974;
	Thu, 20 Jun 2019 05:17:21 -0400
Received: from ppma04dal.us.ibm.com (7a.29.35a9.ip4.static.sl-reverse.com [169.53.41.122])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t85xnbjuf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 05:17:20 -0400
Received: from pps.filterd (ppma04dal.us.ibm.com [127.0.0.1])
	by ppma04dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5K94n4t009609;
	Thu, 20 Jun 2019 09:17:20 GMT
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by ppma04dal.us.ibm.com with ESMTP id 2t4ra6gquf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 09:17:20 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9HJXN33882408
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:19 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 70168AE062;
	Thu, 20 Jun 2019 09:17:19 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DB0FCAE05F;
	Thu, 20 Jun 2019 09:17:17 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:17 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 5/6] mm/nvdimm: Use correct alignment when looking at first pfn from a region
Date: Thu, 20 Jun 2019 14:46:25 +0530
Message-Id: <20190620091626.31824-6-aneesh.kumar@linux.ibm.com>
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
 mlxlogscore=880 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmem_altmap_offset() adjust the section aligned base_pfn offset.
So we need to make sure we account for the same when computing base_pfn.

ie, for altmap_valid case, our pfn_first should be:

pfn_first = altmap->base_pfn + vmem_altmap_offset(altmap);

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 kernel/memremap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index a0e5f6b91b04..63800128844b 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -58,9 +58,11 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
 	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
-	pfn = PHYS_PFN(res->start);
-	if (pgmap->altmap_valid)
-		pfn += vmem_altmap_offset(altmap);
+	if (pgmap->altmap_valid) {
+		pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
+	} else
+		pfn = PHYS_PFN(res->start);
+
 	return pfn;
 }
 
-- 
2.21.0

