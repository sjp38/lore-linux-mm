Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D15F3C10F00
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 12:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F531207E0
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 12:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F531207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C23BE8E0003; Sat,  9 Mar 2019 07:07:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD36E8E0002; Sat,  9 Mar 2019 07:07:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2988E0003; Sat,  9 Mar 2019 07:07:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC668E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 07:07:39 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q193so180691qke.12
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 04:07:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=9KkIG3yOu6CpZbEaiwEFu6KX3Uml3gERskGvBaEHpqE=;
        b=OTeVWP9jJAqCF42j6OnvHztithySomJo4Kua1WOyr9TeXHFtTbNEjxNIVqpupWMudS
         ZVr3nk2LUwy5hS1pj2efPj7ufRe9mwgN69nKwY6+5bic9rACBfe+nA42ZqcA+3KQYITP
         6cIz6qy6a6XeoszW8sVlwvf5g3aRRQHueo3wt45M4ke3JgUoMvlXVSb8V4yhnNLpfhdL
         JBwK8Jr0UXai/li/cmm6vb6pP5ERtnyVG38MLPRgHa7cPOCbIVNGPwWRs/mV2pF1zE9U
         kDgttLOKFLLq1qYxidbiyzjPLyQcu/kHcy+ZIHBBQW3XI7u9y+TPvrcwX/7TTXDH1j+h
         jWsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXqe4ASA+VIpFkAq8d+2eb/BV2vmBh8DnEp8+IeGfNl4uWfcATD
	g1pEPbqXaKUfG2NZ5B9nB/Hn4Pz76EsTTxCSdCCsTiMmy9rioO8JP6Se2wPrh9/bx00ZM80NkR6
	1J/xCPJtoyUPwI0l2nw9GenB47aB+2YCzriQH6ZffiExW5uwCmbCWu21ZvNsuizPMCQ==
X-Received: by 2002:a0c:d0db:: with SMTP id b27mr18818139qvh.223.1552133259143;
        Sat, 09 Mar 2019 04:07:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqwp5lae9l5vAgW80SYitYHOxP2z6P40i3nZvYz3dcZrczBp64W1UYDVq+edf6A/1DgVMBim
X-Received: by 2002:a0c:d0db:: with SMTP id b27mr18818088qvh.223.1552133258268;
        Sat, 09 Mar 2019 04:07:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552133258; cv=none;
        d=google.com; s=arc-20160816;
        b=uTRKFhMrtMozJQIVz5XLP0cpbzUymahCRc6VRXw8jfInz7BPfWl8CQTvPLcdEGGjmJ
         4gMuSX9J0o3I8euVPQOY7jAKqzGExRht2FtHolIZ26IdP11TJeV56BVIz4gB8BJ+kTaQ
         AhyBv+xr2Zto2aBKAGSZKTBYCE9MAhGIDT68zkwXB92HiU/CJSL55W8hc8nQDCdBNCtk
         PSbtBBmzcrwh/0yI/bAHan44zFJLzYKX6CcJOnZ821Niv4lFv+5wtzV5QM/HnLl948t3
         aLANfyAYjEakzUVqD0z5oocG1krQfsc1SpW9TraAn8+AmRgE3q6OGwkMRj5TZdkX4Z/R
         mrLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=9KkIG3yOu6CpZbEaiwEFu6KX3Uml3gERskGvBaEHpqE=;
        b=d6rLBR78/MhtHoxBLj57T8z20i70SrDoDapR5UQKjyLaTKAwe31Z17yu93Zc/FZ2eL
         BF4lOt8ZvRGUPKzoTLCZg5yiJV3zMVn8MHr22HZmI7n1aJCBDh6B0lr6lep5YScE2L5j
         LtC7BpahXiPxq9+zMZkP8GG2r8/yNtiqLpc/SLVuocUVEZ5xLuwFT/kCPvIxiVOcDaC7
         oLFkdFmUGv1zas/gHIzj0020Tdql8B/vTEWEMVqHWJJjJ6ZTe9HaZstLsIewg7BIKtfm
         sSWvMe7lgMqIRi1uYJIXI2pq55V/2sktbjiJxEE2El/4f/kb4XFy7SwxgsO+Uldf766X
         QKog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j92si215220qte.44.2019.03.09.04.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Mar 2019 04:07:38 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x29BsJDd179292
	for <linux-mm@kvack.org>; Sat, 9 Mar 2019 07:07:37 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r480egmdf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 09 Mar 2019 07:07:37 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 9 Mar 2019 12:07:36 -0000
Received: from b03cxnp08027.gho.boulder.ibm.com (9.17.130.19)
	by e32.co.us.ibm.com (192.168.1.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 9 Mar 2019 12:07:33 -0000
Received: from b03ledav005.gho.boulder.ibm.com (b03ledav005.gho.boulder.ibm.com [9.17.130.236])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x29C7Wpv52822224
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 9 Mar 2019 12:07:32 GMT
Received: from b03ledav005.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EA445BE054;
	Sat,  9 Mar 2019 12:07:31 +0000 (GMT)
Received: from b03ledav005.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 80886BE05A;
	Sat,  9 Mar 2019 12:07:28 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.71.67])
	by b03ledav005.gho.boulder.ibm.com (Postfix) with ESMTP;
	Sat,  9 Mar 2019 12:07:28 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, Ross Zwisler <zwisler@kernel.org>,
        Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v2] fs/dax: deposit pagetable even when installing zero page
Date: Sat,  9 Mar 2019 17:37:21 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19030912-0004-0000-0000-000014EC02DD
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010732; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01171848; UDB=6.00612557; IPR=6.00952491;
 MB=3.00025905; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-09 12:07:35
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030912-0005-0000-0000-00008AD90E02
Message-Id: <20190309120721.21416-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-09_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903090092
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

Fixes: b5beae5e224f ("powerpc/pseries: Add driver for PAPR SCM regions")
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
Changes from v1:
* Add reviewed-by:
* Add Fixes:

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

