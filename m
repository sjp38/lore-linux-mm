Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 977C9C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:53:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49E9720644
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:53:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p5TIJ5f6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49E9720644
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E94166B0005; Thu,  1 Aug 2019 21:53:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E450C6B0006; Thu,  1 Aug 2019 21:53:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6486B0008; Thu,  1 Aug 2019 21:53:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 998A06B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 21:53:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so40718954pla.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 18:53:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=XfqvSMY3vuMJZoSapTzecDIZKe5sCbQNfwsqgd7200k=;
        b=HNLp/BWS3RC/HjhlYIY1H280Cu82bO78VD6rMOutkhOnrQvTDZD60NpF1nU3+KbyzK
         ZzMDX0YtMlHie4sH7a3dU6gN60b+A4GUfrbd1Fug2QiGEv9Km3arpPgc7dN3sxgp/d/6
         uH9A96JynCpxdcq2jvwklVgdJ6TR+PRYjvbWrpF/uJRABV+Ah8d+IZgwhzUr89dzccoJ
         BS+oDC1CKcMGNVHP4G1SKuHdXUviAE3mdKAV3c3gQ11BiVQAt514bNOh60pXCs2L5Ca4
         oq3Qm/stBM4RQaK/okrjx1zG/ySj1pHYtm3EIHBHy7Y5XIoZkvVhpkP5vPliVM65D9RY
         rrJw==
X-Gm-Message-State: APjAAAUmReaYVx7W48NRq4b8RQe41lEVp5/JBDMrGIyZiKQ61Klp0xeT
	NqwWKzOSZOFvu5NwDPuLYIIgpFykhtUJ2pNldHWm1cLUy1K1dDdCbl4y3UQVm/yZizn0pRvG7jN
	yMVdEJ/1iXLfAklBz5x/+z7EnRvuI57eN6On3c+F3NQjeIThWwGQaQA7lwZ0c1nSgOg==
X-Received: by 2002:a63:fe17:: with SMTP id p23mr23722731pgh.103.1564710824018;
        Thu, 01 Aug 2019 18:53:44 -0700 (PDT)
