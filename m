Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE31C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EADD20842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tYp6+TIU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EADD20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BC426B0006; Mon, 12 Aug 2019 17:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16D6D6B0007; Mon, 12 Aug 2019 17:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05C6D6B0008; Mon, 12 Aug 2019 17:33:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id DBA1F6B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:33:34 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 89B55181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:34 +0000 (UTC)
X-FDA: 75815077548.10.honey09_595adff857f00
X-HE-Tag: honey09_595adff857f00
X-Filterd-Recvd-Size: 6225
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:33 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w26so5082529pfq.12
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:33:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=gP7k43mJSv5f3YSNOpp9K4LaCXk5lNEqmssvOI0R3mU=;
        b=tYp6+TIUEgqUEVOd3/wG8T2Wc6LtpGcesLdCDXD7zKuA9rlMoqRP1Hao9b5KKfCxov
         4vTvfO0mfXRWJYtn8WF8OJ9ENLMWipWoXQoBgwvqn8fY2KU4H98Iqh9QJ0jLiYXsoNvw
         XPqSZ4RgVZm//f6mfnGMk1IfzBZNWhPhub2fWw9uRBtVdEx2FjXSrp2xit2/nlrhmJ44
         wK36rTY4Oc7I14eHPdikOaMp8EopPMhki8WlxKWaA2vLUClZxtz3NR50HdFgf/HtgypD
         /66NSma8aerTGVGesGGmlU8jQbytgUFKcTY3tpf4LC70ulROJea5XMcKA2Ed3YxnXVfa
         x6Cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=gP7k43mJSv5f3YSNOpp9K4LaCXk5lNEqmssvOI0R3mU=;
        b=lB9XotccK6p1C/lpHbL66zDzWolZwFXs1MqXBsRnXnkAFhkfHtMGo+cecEz68MkCkp
         7ci7IAkLa+Uy9MOgNiN0dH7dVtcKZzMhvkq73zJ5SuJ7D9hkQBaapl+umBU3S0oF2MpB
         8nm3q+NpA0HCA1PE0uG3ZLAJnLOVPZRnOSIVuNC55ORDE0Y1QxXhBAk5QlXPjXFFN5Lm
         PeaTjbaswQG1fsuSijENfQNBfWewXcRzLhOwpw3npRHjtw8EHSbwxznWEYqa25biRTOU
         t+J8SxgQtn97ujSu/ex29tuXJ1eu4ScOV+MPlaP+GhxGk4BrDxB5XCus1u6nTEaAv4a5
         aiag==
X-Gm-Message-State: APjAAAX5GijlX8h47epAXGnRJIWAF4k1miGbkjGvN+V0Jhtx1sLfIdUu
	b7OMm/3/FIKqkxGX/kXw2UU=
X-Google-Smtp-Source: APXvYqyuO0QCuGKHd/8j+/2toQLfvARYCrAPYBvjPNhEu77qAFuOgxBKtquha3T84KDeJcTTHIjcLA==
X-Received: by 2002:a63:6c02:: with SMTP id h2mr33347922pgc.61.1565645612681;
        Mon, 12 Aug 2019 14:33:32 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id c70sm8063pfb.163.2019.08.12.14.33.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 14:33:32 -0700 (PDT)
Subject: [PATCH v5 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Mon, 12 Aug 2019 14:33:31 -0700
Message-ID: <20190812213331.22097.94620.stgit@localhost.localdomain>
In-Reply-To: <20190812213158.22097.30576.stgit@localhost.localdomain>
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
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
index e3cb6e7aa296..f04192f5ec3c 100644
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


