Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE9D6C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 11:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4603720856
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 11:51:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4603720856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2C026B027B; Tue,  2 Apr 2019 07:51:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB1F06B027C; Tue,  2 Apr 2019 07:51:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92E5A6B027D; Tue,  2 Apr 2019 07:51:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 561D96B027B
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 07:51:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e19so3631572pfd.19
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 04:51:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=6M/ODAhw5kC3VSMnrljDc0UGz0+sFfq/Tcz9NAaqeLI=;
        b=N2C3O16StpUQx1XJQxs4mb9rbrpceIOAFJl+paxwYm34obp6s2w9UfO/w3LYmBjt2j
         AQ79EvpvWMJPU6o4P5gFDhJ1RsO9VTVwv/f/ABrQh/kvB26q9Vw6IW56Fg2Dp+E+YCcp
         byJ2EHqTKY9Jc9maOgVvK5z0uaJ45pMDc3Pzar4MNIT6EpRN6VkSnWB6GLmPPydMwHXh
         aVsmctplip/Uy2fElC+5pOBVvx1vmj79lxjyTdhBXuNU2btZ/f1CyupDhAAA7t0s0KQP
         5oiAQ0zQmjzMeN0gnRtIFi8N1sp4dl93dRv13RSZXutRxVe+BfB0ZsU9a86Z9h1mByfy
         Cg1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW2dmRsRgi86H62JHUlLpaBqVCcTG4YcSm4iG9AUxFBc6G4GHrp
	yDCTdd/YJf2pMSP/Vc+FknTKFyhi6PHVLBjlaP+vuNVDWiGAgsJcJCAuTWG/c6knGkykm0ciP6h
	nIL5gOACjoY1A5Z75z00ro0QwwWD3orMZg+cpMHJIQK13XRPjFiFw/aJozUqR+HnXWQ==
X-Received: by 2002:a62:1b8a:: with SMTP id b132mr45322975pfb.19.1554205897952;
        Tue, 02 Apr 2019 04:51:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn0xiOqqmD6jdQR7y1G6Eiuk60y66ny2iji3IXq8g/wH8qS53j3Cf4m58EJ662Oq0/MJK0
X-Received: by 2002:a62:1b8a:: with SMTP id b132mr45322872pfb.19.1554205896547;
        Tue, 02 Apr 2019 04:51:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554205896; cv=none;
        d=google.com; s=arc-20160816;
        b=I5A/54aW8MyRZ6+2s7zujF26EDVCYhE/2vIR0lVKSeEALylNxG3hjdGSuEwv9Rp76W
         xD5QjHxbJJ5gLXdYoGFJLhraZ2eShGkV0LUL/cJSLYw45LamvY5vzKYUaPAPGeZtQyUk
         ecOhtFtA1jbjJU0k6qds6emgP9upoxBjvbAu0gp6SHX44K/I1ZTfYV2NRv1apVCmrgsz
         skI/y1vR3oz6j1PJg/YOb44ePRj685NiyDAZsZC48sRvOZ/EBvn6A7c8culNBZvl3dfQ
         94/jD6WzFHcqlroi+P20xV6bnlodUkiBRzilUJ+Z3sooZZTfpcyZLN0k5UsuNyAViWHC
         u71Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=6M/ODAhw5kC3VSMnrljDc0UGz0+sFfq/Tcz9NAaqeLI=;
        b=uvmT8HgezqmVQYdmlpYBzaGBwuZ1Bicvq2v1K1nEueEaeowI8av4a2sRPdJJvT13n3
         M+St2QWEHiEQ1O261lSwRtbyLiWsSuOyd2abSiyJ+/M9cmSa6hPCZmI6I11ILJhTgBx8
         ivgZx4kLviVUc2pfJM61gZ1uRJLcdqJyf7ifcUMMcGlNMZmvzcgtWArijIJYujd5e8Ze
         UmVb6sXTkCJ1P8lssNc8GL2+mkbIsAiM7KoTZEGzuhhE2CWHzpesT0fj2iJzZMwb502a
         8r6Csh3Z8SE3kY6LTy22E2qUAPcI4jp6q0u/bP0esBYpnwsqIpoR1kI8qAOPkyyk7nSV
         gxwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o1si11230264pfe.194.2019.04.02.04.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 04:51:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x32BelmO116280
	for <linux-mm@kvack.org>; Tue, 2 Apr 2019 07:51:36 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rm631ky0e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:51:35 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 2 Apr 2019 12:51:34 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 2 Apr 2019 12:51:32 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x32BpV3L19464358
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 2 Apr 2019 11:51:31 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8678FB2067;
	Tue,  2 Apr 2019 11:51:31 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5801DB2068;
	Tue,  2 Apr 2019 11:51:28 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.118.252])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  2 Apr 2019 11:51:27 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, akpm@linux-foundation.org,
        Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        stable@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
Date: Tue,  2 Apr 2019 17:21:25 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19040211-0064-0000-0000-000003C55D6F
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010860; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000284; SDB=6.01183232; UDB=6.00619446; IPR=6.00963980;
 MB=3.00026260; MTD=3.00000008; XFM=3.00000015; UTC=2019-04-02 11:51:34
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040211-0065-0000-0000-00003CEC1A00
Message-Id: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-02_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=827 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020081
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

Without this patch we also see the below message in kernel log
"BUG: non-zero pgtables_bytes on freeing mm:"

CC: stable@vger.kernel.org
Reported-by: Chandan Rajendra <chandan@linux.ibm.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
Changes from v1:
* Fix the pgtable leak 

 mm/huge_memory.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 404acdcd0455..165ea46bf149 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -755,6 +755,21 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
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
+
+		goto out_unlock;
+	}
+
 	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
 	if (pfn_t_devmap(pfn))
 		entry = pmd_mkdevmap(entry);
@@ -766,11 +781,16 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	if (pgtable) {
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		mm_inc_nr_ptes(mm);
+		pgtable = NULL;
 	}
 
 	set_pmd_at(mm, addr, pmd, entry);
 	update_mmu_cache_pmd(vma, addr, pmd);
+
+out_unlock:
 	spin_unlock(ptl);
+	if (pgtable)
+		pte_free(mm, pgtable);
 }
 
 vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -821,6 +841,20 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
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
@@ -830,6 +864,8 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	}
 	set_pud_at(mm, addr, pud, entry);
 	update_mmu_cache_pud(vma, addr, pud);
+
+out_unlock:
 	spin_unlock(ptl);
 }
 
-- 
2.20.1

