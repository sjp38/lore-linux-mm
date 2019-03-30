Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4103C10F00
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:41:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8628F218AC
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:41:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8628F218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E69876B0003; Sat, 30 Mar 2019 01:41:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E17D66B0005; Sat, 30 Mar 2019 01:41:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2BFB6B0006; Sat, 30 Mar 2019 01:41:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEE7F6B0003
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:41:36 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a15so3712237qkl.23
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 22:41:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=BanAFjxwx2/bGKXj2uWHhj5BN5AsIe1UhVs8ZkbcyfU=;
        b=AuGSQmtrAJSWDKJv0TF5h0uhASnipXYMgPC9OJJF0KAWcvBN8TLNb8XfPtDekdR/d8
         lMzcieXCVD5gEOt2rv7LK8cyfbPuo42DfMcg8gznl2r2FU6RXqYuzo95oEIkhth5+P0n
         w8zZQuuTvlNkAApFQ9TlJEauV1ztCi0fGvEqzYo9V4wKnJuh8zQ0HGzp2m7JQQLqufFY
         AIHRvZo57MKZsdhGS7uqcX5b1yosNIdlRSRlNgYsNAZkhfaHwIuRi2SZy6qVNe7EMTvl
         JsDXa5YXo8xzJl2eNzS0FBEzzqrLfCWNt1eSHhePiBK5Gh7oZLDGEOrZG2+oRb22H9Dk
         wyLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXJqKSOLhQ+Jg2b2yOyzuMkiKLvqpSAQNdwKwCj9P++rsQ5NXdr
	9ndr2NBrg9teVuMZRpP4EM7K1xybphDXKl6ewVEv4Rk6agu79O5TIByAoZ9aqhhTXw1LfTjG3pM
	UXRAqdKjP0JaOJPgG0oAFnfl+wmqHUkNh/1xggCclg13tQiA5I6X5uU419UT9Mnr+WA==
X-Received: by 2002:a0c:8957:: with SMTP id 23mr42928387qvq.92.1553924496472;
        Fri, 29 Mar 2019 22:41:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcQzP97vXI9jFDlXFB8FjptwsmTOtdS+4xOen9Krey4prH2axTgEHIBWDK8pOaHX3X3CxF
X-Received: by 2002:a0c:8957:: with SMTP id 23mr42928358qvq.92.1553924495759;
        Fri, 29 Mar 2019 22:41:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553924495; cv=none;
        d=google.com; s=arc-20160816;
        b=xwooWDK/TK24b7gq2o+ibTikGjQZm1+AA2ksjF+ZzIkWQ/vrYTeNAqCMdP6f/WtidG
         2i+hjcUYHiDX2G8K1uGDeCXmZbKvDkbyhB8MF74uNqASfQME72eh1ZLoX3K23TVtEa5G
         KOhiInMCjn3ApH9sgPyd5hDNYmLvKxTCECVPvOJYgs1hiNKqIOvDfODleFbdDnd9/Ms3
         XuXAmH5EwxnVSm/UZJ10kTigQgev89506ARwqeFiUT6oZ7IJFbl0pzb8he0uP9qVk+51
         cXtoAfuWIAxw0G1zJYn2jxwqWYlHseXlZI0kQg5K09W9S3COOJgBMn9L0B8wMWblNpRP
         kvdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=BanAFjxwx2/bGKXj2uWHhj5BN5AsIe1UhVs8ZkbcyfU=;
        b=Tpm0ZhIqlcgV/OzLSetEzX1wKzGfzk5zdqCcscHmVoMzIuZmW0/XpTTWnf5qdT/0ki
         Zs5TkfaYEwfoRaHJC5fie/lcTStR4m0fHyyAbFAzeb5PdMLRy6Xy/x8nGHe7y0muRh/p
         XzKIuUOZHGOVh51qPpxwiaaGPkEIiWG6fG11F/wVyCpLaKeXM5KHuJblN53bMHyTVvWU
         11NS5Ew5hvppouf0k64tbyvZ19EzDl7P0cNrFCc1YeYW1E+Na6ww2YYSLeZXI+ZZSyj1
         pVfaOSugXRda7F0QNh3+lGm4kmSN0ti2el7J0Kr2g43G9zVt8f+UFdYVAE6ZLPxgwp+8
         yCYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c20si97607qtb.35.2019.03.29.22.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 22:41:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2U5YFgs098030
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:41:35 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rhv513jqq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:41:35 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 30 Mar 2019 05:41:34 -0000
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 30 Mar 2019 05:41:30 -0000
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2U5fTBm15728746
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 30 Mar 2019 05:41:30 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E096D6E04C;
	Sat, 30 Mar 2019 05:41:29 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3861A6E04E;
	Sat, 30 Mar 2019 05:41:27 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.85.132])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Sat, 30 Mar 2019 05:41:26 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, akpm@linux-foundation.org,
        Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        stable@vger.kernel.org
