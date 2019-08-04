Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34317C32754
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D09C7217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n2GzADBC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D09C7217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77FE06B027C; Sun,  4 Aug 2019 18:50:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 709E46B027D; Sun,  4 Aug 2019 18:50:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50E806B027E; Sun,  4 Aug 2019 18:50:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5416B027C
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so52215816pfa.23
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=FuciryAGC/68YnHVK4NKHxXMwx6v6FBZFh4/nz+g4FX2nTIQAi8E420HDxm+2+6mzE
         Zt+AKxRIzqlL9+tTdOpQ2fni8jpnXkZwCnGMKHFaXlZvG+ASctZVLZMY9P4w+v31a7vl
         fyRc0y7EyIwn6i6zN06BmzSAJvpf1FLllZ4wq7xkP7tHcQGIWIEJekrojZAGyBULS2/o
         fjP3Z/R4c1HYV0esSpGGZV9GNMtFkE0yL9b41hUXWMV7cQtT6Pu8z0L/a6Kqydm0bK3O
         kX7RqXekqQtW0E7BGZqhwNu8GH6SLwL/Eh2sCttgGY8KR7u5HsX5aWPV845aqc42yUT4
         3tTA==
X-Gm-Message-State: APjAAAUy3Uh8CPgYPUcNUCahUgFzBp5BftZhNYvdAbuMnSns1S6Pwg/4
	LGUiWSTmWHQB5a3IVNcqhQ3MtHXAFd2BX3HcQGXnZGmEQB1Hlw4gz5s6HwrjQSMPemjiUzHuh8Y
	ZHMSFvqxUvMekjlOjjRbuPO5tryZE02MtVmb2cCA8HE4ho8t+5COCX/YfHEk87yQLIg==
X-Received: by 2002:aa7:9516:: with SMTP id b22mr69768793pfp.106.1564959004821;
        Sun, 04 Aug 2019 15:50:04 -0700 (PDT)
X-Received: by 2002:aa7:9516:: with SMTP id b22mr69768764pfp.106.1564959004097;
        Sun, 04 Aug 2019 15:50:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959004; cv=none;
        d=google.com; s=arc-20160816;
        b=q0Hg8tR9kUQKYsnJu6Zbmcs4gZ1Y2Ss7rgcC9mbpZY/Ttuz7tQxwsX1i8U5Q8nHnPD
         wYi1gqXDO5cCMWcnUNLV2TdB72Lbn5+Re9+TgfDcVGYMMdMn6EuBxKjbFVNRUnDjiqei
         /imJCZKjOwwRHbf5gaurF65aj+1jNZfiNMzSTTuELBTxEwI4s22qQw0RApuLrrweHmWS
         XI1urZkBMKFaRIjCVDAi1/d20OVW+SwLEk0KvaEglxw1GIMLG25YULKM6hs8LFT+T9U3
         AmTwCNYvzrf9Zl2xOHlgpj3fzLwq9Rmb7Z4a0bOTDMB1jFsYcAuBV2VSV2Cf1M9eAIyq
         YkNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=ohqi/0sMbAwK6MLtJB838iKSYBhyuD8LDbcwgP8cZIf6cYF91LhXuT+Jm/fupyF3Bq
         OMfQmU0/RiKicYikmU2nLcd8rXH47+v6sf74ZiNQjFqip6cFZWSNV8AP3HN4HmLUe/og
         /5J+/AwJJGSkR6wTvKwElwrKqvPu+h0KtbGpT97oja2VtttP9rk316Wq+rNdisSJElyz
         EdSkY48XJQejnMQf0HjOU7X2YYnTaRlXtFjqAJN15bUGjnvpwq0FaN6kwRuGipoEMrvD
         nbBzybchCixvBjIaoJmL8qhW7p8s0HaC9xEm6ODcnOg9U6AbdT4c74wA+ke5qOMQyqdT
         NCgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n2GzADBC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w24sor97664360plq.4.2019.08.04.15.50.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n2GzADBC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=n2GzADBCRaGfCHf6HbXgRg+V0C89X4GtWNxkv2j3+LQsrqKpmTUVe0ByTHKQwdeBJn
         2GjNEQhUsYm7dhY4Od2Sd6r20534hykhUqRe4t1VnKwQ4DMvNZ5YhS01Fzzgrjh0SFnz
         cOALy97h5W1lbkzKyPwHr+vFBFBbcXlcy5zpFAQBNWN4n0Cj0kftmPhY24PBwGy3tLN5
         iaVwvJuxvheoQgKbgYArnZAnGqCyndt7VZwBKzGO0BC6OrGMqarpUlPnyV+UVYDmCU/k
         M/mEk0A479arzsza58VY7eIxZdZ0ZSau4HrT6ltuIf1VzdnlaHlbMs8Cfp7zJmoWUVEJ
         eBOw==
X-Google-Smtp-Source: APXvYqwABL/owZcbuKs02BqFh/fswcnIOGTkP8u9lrE9SbNiB96M9TYbiEw8R+LSl6DRBzA56M1pUA==
X-Received: by 2002:a17:902:bb81:: with SMTP id m1mr58194086pls.125.1564959003903;
        Sun, 04 Aug 2019 15:50:03 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:03 -0700 (PDT)
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
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 28/34] mm/madvise.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:09 -0700
Message-Id: <20190804224915.28669-29-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..1c6881a761a5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -672,7 +672,7 @@ static int madvise_inject_error(int behavior,
 		 * routine is responsible for pinning the page to prevent it
 		 * from being released back to the page allocator.
 		 */
-		put_page(page);
+		put_user_page(page);
 		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
-- 
2.22.0

