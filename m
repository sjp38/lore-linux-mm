Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DAB6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B80F1213A2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mZKNr6LS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B80F1213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56DFF8E0004; Wed, 13 Mar 2019 15:11:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F4B38E0001; Wed, 13 Mar 2019 15:11:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BD188E0004; Wed, 13 Mar 2019 15:11:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEB738E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:11:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d128so3286132pgc.8
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6Tag9EqO03KMHYu8p++5IfmVZggsrAI5p9kAMMcr9Ug=;
        b=muAgDaDKcTIVhNVFyrAi9AT+WLz8tLmXCiyyxm2BsF0bwauetvHwMF7WpXKeSzN1oZ
         4RFTEkJ3QcqkzMNTyC7RpvUZXtrzAuNe80S83B2J4SHpxtUOz0lb8G/hNNgbVtBSTvGR
         ncO/iebQQXsmz9mngjuqXjfn93ceTmafpaZAbLJnRX98rpuxH16p83oedP8s9UXgfBRl
         jsjjJBKMEs5F6L0S6zq0EGziI65cSNGSz3QALoSvqEWYIInzip4U5GKBIBChaVOXPswU
         xdnazFcgJy56ud3407TYKLfOW2ApJliboX2Lx8wzfkOdWGTRUG4hNFXITMkuPARCRS/D
         52Bg==
X-Gm-Message-State: APjAAAUYEcuiX75V9D+/hntyHJhXKbX6Q0LZP4AUbY/lsLeyAVcx5v5C
	gNuTJDy6heTaHvOAbPHiZKuxtb57gfFMw1bmdA4Au+eBNlH0CKG8mX5WRm4ZRpS8usDhjxwWJ3D
	Kmi1k7+hm2E8qOtt2l/kNksJzNLaP0IsdqOtRqsguC7CCq5WzVBSbAt3sKB1U6/ssYA==
X-Received: by 2002:a62:54c5:: with SMTP id i188mr44483633pfb.188.1552504300602;
        Wed, 13 Mar 2019 12:11:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgVJDGYB9VhLmq1jlQ/hdAoyTw5Nsy4sfZQVbcw/IWR9cp9Epfy01KOLnHO8a2oViAAHPX
X-Received: by 2002:a62:54c5:: with SMTP id i188mr44483570pfb.188.1552504299819;
        Wed, 13 Mar 2019 12:11:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504299; cv=none;
        d=google.com; s=arc-20160816;
        b=FzkHXvlDU2A9XkEqswn3Q9VuaGpBcLPK/t/Xx+Zept1brLAujQVBt+6zpU7jFcyote
         Qj07iaS1lGqwrxK4LL+1NaXDzg7xxibfu+6uwcaLvKDhkDZdwVmIARkQmRPlwJZWLGDL
         ajbPF6WmOlZRt/OTgvFEQh90/8Px2uZQEPxztdvPne4PzvZpBj+J83UMQUAbMgTfPexy
         46Jk8Q15970Ulbk2OmuaD838TsYU5smmO6jQtTpM5eg2L2Am8+8oSnuQb05Kcg8kT7jk
         jGhfGTta6YsHUaeP6DT7aWeTUBqLwSliMpd3AS1amdof9ukdscwMUTev+0t9txuSSzt1
         hRnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6Tag9EqO03KMHYu8p++5IfmVZggsrAI5p9kAMMcr9Ug=;
        b=w3cH2U+WSQiouMUprr1jSnAUO+th+d4jXHqHIG6JSidRE7MsaEChW8EQjlmHwe+eMJ
         pSl9vYtBFMEZHp5Cjntk7TJX5CTUmfDWpqfSIEghbshUqbqOwH+dATCP1eb2wdKo/ZDC
         4h7b5pSd7Rbpny6SSSG/Yxwq2UKddTt9510sguxGf+nn0l1Lk5vvxMLioPIrrjwZHXrz
         ATSzVT8OrI/vVTuTOIdqaEuIOqtGmSphVbWGmUYTk+rDtbTKt6bPuh1vfzrP9Hz60lyF
         hY+l77wDl9u7cwF/Aq6DLSe/MVjm/8WqplzjXL++RUC7WCH5c7L/LvHT3ZZudjNThgHx
         rPow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mZKNr6LS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f1si11799758pld.87.2019.03.13.12.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:11:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mZKNr6LS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 72385213A2;
	Wed, 13 Mar 2019 19:11:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504299;
	bh=jxkikg5QHx//0IM4ZsTVNLsYhaj12DfblrWwOmRjxp8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=mZKNr6LSCcahl+kNRMGJFPNgnCEjY6H6QB5zTBRhSt0Opp8KoYEjdD/SkRHdOi3Yt
	 5f3J52iaY3jy+7XqJfZwIWGnBJOx2TvMx55sBWeBfdRtXfcaFLFhCDl/nNScB3x4dU
	 0FKlKmCwvlo/inOsAqLjefaENTjFdWwayEuXF3Ao=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 35/60] mm: handle lru_add_drain_all for UP properly
Date: Wed, 13 Mar 2019 15:09:56 -0400
Message-Id: <20190313191021.158171-35-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191021.158171-1-sashal@kernel.org>
References: <20190313191021.158171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit 6ea183d60c469560e7b08a83c9804299e84ec9eb ]

Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a
("cpumask: introduce new API, without changing anything") did not
evaluate the mask argument if NR_CPUS == 1 due to CONFIG_SMP=n,
lru_add_drain_all() is hitting WARN_ON() at __flush_work() added by
commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without
INIT_WORK().") by unconditionally calling flush_work() [1].

Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
implementation.  There is no real need to defer the implementation to
the workqueue as the draining is going to happen on the local cpu.  So
alias lru_add_drain_all to lru_add_drain which does all the necessary
work.

[akpm@linux-foundation.org: fix various build warnings]
[1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
Link: http://lkml.kernel.org/r/20190213124334.GH4525@dhcp22.suse.cz
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Guenter Roeck <linux@roeck-us.net>
Debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/swap.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index aa483719922e..e99ef3dcdfd5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -320,11 +320,6 @@ static inline void activate_page_drain(int cpu)
 {
 }
 
-static bool need_activate_page_drain(int cpu)
-{
-	return false;
-}
-
 void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
@@ -653,13 +648,15 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
+#ifdef CONFIG_SMP
+
+static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
+
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
 }
 
-static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
-
 /*
  * Doesn't need any cpu hotplug locking because we do rely on per-cpu
  * kworkers being shut down before our page_alloc_cpu_dead callback is
@@ -702,6 +699,12 @@ void lru_add_drain_all(void)
 
 	mutex_unlock(&lock);
 }
+#else
+void lru_add_drain_all(void)
+{
+	lru_add_drain();
+}
+#endif
 
 /**
  * release_pages - batched put_page()
-- 
2.19.1