Subject: [PATCH] mm: Fix modifying of page protection by insert_pfn_pmd()
Date: Sat, 30 Mar 2019 11:11:21 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19033005-0016-0000-0000-000009991E5D
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010838; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000283; SDB=6.01181690; UDB=6.00618514; IPR=6.00962416;
 MB=3.00026217; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-30 05:41:33
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19033005-0017-0000-0000-000042A193B0
Message-Id: <20190330054121.27831-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=905 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903300038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With some architectures like ppc64, set_pmd_at() cannot cope with
a situation where there is already some (different) valid entry present.

Use pmdp_set_access_flags() instead to modify the pfn which is built to
deal with modifying existing PMD entries.

This is similar to
commit cae85cb8add3 ("mm/memory.c: fix modifying of page protection by insert_pfn()")

We also do similar update w.r.t insert_pfn_pud eventhough ppc64 don't support
pud pfn entries now.

CC: stable@vger.kernel.org
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 404acdcd0455..f7dca413c4b2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -755,6 +755,20 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
+	if (!pmd_none(*pmd)) {
+		if (write) {
+			if (pmd_pfn(*pmd) != pfn_t_to_pfn(pfn)) {
+				WARN_ON_ONCE(!is_huge_zero_pmd(*pmd));
+				goto out_unlock;
+			}
+			entry = pmd_mkyoung(*pmd);
+			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+			if (pmdp_set_access_flags(vma, addr, pmd, entry, 1))
+				update_mmu_cache_pmd(vma, addr, pmd);
+		}
+		goto out_unlock;
+	}
+
 	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
 	if (pfn_t_devmap(pfn))
 		entry = pmd_mkdevmap(entry);
@@ -770,6 +784,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	set_pmd_at(mm, addr, pmd, entry);
 	update_mmu_cache_pmd(vma, addr, pmd);
+out_unlock:
 	spin_unlock(ptl);
 }
 
@@ -821,6 +836,20 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	ptl = pud_lock(mm, pud);
+	if (!pud_none(*pud)) {
+		if (write) {
+			if (pud_pfn(*pud) != pfn_t_to_pfn(pfn)) {
+				WARN_ON_ONCE(!is_huge_zero_pud(*pud));
+				goto out_unlock;
+			}
+			entry = pud_mkyoung(*pud);
+			entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
+			if (pudp_set_access_flags(vma, addr, pud, entry, 1))
+				update_mmu_cache_pud(vma, addr, pud);
+		}
+		goto out_unlock;
+	}
+
 	entry = pud_mkhuge(pfn_t_pud(pfn, prot));
 	if (pfn_t_devmap(pfn))
 		entry = pud_mkdevmap(entry);
@@ -830,6 +859,8 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	}
 	set_pud_at(mm, addr, pud, entry);
 	update_mmu_cache_pud(vma, addr, pud);
+
+out_unlock:
 	spin_unlock(ptl);
 }
 
-- 
2.20.1

