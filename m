Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B5C9C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25AD8217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SVC7DSqJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25AD8217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71EF26B0008; Tue,  6 Aug 2019 21:33:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65D7C6B000A; Tue,  6 Aug 2019 21:33:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48BB26B000C; Tue,  6 Aug 2019 21:33:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2226B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so57183789pfe.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=oRaNWju2L+mzjbW1A1+zWLd8FIg/hDLf8o9AYPEkc4hE7tzFOC4DB/o6HkFOfCTjQW
         lWTGajLgd84SHkeD4USR9D38TxRn2antH6F+NRIa007IoCsImgGXjcqI+EKNtkO9CSFD
         gH8IH2GmJIMH3SQSjiXehdBiAd5nbg47nrHgv41jYIx5zGyQIHR5N55xybRfp5JAjWKm
         osiZLkomx5JF3ZJN/Xlk6NjQClN8UmlsdDURN9X6OXD+OS3Fg5w0s+rVOD1wjhBDBYQf
         Sxy9ogT9b47p0EwJSFYjdx2CO7/r15Y5yOX0Tn4YRi60Qf9UofFC7O1KgowihlC+RrPK
         XWhA==
X-Gm-Message-State: APjAAAWWfhFrsJi4TBJYd2Nd42+cU+gyL6pIB6RiAJkidxTaiHaX0zRx
	8AGVwSx5uExyjoN4ODhPwuI21IHtCDqve9ccHwz4LD8H6ZLNbErq6T5qRCuPjjoLqRYdsZSlld7
	14Mmqt2nhS7VeqMd8QN81nTamTxYOrEVWvfOaFLRaKflipG2W2Trl9BaCaGCFOVWoeg==
X-Received: by 2002:a63:f048:: with SMTP id s8mr5442410pgj.26.1565141630647;
        Tue, 06 Aug 2019 18:33:50 -0700 (PDT)
X-Received: by 2002:a63:f048:: with SMTP id s8mr5442368pgj.26.1565141629698;
        Tue, 06 Aug 2019 18:33:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141629; cv=none;
        d=google.com; s=arc-20160816;
        b=VOgqQUjO/MCz7xHUJjFafKJA+AuN9zf5mAjQjlGuGYdnAKHQ6ioTERwObktmHMbTfr
         c8Nazl4mQ+D01wrXjICaFIZ55bTXpqjsF8ggVyqUV7f3ZhjwrQ1ceDH2/xCMAODbY3Ob
         XuGq4P7vmYTo+BSrNdKddH5HAJrgrpPOhTASW6OGUjrgI8IiX6qq5DxCyGLGsG1NLp9o
         EOsPdlC+g/bnbSaZ+egTH6PtH10D+eaFhWiAt6o0p4zpsrcYFykleIV+bow/Fynd1uII
         WUAe7wGHQ5GLBjVIExLDWam9bvNbdA419aUPvv6egzhDKXQ6J5w9TayXYTHc3ILaPWcB
         4UiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=G3gmiPtWWczY5L5yidP3Skmk9gwLLPXuWk8LdVTTNtkjubFbR3TcD/BEwEI9kWkZ8J
         9hZq6tLpSJa8l9OtulWSZ9DpzaV9FLZeM0AnJQya6T92c7AefVZ4bJ6UIuXlLIqRHzZV
         HBwAM9hKzc60bSfKueALQ0dAT0CvFzKH7MMPLGLBWTZzeV09m9V3uG9KjYEPfHksS/XJ
         n4QlN6vtjSU6U54HjR+KFzXULwhicy6obC57Au9v+5KCpAHXbCuABNDt6Pf0lGmwft4v
         +Grmg1PwCL5cdo/+4PsQ+JqETY42oXl+f6JaX4EULXeDIjTJvuK5+vTtiN3eeZcmj3Yn
         FqGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SVC7DSqJ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor27084085pjk.27.2019.08.06.18.33.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SVC7DSqJ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GHzc1obwFKwJgG7nswfPGhmCYytguM8zaNUDmj5ciqU=;
        b=SVC7DSqJ1aViuFyLacSuD9ekUuon1nsbmGXQ+rccZqQD0M5OpWv4FInOJYOUS0zDrw
         iiaUKlpU3oYT6EB+TLC7fde9FCQbqLPjcDOo/pPYr/Dy4w9ZLyTeVh++4NmqxXNEZ0Um
         gS5DfjjL21uHhIzIHJrVsnAGurOzAGDNfpv0OIjYG3RHWT96uJJIGB6LIuNQuZVc7Ym2
         eeEnUQ4CldleB6IB/9Fxp6/W0nXsF/e4MjOETkKBsrMtb7StZJlqXJT9WcIpX7tnyI6X
         9gewZeHtS0mR3vhC08tQKk4aqf3pL5knJE/hrGJP04i1jVNIaCHMRTQVdWFD0VLC/Xeg
         c3+Q==
X-Google-Smtp-Source: APXvYqxeOvPea8wN4/1KbcpbOcv0WCKYw/yUT+8N/xQtvHJFmkBBq3xYGl9YYXdHhoFcN7NXCSJlJw==
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr5992770pjz.117.1565141629443;
        Tue, 06 Aug 2019 18:33:49 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:48 -0700 (PDT)
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
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH v3 03/41] net/xdp: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:02 -0700
Message-Id: <20190807013340.9706-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

