Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E22F9C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F6AD278A6
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JCa8vrPU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F6AD278A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 458636B0008; Sun,  2 Jun 2019 05:23:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E02E6B000A; Sun,  2 Jun 2019 05:23:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197B06B000C; Sun,  2 Jun 2019 05:23:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4F416B0008
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:23:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so7712625pgs.13
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:23:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=hCkIqt6fexvvpbX1gT743RpZVC43WiYedQGBsBi8Dzm1KgoVR+2mDtvb0op69gh3Ol
         EOlTLSCZCBjgIDDxSwPekP/Axz1tFYcuKclnZj4RtjB8R9qkf3Q4NEFFuJ01Aq1/0u05
         qeildE9u0GBMPTlJlCXpF2xrckKMp/kw1t67/5T399DHjv7rCRBEGjBvOfopkSBREMPc
         RUdlSf+m67ZciowkuEHO5hxmDYlw1E3/s8Tk2TslmGWNdVzMw1ILwUiA93T19AXE+b4G
         HxT+wEcAKjUPfwCCacAPNRGyCjcfx4ZU6G/JFhH/s+xtavcm70Xj40ExdevTFIhDzDLW
         Fkmw==
X-Gm-Message-State: APjAAAU8dqC4ngF0tkxJVe6FCQQ3oRaOQ6wNp9aFMll7o2EDmuP3xmKm
	7A/PDde5JfUfAF+qf0R4gWcxsWtvH55O0fyFGCWTDuPCMnmS07gHbMH3xnpBfGh6s195QUSqDbO
	NFpRWVmzgYG5lfBB9SFMNR0cqP6lU5S1dX33OlvRRkzcNAXeE+QahS9ofDOSSMwuW6w==
X-Received: by 2002:a63:3d89:: with SMTP id k131mr20744065pga.121.1559467408388;
        Sun, 02 Jun 2019 02:23:28 -0700 (PDT)
X-Received: by 2002:a63:3d89:: with SMTP id k131mr20744025pga.121.1559467407222;
        Sun, 02 Jun 2019 02:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559467407; cv=none;
        d=google.com; s=arc-20160816;
        b=Xuyxgu1isbXQyHkd90xzfCAo1AKn9H0lz9sLT5ieC/jv3rQsrKj2VAETzNq6XDmP+z
         71hm7q36B04T1AA+3xOo6gASsuiYozsPa+eKyu+FSaq3nPq4tQ8RApuv/ogOF5/qT9vv
         vgYVRog+JYhi0A/oKMnRv+GDMuzoSWTdmGc6R4Jd4f7Y8ZGyviAhXn/Dh5+PaARNw48P
         Hlo16pP7FsLTt4K8Stjb9ig4xo3QpxdyJDynEr43w2/6qiqzGSwgE+b35foTfN5zxYeu
         nQ78zgubYG9Yl6KZR0u1Vrnxp/LryOmjv/aZjicFr1q4fJaD+EumoZP3XgHYT1BQRn3B
         glsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=h8moMUWBRVlk2OBbkG2LHOmlkDzvpN6YHi/DX7KUejAdLFSPAw5uB+2AvCGPBaA4n3
         lZhXKY3thuSQgPPkq7KZ9OjubA+gHQSqYkfvEHvH83zmwKiU70eDZvzde97BwHpXJN7a
         2Z0ZJEc//Ep2Opjh5g+NTjNS2s/jPIzmZwnJk8tMgMgX6TXqPvXzriwx14qrbUxkFavc
         E3Jd+MomuwEsI1EO5rzlO70J+2aP1Pez2vma85QSfY3TSu14YGgCZ6Kz2pnuv00Is0Gv
         KiibykCIMBhXgGxZV0rTiKLXN81gkzyQM136RWc5pQ1P4BupGThCogrlV4lbyZGerbFA
         X0IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JCa8vrPU;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor9030386pgl.84.2019.06.02.02.23.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 02:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JCa8vrPU;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=JCa8vrPU9ZaSP+d6DhHtJS/xMJbw3LWRN1wlfqqClxCv0kqcH1nayWducq2neQzFA9
         6GxvXtB4xF1G/BNgTBWcyDlGI/SCOHdgvIjE6IPNDciY0wchACd+yXmj2fagWTRq4GYx
         a+Hf+bhMClkF/lydXqvxVcZGOqctV4e3jTfh9bsgUWMTrBlV+vp0QgOkOmCSYFqRIVQz
         GJMaEcoLSuf+ZR+N44ngajYUe3CqgP3rRPGojOKcRkI3Tww41Iwfvyq/Lx5fPZolrdMM
         OkvIT81Dg2TFFlS2ZoNNJoU0lmAW8BEQ8Jd8v5vaPjmAXm70Y30kzq9RJW1P0PfjtUAS
         hlVA==
X-Google-Smtp-Source: APXvYqw1gHKEpelM0277rX1MObYnyaVLeyQXviDqOCMcGV+XM4Nup0wlQgpmbj+SkUQdzl7mhEFgkA==
X-Received: by 2002:a63:91c4:: with SMTP id l187mr73263pge.95.1559467406938;
        Sun, 02 Jun 2019 02:23:26 -0700 (PDT)
Received: from localhost.localhost ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id t124sm11633191pfb.80.2019.06.02.02.23.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:23:26 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v3 2/3] mm/vmscan: change return type of shrink_node() to void
Date: Sun,  2 Jun 2019 17:22:59 +0800
Message-Id: <1559467380-8549-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
References: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As the return value of shrink_node() isn't used by any callsites,
we'd better change the return type of shrink_node() from static inline
to void.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e87..e0c5669 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2657,7 +2657,7 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 		(memcg && memcg_congested(pgdat, memcg));
 }
 
-static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
+static void shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
@@ -2827,8 +2827,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	 */
 	if (reclaimable)
 		pgdat->kswapd_failures = 0;
-
-	return reclaimable;
 }
 
 /*
-- 
1.8.3.1

