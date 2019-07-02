Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A78C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:35:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90C28219BE
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:35:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qKiWSMCy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90C28219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B4686B0003; Tue,  2 Jul 2019 19:35:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 065F98E0003; Tue,  2 Jul 2019 19:35:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6FA68E0001; Tue,  2 Jul 2019 19:35:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B02E16B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 19:35:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so245727pfb.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 16:35:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=MklO/nCO3vTONhpU2/Xc+PDQxZ8geoXuw22CpQ4sZO8=;
        b=MYTKkXxUEeyPnsKvymY4kkIPJNHnpCx7OhlmnJHdarM+Qd/nr41TsDEIIgAZ/5lbWH
         ikg9ZG/YbbPBw+KJ+J/qP+HSDvwXK0qsGWCplqIps+OrWvzg9x4jQ0Tsa844A3qYxfSf
         52Y496e6n5iOOPYH5dBPX7EaxnmHkmHn8ZgNQ5WwHRxuO7MI+aZZF6/HIPU+CV5H6sRc
         CxpOZDV7CE8/WyN0NxmDENfgsXS8qLXlOE9YDn38f16oiUWt5+J4f2QyQplz4E2wAYEi
         7g9Nv1xXbHO9Hjk9/cO2zuvmU2Aypkjenragh0MMBWizWhYhgCbA+jmOYCYaEY+wnNTi
         BkhQ==
X-Gm-Message-State: APjAAAVQIgV0Bmfmn+ZEdSa/+ak2IcXg1HtHLS4feIbEVk4sazgajhxf
	L14MYu2oQQd3OK/ML4S6AIEzGbu9hlakpSEOKIr8WNgNloL0wgg708J6/xfdlpJ1U1e9AXgiB9t
	qUoLDjHOxioskIOdyQx1UlzNdtnD96AJlXKvf6sj4UvirEKytKbx3Dd9iuO5I6a5/SQ==
X-Received: by 2002:a63:2985:: with SMTP id p127mr9585088pgp.400.1562110552245;
        Tue, 02 Jul 2019 16:35:52 -0700 (PDT)
