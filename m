Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 592F4C46470
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 164D8217D9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 164D8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7481D6B0006; Wed, 22 May 2019 02:21:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 692476B0007; Wed, 22 May 2019 02:21:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 535696B000A; Wed, 22 May 2019 02:21:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2360F6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:15 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q185so1212665ybc.8
        for <linux-mm@kvack.org>; Tue, 21 May 2019 23:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=YreXa9XJXamXXEsykOuOR/Vp8XWXjJ9Q1XWjC3jqg20=;
        b=rSEy30szZHskxnaZr9deM2FvqDQTcP6xXyB6/LfMMmskbZYSZgCXYsrdHiaQRmT6uh
         ER1jkjlbK5b6Ycx+YzLsG6CIbY04g8NaZRN+ayy09t/fhlyiHzDE0tY7rGg6HcWmmnJ3
         wkgZyVJm0CyGY15GSb/yKchcbCOn0QtssBjMfI1+hyTT3vPLKlrA06Cuj20bGTqfPWfe
         t9pe9+9nTtx4GPugJh18A80bVu2Zv8MdeenProbJDmhVBtWHy70OTjaKWhR1o5zpbMXM
         TcpTDHi0GiDTHvD6S9m0jQPF9fjXthn4lGoOJqupYqgqN9adO28H3Ept/LT2RszJEgTq
         hNDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWuIsf1dzEyDPfeEYJZ1QMyZfPET9yaUUr68O4nrEZ4aFFwQmDF
	dMUNrp8UNX81uKPLwpT3cuSv83N39p/dOxJt9ITd41h/0LcAwq8tKvAJ9p/tZnyXxEEQfDv7DUY
	x3uFgfbiXXBr0q+karBqPfM0mBMER8ygDJIQHdDzqYHJn2GEQ6CfjwKqKbdKAjc62CQ==
X-Received: by 2002:a25:287:: with SMTP id 129mr19003877ybc.503.1558506074903;
        Tue, 21 May 2019 23:21:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ2IV7bW4JzUa2beVc3NFWA8tJiGH0x5jFcqApu3MIsRGeF6DjdgLUnF+AgZQl85b17RPR
X-Received: by 2002:a25:287:: with SMTP id 129mr19003867ybc.503.1558506074270;
        Tue, 21 May 2019 23:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558506074; cv=none;
        d=google.com; s=arc-20160816;
        b=jWq4HPFd9F4BnUKxSq+tUcQk4aGPSjZVsgWd/QQ4295Nq+/9E99A3qYvO5uf9rXiwP
         /lxXBxKy6VNFqbFf7EP3hiwKjhhUX5wYKk9eLSKwnyXxQwJGf2UUYxn8gFjas2zMGScb
         bS3HKlZOx0vurftDiPrfdl8XtVZgeKzUSVVLRcKVX+mVcb3fkOQ/8fYu+6TleW7RSxvP
         4a7io0kkh1P2Q2Ho+GLsdcAkRUFoepTQvEmder9URZGpirus8rT1PauBKBqsFCmXE00K
         irTaeovXqMfBHq5KXfmq+E/r9lopxVdl5Z0llxSo9S28dWbf/rJvuf+rpGwSoRYh1RTz
         7ENg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=YreXa9XJXamXXEsykOuOR/Vp8XWXjJ9Q1XWjC3jqg20=;
        b=GN63/4ZrsLOD9B1ZgecmPgZfrxfijoD6zXW050g6uutwCsoYMcRt4Mwkh2T5Iylll8
         NrW+62cTj/KfyM36kBtL5abEricvdG0HpTTJcQwBlbW2YO7FIabkOOgo3pEOykvpbQuW
         1tyEVq1+W+j5ljYtqEhLsB3839/CWs4GACpNaTlcxLReycEPqK4rKL4PPAPtmoYZTitG
         jJZbR16ZDWIzS+hip204BSmRjkHcbsZ1mwqV5rutGnsUlSPIASUNryVw6ufd1tsoei2Z
         UdwS9KiMQYBsXp4wt0daEvHjdA1U4saLPav+bDEiItOjN6TG4wGr+ddOhw1NnQMLBQkt
         ORPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l5si1119780ybk.245.2019.05.21.23.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 23:21:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M6HoSW150414
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:14 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sn039t7h1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:21:13 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 07:21:13 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 07:21:10 +0100
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M6L9Fs40108278
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 06:21:09 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D95A1112065;
	Wed, 22 May 2019 06:21:09 +0000 (GMT)
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6A4F3112062;
	Wed, 22 May 2019 06:21:08 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.87])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 06:21:08 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH 3/3] mm/nvdimm: Use correct #defines instead of opencoding
Date: Wed, 22 May 2019 11:50:57 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190522062057.26581-1-aneesh.kumar@linux.ibm.com>
References: <20190522062057.26581-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19052206-0052-0000-0000-000003C54520
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206843; UDB=6.00633755; IPR=6.00987819;
 MB=3.00026997; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 06:21:12
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052206-0053-0000-0000-000060FF565F
Message-Id: <20190522062057.26581-3-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220046
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
 drivers/nvdimm/label.c       | 2 +-
 drivers/nvdimm/pfn_devs.c    | 6 +++---
 drivers/nvdimm/region_devs.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
index f3d753d3169c..bc6de8fb0153 100644
--- a/drivers/nvdimm/label.c
+++ b/drivers/nvdimm/label.c
@@ -361,7 +361,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
 
 	/* check that DPA allocations are page aligned */
 	if ((__le64_to_cpu(nd_label->dpa)
-				| __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
+				| __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
 		return false;
 
 	/* check checksum */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 94918a4e6e73..f549bddc680c 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -765,8 +765,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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
@@ -778,7 +778,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index b4ef7d9ff22e..2d8facea5a03 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -994,10 +994,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 		struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
 		struct nvdimm *nvdimm = mapping->nvdimm;
 
-		if ((mapping->start | mapping->size) % SZ_4K) {
-			dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
-					caller, dev_name(&nvdimm->dev), i);
-
+		if ((mapping->start | mapping->size) % PAGE_SIZE) {
+			dev_err(&nvdimm_bus->dev,
+				"%s: %s mapping%d is not 4K aligned\n",
+				caller, dev_name(&nvdimm->dev), i);
 			return NULL;
 		}
 
-- 
2.21.0

