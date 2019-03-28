Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5BEFC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91356217D7
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91356217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9E5E6B0006; Thu, 28 Mar 2019 09:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4DB26B0007; Thu, 28 Mar 2019 09:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C85B6B0008; Thu, 28 Mar 2019 09:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2F06B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:44:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f11so4868753edq.18
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XODt1qR1GPIXDsOImWFqchXZf32Hc7y493iTY2DeLnY=;
        b=iPYfh222EV1NWNqG4gvRfmAK+Od9nXW2VB7mIdSn1wEVdBEvok6JGxmJUcD8WucdsW
         GfCm2Rof+va6v8UrFI+TyCxinqYky2JjaUNz1LFNq9ghgh5q4yOVI7yKoTzz49433pq3
         0ON+DJquG5XClrfxlGOGilORMq360Y34IplkNOZQJaznbjcv0lAS8u+neNJD25o0J1yA
         pokq4NBXBSgtNsEvpENNuTXe/g9mUCJVZxDIGumTOh0Av9daZtL6xPO0o/oBSLPb6KOl
         syDkXXI3zOkSOA8TJTnldNjFeBNmqQiJhUHVVh4LSENzNuKiZf2WPhb1ntHPDH/dnSZx
         CshA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXVpiED+MMRh4kGQO6VLHQRkkNkZ5CUV1dLO4NcCS2E13mOb4MS
	AMEw9O3t4u6qdMkuoTAsciewrmLV4XUUaKHb1/LAlenhE7IMSsvlE7qNYnu66IFGXpWRHMw6Fn9
	j88Tmx4LUlSaAhqvP/yHlbkeND1QH1h8xg0rL/YNh9RPlmWUFDRMxxxLNMzEK6Chwjg==
X-Received: by 2002:aa7:c6cf:: with SMTP id b15mr28056734eds.46.1553780643713;
        Thu, 28 Mar 2019 06:44:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwruMQbHe/0h3n4SKb1mhLy6Uyv/o1lLT3/s8ly+FW/czXdAWQMgv8IiG5gdM2Hwm3sdRM4
X-Received: by 2002:aa7:c6cf:: with SMTP id b15mr28056678eds.46.1553780642709;
        Thu, 28 Mar 2019 06:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780642; cv=none;
        d=google.com; s=arc-20160816;
        b=snYwMvucaTgDPDAsQOoDnoLmZKVNN0HHwSZsQz1L8cUf6Ze11XodDGb3jVQhZs+Wo1
         JPEbY8po1xKkMf/JwxxC3lmslEYwc1S3Bs4OrmxnMVWSRe1tNpPUTHdq9kg+5yDLTZ2g
         MUPqp0X1LmjZloz43pSOtH1Fp+YKeymq9u1tdwyvC+yE8i4tuuzlGbpspCx0IO4GQnSz
         y4SGT+ZJz6WgQUb20Regn/ichv79sIlQXVBVQ9mzI9HdAZ54xzhOr3XHZk3ZTIzUye9d
         SkXlEqb69MYEh0qzZr/BHe5nzVUhzySZP/l8XSt5dwXXOHDYOQVhQF30vU1Uyw0qFu87
         UNvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XODt1qR1GPIXDsOImWFqchXZf32Hc7y493iTY2DeLnY=;
        b=XqUWlDpCPZpIzkgXnP5H5VkfIsiT/rH4tzr2XzLXs7uspg4AEt1mqGaq2DeRGkWWjU
         TVK/wsgivrtOYULRQ1GXg6aH/IFer4BCzTCvG+YlSP4SmSXvRGmdyP6oOijI+pJqPHj6
         t9O7Oy+NiFSbWIdV/iHVm3Eh003hkTXkVMyWPovTFIdKn+eI2YUxUXDU9ioSSueSVhZc
         Bi+P3iLfiWLb1a9DEtknQHaQlqlO/R30tzrkhIzbccp5U7yqlsx0xLwI3ImdFIn4clKO
         4ejwRvZ+lpoauy8L8PZ7gG40mG0r22lufxhYDixApxuFLG3SSAgoNzXDprzpwNt+ZUx4
         JRoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id h26si227035ede.241.2019.03.28.06.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 28 Mar 2019 14:44:01 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 28 Mar 2019 13:43:30 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 1/4] mm, memory_hotplug: cleanup memory offline path
Date: Thu, 28 Mar 2019 14:43:17 +0100
Message-Id: <20190328134320.13232-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
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
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 45 +++++++++++-------------------------------
 mm/page_alloc.c                | 11 +++++++++--
 3 files changed, 21 insertions(+), 37 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8ade08c50d26..42ba7199f701 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -87,7 +87,7 @@ extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 extern int online_pages(unsigned long, unsigned long, int);
 extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long *valid_start, unsigned long *valid_end);
-extern void __offline_isolated_pages(unsigned long, unsigned long);
+extern unsigned long __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page, unsigned int order);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0082d699be94..5139b3bfd8b0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1453,17 +1453,12 @@ static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
 			void *data)
 {
-	__offline_isolated_pages(start, start + nr_pages);
+	unsigned long offlined_pages;
+	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
+	*(unsigned long *)data += offlined_pages;
 	return 0;
 }
 
-static void
-offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
-{
-	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
-				offline_isolated_pages_cb);
-}
-
 /*
  * Check all pages in range, recoreded as memory resource, are isolated.
  */
@@ -1471,26 +1466,7 @@ static int
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
@@ -1575,7 +1551,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn)
 {
 	unsigned long pfn, nr_pages;
-	long offlined_pages;
+	unsigned long offlined_pages = 0;
 	int ret, node, nr_isolate_pageblock;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
@@ -1651,14 +1627,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
index d96ca5bc555b..d128f53888b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8374,7 +8374,7 @@ void zone_pcp_reset(struct zone *zone)
  * All pages in the range must be in a single zone and isolated
  * before calling this.
  */
-void
+unsigned long
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
@@ -8382,12 +8382,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -8405,12 +8408,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -8423,6 +8428,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return offlined_pages;
 }
 #endif
 
-- 
2.13.7