X-Received: by 2002:a63:2985:: with SMTP id p127mr9585015pgp.400.1562110550937;
        Tue, 02 Jul 2019 16:35:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562110550; cv=none;
        d=google.com; s=arc-20160816;
        b=b4UJ7OFp/G79xy+3rraVVqvcJTNAG9+wxgQZvx676Cvw62NtgD35cTAxxwvc2Jn79g
         GfPVigKgcGjP6F/ZVNVqXBRqzYQp1kcapAFO716cMnwWrFkf/Y2FbbYAn7F9cJOQ1hjE
         T+YeRC/PygCqGSsIlCfsI0xMtQttNqbrHhz8YwLaCJbfyTt4PabvS5pzpC3j7zbJ+igh
         RtJfcR06X0hLZbRgVZsJitCvNP0B/MzuAGukAqB8t3UGxLkQ57OT9wAMs9m7CKICCc2F
         Rztv2s4cAqKaJgdHUal+6ePfMj8rQhjPQCPD56Yayc2ZfwaIkURDKKe8MxwtnRCEjIBk
         EO/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=MklO/nCO3vTONhpU2/Xc+PDQxZ8geoXuw22CpQ4sZO8=;
        b=ZzAlLlgw/g6VtL8djUODwr5TWm4aPS0TTsYPlzFKHVqUgq1Q4Y7wS5yCwILj4wjS8b
         32iNRa9wWm44xTCO3ulEAhbKdksqwRSQhLdU+daaZSSOlpqWIgPQaAV03jQqT6EZZ3jV
         ITI2L421POah2Xp7bO4j6fzeJFHwdyiwaS5DOBmwpTaIEjb+amRYHxlGXTtmxv6G8PEz
         hsQE4CBzNWQT3WM1YeIXzot+sdl7QWbEzFgjsvYyB3qcjklROSgi7AgBuFhH0WUOyYfZ
         5ugKzjli9JGyqFJyV9a2a0IgQjY5bRuTnv5lQsqFWB0kVqx02pf9IwwOWBDo7szc010t
         0YwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qKiWSMCy;
       spf=pass (google.com: domain of 3vuobxqokcikur04bo7405t11tyr.p1zyv07a-zzx8npx.14t@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VuobXQoKCIkur04Bo7405t11tyr.p1zyv07A-zzx8npx.14t@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f3sor80716pgj.41.2019.07.02.16.35.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 16:35:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vuobxqokcikur04bo7405t11tyr.p1zyv07a-zzx8npx.14t@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qKiWSMCy;
       spf=pass (google.com: domain of 3vuobxqokcikur04bo7405t11tyr.p1zyv07a-zzx8npx.14t@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VuobXQoKCIkur04Bo7405t11tyr.p1zyv07A-zzx8npx.14t@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=MklO/nCO3vTONhpU2/Xc+PDQxZ8geoXuw22CpQ4sZO8=;
        b=qKiWSMCySfNKdrYjXhmrf6cfPbbz+oWEXvqnz1cpm0Z7vknJMNKnxJ+lQlVEm0E3hG
         RB9MJVn2xxeW/3haHy4B43l9sOPJSz9tekq/KPZSWh1be1FAzolI0qebmS2oJK4IXslI
         E1L/+HV1EWoRH9KnyHD4xeVzCWprAVojb7MrOxidOZ8BROzux7QmYFoYmx/+uLK1SX2D
         58G/T2wFKuZgk4DoXdfPCyK4TGp42G+xC48rMy1I7hzqFMoEyzh+cb+CIkDARyYfI1h1
         T5urZELFI4Fv+PnARlvjBvJrNSrFCRqIrsztsO3BARX88+dqkQv2cu5IH+wuoQj1vloo
         wACA==
X-Google-Smtp-Source: APXvYqwxWC5LdWcl2/XKPgh1zut3SpHgJ3FIJ714nB1MgOY6lhh76l/rN5P/M8Kednj/Tx9T/ZAwDQyC84jyWjts
X-Received: by 2002:a65:6106:: with SMTP id z6mr20033643pgu.250.1562110550143;
 Tue, 02 Jul 2019 16:35:50 -0700 (PDT)
Date: Tue,  2 Jul 2019 16:35:38 -0700
Message-Id: <20190702233538.52793-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3] mm/z3fold.c: Lock z3fold page before  __SetPageMovable()
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>, David Rientjes <rientjes@google.com>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Following zsmalloc.c's example we call trylock_page() and unlock_page(). 
Also make z3fold_page_migrate() assert that newpage is passed in locked,
as per the documentation.

Link: http://lkml.kernel.org/r/20190702005122.41036-1-henryburns@google.com
Signed-off-by: Henry Burns <henryburns@google.com>
Suggested-by: Vitaly Wool <vitalywool@gmail.com>
Acked-by: Vitaly Wool <vitalywool@gmail.com>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Xidong Wang <wangxidong_97@163.com>
Cc: Jonathan Adams <jwadams@google.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 Changelog since v2:
 - Removed the WARN_ON entirely, as it is an expected code path.

 Changelog since v1:
 - Added an if statement around WARN_ON(trylock_page(page)) to avoid
   unlocking a page locked by a someone else.

 mm/z3fold.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e174d1549734..eeb3fe7f5ca3 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -918,7 +918,16 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		set_bit(PAGE_HEADLESS, &page->private);
 		goto headless;
 	}
-	__SetPageMovable(page, pool->inode->i_mapping);
+	if (can_sleep) {
+		lock_page(page);
+		__SetPageMovable(page, pool->inode->i_mapping);
+		unlock_page(page);
+	} else {
+		if (!trylock_page(page)) {
+			__SetPageMovable(page, pool->inode->i_mapping);
+			unlock_page(page);
+		}
+	}
 	z3fold_page_lock(zhdr);
 
 found:
@@ -1325,6 +1334,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	zhdr = page_address(page);
 	pool = zhdr_to_pool(zhdr);
-- 
2.22.0.410.gd8fdbe21b5-goog

