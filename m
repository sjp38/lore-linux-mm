Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39435C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED192146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:24:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED192146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0EF8E0003; Tue, 19 Feb 2019 10:24:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38F038E0002; Tue, 19 Feb 2019 10:24:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27ED48E0003; Tue, 19 Feb 2019 10:24:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C09098E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:24:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i20so825875edv.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:24:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=WiIHODcroN22izO5RjtcWo4Sx9laeX2psmXfDMgWKOQ=;
        b=DVddXf5EGYGrZdAQrzDk9xPuDiaPG3dK+O5AZOvzaKYmJKXjsDK3IOd3mcAQYZYIo9
         jsnY+8F6W5Pz0sNZWlX991VYMyzo5dHGkNdZ5Yfi7UfoFY5M08SzhMRUzC4x0D6VqHFA
         8xa92eCf6OH9yhgobhzS11ptKyowp65uhYUoO9Gk3nmK6mNpozi4lmu+d5isVIf7WIzw
         6+YhLJUmtmFclCYRBJbD0RPkyHPDAWOt5UIXkS43ADAOR7eAxng5suDGT0OCFnlLqODQ
         M3q+9ppXsEJN2gLXZeEp137/sxso/PnfyMm5hFPcCNK2ia9JgTVpoquDVSCz1wBhPdDP
         Od6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAub8u88aWMG6U+5H5X35eFVqcsNIPKjGQ+bph1HuauPEx843XuqJ
	eaIbuCm7Mv2rURXhSUheSrJs2dGvIBE3k7b0JKWdK1zL2AnwbMweIjSi59FsMEBNi3XQQWPf+WP
	sjgHxPSwPOhcsAeBS7B1i6rk2ZqCNgfGpFb2YfseRYnUmeZhEdITF2KaVvygAR7acfA==
X-Received: by 2002:a50:ad4b:: with SMTP id z11mr23284535edc.157.1550589852220;
        Tue, 19 Feb 2019 07:24:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5K2gfkTA+0kgVyBYx53wG7MQsBKQwOXCm1bvFiLQzhsOT5LZLM2zPrN1O30jS/VdroruU
X-Received: by 2002:a50:ad4b:: with SMTP id z11mr23284485edc.157.1550589851149;
        Tue, 19 Feb 2019 07:24:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550589851; cv=none;
        d=google.com; s=arc-20160816;
        b=w8w8+N/AtVtl8KS5k88s2WefPkyITyci3HaRr5mt10+K7nMOJ1PGTXhwPpgRrC7sld
         qw72NjOmPolPI8N8j4HBAyeyqxtFNoH33Df/FGvYYnZ4FSx6Hy4W0s/vpCq/MSkF1Zbq
         Mr9q+7SQ5K9bmu36So+BwCOBVDb2kHcUQvEVljvCg9FIMvb0iJbMByn05FdHDWJhhVCj
         ojHktWKQg8sI+YeacFeq2UpYviGOtpqnDElXtYEM7530ur+YbccpUQwT9Jz0eTuoiRhw
         91Q3rV/2leUbXhRKzU3mXaKq/lPjhHQNONntlKEUxqcj1adtVTiR9aPcUNH9UNQVpk28
         kQHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=WiIHODcroN22izO5RjtcWo4Sx9laeX2psmXfDMgWKOQ=;
        b=02G05p+kgPnGz2I6WcGGzH73dvcHsNDB7pzGRwSo1bxzzjQ+LEo87NJxvEVNSt57Am
         CTMGmpy0eW4142gn39IU6gQzcfahiP6O5nh3At5DClZA/8CctPUx5CfUr8BFnPGvQEx4
         pvSpzI+UU5pCTpgI56oQmDeKccKp75Bl8S8wG6EYtihammrqP6AU5PFXi9wS9wpZMUjN
         Lehe7YnNiLg+7r7iCbrmk5rhc/X9r71wwbeVY/vcxRtj/yOUTevkau/Vcf+3b3qQu5Ns
         ok72ikvqLiR/54hEdahOqZQvcX4Vpn3xq4Q4WOGy7CH5zopa0ZZxWl27VwoD65cAX0Eg
         Onyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x25si7604615edb.0.2019.02.19.07.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:24:11 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5B46DAEB7;
	Tue, 19 Feb 2019 15:24:10 +0000 (UTC)
Subject: Re: [PATCH v10 2/3] mm: Move buddy list manipulations into helpers
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899812264.3165233.5219320056406926223.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <4672701b-6775-6efd-0797-b6242591419e@suse.cz>
Date: Tue, 19 Feb 2019 16:24:09 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <154899812264.3165233.5219320056406926223.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/1/19 6:15 AM, Dan Williams wrote:
> In preparation for runtime randomization of the zone lists, take all
> (well, most of) the list_*() functions in the buddy allocator and put
> them in helper functions. Provide a common control point for injecting
> additional behavior when freeing pages.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Here's another fixlet to fold into mm-move-buddy-list-manipulations-into-helpers.patch
This time not critical.

----8<----
From 05aaff61f62f86e646c4a2581fe2ff63ff66a199 Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Tue, 19 Feb 2019 16:20:33 +0100
Subject: [PATCH] mm: Move buddy list manipulations into helpers-fix2

del_page_from_free_area() migratetype parameter is unused, remove it.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 14 ++++----------
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index da5321c747f8..2fd4247262e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -143,7 +143,7 @@ static inline struct page *get_page_from_free_area(struct free_area *area,
 }
 
 static inline void del_page_from_free_area(struct page *page,
-		struct free_area *area, int migratetype)
+		struct free_area *area)
 {
 	list_del(&page->lru);
 	__ClearPageBuddy(page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 37ed14ad0b59..d2b6d5245568 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -901,8 +901,7 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
 		else
-			del_page_from_free_area(buddy, &zone->free_area[order],
-					migratetype);
+			del_page_from_free_area(buddy, &zone->free_area[order]);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -2173,7 +2172,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
-		del_page_from_free_area(page, area, migratetype);
+		del_page_from_free_area(page, area);
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -3144,7 +3143,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	/* Remove page from free list */
 
-	del_page_from_free_area(page, area, mt);
+	del_page_from_free_area(page, area);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -8507,9 +8506,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
-		struct free_area *area;
-		int mt;
-
 		if (!pfn_valid(pfn)) {
 			pfn++;
 			continue;
@@ -8528,13 +8524,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
-		area = &zone->free_area[order];
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		mt = get_pageblock_migratetype(page);
-		del_page_from_free_area(page, area, mt);
+		del_page_from_free_area(page, &zone->free_area[order]);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
-- 
2.20.1

