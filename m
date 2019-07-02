Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2087DC06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC98A2064B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:54:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gQ79Hkh/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC98A2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59DB86B0007; Tue,  2 Jul 2019 09:54:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5277E8E0003; Tue,  2 Jul 2019 09:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A20E8E0001; Tue,  2 Jul 2019 09:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1B226B0007
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 09:54:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so389979pld.15
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 06:54:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=w2BNPQwh7S/nFGeH+ms7w19rWgUYaTkEZzHk2Qdx8+0=;
        b=H9oLUyJWj8uLam6LSXfAWyteLWkBM+NO/rchR5k4TgosjVFHhDn+qhemuGIWQAtLzq
         9WB8ynZ5x0xHMc/zuUKbkdMJHaNYB8F0PB8jwiTG9WUMyTeor6AH/nYsBa0DYQAbjmr5
         G1S3tum9/6xKcRljjUcMOkjhQKSJvFJ0F96A8qtG/hP2G4CnHC7w5qI5wGhwxlU+bq7n
         RSjv2aBy6EYGrcrpF5B8Y7dVGGrFjZzV3bzTe+w6zJknVUFuJ9jSPls4iwozKXT1Y7p6
         XgLl+dSgPnk2Dq08desB4Q9zFFTMsiohuOQVXtsUd2gRnUl89IThTFRQID2B7RxwHoA/
         YSdg==
X-Gm-Message-State: APjAAAXOfb3SRUbCdtzUXEjyg22uPlt+JQc/bcdx2oknQ3jgXL38IZIH
	sZCaAgzPgVweakODZv/11DV1kgh8TT2pSQqHqJmLHkg/AKdJa2n7cZmQmuCzAO63KKa5iPLRCDg
	ZCTZMSTDjWElhBWLXTrPRqFdcrJevBptz8R43UDWwsQKW1iHPoRRdoYrG0KnXEWbtHw==
X-Received: by 2002:a17:90a:35e6:: with SMTP id r93mr5858441pjb.20.1562075641525;
        Tue, 02 Jul 2019 06:54:01 -0700 (PDT)
X-Received: by 2002:a17:90a:35e6:: with SMTP id r93mr5858359pjb.20.1562075640507;
        Tue, 02 Jul 2019 06:54:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562075640; cv=none;
        d=google.com; s=arc-20160816;
        b=TfBhFpT3an6IdCEWbvElKSWqqeZ0DvEmlg0etAATV2r161zKwsHwY7YsT0F37cIxsv
         Nh6IB0S+LFL5CP6QtV2qrkFm2GDNCWqdmv99SAvPgHg4GS1XczcJF3SdqxUFuLb9Nw4H
         DqYeebijEzJpLNr/7onw5VdeAVmyF3es4/JTIpQqN6zeaCscwThIyZlliuxKfI23Q2Rt
         86B0+3pGFmHzds0vv16Y4W/fKIYWKCf+5+dSJ1YRT3GobzwvJ0OXm7SHALNWVFc7oEDt
         8qeqlvdkEmXgSjFbR8X4R+FMP2FX5a4f08PBy4rv5t1b6Hu/gOwsd6UEnBbBExYSbuni
         EbVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=w2BNPQwh7S/nFGeH+ms7w19rWgUYaTkEZzHk2Qdx8+0=;
        b=tOy94QgEV9KgIIZKW/t2cV+MrAs6TM4vOMo1qp0fwW7LwxskzTEQfBENhyxswG39Sx
         WCMOi4RjICsqgBu8CiFO6wQX8JHCtcVal6dqLJkgp0WCFZzMdZOGqpg2NKi9IEz+8q3C
         bTOGhn/OzWI7ryquzDdSu2PslljLKIc8lj9eQe3JwhsRBpRm/ekb2TC+z8ItPVD0zH0k
         JMV7TFwCNds6cxRNu5A0E3pvaH1hBficdNobGqMETOVq7VGZAe6ML2tVNW1qcoZT9MBs
         okUdgIAWlgByMwGLLzQMSinS8nL7bVK3iWYQdkqt0MoVFpD3YnpdJtBYcSgHw/B/CYU3
         VonQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="gQ79Hkh/";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a68sor411471pje.1.2019.07.02.06.54.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 06:54:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="gQ79Hkh/";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=w2BNPQwh7S/nFGeH+ms7w19rWgUYaTkEZzHk2Qdx8+0=;
        b=gQ79Hkh/BFF778AYW0KVlVtHqMRepoo0B1ji+zXqPLbUaZWpmlnMucSvl6y+CN4+3k
         qYx78jLBkZO0JEaaMprEJ34ZMs4EsSKBKI0AMbO7wL7lyagjvRK9q8Py0s2/VagR4jFG
         uTfQ/JTl53KoIzXhnrMcRtOqFVGvd+oyiw2+Ii02zSLeI3H7b8kOom3hSc0SrxA4GsYz
         PZHa2a2uoByUvW/qj5NCw9eO73gC4/kxbxHOvbbkxi9XCqJdpikpXPyQVEl82YRQtVhv
         hDfA4Psa1uJkyAB1VDTPN1+nJD9qT8AkDxucUvAuNQo1ggHgYxR21vKbDpHIPNhbP5Gp
         gZOg==
X-Google-Smtp-Source: APXvYqxthi/Anqcspql3AIVjs7d8XDbWIPItCvqC6SzOFphrFA9bEN6ceq5EwcqWj1z9QjuO5vVWZQ==
X-Received: by 2002:a17:90a:a489:: with SMTP id z9mr5598087pjp.24.1562075640093;
        Tue, 02 Jul 2019 06:54:00 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:782e:f8f0:635f:8a20:82ca:fda3])
        by smtp.gmail.com with ESMTPSA id g66sm7955419pfb.44.2019.07.02.06.53.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 06:53:59 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Qian Cai <cai@lca.pw>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/page_isolate: change the prototype of undo_isolate_page_range()
Date: Tue,  2 Jul 2019 21:53:24 +0800
Message-Id: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

undo_isolate_page_range() never fails, so no need to return value.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Qian Cai <cai@lca.pw>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org
---
 include/linux/page-isolation.h | 2 +-
 mm/page_isolation.c            | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 280ae96..1099c2f 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -50,7 +50,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
  * target range is [start_pfn, end_pfn)
  */
-int
+void
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			unsigned migratetype);
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index e3638a5..89c19c0 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -230,7 +230,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 /*
  * Make isolated pages available again.
  */
-int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
+void undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			    unsigned migratetype)
 {
 	unsigned long pfn;
@@ -247,7 +247,6 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			continue;
 		unset_migratetype_isolate(page, migratetype);
 	}
-	return 0;
 }
 /*
  * Test all pages in the range is free(means isolated) or not.
-- 
2.7.5

