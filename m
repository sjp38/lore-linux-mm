Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E61F6C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D70B241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="jQQKpymP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D70B241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B9696B0270; Mon,  3 Jun 2019 17:08:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 142BC6B0271; Mon,  3 Jun 2019 17:08:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02F156B0272; Mon,  3 Jun 2019 17:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BECD26B0270
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so1262886pfv.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0EoeyvI+6nSZVdPsXoo6A3bLjv7jCmnakg13/Vo0S7g=;
        b=eeEw2RcJHS2e+djt/AFU9JQw3EnH2GUSXUIFCys6HgEOJ8INAOK++77IdgIYBk5MJz
         R7sF+HuBTXVyQSLGStrFG0JlGdWIzKFnzArsJNXKH3onBdTzj5jxUOwX9Sj9DaaLKkVD
         o5eUUSrnJ3nL/T99unU7WiY2M2WgMNHSLPxyNaC7FZACt0xgWD4wPH4FscFxsPPHXOad
         XPHKOHLGwilTMMGggIodQHxcTL6Jz41zGWFKWpzuwsLg1JzkP2D4leBgmm+sMVvUbQjH
         W/uo7L+qCTukSCPiJ837Z567m6DzJS3o/vp3nbOwXo4q+kEdowOLkD01u+plV/hb+1x/
         z7TQ==
X-Gm-Message-State: APjAAAVrp2sr2GLhqhghsxA2Byt27N+x8pT2ewCpXhf2Lgxmn4qaMqRk
	zPFfKH2DpBEoJ/p6kzUveDzkmClVA7rusUB0X/NP6YxTpmmstP1wMjV2L3cXpicO7pc2j1GUmoK
	xpURj1KWOI6/tRUtU012owtjylY2xI7q7liD66JwIK/WA/BSDAhttcKQX7kydzAsVZw==
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr24365621pjq.134.1559596106298;
        Mon, 03 Jun 2019 14:08:26 -0700 (PDT)
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr24365464pjq.134.1559596104842;
        Mon, 03 Jun 2019 14:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596104; cv=none;
        d=google.com; s=arc-20160816;
        b=xwM12bB9+Fxmx9N1tZdclczVxm0nJ/J7OZjS7lmtfKzMNF6vllVUL9uHCVx/MIsTE5
         zaWD3aZN1tqunlQsQR9NTPDFxjUmngmVmuxzmFBx1VSQ7tzrf7Hj9VhPkP3POROftfmq
         6Z4nipdfvvsBITNyURHC3OvupccE6e1Dts5Stb+lGpLUWemxN25ZRaU9wQa5st1ByiKc
         kgAARsq9NcLVOJgQWyMYy6j1RIaIGdE8FlxI6yHYqqHQbAQIQ2uznLImb0iwrXkOG7iL
         GklktQ9NpQvkaDKmhd5HYfrmHC20FR0z2Rql8B2jFQaXiktELPUEMDEjBXsE185f3fdp
         /2FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0EoeyvI+6nSZVdPsXoo6A3bLjv7jCmnakg13/Vo0S7g=;
        b=T0MFE6QsVHxNyHAN03j+LNnQ4ifNRCeFZdJi+DQcqDxmbe8CZpFDGD0WLAw6nGwA0X
         Ixblukq6y7aZDqAnsInn6uuOZ78YnJpz2XRosyMWcLuKYzUDS08zmnynz6GPddfunpBB
         gr83/UHKDEcJuvi5ahWx8ynfMMdmALeDstpstUtgILgBjhyvifQVeQmAAHM5PFKA76G6
         ZShgMTzORzF8Ie8Xfg/1kT35XLoUT0RYVQtyL1wk1/rfgASFWQHSfwkUtrnv5TZCJc9q
         6RDUEWgbE28DKVfBLC3K/qNTjOwpyHpX9QKLME3r/X37Uhy/9AnOtX04rvjWPsMhTVDY
         XLEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jQQKpymP;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor16041698pgs.55.2019.06.03.14.08.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jQQKpymP;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0EoeyvI+6nSZVdPsXoo6A3bLjv7jCmnakg13/Vo0S7g=;
        b=jQQKpymP0x+HXM6AidEDpl+oryXhrFlsULaSJxrk+bRuLIK2zph32NK7fQ9YAJaCBe
         N7+enaR2Vc1oYLo8aptLEfjl+dIsZ+yBuVWMXGIzNgNQI9SdCmD/jLhITwBQ9ehLSkb+
         XEVP/h3PMZVC5vzDLRMA2ctacgD5ioiLhXBcIfjUB5IUWXVcT3hHScDrk9eh/9mNvu5o
         PWXDbM+Um+WQ9hcOjSXq+jo3FDIH6cYOI+MipuzXRWJvoaNI+qxII2acSgoctNl9nHHf
         375AuTgxJjHK4jIuhHyjGLr4uaIo2/oQ034Ox+mp98rzfJnHVOkExpOIKkw9vVPM1s+r
         yyag==
X-Google-Smtp-Source: APXvYqxa0AysWp131gGXPRfGsUoOrmmAU0oaOx10qyqfliSX/gy0fcowTdd1qaAaihU44ugQyNlEYQ==
X-Received: by 2002:a63:a34c:: with SMTP id v12mr30337699pgn.198.1559596104078;
        Mon, 03 Jun 2019 14:08:24 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id n32sm7753279pji.29.2019.06.03.14.08.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 01/11] mm: vmscan: move inactive_list_is_low() swap check to the caller
Date: Mon,  3 Jun 2019 17:07:36 -0400
Message-Id: <20190603210746.15800-2-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603210746.15800-1-hannes@cmpxchg.org>
References: <20190603210746.15800-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

inactive_list_is_low() should be about one thing: checking the ratio
between inactive and active list. Kitchensink checks like the one for
swap space makes the function hard to use and modify its
callsites. Luckly, most callers already have an understanding of the
swap situation, so it's easy to clean up.

get_scan_count() has its own, memcg-aware swap check, and doesn't even
get to the inactive_list_is_low() check on the anon list when there is
no swap space available.

shrink_list() is called on the results of get_scan_count(), so that
check is redundant too.

age_active_anon() has its own totalswap_pages check right before it
checks the list proportions.

The shrink_node_memcg() site is the only one that doesn't do its own
swap check. Add it there.

Then delete the swap check from inactive_list_is_low().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84dcb651d05c..f396424850aa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2165,13 +2165,6 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	unsigned long refaults;
 	unsigned long gb;
 
-	/*
-	 * If we don't have swap space, anonymous page deactivation
-	 * is pointless.
-	 */
-	if (!file && !total_swap_pages)
-		return false;
-
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
@@ -2592,7 +2585,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, sc, true))
+	if (total_swap_pages && inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
-- 
2.21.0

