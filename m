Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D0E1C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0820222BB
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0820222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06F926B028D; Tue, 16 Apr 2019 09:47:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01F836B0290; Tue, 16 Apr 2019 09:47:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07A36B0291; Tue, 16 Apr 2019 09:47:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B78DA6B028D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:34 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id a75so15577030ywh.8
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=kUz3G0QDyjTuW2R2fjyO6alqd0rMD6GtLnwwAlb/tIs=;
        b=rXVu32TTsqtghqfKi+HEZFHwaIz8akQJr9FyFwW+LNhyJCCj0IM43tF65s5R4MD9Uc
         0Mf8iasf+41eg+a8DiZhWjJPyuhI/a8nxVN6VA1acGJLLvLitr8/ST0QhirhbPuDSnxN
         EdujeX73uCtFxVXyABiAqpJzQQc58YqlIjeU2RwR5UqORIqi4W4ckdSHDmdjhAWJKcbs
         BRnrZKAcr3VJoih8Ty4OSGstC5EIlaYZUgP8GF2+Ho/RzstpVe5h0CXzmJADlribIHFO
         3q9u6Rjp1KBjVnfByMsVLUeTLWI8EmcU500J89i9s4B0YZhD6vJhLTfyViNk7fXi/Z8G
         7Trw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUQNF0IfawYhWEdEwvnsagUl65ikEgcg0yhWADJiMiMBbJiokp3
	UKwpvHwQYszZRT6n9SJXE1WMym1RzKxrHSOUr1JhxbSv/Qe8xCUTGcG60Xm9LUs25+IWDOrAOV1
	Gsu812AwUo1WY7VBNZqvb6Dklv+CpRx/ZDnCulVnLZ7p/5XH0x8AV5gm92y5aN5He1A==
X-Received: by 2002:a5b:4c8:: with SMTP id u8mr1406905ybp.291.1555422454404;
        Tue, 16 Apr 2019 06:47:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyoZWyXd895k3WhFq3drx2t1ASveKg6+iRG2uYCLCbwhMJHDCHZ6fjX378FBHSEQNEaCBa
X-Received: by 2002:a5b:4c8:: with SMTP id u8mr1406830ybp.291.1555422453473;
        Tue, 16 Apr 2019 06:47:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422453; cv=none;
        d=google.com; s=arc-20160816;
        b=x41J7rbugwIt5ZI3e2uXrUM3TYowEXbpW1uBfQJcYO/92kLnGCaqdIywp4GaTUTneF
         5gbE2VVR8eNSuhVadum1xVQXDsIoG41nUiDVnVxmIO5mByNxqjoYJqW6BR2vk3DTWrUF
         fwRUqSQZvtW7iQsMhLW7gHBWB1myb8UVASde89YY761DvFH5NAHAzRpzk2EckVoUCxoL
         AtzQwFMxtUI8BljYgPXyv+oeoYlzMR9jh11v2jNyeyvL+49AB3QENkJbsHchAiQHHY66
         mcgzPhO/QVPqvKTSw+J8VYiK5Rj4yWLx63mqhmvP9xa0OPO9ErvE1zApGt1IKxo6wB6D
         hXYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=kUz3G0QDyjTuW2R2fjyO6alqd0rMD6GtLnwwAlb/tIs=;
        b=xwRLtvtLvHsaOv/kBJajmL5IdQQ66tQK8UT4+5f4VKUlZwh3eEyBKGmOxHFEwCARHb
         tWoWqzhnDEPLWclzCzAaSDCMxNcHhs0Jx8NzTsUkIHtKSG3WudKQHVgtCQu0cnFhXkYM
         GT52Wi6JW35Hm4DBi+eGVr+BsW4ynOLPNDooXUX/cLHFiDF6smiPa//ROR+wM8OeuddX
         O8aBmDa0LDRIklY1DirpBOcX/qantt2bopJdT/5Bbl/+GB5rOxwe+SzoliMgBKiB6tKA
         +G46ygRuhxDX+WYQTv65zejv24eazxIp3XDANP+Ls/kurG8QZ8WvMtCLCh7SjS+O7Kt2
         KXQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v1si20354733ywf.2.2019.04.16.06.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlJw8091703
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwfsus81v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:23 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:01 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:51 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjneJ48103450
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:49 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5AF6A4C05A;
	Tue, 16 Apr 2019 13:45:49 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE2934C059;
	Tue, 16 Apr 2019 13:45:47 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:47 +0000 (GMT)
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
Subject: [PATCH v12 09/31] mm: VMA sequence count
Date: Tue, 16 Apr 2019 15:45:00 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0012-0000-0000-0000030F6EFB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0013-0000-0000-00002147A858
Message-Id: <20190416134522.17540-10-ldufour@linux.ibm.com>
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

