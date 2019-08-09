Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83233C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43FDE21743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43FDE21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0876B0008; Fri,  9 Aug 2019 08:57:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6B516B000C; Fri,  9 Aug 2019 08:57:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2F46B000D; Fri,  9 Aug 2019 08:57:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3B96B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:57:42 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e32so88556204qtc.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:57:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=frh1oSFBMCr+fRfy8XmAyLcx1eWf6oWHREcdsvCf+ZI=;
        b=MJgFkaVLt1iQFBZaL+3uX8kweBD3M6fRmvkGzZMjGVRe3Cuw0n2Xfj8NPNjM1nLIBf
         zLUejvgmuOjHUXmBOEu99+z9jKBOLggaiR9y9TCPtcuYlIzryudWDeAoq1emHmPg2jm5
         NyQ2H0w5jvFfbCIfxHz86WJGx5os8aopi24ThmLba6uRlHaB+bVLRIJdagjTOag7n0zb
         wiye3Q0rrngs9bU5D+ZB+HCi0+XyRVjtNxxb1Fs+R6BiBcKmeTrOzO06qoTK9Q/xvXXT
         awehuoKJr534xMCGFu7wxGUST9O2Jmfu3426C9IyE2I0B+o1ndSP4LrV3UtyvFRczyYE
         yKwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV5BMAWfl/QgWudyAFOEWKel8Gghc6yFn3CHCTK2CHs3Pme3KwI
	lmEQKdUN/J2575ERxKq4zMckdLPODn1BBXLldCSvyN5XeZ073twEvnEIDJU/7co+pmWu6Cq1zmJ
	QxSWz/P7IuY+l6TAKvwaOA+Fvvvxv0cF9cgF3B/ovKs2q+lnSnOTxiXtkC0iXbgKpTA==
X-Received: by 2002:a37:9bce:: with SMTP id d197mr6297859qke.230.1565355462219;
        Fri, 09 Aug 2019 05:57:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLDnNXIfUpZArsv8j3bgV5GJ177Y0oETh3o48z7BwgZ77L4ecj8POWWK+p6FuZrcn25eJo
X-Received: by 2002:a37:9bce:: with SMTP id d197mr6297806qke.230.1565355461322;
        Fri, 09 Aug 2019 05:57:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565355461; cv=none;
        d=google.com; s=arc-20160816;
        b=nZJEITHljkucIPRKM+IXR6wNJphpheuRKLdQ6aqNKyhhxliB0HpVBXENRN+IwesNWJ
         jcsXM+Js28bwloKEZpX5oMUhu8OS17YtDdzmsMOaI1lin5wADZxJ4GloYTN4j2UfZOhS
         SMLLAYILVcgniojwkL7BtjIePZ7nh7t0HvWrO44P5GyYEPYF4d0w1m7yCVXp2dD8fmOn
         NoLupax6wGB7Y0Bi3yXDkaW9bOSKjG8fi+ffPa8rhEa/bUasm+SxoO+zkiH4IoOS+VNo
         BCkPmBExKm5CKx5/zyoy+oT0QvFnZWF8WAKKLSjSZGMmXt39R2rpyWpNtIHGlEDVK60J
         2F7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=frh1oSFBMCr+fRfy8XmAyLcx1eWf6oWHREcdsvCf+ZI=;
        b=vhz6j4nvAacSwrVID0RhND/R6Ca9U4b4JYzd17iwP+TsPd24rnUYPHabAo1B/55JYV
         LPl+6jOdKeo0lAM8WL7Hal1ZQE4+klLPPOqSKakMWnsbsB6IA3W6tl5EyxzvHQkFcila
         6Ek+tFCUdR4MbflNWudfJuEHX55BZtd0FG08C1IaCiaqdynqtv+z0ID7OvdM1j/oG/mS
         DD1acEeDO9Megx0aCaWykVUTuMmphpreDTH/6my0RCs5c+eWHNWS4e0TEqwjhKqK5tI7
         JOQH8ytodWAjNKVIjRRIHa6s8xfiwip1TER3a6Tj3DZw4DNuID7MrN+qwJBRlcSeE4k6
         J2nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15si39672259qkg.57.2019.08.09.05.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:57:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 82E5FC0A1971;
	Fri,  9 Aug 2019 12:57:40 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D61EC5D6A0;
	Fri,  9 Aug 2019 12:57:38 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v1 3/4] mm/memory_hotplug: Simplify online_pages_range()
Date: Fri,  9 Aug 2019 14:57:00 +0200
Message-Id: <20190809125701.3316-4-david@redhat.com>
In-Reply-To: <20190809125701.3316-1-david@redhat.com>
References: <20190809125701.3316-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 09 Aug 2019 12:57:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

move_pfn_range_to_zone() will set all pages to PG_reserved via
memmap_init_zone(). The only way a page could no longer be reserved
would be if a MEM_GOING_ONLINE notifier would clear PG_reserved - which
is not done (the online_page callback is used for that purpose by
e.g., Hyper-V instead). walk_system_ram_range() will never call
online_pages_range() with duplicate PFNs, so drop the PageReserved() check.

Simplify the handling, as online_pages always corresponds to nr_pages.
There is no need for online_pages_blocks() anymore.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 42 ++++++++++++++++++------------------------
 1 file changed, 18 insertions(+), 24 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2abd938c8c45..87f85597a19e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -632,37 +632,31 @@ static void generic_online_page(struct page *page, unsigned int order)
 #endif
 }
 
-static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
+static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
+			void *arg)
 {
-	unsigned long end = start + nr_pages;
-	int order, onlined_pages = 0;
+	const unsigned long end_pfn = start_pfn + nr_pages;
+	unsigned long pfn;
+	int order;
 
-	while (start < end) {
-		order = min(MAX_ORDER - 1,
-			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
+	/*
+	 * Online the pages. The callback might decide to keep some pages
+	 * PG_reserved (to add them to the buddy later), but we still account
+	 * them as being online/belonging to this zone ("present").
+	 */
+	for (pfn = start_pfn; pfn < end_pfn; pfn += 1ul << order) {
+		order = min(MAX_ORDER - 1, get_order(PFN_PHYS(end_pfn - pfn)));
 		/* make sure the PFN is aligned and we don't exceed the range */
-		while (!IS_ALIGNED(start, 1ul << order) ||
-		       (1ul << order) > end - start)
+		while (!IS_ALIGNED(start_pfn, 1ul << order) ||
+		       (1ul << order) > end_pfn - pfn)
 			order--;
-		(*online_page_callback)(pfn_to_page(start), order);
-
-		onlined_pages += (1UL << order);
-		start += (1UL << order);
+		(*online_page_callback)(pfn_to_page(pfn), order);
 	}
-	return onlined_pages;
-}
-
-static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
-			void *arg)
-{
-	unsigned long onlined_pages = *(unsigned long *)arg;
-
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
 
-	online_mem_sections(start_pfn, start_pfn + nr_pages);
+	/* mark all involved sections as online */
+	online_mem_sections(start_pfn, end_pfn);
 
-	*(unsigned long *)arg = onlined_pages;
+	*(unsigned long *)arg += nr_pages;
 	return 0;
 }
 
-- 
2.21.0

