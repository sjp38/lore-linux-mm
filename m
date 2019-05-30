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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA48C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F449261F5
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rcau95AX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F449261F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B96846B0275; Thu, 30 May 2019 17:54:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46916B0276; Thu, 30 May 2019 17:54:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E7EA6B0277; Thu, 30 May 2019 17:54:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6E76B0275
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q12so3469822oth.15
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ySRpFG6dIOHZ+M23tjria9Tf+GQw7/jvywjmJkXyRMo=;
        b=Pg5nJevJVQOS7Qv90xjEzkKAtPWV7HyH5FaRQqwK9Nnuk4YiQhgcnXCCBISalbWLrF
         iZRFV5E1lQzYtN8KhE4y7eUfSoDw7ZOLishvuvxCGpkX0kg1DH5cx04cD0DTxbv34ZFp
         9+kVQqJGvNE128lxIGVJKdWdVPsNL6sQCgiPulx+qVVHA1UDb017YsPkek+dZeODQlYV
         JOGJ6RFn40Lv+VGpsrL6rRiksHLOhda5m+Py+uEWIpzS+k3qb51Uf9MB4A5JYJf04F0D
         oSOlbIc1bLD6ST0MsJgxfEl+7HtAZ9HhPWiWBs2xATIDLTTZnXfMBi/JLDhE/kisD/io
         +MHg==
X-Gm-Message-State: APjAAAW5oF0dyOZmgiWiFrP2WhY12pmfmn/WC7N5Xzbfirvi21w8rpK8
	UNdqs20v5kNBdMFo/QJUnCeSCG/cjLxY2kagP7koGAgv67IiqDXhYOUjEw3Zc2DiCScw5fiUkFy
	xhmAnIY+2qplk5YFb8XQQ9EbH5oxeLtte/mYmy9n8xMV7uATrRjv9zMwFcCehzTAo7g==
X-Received: by 2002:aca:c7d7:: with SMTP id x206mr2820268oif.92.1559253270117;
        Thu, 30 May 2019 14:54:30 -0700 (PDT)
X-Received: by 2002:aca:c7d7:: with SMTP id x206mr2820230oif.92.1559253269030;
        Thu, 30 May 2019 14:54:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253269; cv=none;
        d=google.com; s=arc-20160816;
        b=Hn7PLOBTPXfRTLjiqNTm6qaZREFAzmOLiV8Tq14Y6sOCXboZytpYEhjwfzOhCs1Bgy
         +xW1/g376a3gMLxhbaSoon6UD7tfPOez6aH90ifZ21B0qNqRAFxio1Z9oTJsM5VS6uPe
         N5sTRe6QOwQC+WJE2QG1n7Jx9B+SqDccPyPvNJHj76x//NVN165l1KnHyEP6R/FOU3wJ
         1NJYsu11G26ksZj2wzxEChz38YwZKpZzRuB0mUIuhJuLs8QCZGZzKkIMSIEIOhVH+SV9
         aGlra2Cpd4Jlq6YkFMOFQpSVNC1SKgOiDSmpUIJpy5YoixbMpl+MQI0Zkkph8yDJ7jse
         zRQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=ySRpFG6dIOHZ+M23tjria9Tf+GQw7/jvywjmJkXyRMo=;
        b=WqBIIMf48PF1Hvh9OP6GbcyWTLzEjbyky3H4xebJNbxVfAGhySJjMsCajIPjk7FLtE
         oXW/dClHl5HVHY8EhBvPUDZh95BNQxphx4b82JCTRYycGTcgz+WfBJMZqjQ101TJGEms
         j+WXfuY2pZJRuFwHyHn38UZdwJQRDJl1RAF7ExHw7YjpuyR0y1R1u2bgll793PnYq5L4
         Dw0yjYTtKx2tOKE9sxKh5JmuIvKNGhzVDo4RdrP+Ay4lvxytPdvaoCF+cJFbilUk0U5s
         61YEfyTJ5kVNQdxd3SpaCyWjk2Wq/46s84+cXXL07Eb/SratEy1BEMtNGeY1wO2VKPkt
         ythg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rcau95AX;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor1931288otb.115.2019.05.30.14.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rcau95AX;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ySRpFG6dIOHZ+M23tjria9Tf+GQw7/jvywjmJkXyRMo=;
        b=rcau95AXvxEykUxo3o4rkucpfbR1LX1x5X5CXkMhzd1fqmFgZZwKoTCbMpKKbYqFfC
         UbdBILZlqxd2RuRIYCEGRxN9ep9jYLYhRreEWra8LWhyYsMzByoobPErsAneYypuf6Gu
         PE0cjm4SCxwhQ+NB4y+KyiiEoBG9ckxFVgWYm/GtS2/Qw+K5GSC6c6a8Nvh8Z/zxoIGG
         Y4buUb8l/83NXSsb2o15MmHUsRTwTI8cOyyoiVqfkSpG+HVP3nQTtHm+7oCsJFRGsagc
         ei5rEo+G+E2/wyIldOG821aJC1RHYMP9oREGt0ATmV6jeHMyQNAdMUGC3sbUmsIg0r9/
         beYw==
