Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49298C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EE72218AE
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kx9ZIS92"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EE72218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E5EC6B000C; Fri,  6 Sep 2019 10:53:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 995896B000D; Fri,  6 Sep 2019 10:53:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AAB26B000E; Fri,  6 Sep 2019 10:53:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 678E06B000C
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:53:43 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1879C824CA3B
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:43 +0000 (UTC)
X-FDA: 75904789926.01.crush12_5a9320fb0604f
X-HE-Tag: crush12_5a9320fb0604f
X-Filterd-Recvd-Size: 6283
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:42 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id b10so3283476plr.4
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:53:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=XeOFbkXePrFioXOb6FAIERJbwcp7KIiK2/+DoMA6rcA=;
        b=Kx9ZIS92cpUp5XYIgowvjW7gz1qiMuGj8JlFJNvG2oheLU6d8RkrFPqNoYDIqBlCgC
         7yWJrSWC5qsnaNG1td/FhR/Eh7krX8YN3gNEQb7XZDOqw7RIgh/pq97J7x9Dy1Bh+QMK
         tBooMcRP+jUXwbQAoJ7u4uaWvZxlz0NvfE453INuDbkjU92ytM1GjgzEhFudHkrULMBu
         x4I1vfYTMCxzZR5yPeVXEd5nvbYKNtky10MfXkhJ3d31ysg4eDDfOLhqQxUr7ILHA0mZ
         dqp0UtKqt+MixfklXN0qXJm6oUF1E5nRNfabdr0WG9xY8NE8ppzlso5wyOA8+CO4RtcK
         JeXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=XeOFbkXePrFioXOb6FAIERJbwcp7KIiK2/+DoMA6rcA=;
        b=Wq1RrlX/56FcC7lMM01fsXYgrcN7lhgkOfFAwjuSTbzfGUXO9j7BX5Y/UcmmmUc2kU
         1Ce+cKJ/d+R16kl+43TFg1DJ7Tlq0I/PGXhgRVVASKMSEa23TcBuZePA94jSQ8Ehwdmg
         XhzJRqy8UDQ2wsYVj5CqOV7trti9x1IurNiYW/BPQsL9oDWwCGpJtIVNHDcg7CEoTa/e
         LHOC9g1ozbCR4H6NyxGCuav7AbzsW5W0IfVmhOoDzYuqcc/0ZIxw4hvL+xBGWwuRBNGT
         7hkj1hyGPmLvKCBTsSqs99VTs/SQW9zpMWVsqxBqGOQ6yOm2/EU2ThJOLvzpsO8lqEm9
         EwkQ==
X-Gm-Message-State: APjAAAWssWhhVjJYKDnlJCpkzoJJpssQQJqUhlGwfyC1YaFLnnl3QitG
	w9/9WK/JnYHHm2R8tId0pVs=
X-Google-Smtp-Source: APXvYqxhaJ6uuXR8fGWWr/ufBumPF6vYW2fu4W//uKfSwtowVRUUh4NcMog0BEj7MwBiHEYx30eOGA==
X-Received: by 2002:a17:902:36a:: with SMTP id 97mr9103349pld.75.1567781621416;
        Fri, 06 Sep 2019 07:53:41 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id d15sm6060563pfo.118.2019.09.06.07.53.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 07:53:41 -0700 (PDT)
Subject: [PATCH v8 3/7] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Fri, 06 Sep 2019 07:53:40 -0700
Message-ID: <20190906145340.32552.49026.stgit@localhost.localdomain>
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
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

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
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


