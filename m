Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58BC8C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 125FA24224
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="i1ckGPPp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 125FA24224
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FD446B026F; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AD8F6B0273; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7003C6B026F; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 365A86B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 93so2423674plf.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=UArkez1wLqfjMeDv/pROrH5C6HuDZSMjR0N7lqYER04=;
        b=ZxlnCkfuwXWcJ0+TCk5SUjSkXGgBQsYrCx3rVP6BsLL+FYAeEMCEem+gM25/rLnQ27
         OGJTPM8a0KqefIGk7p7z6RENRdyneXJthoFK8C7Xo+Kxcra+82cCs55nlYbgFmII3iXW
         hfvaKvyotPzY4xEKAyVnITD81yXhaPAfCfT92D7bzRFFkf3i2/cG7h45BRQ1UG4YWcxX
         3htljo04J88/2SRRIzuOVjctrJ3lKsGSrMiEfWZ5PEwFxcD6Bt22pfI/DFI91PChRjBt
         8YXwLsujoTcg0ysjrnWv0Jl6CnMcp7fOUi0SjygnpqpM0niDYD0x61X4+RZ7JQTKvxkr
         t3Ww==
X-Gm-Message-State: APjAAAWRxl6TcER+d9WBelydwx+5ONsHXLpfaIuY8nkXHXCTAVb1cmGH
	EBsnPMtszqpKj6HORJAQSbNgSdZ96MPH0eOiPCCLxF+VLE90HrV1pkrea7Z9/WHXRERaw06ZehH
	yg2uVb1ATns0qqgvh/nFRXuDiF/f18eCrK/cmqfdlPzaVaBaWWqlfKTR3Vk/znFFzsQ==
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr150551940pfo.85.1559165813731;
        Wed, 29 May 2019 14:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsQPJq6uYZ0V7AHC+cFez2ImjFAQUWvfgnTY9QG9C9BWejKMGqpOhMC4TpAJN6HhFk3ZeQ
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr150551882pfo.85.1559165812698;
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165812; cv=none;
        d=google.com; s=arc-20160816;
        b=yC7KyQa0HqhA2FdO81Uw3RnEpZMeinfdxwQlReSlOQ3CsimLpeAFqd43G7V+PF6xxq
         gb6GzXTdAMTrZ3biL9hhVhLWxl6/TIz8VO03mRFcRf1Svzz+yADg8MBtKeYF7gNwPi9l
         rzEGeYzqtO5nVc0NB6tQVhcHtxrNSfH0TtaQcn8sSl00mke8yuSn6XgDXtZqcFK+YNGW
         X1jHEI+o6rCXG1KaS4SKQtRwIo4XZOOHUgL0Pw1lV1clV9BML1N4jvGY7FrHAjhe1I5M
         4u2Kh3VGFFetboRoJx4pNDq2RPbrbYRL5i7uq6jvvaaja8G+4zvesCjNsZj2sz6xcuzF
         hOvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=UArkez1wLqfjMeDv/pROrH5C6HuDZSMjR0N7lqYER04=;
        b=q7MJuqNMYpjvcnte8b/N5n8Eszikb3o0xCaakc8h7N+jE0aY/t+PkuQMY0hbM+lZQ3
         bxFJPA9r0FLotlzzhwpaR2D8FvxBYHnt5hLwHQq7El3M5KVPTZTW5gR2w7jrTJbhKeYt
         vmRlTS79bVtGAj3yQFFECCE6EWJkMVVkDSvnjTNNNtDXESx9TeLHQbKHDd6WpLOvbuAB
         eSsCAXV4aaYZM3WgCOkemJ95Hg3lOISJNdDaWc6JAOV5S9ciy85pjzSr3rRvR4c0M7xv
         U0mvl6HLxPDI7fef4hS0CqVHCk8VXrqUmf7M18PtfcdD8pCi+iHSUowsp+s/Qq1OO6kD
         cJlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=i1ckGPPp;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m13si908313pgj.577.2019.05.29.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=i1ckGPPp;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TLXFa9029780
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=UArkez1wLqfjMeDv/pROrH5C6HuDZSMjR0N7lqYER04=;
 b=i1ckGPPp7A/6a0YxZ05oFISrNStf/pYAXhCeWxn8FmdL5JNi1JGPfKAllMordz6uf/DV
 EktRl4V9y59BoXDexVHPEMovn5SLL9w5p/zqSFlL24v3+A8lE8YzOXGA5rOBY/hjs40q
 JW4PcnlMn5jMrSCpFZquBhAUs/CD5Y+C1b4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssqq9jb6r-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 29 May 2019 14:36:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 7984C62E2174; Wed, 29 May 2019 14:21:27 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp 4/4] uprobe: collapse THP pmd after removing all uprobes
Date: Wed, 29 May 2019 14:20:49 -0700
Message-ID: <20190529212049.2413886-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190529212049.2413886-1-songliubraving@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=725 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290134
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse.

An issue on earlier version was discovered by kbuild test robot.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/huge_mm.h |  9 ++++++++
 kernel/events/uprobes.c |  3 +++
 mm/huge_memory.c        | 47 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4832d6580969..61f6d574d9b4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -252,6 +252,10 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+extern inline void try_collapse_huge_pmd(struct mm_struct *mm,
+					 struct vm_area_struct *vma,
+					 unsigned long vaddr);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -377,6 +381,11 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline void try_collapse_huge_pmd(struct mm_struct *mm,
+					 struct vm_area_struct *vma,
+					 unsigned long vaddr) {}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 56eeccc2f7a2..422617bdd5ff 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -564,6 +564,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	if (!ret && orig_page && PageTransCompound(orig_page))
+		try_collapse_huge_pmd(mm, vma, vaddr);
+
 	return ret;
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4714871353c0..e2edec3ffd43 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2923,6 +2923,53 @@ static struct shrinker deferred_split_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
+/**
+ * This function only checks whether all PTEs in this PMD point to
+ * continuous pages, the caller should make sure at least of these PTEs
+ * points to a huge page, e.g. PageTransCompound(one_page) != 0.
+ */
+void try_collapse_huge_pmd(struct mm_struct *mm,
+			   struct vm_area_struct *vma,
+			   unsigned long vaddr)
+{
+	struct mmu_notifier_range range;
+	unsigned long addr;
+	pmd_t *pmd, _pmd;
+	spinlock_t *ptl;
+	long long head;
+	int i;
+
+	pmd = mm_find_pmd(mm, vaddr);
+	if (!pmd)
+		return;
+
+	addr = vaddr & HPAGE_PMD_MASK;
+	head = pte_val(*pte_offset_map(pmd, addr));
+	ptl = pmd_lock(mm, pmd);
+	for (i = 0; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+
+		if (pte_val(*pte) != head + i * PAGE_SIZE) {
+			spin_unlock(ptl);
+			return;
+		}
+	}
+
+	addr = vaddr & HPAGE_PMD_MASK;
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm,
+				addr, addr + HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+
+	_pmd = pmdp_collapse_flush(vma, addr, pmd);
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(&range);
+	mm_dec_nr_ptes(mm);
+	pte_free(mm, pmd_pgtable(_pmd));
+	add_mm_counter(mm,
+		       shmem_file(vma->vm_file) ? MM_SHMEMPAGES : MM_FILEPAGES,
+		       -HPAGE_PMD_NR);
+}
+
 #ifdef CONFIG_DEBUG_FS
 static int split_huge_pages_set(void *data, u64 val)
 {
-- 
2.17.1

