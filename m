Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAFB8C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C6DF222BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C6DF222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2468C6B0010; Tue, 16 Apr 2019 09:46:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FA276B0266; Tue, 16 Apr 2019 09:46:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 097056B0269; Tue, 16 Apr 2019 09:46:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A75F16B0010
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s21so3585762edd.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=ZfEwFFloPr/8tc9stcBjbN7acEwKiBqAEeq/s4rwt0o=;
        b=ibn4q/q4rmQMD4PihVcnCsBFpaWJCAmkwyRi18D9N8hR1Ma/leGcZ8FEeXVyRAHirA
         dRbMFgevD0v7jrn7b1W8FcfjJUCzB5M+PQolcgl/KH/y8thtUTOwugUKGE8t0qem0Gs9
         ZMRg+qkMoigHkgI7tWsAh71tIrSrk1yY3DoDeJCE6iN0kkHrriFTv4wxsrPZIaXiUr8U
         9bbA4V3hJL6GNoIqqZRPOjTV66NazN7dn4GjyMq9MBlpGgw6/SnC2r0qADcdJn8sCnxg
         mHYYQn7Anxr2c7t5u1WmyDhgEeCIKazoxorrEN51HGjUckQgf5W713LCvnhVdhbTu8B+
         Sw9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWwGk36m4TM4udgHJevRByAIDDKTTlQ2sqN0EfhMNzJ31NeQlkl
	+coPl3dO0pFltl+SSfTI++12LzntRiexlbsGf2j978VNT7J/j02HoKel2UKbqIYiVrdDEqpJWLR
	WXxDi1l3TVCugbaPIq32nZsNw2R5pJSy7lmreWRJBfolrTH3kuuPm6tEkxiD727jNvg==
X-Received: by 2002:a17:906:4d4d:: with SMTP id b13mr44319316ejv.256.1555422413042;
        Tue, 16 Apr 2019 06:46:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFka9u/Og2CyLE+DtvOB8FpNiv96H3w4T5wwocLouhKUX+Irbt4O2thfEL9D2iwpMPrS8W
X-Received: by 2002:a17:906:4d4d:: with SMTP id b13mr44319244ejv.256.1555422411607;
        Tue, 16 Apr 2019 06:46:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422411; cv=none;
        d=google.com; s=arc-20160816;
        b=R1MDQolsus8PdvGk3oaImHlzV53CfaRZtK1iX3eRlO+isLGc/y1J0bdjFivhr6ei5S
         zOrA8D7AsyZoyquHw5sm2P20J6PNR8cWdrjCqofcoEaEFTv2iZcmDYWU4VbIxKlvXtNC
         HZWs4A9We54u6UhmyUsc6K1Xc3m5CQo4EXVzNhOdKz38Qun7fO+uMJgpR2vp279Mp9k4
         5lMNpflFSVkOKwdD5nKcPdeQ+EIs6x/fRgmO7HeFJStgp3kzEgHCO59ok73ANPkQ6+Bl
         6OC86G8b06e7NTuzmwQTNyROWgdEEQdguQmdfgCQm3vsDERiu1GE8+SOMvkKpz2Ca1oe
         P1ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=ZfEwFFloPr/8tc9stcBjbN7acEwKiBqAEeq/s4rwt0o=;
        b=MQM4Cd7P0/H9VKt98aL3ivUx68EwMlafgoE6JvB5mohVkEG/nutfolI6h42kPbmBZj
         3/e2pIk/0EytjUv6gOZo+qsaKYGJN5pe4sbjhtk8BDC8e4N1bL7fDjUIdQUqicc/Zyku
         SVNHdf/bPfR9J32i0ZWqVYVm16PCJb7LRkBqOiZldJ6jpSKWba4Ar1Onb+biQDOEjXdq
         GklJIHbvS6zGJQMbjzx7FuLUGKeCRKqwFLdJbEbIuHb024XWEuAIEFH/EIPsm3J6CQTt
         5yVPBAkrTKWhRJMBYfnjBo/6rRdSCIMWts9zQsum5oJ0LYZH5aGL2Y/k9A1kSjtCG8CX
         bTxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u8si1303533ejt.152.2019.04.16.06.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkJOD129673
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:49 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe6cnpn8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:47 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:31 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:22 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkLXG49545466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:21 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 06E084C044;
	Tue, 16 Apr 2019 13:46:21 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8661E4C040;
	Tue, 16 Apr 2019 13:46:18 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:18 +0000 (GMT)
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
Subject: [PATCH v12 19/31] mm: protect the RB tree with a sequence lock
Date: Tue, 16 Apr 2019 15:45:10 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7277
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD8F
Message-Id: <20190416134522.17540-20-ldufour@linux.ibm.com>
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

