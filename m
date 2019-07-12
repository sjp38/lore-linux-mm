Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B99E4C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 20:49:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 638F2208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 20:49:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 638F2208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0778E0168; Fri, 12 Jul 2019 16:49:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C900E8E0003; Fri, 12 Jul 2019 16:49:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7F1B8E0168; Fri, 12 Jul 2019 16:49:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 819088E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:49:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so6206585pfb.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:49:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=bsyDGh1sK3BtUgF1tNlRvNgNYEX4bOGkV/ZkcG2sNak=;
        b=RTUTiAdS64cFgWNIlDZTcMqzvBhCAr8ROUwWdMBOLgqm1zqFdm5cDsxdzUO5semxGI
         hpXpSUR5GxrMTl6QgkF6+aMTLQ+5rM9DZjQQlO9X4zZmSI7QVgzJC3xT3TTD2q/bG5bF
         46KiZeS3NOn6xxKdx5o8XogmGc8oKVjGWiwA1t7j8TL6lYHB79M2bt6sWixaEyh1x6sS
         xVwric7I5/UMsmSlrI1uW/UoYC95t1dlOVycOdvl6H0QVa52WYWOcquvSERO+Qxthn7b
         Oaz+Nl90iA0Xkd2MJGl99mlgd5Nv6Fczur8dxOrOPYrn74uY72UkTqvWjJu1Nu0NeTc3
         lwww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWT/bIrlsgnEqIxPO9LdNiTAz6VbWjFYrW9mYiarpmvQhaZ14d2
	OMF9clZR0EWF5BSSLl3mw/yIBzmkJyitd8Tf0IxnnORZef/BqjtMp3mKPqC18uz0PGKRH8eebxL
	Kylm8A3ts/WWjBUkFhQrr1B94V7xQNcgX7aiPNtLh2Rr6nIZr0ApVXl9NQ4fFgYpLpg==
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr14538785pjq.114.1562964555123;
        Fri, 12 Jul 2019 13:49:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWehRYBrhfaRsm8x8I9hpTJHO6fJ5aIj9eXVNORf53elHODy4wLz6mH/mLqCZMk6MkUWNj
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr14538723pjq.114.1562964554110;
        Fri, 12 Jul 2019 13:49:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562964554; cv=none;
        d=google.com; s=arc-20160816;
        b=KFjTloBlT/crDsMyD99vD6VhPqaCmSGibo5EJy2oL4PBUGPxonKP6kVpQnD528FVTn
         i/xP3pTgIIrpIF9zmRYuFnEtMHnxeduJnpAYl8me7QHTH+zT1gqQeAtcgudD4AiYOSOO
         JSDJZIEjjusR+WA69gyn1KxDQ09d969+Y0roSCyyLV0SmTvqme04/MEmYxxlk0PwWkq1
         52xKMCWppzoP70m/SxGkD6pxoQpTBIeiPoobyzrI8qWNJRnbt6x6HIoh13gYXxS0GaSJ
         5C48/1ib4gZL5sFDx5bq9tl9a8JMX1lC8M9uEtmxPnL78Rmfq8DpqdDCGMbL0MP7m1Tr
         b3ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=bsyDGh1sK3BtUgF1tNlRvNgNYEX4bOGkV/ZkcG2sNak=;
        b=K8P4LvBX9X46cgfmH8Tf38nKDGmqwMa2uPMfQpsU6kg5XR4JdiLvj6Jk3zhoLVOlBt
         k3xI2NPXfljX0wC10var953AhP9cHJvmCe4XHpkOankzLnUN+viXi3Wutbjsqm8xUcXF
         bDxQlwZ/DawL4Bo2IcOePi3G/92K4YZ9I0s8qCVeRNtLfdcjGtKnDgpWNkjGXDI0IJkv
         wJj1XIvp85oKnk62N2INaS6L2r/v6TimfsCRpEEyUyMO1MP2pdmCp5IdXhGScPyeikzQ
         fOvklmDAyi3Wk/l5/T55vE+dPWs1Y7pzeLmY5zqaZ9D24p06GajFHTIsh3esWEksRRTq
         gABg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id t20si8902546pjr.107.2019.07.12.13.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 13:49:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TWjde2R_1562964544;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWjde2R_1562964544)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 13 Jul 2019 04:49:11 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	dvyukov@google.com,
	catalin.marinas@arm.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: page_alloc: document kmemleak's non-blockable __GFP_NOFAIL case
Date: Sat, 13 Jul 2019 04:49:04 +0800
Message-Id: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
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
Modules linked in: loop dax_pmem dax_pmem_core
ip_tables x_tables xfs virtio_net net_failover virtio_blk failover
ata_generic virtio_pci virtio_ring virtio libata
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

The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
__GFP_NOFAIL set all the time due to commit
d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
with fault injection").

The fault-injection would not try to fail slab or page allocation if
__GFP_NOFAIL is used and that commit tries to turn off fault injection
for kmemleak allocation.  Although __GFP_NOFAIL doesn't guarantee no
failure for all the cases (i.e. non-blockable allocation may fail), it
still makes sense to the most cases.  Kmemleak is also a debugging tool,
so it sounds not worth changing the behavior.

It also meaks sense to keep the warning, so just document the special
case in the comment.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/page_alloc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8a..cac6efb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4531,8 +4531,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	 */
 	if (gfp_mask & __GFP_NOFAIL) {
 		/*
-		 * All existing users of the __GFP_NOFAIL are blockable, so warn
-		 * of any new users that actually require GFP_NOWAIT
+		 * The users of the __GFP_NOFAIL are expected be blockable,
+		 * and this is true for the most cases except for kmemleak.
+		 * The kmemleak pass in __GFP_NOFAIL to skip fault injection,
+		 * however kmemleak may allocate object at some non-blockable
+		 * context to trigger this warning.
+		 *
+		 * Keep this warning since it is still useful for the most
+		 * normal cases.
 		 */
 		if (WARN_ON_ONCE(!can_direct_reclaim))
 			goto fail;
-- 
1.8.3.1

