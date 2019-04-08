Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6A66C282DE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EBB820870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:27:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EBB820870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 368096B0006; Mon,  8 Apr 2019 04:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278BE6B0008; Mon,  8 Apr 2019 04:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1420A6B000A; Mon,  8 Apr 2019 04:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B26846B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 04:27:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j3so6511017edb.14
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 01:27:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=USfFxXD/a1Pabx8JBccnTQ8Cwuej+Rnj+Bf4yZ/rMyQ=;
        b=eUYxTAVav41xOo0qASxEBK3Md6YooIEV3LODAVQBwwap5mMdzZeNNj4jPQP/otI/H2
         SaKBjBgR5oE7CEp7+muMZv0XVDLTe5vrd+kwhSw2arCykeT32OC6HIz9PZNItAk1wplt
         v71Djz4CAG/ilvw0L05fTnlA4TtOiZ8QaD2HAMWcu+hgw7OLBY9lVby7tP4MFHwFuQxO
         hDHA0RzaBud9KBA5u7uWFz9KDUJYK899q+AX6UrWUR2tW/8O2zje8k1lAQMzyte1PdaI
         XyWwP4piSrsq9FHQ6PDXc8REVMhHtn0pIVQqhnurTM46K0fKbf/ezs/bcRG8d0ENnD07
         2wmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVHiG5En3kkcL24TfLR7aw0SSb3bzcQVzKS+bmPDJHQ0q0i4JmG
	dQB3F+c+lAIZ8QvRcfKzRk+KFZnBMwC1LBj/7PGRiOOSw9zt3ExlH6R5RDqK0Rx49CChPUXHPI7
	3v9owaOJ8bEpqLyKzpKDVGqhYZIZxA6HY/dOHXLWUXJOOIc7sQ5jrLGPwaGHdBmSW8A==
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr12509838ejb.218.1554712023239;
        Mon, 08 Apr 2019 01:27:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaE10S6aXiT8sRe2s/pnWvCjWm9JMnAXi3653CMq3akXqagUkMMtH/RdTdkryePM4TMLnD
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr12509790ejb.218.1554712022189;
        Mon, 08 Apr 2019 01:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554712022; cv=none;
        d=google.com; s=arc-20160816;
        b=IKWG4dHNetjGPB/ZGA+9WFucRSjdVItIhHw9LqIQ1tE5VX16XT+IlJ7aLGIj1Yj2o+
         KWF+b6KJK95xyWPtfPAWO6BRQqMqZxc/f2FgO1hDeL6FZyHfOmq1Yi9+a14FirdYZXVN
         L+FQ4W+r1bH8o4ZsE04P3nbXpR8FcDzHsBHiyO3y/EkXfhb0AAzMEHaU6E2ouljjeyuN
         ybzV4jrt0UtWZHVC9DjoBj7VHq5oxq3b14mPor/IV5Qae3bIZ9mdyGF6cSv1YtVtKVK/
         9e/oq56jT3jFHfPcURDtnwEmcycBuG2kgtI+GEJWKoRgP1E6CEuGclE0s9h36a8WAVnu
         t35w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=USfFxXD/a1Pabx8JBccnTQ8Cwuej+Rnj+Bf4yZ/rMyQ=;
        b=VpUXBcONHHTvbzBcOHHqL+BsWAwvi6afZbzg/YaxZhC7etGLltXWD7kWs1CNCpjs/t
         EbYNYcA3zW7Tr2WhV0BXzqAQ+3lDBTOspNuSa4Tk3IobWKCYvLXq5+Bcx3AFb6xD5EUo
         7QvNIAjUG8GQ0TtsFfmnFgs/FEh7emLACvL8kOJz33xtK3Gishkh2Z+TrmK5xsM7cM7c
         nBnfzmtV36WjM8nocLsEz1xckxIMGOpwtCxvsU0+jRTMoW5pqjm3S/wDb1TTocUwj6kh
         U1e8MGl/orzIohQTwczilktSjFD0OrLr4U5ePW486zDMfR3YmtN4zZ0je96OJ4sGg17X
         ABLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id j3si109742edt.141.2019.04.08.01.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 01:27:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 08 Apr 2019 10:27:01 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 08 Apr 2019 09:26:45 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 1/2] mm, memory_hotplug: cleanup memory offline path