X-Received: by 2002:a63:fe17:: with SMTP id p23mr23722680pgh.103.1564710823051;
        Thu, 01 Aug 2019 18:53:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564710823; cv=none;
        d=google.com; s=arc-20160816;
        b=ZU4H6C+NqQVqO9qtlFZuVFs8qF+KwwrGYcp1HxwyDHodHY02x/B7lSd9v8Ec2PbOQ5
         IyEskwbWq6gC6HIMmCHqVj4dSRSKRGsRY5dBSB0qkiy3uxj6p5ObJPsvyHvRXDPgepYy
         E6DzR2klG0PuZC7l/OIvo1q91Ag/pGZ16TxWGeI/EbpA5SudZ55CtnjEBF2ktZRvhz8G
         8BO9a3Yz+SXs1e3aVP0nlpGWEGdmVC6ldc3EFBYl+2m6Cb2/xkUhHcQK3JU2xxQc8w4A
         CaGlCt5hEZBj/VRZ0PR3MrCS3yA8btLzCvD8I3oovCEwi62RCnR27TnT2oyEemwmMJwS
         MxZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=XfqvSMY3vuMJZoSapTzecDIZKe5sCbQNfwsqgd7200k=;
        b=EiLMltYeFwmXov7YWfGGasl2fTk2/dF5Dnlv7FxcAKNiaKoWNoOKKP0VdrxBmhYR2o
         aC29zJm8iaB4nthAWJHCQMd/5ki42xXl5itEX7SLsUyMztR+30J5IzzNqSneiFOOZ+Nl
         nU4Zrfdb2Ys2A7l+DerQ8YceJEWTaNDjQLlYda+Ndt774YysbzkHUtYINekBKflGcEaf
         86I59f0PfRK5d6BSugg+Ldp9GB0wLzuk7BmPfswhdL3zUPpUNh4ik0rUHN5hXQRL+vBz
         9VuElg1hWHMgTdbS+FbaMOEpob1D+8novEpZpjb/h0VNoaS6Qclah2LDdqioWNlbok8o
         4GNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p5TIJ5f6;
       spf=pass (google.com: domain of 3pzddxqokcni52bfmzifbg4cc492.0ca96bil-aa8jy08.cf4@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pZdDXQoKCNI52BFMzIFBG4CC492.0CA96BIL-AA8Jy08.CF4@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a2sor24220530pgv.3.2019.08.01.18.53.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 18:53:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pzddxqokcni52bfmzifbg4cc492.0ca96bil-aa8jy08.cf4@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p5TIJ5f6;
       spf=pass (google.com: domain of 3pzddxqokcni52bfmzifbg4cc492.0ca96bil-aa8jy08.cf4@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pZdDXQoKCNI52BFMzIFBG4CC492.0CA96BIL-AA8Jy08.CF4@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=XfqvSMY3vuMJZoSapTzecDIZKe5sCbQNfwsqgd7200k=;
        b=p5TIJ5f6MVFBRe3B9FceQm/4gs7Cvl3ZuFMo7cj8iq+4dzU4+OqUArk/lEreUbEL1U
         vrd8AcwS1VpLDTX3G3YZHTJdR1vm3GNllV3bkqUbnShlN0YcdvVRWjoTwckFozilANXm
         GlaMCVLuG+aHCjgQ7b6ydjMzG4m15noAOmkljX9L0K1u9RiRXjh4bvzDJs2o4RHUb+Oe
         cITeM+mkUafwR502ZAbpc+e8q5MU2jox9lwgbYqTBnXcQejQCQAwZgUghfk8PkE9oCGZ
         z5+BGjV+Ofkv3LA0OgmtGG8wWFCs6AIRYjwHDYYW9XIF/HMmNLestOUgLXfEuG0oTZr1
         vGiw==
X-Google-Smtp-Source: APXvYqyzw0qMysn2okVWhtirOPdv/rIXcjqzBGWclCKsHQco/P6X9P2iu4GWpUyUDJWzqjS57gIJJllTBFoWOcPY
X-Received: by 2002:a63:3c5:: with SMTP id 188mr119467762pgd.394.1564710821042;
 Thu, 01 Aug 2019 18:53:41 -0700 (PDT)
Date: Thu,  1 Aug 2019 18:53:32 -0700
In-Reply-To: <20190802015332.229322-1-henryburns@google.com>
Message-Id: <20190802015332.229322-2-henryburns@google.com>
Mime-Version: 1.0
References: <20190802015332.229322-1-henryburns@google.com>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
Subject: [PATCH 2/2] mm/zsmalloc.c: Fix race condition in zs_destroy_pool
From: Henry Burns <henryburns@google.com>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
have no guarantee that migration isn't happening in the background
at that time.

Since migration can't directly free pages, it relies on free_work
being scheduled to free the pages.  But there's nothing preventing an
in-progress migrate from queuing the work *after*
zs_unregister_migration() has called flush_work().  Which would mean
pages still pointing at the inode when we free it.

Since we know at destroy time all objects should be free, no new
migrations can come in (since zs_page_isolate() fails for fully-free
zspages).  This means it is sufficient to track a "# isolated zspages"
count by class, and have the destroy logic ensure all such pages have
drained before proceeding.  Keeping that state under the class
spinlock keeps the logic straightforward.

Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/zsmalloc.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 65 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index efa660a87787..1f16ed4d6a13 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -53,6 +53,7 @@
 #include <linux/zpool.h>
 #include <linux/mount.h>
 #include <linux/migrate.h>
+#include <linux/wait.h>
 #include <linux/pagemap.h>
 #include <linux/fs.h>
 
@@ -206,6 +207,10 @@ struct size_class {
 	int objs_per_zspage;
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
 	int pages_per_zspage;
+#ifdef CONFIG_COMPACTION
+	/* Number of zspages currently isolated by compaction */
+	int isolated;
+#endif
 
 	unsigned int index;
 	struct zs_size_stat stats;
@@ -267,6 +272,8 @@ struct zs_pool {
 #ifdef CONFIG_COMPACTION
 	struct inode *inode;
 	struct work_struct free_work;
+	/* A workqueue for when migration races with async_free_zspage() */
+	struct wait_queue_head migration_wait;
 #endif
 };
 
@@ -1917,6 +1924,21 @@ static void putback_zspage_deferred(struct zs_pool *pool,
 
 }
 
+static inline void zs_class_dec_isolated(struct zs_pool *pool,
+					 struct size_class *class)
+{
+	assert_spin_locked(&class->lock);
+	VM_BUG_ON(class->isolated <= 0);
+	class->isolated--;
+	/*
+	 * There's no possibility of racing, since wait_for_isolated_drain()
+	 * checks the isolated count under &class->lock after enqueuing
+	 * on migration_wait.
+	 */
+	if (class->isolated == 0 && waitqueue_active(&pool->migration_wait))
+		wake_up_all(&pool->migration_wait);
+}
+
 static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 				struct page *newpage, struct page *oldpage)
 {
@@ -1986,6 +2008,7 @@ static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	 */
 	if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
 		get_zspage_mapping(zspage, &class_idx, &fullness);
+		class->isolated++;
 		remove_zspage(class, zspage, fullness);
 	}
 
@@ -2085,8 +2108,14 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * Page migration is done so let's putback isolated zspage to
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
-	if (!is_zspage_isolated(zspage))
+	if (!is_zspage_isolated(zspage)) {
+		/*
+		 * We still hold the class lock while all of this is happening,
+		 * so we cannot race with zs_destroy_pool()
+		 */
 		putback_zspage_deferred(pool, class, zspage);
+		zs_class_dec_isolated(pool, class);
+	}
 
 	reset_page(page);
 	put_page(page);
@@ -2131,9 +2160,11 @@ static void zs_page_putback(struct page *page)
 
 	spin_lock(&class->lock);
 	dec_zspage_isolation(zspage);
-	if (!is_zspage_isolated(zspage))
-		putback_zspage_deferred(pool, class, zspage);
 
+	if (!is_zspage_isolated(zspage)) {
+		putback_zspage_deferred(pool, class, zspage);
+		zs_class_dec_isolated(pool, class);
+	}
 	spin_unlock(&class->lock);
 }
 
@@ -2156,8 +2187,36 @@ static int zs_register_migration(struct zs_pool *pool)
 	return 0;
 }
 
