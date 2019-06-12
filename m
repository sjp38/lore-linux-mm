Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC41FC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB80820B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB80820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E5E26B000D; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31E826B0266; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197B76B0269; Wed, 12 Jun 2019 17:57:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCF746B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:57:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so10578214plz.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4kJ5Q4DCdZWctI1HwEx678LwDtYH2kVuCUx2wAqJGFE=;
        b=L3CAou3SVWOXgXb0Sz9Sl9Y//bqaft3bSfQeFubcI5Lbx6Rx4h6jrGYAS/ArPQ1JNn
         I7JpNPqNIQyIJOyy1hpP7aBpxruprx7YxWUy4KyqeRIJe20jQVNIiKtK5lsFP7PtFAw2
         YdVPlyMh45q0r1e+WCcYO0vZNHJcdMZJnUJ011hhqTJfgmxXQuBL6Ftizk62eykfmqOe
         8Rtet7p9bSs3FL9Z6LP+INGsHAAfpnx8/tceD299Puw+s/Tn6cRYxmPcAeO22FbnMHRY
         VXN6YhKOakJ10Txul+DZexW9Fd50bUZh6IUZeoYAmOxnBvSQx8KqQJtNYB92zt9B0BY+
         y5Zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWV84FQC0SOX+cL8X5kArrtNJaQXFPW4DwNH0P6ER9mRJ+t7SGs
	Bs/SmT8eAPGeBrsp78QmSUIMyKL+tbIcMLwr1CMBJntv39M+RDdIVznOaREK3zYG188evfvi2ur
	cVin6bk8z1TPWFKmUEwv+wDv4pRLKC0o+vLxhUGL1liS0ukCW6Yq+WFjB0HUYwWyctA==
X-Received: by 2002:a17:90a:5d15:: with SMTP id s21mr1290373pji.126.1560376637467;
        Wed, 12 Jun 2019 14:57:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVfRQxhJ7pSepqggSIW2uiOA1I3JE/aBEBOCdIakKFmal7aWT7YumS5TXPiHQzbcIQ8ds/
X-Received: by 2002:a17:90a:5d15:: with SMTP id s21mr1290321pji.126.1560376636386;
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560376636; cv=none;
        d=google.com; s=arc-20160816;
        b=Y1towDrZB69ow/w+Ifg6YcMhhNFyI39RkJvVMURLU8nYQcFFdvc8cijR62Hh8rdqhG
         nBo1Rcf8H0f4TrkHeTWMlRKwHhDPx+c1S/pIdKQDaLFreVWiWk8Fws7zW4xbrvOuo1hn
         qO9E3VFdNmnZFLRiBbtmSyL1Z4Y8XYtLy5bbeBt+7YtDjquOVle5T2rcB/GQZ/hAZ4MM
         ZsGXSk0SZOoRVi8ycSIp9eAtCdUSw1MvYz5rv2jYpMWf65oR+ButSxaHXfwr5GwlFsh+
         wXdFHY6py3SZLqbdhW2I7x2mHEqARUPcpjr1w9iN/cUlhM+ELAXHiRBSKiKRJjumvUiK
         DrYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4kJ5Q4DCdZWctI1HwEx678LwDtYH2kVuCUx2wAqJGFE=;
        b=YV2LOHQQ0RWURgI3czPSwL1iljsKq5QIfwqccY56/KzZGA6k+28Y/z6nfLcO23TFgi
         ZWdEwuObgSQE2b3i7FaBKllwnnfVMCLNslvbuaXn1JaFUTSbKPcSR5g8n13RCPGXh2o9
         W5DDH0E0umx7Q5Mxg+tU600B0D66mynr5nG8s1AszNBRy+qaQermSRPdeaIiompDBSDe
         Fj1/KnRNJsFVlbSqY7L8gSzEBKl8C0xR9dUnautlCTSG9Jdvf/+okjyBugxCEWtPFNd3
         rsJLC1Ede4NuKjXSa6XoeHUSu5zy5C4JinuK7jMs3RoM1xMxJy8Y0h6AYTJHdlUocOgM
         HVXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id c14si806317pjr.51.2019.06.12.14.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU0Hbt._1560376624;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU0Hbt._1560376624)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 05:57:14 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of __page_cache_release()
Date: Thu, 13 Jun 2019 05:56:47 +0800
Message-Id: <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The later patch would make THP deferred split shrinker memcg aware, but
it needs page->mem_cgroup information in THP destructor, which is called
after mem_cgroup_uncharge() now.

So, move mem_cgroup_uncharge() from __page_cache_release() to compound
page destructor, which is called by both THP and other compound pages
except HugeTLB.  And call it in __put_single_page() for single order
page.

Suggested-by: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/page_alloc.c | 1 +
 mm/swap.c       | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a82104a..7f27f4e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -623,6 +623,7 @@ static void bad_page(struct page *page, const char *reason,
 
 void free_compound_page(struct page *page)
 {
+	mem_cgroup_uncharge(page);
 	__free_pages_ok(page, compound_order(page));
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 3a75722..982bd79 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -70,12 +70,12 @@ static void __page_cache_release(struct page *page)
 		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 	}
 	__ClearPageWaiters(page);
-	mem_cgroup_uncharge(page);
 }
 
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
+	mem_cgroup_uncharge(page);
 	free_unref_page(page);
 }
 
-- 
1.8.3.1

