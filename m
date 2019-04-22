Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8621C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 22:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E03720685
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 22:25:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E03720685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86FD6B0006; Mon, 22 Apr 2019 18:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0D1D6B0007; Mon, 22 Apr 2019 18:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAEB86B0008; Mon, 22 Apr 2019 18:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1C06B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 18:25:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d1so8726328pgk.21
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:25:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=/GDXjKfCx6a4prpl6Gn8uwZghIRYT2FOxNBmRGsf6dQ=;
        b=CyDQ57lf23ozDtgx+sO1DOX2exkQj/YZuNKabBkzWZGT7JaFMoqUnXZ/4sDn7Tu25b
         zcU1BaYYrzOwl6G6xVqWlAJTg7aQckbggVl8Nsj9snGMEuGYHuWLXGRwMfHR1mtUyss6
         CyC9ZuJzCUxA6ZAoE8m+XZbZzue6b6tVps+d32kBhuBEkyoXnLseGbln/degfaUJKisB
         T/B4Br8vUNuX8rZemGgbGYp30APx6YPB/y8NBiDCTwEYPeVU/3DdtLqg1Vw1sRdY5FkE
         2J6CTPa3K8gQWUN5rNuB3gmNTIXkBOkn1buqDQev9XbcGHWDS+ZAzojIcVlTg8ojlzLC
         TPUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV4wFSb59jRV0DnttAqi8Sv+TCCO5oUlKAHteAaLJJwzof/ZYXq
	slmJ7B8MxjtdPz5Qi7ETP6L5mw3Oizvw+qH0+rkE6hLG6Bzvw2w7AVqSTw7A1AxNh+uW+OmxSZx
	hEVrTsc0j6qAc7BS9GJRsBdI0txdUeTCMfAe36nvqqW8icbBvOrI6VnBWHNXf9MCbwQ==
X-Received: by 2002:a17:902:9006:: with SMTP id a6mr16060921plp.259.1555971904054;
        Mon, 22 Apr 2019 15:25:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztf/a8lhJav9lnYyPEOjhWpcAdZlV1uR/cciaGoQ+v/mE4xgDAwH8Yh6D0JvoG3fcTCQTL
X-Received: by 2002:a17:902:9006:: with SMTP id a6mr16060856plp.259.1555971902857;
        Mon, 22 Apr 2019 15:25:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555971902; cv=none;
        d=google.com; s=arc-20160816;
        b=NqsctYo3ScnVV1uc7NnIrKJdmsmzTjXgGJx52qP1ThKEjT39EFZ3QtjMenveK8Awan
         TwjXmk70Krkw9aUZmo/anj2M9yxao1UZK/2dEnAbC+la8AA1SKYdJCg2b0UHDec032US
         Wzb9YtJ1MghvneSokLu40ZTkKFr0ZQXs+MtJ/yYts+EzXhDhr+jXCpSnd0LElEvK1e1H
         +H65+85Vw6fUdczmd7njTcHLQLKvuLggF1f+2q/1k8Ii23mtR4QLbWIpd7BlKWGBL1fW
         tg7SVR6HMZwDd50VDSUFqFRRwvDVCD4ZblGs7CebXuUWdXDId5wn7Ft6Ch8kUQ7Ux6Wt
         1oUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=/GDXjKfCx6a4prpl6Gn8uwZghIRYT2FOxNBmRGsf6dQ=;
        b=K3Om5m4UCfGQlT8U7k8W1qDFYnh4AnzgZcsacdQaxalVPgt7SEJQRxc4PXZE9JB+hO
         HJpb6BY3yR7HLwjZz/qZIQ085OGA2orqYyRfTOqoq/3BfAhZ99c4/yy+0atY1OuzuzK3
         aWCRmUW9adgMP0svJZlUk60vutmZJm+B8ZJoaeegeXzmoydLds5hmW2tWfCdFU4NAgcc
         8i6OQkAURdVkhq7vTF2BRPOvepNoiq90B4Uk8ghbEFNf9Lvd072apWOGE/8/jKHvDlq6
         MOznL9lQeIfZLdnDtFcfgi3osS7ruxrN53mg1YqR20qiLDfDrL1xkMZVmErK0js3MOit
         ydoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id p85si14630314pfi.27.2019.04.22.15.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 15:25:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R391e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TQ.RLKx_1555971893;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ.RLKx_1555971893)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 06:25:00 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	kirill@shutemov.name,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: thp: fix false negative of shmem vma's THP eligibility
Date: Tue, 23 Apr 2019 06:24:53 +0800
Message-Id: <1555971893-52276-1-git-send-email-yang.shi@linux.alibaba.com>
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
 mm/huge_memory.c | 4 ++--
 mm/shmem.c       | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

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
index 2275a0f..be15e9b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3873,6 +3873,8 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 	loff_t i_size;
 	pgoff_t off;
 
+	if (test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
+		return false;
 	if (shmem_huge == SHMEM_HUGE_FORCE)
 		return true;
 	if (shmem_huge == SHMEM_HUGE_DENY)
-- 
1.8.3.1

