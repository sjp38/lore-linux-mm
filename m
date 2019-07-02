Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1C59C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 00:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F08C2183F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 00:51:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ODdYbhrZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F08C2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA7F16B0003; Mon,  1 Jul 2019 20:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57808E0003; Mon,  1 Jul 2019 20:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9467E8E0002; Mon,  1 Jul 2019 20:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7E06B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 20:51:52 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id i3so8105096plb.8
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 17:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=fQRHpcnZQgmJ5EVYhy+Qqag9BuKV3GgR0RmH9DgVc30=;
        b=QYtWlToFbO5Q6J4H0Ms/ILYb3obvC8aemV+AYDDJpzWE3mVt4P3eSoXKwoFEUbEGZt
         tJ8snK/JrMSxLRA4W1ZWFJVlwvi2R3sF4pEz43NOYYgrTSmtTL7zjHSJD5Que14RoUV6
         XclIjL+LniFXRqEpY3QgUyVITLMSMy6ZjaCJ5z/xOmkxpe9Mqs4lz+lirSX6m0buZ+dJ
         TzLS6CRevskN45IegKhZt47Xk+0rafxOhKU2iNaedztkUQpENr4DfZe7SrU955FP6vML
         uHzAUaQedjvkO7xqT+4zgXHHv2klsCWAQQNzLUrJLxNIOdnQuKzj7CjcYAs55MAjkuni
         ydxA==
X-Gm-Message-State: APjAAAV6Qf+u6MajhbTLWwbGXRLuRClnXSxc24Gw2GZx0DzfY0yvMO4K
	Cz4YW4ZBLA/vj+GhIu/+XeYPCMXIuJALbW2Psik94k9AlVsVeUeA2r7G+ZyEtp0EoK7GwnZYlwe
	7gu42pHKZqgTmvaD45umIVs2tGnzRYoC/um2gm3d6GOZzw5AGRoiMEuN8dhfZ/UdxlQ==
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr2333592pjb.10.1562028711842;
        Mon, 01 Jul 2019 17:51:51 -0700 (PDT)
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr2333543pjb.10.1562028710899;
        Mon, 01 Jul 2019 17:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562028710; cv=none;
        d=google.com; s=arc-20160816;
        b=FDlK0ZY+xiDBvrcsVcTz36H8253qrj5Q2Ee0wL8k2gBBIGW7ycXpAlwUnnzViYvqmb
         b3IhjkxP7yscu+JOzvsQUJmXmx1YO6cQFzTf2ddHFYSDPi7eWWtaZC15SY9Q587ZW1iW
         4j7pe9YROyBQJwGFMiZ8I7TiIb/jhGbN6lbYIWKPRvDUNkMUib1S81mlBrN9b29r5clH
         2Nd5+IoLyvHqhGsOt1WsMUYkdNM3+7n+puM6HR91FtAaY939lJ2VRcPZ7GQYhoh9Y56x
         SLsQyq5A4xU4nV37s9ONzAm4HN1AME+oDadXaTLgbfCwSs+voXy3wAnCKi7hTLvBVXQs
         gASg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=fQRHpcnZQgmJ5EVYhy+Qqag9BuKV3GgR0RmH9DgVc30=;
        b=Lt2RbtMVpiqiRkio92nqTLWLnzL31ciKNmssYMjh6kzS//KSdRx7X8tBvXEDwPolS3
         ji/kBOUuwhpxe5XyftXKJpYwrrNtL95ob1AkuY9ZVVYF455B17Q2Z28XBQt7Xb19P3fe
         fTJvmwOzVIDBZrua18FeWmp0pTwtDeR5tLmpde03a1zIildOwtNdOjiKLSvMq/98ksII
         2MkIuYXsatcEKk0g4DnAAKdzYwa37MLzokHBcBnHiqpxhXuw7RtV+vr33STZLZdpUZVc
         9QD1x9M3s3igv6k3PyMNdEg4JOjIpwbzLpNOJ9xOcJinCmiMgWg4F/3fRrmQ8xcATcZe
         g4qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ODdYbhrZ;
       spf=pass (google.com: domain of 3pqoaxqokcfu41aelyheaf3bb381.zb985ahk-997ixz7.be3@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pqoaXQoKCFU41AELyHEAF3BB381.zB985AHK-997Ixz7.BE3@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t4sor2420581pgp.86.2019.07.01.17.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 17:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pqoaxqokcfu41aelyheaf3bb381.zb985ahk-997ixz7.be3@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ODdYbhrZ;
       spf=pass (google.com: domain of 3pqoaxqokcfu41aelyheaf3bb381.zb985ahk-997ixz7.be3@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pqoaXQoKCFU41AELyHEAF3BB381.zB985AHK-997Ixz7.BE3@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=fQRHpcnZQgmJ5EVYhy+Qqag9BuKV3GgR0RmH9DgVc30=;
        b=ODdYbhrZxLaj82QT81sQFex0PsUNmi7pkBfxxjI2BAqvUgbT1v5TtvMslVPTu/mUMp
         MnvG9TO9zNsxpUFKLqftjjjMTJsVYPqjIOmm2oNV41LiRHkjdcA3EKJ4EbQnS5uiPQfM
         Zpt0Pu7BsCzYycwnA83E8hGzxksbyCLMMp8GvRlzJdjwyfjNUsSW86ZNgnExlTFI0clR
         lrPk2JAuiLERvcNdFXCFwo9a7auujyK/+AtWsKFveHTrcIEjmeUqdfcQw+WmGs8kjTjm
         NrDfELXrRp/baVJbjHvlkgBpNBTz6IjR4P+aaniPxlvNq/kvztmSoJu5gT1ZU+y8IjCW
         UEJQ==
X-Google-Smtp-Source: APXvYqzXhknzPhp8ywA8IJFv6X8bS3qEb+pGQJo6CDssSNJBkI8XUGFWLMs249ByEsdnkPkZUi5H4YIv/jBLv21t
X-Received: by 2002:a65:44c8:: with SMTP id g8mr27400341pgs.443.1562028710037;
 Mon, 01 Jul 2019 17:51:50 -0700 (PDT)
Date: Mon,  1 Jul 2019 17:51:22 -0700
Message-Id: <20190702005122.41036-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2] mm/z3fold.c: Lock z3fold page before  __SetPageMovable()
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
lock the page. Following zsmalloc.c's example we call trylock_page() and
unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
passed in locked, as documentation.

Signed-off-by: Henry Burns <henryburns@google.com>
Suggested-by: Vitaly Wool <vitalywool@gmail.com>
---
 Changelog since v1:
 - Added an if statement around WARN_ON(trylock_page(page)) to avoid
   unlocking a page locked by a someone else.

 mm/z3fold.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e174d1549734..6341435b9610 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -918,7 +918,10 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		set_bit(PAGE_HEADLESS, &page->private);
 		goto headless;
 	}
-	__SetPageMovable(page, pool->inode->i_mapping);
+	if (!WARN_ON(!trylock_page(page))) {
+		__SetPageMovable(page, pool->inode->i_mapping);
+		unlock_page(page);
+	}
 	z3fold_page_lock(zhdr);
 
 found:
@@ -1325,6 +1328,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	zhdr = page_address(page);
 	pool = zhdr_to_pool(zhdr);
-- 
2.22.0.410.gd8fdbe21b5-goog

