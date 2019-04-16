Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB462C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A345222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A345222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C1B86B029B; Tue, 16 Apr 2019 09:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A07A6B029E; Tue, 16 Apr 2019 09:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59F946B029F; Tue, 16 Apr 2019 09:48:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 034826B029B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:48:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so10684942eda.8
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:48:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=Rzqn1HhdYspdyMrbZaPvWkCFg9mUFKqEPfg7Lcjtn5I=;
        b=glr4qmqFMQg/5a5tF2Wp8o/5qT/3Q6ZjKIvG6Qe35vlJw0z37CMoLluEVL0AXOeBSy
         IzadzR6AcY1CSYoFKsDMkMWonq8I9PmqjlldFRcDU4AdLNe9ej1ZYaulzoCzxpNzOAD4
         UEh3aAAabvs1UF53kqumcGj7kNSdoFXpl5I4oZQmeDIej7uWmIH/KoUzciQhShLIJ4RX
         KrlPGnhKy9sw+NwYTDChaeabPsNwbR2dxyYRDbApukuXkZN1UNzltOKkfHtoD711MFzd
         Lr3fXfeaF1qQT+hKbVax/TwNtVBxePB4qFZmfwSMgN2parjIfknEw4aipe8kTx78Vgb+
         7o9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVC1EzQ6LHln0g33lvdWlLCJHEsjlcbKleXdbmknuC1RVgODOGN
	RWoqMow8SVW6kqnhFDkvkpVQHDaNzc10nxNTtVJ6FLWOUQiZNAeq0fButZzD02JTk/rmBDxAUN4
	Utti7pgjON/Zd2DCaIg3VOusnVPBD2RtrV+Ez5nZuzrKu/mYzSkCt5YvHjygzvc49kQ==
X-Received: by 2002:a17:906:251b:: with SMTP id i27mr43830546ejb.146.1555422493423;
        Tue, 16 Apr 2019 06:48:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwouZ8YCWI8SnBB1QlOsGUcX3XKuBOa0FeV8Kh6YyBELcUSO3LJb2nAlY+e6xeVCD43+AY6
X-Received: by 2002:a17:906:251b:: with SMTP id i27mr43830457ejb.146.1555422491241;
        Tue, 16 Apr 2019 06:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422491; cv=none;
        d=google.com; s=arc-20160816;
        b=fpYWnNZ11AuJ6cg0BdEqMQNLzV3EQVNEMZEbDahElJODE/o2nG68cZb70casAMKNSt
         UK3CJzan5NK7fgSYWLnLi8gOjXfp3ZJH7TK+Ta7/fZk23Z+P6GuS6oOjQkkUfLTj0sXO
         KqPxcy8W7/AmWm5z3xfRDlJAkGD4GYrzmVIvLs5g9KjKwwzUGwUsV4soeP2MToliwQRu
         PNT4UxUrZSWk3lV8xd91pL56vKu4uhDQMk2wADkLfWkXKDYVwuHGuWUbtcVyJrFyFsOp
         cHeRsW2Mmy6odWCPP8l6FRV5d8xYAgWVwrtAERkLgAQNLrJ0CQPruZmvlBjLKYCgHick
         PPAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=Rzqn1HhdYspdyMrbZaPvWkCFg9mUFKqEPfg7Lcjtn5I=;
        b=ycJPJPbrEWANZb4+cpWoVVH+XsFMVclt/REM72kOpVIoBw/8xkgTqk0yvvcnZduRFt
         g8ND8dL3ipT4kXk/o23IkCt0UgCn13ViWZVSyOIg74UOUSZO2ttOTGndgO6Fa+IJf82w
         QPUCoH62nuICjURrnpXH0mIuwZq61gTj59s/M1jjYOP4zte+T6ACWtedWB90j+2vlwsg
         L2PJH7MxIUXIiDYbgCm+wIO8gNgbbG9LeQRayfJVa8Q1WM/ZXH+ksbRMgf+TJm4sD0BW
         j2ytewjWg25pFWYTgz6isB2k45hFBxMULEYqZaY6zB6dWawA6hZkkIMjn4p1V2qknf0o
         ZpzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z8si3309052edd.352.2019.04.16.06.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlHfR010806
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:48:09 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe56nxcm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:43 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:01 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:52 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjpCb52232298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:51 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0E2AF4C046;
	Tue, 16 Apr 2019 13:45:51 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 90FDA4C058;
	Tue, 16 Apr 2019 13:45:49 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:49 +0000 (GMT)
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
Subject: [PATCH v12 10/31] mm: protect VMA modifications using VMA sequence count
Date: Tue, 16 Apr 2019 15:45:01 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0020-0000-0000-000003307050
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0021-0000-0000-00002182B501
Message-Id: <20190416134522.17540-11-ldufour@linux.ibm.com>
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

