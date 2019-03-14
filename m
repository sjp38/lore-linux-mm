Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC655C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A561218A3
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:03:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A561218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 180268E0003; Thu, 14 Mar 2019 12:03:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12FB38E0001; Thu, 14 Mar 2019 12:03:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 045C08E0003; Thu, 14 Mar 2019 12:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5FD98E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:03:05 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id b188so5146638qkg.15
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=UKaz6a+wdgUSTWiGbc13c0jwiZBe2ENhLLqdxIE+5Lw=;
        b=YjYWv/akkNujetsFD7ETYV/LCtA+UaZp2fH6PBcmI0o88i2bj3WuQ6ipyjIaKnyI0+
         qLI+sBoP5lBiVydcyhzI+NB74XzP8jon0t6M4yIKFY5zNw1WE2621MdPHPkcMA+4oNHd
         WI0kCSWYT2bCFhchuWBzr+hWO2SmScEMnLDAsjUe0aRXammprHnt6YH6wsImOXsMhn4P
         EVp4wG3CzyDa+jZPTsE7wVe8baITLugqxgcl01HA8W9XEW3v2fm8BnaVhzcPA5alQB0z
         EqvO8e3Frj4D54tVJw8gLstrVGKnO9rgw2hqCL3admeBBuMoEH7G40FRa4EVWbtGxEe9
         I4JQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfNHUUgLPY2rnmW2XAUcrl56AZdHNjZXXocVuv9SjqwCAnyKAk
	F3LRiU5v0SWIULoTergVgN/44XmKmPnv+Sah5qMValtU34WFO4MHewDy6eRiXrvHcwi492o+9wh
	XH0FyGkYpNU5ON83mGwLDqY2W2QXNDux5o17BnNvbWyAr9ySlWgOZPMPNyr8OROrwaw==
X-Received: by 2002:ac8:2269:: with SMTP id p38mr24962158qtp.340.1552579385646;
        Thu, 14 Mar 2019 09:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrHC6WQvGhBH5y1tjRrMPKKk0ZgXOmvs0AofMiVuMAdcvPPBI8f9jo2f5momQnkVXXZhlY
X-Received: by 2002:ac8:2269:: with SMTP id p38mr24962079qtp.340.1552579384592;
        Thu, 14 Mar 2019 09:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579384; cv=none;
        d=google.com; s=arc-20160816;
        b=FOCcwIxEIWFUnrDwTt/raTr3I7ucz5cSkp0tM1cpSGn6FeUKqVjcB+2uv6tnvmr+3/
         JshTrZr4xxpk5nPEyNueW8wILgw/foxe5MSsDJEumtTyEHP7nuaKox1YMDqnDOLnGJK/
         +gvLPrQaygA2SxhU2TELjaKn4GRe0vmGFEckULO2ounTCES1lP71QC3PwtlWH+aZQ1DB
         FhnH117fq29iMPxm7GWGwKAA1JRlr90VFKrwJyfUqQudBVmpGexi5aHBjVZjHlOYNcYs
         /DrAGbskuKjH2xjPW2zKz+1ItksPKGDEP1AhX6CWU110uVLNQlvYaPr6vTT29x1gY/BA
         uVAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=UKaz6a+wdgUSTWiGbc13c0jwiZBe2ENhLLqdxIE+5Lw=;
        b=ehIrtqTDBxZHg5Kxy1gMbgaKlTYG2ropRblBQzvS+rO+Az0mVo3zz3aKX3nD4D6rXA
         nst9qMCDHqVdWFo14YTzjO9yW6BR85Na8CeXkdfMC9rNbKsZ2vglM5AZhNvIxYnxNKkw
         O0owREMaBg1EIYEI1ej/FhMkXTakasjVpVXFMpPO+4QYyjo/EY99u8224nzgczvCq4yc
         zqlSAkK56j6fdU1bQk+bt6dtVi/zaq1oMJdD+2FPJhbKthUyUr4naXvf8MkO6EaQnNjs
         g8IoJUQviHgHK5UwxNX3/m3Suk47I+UI4SBH1ClrjgcmqHoYdjpO7X3EdHatLCCBBkoW
         y4iA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x14si5451156qtf.207.2019.03.14.09.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B4C513082E05;
	Thu, 14 Mar 2019 16:03:03 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-188.ams2.redhat.com [10.36.117.188])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0F7356BF91;
	Thu, 14 Mar 2019 16:02:56 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: xen-devel@lists.xenproject.org
Cc: linux-kernel@vger.kernel.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Julien Grall <julien.grall@arm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Nadav Amit <namit@vmware.com>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	akpm@linux-foundation.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>,
	Jan Beulich <JBeulich@suse.com>,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v2] xen/balloon: Fix mapping PG_offline pages to user space
Date: Thu, 14 Mar 2019 17:02:56 +0100
Message-Id: <20190314160256.21713-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 14 Mar 2019 16:03:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The XEN balloon driver - in contrast to other balloon drivers - allows
to map some inflated pages to user space. Such pages are allocated via
alloc_xenballooned_pages() and freed via free_xenballooned_pages().
The pfn space of these allocated pages is used to map other things
by the hypervisor using hypercalls.

Pages marked with PG_offline must never be mapped to user space (as
this page type uses the mapcount field of struct pages).

So what we can do is, clear/set PG_offline when allocating/freeing an
inflated pages. This way, most inflated pages can be excluded by
dumping tools and the "reused for other purpose" balloon pages are
correctly not marked as PG_offline.

Fixes: 77c4adf6a6df (xen/balloon: mark inflated pages PG_offline)
Reported-by: Julien Grall <julien.grall@arm.com>
Tested-by: Julien Grall <julien.grall@arm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

v1 -> v2:
- Readd the braces dropped by accident :)


 drivers/xen/balloon.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 39b229f9e256..d37dd5bb7a8f 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 	while (pgno < nr_pages) {
 		page = balloon_retrieve(true);
 		if (page) {
+			__ClearPageOffline(page);
 			pages[pgno++] = page;
 #ifdef CONFIG_XEN_HAVE_PVMMU
 			/*
@@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
 	mutex_lock(&balloon_mutex);
 
 	for (i = 0; i < nr_pages; i++) {
-		if (pages[i])
+		if (pages[i]) {
+			__SetPageOffline(pages[i]);
 			balloon_append(pages[i]);
+		}
 	}
 
 	balloon_stats.target_unpopulated -= nr_pages;
-- 
2.17.2

