Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 630B9C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 368B520665
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 368B520665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E41F6B0008; Tue, 25 Jun 2019 03:53:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD1C8E0003; Tue, 25 Jun 2019 03:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E14108E0002; Tue, 25 Jun 2019 03:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95F556B0008
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:53:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s7so24339014edb.19
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=pQySH0L22RUnV1R+Ri6D2HobC1fyefST74dWKRzISAc=;
        b=JWvbw+JHcoe/R1M7xUfPlY0Aw0EG2CrtbYtiJy1Jx17X4MkmWIs5OX+YnGl56l8HTg
         nXhbKp41agOHBBxV5O4gdiWiGzCKcj3ao+7NOpOof8rW7+WmVUdWQATSYbaKqouhZYt5
         UzNNoOjlYFCwLgCWU63xrHbehUC05lWocea1FDNLo/kDemy6dmxWYPMzsmSSNwvQ9wK0
         NQbifc/gSSWwhRF5L1IPb5d10AzM/wtbe0iCe0davve0Q4M0j48wnS8TqzbYRc4yEPp1
         uuwzHsQHo6moLL1we0gmTxgFomuJywUcw9h7pnsr8jkSFplKXsk1IXU0gxW1bwVJ9Z2Y
         iWEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUp2KjKzZR+4Dd3gAGPCEzUMjwYIIvICyVzbJ5sVj4LeUrzawPm
	pKk55gD5VI8XlnPLtnEnjE1hR+ydVle8/F0ugEZF74W6H08C2Gpnj8d/TYE5WV9cJBrA2u0ydq4
	+sJh8tKgIxzZq//e2dVoX/fJ9gFcGJd9bSydJhzdB0RaqccMxGultiojz/hXnz2xbNg==
X-Received: by 2002:a17:906:3953:: with SMTP id g19mr17204153eje.242.1561449190192;
        Tue, 25 Jun 2019 00:53:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHUQ4uiafh49rYR/Ooi6d/eoY2fKQ4YJQnAs+cJggb2qcQyyo48V/G73domiGWZd8bLePB
X-Received: by 2002:a17:906:3953:: with SMTP id g19mr17204083eje.242.1561449188973;
        Tue, 25 Jun 2019 00:53:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449188; cv=none;
        d=google.com; s=arc-20160816;
        b=ES3NebXaS/goRHdD2ZxCVaxNXTOypBV0S9XCtb4tSj2+YypaakkDNaYwg8Ug2YifTn
         k4PwMboOFoLuqnKHZ79HxXtm8JsMlrpDOqlESBGMZu42c7US3TapW64F1uCRbhpKyVnb
         iS2XzDZcDKSQM+4f8Di+7CTBfnryLDBokhKcWflMk+hYeyZDzaUZ47/kt2SbXhGuVpTK
         NX1ptbwAcISmI5GD3T7GVw2qjpbNzkUEgPten0SYbXZ50j5gAvvsOQRaBDok6sfwrC4/
         lrzjHGG6KL8jXmZ7oFWIcv1aa2i0cqBBOZXX+UKHfHIGIg3zoQZPqUzvwFdG55pwH0hx
         agIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=pQySH0L22RUnV1R+Ri6D2HobC1fyefST74dWKRzISAc=;
        b=tTACkTXVb9UPXWfvlOy+VhOrmco9AfRglgS3iCPN0Tlt0bF21ZrZuUJFVjf9BHdXwz
         5J4LBIRDb0a4vOcqWSE6+7k3y0ZcVdcHkCi6E/kKYCxEpQ8jrO/5sG17x7pk4RAxZge+
         TS7t5yCV4uX2exOecSClVTgy/aG5luld8ETUYWcThe9Bj60R4s6AQa8isj70IoOaB0sh
         urhSsrXbzE7ARHw3syauBPCAsm6w+pIED4LVn9wT4H1vNwjG10yoBZ1s3bJtv7h7rmk8
         2cAXV+HOysmv5vshc1mA696GwYEw7MZdBXFouwRd4zM3mkNv7cywOD9YJ9kTERzUitSK
         6lgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id j20si8309411ejt.117.2019.06.25.00.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:53:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 25 Jun 2019 09:53:08 +0200
Received: from suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 25 Jun 2019 08:52:34 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	dan.j.williams@intel.com,
	pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com,
	david@redhat.com,
	anshuman.khandual@arm.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 3/5] mm,memory_hotplug: Introduce Vmemmap page helpers
Date: Tue, 25 Jun 2019 09:52:25 +0200
Message-Id: <20190625075227.15193-4-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190625075227.15193-1-osalvador@suse.de>
References: <20190625075227.15193-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a set of functions for Vmemmap pages.
Set of functions:

- {Set,Clear,Check} Vmemmap flag
- Given a vmemmap page, get its vmemmap-head
- Get #nr of vmemmap pages taking into account the current position
  of the page

These functions will be used for the code handling Vmemmap pages.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/page-flags.h | 34 ++++++++++++++++++++++++++++++++++
 mm/util.c                  |  2 ++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index b848517da64c..a8b9b57162b3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -466,6 +466,40 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+#define VMEMMAP_PAGE		(~PAGE_MAPPING_FLAGS)
+static __always_inline int PageVmemmap(struct page *page)
+{
+	return PageReserved(page) && (unsigned long)page->mapping == VMEMMAP_PAGE;
+}
+
+static __always_inline int __PageVmemmap(struct page *page)
+{
+	return (unsigned long)page->mapping == VMEMMAP_PAGE;
+}
+
+static __always_inline void __ClearPageVmemmap(struct page *page)
+{
+	__ClearPageReserved(page);
+	page->mapping = NULL;
+}
+
+static __always_inline void __SetPageVmemmap(struct page *page)
+{
+	__SetPageReserved(page);
+	page->mapping = (void *)VMEMMAP_PAGE;
+}
+
+static __always_inline struct page *vmemmap_get_head(struct page *page)
+{
+	return (struct page *)page->freelist;
+}
+
+static __always_inline unsigned long get_nr_vmemmap_pages(struct page *page)
+{
+	struct page *head = vmemmap_get_head(page);
+	return head->private - (page - head);
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
diff --git a/mm/util.c b/mm/util.c
index 021648a8a3a3..5e20563cdef6 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -607,6 +607,8 @@ struct address_space *page_mapping(struct page *page)
 	mapping = page->mapping;
 	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;
+	if ((unsigned long)mapping == VMEMMAP_PAGE)
+		return NULL;
 
 	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
 }
-- 
2.12.3

