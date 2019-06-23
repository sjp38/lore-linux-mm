Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10D59C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFABD208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Dt/12qf8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFABD208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5F366B000A; Sun, 23 Jun 2019 01:48:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A10568E0007; Sun, 23 Jun 2019 01:48:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8897E8E0006; Sun, 23 Jun 2019 01:48:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62C276B000A
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:50 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y205so10985692ywy.19
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=AtQj8VLyTrqRYrPUwfju4QOAPsUo2N5QiDA9TqjFheknvrhpcp/Liygp5UYhuFvf+1
         4bO2BNd0CbaBCsdAXFAr01OcOi532MMvHo7Y9ujzVSwXWWD2lQ2hzLbIP6/QTPSIpw86
         b6XIq5TXxki1hBVtQygHUAZY6MaifWKyPZ5jOa5TerfbISsSZ0RUzJLGsxPj6AmOoMUp
         XUlSAxnCN6W3M+tTvTn5CqHXqbxYnpuVYA0ipkVSZG39mpAWeohLSvMzNFeHWQCScI/x
         aSI9xzwEu59Zza6InST8ESw6jJ53uhOPAQ4sDKYXUuKU4cGYuCDb9bsfW3BtXpZpPbEG
         HSyQ==
X-Gm-Message-State: APjAAAXPpSMHketC/lGMpS2ilyuSna0xO3SiLgW/J9fWjrw/AvuJ2epC
	Dd1fpj4mU2jF0VrlKjkW35lOgYbK3r89hID2XMq7OG9chWWqQV2TZDIPbOeUngbtIECAvxvB3qi
	rJV8Fi/r+R81gOOyJMgTRwMvdhglgfKuwLXXLu+TpEuOVU82QMneq1N+YURaK8dSBCA==
X-Received: by 2002:a81:3903:: with SMTP id g3mr79560339ywa.304.1561268930136;
        Sat, 22 Jun 2019 22:48:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuYeWpFoga+qJL5XgDNrNvEPOBRxWOn1NdBVvbxhzX8Xk/OXuKstISjRfioD929GXsO6jk
X-Received: by 2002:a81:3903:: with SMTP id g3mr79560334ywa.304.1561268929622;
        Sat, 22 Jun 2019 22:48:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268929; cv=none;
        d=google.com; s=arc-20160816;
        b=jm9c4F8cQvPq6Bfe/2+B049Ue3Ix/cqfeoIwGdb6kbHGomFQmM9hiKnpBAywBzbZ9b
         DNVvsF3UkpmcvyS4Trir5200QKQVpW0eKuZKx+d55lnctKqJ2+1wx2bA9FjqXsVrDGrP
         sz0zSup+mEihGOCvdatlaQgA0OiBgKLUSAR3t1zeGT801g9PE6fKlB2Ke6SJwVPoY/sM
         9RxhOxLft+oZVJryDCNspM8OX0k5DQ8qqTXlEX7Sm9x3tkDro5RVk6xkzybFNeFuB4KH
         81t8bxZqko2GyOTENv/bc3DN4lwRCMrsu0u52Zj0CEJvLvhuNAxAGJMIXkvhtkZVlcop
         CsjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=vtSEnBKJkqsEElXhVXPO0jdOQyNNJwvXyg8fDY0DnL+BnDzugPanbrhc2YgqzIIj6M
         R4Sjy920CAb3f5TVFD76HVRJaKMWR9swA0x37YRShodvJb5ItLom44lpaXltCnL1g/zc
         XRdZ4MzHHL0yo01cMVFhr8HCkzdIGZondGZ/8okPUf042uS6+5lU875ZwDtC2LHHod5r
         Fhuxrjp6P/ZmMXQ+ZfH/QnnHxDKu3RrzRsyDhafBiDI/7+syOeKp1pfPaHfsxorKlq3s
         ZXCMbDd1a1TAAUCUhgz+wDKffuFQSKQWbAMltD9oZZ3Umtiq711MjPZ9l85s+rvelpZa
         CBFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Dt/12qf8";
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e1si150681yba.281.2019.06.22.22.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Dt/12qf8";
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5mlt0006687
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
 b=Dt/12qf8MBN6wdcG5X0gb23qTJOL1XuW1pi+Digq5HYIcaVku4TAWJ1tMk2ODFLK916b
 WKBtkxy9Yy77GXKfnDRsXgCMvqjVdAxdOC2ti12rz7uv1AfgswRH4WrHQ+/NXd1u2nO4
 uYo2KFAIwHwYPDABcb1zO+3b2TIjg3+LKu4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9j2ca3jp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:49 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3C08062E2CFB; Sat, 22 Jun 2019 22:48:47 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 2/6] uprobe: use original page when all uprobes are removed
Date: Sat, 22 Jun 2019 22:48:25 -0700
Message-ID: <20190623054829.4018117-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=990 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230051
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, uprobe swaps the target page with a anonymous page in both
install_breakpoint() and remove_breakpoint(). When all uprobes on a page
are removed, the given mm is still using an anonymous page (not the
original page).

This patch allows uprobe to use original page when possible (all uprobes
on the page are already removed).

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 45 +++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 78f61bfc6b79..f7c61a1ef720 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -160,16 +160,19 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	int err;
 	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
+	bool orig = new_page->mapping != NULL;  /* new_page == orig_page */
 
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
 
-	err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL, &memcg,
-			false);
-	if (err)
-		return err;
+	if (!orig) {
+		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
+					    &memcg, false);
+		if (err)
+			return err;
+	}
 
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(old_page);
@@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_invalidate_range_start(&range);
 	err = -EAGAIN;
 	if (!page_vma_mapped_walk(&pvmw)) {
-		mem_cgroup_cancel_charge(new_page, memcg, false);
+		if (!orig)
+			mem_cgroup_cancel_charge(new_page, memcg, false);
 		goto unlock;
 	}
 	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
 
 	get_page(new_page);
-	page_add_new_anon_rmap(new_page, vma, addr, false);
-	mem_cgroup_commit_charge(new_page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
+	if (orig) {
+		lock_page(new_page);  /* for page_add_file_rmap() */
+		page_add_file_rmap(new_page, false);
+		unlock_page(new_page);
+		inc_mm_counter(mm, mm_counter_file(new_page));
+		dec_mm_counter(mm, MM_ANONPAGES);
+	} else {
+		page_add_new_anon_rmap(new_page, vma, addr, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+	}
 
 	if (!PageAnon(old_page)) {
 		dec_mm_counter(mm, mm_counter_file(old_page));
@@ -501,6 +513,23 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_highpage(new_page, old_page);
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
+	if (!is_register) {
+		struct page *orig_page;
+		pgoff_t index;
+
+		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
+		orig_page = find_get_page(vma->vm_file->f_inode->i_mapping,
+					  index);
+
+		if (orig_page) {
+			if (pages_identical(new_page, orig_page)) {
+				put_page(new_page);
+				new_page = orig_page;
+			} else
+				put_page(orig_page);
+		}
+	}
+
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-- 
2.17.1

