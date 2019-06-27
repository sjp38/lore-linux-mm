Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1549EC48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 17:12:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF5F5205F4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 17:12:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF5F5205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C4136B0003; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4742E8E0003; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38A2F8E0002; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02B726B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so1783573plk.23
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:12:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=j+sZ0GThXRrDqlRClxNnNtuaC0HEgHvl2cLujJxfPMI=;
        b=YnYRE0mJyOMPe7s+vrsNsvQmvX21XlA97TB049qmp+hHFEXwl99UV8bp9MPEx+yLLI
         pFIoBjDC7BIasAuKrllI1NjddEBu6KC7r6aEP8iPogDicBFeQW1AH4J0WgWdsLxEexIe
         xxZ5QX0Z6lMV4lcDn9dtiGVQwCRsdJH1PymeO1s8X64gi7IynFZ825p1vBQiRLckJEAm
         WPSm/7VcH/5MmzvJa2pw7ldHLPHtnjffNStSjNZacJHX40v/j4UyqTQlRJtFcc0Es0PR
         f1cpmQm/5luZy8Z+cty8vUu+bHK9RMmsW6/W4KFD4pUJCriTjHNXrtvuYT7Nvzf2wWkT
         087Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXb/XRW+mz/agNAShPymOv5ZSf2a260fHuyT3B5qVZ5i7J1KoHL
	5jbo8UBlKudjHT85dFPfbVyeXF+11t14CqBqVf2ruGWywJ49h6vh8jVvxBRpq2WbIz/mIjJXhNb
	fCZLlHVA7B9VIvLCnr1taTXCqLEWED4Erc4E1kpxmll60imz2C8n5Q0dqTRBmZaGQiA==
X-Received: by 2002:a17:90a:342c:: with SMTP id o41mr7313663pjb.1.1561655535538;
        Thu, 27 Jun 2019 10:12:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVHGOlN/9d/nXFNJPwPW1Dnp9oi9VvEAIo6jAeOJcXWYutlYvN2rAFm447HcDaH/Jzj2Tz
X-Received: by 2002:a17:90a:342c:: with SMTP id o41mr7313594pjb.1.1561655534771;
        Thu, 27 Jun 2019 10:12:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561655534; cv=none;
        d=google.com; s=arc-20160816;
        b=JtBSAhs3V9pciFHyC98aDIfnXmYWiSZ9c58bPfHN+Xr2in30p5YuB+SY7LJwx8bGVV
         QZEe1ioQ5jV5hPms8jFSDCuFo9vXSHxVdQla5bUV8zJLRh0Hp9lG/fKpVYpbtH0cImaj
         5tqFJgG/+uI7DO9aPCwYexmC/lkNzr5Jl7L7kWfBAMZPe988SfPAlOkuk2BmMASm159u
         73+If4CH6MgpjIbgmt2lmm7M30DM4F79Bmpeyr7Dhm4t1F2Ve/dQUFImkEoqlmWToYJK
         NQ4zdvHIp5EkshEd8lIIjPYysjjgpTtQndrUiqwwtaub3GnLUg+XnXFZpXVdtBhaffcr
         RDaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=j+sZ0GThXRrDqlRClxNnNtuaC0HEgHvl2cLujJxfPMI=;
        b=Mtnax20PO9mEySeg0S11l4EsHSpJ3myZpYBnmPJwwAnvbIFc7MaraAUf/BU8CE1Py0
         pfMJf1S7kIYLhy2G9F8JfNn2rmHFqkhUY0Ky+A84wTpCT5cNfJyjxMvdP7vk0t14KEry
         owtqvphlqmCtRC2rsZkRGoLhrFcKSAEJnc3KE9qO8PEze5FbUG75E+fANNGJNeo4ng7q
         Rl2QFDrlNB4uvGAC6tBylSbUXWeJJ8heDGjboTPLDQbCKbAY2Bf6OaHLs8UyXRfhi2J8
         4SXZyieaJwo093qj0MROMNOcGAEOLQr9wXezgpZu0Yv5OGc8gmVRX5109iJWPAei2gqU
         5e5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id g8si2498009pgs.461.2019.06.27.10.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 10:12:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TVMmS7H_1561655524;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVMmS7H_1561655524)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 28 Jun 2019 01:12:12 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: rientjes@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/2 -mm] mm: account lazy free pages into available memory
Date: Fri, 28 Jun 2019 01:12:04 +0800
Message-Id: <1561655524-89276-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
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
index cab50e8..58ceca5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5005,6 +5005,7 @@ long si_mem_available(void)
 	unsigned long wmark_low = 0;
 	unsigned long pages[NR_LRU_LISTS];
 	unsigned long reclaimable;
+	unsigned long lazyfree;
 	struct zone *zone;
 	int lru;
 
@@ -5038,6 +5039,10 @@ long si_mem_available(void)
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

