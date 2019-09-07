Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52250C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 068E1208C3
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rYZVLzjv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 068E1208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABABA6B000D; Sat,  7 Sep 2019 13:25:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A910B6B000E; Sat,  7 Sep 2019 13:25:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D9A76B0010; Sat,  7 Sep 2019 13:25:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 777C46B000D
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 13:25:33 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 30D4075B0
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:33 +0000 (UTC)
X-FDA: 75908801346.05.tank09_134b539778705
X-HE-Tag: tank09_134b539778705
X-Filterd-Recvd-Size: 6441
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:32 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id b2so8712795otq.10
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 10:25:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=XeOFbkXePrFioXOb6FAIERJbwcp7KIiK2/+DoMA6rcA=;
        b=rYZVLzjvr5yE4QlzHHD82dZS2lBNT8G+0FQqFRdBYAjb/wKgN0lU5D1lBtoQWqfTjX
         aSCp6awRi7fd3X5kAvvuGccRdgGzZtxlICkGXwUikok0PX+w0BwbIa3SKAUzKWWokUeZ
         Qps21btfn9+VGyzAHOVRDS6z2Kqho67V64Mbajq6dDKkghbv6HLu8OoqaTF3ne8jpW/A
         uy6B4yNR064NWLAcd1nJqcMiDvCWIWDdSqgiAzUal7K14B5N6xMLv4F+4vPTHKSWOCJI
         Yzxr0oGW//qzZPv/1RcDfTKG18YRItPedk5lEVTeukfviAzCKHdYZIHdUFfHEbJsMsKs
         NGqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=XeOFbkXePrFioXOb6FAIERJbwcp7KIiK2/+DoMA6rcA=;
        b=iIhlPF7jkDdFQPugft9Ebvaav83U6X6HeZTs+70uTzYQX1z/i9KrN1sLX5pTK96/6H
         2M9t0klD8ibeBdc07ocenQuV/BiLdf0OHivk4jGdqxq+d/wyZwjjYTGGqR5cuoBeK6i7
         oqLFYUfhSy4KT13mj9E6q5ZCycXdzQ0rkbLy3bB1/pIrA3C07jhdqQgPTDJzs/eHC5yW
         SlSo5rr7eBgu5HvjY40f1B5rQTTghxga7rKW4azJYdCzbJAGnuBxdltIpagwtr9jP1Kc
         6TVwV1RV7IZOzdjKlDgFNCiINfO0L9vrNXnrGJNwWJyweAKs2ZQKPMkWwvpIzOY6wZb4
         L8MQ==
X-Gm-Message-State: APjAAAV3a1DKOa+bOajDCdIYeXSQJNHFX8Gn/BpDrlhDao8/rWxdWvbs
	Jg9JXAJc4kxz0q4+knFARoY=
X-Google-Smtp-Source: APXvYqwv1SFq7ObWqAIFpc+/RF0fOZtse6a3DjMkC4Rs/jY3P0in4RopuF/MfrzoMf7ETBATX4C09g==
X-Received: by 2002:a9d:1921:: with SMTP id j33mr12440399ota.304.1567877131742;
        Sat, 07 Sep 2019 10:25:31 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id p28sm3582003oth.38.2019.09.07.10.25.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Sep 2019 10:25:31 -0700 (PDT)
Subject: [PATCH v9 3/8] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 alexander.h.duyck@linux.intel.com, kirill.shutemov@linux.intel.com
Date: Sat, 07 Sep 2019 10:25:28 -0700
Message-ID: <20190907172528.10910.37051.stgit@localhost.localdomain>
In-Reply-To: <20190907172225.10910.34302.stgit@localhost.localdomain>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
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