From: Peter Zijlstra <peterz@infradead.org>

Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
counts such that we can easily test if a VMA is changed.

The calls to vm_write_begin/end() in unmap_page_range() are
used to detect when a VMA is being unmap and thus that new page fault
should not be satisfied for this VMA. If the seqcount hasn't changed when
the page table are locked, this means we are safe to satisfy the page
fault.

The flip side is that we cannot distinguish between a vma_adjust() and
the unmap_page_range() -- where with the former we could have
re-checked the vma bounds against the address.

The VMA's sequence counter is also used to detect change to various VMA's
fields used during the page fault handling, such as:
 - vm_start, vm_end
 - vm_pgoff
 - vm_flags, vm_page_prot
 - anon_vma
 - vm_policy

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Port to 4.12 kernel]
[Build depends on CONFIG_SPECULATIVE_PAGE_FAULT]
[Introduce vm_write_* inline function depending on
 CONFIG_SPECULATIVE_PAGE_FAULT]
[Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
 using vm_raw_write* functions]
[Fix a lock dependency warning in mmap_region() when entering the error
 path]
[move sequence initialisation INIT_VMA()]
[Review the patch description about unmap_page_range()]
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm.h       | 44 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  3 +++
 mm/memory.c              |  2 ++
 mm/mmap.c                | 30 +++++++++++++++++++++++++++
 4 files changed, 79 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2ceb1d2869a6..906b9e06f18e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1410,6 +1410,9 @@ struct zap_details {
 static inline void INIT_VMA(struct vm_area_struct *vma)
 {
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqcount_init(&vma->vm_sequence);
+#endif
 }
 
 struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
@@ -1534,6 +1537,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+static inline void vm_write_begin(struct vm_area_struct *vma)
+{
+	write_seqcount_begin(&vma->vm_sequence);
+}
+static inline void vm_write_begin_nested(struct vm_area_struct *vma,
+					 int subclass)
+{
+	write_seqcount_begin_nested(&vma->vm_sequence, subclass);
+}
+static inline void vm_write_end(struct vm_area_struct *vma)
+{
+	write_seqcount_end(&vma->vm_sequence);
+}
+static inline void vm_raw_write_begin(struct vm_area_struct *vma)
+{
+	raw_write_seqcount_begin(&vma->vm_sequence);
+}
+static inline void vm_raw_write_end(struct vm_area_struct *vma)
+{
+	raw_write_seqcount_end(&vma->vm_sequence);
+}
+#else
+static inline void vm_write_begin(struct vm_area_struct *vma)
+{
+}
+static inline void vm_write_begin_nested(struct vm_area_struct *vma,
+					 int subclass)
+{
+}
+static inline void vm_write_end(struct vm_area_struct *vma)
+{
+}
+static inline void vm_raw_write_begin(struct vm_area_struct *vma)
+{
+}
+static inline void vm_raw_write_end(struct vm_area_struct *vma)
+{
+}
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
+
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd7d38ee2e33..e78f72eb2576 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -337,6 +337,9 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqcount_t vm_sequence;
+#endif
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/memory.c b/mm/memory.c
index d5bebca47d98..423fa8ea0569 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1256,6 +1256,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	vm_write_begin(vma);
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -1265,6 +1266,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
+	vm_write_end(vma);
 }
 
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 5ad3a3228d76..a4e4d52a5148 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -726,6 +726,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	/*
+	 * Why using vm_raw_write*() functions here to avoid lockdep's warning ?
+	 *
+	 * Locked is complaining about a theoretical lock dependency, involving
+	 * 3 locks:
+	 *   mapping->i_mmap_rwsem --> vma->vm_sequence --> fs_reclaim
+	 *
+	 * Here are the major path leading to this dependency :
+	 *  1. __vma_adjust() mmap_sem  -> vm_sequence -> i_mmap_rwsem
+	 *  2. move_vmap() mmap_sem -> vm_sequence -> fs_reclaim
+	 *  3. __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem
+	 *  4. unmap_mapping_range() i_mmap_rwsem -> vm_sequence
+	 *
+	 * So there is no way to solve this easily, especially because in
+	 * unmap_mapping_range() the i_mmap_rwsem is grab while the impacted
+	 * VMAs are not yet known.
+	 * However, the way the vm_seq is used is guarantying that we will
+	 * never block on it since we just check for its value and never wait
+	 * for it to move, see vma_has_changed() and handle_speculative_fault().
+	 */
+	vm_raw_write_begin(vma);
+	if (next)
+		vm_raw_write_begin(next);
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
@@ -950,6 +974,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
+			if (next)
+				vm_raw_write_begin(next);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -996,6 +1022,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	if (next && next != vma)
+		vm_raw_write_end(next);
+	vm_raw_write_end(vma);
+
 	validate_mm(mm);
 
 	return 0;
-- 
2.21.0

