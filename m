Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DBCCC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28F02208CA
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:09:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28F02208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFA256B026E; Fri,  7 Jun 2019 02:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD32A6B026F; Fri,  7 Jun 2019 02:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972626B0274; Fri,  7 Jun 2019 02:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69ED96B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:09:13 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id v1so472853otj.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=YO/B0XIPUrcta3UGb7HueTim6Go09O/U69ZQrtX4kec=;
        b=WrPANRxFDogr13mRFEb79X6e2A5SSqCaUwooQhsWdpg0bIUu7x6/y71Tt2KDpZOLGK
         13OXPveX+dync2aG6q9LRH4KBZfeifaK6W8M5hU0Lvt4QW0ENWjbHnYIVKFKSYZ3mKZO
         Io7iyQPRTc31rcxsHSLEr5mgjsJMFR2lbUhGbCiQzNpPDkBndRgPeVfHbAwFpqyOxSjv
         EQMX9Vpo2SUjYqmcbvdEVqwilUHw4aTLT0Ef5qskmKPlbHGCncxVCgpiYGzfgJuWCTPg
         1JJ9irTTx/dVMkoJbVbNm+d2iguhGs/L/BvRNnM/6utOkFDejpp4C1EbWM1hghp5vits
         RLVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXuQwM/1NFq79ABiLnNU7a4ihGWprRr5N3xLgPmjyEHinuo7mgr
	IKxiEX0KZyEtb88LIYurw8aLhevcOqkl2qO7t9DC+6INHnEi5mAhjaj9qk+AAAHjhdBPU8QudEi
	vZWgT6g3JN+KsNT4N0lOcgieCYYyjG2zzFD/LJ3jYef3BMKRrjr9mrWOxX6xji6xpgA==
X-Received: by 2002:aca:c48b:: with SMTP id u133mr2600032oif.95.1559887752990;
        Thu, 06 Jun 2019 23:09:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0LC4sQmfMlEk/PAS1epwbCEbLZ6iHbobfKY9lsWFmV4OScQMFtiLr2ag+2zD5nnrwAS5e
X-Received: by 2002:aca:c48b:: with SMTP id u133mr2599989oif.95.1559887751859;
        Thu, 06 Jun 2019 23:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887751; cv=none;
        d=google.com; s=arc-20160816;
        b=IgGPRGNFdj6A1JCDmQopzntqCZ/WRvQ214MGDIATc04Vr66YQpfQAjhtasik7THqoj
         huUuZ08mwy8QzGUGcN6R3qRj1ubFygKIC0zQY+5klmcM14lhNBgbwEJkVeYJp+tDU/EO
         MfSk211xf77Dt/tquO3fUJDlvWOZXf1octKMl0Ym1dSI+Gjxx5CNUgPcCaylk0A/GL/s
         8UkCqJ7dYom6LlRNs3ACKh74ChSTrIlsyLWdi9qdbehN5r5ruOGQLor7SGo0Uz4lgvj+
         LRCQc8W8whCg6Q7kyn9kZC6CbfvnfAIlFQPTPTI1Lz/AX+OGIIrM+MCicCUfiw/+mwai
         j1dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=YO/B0XIPUrcta3UGb7HueTim6Go09O/U69ZQrtX4kec=;
        b=NhBQ+pDAGu6Sz5XnF4HqtsY/3ISeHjX2HPcwxkVhkW+0nO+UtK6Jl7dsYv+wS3+V6a
         +yYbPwk2NzuPFmY0sJPSFcupG3kvjqCwM/OjwPapiGKxHQ3Pr2smHSSdYd5ImBf7afob
         5MOLYnRZZJLtKCqAmVAI84hyBskqcaoneBXvupUSlQxpnbuwBXaYqvfDU1a9UcEXev7N
         4DieISZne0UhXhZKe66mmbFQH/iv6Ep5v5L7aRfRjUAnTDWfuCWMCuaG7nn83qmJwjX2
         r9npItCqEIBwWHlgLCR5D5M8XDEE/SbvcZnDQ3xqn7J9CrbHA67qvYF8pgPJQ2HFCmpb
         jphg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id e132si800033oia.44.2019.06.06.23.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 23:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTcZLUN_1559887677;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTcZLUN_1559887677)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 07 Jun 2019 14:08:10 +0800
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
Subject: [PATCH 3/4] mm: thp: remove THP destructor
Date: Fri,  7 Jun 2019 14:07:38 +0800
Message-Id: <1559887659-23121-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The THP destructor is used to delete THP from per node deferred split
queue, now the operation is moved out of it, so the destructor is not
used anymore, remove it.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mm.h | 3 ---
 mm/huge_memory.c   | 6 ------
 mm/page_alloc.c    | 3 ---
 3 files changed, 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834a..e543984 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -740,9 +740,6 @@ enum compound_dtor_id {
 #ifdef CONFIG_HUGETLB_PAGE
 	HUGETLB_PAGE_DTOR,
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	TRANSHUGE_PAGE_DTOR,
-#endif
 	NR_COMPOUND_DTORS,
 };
 extern compound_page_dtor * const compound_page_dtors[];
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3307697..50f4720 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -511,7 +511,6 @@ void prep_transhuge_page(struct page *page)
 	 */
 
 	INIT_LIST_HEAD(page_deferred_list(page));
-	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
 static unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
@@ -2818,11 +2817,6 @@ void del_thp_from_deferred_split_queue(struct page *page)
 	}
 }
 
-void free_transhuge_page(struct page *page)
-{
-	free_compound_page(page);
-}
-
 void deferred_split_huge_page(struct page *page)
 {
 	struct deferred_split *ds_queue = get_deferred_split_queue(page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a82104a..6009214 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -261,9 +261,6 @@ bool pm_suspended_storage(void)
 #ifdef CONFIG_HUGETLB_PAGE
 	free_huge_page,
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	free_transhuge_page,
-#endif
 };
 
 int min_free_kbytes = 1024;
-- 
1.8.3.1

