Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB98C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06E652084E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06E652084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 973968E0002; Thu, 20 Jun 2019 12:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9249A8E0001; Thu, 20 Jun 2019 12:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812948E0002; Thu, 20 Jun 2019 12:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47CC28E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:08:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so4891465edr.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:08:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Wj4l7u5/Zr5Kx/uUEp0mWbD594cR9O6KElaUEAz2BSY=;
        b=KFIgMKgoLhaQQjNbzapHQ5ZzqNkcyb/SEMH8f4J/r+ehHotnhZ3HljxOhUCZKoioks
         nfVLqw84TZsjkpoHV4E3MihJtzCG6vjvTgjXJGdO3gUwSoaULn563+31IaxVRyYBKuUJ
         awi4xaCTlkFiO0vnq0VxMfUBz8DJc0DQgVzVynqwq0NvCCdlGW1f0f6ln4pGCZLDcipW
         vQ+61QKPdHY6r3uZ6y/nlkaYtMQFdz4nt9gBiptkzIUcEyf/vsFjdmvKbxeKMCDw/a/c
         2598ByQorGgtb6idtxXOVDZM2lF21vB/YFkVOalozkfGzLHBBp8TiScU8EuC/rz2uk0R
         CUig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAWyujq5z9HY09AjdLuLCrcbXiBITas0kSTio4kRFZHMEVXt9QV7
	OjIz0sa4FvU6VcwYZlbi1QHHkxu5T3oMNs5w/Ae8PLA+NtCj2I4ejgD5r3e0oKrJAapFszaH0tu
	fAOiXMJz1yAAL5UD1tsXVTyA/jKkwQyDzhJAtCk4Fne4zw2JVRFMgrUX+dmq7hkiVqA==
X-Received: by 2002:a17:906:45d7:: with SMTP id z23mr60665389ejq.54.1561046904824;
        Thu, 20 Jun 2019 09:08:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIFZYXFM5jxpKpM12w8FYZpRJsDEFYLu02dwjiwp3ph6dqboBevAvolbRl6e9NawCOcXHb
X-Received: by 2002:a17:906:45d7:: with SMTP id z23mr60665319ejq.54.1561046904040;
        Thu, 20 Jun 2019 09:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561046904; cv=none;
        d=google.com; s=arc-20160816;
        b=N7QWZWy6bAjwK6Pikmik08Xccf1JOlkEf+K0/u9PKTozWQRRf/OYmxk1DRPXuiIEkv
         /D346yk8jF0FjKnsZrZ54FZNBYjiF2zSeeapW1BvKDxtmnVw7skyUrnQSL1WMvGRpslB
         LAZSg/k+FGGwM0BrdR5EoyCH+bF39C3hJPBY0FGuFtaFSvGJPVJSoAYyYEYppppLmJPJ
         v99wjQ5fb7gQgQn4wCfgapnBPhONMzh08aORh71hnE1c/Jrjdmcitgk13qKv0PMqYy1q
         iooPmtdFvLCF3nhAb7hrDe+0o0EYa08AZ8+lfNscGroo8A4MkrxJmdSFT5n2FS493d41
         q4KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Wj4l7u5/Zr5Kx/uUEp0mWbD594cR9O6KElaUEAz2BSY=;
        b=hZAxPMiJT01mzh2F6NHzGjRdL0W8B9i/SHlUi/3BqA4qLwIxCzFhkersVeASKzVwTd
         xlyRWrtJCjfNILL2FZtoErMtUHYpghpKmprNT7R0oyJOjAjSxx3pfzxNyarU4+2BYPLT
         oebvGJ2r5QAqmQDMto00Q0aPeXuu0EfzZd1FlXJ1luzEhFdVUvjhpkoyGUrozE4i750C
         i9jGfgC6k2trMaMByvl6jMW5UBDGf06MOBDcx4zTSnUYEJMkWXS3s5HqtJ3sPnkER8hD
         Y95/vS9N8bFfjfxNpc2keWKWNGlnTHE7OYHCIZEdPXg3kRuxOgnKjWvrhbkchIOdbi3Z
         qVlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si209097edh.167.2019.06.20.09.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:08:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 979FEAF2B;
	Thu, 20 Jun 2019 16:08:23 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: [PATCH] mm: fix regression with deferred struct page init
Date: Thu, 20 Jun 2019 18:08:21 +0200
Message-Id: <20190620160821.4210-1-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
instead of doing larger sections") is causing a regression on some
systems when the kernel is booted as Xen dom0.

The system will just hang in early boot.

Reason is an endless loop in get_page_from_freelist() in case the first
zone looked at has no free memory. deferred_grow_zone() is always
returning true due to the following code snipplet:

  /* If the zone is empty somebody else may have cleared out the zone */
  if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
                                           first_deferred_pfn)) {
          pgdat->first_deferred_pfn = ULONG_MAX;
          pgdat_resize_unlock(pgdat, &flags);
          return true;
  }

This in turn results in the loop as get_page_from_freelist() is
assuming forward progress can be made by doing some more struct page
initialization.

Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Signed-off-by: Juergen Gross <jgross@suse.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..8e3bc949ebcc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1826,7 +1826,8 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 						 first_deferred_pfn)) {
 		pgdat->first_deferred_pfn = ULONG_MAX;
 		pgdat_resize_unlock(pgdat, &flags);
-		return true;
+		/* Retry only once. */
+		return first_deferred_pfn != ULONG_MAX;
 	}
 
 	/*
-- 
2.16.4

