Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0600C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EA752238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EA752238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36E296B0005; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345C16B0010; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BDEB8E0002; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C06306B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so32436181edr.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6Mh79RAA5pSJuJeknurkVikW8ZCWGhCG4w/vjmj7nmU=;
        b=FOR2RM9C6rEHKcqqOkx3zh+ykjb64UYEDBT2A3qa3gLSA4LZiXM851hcuAFeKzWFWB
         V0v4h6YOTuwBZySlrLhEHOTXvAzt2Sm+Or1Gcu+0BCGtX458wcWn4BVNU9xYNqRwHqYv
         7SbWRzHb5g9yTbBieKt1T98MeN9schkgu+Sjrmyg38UJ2mHVcbhxER20aSdB1e1Onml1
         sxlSOiC0V7MPzxpFlSbIRISOw9yMn+6oMC/zTRu5uucy7lwW3t7gCPCnnzZ+I9ezbDpa
         JjByLKLXEB79tDjjzcRe67T6dQbLzwDVUMP45vtCn3kGqIiFdIwlNx4koC7Z8ZtuRytj
         vVKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWVgcnsoc0Sfb/fqYCIb2ndM9NlsdAsdq6UNLBG/WxsE3SJA7qG
	WpqLmXEXaPBQBqFmKgoAKIKgBlEHve02XhbrCYjX9BtSdkfMqgl9NERSwDE2nPjE71iyT49+Mbb
	RweaV4MWqqLhSVVylvguLVq2sviEnRF6DaK9mNegPelqFwnKd5C8AmHa5sMXNlh0a5g==
X-Received: by 2002:a17:906:161b:: with SMTP id m27mr67622980ejd.203.1564070537250;
        Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxjN3PrVIVcACi3oyfn1EmMWSJglYHFeN/cdEwEtLf5yiddhDuwiQ2KW7jCnf2nMsGbtnb
X-Received: by 2002:a17:906:161b:: with SMTP id m27mr67622883ejd.203.1564070536114;
        Thu, 25 Jul 2019 09:02:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070536; cv=none;
        d=google.com; s=arc-20160816;
        b=I5qEZnZMeAc7r1WPcRBoEJVhEXhXsAna6Jj2b5DInlF7wHQmxZjfPv+YkCX21j0Af+
         PZMrOVBjcowpdz0g1AEL3u3ksw8eACo2Pymp+mnGuqY4VBKYrrahS39aVzOq80gbd8+s
         GikRTdtmBg4U+8CtLXMzutajCeuVuGXpHDFDY9qqu3/LjbbK6s1Kvo0aKn8CsgNrtceP
         BgIvfpQocT037hxSXfMZBrCnIN8MsRNLWAJmkk8i9M8GtUS3peCOHQvB3J2sBBcMviCz
         TgPJhbBd8YkdynIN+q+b//3ZyqPCv0p2SAM2bVjW/0mFrJlGWig/s+IKkCCyuBwbu03E
         WaSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6Mh79RAA5pSJuJeknurkVikW8ZCWGhCG4w/vjmj7nmU=;
        b=PnWVVQjucA6JjpH6QJ5SrrX0EERDjN4A+WhH1AeSh89tftarOm3iRbIfFzUamaHMK8
         /+SWUJUgzHBl3/vM0NDqGcsvd8mzGo6d+aHkkEr69fxp1dEmargp+eU956C4XRjSkb/0
         GRuFl+4yYYWFdJVTeqIXzW4jSX1KyGY/hHplvylmKAzUOVAn9Q8GaEJGzaL6+xk7e1NS
         6pze1rWh7DPvqKA45KeqF2XyFiU4kTJd4nCu1gsizP7TMMJErk6Anjb615nlmci9uvaF
         4lellV/M6jlB3s7mIJpFKDqnvIplFSCCj3TLamK8LcmenDipIiy6cQy3vmpSttRADthk
         ZGQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si9722043ejb.211.2019.07.25.09.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B6699AF74;
	Thu, 25 Jul 2019 16:02:15 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 2/5] mm: Introduce a new Vmemmap page-type
Date: Thu, 25 Jul 2019 18:02:04 +0200
Message-Id: <20190725160207.19579-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
References: <20190725160207.19579-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduces a new Vmemmap page-type.

It also introduces some functions to ease the handling of vmemmap pages:

- vmemmap_nr_sections: Returns the number of sections that used vmemmap.

- vmemmap_nr_pages: Allows us to retrieve the amount of vmemmap pages
  derivated from any vmemmap-page in the section. Useful for accounting
  and to know how much to we have to skip in the case where vmemmap pages
  need to be ignored.

- vmemmap_head: Returns the vmemmap head page

- SetPageVmemmap: Sets Reserved flag bit, and sets page->type to Vmemmap.
  Setting the Reserved flag bit is just for extra protection, actually
  we do not expect anyone to use these pages for anything.

- ClearPageVmemmap: Clears Reserved flag bit and page->type.
  Only used when sections containing vmemmap pages are removed.

These functions will be used for the code handling Vmemmap pages.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/mm.h         | 17 +++++++++++++++++
 include/linux/mm_types.h   |  5 +++++
 include/linux/page-flags.h | 19 +++++++++++++++++++
 3 files changed, 41 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 45f0ab0ed4f7..432175f8f8d2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2904,6 +2904,23 @@ static inline bool debug_guardpage_enabled(void) { return false; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+static __always_inline struct page *vmemmap_head(struct page *page)
+{
+	return (struct page *)page->vmemmap_head;
+}
+
+static __always_inline unsigned long vmemmap_nr_sections(struct page *page)
+{
+	struct page *head = vmemmap_head(page);
+	return head->vmemmap_sections;
+}
+
+static __always_inline unsigned long vmemmap_nr_pages(struct page *page)
+{
+	struct page *head = vmemmap_head(page);
+	return head->vmemmap_pages - (page - head);
+}
+
 #if MAX_NUMNODES > 1
 void __init setup_nr_node_ids(void);
 #else
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6a7a1083b6fb..51dd227f2a6b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -170,6 +170,11 @@ struct page {
 			 * pmem backed DAX files are mapped.
 			 */
 		};
+		struct {        /* Vmemmap pages */
+			unsigned long vmemmap_head;
+			unsigned long vmemmap_sections; /* Number of sections */
+			unsigned long vmemmap_pages;    /* Number of pages */
+		};
 
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f91cb8898ff0..75f302a532f9 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -708,6 +708,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PG_kmemcg	0x00000200
 #define PG_table	0x00000400
 #define PG_guard	0x00000800
+#define PG_vmemmap     0x00001000
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -764,6 +765,24 @@ PAGE_TYPE_OPS(Table, table)
  */
 PAGE_TYPE_OPS(Guard, guard)
 
+/*
+ * Vmemmap pages refers to those pages that are used to create the memmap
+ * array, and reside within the same memory range that was hotppluged, so
+ * they are self-hosted. (see include/linux/memory_hotplug.h)
+ */
+PAGE_TYPE_OPS(Vmemmap, vmemmap)
+static __always_inline void SetPageVmemmap(struct page *page)
+{
+	__SetPageVmemmap(page);
+	__SetPageReserved(page);
+}
+
+static __always_inline void ClearPageVmemmap(struct page *page)
+{
+	__ClearPageVmemmap(page);
+	__ClearPageReserved(page);
+}
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
-- 
2.12.3

