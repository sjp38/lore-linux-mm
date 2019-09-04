Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3E39C41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:10:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BFDF22CE3
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:10:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UFkLFQpC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BFDF22CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CDAE6B000C; Wed,  4 Sep 2019 11:10:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37ADB6B000D; Wed,  4 Sep 2019 11:10:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290306B000E; Wed,  4 Sep 2019 11:10:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 045376B000C
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:10:39 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A3BBA82437CF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:10:39 +0000 (UTC)
X-FDA: 75897574998.11.ants44_7a1b547f3f653
X-HE-Tag: ants44_7a1b547f3f653
X-Filterd-Recvd-Size: 6227
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:10:38 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id s12so6439395pfe.6
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 08:10:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=p6kpa+V/mOCw2Z+/w4fmfqemmfT1IhqWlu84Sk3ejgg=;
        b=UFkLFQpC7E14Ptl4qhmREGp8b+BS/boPhGg+O4m+5ArD6kZf3FfjmAiTLZuUmkI9Ty
         OZGjg3C0zJnk4XgjOsLLfFKed7k3HdgxKtDtveiknbYQRkBFjfuYYrVB+kI8mX3tc0YF
         3gyE136VMmMvaCZhCWqAA1f0NuTsdCQL/n9hMLMCmC/yyNcUO7rzgc6bBfuSYVQn7QO4
         4xfcHLLp9fjwzH5U/MDqPGMleIl53/lI+O/0ubte1uyIFmU+nYcd8R9VSVkwaet4v8lc
         xPSSdiyMlPiEooJhGOKIrRD23sse/vHSBlGXXWob+PZTqG0xKym5Z7Xfx+mPx4Sn4C11
         j4Rw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=p6kpa+V/mOCw2Z+/w4fmfqemmfT1IhqWlu84Sk3ejgg=;
        b=BBcFhB1SH4ZluU7Yx2EcD6gkilQA+ccaxkrGfhAxwpOohT5GOqt8ym3boKkiV77hAQ
         E0UzuL/m7+5yZsgKpNFn0TFksY2cX9HKgmbDtz2zCBzQf145Z8XQ/knls22J/QiR4zdr
         h8OdkAULkkyeyIVG4j3TTYaYZmQbiXcKSrqC/qWdirxx17gBrzP9qfxP3rm1cTXsooKj
         BK0uKdnvnU74w1O4Ftp1Du2g7GA5Px5j3u6rGfkJlbZG7hPc2yS0p3wRMILMWCYd1TCB
         oC+V6zv/invqcgKd1J4XEs6l/ph/AP2kASNq7E6gkcow2ctQLppOEnfrW5Da17EhNWGb
         5j6A==
X-Gm-Message-State: APjAAAVRtuqbPp/Euh9Guh7NQuII2YzYuWIwvwCtOwKl+LhA6Lk+XGhy
	Kfgb7iGoavGgQFUiu5DoBqE=
X-Google-Smtp-Source: APXvYqwrcq8XegDQKGDNlpLz9ievgPZeY+21HMDXgAdbxzbLSVIJ4dp0rvcd/C0zGXp9pDll7JlPZg==
X-Received: by 2002:aa7:9343:: with SMTP id 3mr15433820pfn.145.1567609838132;
        Wed, 04 Sep 2019 08:10:38 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id u69sm25695517pgu.77.2019.09.04.08.10.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 08:10:37 -0700 (PDT)
Subject: [PATCH v7 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 04 Sep 2019 08:10:36 -0700
Message-ID: <20190904151036.13848.36062.stgit@localhost.localdomain>
In-Reply-To: <20190904150920.13848.32271.stgit@localhost.localdomain>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

In order to support page reporting it will be necessary to store and
retrieve the migratetype of a page. To enable that I am moving the set and
get operations for pcppage_migratetype into the mm/internal.h header so
that they can be used outside of the page_alloc.c file.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/internal.h   |   18 ++++++++++++++++++
 mm/page_alloc.c |   18 ------------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 0d5f720c75ab..e4a1a57bbd40 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -549,6 +549,24 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 	return get_pageblock_migratetype(page) == MIGRATE_HIGHATOMIC;
 }
 
+/*
+ * A cached value of the page's pageblock's migratetype, used when the page is
+ * put on a pcplist. Used to avoid the pageblock migratetype lookup when
+ * freeing from pcplists in most cases, at the cost of possibly becoming stale.
+ * Also the migratetype set in the page does not necessarily match the pcplist
+ * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
+ * other index - this ensures that it will be put on the correct CMA freelist.
+ */
+static inline int get_pcppage_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_pcppage_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
 void setup_zone_pageset(struct zone *zone);
 extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e4356ba66c7..a791f2baeeeb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -185,24 +185,6 @@ static int __init early_init_on_free(char *buf)
 }
 early_param("init_on_free", early_init_on_free);
 
-/*
- * A cached value of the page's pageblock's migratetype, used when the page is
- * put on a pcplist. Used to avoid the pageblock migratetype lookup when
- * freeing from pcplists in most cases, at the cost of possibly becoming stale.
- * Also the migratetype set in the page does not necessarily match the pcplist
- * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
- * other index - this ensures that it will be put on the correct CMA freelist.
- */
-static inline int get_pcppage_migratetype(struct page *page)
-{
-	return page->index;
-}
-
-static inline void set_pcppage_migratetype(struct page *page, int migratetype)
-{
-	page->index = migratetype;
-}
-
 #ifdef CONFIG_PM_SLEEP
 /*
  * The following functions are used by the suspend/hibernate code to temporarily


