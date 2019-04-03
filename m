Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD37C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:26:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7481D206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:26:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="HKmwFc3+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7481D206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25A9D6B026A; Wed,  3 Apr 2019 11:26:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209346B027A; Wed,  3 Apr 2019 11:26:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1207F6B027B; Wed,  3 Apr 2019 11:26:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC37B6B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:26:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d131so14794028qkc.18
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:26:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id;
        bh=80rRh7RveylpWIj+4mRydt/71aAcd0f+TzLH0nsPFA8=;
        b=kMS9r2rI6y0RqC5q3VhgIG4Rv5GV1CpiJUHnwX25RqGzQiAsYEwOnGAPacMogrMLEA
         6C8Rhv2Xp3UYzeHylz8IcE03iTtWFHiQ92Nb5s+K8vUY0zQKMT97CSLApZX36J84W9YA
         wXTYTQO0TI7y0FH8IZ2gIrJTI1gGWdRyJQr2U8hv48MqhL7O37g7c1dTBqDxS8N/hcmy
         jh23jdLjkSgFAoeBS2uR5Bt2gb89/DdBTCWOC8Dn739o0/s5mAIgMh09rXu6yRgtqWRm
         HC4zTrsaiL3vxLNY4ATsho8Bbd/+UWDch8U7noeBrzMouf9zJYWFJld/qfCQkpb8W2oz
         Gb7A==
X-Gm-Message-State: APjAAAVC5QEjkR2fdmB3oWq9yToNaJJgKFVW/xkIbs2AIqG1dFwuLK2w
	Stcw/JfsYpI4/Uv3YornHsI73y7MX/afsoyzqCgKHrX5qywj0wyQfagQ8Rjwkpg4HavSmisODWn
	ifR/I1vusBB3E+MkWkHHnFGlMtgy3tC60yNOA/DUIfzM3f34Hxpw+wRk8lmYTzVxEiQ==
X-Received: by 2002:ac8:3585:: with SMTP id k5mr471139qtb.55.1554305167694;
        Wed, 03 Apr 2019 08:26:07 -0700 (PDT)
X-Received: by 2002:ac8:3585:: with SMTP id k5mr471061qtb.55.1554305166832;
        Wed, 03 Apr 2019 08:26:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554305166; cv=none;
        d=google.com; s=arc-20160816;
        b=nCrBluNo5TNeQP18jMwvgn7C6gjOZnLCLcPl/hq9AGfNrJsnBCdq0uzZ6GDnBQt3tM
         coBM2bJEexQLc481vimQ2UokCDlIRqorYmv94fknU/Q83cuHiHgcUtmyEit42v8XmXcH
         CSv7wVxGlvoJM64H0gSEPSRGv9djg803J981w+5foVQk22RavErz2+e+nytwznegwgfk
         mM64YhE6q9LMo6H8dDcHYBqZwYghtOr3o3MZirHJPu1e3YBXGzuS7V/BqWrdLwze3Epv
         9+BiogzVdkzETzPn4+2Qe4KJDsri7ijpgryAl0aKcGP3cdzKRLEoQVNMxfZPZ9g3rGFs
         LBZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from:dkim-signature;
        bh=80rRh7RveylpWIj+4mRydt/71aAcd0f+TzLH0nsPFA8=;
        b=h9QxiEU9dUkEJtL5tVPgPLiIye7l8FvUvT5cfxZfBVvWpq0sAUmypsUEghbj4wGBxF
         ulB0+/7vQcB0r7cHFnizvoiHsFV2TcHPnj1EL6JEpp+LZ2XbaU4h9W89sKdp5XHdhDLl
         pqjlAcsVYxbmtAdMWKwFrnLt4Dg2rILdv2enes0wE0bTIoJBYHjZe8CfGxzGHCRdLNOy
         BaULRr50GAN2BRZMPO6qyC5sKUGcgy72U9oMkAZxC9WyzPqUfPd0wYhNCzBWs1Dfm5AT
         aJRsZEjPHpNs2GaW65SkBLZbWPbHXnkkMQKrHSVcVsXtLiEmJMf4TKWbowb04cobhLMY
         0Egg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=HKmwFc3+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor22780238qtb.45.2019.04.03.08.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 08:26:06 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=HKmwFc3+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=from:to:subject:date:message-id;
        bh=80rRh7RveylpWIj+4mRydt/71aAcd0f+TzLH0nsPFA8=;
        b=HKmwFc3+qTx5+TUjurNFpUetUu4Ie6IH+IqnkXfiL5UMEj+oARQJCM7w4h5WD7NvM7
         M5YYJtoq6dBfA0JdK4+SEiMCpEQem9mXTw6t5anneXD3r75ZbdJuZeJrLHYqqyvn0mjj
         EFDq8ZedIriNZuQT2DnTqxvZEwvgJLNcQD6luj4r33AwDQf/lhxA7NrIOBPQ4tqJhdfP
         9AA2pcKXTWn+zQQwUDGoRIEkTIX0RptP8aQavaaAdMVVVpAbT56+PU2hWGxPo56th7b6
         NPyfNF/zxBQ0w1fbm/W8CggZ6ndRdy+08SRRP48th4yRDJroTQUcgP4m+9WgdKDw68QP
         YEpw==
X-Google-Smtp-Source: APXvYqz76JDs8Pq1AXLQOSPj523EJxiOcVx729Q9PxMBJoif48q8FHZqxFqplyffg3z9uYI+G9Nt9w==
X-Received: by 2002:aed:3f49:: with SMTP id q9mr442590qtf.279.1554305166024;
        Wed, 03 Apr 2019 08:26:06 -0700 (PDT)
Received: from localhost ([107.15.81.208])
        by smtp.gmail.com with ESMTPSA id p46sm10361482qtc.41.2019.04.03.08.26.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 08:26:05 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
To: akpm@linux-foundation.org,
	kernel-team@fb.com,
	linux-mm@kvack.org
Subject: [PATCH] mm: enable error injection at add_to_page_cache
Date: Wed,  3 Apr 2019 11:26:04 -0400
Message-Id: <20190403152604.14008-1-josef@toxicpanda.com>
X-Mailer: git-send-email 2.14.3
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003264, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently I messed up the error handling in filemap_fault() because of an
unexpected ENOMEM (related to cgroup memory limits) in
add_to_page_cache.  Enable error injection at this point so I can add a
testcase to xfstests to verify I don't mess this up again.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 4157f858a9c6..a0fe0ce7a0df 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -882,6 +882,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	put_page(page);
 	return xas_error(&xas);
 }
+ALLOW_ERROR_INJECTION(__add_to_page_cache_locked, ERRNO);
 
 /**
  * add_to_page_cache_locked - add a locked page to the pagecache
-- 
2.14.3

