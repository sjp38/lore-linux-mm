Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43412C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF833222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF833222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D42426B000E; Tue, 16 Apr 2019 09:46:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF2866B0266; Tue, 16 Apr 2019 09:46:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFB96B0269; Tue, 16 Apr 2019 09:46:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A92D6B000E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p26so2657471edy.19
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=wYGpYk7Grim5SqOFzD8BUE/Zqht2/KBjOtsFukYIArU=;
        b=Ajg1ZFka58JbpZefLR9GBKrK1g2N75wb0ULA88/1e3aGAwysQ9HG0SMr3yVstDq0Jx
         6g9s7Baq6BRquJqfJ+LNcpc0Zo/MPS+rd1po2j21hmTEwljat51hOKHBwQvz9ruqJN/V
         O0eFXX6GQkpiGtPPdBnYOveAiSfgyk7P+2MdHwg3skd/3hvouXxyVZYJcKYcWz43LrRS
         Y4j+qz3rhwnL1AWkrTWKYweAI8usxakNUgLMi8nS6L7TufRyDr4Dz//HI1R0J3kKoj7q
         J1UGvMLQXaq731KD02tHMfGytosa9TQF2S9DIK12IO3kcQFiXWt7VZ48+m5LmVly/zvn
         O5Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVwYSqp+gq+qfTtiSoGx9rXvES3GUk2jxjf5jtTQYz472swPRiz
	oYNVibtz4R15MEXkcU58LBPECY8OAEIycK1tpGLkA/Nc/rQbzdPEtzaMukji4IPYnSpab8RUt5F
	SFj4LkhFioLtyEPbX3rwg6Uzr0iaXhguAj195AfgRHE8XXLhqauW5vzrIZwyXQcGjbQ==
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr51420671edb.61.1555422412856;
        Tue, 16 Apr 2019 06:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGEaXI+p6jZn4Zt6ynvNHdst++MUcCbHWGq16jcvxt5wa6+L0D/iDwzVaqoQyiMZ91V0qI
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr51420359edb.61.1555422407946;
        Tue, 16 Apr 2019 06:46:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422407; cv=none;
        d=google.com; s=arc-20160816;
        b=gTklXpTZtDwihGdJFnqiCbhGW5LGo6of1r3dViFhSbMWKfSGTz92bxZrfXheSBLGJn
         /daEhxM4lYIPl0tnSObe4M/Sx5AlNoUgYvHIWbBBaiiR/RLgPPFK3JoCIPW0G/ih01Fg
         T9x13Iy8mHnF6OJ3Xaf4z07sulVdGPGqFk/tzUlCnAkktKl+iudV5itXeJK8YoO4wVqd
         bhbvv+27NxoA5Zmp7MJvIts4qxOcwEwTimq49kLTNOko3LYMzxgrLTE0LtQ4Z4cEb1fU
         Rs/nfLv5uQOrhzesXlo/DBvT0nyndUvXQZ2u1IysPJp61X8RgAHt8UE4p8aU6uZt7OQc
         UhKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=wYGpYk7Grim5SqOFzD8BUE/Zqht2/KBjOtsFukYIArU=;
        b=tR0SZme56GHBVpwAiiioS6qmf4KcJEQ15bMFkyKNYraA/WNmG4WB1r69pToylKatw8
         Kx2Fv1UReqPMUioiNHAJ+2ML+ECqreNJiwyv5zeJrCt40WlMydrmPUINej8Ien7wupWA
         JLZ85LJZ8/SlPz6ke1UZE4E2i43rdNY/AClanzzO1rScEAI1p8MdMXYmOgiiMWcl+oXD
         DT2MwanjmP3OorUYO+o85Wm0c30QuONs2zTqN4CTz+FspUWMNfgoFyvW3HRX1gfQprvp
         ubtvTrNW2j8quBSdl1mkCupzC1PEe7Mcw+xwiVSbxzXhHq629x3wf4SnJzuzVxaWgRCC
         prBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id en2si3323203ejb.6.2019.04.16.06.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkZbA113297
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:46 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwentmu3g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:22 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:13 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkCpF41353468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:12 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0FEDD4C04E;
	Tue, 16 Apr 2019 13:46:12 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A69A94C04A;
	Tue, 16 Apr 2019 13:46:10 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:10 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
