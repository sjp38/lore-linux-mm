Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CDB9C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F20BE222AE
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F20BE222AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5DC36B000A; Tue, 16 Apr 2019 09:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A33356B000C; Tue, 16 Apr 2019 09:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 921BE6B000D; Tue, 16 Apr 2019 09:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA246B000A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h10so2910308edn.22
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=VpgllxzPc37sNU/qdZLcQd5VeTMUV+mWthl8cxM+qN0=;
        b=bWvd6+NhapisvdyBw7oRux20ShGt7wymfBGHvSThZvPeOz/e4sxQaSmGkp98kTz69S
         o87JqhotmSenwtAI834l7OWBngvGDza+8oxtzm52sp3Dz0ATxm4KSyyAkm1URechz61v
         jdApBZk9B16hp02/sqsGl5tKYRbo92lhqr/xslYFriI03HswdsFvmzFAlGKjqc8jnBtg
         i+wAnNEsqqC+kIShJW5egHPmYQX/J1qq1RZ3N2NMr1TAghl9Ku6Nv7BSibjNwzR7sUPa
         YRBg5ffkrkcSETaobXQf3yLdxSznkhp63vSObjIP8LcBJWixDq9Gu2kup1ei00i093Yf
         +kcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU4TcwPyOyyKHUSWeBhClSBaeS3MrJ2HPfo37lP9xiZJVHAAjd5
	ISN2eDsqClkz+IpMhdIIJsigCNzpcDNfiSXOqo78cayT3uHXFlkT7zCUzJYtR0lMZ49ePAQXUFM
	cPEiw4XEYbZAQu34di1J8KoqatymqQykTqiIkot8MatCrd86Uxs+d8+T4ZlAa5gUqsA==
X-Received: by 2002:aa7:c38c:: with SMTP id k12mr6079446edq.33.1555422407718;
        Tue, 16 Apr 2019 06:46:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwyRlBeKA/f7fGRXUEQGuKi1QuzZLqer1ProhCj9xyHk3+Zuk7JxqQEsfLh6uSP4XKZmpK
X-Received: by 2002:aa7:c38c:: with SMTP id k12mr6079370edq.33.1555422406406;
        Tue, 16 Apr 2019 06:46:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422406; cv=none;
        d=google.com; s=arc-20160816;
        b=rpZp3+4lzHot1jyTb7lf4dzYiTskbNbOLLUehX8eLj3n8GxVxKmDQgLgqWL/vg5Bas
         IfgpujExMcG58In+Q9WESlo/Kge/gpdLn6ysKxAQ2gzdFPrPQlEnvJXMf681C3PMOJhz
         3LI4Ws015MWnS5hj+LgOiDp21p60DT5NQJo9sMJ+D7FcwAcIqeK+iQWemjW/7XJ0wpKh
         5nY/cy5pKHJq5tWOx5jGFVGQigecyxx31K61pvhiuG63nd2ZXzBOwoIK3xO67I7xkpHj
         V2rjdaOGpOMDy37lVqb6+mu8em4mLwOtZZwi8kNVnAFUm+c60m3HKPmXmoSBrw/LXXI/
         /ENA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=VpgllxzPc37sNU/qdZLcQd5VeTMUV+mWthl8cxM+qN0=;
        b=B4LZlp8UHYy+iKgS6xc5Nb8rWaWGH5JpwwTHpSEFWxblwt1FQkiNWC3WiG8LM+amoG
         jXbuyGXzcG75NV5QZxQ8xEmnT4Q7ZF3ErX3iKf0sXwjW9cm4hjHyD3HTlO6zYejuPxXs
         VQNX0tt0af1gkhBMRb0gf8WozyM3ki7xC4W9HLZ0OuJwshJQz9/rPuwDlKHR1+/CVrMH
         gdvxSLtMOArT00ZlRB6XNMpH2ZjWV5jvBmVEgTYrJ/obvwMLt7GgqCRvFtast20svktH
         CYXHK+l4930a+xVxwk/6UymLMzetvh7xAprA/gZ4X2XiNlDgbn9xtgATAuJ12O9qcnyD
         T8+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id jp19si248245ejb.116.2019.04.16.06.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkd9T178780
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:45 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwfpusewg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:42 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:56 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:46 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjiab16646206
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:44 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5066E4C052;
	Tue, 16 Apr 2019 13:45:44 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D71B34C062;
	Tue, 16 Apr 2019 13:45:42 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:42 +0000 (GMT)
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
Subject: [PATCH v12 07/31] mm: make pte_unmap_same compatible with SPF
Date: Tue, 16 Apr 2019 15:44:58 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7268
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD7B
Message-Id: <20190416134522.17540-8-ldufour@linux.ibm.com>
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

