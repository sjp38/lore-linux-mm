Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8899C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DA4321841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kHN1iP7z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DA4321841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 073C78E0003; Wed, 24 Jul 2019 13:00:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0252E6B0010; Wed, 24 Jul 2019 13:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2CD88E0003; Wed, 24 Jul 2019 13:00:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4B476B000E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:00:41 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u84so51794535iod.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:00:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=H5uePaAnfho3jP4O84y/TR/d85pMr1PHhHfJNr70LiM=;
        b=cZO3f5iZ2eEdqHK+vnLTYYDpT8CUxC6SAP0kyrqUyrzY6QlkHbbtaSR78UXTKdCpGM
         upY96ECHy2JNaLViC3utgqvQ59OAsimPkQbmcu36ZqyZ/6Khd8QScDRdLWmwr8Z58+UW
         NBGI4ArPvpLSj+ZsbIrcFwNXrFmNBTdQyXbcjjfaZr4nHPAXwQMfGX52D2VoHXIVV8oA
         8ZH8PavfV3RR8oa5FIJxNPMJ4hJZQIJGVSmRyYXZPHya3easwbEBk3FkP7wriEWCnjnU
         BuTE9z6uaoKkmPsWVI4Z7aAOI/levv+1aRtnzbiVwecqzOckiknD7gWK8l+HaFzA4Gj1
         +2fQ==
X-Gm-Message-State: APjAAAWbmxElI8yzjnUgMYSYMmbNkBJWNn//OsjXiAanwL6Rsljpvk6+
	xQ3LHViMYJILdoOIlmlYtKbKX559R7PI6zE3ZTnSa6k+IBqmcgL/o7OaCaS8gE7I8FEobEryk1O
	W0imVIjWLbnjqIYQFgFCyYBJFL50tCQsoPD8USEtkJTGcTVjnO8oSfFyetoaNKjE+9Q==
X-Received: by 2002:a05:6602:220d:: with SMTP id n13mr79956330ion.104.1563987641539;
        Wed, 24 Jul 2019 10:00:41 -0700 (PDT)
X-Received: by 2002:a05:6602:220d:: with SMTP id n13mr79956252ion.104.1563987640686;
        Wed, 24 Jul 2019 10:00:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563987640; cv=none;
        d=google.com; s=arc-20160816;
        b=I53wHwNYbYrcrEIWZg3gYLY4wEgOtT3Y+BwqiudJanSVzlxNduN2gegHwdhZdhTKwZ
         nvIJyRkaTctfx+vnzvag3Z5N4ia3bEIMXYeKpC7e4v7+fu5g9zyt4X1cub66OlnuFAAY
         WM4ZaQvtZgtoqpUr6icrx4qQtaY0M0A5fbggofyOBYEVU/9esNUOVWjYQbrWF4sw3P+5
         91QwbYWfCknT4QCsXICLkpVSW9iyS3bjzP8zvgEQpmsaI3Yjn35C5A090YpGXfFzIPaP
         HQdbjftVLjZMPtivDfq6qgdoSNwysR6UmSXF3Ew9LN7vuLpKQG6v8Rw2f2B6ITKjzP1j
         gkiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=H5uePaAnfho3jP4O84y/TR/d85pMr1PHhHfJNr70LiM=;
        b=OlCwbO6DMP8z42E+AIOYSGqpuoAPshESPAPaADx6pXdnacZWJUtahOgBVZ5/4I2+lt
         g8f/PJVht8XqkdJmTJ682irquSSM6Z1psyxJK/ccZK9wBEfl0Y5Vgi/u0jdfRnsfRiLD
         LO21MbK2ih845oW4Nmz0xcqPpMKGTCM0rlQjSoGv8kKySLu21p2ejql1XPgXXxy9Croh
         J2WZLH9yBQ2sNjur8BVhrx8kVh49+zAs02KZbq0pBJPjGFdyNMw0t60pXBbTgYSTcBNz
         EMViqLlo8SpBeu0frjgCHulZbehDikcKl5zh2K1D6rRGNFbARIQQRe/IAy9yrg7dqj6W
         sxjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kHN1iP7z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor32460705iop.32.2019.07.24.10.00.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:00:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kHN1iP7z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=H5uePaAnfho3jP4O84y/TR/d85pMr1PHhHfJNr70LiM=;
        b=kHN1iP7zA3FJ74YxjzC8lHyl0JgV6YH25zYfaGW5aYOffgySOf1QKp+KZSQHNEMZFn
         GKh2kTELEzLGxrmnDZLQUmt0ykjoIDF3onJTscviyJA5ehSAC5J/5UW+6OaSP+iS5bu/
         1xU8vU3Z2VYVFmXfnmjeHFfNhPttjVDYToOKq1rg678rqHxcm0f7g0tiQhJpl/xRi+Wd
         hxAt6HjXkfC9jvuYIpfnwcVzdP5pFdL9Cf7F6GyLICGbk9RmPEUy6b4Qcp04eardBWx/
         jknqRgy69k+O7wjc/qY01mpJ20yzKRb5wPGzFCtmmEbEQ6QD7AfuECV7TisOSvi+bo3l
         Y7Yw==
X-Google-Smtp-Source: APXvYqx+6Zi+RypFO68n1WeSfP+QuoinYaHM4/PZrw3z9TvZURJv9ULbWB+7BvwlnKgD1QoYlHaN3g==
X-Received: by 2002:a02:6d24:: with SMTP id m36mr87555505jac.87.1563987640301;
        Wed, 24 Jul 2019 10:00:40 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id b8sm38161917ioj.16.2019.07.24.10.00.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:00:39 -0700 (PDT)
Subject: [PATCH v2 2/5] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 09:58:30 -0700
Message-ID: <20190724165830.6685.51110.stgit@localhost.localdomain>
In-Reply-To: <20190724165158.6685.87228.stgit@localhost.localdomain>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
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

In order to support page aeration it will be necessary to store and
retrieve the migratetype of a page. To enable that I am moving the set and
get operations for pcppage_migratetype into the mm/internal.h header so
that they can be used outside of the page_alloc.c file.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/internal.h   |   18 ++++++++++++++++++
 mm/page_alloc.c |   18 ------------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index e32390802fd3..e432c7d5940d 100644
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
index 1c4644b6cdc3..3d612a6b1771 100644
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

