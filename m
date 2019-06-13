Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0574C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:45:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5FFC20896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:45:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5FFC20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 521AE6B000A; Thu, 13 Jun 2019 00:45:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1E56B000C; Thu, 13 Jun 2019 00:45:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EB106B000D; Thu, 13 Jun 2019 00:45:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06C316B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:45:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y187so12974482pgd.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:45:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=b++5wQT5X+2HL7ydJLKxd3UTgelDknQq5vbNdqzzGcE=;
        b=d2biULrmfohkN7cT3X0s52n4TwPMAtaXXHQdZpQgkdJWcgOuvQsyLsEXiDX5t6awd4
         W9NwVTH4knSfnB8hk1qIHFIXmh9JKcAS2aUU7tNzZoXue9iMo/kOC0fgoTCGb8yh4jMg
         XaMRlTYhwEk32PzpD95DPi+ZVOcHac8b8Oe52LzkhEhUr+wAuQ8kiKOho9Uih6Ras6KP
         oC1iTgd7Jaa9WdlqJoiJwN5X4KmKbmpDgCzdq46eTeDmihje3EnPWtRsnT6pVjfr9/Kg
         w0eN8mhSiJi+itmcSPs0O67v6HfnMJQQRv5RZZDPhux1jUX9HEnDKqMueb6O7WYLiMOB
         68xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX4lKDLNETpVA7cTk+KiE9B5zxA+eHbcpvIyFOZnyx0voLjLTk2
	lPSImr2d9IjhGYJM7agDC2kHJuCCnx6Mb6ZbTPX99DuFh0HyyZAphcrUxbv2yCU1l8PXfGh4YYv
	E3XoOTKKmjF8snHWeiXlel6XwGqlYXjAVGyqy4X5CFPPt+fgH349eMQF7Na+Fhi+HuA==
X-Received: by 2002:a17:90a:9f93:: with SMTP id o19mr3043927pjp.70.1560401130638;
        Wed, 12 Jun 2019 21:45:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLiZC12tCx1Nl2q0GuV+EwKltobTAE3x7NTqBMlxZxfDy4RVULfbgG9Nb3oNLh8uGYUino
X-Received: by 2002:a17:90a:9f93:: with SMTP id o19mr3043821pjp.70.1560401129310;
        Wed, 12 Jun 2019 21:45:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560401129; cv=none;
        d=google.com; s=arc-20160816;
        b=GtK2AHdTW0GGPT7rW+DiZSS2dv20KKG54BGNDmROf/OPc6zhXZL3Dje/zBk2E6cqU3
         II42bS7T3iqVnYc+tmEgcUrWBnusp7A4juy1VMdI/1YjW+biIjrdl4Cv9jIOMDNwhXBg
         8uUEB/+13fwzfzwk5EB8FcvQfV7PEsxSshBVqjl/aNCywVCJTNvu4FD3oaGYXUDLW6Ip
         TcmoPQk8Qr4w3pd1UePVVdJz9IWa+sSwc7coA8JrarI9zLIn6pj1SuVjNrbT1xpl6fuL
         G5ShJceiOChADDfrwX6/llEviJ1QxYM4o2F3oqUUIq2FdYdAV/Tbcg4nhPqeyo+bMgIJ
         peyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=b++5wQT5X+2HL7ydJLKxd3UTgelDknQq5vbNdqzzGcE=;
        b=cYp1TkKZoRp3XmSwPMvU76G6r/rFFabumTZUTWW64PwxTn+tO1aOp2EZQfBxNduJxF
         qwjGZEFL4z6c7sKYzRaomfXDKSbBJfcOfULjh8qgRTcVxPB3/95lnDKaT68FTtKFIrrY
         lD08vRQiXjjsmxG7fi49OdD4CuEEVHipYS4pUMdbUS7gqUHbJicF/3OhJ+GiJ+ATY/ji
         FF+9qInZFFndisq6oQmQ60wVOwNo1IPRSHqhb78/l+y3LDbCxp7WVrEgaaLInJAhMVpP
         S151mLzPl9erg3mEGWVqtynq1ncH7CA4k1ikmA2NyAZucKvV4XMjInuBO4kM8eEpklfj
         TpEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id m143si1926289pfd.224.2019.06.12.21.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 21:45:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TU25N7U_1560401051;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU25N7U_1560401051)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 12:44:19 +0800
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
Subject: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP eligibility
Date: Thu, 13 Jun 2019 12:44:01 +0800
Message-Id: <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
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
Cc: Hugh Dickins <hughd@google.com>
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
index 66cad5c..b0ded06 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -477,8 +477,8 @@ replaced by copy-on-write) part of the underlying shmem object out on swap.
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
index 01d4eb0..6a13882 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -796,7 +796,8 @@ static int show_smap(struct seq_file *m, void *v)
 
 	__show_smap(m, &mss);
 
-	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
+	seq_printf(m, "THPeligible:		%d\n",
+		   transparent_hugepage_enabled(vma));
 
 	if (arch_pkeys_enabled())
 		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4bc2552..36f0225 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -65,10 +65,15 @@
 
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
index 1bb3b8d..a807712 100644
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