pte_unmap_same() is making the assumption that the page table are still
around because the mmap_sem is held.
This is no more the case when running a speculative page fault and
additional check must be made to ensure that the final page table are still
there.

This is now done by calling pte_spinlock() to check for the VMA's
consistency while locking for the page tables.

This is requiring passing a vm_fault structure to pte_unmap_same() which is
containing all the needed parameters.

As pte_spinlock() may fail in the case of a speculative page fault, if the
VMA has been touched in our back, pte_unmap_same() should now return 3
cases :
	1. pte are the same (0)
	2. pte are different (VM_FAULT_PTNOTSAME)
	3. a VMA's changes has been detected (VM_FAULT_RETRY)

The case 2 is handled by the introduction of a new VM_FAULT flag named
VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
page fault while holding the mmap_sem.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm_types.h |  6 +++++-
 mm/memory.c              | 37 +++++++++++++++++++++++++++----------
 2 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8ec38b11b361..fd7d38ee2e33 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -652,6 +652,8 @@ typedef __bitwise unsigned int vm_fault_t;
  * @VM_FAULT_NEEDDSYNC:		->fault did not modify page tables and needs
  *				fsync() to complete (for synchronous page faults
  *				in DAX)
+ * @VM_FAULT_PTNOTSAME		Page table entries have changed during a
+ *				speculative page fault handling.
  * @VM_FAULT_HINDEX_MASK:	mask HINDEX value
  *
  */
@@ -669,6 +671,7 @@ enum vm_fault_reason {
 	VM_FAULT_FALLBACK       = (__force vm_fault_t)0x000800,
 	VM_FAULT_DONE_COW       = (__force vm_fault_t)0x001000,
 	VM_FAULT_NEEDDSYNC      = (__force vm_fault_t)0x002000,
+	VM_FAULT_PTNOTSAME	= (__force vm_fault_t)0x004000,
 	VM_FAULT_HINDEX_MASK    = (__force vm_fault_t)0x0f0000,
 };
 
@@ -693,7 +696,8 @@ enum vm_fault_reason {
 	{ VM_FAULT_RETRY,               "RETRY" },	\
 	{ VM_FAULT_FALLBACK,            "FALLBACK" },	\
 	{ VM_FAULT_DONE_COW,            "DONE_COW" },	\
-	{ VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" }
+	{ VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" },	\
+	{ VM_FAULT_PTNOTSAME,		"PTNOTSAME" }
 
 struct vm_special_mapping {
 	const char *name;	/* The name, e.g. "[vdso]". */
diff --git a/mm/memory.c b/mm/memory.c
index 221ccdf34991..d5bebca47d98 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2094,21 +2094,29 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
  * parts, do_swap_page must check under lock before unmapping the pte and
  * proceeding (but do_wp_page is only called after already making such a check;
  * and do_anonymous_page can safely check later on).
+ *
+ * pte_unmap_same() returns:
+ *	0			if the PTE are the same
+ *	VM_FAULT_PTNOTSAME	if the PTE are different
+ *	VM_FAULT_RETRY		if the VMA has changed in our back during
+ *				a speculative page fault handling.
  */
-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+static inline vm_fault_t pte_unmap_same(struct vm_fault *vmf)
 {
-	int same = 1;
+	int ret = 0;
+
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
+		if (pte_spinlock(vmf)) {
+			if (!pte_same(*vmf->pte, vmf->orig_pte))
+				ret = VM_FAULT_PTNOTSAME;
+			spin_unlock(vmf->ptl);
+		} else
+			ret = VM_FAULT_RETRY;
 	}
 #endif
-	pte_unmap(page_table);
-	return same;
+	pte_unmap(vmf->pte);
+	return ret;
 }
 
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
@@ -2714,8 +2722,17 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	int exclusive = 0;
 	vm_fault_t ret = 0;
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
+	ret = pte_unmap_same(vmf);
+	if (ret) {
+		/*
+		 * If pte != orig_pte, this means another thread did the
+		 * swap operation in our back.
+		 * So nothing else to do.
+		 */
+		if (ret == VM_FAULT_PTNOTSAME)
+			ret = 0;
 		goto out;
+	}
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
-- 
2.21.0

