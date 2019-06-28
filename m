Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6BA1C46478
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 01:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82EA120665
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 01:55:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DUnVyYNN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82EA120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F22F96B0003; Thu, 27 Jun 2019 21:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED4778E0003; Thu, 27 Jun 2019 21:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9ADA8E0002; Thu, 27 Jun 2019 21:55:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBABF6B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 21:55:25 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p13so5784279ywm.20
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 18:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=u6lsjuf98Kc/AH/lf0BUkh49bExoluT1S4n6ULTuKFE=;
        b=g2NLMC6wjSR/o5nxLWXySPw9BVPbmn5lmBi2LJaoRU4UCeAs62OoKVkzg3ZVd1z8SI
         JthawAdw+wctsAW8HDPAJNQJ6w+KK1705BWaCcHo9al22xvq5+bFWcfgHe/OXh4xhzGR
         O/ef4ZmlCjX0pt2MklkdK+rVlGDta39unl2DXI5xAeWeAv2pgpNU8YUz/CvVyLvRRsEP
         PokDph6nbJWtY8idZweE1mjnl+b0pDGjBxeIVlvA9vcjX9w+dLjMZYPRnkvJtd+0/rUI
         nJeOGlEnNGgQNMsalYJhAq9pA2HfmGNq2gfbtkcuI/c9q+9tyQpAmgcNPJtDKZmmfbuO
         X7tg==
X-Gm-Message-State: APjAAAXun8GCMC9OQpP7HG6Luxxj6403+VtwwR4UzhB1uVz4zxwTR9TC
	SQGPMwfnj4e9mLvuKYYbHq7WcORud4u3uIKZUH3FBjC2Z7mYYJc2WPcu9Xt4hd9jl2lf1bxG306
	wMHoFgO5x1cql85iUcqwdu+x9qbzD4PTphqANeeEs+nmT0Sh+LDTP5rmEqnVM29y6Nw==
X-Received: by 2002:a81:aa50:: with SMTP id z16mr4220734ywk.278.1561686925439;
        Thu, 27 Jun 2019 18:55:25 -0700 (PDT)
