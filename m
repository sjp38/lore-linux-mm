Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DE4BC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EF3121B68
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EF3121B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2DB16B0008; Tue, 16 Apr 2019 09:46:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDCEA6B000A; Tue, 16 Apr 2019 09:46:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAF196B000C; Tue, 16 Apr 2019 09:46:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7763A6B0008
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j3so10977001edb.14
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=9jZTtITuVwuX3A0pUuEay1zff/oOC++asy4NappICdo=;
        b=m/4fMsH2rHXVH95ncpPhbxGochB9R306CnBIw+3RXHjbBI4GINu6WIBrWPJiwqaTU/
         wVfDBC2nEJtRcsE5wlRKGCCE0/l4DPjcgQLors4VrQ2rqOn/spd2CvIzEjjF++bgc8KU
         yiXhHzJrZsuJCh8c+YXK8E5v48amHhOYeQdmLlwZU7aByL8+jX3o/cXIsp2prrah3vil
         xsbR8eLZo/QmQJx5QyINUtXG13wrEsLdyObJkzZ5spnUA64D2LyvFO9Pfoax78RNuxCs
         MfTUJMTCpJp53IoUNifx6YJv23VdNuTuY6swBpMInmApJpXdNUAxymFXvhvAlLzwl7Tt
         8wYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVp8ljD5nbX0NdiKAyUO+KlYRAMVPpa+MRdZpOXna43ldyfb5jO
	DPPR0bNqOHLhq5Oybwxc0JG8b82uloHu2Sj9AfGk7h9rhJTrbW7rQQ7BG+UmbFBEhhICmhXunNq
	1plkxFoB3P07F6MPOELq8iyQSLG7+cUzC4DcsSIvY2SVxrh6/rkNJyk+0cw68Ddg5aA==
X-Received: by 2002:a17:906:4c4e:: with SMTP id d14mr35794765ejw.127.1555422402612;
        Tue, 16 Apr 2019 06:46:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjpPyvahpXWSfwo8OAK+mWHzC8mXTh/UzTebasX1s2ZUP0WjcC0O02IuWiNOPE6BaC3duf
X-Received: by 2002:a17:906:4c4e:: with SMTP id d14mr35794688ejw.127.1555422400770;
        Tue, 16 Apr 2019 06:46:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422400; cv=none;
        d=google.com; s=arc-20160816;
        b=HVOXx7BoST8T8XkEJQQrX360wRxB9+ErqGT/1aEu1S7iN2MzcIgusWfhWVxg4ImxDT
         I1nyllnOYhWC6BDq0U/j9KDlLAPO+BabjAiHVOlRG+YFBS154eZ6IMPJ/XIjvXBHdlza
         XfSaazzT3Ws4tA0YUMJwUH6zsxIJN2fdzP/K/z+E7JFYXmwSgrwWiTJt2Fx9qG+uI+nI
         qALr9v0dQIi/LkZLcf1H79srbxakxM+vzVjvxd/ahBh1WqW5uYTqzJYHvKcMISbyLwDb
         EFaJR8wTJV8cK91iBdnDhfowkYrjhMx/Z75dhFRl/Bsc5LpW4TUYZRzkTMsA14NYXoqY
         hJLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=9jZTtITuVwuX3A0pUuEay1zff/oOC++asy4NappICdo=;
        b=nTZresSQ1CqW7oJIrWT12VROmd5ithdyKAP2OY2mwUHNWYRSwgRWlEzvYy4wyfi3JY
         Ktc+//qofOOneE5S4F+4wHhwbkUKIyJv7w82oyzZSAuNTZiT6xyhSvdrwJq+ZMgwHviT
         lzRUTptUV54VZeGFbczYin4xYzm06yku22tvvT6vW6u1fa7ZW58GZ7NznfgadAzQp8Tm
         w+8FeC4+K61TOzQO7onU73pXX7I1Uh5wg+a1G1m7GwkaDOtkI89a6zLTWWHBJsQmJwgI
         sVAZzG/bbHtaciXht2Nt7vtqlSd+T+RsqciY8nHcPlZlNnocw/dqC6t2cAC38QRP0inN
         JwYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l3si2135818edn.275.2019.04.16.06.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkVcp113139
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:38 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwentmtj3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:36 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:50 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:41 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjdqX46661836
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:39 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4BA094C052;
	Tue, 16 Apr 2019 13:45:39 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D1B344C046;
	Tue, 16 Apr 2019 13:45:37 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:37 +0000 (GMT)
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
Subject: [PATCH v12 05/31] mm: prepare for FAULT_FLAG_SPECULATIVE
Date: Tue, 16 Apr 2019 15:44:56 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-4275-0000-0000-00000328764E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-4276-0000-0000-00003837A74F
Message-Id: <20190416134522.17540-6-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <peterz@infradead.org>

When speculating faults (without holding mmap_sem) we need to validate
that the vma against which we loaded pages is still valid when we're
ready to install the new PTE.

Therefore, replace the pte_offset_map_lock() calls that (re)take the
PTL with pte_map_lock() which can fail in case we find the VMA changed
since we started the fault.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Port to 4.12 kernel]
[Remove the comment about the fault_env structure which has been
 implemented as the vm_fault structure in the kernel]
