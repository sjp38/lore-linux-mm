Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60D50C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 213AE204FD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:35:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 213AE204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8E966B0273; Tue,  7 May 2019 17:35:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3F7D6B0274; Tue,  7 May 2019 17:35:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 906C16B0275; Tue,  7 May 2019 17:35:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1DA6B0273
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:35:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c12so11102908pfb.2
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:35:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=led0DBv6u7UXI25sAuz4CP9LBCMQYh8UhwHyrJqvOkg=;
        b=SLtzvH822kusXgme7ut9ifnl/EcT0WS3fV+qC54BxJOSlxdeqPXgiZDhxG28wBO7K4
         BsdNgsaWsvldnBR24Q0d9ShNMoUEL+DS3O/25o9zsBzLxI9bn33iWktqByqAJf8HiXjJ
         KXSxqzKZFvOMtdzWzl3OKjYjzaswakdh9JctlErcqUShyf7C3GRC/3tTindr9EANfYOG
         rn5KtfSF5ZW197WNLY9fkWHChkut9vpxRzM4auG7Ld8eTiWbrV452cswChJoZ2F6OqHq
         gBDqC5zUjMZn12cvJJa3/VT6Wq74Xx3ZNPv09r7znz0Up+yF7UieQF4Qj3oFMjsbWZO5
         Q2oA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW5PGXrFWH1tUGKMKFNoIdaurqWoOSNSA5Pn+WdDNnlcXTMRDeO
	WjOiQ/WJ3r2wGEmPKDIVYIYAE4P7tSg+xEwyTe5TLZhDrDVmUcvFJXWbCkLJ2cBjJ0WBz7GRT82
	OqL6vJjgs/dk4ICB+3AYlGL5cvXoNgczSnPvFKInoxtJu1HNhJ+RN/XfaBGmgr+KiiA==
X-Received: by 2002:a17:902:7c8f:: with SMTP id y15mr24204447pll.339.1557264912931;
        Tue, 07 May 2019 14:35:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO3eusWU/aMRvySifWGvY0MxML/wQn35/5S4DFx7+M+lfwATdt0918n4wTgGtZPMNi4PYZ
X-Received: by 2002:a17:902:7c8f:: with SMTP id y15mr24204344pll.339.1557264911761;
        Tue, 07 May 2019 14:35:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557264911; cv=none;
        d=google.com; s=arc-20160816;
        b=w1BJ7W1AdRmVjpQlbeh7Ui6V7Jip7T8IvrxwtRYerXMvllAx/TIbiYbDsFf09f4H/Q
         7pBLW7/1XwZ0nR000g7qwlx1re+shRUihrZpg42O+AAi566aRihsM5J+xGFcHizbFQz3
         QIB4v3M6+6g7cEJdq5q4mJkEw03/7R9SRI4a5V5CDg//AZ6ZGfu1qba/ceigA7qngq32
         Zjfw3Mze+A1tqOQ3ntgytJ5HpBSAK1KHqC028kPuNRwCQQfjWdMaFBdpOjjejd26kuGr
         smK4fU3Y6TDszBDn4ZiKAndkeHUtH3P32M+Ox26BCllLI/mufgSbGtS9Loq0VFGrdRx1
         ekhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=led0DBv6u7UXI25sAuz4CP9LBCMQYh8UhwHyrJqvOkg=;
        b=ycDBGOLe2t2td7P7eF12ObZnwz838B+sMvtonf/rQJ1AFUIpj52lC5+OaXeB2qF7Nm
         5BMT+IQSb2rlurZbe8IuLRwsIyCLEw5ne8XlOmzWRVqNmAAXUtw+hzAOlMi3Et/y90rO
         iuXZkbagUs15ZHiD4H6mvcDQK/6zR81YPzoZmaYBPUSRHtK9ACUaRFWf+00WSUDoOtFE
         ueZEKn9+S+rCZge5XDkBcWUFOfAVyy7tkjpPKFvEVFmwzf2nlCATtCx/R5bGFomjZUZi
         y2mMca9lPDsTEUmLilLOFFJbAAmRR2wUEKzAqonJYTX1MaM8mKJee5fefpU+/I8qbyuG
         8HoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id j11si19139991pfa.162.2019.05.07.14.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 14:35:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TR8MvA1_1557264889;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR8MvA1_1557264889)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 08 May 2019 05:34:56 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: jstancek@redhat.com,
	will.deacon@arm.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force flush
Date: Wed,  8 May 2019 05:34:49 +0800
Message-Id: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A few new fields were added to mmu_gather to make TLB flush smarter for
huge page by telling what level of page table is changed.

__tlb_reset_range() is used to reset all these page table state to
unchanged, which is called by TLB flush for parallel mapping changes for
the same range under non-exclusive lock (i.e. read mmap_sem).  Before
commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
munmap"), MADV_DONTNEED is the only one who may do page zapping in
parallel and it doesn't remove page tables.  But, the forementioned commit
may do munmap() under read mmap_sem and free page tables.  This causes a
bug [1] reported by Jan Stancek since __tlb_reset_range() may pass the
wrong page table state to architecture specific TLB flush operations.

So, removing __tlb_reset_range() sounds sane.  This may cause more TLB
flush for MADV_DONTNEED, but it should be not called very often, hence
the impact should be negligible.

The original proposed fix came from Jan Stancek who mainly debugged this
issue, I just wrapped up everything together.

[1] https://lore.kernel.org/linux-mm/342bf1fd-f1bf-ed62-1127-e911b5032274@linux.alibaba.com/T/#m7a2ab6c878d5a256560650e56189cfae4e73217f

Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: stable@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/mmu_gather.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 99740e1..9fd5272 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -249,11 +249,12 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
 	 * flush by batching, a thread has stable TLB entry can fail to flush
 	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
 	 * forcefully if we detect parallel PTE batching threads.
+	 *
+	 * munmap() may change mapping under non-excluse lock and also free
+	 * page tables.  Do not call __tlb_reset_range() for it.
 	 */
-	if (mm_tlb_flush_nested(tlb->mm)) {
-		__tlb_reset_range(tlb);
+	if (mm_tlb_flush_nested(tlb->mm))
 		__tlb_adjust_range(tlb, start, end - start);
-	}
 
 	tlb_flush_mmu(tlb);
 
-- 
1.8.3.1