X-Received: by 2002:a81:aa50:: with SMTP id z16mr4220724ywk.278.1561686924650;
        Thu, 27 Jun 2019 18:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561686924; cv=none;
        d=google.com; s=arc-20160816;
        b=blERf9X/m/LPxN+Ma8S+HOfyqvbQIkZE5NXrarjqwRUsLKXqLNUjOZEYH94hbKGyaB
         j9/vMhOSS3U7K7D85IpO+BDC1U1hVXDdWm9rMKT5rcvusedb3Ix0QVo76IBWWq/WeXW9
         qaVIDcvWcPIEs4aFFmN3M31m8tpLdROO1lozfZQygvJLKVN8xJ+HbCcSY01UacSf1i7J
         yKZJrXOsq0Kibvcr3G0pnFs+LvgDmfCPo5ImhDaKxi2quklej/l39MgQflCWNCu35L4+
         wEp+Vip4wZPBO67RsPVMNY5/g+5/3emldCB8IccAsmaXGXwjFXtR04aYDhuYkTdMMp1i
         I/WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=u6lsjuf98Kc/AH/lf0BUkh49bExoluT1S4n6ULTuKFE=;
        b=PoYTojN6PdX/Psk4Zi2qzkgQs8JJMuXSoaRVfZzHWwicQ2p7EUwQ2jr0ecpBCJjIoL
         WKMBBV+4jKI8pPgiKdchgf0Rqr8IWdfglfDo/8eAovtSaYkA7IxcGYY+0HYE/JOY/Ee7
         0ULyY37/rj8KlQNQsou6UTJ4c4atWpF28BVIcu6tgHQTUXYxCylNmGsEoe8ofeeoTWsq
         /w31wZ8SyL/Ylo36y/1TkqEFmj6TELsaJJbvJP3uFvLwBYDFezc+LHmvn0WAHUf2VojB
         La7sMy6V1Swa5SUDMWyWmRjNE9MDwaHIinmegnZa1fgvVRTyG/K7HApllnbcuHvewMS5
         DESA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DUnVyYNN;
       spf=pass (google.com: domain of 3jhmvxqgkclcpexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jHMVXQgKCLcpeXhbbiYdlldib.Zljifkru-jjhsXZh.lod@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 17sor322273ybj.160.2019.06.27.18.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 18:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3jhmvxqgkclcpexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DUnVyYNN;
       spf=pass (google.com: domain of 3jhmvxqgkclcpexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jHMVXQgKCLcpeXhbbiYdlldib.Zljifkru-jjhsXZh.lod@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=u6lsjuf98Kc/AH/lf0BUkh49bExoluT1S4n6ULTuKFE=;
        b=DUnVyYNN/gyqqnMjGKvOykd2YEMoFihsuKcNBpRiSYPenqIhA+Elq8/BHiIoW5qUOu
         btbWSyb52Whtu9ZpklkijJ16YRH3rBjx0uHKdwTjCIE1GQe+Lv4KgSZV1bKUBllCZ6aH
         fX2fpeKFG1jVPsbtlsxk1tOly+mFGT1x2b9f2ih+K8so+vZ/hfOD8fSEyJQ1kkNMCeRg
         4+5X6QfBrnXVlL209DLeJGIAF9hIs1bB3G1zPRMNJufafofGAgbgVV1THZnbJsJR8Bl3
         TeUl79Oj8sJ7UoxTAD2/0I7RL3QBFVvZ34CaD0GlgAjgb4QPG8wnM8F4dpvrjZVi5LWC
         4Log==
X-Google-Smtp-Source: APXvYqy7kjsd2xZhLd9HeGYNnKXRtvsGfFIL3x87rWz9m3sV7Arul7UieQMVekqzHVNsha/Z2VCam04Vm5F9eg==
X-Received: by 2002:a5b:8c7:: with SMTP id w7mr4666324ybq.242.1561686924273;
 Thu, 27 Jun 2019 18:55:24 -0700 (PDT)
Date: Thu, 27 Jun 2019 18:55:20 -0700
Message-Id: <20190628015520.13357-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm, vmscan: prevent useless kswapd loops
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Yang Shi <yang.shi@linux.alibaba.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Hillf Danton <hdanton@sina.com>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On production we have noticed hard lockups on large machines running
large jobs due to kswaps hoarding lru lock within isolate_lru_pages when
sc->reclaim_idx is 0 which is a small zone. The lru was couple hundred
GiBs and the condition (page_zonenum(page) > sc->reclaim_idx) in
isolate_lru_pages was basically skipping GiBs of pages while holding the
LRU spinlock with interrupt disabled.

On further inspection, it seems like there are two issues:

1) If the kswapd on the return from balance_pgdat() could not sleep
(maybe all zones are still unbalanced), the classzone_idx is set to 0,
unintentionally, and the whole reclaim cycle of kswapd will try to reclaim
only the lowest and smallest zone while traversing the whole memory.

2) Fundamentally isolate_lru_pages() is really bad when the allocation
has woken kswapd for a smaller zone on a very large machine running very
large jobs. It can hoard the LRU spinlock while skipping over 100s of
GiBs of pages.

This patch only fixes the (1). The (2) needs a more fundamental solution.

Fixes: e716f2eb24de ("mm, vmscan: prevent kswapd sleeping prematurely
due to mismatched classzone_idx")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9e3292ee5c7c..786dacfdfe29 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3908,7 +3908,7 @@ static int kswapd(void *p)
 
 		/* Read the new order and classzone_idx */
 		alloc_order = reclaim_order = pgdat->kswapd_order;
-		classzone_idx = kswapd_classzone_idx(pgdat, 0);
+		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
 		pgdat->kswapd_order = 0;
 		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 
-- 
2.22.0.410.gd8fdbe21b5-goog

