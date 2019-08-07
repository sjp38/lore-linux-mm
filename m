Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 913DDC31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51F6321743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51F6321743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA4D36B027E; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99AC06B0286; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 817066B0284; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE0E6B0282
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 28so5587966pgm.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 19:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RyYon3OQiUuSLM2zAcIH2GtXGSvPnDCExfLydBYxxQw=;
        b=lxsrbU5Yb0RtlUbluMK62pqah+np6R5VuYvE3G0xHJU1ldNZRTtbJf5WoWB2ciVIOg
         cy2e6LTfuGUm4JNjEysotqDF/kCU80slbnVWPTGNM4MfPCcQGxKDw9GLimDv9DwGlZQA
         LdwCLguIAR+CwI1M5ZUpAHUgpypWzZjQXkdueHjV1PG8hE6QJAfueK1i8YT4TbLzZT3H
         zL7uFdP+K1CwQGAD8kPkW32Tu7y+CfU7lmNAzJPKljkmq9ZikjD8hJavYXeuG7K4vfhD
         xerDCSJRs0N99GpoVDKy2ihZE5X0udmWBIyBUleudEXAaxB507WcgDvstc5uiUbf4CQc
         9y8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUBKIvk2GYwt4hMOtVvny+wmwYziTVf3HlMP9z6QcRlfA2s5VZE
	sZx4nCz8wTMGkhZCZafwezhB/l/3JTZ9tCjtM+xCNSLir657csYzHY8NY9kqzSICPn5tD/zVISG
	mo2UtAaJvFIjMHTetJUwyFb0OblNijf8XypqNmCU4FDIJbyGGaRzYoibFW8IqVmPAjA==
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr5978224plb.263.1565144296738;
        Tue, 06 Aug 2019 19:18:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEXgZY4vxvimCuS1O6cS791DlsR0XF9aGYDULHHKLObSqvBwvoVNoUz18MV/eVIj/rHvTY
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr5978169plb.263.1565144295480;
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565144295; cv=none;
        d=google.com; s=arc-20160816;
        b=VlNG6YjY3yAdskia4wJxm7KYiPo0LGIP/ajsbcXEJwspYBzgF/KnrfMHnjvm8w5tId
         VV4E5EV9/4RcS0MVVaBBG6rIXz5dwFfEoJjMQXTE+0m47g5RB0mgb70Iuh7Kf/ibPxik
         gFv9V85FOrmi2ywrknoRn5nWsyqhhh5B7RtMXubGaqT0Ul+OfQUykvO7bkSzOtXKHVfG
         DrwBDnX4RNzhjRSIjniXI+MpfeqWQ9csJ4ePQ+rWahrzNu7+G6zKTB4aGEXQed1aTOPV
         OHlNf5S8UiXjNH6SwSZ8+T6o+svpiXoLD+aPaujj98Nhw+vUslSiCPxuLlJzKQe0E0DN
         PvZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RyYon3OQiUuSLM2zAcIH2GtXGSvPnDCExfLydBYxxQw=;
        b=OrM8ruj1Yup0UKl3SOiFRj2BSoJMucRjVuyetevAM/FB5aBQdhIGgXpYhHXUE0BNks
         WlvZpejlToDI4DA8sYy2bg8kl9sEaZKTGdngzbxH+cYZQ+LF4PMvw16NvNjTrszsLn1g
         gp3DVPZUmvp+VFkwGIJ33JReLkLA/haDO/cGZhctu7uhlYVBC6MjC1CxmKUoRLSTL0tQ
         If3Z2if8FZMD0js+NkVGftdq3YC9mwHcV0uRINmyFSiMT5m9UrHju6uKscdxi5OhT0+O
         x73g5HNpx03wVhm6oZ/EU/QVtR/YqQko2F0lacBL+J7T1KAXGXpWuD3PKpUAay9yUpH6
         +qRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id ck13si16381222pjb.47.2019.08.06.19.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TYr3obk_1565144286;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYr3obk_1565144286)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 07 Aug 2019 10:18:13 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	cai@lca.pw,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v5 PATCH 2/4] mm: move mem_cgroup_uncharge out of __page_cache_release()
Date: Wed,  7 Aug 2019 10:17:55 +0800
Message-Id: <1565144277-36240-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
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
Cc: Qian Cai <cai@lca.pw>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/page_alloc.c | 1 +
 mm/swap.c       | 2 +-
 mm/vmscan.c     | 6 ++----
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df02a88..1d1c5d3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -670,6 +670,7 @@ static void bad_page(struct page *page, const char *reason,
 
 void free_compound_page(struct page *page)
 {
+	mem_cgroup_uncharge(page);
 	__free_pages_ok(page, compound_order(page));
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index ae30039..d4242c8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -71,12 +71,12 @@ static void __page_cache_release(struct page *page)
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
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dbdc46a..b1b5e5f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1490,10 +1490,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
 		 */
-		if (unlikely(PageTransHuge(page))) {
-			mem_cgroup_uncharge(page);
+		if (unlikely(PageTransHuge(page)))
 			(*get_compound_page_dtor(page))(page);
-		} else
+		else
 			list_add(&page->lru, &free_pages);
 		continue;
 
@@ -1914,7 +1913,6 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&pgdat->lru_lock);
-				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
-- 
1.8.3.1