+static bool class_isolated_are_drained(struct size_class *class)
+{
+	bool ret;
+
+	spin_lock(&class->lock);
+	ret = class->isolated == 0;
+	spin_unlock(&class->lock);
+	return ret;
+}
+
+/* Function for resolving migration */
+static void wait_for_isolated_drain(struct zs_pool *pool)
+{
+	int i;
+
+	/*
+	 * We're in the process of destroying the pool, so there are no
+	 * active allocations. zs_page_isolate() fails for completely free
+	 * zspages, so we need only wait for each size_class's isolated
+	 * count to hit zero.
+	 */
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
+		wait_event(pool->migration_wait,
+			   class_isolated_are_drained(pool->size_class[i]));
+	}
+}
+
 static void zs_unregister_migration(struct zs_pool *pool)
 {
+	wait_for_isolated_drain(pool); /* This can block */
 	flush_work(&pool->free_work);
 	iput(pool->inode);
 }
@@ -2401,6 +2460,8 @@ struct zs_pool *zs_create_pool(const char *name)
 	if (!pool->name)
 		goto err;
 
+	init_waitqueue_head(&pool->migration_wait);
+
 	if (create_cache(pool))
 		goto err;
 
@@ -2466,6 +2527,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
 		class->objs_per_zspage = objs_per_zspage;
+		class->isolated = 0;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
-- 
2.22.0.770.g0f2c4a37fd-goog

