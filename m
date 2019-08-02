Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89D7DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 414DB2084C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hrmJ0pEU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 414DB2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBDD86B0284; Thu,  1 Aug 2019 22:21:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D22456B0285; Thu,  1 Aug 2019 22:21:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A88DA6B0286; Thu,  1 Aug 2019 22:21:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4B86B0284
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:21:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so37490469pgh.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:21:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=t4E5L+nteFApbv8x9BTzZhAA9CrCHyfc4N+4wDD55sE=;
        b=Ak2QGkg3Nfvo7mjGH3nWttdH0peZTEB/rNcMSFTpzkvYtFE32qSprIYcdFyIsonqIT
         oOXnvrHr8SG0Q8O6cwDzPJDmzk2wIVEWWl9qGIzkhSOH0sTZb9IpfZrc6cRuM2mLOneS
         OUv1MKyw2saC2Ex1IK40gEiD0LbKEpw0LETMteuLndq9CHH2REIUijDt0f8bTJv+NwSU
         3MYkjYPj51bD3QysFwyk0YzRBBN0UKYQ2qTb6XKlW4BsnWT440WhIWQnhCQkC526Vsj5
         SP8kpnWPwr5ByCP46wg/iJhQkibs653alHb6NMYN4w7kolZRfsGcooST/ObzhmCGOnuA
         3sPQ==
X-Gm-Message-State: APjAAAWJXkzzx5K75UlvH4Kp3pLEOZAQRzo1LdYmdTA/CydrrafN7Fuz
	Fq7HuSj36AvUdO6dgk6DHVR4PKqwMdugW+U5flJc2hTtMNP1j4XEBcC9yZwA1f+sefvvvQ84mlV
	4umW5nJ9Bo4DKD7wY3xO3RloH7dQtcVHutycCz6HNXG8xHW7qWXhZgCTn2k+pTvSEOA==
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr124695881plk.225.1564712463113;
        Thu, 01 Aug 2019 19:21:03 -0700 (PDT)
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr124695831plk.225.1564712462319;
        Thu, 01 Aug 2019 19:21:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712462; cv=none;
        d=google.com; s=arc-20160816;
        b=ug0RBwrpEHsKJ/al+Z4+lnvUP8tjgXkM8vDJAVm0ppdFs8rYyqR/MB/f2VX6apQv8u
         JopGA5KYTOtLJIAdywm7G2FpWioj/62i7Yi511xW1Hl+lbTXQ5r7Uh5cgE6YbINTkkXs
         jCSbIOkrZDKaMQHBffiH09EtJY6+76Yo5RucmPebV711J7QZPdIvsXiwHC5OJyilAOtN
         NMCYzh/ULoUu4YXSS/cDoCrsLgAtX00A6/KIx/Bel6V13N5MkiGNhJuRbpINT66/5pnx
         upkuSbgN8sn5aJcV+TsOuTMYHlpLQB7ETdpt47JA+oR8+Upv2vzMHBY7pq/yo0upf5dj
         RVRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=t4E5L+nteFApbv8x9BTzZhAA9CrCHyfc4N+4wDD55sE=;
        b=l/aBVBLF1bdn1HsozAX2EjTszr74L0scCnYK5uHH1VDBB1MQcjSQBB+0tSp6mQns7M
         1eT6RgL7Y1PVEpqAryhvzmoMfX9AbHSRsUUe52i0DnJijgRCw/U7jeMbptmE6Z9kKrzV
         nyEhyOW47UdUAOoETTUd4AN5ToALV2YbxknsKvpLW4Ysmj4aYa7DsJuVTbviVBXv201I
         tlozE6tqlPdSS/Uw54LshHP3yp9AtHUr0jg1BBOSgVMHryMzV/oq/mesyBuHM8xgFXY3
         kTfJlC7yUorox+B7KYtK3h0milklCdz/bg2ZDK2wxNePm+eoMjaKLdCja6U0mJZ8zcUA
         lSTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hrmJ0pEU;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21sor88289337pll.8.2019.08.01.19.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:21:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hrmJ0pEU;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=t4E5L+nteFApbv8x9BTzZhAA9CrCHyfc4N+4wDD55sE=;
        b=hrmJ0pEUxxlEVbmnkJiCuXB+z0obVkpM5OAxcIB8ex62qKsRGc8GrJbesoMFhr0ezJ
         BB7gqJEvJ/0j1sMNBYjptk6WEDqh/SuRhAh3YnXCDA+D03E9VD/w0ZTpWsRp/gFtvqDb
         GPSJBQRO2YGZ2n4ciW9tAFCe3EDjB9OuDXHwxqBfuLFzCDYC5sbEZNesZN0XL0xy/T+d
         A/rrSMYh6KaPOeAYQGAhhvKvLVo5NyuQKSBc7dnWcPrp/sW9C+D3tHmYcyJ9WgLD0vU4
         zE+pn4brWMiLPK0lo9h6ZHMbPaOqGStN6e8qWC9iDeImsGRohVaoMFw5HAYT+EunHz7d
         Gu7A==
X-Google-Smtp-Source: APXvYqwMLKf8AGC5hDWCQUPLqudyxsaLfy2JXIWmRI5mzRP+HqysSD+VYVGt/11B9bnV5geCVBXglQ==
X-Received: by 2002:a17:902:20ec:: with SMTP id v41mr122012162plg.142.1564712462015;
        Thu, 01 Aug 2019 19:21:02 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.21.00
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:21:01 -0700 (PDT)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Roman Kiryanov <rkir@google.com>
Subject: [PATCH 32/34] goldfish_pipe: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:03 -0700
Message-Id: <20190802022005.5117-33-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

Note that this effectively changes the code's behavior in
qp_release_pages(): it now ultimately calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christophe Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Roman Kiryanov <rkir@google.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/platform/goldfish/goldfish_pipe.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index cef0133aa47a..2bd21020e288 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -288,15 +288,12 @@ static int pin_user_pages(unsigned long first_page,
 static void release_user_pages(struct page **pages, int pages_count,
 			       int is_write, s32 consumed_size)
 {
-	int i;
+	bool dirty = !is_write && consumed_size > 0;
 
-	for (i = 0; i < pages_count; i++) {
-		if (!is_write && consumed_size > 0)
-			set_page_dirty(pages[i]);
-		put_page(pages[i]);
-	}
+	put_user_pages_dirty_lock(pages, pages_count, dirty);
 }
 
+
 /* Populate the call parameters, merging adjacent pages together */
 static void populate_rw_params(struct page **pages,
 			       int pages_count,
-- 
2.22.0

