Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68F34C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:52:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2568C23CF3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:52:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ou6wWs+h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2568C23CF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB9A26B0276; Tue,  4 Jun 2019 12:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6D976B0277; Tue,  4 Jun 2019 12:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC0B26B0278; Tue,  4 Jun 2019 12:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A34376B0276
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:51:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t8so9788414ywf.19
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Dvy8H8Me5IhbWeZE5T8MjN8uMJLZ8NXUKaabsq8Cic4=;
        b=VvL5Aar5GCKQLGSLD4v2i5rkziwTurwGs476lTjfaWyrXPLOYEwe+0D9Y1/0pCJVqZ
         AUPigZf2/XhyvrZB6Z/oP1LbLvsTW9uq5Nkmmw+1MSRlJhkExTe8gLMxrk+F10frB9l1
         bahkq6go3p/riOVIqeln5QakRjMJOq4ua8oZ8QmH/jxSJXECxV70Cch0BSX+I1twR1vs
         iGcyIxeSrd98KSGJ5yOmc0YN/mR3SposcZ0AsqSxqpJFr1RtFySJmwIEjFdSu6ijD2Q/
         8NbSCV/AL46z3PJ5qyHvtrT5vxFpI20pQlVXhkFyu5tg7h5p9Dc0TlLKHG+WFOPIE9XK
         W08w==
X-Gm-Message-State: APjAAAUeS+0fwL/keRwM0O/u8ycsRE5wBiKanUj0rxafw+L7YJ6CySGk
	vqcPlwpUSXBug4aYta5cOhoVqYqlqooWP3FTvTdvpGeOoDQcecMYrIJSTKKSi2BUxZVk9CHJiGi
	mEAn+zFMyDw/0JetdgrLzW6HQg2Qrwb/5gBu9abnLErd8FMo5n9qgCvdal1cXMdh9oA==
X-Received: by 2002:a25:4b84:: with SMTP id y126mr15084886yba.136.1559667118420;
        Tue, 04 Jun 2019 09:51:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHkaxF9cbBnx6umfsM60/iuN3LPi6mIJLfuwaNhjYrvxpPouM95DRsPnxzt3D3j1dMzTbQ
X-Received: by 2002:a25:4b84:: with SMTP id y126mr15084859yba.136.1559667117833;
        Tue, 04 Jun 2019 09:51:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667117; cv=none;
        d=google.com; s=arc-20160816;
        b=cmMeOxwXvXZ8mG3a8lC5K1BWjBvRwu6G9RdHYdEbv7D+Kga9gYRSykqJ8PNn8pjdmg
         8IDnte2C44A08fMqwxCS5b+BJjKnc4QBiqZ4GqzllGQ1PY48Y8M3Sl6n5nxW0JTzTepZ
         C+n9f4dmO09kKNuW9IPH/+JvUPMkfqz0FQ/aQVyyUpsz/+fessz3eze9GP+A1nDwA1Hq
         +y2tBviYiu09fjPSlbeJnHRHh0f8Tjy3OrJKT8Lz33ldZgTLa/9fcA5jnS57n9b4bcd0
         JoBCY/r1F4YzycTrZ/3e7gV07sy12/3rsfVsSdKWY4Ta5UnXayqA45SRCDLpHPtSbUai
         WjDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Dvy8H8Me5IhbWeZE5T8MjN8uMJLZ8NXUKaabsq8Cic4=;
        b=E+FpFMWJgUemZgg2Qr0qKCmV14Te1mYptKpDywX3Jxxb9ucjnXse+3VfpeY1SpR/3Q
         WsYUeC9K7YvWF+bqSU331Kisj/ZxoITW9WYT1DGwahJrVLOaUXqmlB4pNTLLkNTeVHg2
         fm2gqlzJsdWpsqFcXy1y+nOoNJ6AOH/L5S4gSaA0NxKYifvNWpnvKB0typym7B/VvpS4
         EYkhw2bPIBawwi/tf9H7bq57eWGeDyD3nOnlOvQKixiHBW7pJAD27RFarrUJnByG3P53
         OiIxgDJyJ/yHvk+1zD2b5Z0aVA3xBoq+VGGHdNeF2IViEL/3Dtfdo0HvAIn47Xfl9T9/
         CK4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ou6wWs+h;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r128si6311372ywf.303.2019.06.04.09.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:51:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ou6wWs+h;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x54GeO0B008987
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:51:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Dvy8H8Me5IhbWeZE5T8MjN8uMJLZ8NXUKaabsq8Cic4=;
 b=Ou6wWs+hOMKUtCOADrukHWccLV9czCMuqvnZ0cwB2fbFH+0j8l3XbwMmI/Hu3dEvrpqb
 6iAFbuh7jDr8sgCJoqPWHDpT4g1TIKlzfq4OxXR5aWmc81f2N1iukMO5ZWt3cKd8o/VC
 2e3Z1xTRKTbucIT8RiMMyTJPUlW/0A7R/gQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2sw8mybnsc-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:56 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 09:51:55 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8A48A62E1EE3; Tue,  4 Jun 2019 09:51:52 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <mhiramat@kernel.org>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp v2 5/5] uprobe: collapse THP pmd after removing all uprobes
