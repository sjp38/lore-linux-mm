Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A78FFC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FB05261ED
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aSb1R8bq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FB05261ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09A8A6B0273; Thu, 30 May 2019 17:54:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04A4B6B0274; Thu, 30 May 2019 17:54:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07066B0275; Thu, 30 May 2019 17:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3C4A6B0273
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:22 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n90so93995otn.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=s26j7V3iEZr//55S8rYqaobNc+2iO706C6wxuCttLf0=;
        b=lZXyHBkZMNw3FYeWzKStsifnMbyEOOUYdIs6fVDQxVZNEWRUF9hzD+JxP9k3xBIKmt
         3DBbCanKYk2fyU0xSXnJycaeWZIIt02OKjgIA6uFylSyx+Wvk3J7smJyEQZ/6E31lIuy
         Gzu1lkLGOeaRr4o141R1vWTsjTkMcq0/AYd4OQ6ONJKNUd/F/E7aI95ZHX+0OBi7gZRL
         zKUcgQnjPGuU1JYWvFaNRmcO9xOnD8YXu6RgChF8PGc936YNo+kVZdIGzkLNGC7GLKxm
         49mJfBbzGEsB/xTxgg6Dc9Dq/DXWeGacsaBJ0H1pWdJIvQUGzY+XFH1N8DdQ4DIe/MAj
         NRZg==
X-Gm-Message-State: APjAAAUpd9Ayn23zUzm7Sjd1QegMMA+IdQuPGtLrtytwnumQRNqsxCCa
	Qb7GS+dGbuVTm7QsBC7f2bDtdwq4j6ZFVmTj1CQiQ0U4t53q5lXLZnXI1hoAzb4yy1ngAKo6D1I
	UtGsMKxAEm7tTqFe2tv+DkqusKlkGlFJ5MIBH4GFYjSu2JiAbSi19nnSkuruJZnPL8g==
X-Received: by 2002:aca:ec53:: with SMTP id k80mr53477oih.123.1559253262403;
        Thu, 30 May 2019 14:54:22 -0700 (PDT)
X-Received: by 2002:aca:ec53:: with SMTP id k80mr53446oih.123.1559253261540;
        Thu, 30 May 2019 14:54:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253261; cv=none;
        d=google.com; s=arc-20160816;
        b=Apq34YIl3/ER/WqbIwH7RIiU03h53KOFZV97e37RAjmGInmDg74WcHKtzlq1HeL6Db
         tEX8/FlpYHkcBsd2o2J8Vip0tTJRJiviC9RnA5b0NCx5JTl2K0501APu/i4/4ipj2gTQ
         ti3c9s7OFnaiEdyiZQ8pxnoXUCt93q5DFuMfdThxK9009m5dlCyaHn3qD04+T2PTaA+s
         rdCHvngsLil7O0zJ/0SFWbRNg7J50PWz+9UIr9sjIsFIMYQCZLdcL/+OTeQxA38JyOBk
         GWTP5VGoKuMMmvTkFY6KvORpp87dQjOoboc5DlBTqgB5oEV/AgZNgcnYpynsJqH4b+CM
         FXGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=s26j7V3iEZr//55S8rYqaobNc+2iO706C6wxuCttLf0=;
        b=el4DAqbSfFx6h0y3k5X2mrnaWmk91nF10FF6fEGfyJRdg7SHrvgM0Wh+Lx1aq+Imt5
         KVi21ktsnHRYJjjfe752dsnmNf5unmzrOn7LLydNBGN15Js5R8AE/WPODMQbV9tDO/NP
         DpmOJFI7PnskukRyZ+iVDDMsPKH89CCsGLOZrFq4QAHDBjqUys/BwIjU+vNXK2OtL+Gy
         h+7GfO5t65XZsDN1qpA8YL+w24yeBhV92EEO2KbtcHQr3oSXsZVnDv0r2BrxvgWCMCpv
         K06ZUCWxbon22kvsyr/S4YQi4V2npbGacwtswJuH0AOtdjPpySx7hxa9ddNFceKVQIss
         INCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aSb1R8bq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o186sor1146408oib.8.2019.05.30.14.54.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aSb1R8bq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=s26j7V3iEZr//55S8rYqaobNc+2iO706C6wxuCttLf0=;
        b=aSb1R8bqa6Rr+SLly5lIAn6ed5UqisHx2cm6+o2zE7jy8I/m6Ufv6nvAAvA+75/NEu
         m/lrayI+hShBHlah07B/ZkL3lqq696x2NUjibkLhfJPBsBJBESEtYFuDzDrckyYAlDvg
         XXaTAzOzEL2wAXcPUQn0S6hyluZbeHnPjkSRnnT1eJeZEbbFA3q5XaMAAPOKmsUfnE+1
         7UeR4D2WS4GiveHpkiF9qIUMj9VMCxpY6cjNmQwdap0RJYIve+PbJK2N2DZsXq9TKApw
         jm/vr+vrW24xGM/DJ8+ArlgCGwtunsLl3XaJ3Agwt/xQPku1APV5CR+J397GTEJKbI+1
         6yog==