Introducing a per mm_struct seqlock, mm_seq field, to protect the changes
made in the MM RB tree. This allows to walk the RB tree without grabbing
the mmap_sem, and on the walk is done to double check that sequence counter
was stable during the walk.

The mm seqlock is held while inserting and removing entries into the MM RB
tree.  Later in this series, it will be check when looking for a VMA
without holding the mmap_sem.

This is based on the initial work from Peter Zijlstra:
https://lore.kernel.org/linux-mm/20100104182813.479668508@chello.nl/

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm_types.h |  3 +++
 kernel/fork.c            |  3 +++
 mm/init-mm.c             |  3 +++
 mm/mmap.c                | 48 +++++++++++++++++++++++++++++++---------
 4 files changed, 46 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e78f72eb2576..24b3f8ce9e42 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -358,6 +358,9 @@ struct mm_struct {
 	struct {
 		struct vm_area_struct *mmap;		/* list of VMAs */
 		struct rb_root mm_rb;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+		seqlock_t mm_seq;
+#endif
 		u64 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 		unsigned long (*get_unmapped_area) (struct file *filp,
diff --git a/kernel/fork.c b/kernel/fork.c
index 2992d2c95256..3a1739197ebc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1008,6 +1008,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqlock_init(&mm->mm_seq);
+#endif
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a787a319211e..69346b883a4e 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -27,6 +27,9 @@
  */
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	.mm_seq		= __SEQLOCK_UNLOCKED(init_mm.mm_seq),
+#endif
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
diff --git a/mm/mmap.c b/mm/mmap.c
index 13460b38b0fb..f7f6027a7dff 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -170,6 +170,24 @@ void unlink_file_vma(struct vm_area_struct *vma)
 	}
 }
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+static inline void mm_write_seqlock(struct mm_struct *mm)
+{
+	write_seqlock(&mm->mm_seq);
+}
+static inline void mm_write_sequnlock(struct mm_struct *mm)
+{
+	write_sequnlock(&mm->mm_seq);
+}
+#else
+static inline void mm_write_seqlock(struct mm_struct *mm)
+{
+}
+static inline void mm_write_sequnlock(struct mm_struct *mm)
+{
+}
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -445,26 +463,32 @@ static void vma_gap_update(struct vm_area_struct *vma)
 }
 
 static inline void vma_rb_insert(struct vm_area_struct *vma,
-				 struct rb_root *root)
+				 struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
+
 	/* All rb_subtree_gap values must be consistent prior to insertion */
 	validate_mm_rb(root, NULL);
 
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
-static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
+
 	/*
 	 * Note rb_erase_augmented is a fairly large inline function,
 	 * so make sure we instantiate it only once with our desired
 	 * augmented rbtree callbacks.
 	 */
+	mm_write_seqlock(mm);
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+	mm_write_sequnlock(mm);	/* wmb */
 }
 
 static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
-						struct rb_root *root,
+						struct mm_struct *mm,
 						struct vm_area_struct *ignore)
 {
 	/*
@@ -472,21 +496,21 @@ static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
 	 * with the possible exception of the "next" vma being erased if
 	 * next->vm_start was reduced.
 	 */
-	validate_mm_rb(root, ignore);
+	validate_mm_rb(&mm->mm_rb, ignore);
 
-	__vma_rb_erase(vma, root);
+	__vma_rb_erase(vma, mm);
 }
 
 static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
-					 struct rb_root *root)
+					 struct mm_struct *mm)
 {
 	/*
 	 * All rb_subtree_gap values must be consistent prior to erase,
 	 * with the possible exception of the vma being erased.
 	 */
-	validate_mm_rb(root, vma);
+	validate_mm_rb(&mm->mm_rb, vma);
 
-	__vma_rb_erase(vma, root);
+	__vma_rb_erase(vma, mm);
 }
 
 /*
@@ -601,10 +625,12 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * immediately update the gap to the correct value. Finally we
 	 * rebalance the rbtree after all augmented values have been set.
 	 */
+	mm_write_seqlock(mm);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	vma->rb_subtree_gap = 0;
 	vma_gap_update(vma);
-	vma_rb_insert(vma, &mm->mm_rb);
+	vma_rb_insert(vma, mm);
+	mm_write_sequnlock(mm);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -680,7 +706,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, mm, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -2674,7 +2700,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	vma->vm_prev = NULL;
 	do {
-		vma_rb_erase(vma, &mm->mm_rb);
+		vma_rb_erase(vma, mm);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
-- 
2.21.0

