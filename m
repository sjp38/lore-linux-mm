Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19792C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 04:06:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD8E3218A5
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 04:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD8E3218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2EFD6B0003; Thu, 21 Mar 2019 00:06:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDE6B6B0006; Thu, 21 Mar 2019 00:06:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA6176B0007; Thu, 21 Mar 2019 00:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECF86B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 00:06:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k5so4823728qte.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 21:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=zlPJrPotk8G25zF2Q+KLe2ZN46tX2AVGOesmkXpdEPc=;
        b=kNSr/zwScAGAcfPDxStLEblxWB72FhoFYmCiFjTopBCf72d2BWqZUzsH8/T7vENvEF
         8jiYyvHiTpUnwPZqclklitjyXfhURp1c/HCUVRxgnOSbFBDGt5nLDMnQ6F1pRVnvHTxz
         VVB6yUodeREOcw6dtYlkMrJW5ty7fsJZdVCTa4R30O5lzwPqVxYJpk3SCCaS9Zb11ckS
         E7T5Q6YVz3H8yDLGyobpmNYEszJFeDRfP1nSeFSD8dx9IjNj82aDKPgyqG15mhHb4lIz
         72X93cL3h8k1zUXdmZyiKvaWT3oJxlyhtwAClVdbbnbvNJXxYE8tZiO9wN94bCJ1Ytlq
         IQCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUmp1rP4PRxmY/dyuzSTrvuAgOvSn+y52CSfjuqDHO1hbXvn/g1
	oFLu8sOQlWaDQwuX5efjUH+/Hj9kht3npyEt2Dxd5LsziLAHCNN9k471/feJgQKQF40ydpm4YCa
	CNP+/xk5CiSQE6o95VurKXjVsR7ln3d+orLn1MnrEimlk6p4MfqUSKo1t/zETUmEXZQ==
X-Received: by 2002:a37:96c4:: with SMTP id y187mr973549qkd.149.1553141194368;
        Wed, 20 Mar 2019 21:06:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwai1spazvnjChLQ3a7kvitJjQ6qYKAdCgp9pWdbLUI0LhzXorCkIjSBVX5NH/oeGEjnEjK
X-Received: by 2002:a37:96c4:: with SMTP id y187mr973526qkd.149.1553141193606;
        Wed, 20 Mar 2019 21:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553141193; cv=none;
        d=google.com; s=arc-20160816;
        b=WlGkknXV8ymJcIKCfcqYHV66TwiNcEhoG4cUveQzbGL5iepGaqQYjkpBqNk2GWZ/xR
         9Qw36VNUX5YA7G7mM+Lri6FRhwk+zVrqLh0yh60bMQzOQ/ZVsq8AYtmf/IPJ+Oj9XOu8
         9qhqBm1jRprjp4UqvRouFXsZquW7vbAEtX6vMg5Gkn0vHeZDxSrJVxvEPvTCBPSPLQ0T
         toICkACPzwr36jgd7348u6M5GL2FfDBISL8atS3ii+cBPoU2qzFP47WEfyl70qSXCWVw
         ZGz7dJKzj0GaObPdFYuOMeEr2gFVAhxhsiaincTaEPeEl1/DYesNTv4AYPvzuuAGwS2n
         9IeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=zlPJrPotk8G25zF2Q+KLe2ZN46tX2AVGOesmkXpdEPc=;
        b=hWzAVwWVa7ODYzKTqjApwYau8LNtE58XkYOUTi7+vbP3fqrV1UYvWvvh9941QNezJb
         iX5noBExwp5YZ2nxEIxLu/31DFdsvpwRgbF7u9XFgVG2rEE9t5MGuwFXeTB+auM7Bw+H
         teSFxKdBZkLxplmy1PXk7YlUwm4z1TFItSuaTc9WtIh4/UIdN+3etfT5o+Vd9dT0eFOG
         U25lrLUKkjTrMKmJBAzBAKBWpiapm0/0QZb1TeOqAwkh0Z+Z6FJQW3CRGdMvuNDkuXa6
         qPupf9nMOZc+bauNSalWuVgbTCMCfegyd1RNO0j2oD/+68Vb1CgkpN9Zy7LD01Hw4DeQ
         /hSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c32si1743941qvd.170.2019.03.20.21.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 21:06:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2L3wXLW102897
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 00:06:33 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbxdh2ucn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 00:06:32 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 21 Mar 2019 04:06:30 -0000
Received: from b03cxnp08027.gho.boulder.ibm.com (9.17.130.19)
	by e32.co.us.ibm.com (192.168.1.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 21 Mar 2019 04:06:27 -0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2L46SUL35717156
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 04:06:29 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CFC326A058;
	Thu, 21 Mar 2019 04:06:28 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D343F6A04F;
	Thu, 21 Mar 2019 04:06:25 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.92.127])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 21 Mar 2019 04:06:25 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm: page_mkclean vs MADV_DONTNEED race
Date: Thu, 21 Mar 2019 09:36:10 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19032104-0004-0000-0000-000014F14CA2
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010789; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01177373; UDB=6.00615904; IPR=6.00958070;
 MB=3.00026084; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-21 04:06:29
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032104-0005-0000-0000-00008AF91221
Message-Id: <20190321040610.14226-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-21_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903210026
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MADV_DONTNEED is handled with mmap_sem taken in read mode.
We call page_mkclean without holding mmap_sem.

MADV_DONTNEED implies that pages in the region are unmapped and subsequent
access to the pages in that range is handled as a new page fault.
This implies that if we don't have parallel access to the region when
MADV_DONTNEED is run we expect those range to be unallocated.

w.r.t page_mkclean we need to make sure that we don't break the MADV_DONTNEED
semantics. MADV_DONTNEED check for pmd_none without holding pmd_lock.
This implies we skip the pmd if we temporarily mark pmd none. Avoid doing
that while marking the page clean.

Keep the sequence same for dax too even though we don't support MADV_DONTNEED
for dax mapping

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 fs/dax.c  | 2 +-
 mm/rmap.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 01bfb2ac34f9..697bc2f59b90 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -814,7 +814,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
-			pmd = pmdp_huge_clear_flush(vma, address, pmdp);
+			pmd = pmdp_invalidate(vma, address, pmdp);
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
diff --git a/mm/rmap.c b/mm/rmap.c
index b30c7c71d1d9..76c8dfd3ae1c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -928,7 +928,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 
 			flush_cache_page(vma, address, page_to_pfn(page));
-			entry = pmdp_huge_clear_flush(vma, address, pmd);
+			entry = pmdp_invalidate(vma, address, pmd);
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-- 
2.20.1