[move pte_map_lock()'s definition upper in the file]
[move the define of FAULT_FLAG_SPECULATIVE later in the series]
[review error path in do_swap_page(), do_anonymous_page() and
 wp_page_copy()]
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/memory.c | 87 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 58 insertions(+), 29 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c6ddadd9d2b7..fc3698d13cb5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2073,6 +2073,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+static inline bool pte_map_lock(struct vm_fault *vmf)
+{
+	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
+				       vmf->address, &vmf->ptl);
+	return true;
+}
+
 /*
  * handle_pte_fault chooses page fault handler according to an entry which was
  * read non-atomically.  Before making any commitment, on those architectures
@@ -2261,25 +2268,26 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 	int page_copied = 0;
 	struct mem_cgroup *memcg;
 	struct mmu_notifier_range range;
+	int ret = VM_FAULT_OOM;
 
 	if (unlikely(anon_vma_prepare(vma)))
-		goto oom;
+		goto out;
 
 	if (is_zero_pfn(pte_pfn(vmf->orig_pte))) {
 		new_page = alloc_zeroed_user_highpage_movable(vma,
 							      vmf->address);
 		if (!new_page)
-			goto oom;
+			goto out;
 	} else {
 		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 				vmf->address);
 		if (!new_page)
-			goto oom;
+			goto out;
 		cow_user_page(new_page, old_page, vmf->address, vma);
 	}
 
 	if (mem_cgroup_try_charge_delay(new_page, mm, GFP_KERNEL, &memcg, false))
-		goto oom_free_new;
+		goto out_free_new;
 
 	__SetPageUptodate(new_page);
 
@@ -2291,7 +2299,10 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
+		goto out_uncharge;
+	}
 	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2378,12 +2389,14 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		put_page(old_page);
 	}
 	return page_copied ? VM_FAULT_WRITE : 0;
-oom_free_new:
+out_uncharge:
+	mem_cgroup_cancel_charge(new_page, memcg, false);
+out_free_new:
 	put_page(new_page);
-oom:
+out:
 	if (old_page)
 		put_page(old_page);
-	return VM_FAULT_OOM;
+	return ret;
 }
 
 /**
@@ -2405,8 +2418,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf)
 {
 	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
-	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
-				       &vmf->ptl);
+	if (!pte_map_lock(vmf))
+		return VM_FAULT_RETRY;
 	/*
 	 * We might have raced with another page fault while we released the
 	 * pte_offset_map_lock.
@@ -2527,8 +2540,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 			get_page(vmf->page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			lock_page(vmf->page);
-			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-					vmf->address, &vmf->ptl);
+			if (!pte_map_lock(vmf)) {
+				unlock_page(vmf->page);
+				put_page(vmf->page);
+				return VM_FAULT_RETRY;
+			}
 			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 				unlock_page(vmf->page);
 				pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2744,11 +2760,15 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 		if (!page) {
 			/*
-			 * Back out if somebody else faulted in this pte
-			 * while we released the pte lock.
+			 * Back out if the VMA has changed in our back during
+			 * a speculative page fault or if somebody else
+			 * faulted in this pte while we released the pte lock.
 			 */
-			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-					vmf->address, &vmf->ptl);
+			if (!pte_map_lock(vmf)) {
+				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+				ret = VM_FAULT_RETRY;
+				goto out;
+			}
 			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2801,10 +2821,13 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	}
 
 	/*
-	 * Back out if somebody else already faulted in this pte.
+	 * Back out if the VMA has changed in our back during a speculative
+	 * page fault or if somebody else already faulted in this pte.
 	 */
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
+		goto out_cancel_cgroup;
+	}
 	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte)))
 		goto out_nomap;
 
@@ -2882,8 +2905,9 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_cancel_charge(page, memcg, false);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
+out_cancel_cgroup:
+	mem_cgroup_cancel_charge(page, memcg, false);
 out_page:
 	unlock_page(page);
 out_release:
@@ -2934,8 +2958,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
 						vma->vm_page_prot));
-		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-				vmf->address, &vmf->ptl);
+		if (!pte_map_lock(vmf))
+			return VM_FAULT_RETRY;
 		if (!pte_none(*vmf->pte))
 			goto unlock;
 		ret = check_stable_address_space(vma->vm_mm);
@@ -2971,14 +2995,16 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
-	if (!pte_none(*vmf->pte))
+	if (!pte_map_lock(vmf)) {
+		ret = VM_FAULT_RETRY;
 		goto release;
+	}
+	if (!pte_none(*vmf->pte))
+		goto unlock_and_release;
 
 	ret = check_stable_address_space(vma->vm_mm);
 	if (ret)
-		goto release;
+		goto unlock_and_release;
 
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
@@ -3000,10 +3026,12 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return ret;
+unlock_and_release:
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
-	goto unlock;
+	return ret;
 oom_free_page:
 	put_page(page);
 oom:
@@ -3118,8 +3146,9 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
 	 * pte_none() under vmf->ptl protection when we return to
 	 * alloc_set_pte().
 	 */
-	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
-			&vmf->ptl);
+	if (!pte_map_lock(vmf))
+		return VM_FAULT_RETRY;
+
 	return 0;
 }
 
-- 
2.21.0