X-Google-Smtp-Source: APXvYqxrTapW1llgCNvcp1SuLkSKr6HRUWIeylHL8O4HoCla8qYP0tDZcevscz28QJb95+UxLu1Szg==
X-Received: by 2002:a9d:3285:: with SMTP id u5mr4625825otb.266.1559253268401;
        Thu, 30 May 2019 14:54:28 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id p63sm866455oih.1.2019.05.30.14.54.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:27 -0700 (PDT)
Subject: [RFC PATCH 07/11] mm: Add support for acquiring first free "raw" or
 "untreated" page in zone
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:26 -0700
Message-ID: <20190530215426.13974.82813.stgit@localhost.localdomain>
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

In order to be able to "treat" memory in an asynchonous fashion we need a
way to acquire a block of memory that isn't already treated, and then flush
that back in a way that we will not pick it back up again.

To achieve that this patch adds a pair of functions. One to fill a list
with pages to be treated, and another that will flush out the list back to
the buddy allocator.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/gfp.h |    6 +++
 mm/page_alloc.c     |  107 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 113 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b503dc45..407a089d861f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -559,6 +559,12 @@ extern void *page_frag_alloc(struct page_frag_cache *nc,
 void drain_all_pages(struct zone *zone);
 void drain_local_pages(struct zone *zone);
 
+#ifdef CONFIG_AERATION
+struct page *get_raw_pages(struct zone *zone, unsigned int order,
+			   int migratetype);
+void free_treated_page(struct page *page);
+#endif
+
 void page_alloc_init_late(void);
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f4a629b6af96..e79c65413dc9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2155,6 +2155,113 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
+#ifdef CONFIG_AERATION
+static struct page *get_raw_page_from_free_area(struct free_area *area,
+						int migratetype)
+{
+	struct list_head *head = &area->free_list[migratetype];
+	struct page *page;
+
+	/* If we have not worked in this free_list before reset membrane */
+	if (area->treatment_mt != migratetype) {
+		area->treatment_mt = migratetype;
+		area->membrane = head;
+	}
+
+	/* Try to pulling in any untreated pages above the the membrane */
+	page = list_last_entry(area->membrane, struct page, lru);
+	list_for_each_entry_from_reverse(page, head, lru) {
+		/*
+		 * If the page in front of the membrane is treated then try
+		 * skimming the top to see if we have any untreated pages
+		 * up there.
+		 */
+		if (PageTreated(page)) {
+			page = list_first_entry(head, struct page, lru);
+			if (PageTreated(page))
+				break;
+		}
+
+		/* update state of treatment */
+		area->treatment_state = TREATMENT_AERATING;
+
+		return page;
+	}
+
+	/*
+	 * At this point there are no longer any untreated pages between
+	 * the membrane and the first entry of the list. So we can safely
+	 * set the membrane to the top of the treated region and will mark
+	 * the current migratetype as complete for now.
+	 */
+	area->membrane = &page->lru;
+	area->treatment_state = TREATMENT_SETTLING;
+
+	return NULL;
+}
+
+/**
+ * get_raw_pages - Provide a "raw" page for treatment by the aerator
+ * @zone: Zone to draw pages from
+ * @order: Order to draw pages from
+ * @migratetype: Migratetype to draw pages from
+ *
+ * This function will obtain a page that does not have the Treated value
+ * set in the page type field. It will attempt to fetch a "raw" page from
+ * just above the "membrane" and if that is not available it will attempt
+ * to pull a "raw" page from the head of the free list.
+ *
+ * The page will have the migrate type and order stored in the page
+ * metadata.
+ *
+ * Return: page pointer if raw page found, otherwise NULL
+ */
+struct page *get_raw_pages(struct zone *zone, unsigned int order,
+			   int migratetype)
+{
+	struct free_area *area = &(zone->free_area[order]);
+	struct page *page;
+
+	/* Find a page of the appropriate size in the preferred list */
+	page = get_raw_page_from_free_area(area, migratetype);
+	if (page) {
+		del_page_from_free_area(page, area);
+
+		/* record migratetype and order within page */
+		set_pcppage_migratetype(page, migratetype);
+		set_page_private(page, order);
+		__mod_zone_freepage_state(zone, -(1 << order), migratetype);
+	}
+
+	return page;
+}
+EXPORT_SYMBOL_GPL(get_raw_pages);
+
+/**
+ * free_treated_page - Return a now-treated "raw" page back where we got it
+ * @page: Previously "raw" page that can now be returned after treatment
+ *
+ * This function will pull the zone, migratetype, and order information out
+ * of the page and attempt to return it where it found it. We default to
+ * using free_one_page to return the page as it is possible that the
+ * pageblock might have been switched to an isolate migratetype during
+ * treatment.
+ */
+void free_treated_page(struct page *page)
+{
+	unsigned int order, mt;
+	struct zone *zone;
+
+	zone = page_zone(page);
+	mt = get_pcppage_migratetype(page);
+	order = page_private(page);
+
+	set_page_private(page, 0);
+
+	free_one_page(zone, page, page_to_pfn(page), order, mt);
+}
+EXPORT_SYMBOL_GPL(free_treated_page);
+#endif /* CONFIG_AERATION */
 
 /*
  * This array describes the order lists are fallen back to when