Date: Mon,  8 Apr 2019 10:26:32 +0200
Message-Id: <20190408082633.2864-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190408082633.2864-1-osalvador@suse.de>
References: <20190408082633.2864-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

check_pages_isolated_cb currently accounts the whole pfn range as being
offlined if test_pages_isolated suceeds on the range. This is based on
the assumption that all pages in the range are freed which is currently
the case in most cases but it won't be with later changes, as pages
marked as vmemmap won't be isolated.

Move the offlined pages counting to offline_isolated_pages_cb and
rely on __offline_isolated_pages to return the correct value.
check_pages_isolated_cb will still do it's primary job and check the pfn
range.

While we are at it remove check_pages_isolated and offline_isolated_pages
and use directly walk_system_ram_range as do in online_pages.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  3 ++-
 mm/memory_hotplug.c            | 45 +++++++++++-------------------------------
 mm/page_alloc.c                | 11 +++++++++--
 3 files changed, 22 insertions(+), 37 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8ade08c50d26..3c8cf347804c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -87,7 +87,8 @@ extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 extern int online_pages(unsigned long, unsigned long, int);
 extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long *valid_start, unsigned long *valid_end);
-extern void __offline_isolated_pages(unsigned long, unsigned long);
+extern unsigned long __offline_isolated_pages(unsigned long start_pfn,
+						unsigned long end_pfn);
 
 typedef void (*online_page_callback_t)(struct page *page, unsigned int order);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f206b8b66af1..d167737f888e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1451,15 +1451,10 @@ static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
 			void *data)
 {
-	__offline_isolated_pages(start, start + nr_pages);
-	return 0;
-}
+	unsigned long *offlined_pages = (unsigned long *)data;
 
-static void
-offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
-{
-	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
-				offline_isolated_pages_cb);
+	*offlined_pages += __offline_isolated_pages(start, start + nr_pages);
+	return 0;
 }
 
 /*
@@ -1469,26 +1464,7 @@ static int
 check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
 			void *data)
 {
-	int ret;
-	long offlined = *(long *)data;
-	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
-	offlined = nr_pages;
-	if (!ret)
-		*(long *)data += offlined;
-	return ret;
-}
-
-static long
-check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
-{
-	long offlined = 0;
-	int ret;
-
-	ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined,
-			check_pages_isolated_cb);
-	if (ret < 0)
-		offlined = (long)ret;
-	return offlined;
+	return test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
 }
 
 static int __init cmdline_parse_movable_node(char *p)
@@ -1573,7 +1549,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn)
 {
 	unsigned long pfn, nr_pages;
-	long offlined_pages;
+	unsigned long offlined_pages = 0;
 	int ret, node, nr_isolate_pageblock;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
@@ -1649,14 +1625,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
 			goto failed_removal_isolated;
 		}
 		/* check again */
-		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	} while (offlined_pages < 0);
+		ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn,
+					    NULL, check_pages_isolated_cb);
+	} while (ret);
 
-	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-	offline_isolated_pages(start_pfn, end_pfn);
-
+	walk_system_ram_range(start_pfn, end_pfn - start_pfn,
+			      &offlined_pages, offline_isolated_pages_cb);
+	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/*
 	 * Onlining will reset pagetype flags and makes migrate type
 	 * MOVABLE, so just need to decrease the number of isolated
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c53807a2943..d36ca67064c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8375,7 +8375,7 @@ void zone_pcp_reset(struct zone *zone)
  * All pages in the range must be in a single zone and isolated
  * before calling this.
  */
-void
+unsigned long
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
@@ -8383,12 +8383,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned int order, i;
 	unsigned long pfn;
 	unsigned long flags;
+	unsigned long offlined_pages = 0;
+
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
 			break;
 	if (pfn == end_pfn)
-		return;
+		return offlined_pages;
+
 	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
 	spin_lock_irqsave(&zone->lock, flags);
@@ -8406,12 +8409,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
 			pfn++;
 			SetPageReserved(page);
+			offlined_pages++;
 			continue;
 		}
 
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
+		offlined_pages += 1 << order;
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
@@ -8422,6 +8427,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return offlined_pages;
 }
 #endif
 
-- 
2.13.7

