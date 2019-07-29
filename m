Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01C11C41514
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:10:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B01DA206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:10:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GbpKZO+1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B01DA206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E5938E0005; Mon, 29 Jul 2019 03:10:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 495D58E0002; Mon, 29 Jul 2019 03:10:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AD308E0005; Mon, 29 Jul 2019 03:10:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06EB98E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:10:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 71so32613963pld.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 00:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=MP9bWqLglik/G7ydzgpH6qxtoOPjTnKjIEZbq35U0w8=;
        b=ezBPteRfSVnwUNiEW8vc6xsrLIdYLroPBV1XMBQltuXAAkzmkUw27ogTCrPxgWuuSj
         LCdmcr8dl2ymAt+1cE6NjQcL/lA1vP6LFt5utN12p9sVsstm4/O8kmO0hX6w5Cm4y9PB
         OhEtPC1DGpAe7Of07bLw0EjnrNvxH5RlZFhYQg9b68wsXg/EBszuGONH0puGzikxMdYo
         k9rFOntYrHHfiQYk5FVvbuYN8fRLsJR5OCXTosDFh5H9zp9ls5ubu/LUbgbMrA+KnOm2
         3upp3RGyMDMoCqufzjshP4s3Xj7eaZ1Ygto4hOsDg82m8N3tvEv1TtiniPt3vmQ5oKB6
         8HHg==
X-Gm-Message-State: APjAAAXh4GTl8rP9ZgrkX93RY4uMlAigCGwR1xBRYw0r4xL0wiif5JGw
	ivSi5JkI3QKgyF/3bg0x8/9as4U3RwkScxcxalR36xWMnoAvqjSKYD24FAXfu7Qgils6OgP3Ihm
	MgfEjpKEELnijqIESL/Zoa3gRdNps0L0VU1TR7/+PijVy4BtDV1uxJL71YrYFh78=
X-Received: by 2002:a63:c009:: with SMTP id h9mr75459331pgg.166.1564384246506;
        Mon, 29 Jul 2019 00:10:46 -0700 (PDT)
X-Received: by 2002:a63:c009:: with SMTP id h9mr75459285pgg.166.1564384245745;
        Mon, 29 Jul 2019 00:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564384245; cv=none;
        d=google.com; s=arc-20160816;
        b=L0KZQbnrWRP6oQ8zvHKLofKP5A+oF0eXw7w7uhfQHnK+D61h1A0Ux7Wxt+zHWUAppS
         x7VGa3vC+Kdjmg4ylChW7GQqCqQhRBGU6vonAjdND34r1UAvKzzOLYHx5qYPQLSLfnlJ
         eX+v5p0INUm9EDOa3N4k25tmbkWd7FbrSXnb1kyrkxgIDbHLRIKy/k/XzYbT+p27X1i+
         JMfC7UvDEsUUyM6Ij2DRoRh6KxYt4hTkeDYOmEI0oIvNOgLtSmd3hVdKSlvm58wBKmfz
         KTeVJT9D4AdVPWArqavQ3zk+VkODJoetKTU/9Ta8AqQmh5RPvAEODfq4Vxs1ypktrLTf
         DqxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=MP9bWqLglik/G7ydzgpH6qxtoOPjTnKjIEZbq35U0w8=;
        b=Xsfqo3RdSewSJ3Z8d3lC5bRyzGQ8TB1uN4eOjl02TEhbAee6sDWQGrMmS3Q8s3m6sS
         DMmg1J94IZ68NA4bZwryuTGsPbSUPBf+g7htPlSEpV7K6PFQb7Ama2oM3MTKqNaZgypI
         PmdE3JUgVdokrFahoNeYWxEOYdPB9I0572/SjIkypZxFGx9yF2cLhldDhnZVVFv76hmq
         quB5brkpqADOvuRWjd9Z2NTPDzmhnZk0JL/SyQu/gG9NOHELRlXgKdD3vMqbYb37s3uh
         GmjNyc9+oe5c34cffdfr1kOIB66n3xtW4AA+CHUvwbvRlgojp7IMEAU9sO31F1HByLQi
         ZQEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GbpKZO+1;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor33927445pgs.55.2019.07.29.00.10.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 00:10:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GbpKZO+1;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=MP9bWqLglik/G7ydzgpH6qxtoOPjTnKjIEZbq35U0w8=;
        b=GbpKZO+1qWJF5PiJfpJI+X1d49LQDhRSEjabzM4QoQoxyPC/ykpjviHT067xaP4ur9
         Q8obYhARMbKPZN2+MUi7KS43dNzPuKR0TZprepoLgqL8dD+kKWF7yA9cJNsgLDuWAebQ
         0gfhz135PdhcmBO/tQ+4kqQB0rCDV9+w4pqCBPOlGYoT71nY1o7yaEyjkMRD7hBR1P5C
         yhPQ3G7yavjMpqxRD9NSxGBh3X0PbYCwpznGkB3NPHVGfrc0PBFT5fj7o+pFYkL6z117
         bVr0nUhG4ri8CNjgE/N7liJe66keFa5uc+KTxXZUTrXVXIUPyjeXYn3corPlUzoq8C+Z
         tqKg==
X-Google-Smtp-Source: APXvYqxnzOd4PuafCgb1AfLhTACUQYfJQLs65HMwphdh3OAlLdZAE/tGNxyoyJ+8bK3MjIY85KClhg==
X-Received: by 2002:a63:2784:: with SMTP id n126mr99458545pgn.92.1564384245259;
        Mon, 29 Jul 2019 00:10:45 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id i124sm111028139pfe.61.2019.07.29.00.10.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 00:10:44 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Minchan Kim <minchan@kernel.org>,
	Miguel de Dios <migueldedios@google.com>,
	Wei Wang <wvw@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: release the spinlock on zap_pte_range
Date: Mon, 29 Jul 2019 16:10:37 +0900
Message-Id: <20190729071037.241581-1-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In our testing(carmera recording), Miguel and Wei found unmap_page_range
takes above 6ms with preemption disabled easily. When I see that, the
reason is it holds page table spinlock during entire 512 page operation
in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
run in the time because it could make frame drop or glitch audio problem.

This patch adds preemption point like coyp_pte_range.

Reported-by: Miguel de Dios <migueldedios@google.com>
Reported-by: Wei Wang <wvw@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 2e796372927fd..bc3e0c5e4f89b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1007,6 +1007,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
+	int progress = 0;
 	int force_flush = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
@@ -1022,7 +1023,16 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
 	do {
-		pte_t ptent = *pte;
+		pte_t ptent;
+
+		if (progress >= 32) {
+			progress = 0;
+			if (need_resched())
+				break;
+		}
+		progress += 8;
+
+		ptent = *pte;
 		if (pte_none(ptent))
 			continue;
 
@@ -1123,8 +1133,11 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu(tlb);
-		if (addr != end)
-			goto again;
+	}
+
+	if (addr != end) {
+		progress = 0;
+		goto again;
 	}
 
 	return addr;
-- 
2.22.0.709.g102302147b-goog

