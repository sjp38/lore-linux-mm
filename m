Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD6DC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 415C720657
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:48:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t93ANIwe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 415C720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAA088E0003; Fri, 26 Jul 2019 18:48:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5ADA8E0002; Fri, 26 Jul 2019 18:48:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6FF88E0003; Fri, 26 Jul 2019 18:48:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9734A8E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:48:16 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id l80so23655195vkl.0
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:48:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=ugYwzqnv6FobgASB/IV2QGrorIeaEWGKXnYtHi2Zf0I=;
        b=C9dZMIqDr79Ys0P1h4iPd7VsRkzxxbfP47LsX9wEqh8lwqpNEwfh3zv5NCaOkr/aZM
         Z7ZfSiL3P+iSin0YYHMxobcb3rmeMZ5ZIItJYBVBINW0YegDyDXTkyq90zHyM4C6khcw
         1Fa99X8huEU+iA5NxC1Cfp7rGddHz4K9Ysc2AQG/5Z2uIIdCntfEA3KOpyFb4DtBhShK
         nD+soMXr4iFkFECs3JqBYneZ+ao/cnJ0gXvc3P3dkItSMfw/mgpB4AFShwxXeNuInyQj
         5Ry7x/b000jY4/3QEAgjg20N6+ZsWvhzxKdXZ6xGCnJ5T0XS4M+eFTUwt23XbAhWbkwS
         PIvQ==
X-Gm-Message-State: APjAAAVvT23OL98BJaLA1dSdwoixGwXL6CuSkby9mNxZYi6Su502o7JY
	5QxZDFvle92pBSjNT4x0OKO7h9rJvqcw8iNPwoXUX9Cz7fy9plsG6DkdcZgtFUjYzGikYOCnN61
	FvzcaeEjdbAoNbh5hfQk09mzcg/lobOMupBwKqAtCWOkUa3iHGhr9CsPPPPyxO61Uvg==
X-Received: by 2002:a9f:248b:: with SMTP id 11mr62645862uar.9.1564181296267;
        Fri, 26 Jul 2019 15:48:16 -0700 (PDT)
