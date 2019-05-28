Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49916C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1779D20883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:45:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1779D20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09406B026E; Tue, 28 May 2019 08:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA226B027C; Tue, 28 May 2019 08:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D0616B027E; Tue, 28 May 2019 08:45:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5877B6B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:45:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i8so15633094pfo.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:45:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Tr6OFS5Oxvi0s6GjNtS1zQPYLjHYXXZZYXHV57erJ6I=;
        b=gXobagwunNLR/UXisUs6Uw/ZMceXSPjVRBJFxllts71d6nmwu75xYg8MN5um2nhh3S
         BcE7lHFbsmTdm8jd8B+DCk76nOwdeEuumaEzq6AeFXqvpPvvUOk0TI6TTjiIPx/2mMcY
         6Y/bgCa4DxzzUjH0wam/GoKBlDROWJh1M6xi6MNkcnzy7TKVIR8p0F81b4QJQcTl91pt
         1rFqDB6E5+f/6e0CDkNVVBAqQ4zFh/g1wwcOKfZS7KuTh+U1doUTU1zoCIKnkyk8vwXO
         ppxh0/A4XkRCSuSx4H8niMqbwPA/SIY3yI/8F8RRecdJ36Ynk22nATPQ5iW0ID4HZc5i
         G+Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVoHZvsiNp+HKKg5S3xMmwzL6i2MqybbixWnT1Y0yuCVJn4X6se
	JXo/cVW3b41uDMIWtLESP7I0i2MmtSI52hyzwic9wp95fEvrq37ECfadg5hT4YHrZrAgZefVVRf
	sZDF1jWctjyFd9ZQUd8hj6cXGsJ6o2R2OpTLRx0/9yGRcO2PgcZntdM3Uc6g2aCIung==
X-Received: by 2002:a65:5785:: with SMTP id b5mr96895666pgr.252.1559047558008;
        Tue, 28 May 2019 05:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4YU2tJnQiro+/4kA56TJdYGXFZL+Hb05ivwo5Ps8QGJM5KKpe9fXY7VV0ZsZSeYk+/j+X
X-Received: by 2002:a65:5785:: with SMTP id b5mr96895542pgr.252.1559047556906;
        Tue, 28 May 2019 05:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559047556; cv=none;
        d=google.com; s=arc-20160816;
        b=fJEw4ZlVqxcdKxX1jTqAAk5k2HyPGrJQTdixQaK6n1EbBmODPTf9dIFO7kljkfPLzS
         fCM9w924oe0xzV0HdozWDk37i1WVMEdLar1hGZPG60A606jJ3iPjjVQ1ytcC6FAI3VLi
         yGOYDuy1xM8LrsYNVQyPyE9OWRLm3KkxVbJiZr14taR0mUrlSFtUfeVlPLmdDStU8hRA
         DY8eenUoqlRazDaL6Ma7oGv9gm3CVYzprtToSi4SUq+I6BccMLwr8VCJFMz40bw6Bb6c
         U6iw+rvN0fOJKHW4irgTwWXfIvzNH9tykzkYCX89GvnEHiPVVdEyIFLSMaWr9dnG/aSu
         LOyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Tr6OFS5Oxvi0s6GjNtS1zQPYLjHYXXZZYXHV57erJ6I=;
        b=vmWw+TvA1mk+cSOd8/2z02gVb/RtXu3bl3dJNlL2wFnuErbnk+eAXK9hA/yX3LTKm2
         CbYIYETvPNpAgg98Y90VX9pHHxfz9l7cixa4slKXK6P9kKi3pEa0SwyU8pzn0NJEk0BX
         p1Rwgp84gFpp40RS41Gc9HL1qLchkLYMhc7W5lzqIib1ISN514nyUlMPchQshbh1FLVN
         0PAldvXkrAyqVuU2inpvRITGe7YQM+gn5FfRsh6oz2s6g2M4YRoFqxeBj6xFF/r+hbX5
         cDAevzgWwSHEHUhR21aSSjq5IiVe6TrA5R+xyhcuM2RtOp11AAK/wRHWXErpzdHsGc0x
         dlkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id k15si22885591pfi.61.2019.05.28.05.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:45:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R361e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TStMl0v_1559047475;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TStMl0v_1559047475)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 20:44:42 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] mm: thp: remove THP destructor
Date: Tue, 28 May 2019 20:44:23 +0800
Message-Id: <1559047464-59838-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
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
index 0b9cfe1..91a709e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -503,7 +503,6 @@ void prep_transhuge_page(struct page *page)
 		INIT_LIST_HEAD(page_deferred_list(page));
 	else
 		INIT_LIST_HEAD(page_memcg_deferred_list(page));
-	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
 static unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
@@ -2837,11 +2836,6 @@ void del_thp_from_deferred_split_queue(struct page *page)
 	}
 }
 
-void free_transhuge_page(struct page *page)
-{
-	free_compound_page(page);
-}
-
 void deferred_split_huge_page(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b13d39..7d39b91 100644
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

