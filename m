Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE6D2C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 762A221985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sw0HvJJT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 762A221985
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0AE76B000A; Mon, 22 Jul 2019 18:34:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8EC36B000C; Mon, 22 Jul 2019 18:34:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46C18E0001; Mon, 22 Jul 2019 18:34:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76B506B000A
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:34:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g21so24768897pfb.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/ofa5EhPy5N+KM7nweAsOE7rWC5Duznu1d2IMlN4I/Y=;
        b=BZ3TCPpbiJLlHZFwV7CdoSOGvZccq7/Fkj9mviNWJAz9FwXICnFwN8eJ1BMwZMiXwW
         81FupCUBlExW7y2pzZItf2Hx6v765IzxUgxz7AlEomrSoe4eHOT5vFh4aO8EW0IHxoIF
         bvfnPF0VhskprCZ62DeogFaSIg5Sb4PuvdPJXqASPUOdJ1XP3O0pLSkLoM0u3zqtPf6t
         4+XZOgurEpq6vhB85t8j8yfVlIwoFITm84y3X11wmiUnchAE3ZkNTuOxIlprfTkLTK1X
         3KYmF1awuuk6ggVJfZWitlR7L8H3z10l4jfrov2ZqV1cMdsvaEfqcjN/v56M91h+brdE
         CrHw==
X-Gm-Message-State: APjAAAUL9flZ2WCa8JuPYoehv/vTyIb3Xp2838iTr7esENJ6qC0Y1W7X
	SyXLgtr+CFvW8EY778uVYBWcZwTx45tXjBKxZD3S9pv288rX66rMT7R1G7Zx3rB18cjFM8S6aW+
	yCAgwiDGgZIAgFNOc2wL4tT7lsFcr9eLholReRt70UIQvjlhe9ci7cmASb9SMjQqknw==
X-Received: by 2002:a62:f202:: with SMTP id m2mr2585504pfh.6.1563834864180;
        Mon, 22 Jul 2019 15:34:24 -0700 (PDT)
X-Received: by 2002:a62:f202:: with SMTP id m2mr2585458pfh.6.1563834863434;
        Mon, 22 Jul 2019 15:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563834863; cv=none;
        d=google.com; s=arc-20160816;
        b=OZo2qirEC1iqjRwXLYV+JJUIDd7TikOMQrbvHbpmIXlFnU0+7UnhDptftE5zrX6kGC
         WpIju4DYNUEyH6jvQI5r3EQoggtMWlOzoVpfy/TmpcvZOzkECIBYf+AYq+nuW2IvO2CH
         ED6SaQyXGLiXfRdJcTD8lH9EIS0IQ2dcOFyvJqQKpqYkZ6kEH1daB+lY6UEmZ4PpZFIE
         44lYKoCCLTopDANC2Lr0rhtJg9x0vA41emWRWpBjbPhAEJR2IlN08ltIMJPOWN22swD0
         LqUlL/4XLcLRBzKDWBD/jHpJZ635P9IiXSgF71yBf71s6OyZOcnUdpjw+wKFP6NvkY+r
         DaCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/ofa5EhPy5N+KM7nweAsOE7rWC5Duznu1d2IMlN4I/Y=;
        b=BQb/MfyI0BeNFXB7dsbhUVwOtENPjSPT2ODEsF6auxdaPUfjAX+NPgzKs8/GWw6PUl
         KAB7V9LHtK2GtCAmcOsTe7PKOLg19ZKqu3wyE9dXj2ZGewdIjmRkT93yUSdn4FHnv8Y0
         XKYOIAgKYnzuoB5+Cqd0ox1kEBDnkmzQtvqGbQdxf7M+3yZpGA1Ih2bOMuG1FIWI1LDU
         JvF0XW52Dqui5B7cfe039DyavQgE/FYm+TQ1dE2wf85n1kxSEJxc1W0ZqOXMHAt53HtH
         kblKTUHlBoKDF5cUHqB1EMJrQzTkYtLuV/0BMr8MA78ZzCX6ozfcmLEsz0jdZdWak+9s
         45+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sw0HvJJT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor6337297pfa.44.2019.07.22.15.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 15:34:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sw0HvJJT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/ofa5EhPy5N+KM7nweAsOE7rWC5Duznu1d2IMlN4I/Y=;
        b=Sw0HvJJTDmzbJlbRnGPA0tEKa9wBsoXOpSBSyyCpXXoTDy/oLlPojLp975N/iZT3Rt
         8jfBQuYyMJoyHlJ2fyV7WUkxYIldTegTihpxRiAvNY8zRba3PO9qS3NZSvTUxei06Rk0
         uOGdeG1FwadWsIBYlsr2yV0g+UwUeH2FEFiAyASHNNXam+5nvwUOaLXqS8GitFl6ninp
         eVYAIz6e9bu5JJNLX4jLtYsSme3OBg4qojzmnb1QA+ka0SBTx6a2p/N+h2SdySOnbmnd
         qH6vvH98sRnmJjM2M9uSzbppXdvFGZyQFLd9B0l+ZOt4ywhtBFZH/zZ3Y6U5IOl5jKuB
         XGJA==
X-Google-Smtp-Source: APXvYqwVaJn+EzirdPn13F0RFZ1U5rQgVF9dbTt0Dcd+iQUjCIySQADzRQKVKnRyYTBRNLHQ9Mrw9A==
X-Received: by 2002:a62:7990:: with SMTP id u138mr2390135pfc.191.1563834863230;
        Mon, 22 Jul 2019 15:34:23 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r18sm30597570pfg.77.2019.07.22.15.34.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 15:34:22 -0700 (PDT)
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
Subject: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Mon, 22 Jul 2019 15:34:15 -0700
Message-Id: <20190722223415.13269-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722223415.13269-1-jhubbard@nvidia.com>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
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

Cc: Björn Töpel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/xdp/xdp_umem.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 83de74ca729a..0325a17915de 100644
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
+	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
 
 	kfree(umem->pgs);
 	umem->pgs = NULL;
-- 
2.22.0

