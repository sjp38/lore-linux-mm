Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B200C32750
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA53521842
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VGrPeNjq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA53521842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E2C76B000C; Sun,  4 Aug 2019 18:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 846216B000D; Sun,  4 Aug 2019 18:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D5F66B000E; Sun,  4 Aug 2019 18:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262D56B000C
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:30 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u10so45031669plq.21
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YLPz5BCHjHkg+J9ZI8yxOLwnUAw8CiRxIyzlmsd6bb8=;
        b=h0w89imON5BoOOI40UTDaGY3Gy3LExJy3YfnBTv6r+ETnpm1RWhSsNpWSMnaY0qA4n
         xvZakSrohwoUCS9OKlPa1+8dpjN2swfJcdxNcp4kcVmcfD+6NFABIOs0iXUtN+i/NpwU
         I8BwzPhPLVhHK09X7wlBZEM8Va/BIqb6tPTkQc/ReIxcluhyhaR3Dg8OnQU7qqUd6iJE
         UmDpjxP/hV3t5BsE1oBRYaBAVrBNYPxZjKj/tqmGhJhVF1pGeeF5lhpB8MlCEFy1Ik/g
         m/ZDHKSxR9ZtcAgggIst0y1g6kxIDiTgTkb76fCfsLZdTO3UAMVGzcCkxxjOUQmX614h
         eEWA==
X-Gm-Message-State: APjAAAU74AjadlfZj0InsJaYZd8sypHDK1NOSVh0W/iLpdLy0Z1iVLHB
	/x0kjD1DnVTkmjwg42EvkhVN4K0nc9BYvYBcPXrq369v4tMteKTfctPoSNZ6fQiBH6PG8jWjDIi
	ztDc7PT9UOzM9ECajnBfBDqYHvvG4ZiRckWu58z9kGKo5h7V0AzsB1D7WPTNp14dVGA==
X-Received: by 2002:aa7:8651:: with SMTP id a17mr69597702pfo.138.1564958969785;
        Sun, 04 Aug 2019 15:49:29 -0700 (PDT)
X-Received: by 2002:aa7:8651:: with SMTP id a17mr69597671pfo.138.1564958968903;
        Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958968; cv=none;
        d=google.com; s=arc-20160816;
        b=EKK4V6FUfqgD176OhXlbji0IwrTdxiVsXqEx7l6tQ4h70HeFjIqqgM7oc1m1/oqIqP
         LPKqfX4Erjw+ZX2Hb6llKMHNg3hptXQ4q4YIziN3ka6VEeEad2ifAEvGs7Siooaqdpc7
         hl7qRnkDvHcsHlIvMv/dZ2TtlH+ZD1+WV2j/IBU2uHQCBubCcy5uPLmC5DPMVN+XFB0c
         kLPfAqYud7pTr3bjrj3EmmzXTY0u5y1lQkHJwe746KP7Bo2l63Qw3zdOIQbVPISOt9PR
         H7zH34srnDYgd0JfdsULYplkhYSmvco6GJJsU8+yTdWzge05aQPP7yNQcgGuReI/FoE6
         bb5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YLPz5BCHjHkg+J9ZI8yxOLwnUAw8CiRxIyzlmsd6bb8=;
        b=Qgg0Btb87z/d1W0/N0/KTIjMWjQXFMXYLCXaJf4croqsRAz0DCtAtH+ty4tHNoSCFG
         K43oLQWs6hqHgnS3Wg1E+AuLnMzepeCyyoVAFlt0OMDha4NB69hFMNn21s9RqHWxoKl7
         haqYXhvdJJPjAssWuchZQ9462LuY82RbZ7ZHr+zy3QevQTU8OV7YQSrkQzuyI0lCcpxt
         iIpcVrABKtR16xOi+cKr0/yedfWGwprSWkN+WXTRVaD/fHtmuFD5rGB1hVa9Z/ZOZH9i
         4tu6T5nJ6B72cXkyR+jXS7VD8TjziGJUVqGhUsvnpSaG0+pC4P89MwRxLdfhk3iA7FvI
         4tIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VGrPeNjq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l64sor56323650pgd.60.2019.08.04.15.49.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VGrPeNjq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YLPz5BCHjHkg+J9ZI8yxOLwnUAw8CiRxIyzlmsd6bb8=;
        b=VGrPeNjqXUKwD8rPOUJWvgTDjvXlBgpZNgVsAZpGvh41vX88GkAws7QVpEp9tEzYXW
         EWAxbuchsvglHqS59E2TkHXvzV9QiwRyVicm9YfNC1RSq1Lw+8bSeox7MCzKs4UlTpfP
         ozXvShoKM7yUTPqi96o4h71oG13jljV2Z5NhvBV41avMLU4Q1BrhH8GwT114cWkCl1MF
         d261JitS12TLzntNYSyrJZWMAgzBr9+636G4ae4VYGKmmjZF/lcCezF8KGvZPOFySOt6
         etVud9nCJxdyVx56j1jluPcIcFoQjayW3OLzqWiVdA46hf2UCQT0Dq3HzUpJLfZuSPrQ
         6mhw==
X-Google-Smtp-Source: APXvYqzIKv6XtE7UttpMMo5Kx4L8tiNE0k37oAlXEn6wMXua1ZT012h1Fuu1D5Rv1jbsWDQQbHwbnw==
X-Received: by 2002:a65:6547:: with SMTP id a7mr112462494pgw.65.1564958968612;
        Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	David Airlie <airlied@linux.ie>
Subject: [PATCH v2 06/34] drm/i915: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:47 -0700
Message-Id: <20190804224915.28669-7-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

This is a merge-able version of the fix, because it restricts
itself to put_user_page() and put_user_pages(), both of which
have not changed their APIs. Later, i915_gem_userptr_put_pages()
can be simplified to use put_user_pages_dirty_lock().

Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: David Airlie <airlied@linux.ie>
Cc: intel-gfx@lists.freedesktop.org
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/i915/gem/i915_gem_userptr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
index 2caa594322bc..76dda2923cf1 100644
--- a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
@@ -527,7 +527,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	}
 	mutex_unlock(&obj->mm.lock);
 
-	release_pages(pvec, pinned);
+	put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	i915_gem_object_put(obj);
@@ -640,7 +640,7 @@ static int i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
 		__i915_gem_userptr_set_active(obj, true);
 
 	if (IS_ERR(pages))
-		release_pages(pvec, pinned);
+		put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	return PTR_ERR_OR_ZERO(pages);
@@ -675,7 +675,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj,
 			set_page_dirty_lock(page);
 
 		mark_page_accessed(page);
-		put_page(page);
+		put_user_page(page);
 	}
 	obj->mm.dirty = false;
 
-- 
2.22.0

