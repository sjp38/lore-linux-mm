Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0946C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CA4221871
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NTl4XRWo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CA4221871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FB186B000C; Wed, 17 Apr 2019 17:55:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 162EE6B000D; Wed, 17 Apr 2019 17:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2B4A6B000E; Wed, 17 Apr 2019 17:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB4756B000C
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:54:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so15419964pgv.17
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:54:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=VEV3Li/9YuCNqydlSFEjpMflQPrYvqRYXUcLuce7mLrrcU/o7g9zaTqtFz9jxrHm1C
         eJvp9bDx04eHM3W+sfZKr3To6Ly6NGnCrtQc5qdyUQqmezzxvPzSM1JrtSW4WQVonGgk
         2kX6AUxv3aDiE7G/0/2pCaPdvPZDF1bBaVpjt3d41DfefnABxya54XPBt8jVCzdBcgsf
         VzLQXLZe5xAyVa2UzfGpEfXPiyWQSac5wCcPMShUGpYKcjdhwW3xWAPk62cTKTnVFxOP
         V4/HtJu7feCCFgj1YYXkKBEGm59m8inQKVt28f4bKV0nwhU36ayUML4DZ25KuSd48gP3
         vHgQ==
X-Gm-Message-State: APjAAAUFHSFDEfFh6FwnWVMZvS3Gc3xeLz2wkBL0pO5shQ8MWD+o3AJ2
	5vFFvlsoOewk8htM8bSWZfSZwoPg3/LHZdTVAHzmx+Qg7Tx5+EHKlHfWW6w2yS4olDoNmSV92BZ
	u2HijG9y6BNhlD2LHS9exRtagenQfHdmQ5JiQw/QyI/740mpjGzgNJvYpK0IXxZynmw==
X-Received: by 2002:a63:e304:: with SMTP id f4mr80305927pgh.374.1555538099356;
        Wed, 17 Apr 2019 14:54:59 -0700 (PDT)
X-Received: by 2002:a63:e304:: with SMTP id f4mr80305872pgh.374.1555538098078;
        Wed, 17 Apr 2019 14:54:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538098; cv=none;
        d=google.com; s=arc-20160816;
        b=i+5bVRjePCRJFyp++vlpDFstjxV/eDy1IRwhns1isklCE8LSpuyA/2ntRWwpfFvx2V
         U683SCFASqCsyzncfZQ0UNEvYIrc5YyU+Xuotm4rg3iMUu39CofXuwL3JXNfzS0HnTPB
         QercExbpgbIvEgu0Xv72aRI9Jpi4S+Ol13Zep40vLd4wHKteuKuCCRZH3a4iYUQ5egdt
         1OLWC7sBMuKGscB42SVMNSeom7OJ/2yOUYmJgWUs9/892o9qkKywrwWO460p3ojVjlFw
         PguyJ+tGekmNzO6wbpxpFzXNXzHZIf0kxEMWFYRmZUYSVyGjYJB8wHhU50ggnx5D7hY8
         9Fow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=h9U+cXwNvz8v5QQTO/aSA9h98DPM2GmAxLdjcyv19+is7UGQTNGpRyiYl8uiYxb4mJ
         dNes/KTDhJP0BvSMS58pYIJh4RzOQPjWiwbXQ6N8FeVqtEuEJAWkiljJ5xahAznE6FWg
         kVG/gjsJ9r4FGUZW9816T7Zs0JgwcP63SF5Sxii42X08Y2EYMWiP2hBfUfBuvApauVcC
         94JRDMfQDlWQO24DbP/6to9xACmYACGoWo5Wq4wZztiX5wS+Y23yh/hvYD/p+h3Ab79f
         3VzPKVMP+zs7luMjEYKxsl9HRSm2SwzSVkrkYSaxtQ2ldhC7GwbjVw6n2wk+Xc/vIeWp
         A5lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NTl4XRWo;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor50289pgh.26.2019.04.17.14.54.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NTl4XRWo;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=NTl4XRWoAOp1/x1XLk1hvjEAxMAeJ6AzgfrCpOEahhVu5/jEYVGYy9d8pQy0Q15Q5U
         Af+lGn62qofRvBvBdvBMEbsEt60SVxN4kbLUVNa3p4G04O0b3J0+eI/IK/fQuiBqxiS6
         WiuryM9qYvtgVaF+gjTGm1N4hsHjkIoMrNg+aPLTfQz5+EXgGtkXNKvE9FYVv7RBNw+3
         //6RWegxUI3mqwV1pBVcvVWJrvdru3y0dvGNdNFFl8qK0pwHGJLQr9whaDrPGVDFzW8S
         2zjbStnsuX0AEOR3NxF66n1IsvnQg5X6M9nueJXmXqIsgr7PkbG+bqIfS8Q3nPtlQuZA
         XMrA==
X-Google-Smtp-Source: APXvYqxdPynQgSY+DGmrN9sj9aTAAj9DpThBayF5QAZBIIpe/kk5KnHKGpzPxv/HTkfDwV1hWwrARA==
X-Received: by 2002:a63:d713:: with SMTP id d19mr28640839pgg.145.1555538097772;
        Wed, 17 Apr 2019 14:54:57 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:54:57 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 3/5] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Wed, 17 Apr 2019 14:54:32 -0700
Message-Id: <20190417215434.25897-4-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's separate the page counter modification code out of
__memcg_kmem_uncharge() in a way similar to what
__memcg_kmem_charge() and __memcg_kmem_charge_memcg() work.

This will allow to reuse this code later using a new
memcg_kmem_uncharge_memcg() wrapper, which calls
__memcg_kmem_unchare_memcg() if memcg_kmem_enabled()
check is passed.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 10 ++++++++++
 mm/memcontrol.c            | 25 +++++++++++++++++--------
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 36bdfe8e5965..deb209510902 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1298,6 +1298,8 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void __memcg_kmem_uncharge(struct page *page, int order);
 int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			      struct mem_cgroup *memcg);
+void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
+				 unsigned int nr_pages);
 
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
@@ -1339,6 +1341,14 @@ static inline int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp,
 		return __memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	return 0;
 }
+
+static inline void memcg_kmem_uncharge_memcg(struct page *page, int order,
+					     struct mem_cgroup *memcg)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_uncharge_memcg(memcg, 1 << order);
+}
+
 /*
  * helper for accessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 48a8f1c35176..b2c39f187cbb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2750,6 +2750,22 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	css_put(&memcg->css);
 	return ret;
 }
+
+/**
+ * __memcg_kmem_uncharge_memcg: uncharge a kmem page
+ * @memcg: memcg to uncharge
+ * @nr_pages: number of pages to uncharge
+ */
+void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
+				 unsigned int nr_pages)
+{
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		page_counter_uncharge(&memcg->kmem, nr_pages);
+
+	page_counter_uncharge(&memcg->memory, nr_pages);
+	if (do_memsw_account())
+		page_counter_uncharge(&memcg->memsw, nr_pages);
+}
 /**
  * __memcg_kmem_uncharge: uncharge a kmem page
  * @page: page to uncharge
@@ -2764,14 +2780,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
-
-	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
-		page_counter_uncharge(&memcg->kmem, nr_pages);
-
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_memsw_account())
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
+	__memcg_kmem_uncharge_memcg(memcg, nr_pages);
 	page->mem_cgroup = NULL;
 
 	/* slab pages do not have PageKmemcg flag set */
-- 
2.20.1

