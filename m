Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97143C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 536AE20840
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:16:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 536AE20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70E18E0003; Fri,  1 Mar 2019 07:16:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20C98E0001; Fri,  1 Mar 2019 07:16:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2148E0003; Fri,  1 Mar 2019 07:16:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37B0B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:16:45 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id g75so4029620ljg.17
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:16:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5V0Jc8fZCMuyA/STfU/rTFl8fSsF3ZLymwIJq0T3P0U=;
        b=nMsr8q2hnwiJsVEYBlE0t1Wp/dOyynn88YWAwKyl32NK+L+y08BKEEMEa3qvvk8+zu
         ASpvUQV4nrveqr8uCINfuDqa+8xxrx2wSlucgnpVjhl+Jw67KLCJDUQAJ2KDUmENyqBY
         vinzT/pzup4XUW70X/edYS1tSBoGbBTLDIzYVBGrZKm75HIV/CIuRcNtYqyW9pMFj8MK
         /HwnegT9asUFDWamM/YOLl5uz/RgnwBQ0XHOi0imm/2xLMnHZSI7Q1Ibo7/NdLYVFZ9c
         AUzTyQ9cr3DDqYOWLovJO/xfwCoSDh/lm+8twDJYN/DVI0UYqxg1QxfBhfdnWjOoxLsM
         cv8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWHRSQf482156FtkVZjhC4l+FHtehAmmWV2Blgc+BjYYNiziOui
	NAbJNBCjxAvhbhWuN6LALirdoo58bYyH9221cIbNWEpwH/Zkj9dofg0ajNRbi214mMQinMc+8rT
	Td11S+BrCEkSgkn6R08vWAjbcav1xFdv8Jr14lgMoVbQbyXPHcisnSBTFb6q/ZzgYUg==
X-Received: by 2002:a2e:814d:: with SMTP id t13mr2513028ljg.46.1551442604568;
        Fri, 01 Mar 2019 04:16:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqyxSkAJwk+cDZKow1NhaN+pBIjvo07pt6KFVNGMVeiuqo966tIDZFOmwOueQzg+Ktb1jC5v
X-Received: by 2002:a2e:814d:: with SMTP id t13mr2512980ljg.46.1551442603463;
        Fri, 01 Mar 2019 04:16:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551442603; cv=none;
        d=google.com; s=arc-20160816;
        b=XnfxMMSOY2dtoXFVUGc4PK36PI+xVJCMjbUQxZiqDJKyfud9JhD7+t693d+FtfRF1s
         SFGq87EsEWEDz/Tiqh4fk+aV8SIwAVBgD46ZH99Wv4qr9GxoARm9jRDlGonJVFB7EKMd
         5tkCu+meafDvR08v2f1ZDcX3ALlVsrmYOktLMYxc9ph9CdK5i+ypEBGe+qv0I3Ve1pzm
         FuxY0jmgGae9WYYgyMngBphTCp3Sc6Q/lUUNHhwOTHMOAnE1N0TFEqszIVPbLjEgIJXC
         cmtVCC99E6g5prV8JmC6321D+v0qBHlgrEtJnz4pMvOZ3S0GIOR0wA6JkoN5o8gKTUPD
         O+jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5V0Jc8fZCMuyA/STfU/rTFl8fSsF3ZLymwIJq0T3P0U=;
        b=pSjAww+ByOijImXu9hsrqvK4bdajEsLyCdLN75vXUkltfrfh2x/fECaSLstyafxN/c
         evnj6i4xtGxz73BFhgeLjfufeJfup5PuzKyPubrn7xhtwrdvrIPzAlcBuDqlEpgWFYiK
         v0Sgt54vVCofUZ7OWnzHhqih/2nj2qw4tu8RcA7DgnJAuhy58WB3VkcXUcKfO2NBWBYY
         31xamZf4Ex5GTFyV9bv6jmiq5AtrBSuBKZ1JCqzpjSdpPrHEQvZi0sCtaQ964aC0nTZ8
         SfGC1FHVcBVI2gHO5fAAVS6lzmQOKGFtUi8FfG1eaYTDBlNp01YlP750X+4nf7c3EuAa
         W9YA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y24si10244833lfg.7.2019.03.01.04.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:16:43 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzh5j-0004ZX-33; Fri, 01 Mar 2019 15:16:39 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	William Kucharski <william.kucharski@oracle.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH] mm-remove-zone_lru_lock-function-access-lru_lock-directly-fix
Date: Fri,  1 Mar 2019 15:16:51 +0300
Message-Id: <20190301121651.7741-1-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A slightly better version of __split_huge_page();

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4ccac6b32d49..fcf657886b4b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2440,11 +2440,11 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		pgoff_t end, unsigned long flags)
 {
 	struct page *head = compound_head(page);
-	struct zone *zone = page_zone(head);
+	pg_data_t *pgdat = page_pgdat(head);
 	struct lruvec *lruvec;
 	int i;
 
-	lruvec = mem_cgroup_page_lruvec(head, zone->zone_pgdat);
+	lruvec = mem_cgroup_page_lruvec(head, pgdat);
 
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
@@ -2475,7 +2475,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		xa_unlock(&head->mapping->i_pages);
 	}
 
-	spin_unlock_irqrestore(&page_pgdat(head)->lru_lock, flags);
+	spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 
 	remap_page(head);
 
-- 
2.19.2

