Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCCB1C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 823B8216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 823B8216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B87956B026B; Mon, 20 May 2019 10:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5D806B026C; Mon, 20 May 2019 10:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4C926B026D; Mon, 20 May 2019 10:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4C96B026B
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:39 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id e11so2632732lfn.19
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=qzFh73EFiUphac3v9UKerHFDloFYF/p8i538X3csTX4=;
        b=BgPYxkYsdIAqzgbImGuFaiYjH93M0NqogfJquOmGPpz/bopj0lfJd8prrLPmaef1Ym
         0x1UM+kZwtrHwuswpUFGx95eREYmHRbHHOdqYdpe6HhHoEOj2ys0tZoy2TcNou8FDqhM
         xbqRGayJL24hgmIOy7X7YvF7rzZ/dkE+BOIkYOn421y8hqFJUKxhYKNbsgMl6/eyEOTr
         IonGClv/m6VZLv8MqHmOuc1M0p6aCIgPoczZi98Ar0PGP5yUcLuUXPVf6fnqQ64rBSA8
         rZGtKNzMpxx1nLss4jMZYCFaggIcocL2y1iTkM8m+7scWH//3efV0HWga0Nd5VcmC1+t
         8goA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVUT/41zj7+Ye3Ka48WCxzRvvMyjOfcJbBY3zlHHt9r1tmHTOgz
	6I8ZO8z6zPxLwc1MbOL7A4UkwrRkrwrSCA4S+JUDZAPurbqGWpN+S16WcgT1SpnyGfd0XAI531z
	PqUtUB3exS0aFwhncU73qN3gHv3MH0X/jUIyN3qyVsQupjCppiX1Hw+nDkjw7SbzYPA==
X-Received: by 2002:a2e:9092:: with SMTP id l18mr3209641ljg.8.1558360838693;
        Mon, 20 May 2019 07:00:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP0tNK9INNt8xyEdYq/CWEjP/DyUN2dr7taZocM+mvxWIj4M5GpsC8wLHakXHoYuCTwL6S
X-Received: by 2002:a2e:9092:: with SMTP id l18mr3209582ljg.8.1558360837656;
        Mon, 20 May 2019 07:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360837; cv=none;
        d=google.com; s=arc-20160816;
        b=d83w/zTvAmkTgKC+RhBtXFcsD2KzD11s2F2aRT9aDDhsVcQ58ny36HB/qcTViW/NfC
         EEcfQhj43Re15l5jmR5X9oYTp1Bu6vQA/7ABsrFFYd+ys+MyEfdoFF3HS6MTZiJ08FR4
         E+MwufZXDz1G4dmvWK8G3HVkCYu/+t+pg4vi9J+bfEoMFQJKfw8RcEHfCsPteL/wp12m
         EqCrNiSmGDMAFCW/J+SXS1HGU5C9XiDC70hqR9YZR7nPA+VOx9W9fs/eUdXSDwLlQNjV
         oVgHI/UizSx5IGZeblwp+u3LnFIFJy0xLI6lx2qjtNVqBQE1ni+eYtUxaYSBn6hkppqb
         8vrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=qzFh73EFiUphac3v9UKerHFDloFYF/p8i538X3csTX4=;
        b=YxgYONYwBXbRUgViJiYofvg1nRhI8IIP3oszBxoQEJC7IaQH/fq9EAka5K1aJxLKgO
         JbA5qH2Dt0LB7Bjn3EUBEDfRFcb/bJaTMWfOMBCfHGlaKw39DQZ1me0E3hZXWDE5E6Cy
         uUat6+wYV+XFxpXq1Ej4l6eo8ZhMIHc9XpFLvWCkmGbaRidl+jKhm4QOdgWRfuRkYRnN
         izHgNSTH0H9M7ah9bXz9vPi/flQEyqMeahY/CnMq/tdmVfyoh0sNLhxyiIz0DJ2kKCwi
         ha3uroF117cai11S2z9IH5JqpqSJnSsEOidDZouuWHKV1TtGN+0AqlGoNuXer5OHa4FO
         fkfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v2si14275154ljg.12.2019.05.20.07.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSiqA-00083v-6q; Mon, 20 May 2019 17:00:34 +0300
Subject: [PATCH v2 6/7] mm: Introduce find_vma_filter_flags() helper
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:34 +0300
Message-ID: <155836083406.2441.7999607190635457587.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduce a new helper, which returns
vma of enough length at given address, but only
if it does not contain passed flags.

v2: New

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mm.h |    3 +++
 mm/mremap.c        |   39 ++++++++++++++++++++++++++-------------
 2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 54328d08dbdd..65ceb56acd44 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1515,6 +1515,9 @@ void unmap_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t nr, bool even_cows);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+struct vm_area_struct *find_vma_without_flags(struct mm_struct *mm,
+		unsigned long addr, unsigned long len,
+		unsigned long prohibited_flags);
 #else
 static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags)
diff --git a/mm/mremap.c b/mm/mremap.c
index 9a96cfc28675..dabae6a70287 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -430,14 +430,37 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	return new_addr;
 }
 
+struct vm_area_struct *find_vma_without_flags(struct mm_struct *mm,
+		unsigned long addr, unsigned long len,
+		unsigned long prohibited_flags)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+
+	if (!vma || vma->vm_start > addr)
+		return ERR_PTR(-EFAULT);
+
+	/* vm area boundaries crossing */
+	if (len > vma->vm_end - addr)
+		return ERR_PTR(-EFAULT);
+
+	if (vma->vm_flags & prohibited_flags)
+		return ERR_PTR(-EFAULT);
+
+	return vma;
+}
+
 static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	unsigned long old_len, unsigned long new_len, unsigned long *p)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma = find_vma(mm, addr);
-	unsigned long pgoff;
+	struct vm_area_struct *vma;
+	unsigned long pgoff, prohibited_flags = VM_HUGETLB;
 
-	if (!vma || vma->vm_start > addr)
+	if (old_len != new_len)
+		prohibited_flags |= VM_DONTEXPAND | VM_PFNMAP;
+
+	vma = find_vma_without_flags(mm, addr, old_len, prohibited_flags);
+	if (IS_ERR(vma))
 		return ERR_PTR(-EFAULT);
 
 	/*
@@ -453,13 +476,6 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 		return ERR_PTR(-EINVAL);
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		return ERR_PTR(-EINVAL);
-
-	/* We can't remap across vm area boundaries */
-	if (old_len > vma->vm_end - addr)
-		return ERR_PTR(-EFAULT);
-
 	if (new_len == old_len)
 		return vma;
 
@@ -469,9 +485,6 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (pgoff + (new_len >> PAGE_SHIFT) < pgoff)
 		return ERR_PTR(-EINVAL);
 
-	if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
-		return ERR_PTR(-EFAULT);
-
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = atomic64_read(&mm->locked_vm) << PAGE_SHIFT;