X-Received: by 2002:a9f:248b:: with SMTP id 11mr62645842uar.9.1564181295655;
        Fri, 26 Jul 2019 15:48:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564181295; cv=none;
        d=google.com; s=arc-20160816;
        b=y4jgGwqVh9tt7UA28aX2KalL5qZfcpIbahSVB2Q1VVJfurbUg1RbcpSMchP5nGBBFM
         yiOI1vgcP0na5dUTA12tHr8mr7KDh6bamF+1vnlspjyMxLt1eTvx5mM7zh2CelCgp77Z
         bG9IiqzV/qLi+04XKqqEFFlzaMDiZyboiKNdZrWPWV5E8jExKvArPAM8xiXdIB0CCf6f
         ewmZRYnw1zEKSXHRDtnPqInNwL8BtKiynkZZueBT36tHMukci096X/8frzMwaYgvXNpR
         Ps3SRZe4gAq5U/+YWDWOwCfBFe64r2w4y/e2ggROvLlZGylDEbRDLkohSwZBN8cVeVrk
         wk3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ugYwzqnv6FobgASB/IV2QGrorIeaEWGKXnYtHi2Zf0I=;
        b=faNHyr2GfBiWnNn7F6cucmHjLsKCAc3iA5rgJK5QMdd3JeUiFizWBk5j/P1/3kZufm
         37xfRw/4hHfDBy76rnjS1hsAEzyAuWBSxsHopp9BTKL0A0DqGidS7lqaH41q4BhqX0P3
         XIi8po1v08HHJKb0VLPbkAM6/AXu2J151hpG3cX2wXlNcRETgkewR3P6WDbIFO+kupso
         z1RLvPBxvtG4Apj5xUqTXE2SS0NPBsefzKsYIUYJIBOznDeGlEFCCRcsLhqucl6RhW0g
         3ZxDeCeUuiOxXIGH9adJ7W9I80snMHbILfzBf0+cTT9BQMBO/+YfAG/t3z1snjUgvShQ
         fF9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t93ANIwe;
       spf=pass (google.com: domain of 3l4m7xqokcbq1y7biveb7c08805y.w86527eh-664fuw4.8b0@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L4M7XQoKCBQ1y7BIvEB7C08805y.w86527EH-664Fuw4.8B0@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 82sor16187468vkx.3.2019.07.26.15.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 15:48:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3l4m7xqokcbq1y7biveb7c08805y.w86527eh-664fuw4.8b0@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t93ANIwe;
       spf=pass (google.com: domain of 3l4m7xqokcbq1y7biveb7c08805y.w86527eh-664fuw4.8b0@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L4M7XQoKCBQ1y7BIvEB7C08805y.w86527EH-664Fuw4.8B0@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=ugYwzqnv6FobgASB/IV2QGrorIeaEWGKXnYtHi2Zf0I=;
        b=t93ANIwehynL05QpzsPZQsNzsYxLbN+DEc+mU/gC8S3QoOdwTg6FWn2YHKT6g/JEBV
         +plV+4WjbYjE9Iw7uZ1VG0BDJ+16Y9xWYd9v1LIt6vDngPyZg0/hmMjTS2I9YEl9jicA
         31jSLX5XQ9oBkwYmBtzOxenRKIsCwx4PNL90gPuNXhPk5XJ3rUEY55ZCDSl1dislK+H0
         g6Wfn1ehtdFKdIlTR020Dp7vd8oiLIwlhadCFIXKZS3z+9hQC3ZJf+K+w2i2gEvpCJ31
         DBHOPYqz9sCbWxdhFNbi+HS5+FiuDxaZBwOgrnmhPGa7Xuj/2HX8s72wsXj3lo0fpkwD
         hnag==
X-Google-Smtp-Source: APXvYqwkSvswxUgvR5c6fCqlODLxRregW3zUnnkYsv9AKzH6EnFwtFPMVKnEpmizdeK6j5ngy/2lUoNmIaVHBLtU
X-Received: by 2002:a1f:6e8e:: with SMTP id j136mr2583640vkc.80.1564181295126;
 Fri, 26 Jul 2019 15:48:15 -0700 (PDT)
Date: Fri, 26 Jul 2019 15:48:09 -0700
Message-Id: <20190726224810.79660-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() ordering
From: Henry Burns <henryburns@google.com>
To: Vitaly Vul <vitaly.vul@sony.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The constraint from the zpool use of z3fold_destroy_pool() is there are no
outstanding handles to memory (so no active allocations), but it is possible
for there to be outstanding work on either of the two wqs in the pool.

If there is work queued on pool->compact_workqueue when it is called,
z3fold_destroy_pool() will do:

   z3fold_destroy_pool()
     destroy_workqueue(pool->release_wq)
     destroy_workqueue(pool->compact_wq)
       drain_workqueue(pool->compact_wq)
         do_compact_page(zhdr)
           kref_put(&zhdr->refcount)
             __release_z3fold_page(zhdr, ...)
               queue_work_on(pool->release_wq, &pool->work) *BOOM*

So compact_wq needs to be destroyed before release_wq.

Fixes: 5d03a6613957 ("mm/z3fold.c: use kref to prevent page free/compact race")

Signed-off-by: Henry Burns <henryburns@google.com>
Cc: <stable@vger.kernel.org>
---
 mm/z3fold.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 1a029a7432ee..43de92f52961 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -818,8 +818,15 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
 	z3fold_unregister_migration(pool);
-	destroy_workqueue(pool->release_wq);
+
+	/*
+	 * We need to destroy pool->compact_wq before pool->release_wq,
+	 * as any pending work on pool->compact_wq will call
+	 * queue_work(pool->release_wq, &pool->work).
+	 */
+
 	destroy_workqueue(pool->compact_wq);
+	destroy_workqueue(pool->release_wq);
 	kfree(pool);
 }
 
-- 
2.22.0.709.g102302147b-goog

