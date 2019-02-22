Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76923C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 428EF20700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 428EF20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 258AF8E0108; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CA9E8E011D; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F383F8E0120; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8249E8E011D
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id j16so557570lfk.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:43:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=yKRXvErt07o5tp+Ch7j9nKCwXPl5/sL18WaRQ7Sr6og=;
        b=aIIN+9XUE1GtKKa3YNbOZhiNHv0zzzZOcEX3ZvHF8gxduM/nfYheIVBd7Ex+ypWvN9
         DuMk17c0+mWEKp7F+2kDQ9BkNAXkZE0w4taxAv1TNdK2E5uFAepeYvTN1+wQBbk9bYBD
         hAt0a8oW/yixQq6bS3aMgpfK4iNwG13xb/WmzTlAXlobDKOQs/nrt5wBLvKa2kVNzeCq
         /cOTNJTV+WwBYmvEn/wxXvqVqt+tOc4L6GM5Ag7VSY90OCJT+8nCO+sv4FkZf/tu9/cD
         akVPk77S/Z3i87LDRiPiaNhDvY5pM+l4lwSeOw4BK9uBunmeiWrUp/4Xzyq9pRjxt2YN
         8g5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAualVoSiSbGoLeduQznKxrnHGgzyTh5HtjVqHXLtgGvDxqM0AxlC
	gUgMOyehL5nJlZFQruIBq4+3+deyJff6pxYWEEiAPUosvXTRwGtQ+bWsqt54DhYmLH9HreHjxvi
	/5PsX3x8AAh1Ocrvw8gJJP7kDWqLD2HhQx+FpO7KO0pNF6HVEFzgIrWkMZInJKaTz/Q==
X-Received: by 2002:a2e:81c7:: with SMTP id s7mr3180431ljg.146.1550857406777;
        Fri, 22 Feb 2019 09:43:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYGFtVnCNHV7XIZYvmXrEazVU4rbeDuzbgnbYKROwapK9H5KcoVTWIe9ANLAIpLhJMaYIuU
X-Received: by 2002:a2e:81c7:: with SMTP id s7mr3180370ljg.146.1550857405547;
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550857405; cv=none;
        d=google.com; s=arc-20160816;
        b=btENr6MlNZbAfTRQ3jqSTO6pb8FmNIAlcvRJ8YVrcuAOv9wVkwkcpo3Jkcg1hO5PwI
         CtM02uEZQ7NC8MmGRnH8kSJgrYk0OoN53LgcDMMFsRhWifE39y0pjy8/babr28ZoLzHq
         uvrKIqPq5faJ87UswsPQz7l60X5/OLtF2l35rf9pRm+p1AuL8jYdWa8Ezt76Q+2Ey1wQ
         4vla1aIEFlp/5C4DxIygX6JUaynbH0Hy/DHqFFb2xu+6E9kEqrbwLoqCMJ20+/Vr2bAS
         w77XoKfrdYgyW2ZTMqJLqCm9T2iSOVwl8rLy9bnz6mrtW77pHbCyRKdzuUiVsdvWsq8u
         oIPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=yKRXvErt07o5tp+Ch7j9nKCwXPl5/sL18WaRQ7Sr6og=;
        b=z7REJeiDOpbh7X9DIRV/26Re76ped6gr7XREo7DD2+Iztw0D3UqwcBKrXemUn55HOw
         yTNk+jbX1s6jDYeopthOLu/IWBVuJFcSmrFhJWUNvjac9COPNEUZPh0cMAi3euwAvMk7
         B3JGBkvACEbJrrEuNoAtxYeDsbqF/AbWQfWGjjjlqmWn1rb+PZpfe0FhdVNV8dp82qjK
         ZrVEV+LDVPijPLglCfXn5/l9IyViRUDZJF/6HiGRVbBqtjeLPxpknW2oxc5XzL74qPHE
         3+Kna2ah9aneD7CsuG+9MnTUUorKMzW79PWzu6Yq9YAPwrXekFWl8ngzakLytJC1L7NQ
         ltRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j12si1580157lji.90.2019.02.22.09.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gxEr3-00010r-5K; Fri, 22 Feb 2019 20:43:21 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/5] mm/workingset: remove unused @mapping argument in workingset_eviction()
Date: Fri, 22 Feb 2019 20:43:33 +0300
Message-Id: <20190222174337.26390-1-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

workingset_eviction() doesn't use and never did use the @mapping argument.
Remove it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/swap.h | 2 +-
 mm/vmscan.c          | 2 +-
 mm/workingset.c      | 3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 649529be91f2..fc50e21b3b88 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,7 +307,7 @@ struct vma_swap_readahead {
 };
 
 /* linux/mm/workingset.c */
-void *workingset_eviction(struct address_space *mapping, struct page *page);
+void *workingset_eviction(struct page *page);
 void workingset_refault(struct page *page, void *shadow);
 void workingset_activation(struct page *page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f0f332..a9852ed7b97f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -952,7 +952,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		 */
 		if (reclaimed && page_is_file_cache(page) &&
 		    !mapping_exiting(mapping) && !dax_mapping(mapping))
-			shadow = workingset_eviction(mapping, page);
+			shadow = workingset_eviction(page);
 		__delete_from_page_cache(page, shadow);
 		xa_unlock_irqrestore(&mapping->i_pages, flags);
 
diff --git a/mm/workingset.c b/mm/workingset.c
index dcb994f2acc2..0906137760c5 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -215,13 +215,12 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 
 /**
  * workingset_eviction - note the eviction of a page from memory
- * @mapping: address space the page was backing
  * @page: the page being evicted
  *
  * Returns a shadow entry to be stored in @mapping->i_pages in place
  * of the evicted @page so that a later refault can be detected.
  */
-void *workingset_eviction(struct address_space *mapping, struct page *page)
+void *workingset_eviction(struct page *page)
 {
 	struct pglist_data *pgdat = page_pgdat(page);
 	struct mem_cgroup *memcg = page_memcg(page);
-- 
2.19.2

