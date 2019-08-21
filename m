Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F998C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C94762339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pmRZjyhX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C94762339F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 732C36B02D3; Wed, 21 Aug 2019 10:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4A16B02D4; Wed, 21 Aug 2019 10:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D2A86B02D5; Wed, 21 Aug 2019 10:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFDC6B02D3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:59:41 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id ADCF3A2A7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:40 +0000 (UTC)
X-FDA: 75846744120.18.sheep43_5464fcf397245
X-HE-Tag: sheep43_5464fcf397245
X-Filterd-Recvd-Size: 6229
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:39 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id b24so1617183pfp.1
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:59:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=QPhM4FxLG/tLwSMDGDf/LdT0Fop/lM8Gcn0ubZPF63Q=;
        b=pmRZjyhXPIW1vJkVYB2QAF5y0/5tcxnlwpB7ZAO0Fy+VV95UNeq9duufGGMvxLHJQU
         p+CZYpUGtknHLC6I4RPu+qdfhBXOUVeMXNtZJ5BMlSA0RtWZ2cIHr4pxop6nEt76bTRM
         jg5wMV1ZnhGhmYsPfjGzmKvbqO86oG/HuvrfPrcTiScWmXZOrWextQrIGnJQor9UMP8r
         SjfdB5afonvgflHlux/Uju9eVJ70bmfZpetB8PmatU2wS7SJLr1GaN3e2cl0LuTbL4ie
         vrkAYqnr6+hbqnCanZTe+TPULzpvWc30zoa38m22LFYJjuAALvxvKxfHnkjnUVR5zJwm
         ISzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=QPhM4FxLG/tLwSMDGDf/LdT0Fop/lM8Gcn0ubZPF63Q=;
        b=DZUtB1xx53OR9DBJyZJR4jTccMC1r7IGprIOinviUiGRMQ0NqCHWuiIndlYdqPb291
         E/MX85zCpzDUnTkjZnwHdxGkhYUxIdQZuo38fEmKpUEMuN12/+rYvbDcRMnLh4wUeOPo
         JfPjc2iaGJ6ZvZGwADV6/uxd+keMG8Da6ORJpOXFdLR4PlAH1zvtIlGmB9ZhShGP+Ps5
         /qkX7yWI9mZvOUtSsvKhl/QngtBPvkcqg/zmDvxXxjLT5IV/ksMGoUCGubyfF/47XSdY
         QgIUWh/s4MrmHOtqfhBc0eLOlGGz6F/fp3vXD5Sto019XZ9u8AgCjb4VEHs54rXWdH+j
         xLlQ==
X-Gm-Message-State: APjAAAWxbr42fct++eIbRCbRZsJRtVG8HarG0Py/TYJzIteCGzrznM+f
	/oAG7rD+w9fOZnYTKyCpNWw=
X-Google-Smtp-Source: APXvYqwiHXRijhHRhNIDrYtME3k6OqWOeiu1KWcm0C0JSNx7KxTeuVS2kjfis9eSrEjyDTRxU3GNjA==
X-Received: by 2002:a63:1d4:: with SMTP id 203mr29204834pgb.441.1566399578782;
        Wed, 21 Aug 2019 07:59:38 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id e189sm20827753pgc.15.2019.08.21.07.59.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 07:59:38 -0700 (PDT)
Subject: [PATCH v6 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 21 Aug 2019 07:59:37 -0700
Message-ID: <20190821145937.20926.78233.stgit@localhost.localdomain>
In-Reply-To: <20190821145806.20926.22448.stgit@localhost.localdomain>
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
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
index 3f8d5afe61fa..c1f9a80b3f28 100644
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


