Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EF4AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 168DC218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 168DC218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BACB28E0003; Thu, 28 Feb 2019 03:35:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5B4A8E0001; Thu, 28 Feb 2019 03:35:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A22188E0003; Thu, 28 Feb 2019 03:35:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 78A8D8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:44 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id c67so16301132ywe.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:35:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=jJVa2qV8nKvE2yQie1WFcZW7O3Eubx1M5bJjeVzZStM=;
        b=ONIIKOcfZBC6q0udqgQFYhGBBjghxAGoPTyb7iZDr2mO/orGIVzIMWd5Zees3PARV2
         xd0dtn0wLUJDzTjIwzs99HK0RDemarQdmXpe0K0XS/v9xZWzuEL3TnT6UnuT/PsfYvgo
         tkoLyyIExszuq9ufUypQCBMNjpa0wh2udmLQK0+/sPjOa/7Tx+iETzp2jyShVFWVMvn6
         SxtONb02uA5pwR2PVjdi3XWFFq0rIg4z6640sf5HD6AS7/l1QDQizr0Sf65AKc8Tc9zA
         aL+tpFBiTHGoJyde1JSmykowhXd+4+zpoNobF6UZhGaoBm3Kh/BJK8L9SCbmIBO5ZOhW
         Gang==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaGjruhEFNtunmORupIgbvWQC1DCi0MoEFfpsbyFfg7zZn9oPXy
	9D6hOXCjvPF2rk32c45jbR9pDhX8LU357fEJqnpbFxdFeeeQwjUNWutsW8L5KXEgeZSRvFwqxZi
	er0UAvcrp1+sa/9/D91g7gj0DL5KCxDBdzOatef4gUKyUOjJ+NQmAGfhfymOWB+wwQA==
X-Received: by 2002:a5b:603:: with SMTP id d3mr5287046ybq.119.1551342944168;
        Thu, 28 Feb 2019 00:35:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbzZu/NT6fu5Cw2EVgMIQ0APYeCG+894gru9H/GMfxcp/j58O7ye0zhVKsTuRjqsay41//O
X-Received: by 2002:a5b:603:: with SMTP id d3mr5287010ybq.119.1551342943293;
        Thu, 28 Feb 2019 00:35:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342943; cv=none;
        d=google.com; s=arc-20160816;
        b=WFsB4XYYh295Rfx47vzWEq0Ls6Msg1T6zshbCKyWSxA4dEO0KGZoFnovww9L+bSX6Q
         NOhIIzLCvj6q9w2Kk6Afr8Vgfms9epmhf3UX6/zM2lylP4t60nHYQBuvNrnH2HdpcRwm
         J2XGYSIkuhkw0/iHM3jGlh7uD68f4qAN3e5OV5yA10/lCS3GiKPwHJ7Eg4wpS9RvAOqR
         RhjNFUIGsXC8tZB6XOebgX0I1BAFB1bFt12Cv+t+0JhKAy024Sy43sfDAmusdDSH9v3C
         00r5Fb2DxEa4xqANIkWH04LwsgXysygMmF4cIf8B6kNzWT8PJJA2IEitM3sMzAcxj2SP
         zNgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=jJVa2qV8nKvE2yQie1WFcZW7O3Eubx1M5bJjeVzZStM=;
        b=hPKcrqLuHWzxtraFKfUF4mzj6ycv6HYb7+XU5qk3cIAkCbLHHbGb0DU2NH7WPBRRSs
         2V20QHjYMwiA1sLNMgWRD0gwvAfIYVpUnrMDY0iY02EkVfEhcFB1ZmXWjwLHr4eCnAS1
         V7HA3yGGu/1JqXfNOVEAtkssUVSO5OLhrdE17eKeKVmKSULensNmyOYcdmOYdMGkumqe
         bsS1QE+rAIQFV4kDXfVFmfm2Lz009apsslj/qNSSPuvD/Q+RchCdSyg5eUj6EitT5Wjn
         um9B3RfzcaWcml8NzXdB7M6sgaFhlywGlB4rfJflzjVfzP/x/iYbGGWoVBTGWvozfQsY
         LwpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o129si10251183ywo.228.2019.02.28.00.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:35:43 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1S8Y0vv170833
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:42 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxaejw585-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:42 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Feb 2019 08:35:41 -0000
Received: from b03cxnp07028.gho.boulder.ibm.com (9.17.130.15)
	by e32.co.us.ibm.com (192.168.1.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 08:35:37 -0000
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1S8ZaHx23134358
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 08:35:36 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 890977805C;
	Thu, 28 Feb 2019 08:35:36 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CFA3A7805F;
	Thu, 28 Feb 2019 08:35:33 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.233])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 28 Feb 2019 08:35:33 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Jan Kara <jack@suse.cz>, mpe@ellerman.id.au,
        Ross Zwisler <zwisler@kernel.org>,
        "Oliver O'Halloran" <oohall@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
Date: Thu, 28 Feb 2019 14:05:22 +0530
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022808-0004-0000-0000-000014E81B12
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010678; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167493; UDB=6.00609930; IPR=6.00948106;
 MB=3.00025776; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-28 08:35:40
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022808-0005-0000-0000-00008ABEE271
Message-Id: <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a flag to indicate the ability to do huge page dax mapping. On architecture
like ppc64, the hypervisor can disable huge page support in the guest. In
such a case, we should not enable huge page dax mapping. This patch adds
a flag which the architecture code will update to indicate huge page
dax mapping support.

Architectures mostly do transparent_hugepage_flag = 0; if they can't
do hugepages. That also takes care of disabling dax hugepage mapping
with this change.

Without this patch we get the below error with kvm on ppc64.

[  118.849975] lpar: Failed hash pte insert with error -4

NOTE: The patch also use

echo never > /sys/kernel/mm/transparent_hugepage/enabled
to disable dax huge page mapping.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
TODO:
* Add Fixes: tag

 include/linux/huge_mm.h | 4 +++-
 mm/huge_memory.c        | 4 ++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 381e872bfde0..01ad5258545e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
+	TRANSPARENT_HUGEPAGE_DAX_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
@@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
 		return true;
 
-	if (vma_is_dax(vma))
+	if (vma_is_dax(vma) &&
+	    (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
 		return true;
 
 	if (transparent_hugepage_flags &
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf357eaf0ce..43d742fe0341 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -53,6 +53,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
 	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
 #endif
+	(1 << TRANSPARENT_HUGEPAGE_DAX_FLAG) |
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
@@ -475,6 +476,8 @@ static int __init setup_transparent_hugepage(char *str)
 			  &transparent_hugepage_flags);
 		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
 			  &transparent_hugepage_flags);
+		clear_bit(TRANSPARENT_HUGEPAGE_DAX_FLAG,
+			  &transparent_hugepage_flags);
 		ret = 1;
 	}
 out:
@@ -753,6 +756,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
+	/* should we check for none here again? */
 	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
 	if (pfn_t_devmap(pfn))
 		entry = pmd_mkdevmap(entry);
-- 
2.20.1

