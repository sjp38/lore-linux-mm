Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C392C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA6BC218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:36:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA6BC218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8011B8E0008; Thu, 28 Feb 2019 03:36:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B09D8E0006; Thu, 28 Feb 2019 03:36:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C78A8E0008; Thu, 28 Feb 2019 03:36:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6E48E0006
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:36:05 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id l11so4374533ywl.18
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:36:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=4Cwey845aG5lAHZMAxbXPvYPOgxP0ppIzao/eD7OuCc=;
        b=LBYMBZCTaCAVZPBpMG62Ska2CtWF70yDQ7xaGTtRB9qYXFxg2BOkqx3fL0z3YoNyiF
         lsyNo+Gc1t2QZrb+9FcTwQKvG9b9kzseGb1LIXv9vS0zZQF3Bn3N3gDUJuzkDlUvvrG1
         s2M95qc5GuR1rYZ+MEsSCGzs/2LixhU0MikGvYN79oVWbtc4m416cZ73VSvGevmmdKQe
         vJrIXjRnZUKptD3ESdjokssxTJD5uHfhmfOvwNVadzzLyp4rY9+dTf0+oli3TDNTJDIp
         j8bIwKG8WXWLqF7I7ZV8UiEZb2ePoKXfm2GQDG1jD3lRoDIBw34s9HrN5fktgZWTdM/T
         cGZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubS6ah02zplr1UfUx8PNPXt0ytutEunppAEau3u/bXKkLvGBw9M
	Gv2v4DmZHrot2aKn5tgOnmu9034imPDTEVodsIlADcPBSbObrt4AYE4n69yTRqtkuWsuS635O6B
	cXWolYJuE9gdpZjHH7SwXEbcnwdx7ny6gJqwlYd+apge1xBHXP3KCxeJ+r+rUoGD4gQ==
X-Received: by 2002:a5b:40a:: with SMTP id m10mr5628608ybp.338.1551342964865;
        Thu, 28 Feb 2019 00:36:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iak1fyhxVJhfHpJz3r34vbteux9+bSrLaQU3NcmjzYOjmhsZkVjlcXapdljfg+M6w/MXLKK
X-Received: by 2002:a5b:40a:: with SMTP id m10mr5628571ybp.338.1551342964020;
        Thu, 28 Feb 2019 00:36:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342964; cv=none;
        d=google.com; s=arc-20160816;
        b=F41picqSxEyF7rgUQ8q4IRHthsqx7oSeEHVOfciLtzHYbJieM/rdGUrmvBCE/gTp47
         8/GEEdxT1YwJKkp/ia1OW2gZNIGJb8JSiJfmjW//dlGShjExXm+JbOKK4Nkp1OlMXXJ+
         IuulR5cBV2n/O99XF1uPT9dRmFt/7S+mVaT/jbuceQCRxozWUJn1do3N2rap4+aSaDLL
         xga8y0TrREBrPl08HQ6DwA17blMSjbgAnZaXPY/fp6OHiccUIGHBX0EBWeYPUAWpYH2j
         8+DoPAp3TuQGdCGL5dRJ7DlXoUqqoWnmggibRe7tEGhTbtytxwFvb91Lp8R8HS8UjWqT
         IDZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=4Cwey845aG5lAHZMAxbXPvYPOgxP0ppIzao/eD7OuCc=;
        b=ur4ctYdU7eDN5PHtd3sE6e8yxZVsujLA/CGNJnA+BayluTD662qS5bifRAcpP1FLx5
         TPDuLWKN6RRI81Lt/NG1gx0xBywnYcBO2URlVS2BwsfxB1jTS5TzD96ZbymO4PWyCs+c
         TqncHoF8owQUx5hZZNbipldYm/A1meQ38d0GorbTOoq0u73hJ+CpDUwTrKb+W/U9gzeU
         H5Wt4RBHe4ICtDHxDyK43JKsw2VUXk7U99O7Z54+tVH+NHm6jQ9enZCY+Bi7vBIxbi/l
         ag4kVZaRs0Edas4p5FGx7gj+41qc+4MbctcC0Y7eFZegZXB9mKQDHU5oHHfdbukHeE0t
         BddQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a9si4880242ybo.32.2019.02.28.00.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:36:04 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1S8ZjrE029729
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:36:03 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxbq61kxh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:57 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Feb 2019 08:35:36 -0000
Received: from b03cxnp08027.gho.boulder.ibm.com (9.17.130.19)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 08:35:33 -0000
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1S8ZWVs60686428
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 08:35:32 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 475717805E;
	Thu, 28 Feb 2019 08:35:32 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D9267805C;
	Thu, 28 Feb 2019 08:35:29 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.233])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 28 Feb 2019 08:35:29 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Jan Kara <jack@suse.cz>, mpe@ellerman.id.au,
        Ross Zwisler <zwisler@kernel.org>,
        "Oliver O'Halloran" <oohall@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH 1/2] fs/dax: deposit pagetable even when installing zero page
