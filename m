Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47F45C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC4AC222BC
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC4AC222BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7295F6B0272; Tue, 16 Apr 2019 09:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6890F6B0273; Tue, 16 Apr 2019 09:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502246B0274; Tue, 16 Apr 2019 09:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABC46B0272
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:05 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id y6so15678807ybb.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=VgB2qt03NSBRvN1xU3ANZYNuPmwAImtbKRl4F+x+2x8=;
        b=OFnF87wdqosKi/slonV0B8gY6mY+bzSqNsRQnXtv17wz+zjXCs1mZH/4fiyjLvD0tV
         ZDim9CP7c7x03DGHFNv+gzgaRw5B+1QJQUWoN9QoE49aSJnf4y69vBGmVkmOOESCTojS
         4gl2RYStGUqSzIE0/iSuSnTgDtqJYm1JVzBfvk1xY7drcDta36F7nqYQ96R43oxYs6Cw
         +6ld8jtqgBV2RGVFHmAGftg8OFzhhCkIpViYeQR/thanEDwtiGCK1Tb0jlmJ3RJVxPqP
         BFqBEYRYFN26S2nodW08vjbIouG3+wBS+gqmv/Xzrpi75KgYkWpUuRb6Z0FLl9x1A9c4
         Z4zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUe8a6Bud3DVYdBhHc/c0Qfb86Buh9weEhQe7QVAc8Dl3/k4Jys
	hUWuhCNppBBBOg6p0ObIK/tOL4R1UZvBuWonrRW6xK6Nfv1AMpeFAnKfRTveo4y8qw6RSsZx60w
	JvhVXhs63IpSvi0ODxHEYEiFYfMc5qEAdHCUIB77ISdowu+cc8+nnGvHzS7EISzZuug==
X-Received: by 2002:a81:3010:: with SMTP id w16mr64610223yww.388.1555422424818;
        Tue, 16 Apr 2019 06:47:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyptaVY5GIm2vfaldjrKv3GU7DNKQF7h6uzumICHW0rVrq47oH+faMftgOXoin1vbYkU28W
X-Received: by 2002:a81:3010:: with SMTP id w16mr64610110yww.388.1555422423596;
        Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422423; cv=none;
        d=google.com; s=arc-20160816;
        b=kg0DYAnrLcNvjTGTdzvpTnvYOGF5bQN5hGQKJbagOsz/cRdMb85rxmpV5DIXcdPTQk
         FGLpY2cDiE3JhJBXpQJku6YSFB4ShfA3r+69Lba8g2TM8FLHoCxJm2JkduOfKsmJAtxY
         b1QXo8B91RNQ4laDTd9jQT3xZVEFtU4/+OJGe9hVmIrK4UnPXS9zheLC+x2c6/gMkb7i
         b/wVcGTEXpDEzDMm3bOtWGiDEQPHJR/1STOg3F2M4xdSPH8GP2cnbAj7zfYHZ88FNPFV
         AFS0a1nnMbEJL8HDX891WgQHs0PKDlnGF1uziHc5od4IBiXX5SMFYdrUJSa9u1+8Zl2s
         c5Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=VgB2qt03NSBRvN1xU3ANZYNuPmwAImtbKRl4F+x+2x8=;
        b=LfOErS3HKuC93L3QYTDhXsK/ix8anW6+qnsEnsQEy1T7xuP9iEK+8ug/zwwk3ooFeS
         m/xNFQEeXLJZ/ovC6F/ORn/bv3KOfGuZpcJiPbq09qcZDESS6mJjitjB9O12cm/Xmyk+
         Hseze6cHpDAp42Owy9JFYv8lW2fUmKPA8I+jat3M4tipo1pg3jgNYVLG787eJnULLpxr
         GyZjeUHygrnkxhvw5M0Yt3L+XlN6PjzXf5TnsLZ30EaGXg6YG4rB8z9nIvh1ePXhhP/R
         BqbmTpBWfWkxccCkv9GvS/NU5wKBlvPjuFfe+0lqswEBdQNXxGjjgw4AwQ82kzc0Sz6d
         yrFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 132si33888358ybo.403.2019.04.16.06.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkioX114207
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:02 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwentmu4q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:53 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:24 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:16 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkE4q23724124
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:14 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 905DC4C04A;
	Tue, 16 Apr 2019 13:46:14 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 28B704C046;
	Tue, 16 Apr 2019 13:46:13 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:13 +0000 (GMT)
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
Subject: [PATCH v12 17/31] mm: introduce __page_add_new_anon_rmap()
Date: Tue, 16 Apr 2019 15:45:08 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0028-0000-0000-0000036170C0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0029-0000-0000-00002420A860
Message-Id: <20190416134522.17540-18-ldufour@linux.ibm.com>
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

