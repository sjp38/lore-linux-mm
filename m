Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF61CC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F7720651
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:43:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F7720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AD166B000E; Tue, 23 Apr 2019 12:43:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15B5A6B0266; Tue, 23 Apr 2019 12:43:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09A246B0269; Tue, 23 Apr 2019 12:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAC066B000E
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:43:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t17so10627449plj.18
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=st9ctL0bwQXPnG+ZDcH92e0dsG3UcS5ETD78Lf3mweQ=;
        b=C1QaX4q658ICq4/Xr7NbehvwX9XgOygmUSEkLaV/lh1KOOdElyHR18AkS580xktvN0
         B9onFvfYFpeXDLGyB6+LC+dk5TgYgEB3cfLyhZDEGsXuaGYXh61dsaavhmg79I8kbL/Z
         iqrZGa3maYl24RE8pXsajn775kS7ZQ6c8KPhouc3dnm3MCZYrDg/zRqUf/iKTHhIYswy
         E13CVVbNl6UThI7nBN3bJvYKIHOg3twg3duY63qs0TXNWAt8copnL7Mqhwzkkflp470R
         UtK8DJ1douyTUYeWKWk2UZHshQrYzypdHwC1ZdN+shWsg4JGnkjHiSmO9zqRfJVwUKQ3
         viYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVYCZpFiyxRDuZNlJrRonpcfkypuuVRvXw7d4BTF7NuNTeJ33OI
	nxTej/qrmhRvwpleQZqbmo0NSjsJvckPE5aFO28ukHUIE2wOQhjfAKuKwx9O3irWEqVxRaKWlLf
	HeRFUEgLMwACzojQgQnihN7t9cC/alqqf85HtbpZIzVg5TqfKziZisjSy6AJl1J2pGw==
X-Received: by 2002:a63:ed10:: with SMTP id d16mr9096921pgi.75.1556037801491;
        Tue, 23 Apr 2019 09:43:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBC2Jccuihk/sDE+I91m++CRBDrHxVo5xRZWMKLRN8zSX33IoLC9pcAMwBMFgH66YOGixK
X-Received: by 2002:a63:ed10:: with SMTP id d16mr9096874pgi.75.1556037800788;
        Tue, 23 Apr 2019 09:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037800; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7Kv+XMg083Pwg/u0IkI+WTP52uZtg2Mx29D4T7U7D79sW/VlGkH5VmU+aiZhKr3nh
         5BebyNpw3hG3X2QREMpfIK2w1Kg5/vcKInr6Phrixf3UnpAVVlihj+kKpLcI2tljNEVr
         QTLhwvll2SOUE8B+xOUXbDDDn+VboXspCFp+QHO8X5srP48BzGJHl5iL5sBaVQb5KUYN
         iclB48Y9d8xGmBNkYuIfEP2VGWouUD0PNg9ZFemBUFzvF7gPaQSu3VrWg9L7rJ8Wqz+e
         vf/wwc131l8H2zgyW1strWCe0EvVq1qkfBMJBlCLnMwgaI9W23YuJyDbtJWdJ6VBA9Uc
         0RUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=st9ctL0bwQXPnG+ZDcH92e0dsG3UcS5ETD78Lf3mweQ=;
        b=vaBazzCJorp7zHeSS/NS41TtSbzSxAKmez9DN+TG03S0OrJw8nY40IvsyR8tsov65b
         wTbQB9fldHiPHcTZy2LZDrP87fScXpurMgQ3KicrGwium+KwSvYLgTD+qTmtVzQUCHeD
         IjZR00N3fY2lkysam1IGhTCUnMOc++NT/A70doEW9DqzdbHmqSMjsgAoLoX0gj6lneH5
         /HxvRUpoqq4y0S2xHEQBwEgFalsP2WswZgufF+v1bCppLhmIAxeB6Lpxvs7mASvOrq7N
         jbeLRL4QZPrdHfivArSXJhCL9cyX22hSSfvIidhA6QVNdNGBjIgM6N3cuzoPUKhK7aoL
         UZdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id x30si15905186pgl.477.2019.04.23.09.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TQ4.3kP_1556037781;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ4.3kP_1556037781)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 24 Apr 2019 00:43:15 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	kirill@shutemov.name,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP eligibility
Date: Wed, 24 Apr 2019 00:43:01 +0800
Message-Id: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
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

This doesn't make too much sense.  The anonymous THP flag should not
intervene shmem THP.  Calling shmem_huge_enabled() with checking
MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
dax vma check since we already checked if the vma is shmem already.

Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v2: Check VM_NOHUGEPAGE per Michal Hocko

 mm/huge_memory.c | 4 ++--
 mm/shmem.c       | 3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 165ea46..5881e82 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
 	if (vma_is_anonymous(vma))
 		return __transparent_hugepage_enabled(vma);
-	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
-		return __transparent_hugepage_enabled(vma);
+	if (vma_is_shmem(vma))
+		return shmem_huge_enabled(vma);
 
 	return false;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 2275a0f..6f09a31 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3873,6 +3873,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
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