Date: Thu, 28 Feb 2019 14:05:21 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022808-0016-0000-0000-0000098A1A3A
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010678; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167493; UDB=6.00609930; IPR=6.00948107;
 MB=3.00025776; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-28 08:35:35
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022808-0017-0000-0000-0000424C085D
Message-Id: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Architectures like ppc64 use the deposited page table to store hardware
page table slot information. Make sure we deposit a page table when
using zero page at the pmd level for hash.

Without this we hit

Unable to handle kernel paging request for data at address 0x00000000
Faulting instruction address: 0xc000000000082a74
Oops: Kernel access of bad area, sig: 11 [#1]
....

NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
Call Trace:
 hash_page_mm+0x43c/0x740
 do_hash_page+0x2c/0x3c
 copy_from_iter_flushcache+0xa4/0x4a0
 pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
 dax_copy_from_iter+0x40/0x70
 dax_iomap_actor+0x134/0x360
 iomap_apply+0xfc/0x1b0
 dax_iomap_rw+0xac/0x130
 ext4_file_write_iter+0x254/0x460 [ext4]
 __vfs_write+0x120/0x1e0
 vfs_write+0xd8/0x220
 SyS_write+0x6c/0x110
 system_call+0x3c/0x130

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
TODO:
* Add fixes tag 

 fs/dax.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index 6959837cc465..01bfb2ac34f9 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -33,6 +33,7 @@
 #include <linux/sizes.h>
 #include <linux/mmu_notifier.h>
 #include <linux/iomap.h>
+#include <asm/pgalloc.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1410,7 +1411,9 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
+	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = mapping->host;
+	pgtable_t pgtable = NULL;
 	struct page *zero_page;
 	spinlock_t *ptl;
 	pmd_t pmd_entry;
@@ -1425,12 +1428,22 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
 	*entry = dax_insert_entry(xas, mapping, vmf, *entry, pfn,
 			DAX_PMD | DAX_ZERO_PAGE, false);
 
+	if (arch_needs_pgtable_deposit()) {
+		pgtable = pte_alloc_one(vma->vm_mm);
+		if (!pgtable)
+			return VM_FAULT_OOM;
+	}
+
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
 	if (!pmd_none(*(vmf->pmd))) {
 		spin_unlock(ptl);
 		goto fallback;
 	}
 
+	if (pgtable) {
+		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
+		mm_inc_nr_ptes(vma->vm_mm);
+	}
 	pmd_entry = mk_pmd(zero_page, vmf->vma->vm_page_prot);
 	pmd_entry = pmd_mkhuge(pmd_entry);
 	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
@@ -1439,6 +1452,8 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
 	return VM_FAULT_NOPAGE;
 
 fallback:
+	if (pgtable)
+		pte_free(vma->vm_mm, pgtable);
 	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, *entry);
 	return VM_FAULT_FALLBACK;
 }
-- 
2.20.1

