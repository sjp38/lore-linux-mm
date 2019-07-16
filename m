Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D8FBC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:50:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7EEC2184B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:50:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7EEC2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A6E08E0003; Tue, 16 Jul 2019 13:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757B66B0008; Tue, 16 Jul 2019 13:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6215F8E0003; Tue, 16 Jul 2019 13:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5296B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:50:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so10574095pld.1
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ket4pPekZnLVvlGWf8C2PNVEPfv0rH3OAeqED0KZYpg=;
        b=M4waEaZJwfYyKoDfKlnaxrAw8nrQOplHslZFaggJmjDnr/HeREAeWSvX/HNqrNMR2a
         +MLqG9dCjM+oDAG5wU+SwFnCQ3KeiKCNSKZNwID5GRW+eBXpoqV9hGURZ6amsBaQCC5j
         LPA2M2d9Dj4pocfDZ20Wj8zGhmFLDObwvXSMb34vk85YVRavwsa3hLBvfrSpr2CC4jPU
         KchMIZ962cD2Y6Kgy65vERgtbbI8wJYRHhw/HZXVeZbyTXPhVPWSYq9LODu5s/yCrvhH
         fnZLUjdFC9S80/lf0khivQ4vjyDE8GHUMclbqmeaev5MAfKrhXIK0CT95BYRsnIRsU17
         wZoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVNpvyHx4MHg4VUxGqdx8bdEqKXZKPManPd3jFfQKhfbRkHlPhu
	fhHKl2oN2G7IjBPSm8xzFI3S9XjL72g7ozI9d/ZCyn5MthD7VZmyrllLYkOPjWg9RcXus8ylQxD
	LvTwYIDOILMTJ174j0RS69UuQkigL35IA3waJxG1xoFpQtqRHTj+w9Wn/HKIOtW/ruQ==
X-Received: by 2002:a63:494d:: with SMTP id y13mr36236735pgk.109.1563299442704;
        Tue, 16 Jul 2019 10:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy5vCVW+zgiqCCSXaQ+4azxRb3lqgQnSG4ZBhTZdjdoj79WkamuT3dpsBW+eKUlFr5d99+
X-Received: by 2002:a63:494d:: with SMTP id y13mr36236643pgk.109.1563299441534;
        Tue, 16 Jul 2019 10:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563299441; cv=none;
        d=google.com; s=arc-20160816;
        b=nScWOIzo02KSzFfUVWXjeT+dg/DaLezXeWlPkw76awQA9XGlVYVOPVtLRvj3RRZBBn
         iGQGptXB5kR8OHPc6Br0GuIJ1XKhpaPkV7BjX6g6jkSeo8qymyOzhE2OiObHbegYBXPO
         EPBN1L56Fo/kuuzJ4P9QvAxxdPRB3PXajOaLytQPZK1AjM17A4fc1CCogXWl6i7zdUaN
         tic7vAmR7r+zqdRhEupk3GczsYOp2elveNCclKj053dRqHJTThV23idqRQVZFFdKG4jf
         PKDDaYN4c827ao0SeirsXv4WqKCsfvsglyWPqgkP3smjFk07sdh6ttx2JBVmfm7FqW6k
         rYvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ket4pPekZnLVvlGWf8C2PNVEPfv0rH3OAeqED0KZYpg=;
        b=DjA3wvsSdnTuLDGwq5+svAc6maIPWeWCCUXPll4cWDK8aY85RBXFoVMwI795lNJzHE
         To0HlfoGDcC6TRNVGH6D6JLZdtnBOrrp9MWqI4nPcTn7TrQv4/3lcjlKH22ZYTtguw72
         Fpvi8K0ejAR7rNNlFYOxPyHG0H3x8gbKlfEXJKJrZsHYEJLX7CVp9cSCTwNShHpVOK4P
         1t3JMLZq4fz7klw7RQr6quY6jbEPvl3BHaBGB2/94gHBpbhFW/F2y9k4mEp5v3YPYS3w
         PfYZed6RYHUN95LBMKSrRzbsoCEu5l3+/HiTYI3SjbQLHSgYEyQUGrjHDLw43jrW3yDj
         Y9nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id s101si19549461pjc.5.2019.07.16.10.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 10:50:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TX46pWJ_1563299431;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX46pWJ_1563299431)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 01:50:39 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: catalin.marinas@arm.com,
	mhocko@suse.com,
	dvyukov@google.com,
	rientjes@google.com,
	willy@infradead.org,
	cai@lca.pw,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Date: Wed, 17 Jul 2019 01:50:31 +0800
Message-Id: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When running ltp's oom test with kmemleak enabled, the below warning was
triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
passed in:

WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring virtio libata
CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
...
 kmemleak_alloc+0x4e/0xb0
 kmem_cache_alloc+0x2a7/0x3e0
 ? __kmalloc+0x1d6/0x470
 ? ___might_sleep+0x9c/0x170
 ? mempool_alloc+0x2b0/0x2b0
 mempool_alloc_slab+0x2d/0x40
 mempool_alloc+0x118/0x2b0
 ? __kasan_check_read+0x11/0x20
 ? mempool_resize+0x390/0x390
 ? lock_downgrade+0x3c0/0x3c0
 bio_alloc_bioset+0x19d/0x350
 ? __swap_duplicate+0x161/0x240
 ? bvec_alloc+0x1b0/0x1b0
 ? do_raw_spin_unlock+0xa8/0x140
 ? _raw_spin_unlock+0x27/0x40
 get_swap_bio+0x80/0x230
 ? __x64_sys_madvise+0x50/0x50
 ? end_swap_bio_read+0x310/0x310
 ? __kasan_check_read+0x11/0x20
 ? check_chain_key+0x24e/0x300
 ? bdev_write_page+0x55/0x130
 __swap_writepage+0x5ff/0xb20

The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak has
__GFP_NOFAIL set all the time due to commit
d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
with fault injection").  But, it doesn't make any sense to have
__GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same time.

According to the discussion on the mailing list, the commit should be
reverted for short term solution.  Catalin Marinas would follow up with a better
solution for longer term.

The failure rate of kmemleak metadata allocation may increase in some
circumstances, but this should be expected side effect.

Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9dd581d..884a5e3 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -114,7 +114,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN | __GFP_NOFAIL)
+				 __GFP_NOWARN)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
-- 
1.8.3.1