The VMA sequence count has been introduced to allow fast detection of
VMA modification when running a page fault handler without holding
the mmap_sem.

This patch provides protection against the VMA modification done in :
	- madvise()
	- mpol_rebind_policy()
	- vma_replace_policy()
	- change_prot_numa()
	- mlock(), munlock()
	- mprotect()
	- mmap_region()
	- collapse_huge_page()
	- userfaultd registering services

In addition, VMA fields which will be read during the speculative fault
path needs to be written using WRITE_ONCE to prevent write to be split
and intermediate values to be pushed to other CPUs.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 fs/proc/task_mmu.c |  5 ++++-
 fs/userfaultfd.c   | 17 ++++++++++++----
 mm/khugepaged.c    |  3 +++
 mm/madvise.c       |  6 +++++-
 mm/mempolicy.c     | 51 ++++++++++++++++++++++++++++++----------------
 mm/mlock.c         | 13 +++++++-----
 mm/mmap.c          | 28 ++++++++++++++++---------
 mm/mprotect.c      |  4 +++-
 mm/swap_state.c    | 10 ++++++---
 9 files changed, 95 insertions(+), 42 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..0864c050b2de 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1162,8 +1162,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					goto out_mm;
 				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
-					vma->vm_flags &= ~VM_SOFTDIRTY;
+					vm_write_begin(vma);
+					WRITE_ONCE(vma->vm_flags,
+						 vma->vm_flags & ~VM_SOFTDIRTY);
 					vma_set_page_prot(vma);
+					vm_write_end(vma);
 				}
 				downgrade_write(&mm->mmap_sem);
 				break;
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3b30301c90ec..2e0f98cadd81 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -667,8 +667,11 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 
 	octx = vma->vm_userfaultfd_ctx.ctx;
 	if (!octx || !(octx->features & UFFD_FEATURE_EVENT_FORK)) {
+		vm_write_begin(vma);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
-		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
+		WRITE_ONCE(vma->vm_flags,
+			   vma->vm_flags & ~(VM_UFFD_WP | VM_UFFD_MISSING));
+		vm_write_end(vma);
 		return 0;
 	}
 
@@ -908,8 +911,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 			vma = prev;
 		else
 			prev = vma;
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vm_write_end(vma);
 	}
 skip_mm:
 	up_write(&mm->mmap_sem);
@@ -1474,8 +1479,10 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx.ctx = ctx;
+		vm_write_end(vma);
 
 	skip:
 		prev = vma;
@@ -1636,8 +1643,10 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * the next vma was merged into the current one and
 		 * the current one has not been updated yet.
 		 */
-		vma->vm_flags = new_flags;
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, new_flags);
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vm_write_end(vma);
 
 	skip:
 		prev = vma;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a335f7c1fac4..6a0cbca3885e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1011,6 +1011,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (mm_find_pmd(mm, address) != pmd)
 		goto out;
 
+	vm_write_begin(vma);
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
@@ -1046,6 +1047,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
+		vm_write_end(vma);
 		result = SCAN_FAIL;
 		goto out;
 	}
@@ -1081,6 +1083,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
 	spin_unlock(pmd_ptl);