Date: Tue, 4 Jun 2019 09:51:38 -0700
Message-ID: <20190604165138.1520916-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190604165138.1520916-1-songliubraving@fb.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=783 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040106
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
 include/linux/huge_mm.h |  7 +++++
 kernel/events/uprobes.c |  3 ++
 mm/huge_memory.c        | 70 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 80 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..b969022dc922 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,9 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+extern inline void try_collapse_huge_pmd(struct vm_area_struct *vma,
+					 struct page *page);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -368,6 +371,10 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline void try_collapse_huge_pmd(struct vm_area_struct *vma,
+					 struct page *page) {}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 88a8e1624bfa..0c8e2358dbf5 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -537,6 +537,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	if (!ret && orig_page && PageTransCompound(orig_page))
+		try_collapse_huge_pmd(vma, orig_page);
+
 	return ret;
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9a6b32..03855a480fd2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2886,6 +2886,76 @@ static struct shrinker deferred_split_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
+/**
+ * try_collapse_huge_pmd - try collapse pmd for a pte mapped huge page
+ * @vma: vma containing the huge page
+ * @page: any sub page of the huge page
+ */
+void try_collapse_huge_pmd(struct vm_area_struct *vma,
+			   struct page *page)
+{
+	struct page *hpage = compound_head(page);
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
+	unsigned long haddr;
+	unsigned long addr;
+	pmd_t *pmd, _pmd;
+	int i, count = 0;
+	spinlock_t *ptl;
+
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
+
+	haddr = page_address_in_vma(hpage, vma);
+	pmd = mm_find_pmd(mm, haddr);
+	if (!pmd)
+		return;
+
+	ptl = pmd_lock(mm, pmd);
+
+	/* step 1: check all mapped PTEs */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+
+		if (pte_none(*pte))
+			continue;
+		if (hpage + i != vm_normal_page(vma, addr, *pte)) {
+			spin_unlock(ptl);
+			return;
+		}
+		count++;
+	}
+
+	/* step 2: adjust rmap and refcount */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *p;
+
+		if (pte_none(*pte))
+			continue;
+		p = vm_normal_page(vma, addr, *pte);
+		lock_page(p);
+		page_remove_rmap(p, false);
+		unlock_page(p);
+		put_page(p);
+	}
+
+	/* step 3: flip page table */
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+
+	_pmd = pmdp_collapse_flush(vma, haddr, pmd);
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(&range);
+
+	/* step 4: free pgtable, clean up counters, etc. */
+	mm_dec_nr_ptes(mm);
+	pte_free(mm, pmd_pgtable(_pmd));
+	add_mm_counter(mm,
+		       shmem_file(vma->vm_file) ? MM_SHMEMPAGES : MM_FILEPAGES,
+		       -count);
+}
+
 #ifdef CONFIG_DEBUG_FS
 static int split_huge_pages_set(void *data, u64 val)
 {
-- 
2.17.1

