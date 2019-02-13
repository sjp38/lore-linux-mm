Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01451C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:41:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEE212190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:41:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEE212190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6990D8E0002; Wed, 13 Feb 2019 08:41:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6498B8E0001; Wed, 13 Feb 2019 08:41:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 538788E0002; Wed, 13 Feb 2019 08:41:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 128CD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:41:01 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so1006800edp.22
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:41:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=j2NtpWulAfxY+M1SwtqWw8zv90a2bWWa0qFqTBFmGak=;
        b=cTNar0YIS3r+AdEQAkeg3IcCLu89xI08XwPb0n2DEXb2f2KW9AxuZTgQ8N05+BVuNd
         xOcMOhDtH1/KQvefBdz1YjBYNThT/BeSxfFI5egogkv8daUyNJkjyZ1vHHWq1mvyF7ne
         jSEJDxFTOpZh3/1yYr9iuFSVS67bRzAvrBFZSJR80Zk5tLGE6iq1vLaFse+A6jhhDpBR
         NaRCpoADrdSpwDwCNIcIncpCaVmPNRmAU6i37UAG0CkjPpgyrlaqyHOUTTh1vPXhEJjw
         6IIF2zefOVpGZjICWM6TWwUcSTTOBxnUZBAP9tVnDAvXMeHkeUl7f9gZnGhcCag8qkco
         c5/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAuaQw/cmQBGFFrSbOJgjsTiehTAnSZ8lDyKTzP5hd76zzYyNq5fZ
	pJnwvYM3RrXGLLmgAzw05ZVGQR+xFXicZP8Y1LHxmx8J8G05G+PjshRdUvSp99URdTHCyKu3/tv
	soEHQjvqNNi9FavRmpqk7ZMPszQi5ZDW7tVKMvmmy4Ijcg4Ch377lQ6deCTL4Hh958w==
X-Received: by 2002:aa7:c58c:: with SMTP id g12mr448511edq.226.1550065260548;
        Wed, 13 Feb 2019 05:41:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGrQKyUotx/L3v18wqfFc0bt0FH0oSzhjkTvJZu7wXyNZqBpA/JALcdE+gPrvFv5yA2frN
X-Received: by 2002:aa7:c58c:: with SMTP id g12mr448436edq.226.1550065259140;
        Wed, 13 Feb 2019 05:40:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550065259; cv=none;
        d=google.com; s=arc-20160816;
        b=AE0g/EKurQs5r6Tb2VjXvC32kUYg7ObYHB5sB8oTj3O27ICSlHdtV5vApeiIZyBRZ5
         hVocrMT5vimqYYfIilYCfm/A/TrN0jLJ4ZScEo1r+u4bvc1o/n+Cu/tmlCFunL/D0OYo
         XDuqyhlUs11BxeSbStw19rrc+P0dq/Voq/981UI4P8Q76FFLPkGGtum2/VHNG9Wh+2Gt
         X9wZ+hiWwzN9ToXOtrrOKSe71/O8zkr3CTOrSAJkUVL6Rz4q5l6sJM6UA5MFE7AEOmRV
         3PjGUDaBphOfSyGag1B7LEKXhYCpwuQq3eBml0Qad6BE9QUC38/Cd5K+xWi/BtKwApiL
         zGnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=j2NtpWulAfxY+M1SwtqWw8zv90a2bWWa0qFqTBFmGak=;
        b=sFg+JUjB4o8QZBDqALr9DV2q8ZBEjes5Et81ZRsnNpCiZ5Vz+xmB/ESI2DJqkJ0mQF
         L+iWnRBGLMB1JKBE1t4YFIzUtRv9nZhs1qFVjFITCvPPaHNBX4/itFmoE9iTcUyHEZfo
         Bmk1HXj5QeXRM4jzIAGagqhddmYfrD0XKSTr9SDBi3QuaLi/pH4/eQ24XdVHNUB3QA6Y
         PMq1EHt3O+oM3LnVv00TcD2MLQZgtKVwu6Int7C/X+YpT+jThGZLDsXu99NcQ24iEkIv
         zufcNaraOOuEs0y8Gi5kPKTRux72XhKoetx8b68C1ribAyFt3/ffLPAt1zAfvhwmcCdd
         1Qaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c13si5009915edj.268.2019.02.13.05.40.58
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 05:40:59 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1A6F380D;
	Wed, 13 Feb 2019 05:40:58 -0800 (PST)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 250093F557;
	Wed, 13 Feb 2019 05:40:57 -0800 (PST)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: mhocko@suse.com,
	akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: Fix __dump_page() for poisoned pages
Date: Wed, 13 Feb 2019 13:40:49 +0000
Message-Id: <dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.20.1.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000381, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Evaluating page_mapping() on a poisoned page ends up dereferencing junk
and making PF_POISONED_CHECK() considerably crashier than intended. Fix
that by not inspecting the mapping until we've determined that it's
likely to be valid.

Fixes: 1c6fb1d89e73 ("mm: print more information about mapping in __dump_page")
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 mm/debug.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index 0abb987dad9b..1611cf00a137 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -44,7 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
 
 void __dump_page(struct page *page, const char *reason)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping;
 	bool page_poisoned = PagePoisoned(page);
 	int mapcount;
 
@@ -58,6 +58,8 @@ void __dump_page(struct page *page, const char *reason)
 		goto hex_only;
 	}
 
+	mapping = page_mapping(page);
+
 	/*
 	 * Avoid VM_BUG_ON() in page_mapcount().
 	 * page->_mapcount space in struct page is used by sl[aou]b pages to
-- 
2.20.1.dirty

