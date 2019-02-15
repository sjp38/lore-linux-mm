Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5631C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81A6D2192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="bKmg92sU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81A6D2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06B5B8E0003; Fri, 15 Feb 2019 13:14:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A3B8E0001; Fri, 15 Feb 2019 13:14:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E742E8E0003; Fri, 15 Feb 2019 13:14:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B64D98E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:32 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id b8so6397699ywb.17
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=ob+swExpNm7LoF6qLNWyWo6JURmMckt4VS/AW3Pd3spDexCnPJap3SrS+o0/61OcBd
         qYa8Wa85Bg5YzY2Oui3jU/IaCyoPdmFVAIfHas2wLOpLNb4AZmBZGy27qwCN7t+sh5HE
         wlIqhcPsyHcDgdl3M/CdcdUDWAqd3wWLFwouC9p7bss/rf9hYkvDWNE42I+3U1as/1Z0
         Ebk141mQMXqYnR9XXzki/E+xIKu0QN8ZkMW2zqnBgIqobzIgM+NZHbJtldCztwUebtLR
         1i39Vt1orCcr2vRgQwcbNFjL8kocKze4T5Zrhx1GZGftSuaMDvZ4JNGeWku39zY74l2T
         qXmQ==
X-Gm-Message-State: AHQUAuaezYgmTkZbVoCux07wKEoymOjeLGSl7pF6ZQBH3ovIYcCy+QA6
	Uiw3sduJsDIK3A5hvqR3ESiFAWwuwOI+O+S+l4FBvTugCzjXCvD0tAIGlcBUedKhFmZqwAZFSq8
	Oir7bDhWCCMRJ2OHo4Tw8KthXxJgD55Ogi1snSgLzbIH4SSQia9k7p9/h1Fkg2xA2p4IrGHGfQG
	JVX53SouUkOB0kXp6dzwou+bEM5JOaCoPVQ3J3Vxb8mc/sEluqKrGT5bzpwAVd+eWm5mrkqQP+a
	EH4DGYpfxwSniyivFSexqxBYtgr7+CkDdrhvcp30ZSvAoljHmRnTDrAphsmnGJbKpJ8+xGk3Rzu
	Kk3o7yciQaiq4hmyLVFQL95Ugr4Z3GzPMHzGwLVEDFqxpAo0+o05pZMkwj6LU58FNJCCWQQ1jJr
	2
X-Received: by 2002:a81:5d87:: with SMTP id r129mr8865047ywb.347.1550254472408;
        Fri, 15 Feb 2019 10:14:32 -0800 (PST)
X-Received: by 2002:a81:5d87:: with SMTP id r129mr8864999ywb.347.1550254471687;
        Fri, 15 Feb 2019 10:14:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254471; cv=none;
        d=google.com; s=arc-20160816;
        b=x/cPqwnsOnxHPmBj8Dib2K84GeQmb7o6MOSv2DuQlSWxrLJdIWu9rg0RfjwEYmqZlg
         Q+kkDD8CHpwu0Dec8fcOjxlz7WNOtfYT5ORxsgHnu6ciHa7dE3Yu30UMrXop1hWpk9q8
         5NYYebADvgNZligwPBILf/NqEnRZCSfvlboj8euYnTB3rQAcZmFscHhlxcBW5E3eTG6G
         5jOQiLzEvEdLjfdVVrYu/06OxVAz9yAv3kTnz2Doc3+D2k87u347Wy89LtA+Daemi53O
         HSBoYgURv8J0+aHRBQvekHckYYXX8FO3PqO3djn07oqdGISGlaBJfo4bgeePJxyVCoqC
         bjYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=APrgmDGXa8buFltwDC9Jby+EH98u4gnw5D2VHOw9S7gT9D7TvfXHHeXuRotSQ4aR5R
         5PDZSN+KDG/iFDxDPmUAq/ce0mJ1VcA2O+RKTl4fp1BSDAqMm2QdlqmFTwQd1lpSxiVo
         FxXqyvgvRV2hNyLBi1w0yH4PzbQsm+MEqzNueLsH0pTyIaEuEE3c9ak61M2iTM1D600n
         Oqm0Bq4/GmqFOj2HpxsbdcjtkZ7LVGIiAnesmwkYkhQmyFdHLZtsRzXcKttLIrEU2yeq
         uZGoPJbWGmaHNb4L60JncCpL23VjogogmMigymxxs5UaRzorFSLRBopDlH0eQ8/lr7CG
         f7tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bKmg92sU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h204sor2870722ybh.207.2019.02.15.10.14.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:31 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bKmg92sU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=bKmg92sUiX5H/aar4+WmpOfQmxy/hG1c2YHfPUxNtki4sheyTomFyVrzH9ntdCRAyx
         WMef03M9PiBmcDvaDgiyaJdE3worIGUODUmyeQUiwXDn71kT5mpQ3K+F72km/7vMxHgy
         qyAJdWh9IBCOY7HBWtwuWspK227bmgvl9cvZEw+iU4fXonyASI0DzvnLcU5B1GD8iu3h
         JZfIHl+MyP1yGWCCOHxU3Tfh3CSQNvbxVXxC3+vnDvUWdFnamgPTq9sckkgQalxoa1zn
         9+Ox8YJd/kmPVpOlKAcgEfei6I5y+YerssXk7839LFJ9gDZAAkteIWz8EFKtCe3v+15h
         CBUQ==
X-Google-Smtp-Source: AHgI3IbpwW5Q4dPkw9VzQm4AkpJI/omhQBlFnrFV+tByaOQ7rIM3b+THxwDztmiDkRMQVJE8hFe0rQ==
X-Received: by 2002:a25:6e8b:: with SMTP id j133mr8968247ybc.220.1550254471365;
        Fri, 15 Feb 2019 10:14:31 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id h205sm4730096ywh.85.2019.02.15.10.14.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:30 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 1/6] mm: memcontrol: track LRU counts in the vmstats array
Date: Fri, 15 Feb 2019 13:14:20 -0500
Message-Id: <20190215181425.32624-2-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215181425.32624-1-hannes@cmpxchg.org>
References: <20190215181425.32624-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg code currently maintains private per-zone breakdowns of the
LRU counters. This is necessary for reclaim decisions which are still
zone-based, but there are a variety of users of these counters that
only want the aggregate per-lruvec or per-memcg LRU counts, and they
need to painfully sum up the zone counters on each request for that.

These would be better served using the memcg vmstats arrays, which
track VM statistics at the desired scope already. They just don't have
the LRU counts right now.

So to kick off the conversion, begin tracking LRU counts in those.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm_inline.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 04ec454d44ce..6f2fef7b0784 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -29,7 +29,7 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
-	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
+	__mod_lruvec_state(lruvec, NR_LRU_BASE + lru, nr_pages);
 	__mod_zone_page_state(&pgdat->node_zones[zid],
 				NR_ZONE_LRU_BASE + lru, nr_pages);
 }
-- 
2.20.1