+	vm_write_end(vma);
 
 	*hpage = NULL;
 
diff --git a/mm/madvise.c b/mm/madvise.c
index a692d2a893b5..6cf07dc546fc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -184,7 +184,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
-	vma->vm_flags = new_flags;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, new_flags);
+	vm_write_end(vma);
 out:
 	return error;
 }
@@ -450,9 +452,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 		.private = tlb,
 	};
 
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	walk_page_range(addr, end, &free_walk);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..94c103c5034a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -380,8 +380,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		vm_write_begin(vma);
 		mpol_rebind_policy(vma->vm_policy, new);
+		vm_write_end(vma);
+	}
 	up_write(&mm->mmap_sem);
 }
 
@@ -575,9 +578,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
+	vm_write_begin(vma);
 	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+	vm_write_end(vma);
 
 	return nr_updated;
 }
@@ -683,6 +688,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	vm_write_begin(vma);
 	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
@@ -690,11 +696,17 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	}
 
 	old = vma->vm_policy;
-	vma->vm_policy = new; /* protected by mmap_sem */
+	/*
+	 * The speculative page fault handler accesses this field without
+	 * hodling the mmap_sem.
+	 */
+	WRITE_ONCE(vma->vm_policy,  new);
+	vm_write_end(vma);
 	mpol_put(old);
 
 	return 0;
  err_out:
+	vm_write_end(vma);
 	mpol_put(new);
 	return err;
 }
