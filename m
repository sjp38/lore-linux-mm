Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA0E2C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E90421743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:41:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M47wq6oa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E90421743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 209196B0007; Wed,  7 Aug 2019 18:41:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C31A6B0008; Wed,  7 Aug 2019 18:41:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CF066B000A; Wed,  7 Aug 2019 18:41:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA3926B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:41:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id k9so54284500pls.13
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:41:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=gP7k43mJSv5f3YSNOpp9K4LaCXk5lNEqmssvOI0R3mU=;
        b=r1FSD6ZBf+jXf3TIXg2ZvpnheQtZU8mlObQpqcRJL9c6LE4u667ZQkI1A1IrkI2++N
         +EkDaMQjJ/Af2ZJJpc+N2ehzwfWGjD14emCaAb8e58aCFsoxEaizx+i9/kiBAt2QS6Y3
         wAWiYNnMcyTv3rWU703AEVjzN6bcPG43qWFFzOYkmY93fVR8vAdS9VT3M3i3GIskU8mp
         ga6sQlT42FIcCovFUOCHvMBXbUlxTxyedWGciRcbky3kReiXVaLpc2bAaZ1HfrQj6+XC
         KpyvexhV734g5MOgYFWHqlCJ/TUB5NFib7Q4K2LRF0gI9j62Sw+v8YkwUOk8w/QanETG
         DyFw==
X-Gm-Message-State: APjAAAXac5lcmHeAiTZ3q6o9Z20HMT462OuFDrC/1xJq1EOmkRTaNbYc
	Bkqvvc1GiIyb6ytXHzPw9IkZugcFQktIvyN8ebfyQR4d5/0Hn4TQ0JVf2UuBxhR2L+wi6vb24Wt
	BlLtmLxbiiBwaysVAMhlXkrrwI2vCvcpXj8ibbM2zgjyNP68GCVW3KwR/8hp1L1bxkQ==
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr9733234pgd.13.1565217717305;
        Wed, 07 Aug 2019 15:41:57 -0700 (PDT)
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr9733187pgd.13.1565217716080;
        Wed, 07 Aug 2019 15:41:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217716; cv=none;
        d=google.com; s=arc-20160816;
        b=wbyw/SfEcjEWbEowCK6inS6MJEgk9hRvqIjGr90w9eam5aZsbMI28WMr0ebQWXMEfT
         ssZGolxcy53ZJveK+jfKzWYG1sJOjAgeZMU6PYccDuGXitrPVcULD1A+GQ+zaUo+Ot3Q
         aDTujIRLF4oeSbObpQV2DCr8+BxL2PYZTl/MNTffsNOStHdMd5x6a+kFh6cmDN/qjiAP
         Uap9ukOvJYfBD0xHS5CP0dSlHLPNps3G74Kp+FkHVisITUCsFMPpBHUd+Eoy6d/cI3No
         n4soBCa0LgMTunljpJc2HKw+D7j15KoVwwPVQ3njdlSfC7fb1hbOVbhlxuqdOQTQpvCc
         22VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=gP7k43mJSv5f3YSNOpp9K4LaCXk5lNEqmssvOI0R3mU=;
        b=oRA7w9X7+6hLDQot+QlXf1g8lTeNY32A+zRgxCnDuE+nF0NfAEwWEycKLZw3U9psQ4
         P87uJuyD7fz0ogZL9f6filncS62SarjgzvOrbBlrcsZdna+AXpB64Br3AqlmfgZyT+Bv
         a1zFPrHOMhx2if526lNwfxzvdBX0S2S27CH806yiU3md9CMqPYMv22g9yFLf6+5Mh9yW
         l5M0C/s0CJNha7EwlOr/ELl9WW/pYmRGn4+Gy0M/LLR+D43b3WMMKhU9UXjn/W4GkDOb
         +V3QyXprJS+pByv6mGtwlttlnhJIb39bVAioU4FcTThvXiHJK4BoLXu2DEAGT5+7JHfQ
         TWRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M47wq6oa;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6sor44964238pgt.14.2019.08.07.15.41.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:41:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M47wq6oa;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=gP7k43mJSv5f3YSNOpp9K4LaCXk5lNEqmssvOI0R3mU=;
        b=M47wq6oaadwL5mKkByQrptrnOULI9VDmL0/6L+92fOzfVvfitjC/ElFoAnWigW6Tgl
         2BH+ULIYowkwt5Hra57TrApc83fuelgXBZL+tmKfGBj6Y3DLb7RmXg85Th88SRjxi/k6
         TfW4pMsajAECj1ptU2TDe/SNHCHtERvlsBgXaRyx/NIKpv1HlsNIIm8klzHtptg4KiAJ
         jvM5DgvkZSawumIhfZwbBoqk+Z9YLeG36U2JqC4FPSXlD5VjeyMI7yHlnv9J64LCuUO+
         sBW0JPMMK8sjF5cZxgEemkrTFFuMEQENWnSKtZQPgOUbzPCV7zCmtK+6VxwlUyc6tk4A
         Is0g==
X-Google-Smtp-Source: APXvYqw7+iGCoVEpaok0NeV0fhf636bWennC5o7JVfoBsRlCRu3ykru0N0YOA2U0+OillUts6lvxTA==
X-Received: by 2002:a63:3147:: with SMTP id x68mr10013656pgx.212.1565217715594;
        Wed, 07 Aug 2019 15:41:55 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id a6sm209209pjs.31.2019.08.07.15.41.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:41:55 -0700 (PDT)
Subject: [PATCH v4 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:41:54 -0700
Message-ID: <20190807224154.6891.29107.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

In order to support page reporting it will be necessary to store and
retrieve the migratetype of a page. To enable that I am moving the set and
get operations for pcppage_migratetype into the mm/internal.h header so
that they can be used outside of the page_alloc.c file.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/internal.h   |   18 ++++++++++++++++++
 mm/page_alloc.c |   18 ------------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 0d5f720c75ab..e4a1a57bbd40 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -549,6 +549,24 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 	return get_pageblock_migratetype(page) == MIGRATE_HIGHATOMIC;
 }
 
+/*
+ * A cached value of the page's pageblock's migratetype, used when the page is
+ * put on a pcplist. Used to avoid the pageblock migratetype lookup when
+ * freeing from pcplists in most cases, at the cost of possibly becoming stale.
+ * Also the migratetype set in the page does not necessarily match the pcplist
+ * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
+ * other index - this ensures that it will be put on the correct CMA freelist.
+ */
+static inline int get_pcppage_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_pcppage_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
 void setup_zone_pageset(struct zone *zone);
 extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3cb6e7aa296..f04192f5ec3c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -185,24 +185,6 @@ static int __init early_init_on_free(char *buf)
 }
 early_param("init_on_free", early_init_on_free);
 
-/*
- * A cached value of the page's pageblock's migratetype, used when the page is
- * put on a pcplist. Used to avoid the pageblock migratetype lookup when
- * freeing from pcplists in most cases, at the cost of possibly becoming stale.
- * Also the migratetype set in the page does not necessarily match the pcplist
- * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
- * other index - this ensures that it will be put on the correct CMA freelist.
- */
-static inline int get_pcppage_migratetype(struct page *page)
-{
-	return page->index;
-}
-
-static inline void set_pcppage_migratetype(struct page *page, int migratetype)
-{
-	page->index = migratetype;
-}
-
 #ifdef CONFIG_PM_SLEEP
 /*
  * The following functions are used by the suspend/hibernate code to temporarily

