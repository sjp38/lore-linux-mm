Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05AEBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 01:32:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9717B2086A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 01:32:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9717B2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF1CF6B0003; Sun, 17 Mar 2019 21:32:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9F836B0006; Sun, 17 Mar 2019 21:32:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8E306B0007; Sun, 17 Mar 2019 21:32:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 857AD6B0003
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 21:32:40 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n15so7058683wrr.2
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 18:32:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=1WTYt4dPTkRwxWWll69TinsOwSydmqMNMDtERrHMvBQ=;
        b=doOtAdtAGq2BTtQdREQieABkTB+C9syuXmt1IcD8DUIGtLT8U2sHXbtyNoF/GD9QZk
         AYoeXAeSf9b+heeqBm0bBcLgCrN7trM4QgK3p5ZaPI6Op7rVw2Tg4wvtJQODmCe7iJ1x
         zuvoeOxfok9wLPtJvRe0QZo9YTjs757WYB2IzdhoNdq5P2+KhXUSrXO6eLbx2YB/7HpK
         Yh1uxvGc8JDWNHLd5jkskwCbgFpZjMQgm4IRvs0EN3JInuCKuNHAAmsgM+gZotMtlpXA
         RgZNE3AsZ7YfbqQUMbJN5BgxBXiI+yCEHnmgpLcPRO9z0TsyKQtcUepU5QSoPJLAgZLU
         +SmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMWdPY5MKk935LgTSJ9HDKuW5MM9bm1gLBlM7gxS3U8NiYWMjR
	/73q/b//wZ0WyMCM8+MUIqO8TkI6GbqmdHxVT0ObEWiO1lmamcSerLwu2kqu4vNYDN+AaViHOUI
	sxCt3o58cxm0y5NMdQ/u45SkwWWvl/HiYP5yjzz82reLgvYzJvJecjLK2pe1WN+aRcQ==
X-Received: by 2002:a05:6000:1043:: with SMTP id c3mr9629064wrx.291.1552872760009;
        Sun, 17 Mar 2019 18:32:40 -0700 (PDT)
X-Received: by 2002:a05:6000:1043:: with SMTP id c3mr9629042wrx.291.1552872759116;
        Sun, 17 Mar 2019 18:32:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552872759; cv=none;
        d=google.com; s=arc-20160816;
        b=k+JAVblTq8x8AntGuaoPz7fAx6GV0l5wx2GKTzYsmaMb9x6f5QoSQh+eRuJ4q0l616
         UEu/bEZ7s6dAvfnTWsdTookiT3Wgbxi8E4v4+VD0R02jdOOuBPQ3OdRON5cQhCQinUIR
         KqsG4UpjSXZ2MxYDgntiMooUkD+WOfDHmdZ/9S35z8EQQkm25ouaC+GsjeoKZt43JURL
         JG1wfwtelydkBoXa0t5bNkeM/z+UzDxGknuM7Gx17zWvEBadkG4199n3LwJ3f6pshHBX
         ZLXuR7cOoGDhUoqusjPX7GRGaJ0KCb4weEURdcP48jjf+NsYKZFhgMMzq0KmXaVRU/9N
         5OjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=1WTYt4dPTkRwxWWll69TinsOwSydmqMNMDtERrHMvBQ=;
        b=KMuswu0yTtwFzZRBuTyZKVvdpgLyRPzr6HHoiiPUdzX3cK5+kfKUoAoiztoZsaE5JQ
         cZXXmbUbqs55rI2m0FVOcCxbpD45i3dEV6rBJtQ0U1YbkyfTbvpxw9A9AoJube+P9fyk
         D+mKQ9hZaj4jlOWwIHcnjjH2cazwzHTB7BgHxFyKX7Ob5PHDAXv1DCV07xoGbxh6O6lP
         +JUGVfrAcB6E4tcV/LzQAHZJRVdRERZMOnpILnAO7mVQ84PocemCVGlxXHzlUzcHbqcx
         vpqL5rfqPMDWH1iCetRCCdcQNy4I88CImau4JMTm4ZD6WcOYejN09H3YM6fSQyE1Orns
         KCjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t195sor5127042wmt.17.2019.03.17.18.32.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 18:32:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxO0EBmSA3xDKRieOppgau/YUPokXEjSr330SLH6k64U9sud9zqkDJK3lztRCDnS9fL2gmjRw==
X-Received: by 2002:a1c:7519:: with SMTP id o25mr9087100wmc.24.1552872758362;
        Sun, 17 Mar 2019 18:32:38 -0700 (PDT)
Received: from raver.teknoraver.net (net-188-216-58-50.cust.vodafonedsl.it. [188.216.58.50])
        by smtp.gmail.com with ESMTPSA id j1sm8220794wme.4.2019.03.17.18.32.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 18:32:37 -0700 (PDT)
From: Matteo Croce <mcroce@redhat.com>
To: linux-mm@kvack.org
Cc: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Subject: [PATCH] percpu: stop printing kernel addresses
Date: Mon, 18 Mar 2019 02:32:36 +0100
Message-Id: <20190318013236.31755-1-mcroce@redhat.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit ad67b74d2469d9b8 ("printk: hash addresses printed with %p"),
at boot "____ptrval____" is printed instead of actual addresses:

    percpu: Embedded 38 pages/cpu @(____ptrval____) s124376 r0 d31272 u524288

Instead of changing the print to "%px", and leaking kernel addresses,
just remove the print completely, cfr. e.g. commit 071929dbdd865f77
("arm64: Stop printing the virtual memory layout").

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 mm/percpu.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 2e6fc8d552c9..68dd2e7e73b5 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2567,8 +2567,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		ai->groups[group].base_offset = areas[group] - base;
 	}
 
-	pr_info("Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
-		PFN_DOWN(size_sum), base, ai->static_size, ai->reserved_size,
+	pr_info("Embedded %zu pages/cpu s%zu r%zu d%zu u%zu\n",
+		PFN_DOWN(size_sum), ai->static_size, ai->reserved_size,
 		ai->dyn_size, ai->unit_size);
 
 	rc = pcpu_setup_first_chunk(ai, base);
@@ -2692,8 +2692,8 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	}
 
 	/* we're ready, commit */
-	pr_info("%d %s pages/cpu @%p s%zu r%zu d%zu\n",
-		unit_pages, psize_str, vm.addr, ai->static_size,
+	pr_info("%d %s pages/cpu s%zu r%zu d%zu\n",
+		unit_pages, psize_str, ai->static_size,
 		ai->reserved_size, ai->dyn_size);
 
 	rc = pcpu_setup_first_chunk(ai, vm.addr);
-- 
2.20.1

