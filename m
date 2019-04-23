Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 007F4C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B122C218D3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:44:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="h2ZSmpkO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B122C218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C1216B0007; Tue, 23 Apr 2019 11:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4473F6B0008; Tue, 23 Apr 2019 11:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EAF46B000A; Tue, 23 Apr 2019 11:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF606B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:44:10 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id s7so291120uaq.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:44:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=JXAocCnPjSxHxOedcbkgNjrO0QCzgS2wvknDYgoZYBE=;
        b=XcLG6fBkMKKY6dW2m0zq3/381KxYBgKThK3hUZUhxlelo5tbOKSm7XQeyRDcnI9CT6
         HmYJhIm2c9W3rxVUmkwFYX0Bt7IvFww5/j9uyYpYiwVXC0Cj+6ORq+ZFeOTnF8S9V2JS
         H8yNxEspa9GTu8/L6wRVwANiyxgLIwXl0RPBhvJTLGfm/Qx/aeD97CPSuWhrc1OOB0JS
         hVxgiome6tV9XlZtMltdw00YhvsDTJl3YQUbpuompVSsO/BQxZA2Vhelud5R1s2bOMrP
         XDUDpqd1LLYVhN3s9DBfo4/r1d7N/f9Xt3ts4LocqNXL54dLu3J1qy6QME5w84ybZ67q
         dyag==
X-Gm-Message-State: APjAAAVq9hYmteu5Hunh7WmtELk9YgRP8KY9Y5iqEdFjJTKIIEmYaYnG
	N3WsnN942W/lRHLK159KSULQuEobgS4gDkBl0hBcD8jICQcJGp8WL0yyJfih/QadRTsbmahQIV+
	JF12SDcGZn7WZhRkA3t+zoldGF2SkJng7WfcmwI0ILtpa6KozehpcLigQ2BwhVA22Zw==
X-Received: by 2002:ab0:2a4a:: with SMTP id p10mr13140978uar.90.1556034249959;
        Tue, 23 Apr 2019 08:44:09 -0700 (PDT)
X-Received: by 2002:ab0:2a4a:: with SMTP id p10mr13140935uar.90.1556034249218;
        Tue, 23 Apr 2019 08:44:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556034249; cv=none;
        d=google.com; s=arc-20160816;
        b=VASFx83r8onfvdok28qPq6oIyq4y2kq1t3M46W1l157+FjPoC5wQWPrgAQ+lSeI/8v
         AQvNqIc2D+XuAWkqJvto19ZdKLZyWZ0G+N0iwf2WZc/vbTjE0SxwbdRjHM0H1aJGUI/y
         j4y9H0ii2rFeifZUYvNHC6S0fPjQ6s0jObbyVJbbJLJRnqj91ELmzq/mwQPvdEaGkEKY
         bsqk88bWAzhO20nNkrPad1QYgRcEDILhMBfHar20dvrc8EoYulYkS31nvXfzZuL2wNO9
         FU24cOFHdFhuio+E0EfDSPdVpHSXhQog7qCuIVpJasuKJ4O3SPhb7y1iqw9IMD2ELyoo
         0f6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=JXAocCnPjSxHxOedcbkgNjrO0QCzgS2wvknDYgoZYBE=;
        b=LSUd2tl2t0RQJvFbv0zc1d3dT7uO/eUURH5L7rLl9Ik4TDAz6UPMHxB9ak7R4igxfA
         8jrnBkdt33EsMRpXR1uZ8z5KpmzwDJAOsI3eIi4PwnMEDvsz8emHwl6tOnKodxfqbvLj
         s+xOJdtcfm3mGo9XvfLK9AXcLrWQ4dcbw8oOMEsL3/sVl2sUayDDgSA4FQ7skMHvWWj/
         Eu6mC3Y5bsgMLAHhTiQenDjRas4Gc1mg4LZNoo9yIh6YTBl0AhZVIhbwJogfpw9B01Hr
         7bGLpsUkgJtvMb/0tsvijdX+X6xQKUrOgpCBJ/OKkYsskwUTZydDjoIHun6jECvD6OdG
         2z0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h2ZSmpkO;
       spf=pass (google.com: domain of 3ydk_xagkcbcf4x7118y3bb381.zb985ahk-997ixz7.be3@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yDK_XAgKCBcF4x7118y3BB381.zB985AHK-997Ixz7.BE3@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a128sor1802711vkb.28.2019.04.23.08.44.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 08:44:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ydk_xagkcbcf4x7118y3bb381.zb985ahk-997ixz7.be3@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h2ZSmpkO;
       spf=pass (google.com: domain of 3ydk_xagkcbcf4x7118y3bb381.zb985ahk-997ixz7.be3@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yDK_XAgKCBcF4x7118y3BB381.zB985AHK-997Ixz7.BE3@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=JXAocCnPjSxHxOedcbkgNjrO0QCzgS2wvknDYgoZYBE=;
        b=h2ZSmpkO455hJucWi8vU9qqGrVVPIxjVUbprWQF8SrXGeUWYEtdRdUMU8GtXSHDesu
         yBKEsZSWWW2KJtcxcOQGMiSVump33fTuW6/iTofr8qsMKD3wNxUE25Gumttajj4KG6nt
         9i8XUWuswqN5ShRuRQz6rIFE3sx7GDC60GZV9NMtx5fQMnA8vz/KtmmChP7ERyHcNzqa
         3ihRs/qlttIu67hSLzNPEXnIblh4e6kWAIycUk70uQHAQ/3oemiOq/slmLGv+N4ENQw5
         NocVBF4+UQPJd9FaFhrexwBmhkObiXRvEgXQ3A9zGp9ScaVICRETZkPyKx2KJD80gIHr
         jL9w==
X-Google-Smtp-Source: APXvYqz18sYa2y+Uj6M7CjZ+maaEwP+Bpk8TEQBBch1tuP5pwW66oU1p/mRbW6J4jkzvf13B7Us7G2Wc7DAudw==
X-Received: by 2002:a1f:8991:: with SMTP id l139mr13783395vkd.49.1556034248763;
 Tue, 23 Apr 2019 08:44:08 -0700 (PDT)
Date: Tue, 23 Apr 2019 08:44:05 -0700
Message-Id: <20190423154405.259178-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v2] memcg: refill_stock for kmem uncharging too
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 475d0487a2ad ("mm: memcontrol: use per-cpu stocks for socket
memory uncharging") added refill_stock() for skmem uncharging path to
optimize workloads having high network traffic. Do the same for the kmem
uncharging as well. Though we can bypass the refill for the offlined
memcgs but it may impact the performance of network traffic for the
sockets used by other cgroups.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---

Changelog since v1:
- No need to bypass offline memcgs in the refill.

 mm/memcontrol.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2535e54e7989..2713b45ec3f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2768,17 +2768,13 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		page_counter_uncharge(&memcg->kmem, nr_pages);
 
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_memsw_account())
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
 	page->mem_cgroup = NULL;
 
 	/* slab pages do not have PageKmemcg flag set */
 	if (PageKmemcg(page))
 		__ClearPageKmemcg(page);
 
-	css_put_many(&memcg->css, nr_pages);
+	refill_stock(memcg, nr_pages);
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-- 
2.21.0.593.g511ec345e18-goog

