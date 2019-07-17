Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FB10C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10D6221849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10D6221849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9451E6B0005; Wed, 17 Jul 2019 17:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CE946B0006; Wed, 17 Jul 2019 17:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7959C8E0001; Wed, 17 Jul 2019 17:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2B56B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:59:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so12000727pgq.4
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NXJtoxitHhlDQoPNi265FByj0rrIqDH/87FnzCF7KHo=;
        b=OCehrEU+jYwb73XW3TDiZFhZk1wQwglyHdxcHIHL62Wg0UssP6nHa1m/tF3FMQHvFn
         7V4s4VmpB/+2anvPMuTcVOZhUA4tOZ0KGuAuCOGXpCU5zam0xMAXXLczjq/BHNtKRe71
         0lDi7C9bnbh++eIhBE3qHAaB+Dw01c7PJo0ilzxGeXhHF4tvJRbGvH5GHjt1ajybtK+e
         lEfKwjaTg/8YvgL3bdWI8Za0kxO87r+auPxyYm91dJ6sMWFiAbcqFR6/OoeZZRV00DCC
         UI9bhy3m/k+0jJRpB7dwK/1Xzx32crCco9kb43KDdFzoXMlCi2BqrcoaNTtij2EK1i3c
         Od+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXzQ9tpRRg6Kebe4uQdKjXVqG63tBQm/C4j0BlkN9kzavbT22L4
	Xhp4k577rXfawrPUDZLaoRoSDo+Ylj89BpzpU1dlxs8KrxlACybUqUHdbFhNxqgFH075IOt9rZ6
	usNcEcPuQPcDZ2zH0mlKAsPJAgooajfQB6aFu8sDrZySHHpp8NMZumotflyVajcRpHg==
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr47072437pjs.73.1563400781925;
        Wed, 17 Jul 2019 14:59:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX3y4GUfNviJYyMwf78MLFeD8HeE0S9q34laOEt6+fP/buiy3ND0FXqrwb4cI6+RNw9i7M
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr47072386pjs.73.1563400781001;
        Wed, 17 Jul 2019 14:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400780; cv=none;
        d=google.com; s=arc-20160816;
        b=LuLVUFJ2qZE9LMFYyeRpjOB8ualwvyapb4hbZvKNmFnS1xSNWHz0gg6Av3eiop0apk
         BrhirylnKWawM+lVFIcNc1Eev1WjupgqDTLTfuXOksjgk4Etkc0WXJsaBcfTgTykHMXO
         wl/p+odlfryFEk5BTi8HlXv24K+9nNZAiUGoE0OvtshCTXqpEP++2OTkzXsHxtmiAap4
         vz0Br4zDjl8JU9EquJGiJjBRWub8VOOYlBpeMJrGyPnqH6L4Bt0m6/8wdqGI04JlV2KN
         9shrjjkr9I7gk2zdsHLgGSyB1gNw36OLixsVYt6BKCQzhMB24VF1aYSHNZu6lFGq24E9
         dW9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NXJtoxitHhlDQoPNi265FByj0rrIqDH/87FnzCF7KHo=;
        b=FcS3z9Wh5uVzE3zvNP0hgjUj6FmIbu3hhMEBLELXEJUsevwOQqisuNoV8YhCpJTekx
         oiEJHJ5GBMWb+f1mO9B+GTYniVIrfAiBwrdB7D4LFbHwtBJDlF63rqiwC0u2kW0a4irc
         yVvFgkWOLQ8JziaHCNGOufEEgwD0/M7zoUybgQzSuCumSdsepa+tVwSoNPEQdZ8YGu7M
         LwaSSG3r/w7BsCSWL+SxmiY7iOBr+GgIytT8NVyArha+JhcQpBFH7+pxA4f/bmDNpXUz
         XYJ79xWT2COWBxXihYHyKRCUQrXng/65uSaVYcdpVEXMjmHwJM6B7Xqbfm4uLY7fWhnD
         jF0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id q12si1752294pgt.447.2019.07.17.14.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TX9KWw9_1563400771;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX9KWw9_1563400771)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 05:59:38 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: hughd@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP eligibility
Date: Thu, 18 Jul 2019 05:59:18 +0800
Message-Id: <1563400758-124759-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
vma") introduced THPeligible bit for processes' smaps. But, when checking
the eligibility for shmem vma, __transparent_hugepage_enabled() is
called to override the result from shmem_huge_enabled().  It may result
in the anonymous vma's THP flag override shmem's.  For example, running a
simple test which create THP for shmem, but with anonymous THP disabled,
when reading the process's smaps, it may show:

7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
Size:               4096 kB
...
[snip]
...
ShmemPmdMapped:     4096 kB
...
[snip]
...
THPeligible:    0

And, /proc/meminfo does show THP allocated and PMD mapped too:

ShmemHugePages:     4096 kB
ShmemPmdMapped:     4096 kB

This doesn't make too much sense.  The shmem objects should be treated
separately from anonymous THP.  Calling shmem_huge_enabled() with checking
MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
dax vma check since we already checked if the vma is shmem already.

Also check if vma is suitable for THP by calling
transhuge_vma_suitable().

And minor fix to smaps output format and documentation.

Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
Acked-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/filesystems/proc.txt | 4 ++--
 fs/proc/task_mmu.c                 | 3 ++-
 mm/huge_memory.c                   | 9 +++++++--
 mm/shmem.c                         | 3 +++
 4 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fb4735f..99ca040 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -486,8 +486,8 @@ replaced by copy-on-write) part of the underlying shmem object out on swap.
 "SwapPss" shows proportional swap share of this mapping. Unlike "Swap", this
 does not take into account swapped out page of underlying shmem objects.
 "Locked" indicates whether the mapping is locked in memory or not.
-"THPeligible" indicates whether the mapping is eligible for THP pages - 1 if
-true, 0 otherwise.
+"THPeligible" indicates whether the mapping is eligible for allocating THP
+pages - 1 if true, 0 otherwise. It just shows the current status.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 818cedb..731642e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -832,7 +832,8 @@ static int show_smap(struct seq_file *m, void *v)
 
 	__show_smap(m, &mss, false);
 
-	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
+	seq_printf(m, "THPeligible:		%d\n",
+		   transparent_hugepage_enabled(vma));
 
 	if (arch_pkeys_enabled())
 		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 782dd14..1334ede 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -63,10 +63,15 @@
 
 bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
+	/* The addr is used to check if the vma size fits */
+	unsigned long addr = (vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE;
+
+	if (!transhuge_vma_suitable(vma, addr))
+		return false;
 	if (vma_is_anonymous(vma))
 		return __transparent_hugepage_enabled(vma);
-	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
-		return __transparent_hugepage_enabled(vma);
+	if (vma_is_shmem(vma))
+		return shmem_huge_enabled(vma);
 
 	return false;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index f4dce9c..64e5d59 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3872,6 +3872,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 	loff_t i_size;
 	pgoff_t off;
 
+	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
+	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
+		return false;
 	if (shmem_huge == SHMEM_HUGE_FORCE)
 		return true;
 	if (shmem_huge == SHMEM_HUGE_DENY)
-- 
1.8.3.1

