Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 943E6C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C3EF20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C3EF20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF156B0005; Thu,  4 Apr 2019 08:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37206B0006; Thu,  4 Apr 2019 08:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B83516B0007; Thu,  4 Apr 2019 08:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5A56B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 08:59:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w27so1369589edb.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 05:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wxYbRha7fGiaGe5fjUZcxZAzaofxtp74t6wVIRrOyaQ=;
        b=e5DrcMGhPw70miLr/8nhKWN09jUxzLfP2ouobZoGcGvQVdrBiskaRLloLeEzXxbXyC
         ekpzpGa/DXBdsT8jurN0KOMvV0gbOONOLGyb5nud2pkYVRuGz9dkeGOOkOzomWia9AXp
         9Cpw+3hL1zpUnhQ3r+dN1vANhMDrKxjWtaFWGSUb+ow7HynPQzdm/lC2VQbU6yhMCqKO
         /k6SH2ut6x9R8jMl5GkoZEu4z7bZNeyo31j2zC/qXA5YbUd3q8drOomXCy6Q9B0iTxAe
         NzCW6ChbcRvQ+LVqLvPQx4rAJ9/L7bvcNjM49tfIAPS/qu+ypSlhyqlfLvUu96h4JGtM
         bC1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX8WRsqrIsg3zFuMybrYiz3pJs8wY0d4TwURjp2lsLX7+tavVNh
	/QiPoGWClw187wwOCghoSAlR89BbzKvb4+PTONBF8xEm6Xu0wge7v0N/kdYVwjmlXzOzlqw6eQB
	92HNJu+aTDbCr0UytErdsRdSwJpaQoNtxKOfbVhybOw5RgvZ3U9j4k6vFWKQIGAQnfw==
X-Received: by 2002:a50:b646:: with SMTP id c6mr3718575ede.150.1554382780854;
        Thu, 04 Apr 2019 05:59:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCiN9YoTIxLOU+SODnzhomUf3MvIU8HMQnu9K01Np8Vss3/dCGC//cj/fGaD07SWi9HsJC
X-Received: by 2002:a50:b646:: with SMTP id c6mr3718492ede.150.1554382779461;
        Thu, 04 Apr 2019 05:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554382779; cv=none;
        d=google.com; s=arc-20160816;
        b=RYDrbeLvVeJ/3N5HLzlrkAKD7HGlXeVl3p8qUbLUVNXA3W2Je0qB6epXC2d6YRe57g
         nFlbQQhqWrJLgyZRwhBreLBK3bN+rE7hEwflhGmA545dPQFOpeW/2sdUwrlmzo9O4RUi
         P0ha7VGPBZH1gCatxeWhLeZ0pl8LCe3ngZ+IOvSdS95tU7jdAD5DITNFwTO9bsylV//L
         Mf2s29Q72PycMzhsvtqN2d7OBDQ6Hhv3ZPyb5F90Q966kVjwJZMeV49L9oZcyreSAiGF
         o+f7GAuXPefUcJhM8PFsKBVTgQpnx1n5R5aT69RK7+zZABcU18sn7uA35JKi7J5oscWS
         H5pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wxYbRha7fGiaGe5fjUZcxZAzaofxtp74t6wVIRrOyaQ=;
        b=WYQdjUd5GEmS/5lr7I3CFVhn55is8KApm0m7IAhtHPLXZOqm7tqV2yZDFy7U7aFdCY
         vtH3wsIsQaNNur53J1GJXQMYcTRv+UbTEF8g1wor2tOubZDdw7SEkqPfm/D+wgpocOAV
         tK6dR3Flqg7wIyDlp8iguntnMdKboEwJGCMWe2yoWluOISYnDDuuTjmqqFanETy5hnyB
         D2oeyuh0MnpQD2F4P0BKTp1Q2KlfmLH64Pt+Nn4cgnAOo3PrBNdnhrew9Y+dhIIGm4ah
         4PMr59XKA0qFkKv8pBux38D0+emZ08xBBez4VvKDBYsyWTlxT7dg4tu16IQLAo3OCsjS
         zbOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id s40si1269027edb.397.2019.04.04.05.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 05:59:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 04 Apr 2019 14:59:38 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 04 Apr 2019 13:59:33 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
Date: Thu,  4 Apr 2019 14:59:15 +0200
Message-Id: <20190404125916.10215-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190404125916.10215-1-osalvador@suse.de>
References: <20190404125916.10215-1-osalvador@suse.de>
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
---
 include/linux/memory_hotplug.h |  3 ++-
 mm/memory_hotplug.c            | 46 +++++++++++-------------------------------
 mm/page_alloc.c                | 11 ++++++++--
 3 files changed, 23 insertions(+), 37 deletions(-)

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
index f206b8b66af1..d8a3e9554aec 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1451,15 +1451,11 @@ static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
 			void *data)
 {
-	__offline_isolated_pages(start, start + nr_pages);
-	return 0;
-}
+	unsigned long offlined_pages;
 
-static void
-offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
-{
-	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
-				offline_isolated_pages_cb);
+	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
+	*(unsigned long *)data += offlined_pages;
+	return 0;
 }
 
 /*
@@ -1469,26 +1465,7 @@ static int
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
@@ -1573,7 +1550,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn)
 {
 	unsigned long pfn, nr_pages;
-	long offlined_pages;
+	unsigned long offlined_pages = 0;
 	int ret, node, nr_isolate_pageblock;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
@@ -1649,14 +1626,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
 			goto failed_removal_isolated;
 		}
 		/* check again */
-		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	} while (offlined_pages < 0);
+		ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
+							check_pages_isolated_cb);
+	} while (ret);
 
-	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-	offline_isolated_pages(start_pfn, end_pfn);
-
+	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
+						offline_isolated_pages_cb);
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

