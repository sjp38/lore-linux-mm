Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBD1C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A826120857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A826120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4635F6B0010; Tue,  9 Apr 2019 06:02:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 412E66B0266; Tue,  9 Apr 2019 06:02:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A986B0269; Tue,  9 Apr 2019 06:02:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1565C6B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:02:15 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 77so14095804qkd.9
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:02:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=bupoFsCuB4wIEE6yTajOpUXs8f4zPHEQe9ygmCk08zM=;
        b=Pvmre8Q5ZU/v9xeu5c9oBqhVst3canonx8Fj+DgBe2ia2KP3y9quwBLzyr8N9txmjI
         rcFu61QbJBm52ujfCg16VSctQm4adMOTuIgrorIgQh2STxO2wOvikn5qD7RxrXvO1LKw
         yS+fo0vCuRCiuMVAQMTpsXKUhkjyNQIIBqxpa42gne/jjX5Cr1eBtJVraG99VuYW3ave
         IUkaTnEvq1qClcIxb1dzrymxrEkobil1zRN/Y/jK38TBT2si2ZMKRndJjzu4KrCjF5RT
         U3NZEW8Z6eY+OLQmFh8t9uhlMEqsLUvvAyd7Pj7Od0pm+gG/N+oqdavxSL96ttcQQ4Dd
         Xm3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjtQxb27VSOSgPLOaaAR/0tTA8e0YFB7BFj+K5JJSJE+1N59xi
	1sCU7g/x8GI87Ed2cUCVnpKjK1kCdCqgdSu7CFuKBYIji/V0/Ldcn262Z+wTHgDzuZhqA8ZCl53
	ra6SnAEhcPowiz6PQJqPqJ/qTSrrub+YXZu3EVKSSVfZ+ry7s7ySqiWO9uYLo5cfXhg==
X-Received: by 2002:a05:620a:138a:: with SMTP id k10mr28236813qki.188.1554804134814;
        Tue, 09 Apr 2019 03:02:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxR1AnCIFKshCN+G3YM0Yw6TgWh3IM5LEllVHRe9+C8RTRvorEmFA/9/IbdAjy7bseoFMCi
X-Received: by 2002:a05:620a:138a:: with SMTP id k10mr28236725qki.188.1554804133860;
        Tue, 09 Apr 2019 03:02:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554804133; cv=none;
        d=google.com; s=arc-20160816;
        b=dE/zxZ5BWk1ZOjcPXe8fBpg3HibHpchG04usrUO3kmZ3fNGX6nS1DjOY53QmwzgElm
         DmEJJUpaTjeLqinDBQvrRxlQ86Fh7M8UvmESty44JLXRGXUYRith01m0fHN/ae3/nI9g
         CkBiWfFQb0d6ZHWcTwQCKhH/YfgIEAvYuIpRnz8Q7R6YxRwoL4XfsbeUZtlaNQsFJJ1p
         TAFoWXtTpYXIm7PnLwAnJJESAWBYrPn/Rafq14SoLAjWxDn3bVY99mOzT3GklINOyRj2
         uutqHkULtrBoDGGPVjbatCagG60Bx9hq71d3HCuaHLuKwW+LQYOZnBGsWA0gyqAZC1Dd
         A7CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=bupoFsCuB4wIEE6yTajOpUXs8f4zPHEQe9ygmCk08zM=;
        b=xlAdjtbz4fxmvTjmHy9xaAI+2FCrxoJk5IH0DjwpIAPCjN2e5SZ/okpBCMs9PcPzAv
         pr0ALqbVHiR919Oj/VuKYU4+St72uDV8Nq3Z0gu3uveUEH2hi0nl0bmgjOajnxvbqtIt
         +AixRKx14xtp1s9g54ZzQbBV+Qk6RyfRciXIYkMhcyVwR74mzf3zUrzAXCohIpEEfrGw
         vV2lAsWn9VL+kgoHOiRmRoBlMYOQ5GSEkfadOOsR2Vn0kYJU4iA5zMP9twRAIwx9wreH
         7MsrOgM6iR9cZMBwfayF8Ae//hytlUV3mMZRCxU0RdgnnDNwkvGoczl4Jr/1oGqUtja4
         oZ3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t42si3551189qvc.92.2019.04.09.03.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:02:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16EEC3001A68;
	Tue,  9 Apr 2019 10:02:13 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 37FE75D71F;
	Tue,  9 Apr 2019 10:02:07 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 3/4] mm/memory_hotplug: Make __remove_section() never fail
Date: Tue,  9 Apr 2019 12:01:47 +0200
Message-Id: <20190409100148.24703-4-david@redhat.com>
In-Reply-To: <20190409100148.24703-1-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 09 Apr 2019 10:02:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's just warn in case a section is not valid instead of failing to
remove somewhere in the middle of the process, returning an error that
will be mostly ignored by callers.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b0cb05748f99..17a60281c36f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -517,15 +517,15 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset, struct vmem_altmap *altmap)
+static void __remove_section(struct zone *zone, struct mem_section *ms,
+			     unsigned long map_offset,
+			     struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn;
 	int scn_nr;
-	int ret = -EINVAL;
 
-	if (!valid_section(ms))
-		return ret;
+	if (WARN_ON_ONCE(!valid_section(ms)))
+		return;
 
 	unregister_memory_section(ms);
 
@@ -534,7 +534,6 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	__remove_zone(zone, start_pfn);
 
 	sparse_remove_one_section(zone, ms, map_offset, altmap);
-	return 0;
 }
 
 /**
@@ -554,7 +553,7 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 {
 	unsigned long i;
 	unsigned long map_offset = 0;
-	int sections_to_remove, ret = 0;
+	int sections_to_remove;
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
 	if (is_dev_zone(zone)) {
@@ -575,16 +574,13 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
 
 		cond_resched();
-		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
-				altmap);
+		__remove_section(zone, __pfn_to_section(pfn), map_offset,
+				 altmap);
 		map_offset = 0;
-		if (ret)
-			break;
 	}
 
 	set_zone_contiguous(zone);
-
-	return ret;
+	return 0;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-- 
2.17.2

