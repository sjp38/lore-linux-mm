Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0205AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC748218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC748218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9AC58E0007; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A49F98E0001; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95ED08E0007; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEF58E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id f1so3254669ljf.2
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:35:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=85dsEaG52aLvrMnn+v8Ng9t2qY5ys0HWtclDH8znRHc=;
        b=GM1J/IDxwWDTtNhkDMXFTUxu9Ah2xp41ruzlfOVgvnKrLKXYKj5/G/7pOus6fGV3KI
         XOnlGi56aujNH4EeV2i7PQw5RNKLUr5Qni2ZX5RkJXncyNpYeN/ZBtaiCck9FMvW+kA7
         47E9WfX5hu4C5dN+a0wmlgiYa9Vf2JfipaxhUzEL1F1oFRvYu+mmNzg9LEX4wMcLfUsJ
         7Y47MqG0S28HQRkMzOcbdzydf0pIKt8moEhAdbbJmiF+pCKTiC4n62TLC3cUBFmogQZx
         xnpJZq9hC5efs90KiC616NUfCerA4St1gpsRjNLjdBGJqev3E+Se0TSGinSAXG9wfGBK
         wTWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVbiNE9hl2wSd+dV5u4wVV4VxxJ9o5cUOfRPJ1TwHLq/vqSLWfm
	F84vHZO3nKHjB2ejR/w2sgKPCeu83xHU0+5QtOXVq/XhCMdbhNHsOupt57lGQmEB5Ey5xqrcpLM
	fM3JlMEpLm+OFIomoRWTZCLVFyCdMDrsSmMJgU7XJYy/TVyKmJSAJlpcGvHJZS/zbiA==
X-Received: by 2002:a2e:85cf:: with SMTP id h15mr4030750ljj.73.1551342948506;
        Thu, 28 Feb 2019 00:35:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqx6GvfpT0fiEAorNtho3WTuUI7ghWbH3THZ3xPZ9vQg0zoNJ4gxYCU9Nl//G2m0rBR0gpVK
X-Received: by 2002:a2e:85cf:: with SMTP id h15mr4030708ljj.73.1551342947427;
        Thu, 28 Feb 2019 00:35:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342947; cv=none;
        d=google.com; s=arc-20160816;
        b=QAznN5umAXjo+IoIcIoMnNjnZSYe8rL5TEOKhQbZ2Or3Q2W+bNVjNtVd+LUgzLIbpc
         tCe571Fu8x44sC8X8jhSIpt9tm6xh97JKJ4YEzh99k2kEIeBqovqCoy3xOpnPY2hTzPk
         T0rM2PoRGaNRv1okuypYlHgY6+i/T61HoN60G92ZTAy2AJ9pB2Q1U5uI2ks7L35Blb5z
         Bb8A56RXIQCoGHr0wIkQtfgf4yXDnrRp8AxbpcoN62cgEpGh4YbQH45g51gFQ3S0/uNH
         IlxenhmDYPLpNJODgaOLvw0dEnHgfIE2QkVMHm4oYLF09THOVr+LehYRFSxmVD9kyBVt
         020Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=85dsEaG52aLvrMnn+v8Ng9t2qY5ys0HWtclDH8znRHc=;
        b=E7D6AoA7FuphHoKvOsg6FE00ozQnN10TjNECwMfyioWiIdlhfHnqZdaHDADnzzlKth
         vlAQNZ+ydC25SxTlEqdSHWbXNZOcHZWh8Az9mMuVBgdNZiD1+O9ZVtWwMSH/itekbefX
         ImEAoQmjOzTVsTX5ygsQE6C66b+7qJ8nRg5o4aUmb6HdkXcyaQmG4LFRUJ5vFKuad1NT
         ZzvkjZzb0M3Vf+5EIXXUJlpqfad4QmCo5GorpDumzk8ZhdGQtxdZsnufYxfswByDF/Hj
         fPbeipoBjSyLhej7txwjypW/JbBKh/GwXRGJBnFqlcyIMlrs6C4bUa5l5V1ce/WOSTKm
         kOqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t14si7059157lfk.63.2019.02.28.00.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:35:47 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzHAJ-0008R2-PM; Thu, 28 Feb 2019 11:35:39 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH v2 1/4] mm/workingset: remove unused @mapping argument in workingset_eviction()
Date: Thu, 28 Feb 2019 11:33:26 +0300
Message-Id: <20190228083329.31892-1-aryabinin@virtuozzo.com>
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
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Rik van Riel <riel@surriel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
---

Changes since v1:
 - s/@mapping/@page->mapping in comment
 - Acks

 include/linux/swap.h | 2 +-
 mm/vmscan.c          | 2 +-
 mm/workingset.c      | 5 ++---
 3 files changed, 4 insertions(+), 5 deletions(-)

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
index dcb994f2acc2..0bedf67502d5 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -215,13 +215,12 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 
 /**
  * workingset_eviction - note the eviction of a page from memory
- * @mapping: address space the page was backing
  * @page: the page being evicted
  *
- * Returns a shadow entry to be stored in @mapping->i_pages in place
+ * Returns a shadow entry to be stored in @page->mapping->i_pages in place
  * of the evicted @page so that a later refault can be detected.
  */
-void *workingset_eviction(struct address_space *mapping, struct page *page)
+void *workingset_eviction(struct page *page)
 {
 	struct pglist_data *pgdat = page_pgdat(page);
 	struct mem_cgroup *memcg = page_memcg(page);
-- 
2.19.2

