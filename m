Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D002C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BD8A222DF
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BD8A222DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4927F6B0298; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418356B029A; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E43F6B029C; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 007DA6B0298
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v123so15583162ywf.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=3IPoxrf+6+tcIsdMy7SAxB3smSVYv9hSJsTrPSmFiK0=;
        b=iF/K2QaFd7uNBKkCrRXJd1IzQBm5j481ldDS9Kmm7Q64Ou0aqOi0w86QKmSU6iobru
         VZCl5G2mYspqEof2PXctprDd0OcNNRTE0ijBoqOPOqJQ74QVsKMUeW3S1yxvDSp+w4Do
         w7fIew3CzKMhQUJkiIgXoYZEwrRXyDZMotFMIJ+e4naGYxJXowG6QEwNb4akFVXBkFuR
         1yrIyHGIxb4ZdS2pGzB5l7xbzMErrRNKBLJU9TdoaVZer9V2P+pL115Zh7Q4c+rgwX63
         pq9xh3Hcs8YkDkFZQ39OZyQLbd5+0GwZtTSi5eofd16KDncRVFIxZgErcMoQ85d7wHQo
         2dVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWgotX5BZ10wJgN+WRMcAsfQ8DjQuWJnnelQrcZOqQypxGC09LP
	u1uZmeY6faMCWQLzYG7S+BO9ob8uWdtjFIG8kQr01TeE+gxA36FasciKBpvYXr+ddGu+xPJFJlU
	SycVhiSKboGx6x7/S5n/9b1xSAWEPY9tZViJA7GpWJDaq/9NExytTDLrAUUr4AXW12A==
X-Received: by 2002:a81:2849:: with SMTP id o70mr65690896ywo.180.1555422482684;
        Tue, 16 Apr 2019 06:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw00QYIBluyT61NpLFJhGzZttDdEPvqvAVvCkFS8ESKNlrby4kM3MrCIZhXYEgV6Ez8wGWl
X-Received: by 2002:a81:2849:: with SMTP id o70mr65690688ywo.180.1555422480392;
        Tue, 16 Apr 2019 06:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422480; cv=none;
        d=google.com; s=arc-20160816;
        b=Lu6niWPC7BBnvp1js7r8BZgSpCWFelhQ1wZ+EIZJYdezfs7NFbLhcvMY8uQonal7xO
         nOKqfh+zyP5mJY/35llJPgJodXI8ZPKCMfj0wc1/hwnWxFOyPCMssi6mXnugsZ252I8U
         qpIxrnWe/Qbu28eo085XmlmnbGq9fxSO74Z78wnfRBWsQcrMr/N/xlojgEobLZ16XVwA
         xxiQJiGeS+gjwb/oiFl2iIyvZX2tBeapSu6CXMHeo2AMRPIalnSBlrnR+wj6kweEq2wN
         MX/Taggy4YUIX2ugaYEXyTOTJ8PcNDwVk2lGf6GzJsxzLG7NRVe3VFwyHxpRixxQwJV3
         IMMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=3IPoxrf+6+tcIsdMy7SAxB3smSVYv9hSJsTrPSmFiK0=;
        b=MlRWzpxdVj5A2odgjxwwp3uPClRjv8CAaG7d5dOZ3svDB3+0HZ+8gzngjrpzldEe1I
         vRszwoj37RvEghe9mWTJDKRCJcrdCGLtngJnKHpGhNJCvLpafecO/fSzYN9q9fD5P5Vl
         2S/FqPQTW/xOjgPgHSu/ofZJbiaWUIn1SjQByjYX7ghrFGfaZ5vam9J5z4u2rwf7xAU3
         4xi+OO4da30GVFeSmnOCYWyC2GAS07zgGp+v3NLtw23L6Izm5UAJHaKYqaa40zx5KfR5
         QITuNKkjO7QgXnsZRpZ+VDvD4v9jZmY9Td/V4RzwKxniQ12HPryXQKZPve0iWWASN4oi
         HuEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j185si30165534ywf.80.2019.04.16.06.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:48:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlTue093894
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:59 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe1t6dqp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:45 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:20 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:11 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDk9qK37617726
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:09 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 978DD4C040;
	Tue, 16 Apr 2019 13:46:09 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9DF8D4C04A;
	Tue, 16 Apr 2019 13:46:06 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:06 +0000 (GMT)
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
Subject: [PATCH v12 15/31] mm: introduce __lru_cache_add_active_or_unevictable
Date: Tue, 16 Apr 2019 15:45:06 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7275
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD8C
Message-Id: <20190416134522.17540-16-ldufour@linux.ibm.com>
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

The speculative page fault handler which is run without holding the
mmap_sem is calling lru_cache_add_active_or_unevictable() but the vm_flags
is not guaranteed to remain constant.
Introducing __lru_cache_add_active_or_unevictable() which has the vma flags
value parameter instead of the vma pointer.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/swap.h | 10 ++++++++--
 mm/memory.c          |  8 ++++----
 mm/swap.c            |  6 +++---
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..d33b94eb3c69 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -343,8 +343,14 @@ extern void deactivate_file_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
 extern void swap_setup(void);
 
-extern void lru_cache_add_active_or_unevictable(struct page *page,
-						struct vm_area_struct *vma);
+extern void __lru_cache_add_active_or_unevictable(struct page *page,
+						unsigned long vma_flags);
+
+static inline void lru_cache_add_active_or_unevictable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return __lru_cache_add_active_or_unevictable(page, vma->vm_flags);
+}
 
 /* linux/mm/vmscan.c */
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
diff --git a/mm/memory.c b/mm/memory.c
index 56802850e72c..85ec5ce5c0a8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2347,7 +2347,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
 		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(new_page, vma);
+		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
 		/*
 		 * We call the notify macro here because, when using secondary
 		 * mmu page tables (such as kvm shadow page tables), we want the
@@ -2896,7 +2896,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	if (unlikely(page != swapcache && swapcache)) {
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(page, vma);
+		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
@@ -3048,7 +3048,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(page, vma);
+	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 setpte:
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
@@ -3327,7 +3327,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(page, vma);
+		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
diff --git a/mm/swap.c b/mm/swap.c
index 3a75722e68a9..a55f0505b563 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -450,12 +450,12 @@ void lru_cache_add(struct page *page)
  * directly back onto it's zone's unevictable list, it does NOT use a
  * per cpu pagevec.
  */
-void lru_cache_add_active_or_unevictable(struct page *page,
-					 struct vm_area_struct *vma)
+void __lru_cache_add_active_or_unevictable(struct page *page,
+					   unsigned long vma_flags)
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
+	if (likely((vma_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		SetPageActive(page);
 	else if (!TestSetPageMlocked(page)) {
 		/*
-- 
2.21.0