@@ -1654,23 +1666,28 @@ COMPAT_SYSCALL_DEFINE4(migrate_pages, compat_pid_t, pid,
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
 {
-	struct mempolicy *pol = NULL;
+	struct mempolicy *pol;
 
-	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy) {
-			pol = vma->vm_ops->get_policy(vma, addr);
-		} else if (vma->vm_policy) {
-			pol = vma->vm_policy;
+	if (!vma)
+		return NULL;
 
-			/*
-			 * shmem_alloc_page() passes MPOL_F_SHARED policy with
-			 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
-			 * count on these policies which will be dropped by
-			 * mpol_cond_put() later
-			 */
-			if (mpol_needs_cond_ref(pol))
-				mpol_get(pol);
-		}
+	if (vma->vm_ops && vma->vm_ops->get_policy)
+		return vma->vm_ops->get_policy(vma, addr);
+
+	/*
+	 * This could be called without holding the mmap_sem in the
+	 * speculative page fault handler's path.
+	 */
+	pol = READ_ONCE(vma->vm_policy);
+	if (pol) {
+		/*
+		 * shmem_alloc_page() passes MPOL_F_SHARED policy with
+		 * a pseudo vma whose vma->vm_ops=NULL. Take a reference
+		 * count on these policies which will be dropped by
+		 * mpol_cond_put() later
+		 */
+		if (mpol_needs_cond_ref(pol))
+			mpol_get(pol);
 	}
 
 	return pol;
diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b36415b..f390903d9bbb 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -445,7 +445,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
-	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, vma->vm_flags & VM_LOCKED_CLEAR_MASK);
+	vm_write_end(vma);
 
 	while (start < end) {
 		struct page *page;
@@ -569,10 +571,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
-
-	if (lock)
-		vma->vm_flags = newflags;
-	else
+	if (lock) {
+		vm_write_begin(vma);
+		WRITE_ONCE(vma->vm_flags, newflags);
+		vm_write_end(vma);
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
 out:
diff --git a/mm/mmap.c b/mm/mmap.c
index a4e4d52a5148..b77ec0149249 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -877,17 +877,18 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	}
 
 	if (start != vma->vm_start) {
-		vma->vm_start = start;
+		WRITE_ONCE(vma->vm_start, start);
 		start_changed = true;
 	}
 	if (end != vma->vm_end) {
-		vma->vm_end = end;
+		WRITE_ONCE(vma->vm_end, end);
 		end_changed = true;
 	}
-	vma->vm_pgoff = pgoff;
+	WRITE_ONCE(vma->vm_pgoff, pgoff);
 	if (adjust_next) {
-		next->vm_start += adjust_next << PAGE_SHIFT;
-		next->vm_pgoff += adjust_next;
+		WRITE_ONCE(next->vm_start,
+			   next->vm_start + (adjust_next << PAGE_SHIFT));
+		WRITE_ONCE(next->vm_pgoff, next->vm_pgoff + adjust_next);
 	}
 
 	if (root) {
@@ -1850,12 +1851,14 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
+	vm_write_begin(vma);
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if ((vm_flags & VM_SPECIAL) || vma_is_dax(vma) ||
 					is_vm_hugetlb_page(vma) ||
 					vma == get_gate_vma(current->mm))
-			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+			WRITE_ONCE(vma->vm_flags,
+				   vma->vm_flags &= VM_LOCKED_CLEAR_MASK);
 		else
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
@@ -1870,9 +1873,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * then new mapped in-place (which must be aimed as
 	 * a completely new data area).
 	 */
-	vma->vm_flags |= VM_SOFTDIRTY;
+	WRITE_ONCE(vma->vm_flags, vma->vm_flags | VM_SOFTDIRTY);
 
 	vma_set_page_prot(vma);
+	vm_write_end(vma);
 
 	return addr;
 
@@ -2430,7 +2434,9 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 					mm->locked_vm += grow;
 				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
-				vma->vm_end = address;
+				vm_write_begin(vma);
+				WRITE_ONCE(vma->vm_end, address);
+				vm_write_end(vma);
 				anon_vma_interval_tree_post_update_vma(vma);
 				if (vma->vm_next)
 					vma_gap_update(vma->vm_next);
@@ -2510,8 +2516,10 @@ int expand_downwards(struct vm_area_struct *vma,
 					mm->locked_vm += grow;
 				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
-				vma->vm_start = address;
-				vma->vm_pgoff -= grow;
+				vm_write_begin(vma);
+				WRITE_ONCE(vma->vm_start, address);
+				WRITE_ONCE(vma->vm_pgoff, vma->vm_pgoff - grow);
+				vm_write_end(vma);
 				anon_vma_interval_tree_post_update_vma(vma);
 				vma_gap_update(vma);
 				spin_unlock(&mm->page_table_lock);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 65242f1e4457..78fce873ca3a 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -427,12 +427,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
 	 */
-	vma->vm_flags = newflags;
+	vm_write_begin(vma);
+	WRITE_ONCE(vma->vm_flags, newflags);
 	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
 
 	change_protection(vma, start, end, vma->vm_page_prot,
 			  dirty_accountable, 0);
+	vm_write_end(vma);
 
 	/*
 	 * Private VM_LOCKED VMA becoming writable: trigger COW to avoid major
diff --git a/mm/swap_state.c b/mm/swap_state.c
index eb714165afd2..c45f9122b457 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -523,7 +523,11 @@ static unsigned long swapin_nr_pages(unsigned long offset)
  * This has been extended to use the NUMA policies from the mm triggering
  * the readahead.
  *
- * Caller must hold read mmap_sem if vmf->vma is not NULL.
+ * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
+ * This is needed to ensure the VMA will not be freed in our back. In the case
+ * of the speculative page fault handler, this cannot happen, even if we don't
+ * hold the mmap_sem. Callees are assumed to take care of reading VMA's fields
+ * using READ_ONCE() to read consistent values.
  */
 struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 				struct vm_fault *vmf)
@@ -624,9 +628,9 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
 				     unsigned long *start,
 				     unsigned long *end)
 {
-	*start = max3(lpfn, PFN_DOWN(vma->vm_start),
+	*start = max3(lpfn, PFN_DOWN(READ_ONCE(vma->vm_start)),
 		      PFN_DOWN(faddr & PMD_MASK));
-	*end = min3(rpfn, PFN_DOWN(vma->vm_end),
+	*end = min3(rpfn, PFN_DOWN(READ_ONCE(vma->vm_end)),
 		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
 }
 
-- 
2.21.0