X-Google-Smtp-Source: APXvYqy/FQ8bhtfq9GgSYKUcKlSG4/DGy0PBOtr85jmyWEPil3tQV1gAaVwyI4p86YxQAPDAp9Ru0A==
X-Received: by 2002:aca:5004:: with SMTP id e4mr3986999oib.179.1559253261053;
        Thu, 30 May 2019 14:54:21 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id v89sm1442292otb.14.2019.05.30.14.54.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:20 -0700 (PDT)
Subject: [RFC PATCH 06/11] mm: Add membrane to free area to use as divider
 between treated and raw pages
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:18 -0700
Message-ID: <20190530215418.13974.63493.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
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

Add a pointer we shall call "membrane" which represents the upper boundary
between the "raw" and "treated" pages. The general idea is that in order
for a page to cross from one side of the membrane to the other it will need
to go through the aeration treatment.

By doing this we should be able to make certain that we keep the treated
pages as one contiguous block within each free list. While treating the
pages there may be two, but the two should merge into one before we
complete the migratetype and allow it to fall back into the "settling"
state.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   38 ++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |   14 ++++++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a55fe6d2f63c..be996e8ca6b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -87,10 +87,28 @@ static inline bool is_migrate_movable(int mt)
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
 
+/*
+ * The treatment state indicates the current state of the region pointed to
+ * by the treatment_mt and the membrane pointer. The general idea is that
+ * when we are in the "SETTLING" state the treatment area is contiguous and
+ * it is safe to move on to treating another migratetype. If we are in the
+ * "AERATING" state then the region is being actively processed and we
+ * would cause issues such as potentially isolating a section of raw pages
+ * between two sections of treated pages if we were to move onto another
+ * migratetype.
+ */
+enum treatment_state {
+	TREATMENT_SETTLING,
+	TREATMENT_AERATING,
+};
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free_raw;
 	unsigned long		nr_free_treated;
+	struct list_head	*membrane;
+	u8			treatment_mt;
+	u8			treatment_state;
 };
 
 /* Used for pages not on another list */
@@ -113,6 +131,19 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	list_add_tail(&page->lru, &area->free_list[migratetype]);
 }
 
+static inline void
+add_to_free_area_treated(struct page *page, struct free_area *area,
+			 int migratetype)
+{
+	area->nr_free_treated++;
+
+	BUG_ON(area->treatment_mt != migratetype);
+
+	/* Insert page above membrane, then move membrane to the page */
+	list_add_tail(&page->lru, area->membrane);
+	area->membrane = &page->lru;
+}
+
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
@@ -135,6 +166,10 @@ static inline void move_to_free_area(struct page *page, struct free_area *area,
 		area->nr_free_raw++;
 	}
 
+	/* push membrane back if we removed the upper boundary */
+	if (area->membrane == &page->lru)
+		area->membrane = page->lru.next;
+
 	list_move(&page->lru, &area->free_list[migratetype]);
 }
 
@@ -153,6 +188,9 @@ static inline void del_page_from_free_area(struct page *page,
 	else
 		area->nr_free_raw--;
 
+	if (area->membrane == &page->lru)
+		area->membrane = page->lru.next;
+
 	list_del(&page->lru);
 	__ClearPageBuddy(page);
 	__ResetPageTreated(page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f6c067c6c784..f4a629b6af96 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -989,6 +989,11 @@ static inline void __free_one_page(struct page *page,
 	set_page_order(page, order);
 
 	area = &zone->free_area[order];
+	if (PageTreated(page)) {
+		add_to_free_area_treated(page, area, migratetype);
+		return;
+	}
+
 	if (buddy_merge_likely(pfn, buddy_pfn, page, order) ||
 	    is_shuffle_tail_page(order))
 		add_to_free_area_tail(page, area, migratetype);
@@ -5961,8 +5966,13 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 
 	for (order = MAX_ORDER; order--; ) {
-		zone->free_area[order].nr_free_raw = 0;
-		zone->free_area[order].nr_free_treated = 0;
+		struct free_area *area = &zone->free_area[order];
+
+		area->nr_free_raw = 0;
+		area->nr_free_treated = 0;
+		area->treatment_mt = 0;
+		area->treatment_state = TREATMENT_SETTLING;
+		area->membrane = &area->free_list[0];
 	}
 }
 