Subject: [PATCH v12 16/31] mm: introduce __vm_normal_page()
Date: Tue, 16 Apr 2019 15:45:07 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0028-0000-0000-0000036170BF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0029-0000-0000-00002420A85F
Message-Id: <20190416134522.17540-17-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When dealing with the speculative fault path we should use the VMA's field
cached value stored in the vm_fault structure.

Currently vm_normal_page() is using the pointer to the VMA to fetch the
vm_flags value. This patch provides a new __vm_normal_page() which is
receiving the vm_flags flags value as parameter.

Note: The speculative path is turned on for architecture providing support
for special PTE flag. So only the first block of vm_normal_page is used
during the speculative path.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm.h | 18 +++++++++++++++---
 mm/memory.c        | 21 ++++++++++++---------
 2 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f465bb2b049e..f14b2c9ddfd4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1421,9 +1421,21 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
 #endif
 }
 
-struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t pte, bool with_public_device);
-#define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
+struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			      pte_t pte, bool with_public_device,
+			      unsigned long vma_flags);
+static inline struct page *_vm_normal_page(struct vm_area_struct *vma,
+					    unsigned long addr, pte_t pte,
+					    bool with_public_device)
+{
+	return __vm_normal_page(vma, addr, pte, with_public_device,
+				vma->vm_flags);
+}
+static inline struct page *vm_normal_page(struct vm_area_struct *vma,
+					  unsigned long addr, pte_t pte)
+{
+	return _vm_normal_page(vma, addr, pte, false);
+}
 
 struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 				pmd_t pmd);
diff --git a/mm/memory.c b/mm/memory.c
index 85ec5ce5c0a8..be93f2c8ebe0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -533,7 +533,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 }
 
 /*
- * vm_normal_page -- This function gets the "struct page" associated with a pte.
+ * __vm_normal_page -- This function gets the "struct page" associated with
+ * a pte.
  *
  * "Special" mappings do not wish to be associated with a "struct page" (either
  * it doesn't exist, or it exists but they don't want to touch it). In this
@@ -574,8 +575,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t pte, bool with_public_device)
+struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			      pte_t pte, bool with_public_device,
+			      unsigned long vma_flags)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -584,7 +586,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			goto check_pfn;
 		if (vma->vm_ops && vma->vm_ops->find_special_page)
 			return vma->vm_ops->find_special_page(vma, addr);
-		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+		if (vma_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
 		if (is_zero_pfn(pfn))
 			return NULL;
@@ -620,8 +622,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* !CONFIG_ARCH_HAS_PTE_SPECIAL case follows: */
 
-	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
-		if (vma->vm_flags & VM_MIXEDMAP) {
+	if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
 				return NULL;
 			goto out;
@@ -630,7 +632,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			off = (addr - vma->vm_start) >> PAGE_SHIFT;
 			if (pfn == vma->vm_pgoff + off)
 				return NULL;
-			if (!is_cow_mapping(vma->vm_flags))
+			if (!is_cow_mapping(vma_flags))
 				return NULL;
 		}
 	}
@@ -2532,7 +2534,8 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
+	vmf->page = __vm_normal_page(vma, vmf->address, vmf->orig_pte, false,
+				     vmf->vma_flags);
 	if (!vmf->page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -3706,7 +3709,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, old_pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
-	page = vm_normal_page(vma, vmf->address, pte);
+	page = __vm_normal_page(vma, vmf->address, pte, false, vmf->vma_flags);
 	if (!page) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
-- 
2.21.0

