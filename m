Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 144DDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C398720651
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 21:25:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="WetTng58"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C398720651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EF638E0016; Wed, 13 Mar 2019 17:25:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59CFF8E0001; Wed, 13 Mar 2019 17:25:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 465D78E0016; Wed, 13 Mar 2019 17:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2212A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 17:25:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b1so3284965qtk.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:25:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=OucWAD8gEwp6r0i7GUXnLfUiVl1FutMHKz9ApiJmhnw=;
        b=O+Qb1YuP7bGwHVTEaFP8XkfFb6JVf9T2kiZOifEFmbTuOyvEuz1el0XnAgEzBfTTe3
         sVcwXK2SlgOf7tLWaSiDIqIHMTNJ6S1v3wUmjMPfl/JKjbrLEay/W7oCo7nOm2bCAdMN
         h5mPoqBn6NZOXRpLOFwWY1ZQ1ZsXowATRSbEf6CAcDCSDlHq2KqCVkvBUx0aghhMCNO8
         GbFEb/lv0/vvcOJlAMwK6uC99FccvDNJH4jzG1aC8U5knpTW7aNTdv6Wq48regunqzj8
         NuRvG4jb7KTGtYqDa/rp8a9o/Yto+ZWPcM9ysAHlfyMbxBu0LLiRxeaSvTvUXYbfaPNa
         bXig==
X-Gm-Message-State: APjAAAXziBsQ6W7GRLiF/yrQu/uTrgtejS8xP49NuyonllLIjMhV0Alw
	szlnDBC8Bz+V4gQX0qC6/OVMtosrzodULWg/3LPcx7ywVoi7KRGVQQOvZADHIXPdX63RMJbie5g
	5VHGqo5k1FR8Y6Xh+m9bslznEOpfH0MneedbQ6fvq7WM3wOS9DNANUJbb4Fu3Ecuh9u+RovyPTy
	Cn5y246RP5KbthtpgHfzm5kkIwvoo349P8L5KeyGCGq4XXEQIasIshuWkYxLTSfixfepTt7pZIz
	vdIlPacgKwO40uxhCkBKr6A9RTyV6vwyeDzzQ9QNrIbpx74APOn55OdpOUX973LRULQ2NGiLkoA
	6gsfmLxWALJft4AIyq5iqCxfvXiJaqudrxtAQSZ40N97DlnNNULkxjJwhrC4JYwPJ3h6WRsHZ3X
	p
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr1466431qvi.162.1552512323694;
        Wed, 13 Mar 2019 14:25:23 -0700 (PDT)
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr1466382qvi.162.1552512322860;
        Wed, 13 Mar 2019 14:25:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552512322; cv=none;
        d=google.com; s=arc-20160816;
        b=JVCKq0eDMSeohT2wbN0z/1qEtBmeXpno4lIUdp7eM0UrHyW/nV3FrCRhgUH+V8S0WP
         q0CTuTvpBxEzQoshznv/pf6pkTzLlghFaRqibkC96q1x9QKJQMSV/IIQqv5ze1TFLqPD
         U0G+3KYe0ShZP1muWyGbNq8jfkC4+VL4oC1F5jF139siQBg2meCH8nCNf53tW0r3Vl/k
         n5/CWI0NtIcwDIL0jmOlH6KcYD3lKPdvpwJ6XPBZ63ulWab3GtB6+YlCNTrOXCThMEDi
         KYhZJhDW1ZKDee2ZbIfcOZJeVh3kynBz6M8zgJLL9yRzrdmuK6ZTA/cOe62Va/jwjm1a
         qmJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=OucWAD8gEwp6r0i7GUXnLfUiVl1FutMHKz9ApiJmhnw=;
        b=TD+EQQBkptWorC/F+7vKNOQ9TzldyJ6Tlhrz7VWf5+K3+t3XT5muHT7J0CrN/MmZ3r
         rKOJy1dzbjImXWl0g1RD/nUou5KgIF7torvhKJyC+rDbc0gNtDbYgvOB1O0bkb7RgNKL
         2seyr1/V4DrYXTX0GOu3q7FPmuyNKJq1KBkPdveSCkHrRa1t+gc6IXmzdxsJAGsLeVKp
         7mM1L2MOUQEHAdvUmHYRtqbUjOkQuPSclnugtvCTYM6MWrqpsh3127jrhxVN/23FMx4V
         lnEOVGwiTXPnrCWaNTYrtYyv+fiTp6Mwf97QC1HnXx595X8/0FeIeAbcwRXKRvysINbl
         xm2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=WetTng58;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor6915166qkw.115.2019.03.13.14.25.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 14:25:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=WetTng58;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=OucWAD8gEwp6r0i7GUXnLfUiVl1FutMHKz9ApiJmhnw=;
        b=WetTng58/5AC8vNv7/Q3M7nMkYg6b7Xsn5STk7j1JUnYBxffHHSCDVlDJOBWYGi8W2
         Bs2Sx0XNuM/Tv+AQwEluhvZ+98gWrnkF3wphGlR0XIw0x9UawlMn/qiQ9CSIi5OBL7wR
         gm6ACtvpjid/oYG0TWvRdwHijRAmeCupHl4HeAKaSVk+IF6IHNlkyZgkOJgx0DCAIq4s
         gh4ypLihL9IpgaZKg8tzQM0ROrWEG9CJ2nK6T9OcGAY/tdUhAy02hMyxP43yLrVJtAh2
         /jceOF1yKKAlvDE5PICIZtSfMGSkGTnr9NV0zn3366hFRlNFCpRQi1trDDh7ABZNT8lW
         8CAw==
X-Google-Smtp-Source: APXvYqxsLXlrKPQvRjHH3e/SsrDAGZnPjfdFb0me0wrVY9xzhbgomiMmLcdlIM9CjGnc3IwmpOBVdg==
X-Received: by 2002:a05:620a:35e:: with SMTP id t30mr35097254qkm.15.1552512322586;
        Wed, 13 Mar 2019 14:25:22 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id m128sm7470350qkf.53.2019.03.13.14.25.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 14:25:21 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm: fix a wrong flag in set_migratetype_isolate()
Date: Wed, 13 Mar 2019 17:25:07 -0400
Message-Id: <20190313212507.49852-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Due to has_unmovable_pages() takes an incorrect irqsave flag instead of
the isolation flag in set_migratetype_isolate(), it causes issues with
HWPOSION and error reporting where dump_page() is not called when there
is an unmoveable page.

Fixes: d381c54760dc ("mm: only report isolation failures when offlining memory")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/page_isolation.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index bf67b63227ca..0f5c92fdc7f1 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -59,7 +59,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype, flags))
+	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
+				 isol_flags))
 		ret = 0;
 
 	/*
-- 
2.17.2 (Apple Git-113)

