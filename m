Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34A46C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8E012083B
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:31:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ji33itet"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8E012083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 714576B0003; Thu,  1 Aug 2019 18:31:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69EE66B0005; Thu,  1 Aug 2019 18:31:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 517CF6B0006; Thu,  1 Aug 2019 18:31:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16DF66B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:31:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so39187675pgv.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:31:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=49QRQWf2FNsjOXVM5hrSB1/wT6sFBWj2i81LIQFGLg0=;
        b=kRdLVjTs5bCs1p4Ax6rgPjrMG9I0nmFuVn3jr5YJ+iNM82weh1dqz6vPuw2XFEbxGM
         WYoj9sZylZMgltNBdzFoSwlDYX22NUsnmXjhvh44JAdCH/SKWoiURy2NSAyThW9pNREr
         8+5CdJFHD5H6Yj+gCp2Ehpku3Vd3q1ZlHycESW1kCshlXI2ZhClB3nZ6grCFPz+x4TEL
         rRVkgnM3mwuXsIv5/O42mrIT4ykCOwUbiPtAjaV6BCbvnOVWM3bOd5jzynCoN5kd6h0v
         yMNI041V/MFn0d+/0VDN0wmWv+ry+D4Jdh2ac569578noYk5yqv+uGactc5l8vtjRbmB
         XW3Q==
X-Gm-Message-State: APjAAAVNuQhXm36g2l7AK50BTgPLRGcE4M/zYpqRdIpslQ+gD1GdIf42
	DJokxIn9NhZBmZyQp2VePF8H6dJrmqVUz6vrhSFlqGhFbPYDGUZhEVIuseJbStUhAq0d/VVYCPw
	7atHGy/LiUp/B1Iva+cDqw+3sy/io4lJ64fA/BaluYfjVCk4Zs6ZiaiDIbK00LrOk8g==
X-Received: by 2002:a65:4509:: with SMTP id n9mr67822991pgq.133.1564698700675;
        Thu, 01 Aug 2019 15:31:40 -0700 (PDT)
X-Received: by 2002:a65:4509:: with SMTP id n9mr67822928pgq.133.1564698699759;
        Thu, 01 Aug 2019 15:31:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564698699; cv=none;
        d=google.com; s=arc-20160816;
        b=deV9HHCIyvHEI2KjRaVxzDUtDQ/OrvO6j/Rs5UV1EctH9WIkTYtrWnts1YTGpRS2dJ
         II4UEX72hxaY5gF3vWxi0BLQ6QsmhzOQEER8GDMM3t33jFfzk5ClRyQNigBePLhtJPGM
         8pNwhHgiHdGCj/Qfiot/Tk8PGQ8XzLe/stJo3MCi7inEf+A1FKe6CL88Eebp8Bq6o0aW
         350EnEuwH/n1eMLnl7EP3U4w9UxzCig/6zete2uA+0/UxJ1JHfs/hAbjK8HQFjjyIx/r
         d2aJVraiaPakyUDGYmn/QVK0fVj9mP92HnEX/t8oQ5TnCDxQQaR/ZWUgLHxEaeW7pU/J
         UbdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=49QRQWf2FNsjOXVM5hrSB1/wT6sFBWj2i81LIQFGLg0=;
        b=TomGuwAxzgGzT0A1wTioVE7MnKuAsVdDZ6Ey5O+Ua2aSN9TxlUlDmsUzfpCTkDkFgV
         0gcDoJ2s5iVeufmUe/jcfR6dRiesAQ/a0tLj6Jmh65ktY2fstbtorOh6W5suh5h110Xi
         Ee4Ss6claD7/inxYs3mPdMNXMfSgkZxb7JuCJPmixUHWUohngLJ2jylqLW/C/D46KdBp
         l6dhTzdTlZkQnoIdG/UbIFyJ6I+yjRIViJIdivoP14uTan3owY1aC925RaGArzgmR0x5
         IoQ3gQVd+Qd68M5XKuuWLk0q5gpzij9d9KDXnv+VKPSi+iyp+IddStgXR1cUg3cAsrWc
         isDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ji33itet;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11sor88513549plk.18.2019.08.01.15.31.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:31:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ji33itet;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=49QRQWf2FNsjOXVM5hrSB1/wT6sFBWj2i81LIQFGLg0=;
        b=ji33itetIIDF6723/1Y8YKJGaXsZhwxdfFFZT45WUtDznubVlVgr6z8O6LM2Y0Bm8P
         P43KwP1bs6fuGWQAelVx2jsf+HXc9hjzhGqb6BID3daGICPkxx/rJvFHx5nyJeTqaquo
         J5birZo4hMpfVK6j0Z9nSIcOOGAxTZryiD/Bg7Ea0Sh4JYUZV5Q8A5i5BlFn+XlDUn2Y
         xbtmEccIS9ctv1SzHpgWS+Gmvdsmo1e/yOMrR/P+7j5Dc6t3T1NV9Bf8oF0an0BTRzHE
         zwVYl7CMWW7OMqTK+UidQdCn5nY8fJS9gYQXsiGqTJOK0Pc7c31igD37NF4ruL1MGqIV
         abHw==
X-Google-Smtp-Source: APXvYqx2jv1TK82igL61Day1gZd1T9JWolFuPhQSs0j3XhgePDf2nr7I5FyOs/W+WeBpIigsbk6TNg==
X-Received: by 2002:a17:902:2be6:: with SMTP id l93mr129298797plb.0.1564698699193;
        Thu, 01 Aug 2019 15:31:39 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id m20sm80514167pff.79.2019.08.01.15.31.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:31:38 -0700 (PDT)
Subject: [PATCH v3 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:29:26 -0700
Message-ID: <20190801222926.22190.81982.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
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
index dfed182f200d..7cedc73953fd 100644
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

