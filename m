Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0859AC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6AF7206C3
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:58:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6AF7206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622C06B0006; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584816B0007; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44C736B0008; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07AD06B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so60182581pfb.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=fLtBJR+XUvKo515sWP4TXVz33Wk85BA8Gby7n7ElHSw=;
        b=p1Ncy7g/pHbFBcnVR2/BN4JjQ2jyuHDTZ2d8+ILcWWDA20r8uH2F5gzU2IBTeUEI2j
         bJGHdUVHhjJAJWnPsvho4RZH2TbRmTxUYLPbtUeFaUNCb6uqabkP/+pl2VrzzrC0St8w
         o4yoji6yKyd4POF9boldKkN+izIbAh8szxJnRaII2K2jslS/K7navsZEMfLu256IOzBQ
         9VusAmqdcFF1LCX0esMtbahL9wHJNRDcXHEVf9nLEML5oErLlrkM4uaYUGzoGVe9/r7s
         pV488UqcKxcVCHZ8+3BhIqtaRB8/3suH95PwZXdfIqTQps/2ayvgc4qS2DKlvx4iaBsO
         836g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWI4i2Dzh23A+j/j6Ce+L7JVPyWF15gROJphfeF4o0zGb3EfmRn
	3NVH8HqCNowFDjf/O3yq/qXx5IkTj6/p5KGV/uVD4iIObrhY7X1FkivxR3UGIv2co5Mm7lkkz/S
	oeWru1djpJaYZRrlC+UqkdI89o+O0G8k1McjZeMo/vVjZ8CdAIC31/knYAsqelr7ifQ==
X-Received: by 2002:a63:1b66:: with SMTP id b38mr15076273pgm.54.1565308691566;
        Thu, 08 Aug 2019 16:58:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKjgowtk5fnamx25rO2FzoTYtX1N4xL9Umi0XtbWZn0X+JBZja+N2dkz9l4Vjo86xrDoZc
X-Received: by 2002:a63:1b66:: with SMTP id b38mr15076214pgm.54.1565308690370;
        Thu, 08 Aug 2019 16:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565308690; cv=none;
        d=google.com; s=arc-20160816;
        b=aDOQ+FMxeBg/D4Eg/S+daOpAlnJQ3MlMtS5TEgHWg1gAJoYyGBo3bzuvEfBcuHSMtm
         aw0sHab+FuHHBcmilsC+aTMrO27rGMny+CsYRUnGo8YvYgpOmDSfLP2ZaHY20ooNzf8Y
         Z5w6ZlDdf9NcmTa62FSvfL1a5dYi94dGs4nxfD8cCjr4zQKVdDbdAtL9hWp6LrFJ2+nO
         Pj7Wm6QPr7JDdiQtDAS7HQbkiyG40DQL7yIb9pnBus+nGNAN82e4+gI3vBJp/sNOxKZ1
         ukPlUEj3KZ5Gg1+IdGHJyNQpdD1HUnZoGyhIK7LTYAOBaU2twE5c69PXGSlL4rPR/0L4
         7WiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=fLtBJR+XUvKo515sWP4TXVz33Wk85BA8Gby7n7ElHSw=;
        b=VYrWhkBPYhcCJuFRX1Dpy4Y87WyUzwbyjXO9tTqRkDsKAUo2Ur5lZc5zYHFdfikTk1
         JXv/ewsCSR2JGFH0t7ASj/+Nat8BrN5BHGtaaNyvMKDRZR3WvCVRzt7fv2LtP2zjtcgt
         ksvIVdVQlSqbBfvR4Cl0TbLE0Mu/adC4ousjU2OcQdhPJqA4FTTwq3y/3Ii4cjGvxEZx
         6X2eN8ZqWjEYGC1siS50I8EUFMzEirf3ggb8jH7nEUaP8c2MGq+sbpla7IrC+nWujuJB
         76PyY5/+zj77s2JcqormIX1ALeivFCEisLnFKmdjAXaMFFmoEp4QwUfyUqaqu4Q2isRT
         TRpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id v1si3085432pjn.79.2019.08.08.16.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R961e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TYzn9kn_1565308665;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYzn9kn_1565308665)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 09 Aug 2019 07:58:08 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RESEND PATCH 2/2 -mm] mm: account lazy free pages into available memory
Date: Fri,  9 Aug 2019 07:57:45 +0800
Message-Id: <1565308665-24747-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Available memory is one of the most important metrics for memory
pressure.  Currently, lazy free pages are not accounted into available
memory, but they are reclaimable actually, like reclaimable slabs.

Accounting lazy free pages into available memory should reflect the real
memory pressure status, and also would help administrators and/or other
high level scheduling tools make better decision.

The /proc/meminfo would show more available memory with test which
creates ~1GB deferred split THP.

Before:
MemAvailable:   43544272 kB
...
AnonHugePages:     10240 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
LazyFreePages:   1046528 kB

After:
MemAvailable:   44415124 kB
...
AnonHugePages:      6144 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
LazyFreePages:   1046528 kB

MADV_FREE pages are not accounted for NR_LAZYFREE since they have been
put on inactive file LRU and accounted into available memory.
Accounting here would double account them.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f3eba8..d128b4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5074,6 +5074,7 @@ long si_mem_available(void)
 	unsigned long wmark_low = 0;
 	unsigned long pages[NR_LRU_LISTS];
 	unsigned long reclaimable;
+	unsigned long lazyfree;
 	struct zone *zone;
 	int lru;
 
@@ -5107,6 +5108,10 @@ long si_mem_available(void)
 			global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
 	available += reclaimable - min(reclaimable / 2, wmark_low);
 
+	/* Lazyfree pages are reclaimable when memory pressure is hit */
+	lazyfree = global_node_page_state(NR_LAZYFREE);
+	available += lazyfree - min(lazyfree / 2, wmark_low);
+
 	if (available < 0)
 		available = 0;
 	return available;
-- 
1.8.3.1

