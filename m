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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F798C32750
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAF8320880
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HKywskhQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAF8320880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B4196B0007; Sun,  4 Aug 2019 17:40:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73CB56B0008; Sun,  4 Aug 2019 17:40:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8BD6B000A; Sun,  4 Aug 2019 17:40:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24B466B0007
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 17:40:51 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so47857308pgq.4
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 14:40:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=VOLIOnIsYMIicPChRedOHwTzMfP9zteaq01C1EfmFF6jXsA4VtcvyXR70B5BZa6561
         n21FiTMoFsqKdd4GMfjX4r8SexGEBFYVcLaFoZN28/A/+qYxQWUjPFNKWRN/mOazpNhI
         o/705uEjYbtTxyEfBlG/WTNl2Qq18iebvgRSvSjcTLeFxfM1lezmqVhWqYbuXWCnZoP3
         djj4v9CNhhrfCUNVfRVlBIE24R5cNHIARvBPXmkGRxPg9hKa94UCULu9/9q3ANk6UtAX
         CaOL9DDDxvuTXl0byET+qUd5d24i/QhU6XSCffJIKb1Hk8ELwb8V2bqZCvYxP2wqsIvX
         sxTg==
X-Gm-Message-State: APjAAAUwem8YnH1HFdReWerIfoTuQbN7KRx7ooZTs7c6YazvpQagH+yo
	aTzy8UheaxiYlPbupfbUCLk7sUvCuIGDQmiGe3MUqfazAlQH5Ph+bu6G93nCeDvTiXOgiIwKb0v
	NtrTNfr5+6Y/2brH5zyOA6n10tyu6owSD8TG1+peOpkvHg6hNf45C9V4J4kki+dFtXw==
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr134230999plb.187.1564954850803;
        Sun, 04 Aug 2019 14:40:50 -0700 (PDT)
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr134230968plb.187.1564954850230;
        Sun, 04 Aug 2019 14:40:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564954850; cv=none;
        d=google.com; s=arc-20160816;
        b=jN7qc5xhBZvi8KQZDkq/OY7cR8kpgTZdOrPkwxOJmbYBaSMDRKkvQE2twxrQi2stSb
         apm1676hTiL4JKeqn9NtQHq5jRWDnHAHUo4yLI5Xz7c/t0M/tIMhXUjSvSghNA7dqtDe
         sBB8HYyXgw3Pjla1pUCRxIlDTeho3o1A7RR76OL/wkG94LLt6CTgXOV1dhnsw+esbbkw
         sEZTFxSID5oqQjOMjG+pqpQzLgTJCuOePkbP/XwCvIFxdkWjN03/UA6oL7VwAJaaqdeb
         RILqOerVug4OiP+wlrMYHQHsjiSFs4zXIYMgUaOmokxu9j6OCnzgUbLreNAbz/Ksgu2T
         tLKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=eONDds99Vwa7FwXVcGeGemqLOJTYDb0PlQzPWtV3OXcijtsJhpZ72aVRs5V0HXraQB
         rn1nQlsFfqiQM8AToC4kTyV+eg6F2i1k0YH3DDajrIKGJLOReZsUuHdtz45o12QMgKjK
         y3mdmLm16hnZm6eQvcp61YX0iJ/eYqR0xqDHsuE9jYenA1zQd0qZ6FQyi0Rs1o88YJkk
         swBco3+4uPluldJu/7Bl/gDaZQEobpmxyhUNE2llXNVsRxunW3kvt/H3t/ccU6s/lQfJ
         blu/lUK0xQI3mDwAi3mcYnkrcPlLizesEL2Af9lB3iWN41uq6SKgSD8aCF+DURWZ1zBI
         q7iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HKywskhQ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor18006746pje.25.2019.08.04.14.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 14:40:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HKywskhQ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=HKywskhQFfCisurHq0YN1aLN2VuiPqiZvr/Y0yCqSOvBpKBB6dfn1Ks85FkIOYLagt
         IEjEo2P7HBbsv7VlhjnKuygjXzMpnPaIGsP10h9HDIdzZHjUPIC3xbgsZDjtJvPBVGli
         Q0JbJ4saQdgIeAacaN8voYvTrpABTrxgQ2M5TdIqar+aiYV4J+PYrFEofW0vtuiB1W8d
         opC4ViUFAQNDeWpOVJhlcHdA/+i8Qx8dpZcNxVU8J71QwLdaBiQj1o1QAdYA4aqniQge
         UufbAYoYs/svUAkwE0+PqikjTcfydpE8p7sULH9rSBFGj62Li+L68qWV/CJi6vPwTNy0
         c48Q==
X-Google-Smtp-Source: APXvYqy8FgpOqv4dwZxEbnr2U6myskz4yWgwHk7iGYAw3xfiu+D0Vw5P3EnbA0kXFBgzC5qKDZtyLg==
X-Received: by 2002:a17:90a:bf08:: with SMTP id c8mr15109867pjs.75.1564954849997;
        Sun, 04 Aug 2019 14:40:49 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 143sm123751024pgc.6.2019.08.04.14.40.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 14:40:49 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v6 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 14:40:42 -0700
Message-Id: <20190804214042.4564-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804214042.4564-1-jhubbard@nvidia.com>
References: <20190804214042.4564-1-jhubbard@nvidia.com>
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

Acked-by: Björn Töpel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/xdp/xdp_umem.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 83de74ca729a..17c4b3d3dc34 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
 
 static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 {
-	unsigned int i;
-
-	for (i = 0; i < umem->npgs; i++) {
-		struct page *page = umem->pgs[i];
-
-		set_page_dirty_lock(page);
-		put_page(page);
-	}
+	put_user_pages_dirty_lock(umem->pgs, umem->npgs, true);
 
 	kfree(umem->pgs);
 	umem->pgs = NULL;
-- 
2.22.0

