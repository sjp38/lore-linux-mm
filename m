Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05FEEC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:48:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9E4920657
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:48:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UtD5zDDr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9E4920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 530748E0005; Fri, 26 Jul 2019 18:48:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E11A8E0002; Fri, 26 Jul 2019 18:48:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CFED8E0005; Fri, 26 Jul 2019 18:48:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 067FE8E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:48:23 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x19so33917532pgx.1
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:48:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=xXWX2VUvhlaSP3eFpOp6jubimcyekuwmKjKZ/Jue+2A=;
        b=WWX3wWStvL2FhSBtXeePf06XB6mpLFIx9CV5kIi6wGHc0N5RVezQufTqMA5pgHLOQm
         +sjNzBW3s3ofAGoYvFiQd1tM+mFi+CmWQP6YedC5DDexWNF3dlXCdpQfItMYbu0EH500
         2hLINunN8KxsUUPeyZRxiLTG52FMtsGj9oRwBohlSAoijoCDTQk521qqvVlD9KgzQv0B
         ppxnZr9zUSQ4UFHSP8bjITAHCIvsUM8kP/ayiImMXdmtfzjDaDjwWHfyjUmwpXPDsnfP
         cDV4LuPKphKzau2xVkxkAaNeLBQf9bhkSlyQL8X+xcEbRvDt/XVjCWuDnppq7FDTxOWo
         i6gA==
X-Gm-Message-State: APjAAAWJ0EYcoQtO2iZ89AIj1bDQ0bx6l8D3nYPM26sy55XzvRgWHuok
	pAimQwTJBjqGtd64YCAoq41k0l1U+Xb2AHqHP2C2OClWhqocwQb4yQhj0Gx7HP8rluMKbF8zd3p
	TXqINd3cNaHsrffDxZIcdAJa5gdE5ntD5R4yXVVY+zq7n9dalNGQJL9sldgsiMEFrjg==
X-Received: by 2002:a17:902:7d8b:: with SMTP id a11mr45164110plm.306.1564181302702;
        Fri, 26 Jul 2019 15:48:22 -0700 (PDT)
X-Received: by 2002:a17:902:7d8b:: with SMTP id a11mr45164072plm.306.1564181301987;
        Fri, 26 Jul 2019 15:48:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564181301; cv=none;
        d=google.com; s=arc-20160816;
        b=n4ndOkl9ZVEZmDWkBGkf8KHURNVXeNqWrBF60NGe8E2B2x2WEFfFL1caLPiPjg/Kir
         RwMmV91XDXIqejNKRVTz/UQViQ5StH3b1O+Er7GSFt7CY/o1WPFugrUJ4QT6Y1smNrHS
         OO9KxkGPs1U5qcbymiiePINFpkYYHRR3pmWGCArK4Vs56//+U3BzGWsgyNPfUhJds/YP
         Jx7KfKyz0onNG5955tXhhEXsuVK1CEnhuBS+jhRmMYzHhrDjDsOcN46x3x208qsLFhVd
         sPnccKV2VWpIve0RtZ9bol9BKlGbwmLHXoYN/xjOl1Q6ATu3yIdIlwIxysgKOLH3flK+
         V43w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=xXWX2VUvhlaSP3eFpOp6jubimcyekuwmKjKZ/Jue+2A=;
        b=qaCODWsk7xPLcbJ4qe5u+BGOs4GlLMhF+R8Qi5LmRNgD2HSvzS9oirL3YxvH/VaUZ0
         hNxW9leeKvvoIIr80MrCbPmdXYUK1CEWROU5Y4zaKD5QD2p3uXwAK2ohcx84P8+508qS
         7n3VeBqv64rjNj3ckpdhecTx9upRg6IvNCojLIq44BnZzphdCwyWLS+Hm0J1MeyYA+5K
         IdwaWlT3zVxlzWjA9Tapx4EoPuUPnaP8TsbAOhzoCPu8WGqF0jQq2hJGBbWCIjRQFTHf
         +Z8o3ZH039anBpirXOjQhiAQ0Ls0ChOoP+kCGB+WhMhQJNhKNEYSQmGcs2E/Nbp4rri3
         cC2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UtD5zDDr;
       spf=pass (google.com: domain of 3nym7xqokcbo74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3NYM7XQoKCBo74DHO1KHDI6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m13sor10847623pgi.71.2019.07.26.15.48.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 15:48:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3nym7xqokcbo74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UtD5zDDr;
       spf=pass (google.com: domain of 3nym7xqokcbo74dho1khdi6ee6b4.2ecb8dkn-ccal02a.eh6@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3NYM7XQoKCBo74DHO1KHDI6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=xXWX2VUvhlaSP3eFpOp6jubimcyekuwmKjKZ/Jue+2A=;
        b=UtD5zDDr3YWz08bCCB2rTH85HPonmpnywBjnkC+40TBxVdPSBkrdoJlfpcs3WjPJFz
         qzKCOlMiIkiyh0GnDIb4ufsrPNJH+6YElA+I+DAmT3BhzA7Cmm9gp250MTYPkN6Ojpgj
         Xt8gaKcUKddO+Jht4XR0TQYI5xAqZq8OzHw6rPl5iRysirTvroBgDGP+nZ3xPEukFUbY
         4RkcC8U3MNMoZOja3xOtQkm3b+qq+805SQozYU12Va/qJHk42NnDgNt2CvtQTCBqGNSh
         XMLSKVnibq91UNt6XUzmWQDgQtOKqKqP11a2Zd8Jm4pqJFsK7gP9Xwf9UHSkCsRGA7TD
         5gPQ==
X-Google-Smtp-Source: APXvYqwgia3+whqx87wT3bznlRIKzs5psESC65iyZd4wex6/4W5aVuLVvjvBesKSfs8+uxfSH8qVoS5Vsfbb2O1C
X-Received: by 2002:a65:49cc:: with SMTP id t12mr87423288pgs.83.1564181301373;
 Fri, 26 Jul 2019 15:48:21 -0700 (PDT)
Date: Fri, 26 Jul 2019 15:48:10 -0700
In-Reply-To: <20190726224810.79660-1-henryburns@google.com>
Message-Id: <20190726224810.79660-2-henryburns@google.com>
Mime-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() race condition
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

Calling z3fold_deregister_migration() before the workqueues are drained
means that there can be allocated pages referencing a freed inode,
causing any thread in compaction to be able to trip over the bad
pointer in PageMovable().

Fixes: 1f862989b04a ("mm/z3fold.c: support page migration")

Signed-off-by: Henry Burns <henryburns@google.com>
Cc: <stable@vger.kernel.org>
---
 mm/z3fold.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 43de92f52961..ed19d98c9dcd 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -817,16 +817,19 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
-	z3fold_unregister_migration(pool);
 
 	/*
 	 * We need to destroy pool->compact_wq before pool->release_wq,
 	 * as any pending work on pool->compact_wq will call
 	 * queue_work(pool->release_wq, &pool->work).
+	 *
+	 * There are still outstanding pages until both workqueues are drained,
+	 * so we cannot unregister migration until then.
 	 */
 
 	destroy_workqueue(pool->compact_wq);
 	destroy_workqueue(pool->release_wq);
+	z3fold_unregister_migration(pool);
 	kfree(pool);
 }
 
-- 
2.22.0.709.g102302147b-goog

