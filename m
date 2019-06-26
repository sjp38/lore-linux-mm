Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E163CC48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88381208CA
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88381208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF556B0006; Tue, 25 Jun 2019 20:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B1A98E0003; Tue, 25 Jun 2019 20:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19F2A8E0002; Tue, 25 Jun 2019 20:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D78C46B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:03:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so343140pfv.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:03:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6CrxZMPVKtWiO2W03kvINqv+b3cQRf9/AK6f9stpruQ=;
        b=UZJm2u17PomnP7dKoYQCngG5ZALvms6Wojkq/kF7P85UVMZ4C42+O8OUC52eIIbwVN
         x5UjEHZu11azqkDf4CJ2CWe/2EG9jmVEgeJ9EODoocOEy1sUpoTlanA9ma3F6VkAbEQO
         NwaM469HDitwWaSTVnqS/BDpcxwwpuMVDtHwofsrkbk1f4ZVhOC+RHBaUQDjLkgILL5g
         b/Gtu/Oz6ZhOTuPCMbKSvumgeVlF6zBWX/TlqjP66ErsTv1RlWGPf42C7hjOSCq6rfay
         MsLW9pRXhSXoKW7pjpfgKyBPH7tKkNddjy5vtQxxHApnG1HbPtI+oWCxaTGcP/2jiUee
         Z2nA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWvQiLGhO6b/j0hBr1F41myvoT4Lg6tq6RLVnzHE3CXtqKKN6bG
	uKXHrNMBa9zi9fPGTdJd9K6Sy2leHih2twjlpHbGkZYDOEhoYjkEs631VA6vpjGk6V8zKfvG/LG
	yrlEzwCKJ2MK8fch1isPZwHTQIDsZNS8VPW0yU1kp4Etq00b1dBG7yEo7iwAwZ9o5qA==
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr680125pjr.88.1561507386452;
        Tue, 25 Jun 2019 17:03:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMC7hgLkq3aL01USZjA+AH723n4STuvM6QVq66jtAOER3heLIU0Lf+QlqhT6MpvyvM0AUP
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr680030pjr.88.1561507385419;
        Tue, 25 Jun 2019 17:03:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507385; cv=none;
        d=google.com; s=arc-20160816;
        b=glKUNUIUj2oRhr7fq4z7Y9Swd33Wg83jcXllg9kMLdu6zpq0DYBE9c/RxNkFVZImAe
         ScWKKFjm5zS93W4VhYuvJXAVf08kJoZJlxPXsKNNCDf+TaY4ss1ASoqq5yXanw0buL/b
         TH18XxeyQpqm0FSzB8SySuz97EmWDJjypRUWfJ+Xq/aVDylb2Fveru9d2m0x2TuXlGKH
         zitaJcK1m0PXZkZ1+YWmkRgsY2pYrAD7IXC3AbXwXOSy8nCdjoNBU3mJ9F1Z7fYwva11
         IMk2V+m/sxW9kwLEXFNF++zsiKL94JOfDt1qnVLHOHKFnESByLvQtzebzAfMsnB7GkTO
         7Rag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6CrxZMPVKtWiO2W03kvINqv+b3cQRf9/AK6f9stpruQ=;
        b=rFER6JJ5lF/JUuNVvpEWqRSziQRF1kzXXOZE3ac9RgC7dtjuePF2MMe0s3wsp4gASZ
         PL2oIGIHh4TMHhT4qDIfZCIqTGe4bGvMy5QaHQotexgsI+U0i4OQeU76ouYY4U36/ccJ
         o2d1J4yboiOLYuP8qRzZxdTXa3PcLLAb9H2074rixD2Wm9wb/ggk/WK8Vk1bqjwWxvpQ
         879oDJrvplaa7FyoNxrx4c2ZwsMemsUY9Q3ju/GnIkHG9ANc657AC6/ivwIqha3vWPJ3
         59mlzH9RvkAVFY8tcMj7WQUawIrsONZYwg+tU+AHkhCrmocerie0RTX8DWtG7RAPQpay
         HjNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id h12si12067947pfn.171.2019.06.25.17.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 17:03:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R411e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVCYVJX_1561507375;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCYVJX_1561507375)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 08:03:03 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 2/4] mm: move mem_cgroup_uncharge out of __page_cache_release()
Date: Wed, 26 Jun 2019 08:02:39 +0800
Message-Id: <1561507361-59349-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/page_alloc.c | 1 +
 mm/swap.c       | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6c9cf1e..53a7a6c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -624,6 +624,7 @@ static void bad_page(struct page *page, const char *reason,
 
 void free_compound_page(struct page *page)
 {
+	mem_cgroup_uncharge(page);
 	__free_pages_ok(page, compound_order(page));
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 7ede3ed..170a725 100644
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
 
-- 
1.8.3.1