When dealing with speculative page fault handler, we may race with VMA
being split or merged. In this case the vma->vm_start and vm->vm_end
fields may not match the address the page fault is occurring.

This can only happens when the VMA is split but in that case, the
anon_vma pointer of the new VMA will be the same as the original one,
because in __split_vma the new->anon_vma is set to src->anon_vma when
*new = *vma.

So even if the VMA boundaries are not correct, the anon_vma pointer is
still valid.

If the VMA has been merged, then the VMA in which it has been merged
must have the same anon_vma pointer otherwise the merge can't be done.

So in all the case we know that the anon_vma is valid, since we have
checked before starting the speculative page fault that the anon_vma
pointer is valid for this VMA and since there is an anon_vma this
means that at one time a page has been backed and that before the VMA
is cleaned, the page table lock would have to be grab to clean the
PTE, and the anon_vma field is checked once the PTE is locked.

This patch introduce a new __page_add_new_anon_rmap() service which
doesn't check for the VMA boundaries, and create a new inline one
which do the check.

When called from a page fault handler, if this is not a speculative one,
there is a guarantee that vm_start and vm_end match the faulting address,
so this check is useless. In the context of the speculative page fault
handler, this check may be wrong but anon_vma is still valid as explained
above.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/rmap.h | 12 ++++++++++--
 mm/memory.c          |  8 ++++----
 mm/rmap.c            |  5 ++---
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 988d176472df..a5d282573093 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -174,8 +174,16 @@ void page_add_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
-void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
-		unsigned long, bool);
+void __page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
+			      unsigned long, bool);
+static inline void page_add_new_anon_rmap(struct page *page,
+					  struct vm_area_struct *vma,
+					  unsigned long address, bool compound)
+{
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	__page_add_new_anon_rmap(page, vma, address, compound);
+}
+
 void page_add_file_rmap(struct page *, bool);
 void page_remove_rmap(struct page *, bool);
 
diff --git a/mm/memory.c b/mm/memory.c
index be93f2c8ebe0..46f877b6abea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2347,7 +2347,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
-		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(new_page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
 		/*
@@ -2897,7 +2897,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 	/* ksm created a completely new copy */
 	if (unlikely(page != swapcache && swapcache)) {
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
@@ -3049,7 +3049,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	}
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, vmf->address, false);
+	__page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 setpte:
@@ -3328,7 +3328,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	/* copy-on-write page */
 	if (write && !(vmf->vma_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..2148e8ce6e34 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1140,7 +1140,7 @@ void do_page_add_anon_rmap(struct page *page,
 }
 
 /**
- * page_add_new_anon_rmap - add pte mapping to a new anonymous page
+ * __page_add_new_anon_rmap - add pte mapping to a new anonymous page
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
@@ -1150,12 +1150,11 @@ void do_page_add_anon_rmap(struct page *page,
  * This means the inc-and-test can be bypassed.
  * Page does not have to be locked.
  */
-void page_add_new_anon_rmap(struct page *page,
+void __page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
 	int nr = compound ? hpage_nr_pages(page) : 1;
 
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	__SetPageSwapBacked(page);
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-- 
2.21.0

