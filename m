Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84907C74A44
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AA43217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WuyyNqtp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA43217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12C0B6B0285; Tue,  6 Aug 2019 21:34:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B8A86B0286; Tue,  6 Aug 2019 21:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2D816B0287; Tue,  6 Aug 2019 21:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB466B0285
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w5so56029579pgs.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=gISuvrIA1Ne10hHnJmD9dYJLL0kD9GNduwsatAXeDprN2B41dYEf5ijDZrLfNpAtmB
         AeN41zR9Lm3XFUHYOY1Q9g1eYiIQH44LkywDYIv7vUL4bcu3cL9OX0F5eZ4NEAeUYPBM
         0O/Jv2PdzHi4bMhDBhCyOzUtcKJW9lusfmCMaEAH6sKQMqBNSCvBLA4OLmVVuZ2LGI89
         bjqIw3P/Eh6aIUNkLOR+vpEgEBuXnh91yyujBIc1MFIul5gseHEPt3GJVZY0pHwT6E8n
         X4OkmGLvGzBfdbcbkreyrbSUzNhbCRyjcHUDr8eirOH1j5Z1rQCudhbdXrCT9WIvtqnP
         l0og==
X-Gm-Message-State: APjAAAVMe9SETgTXU57pJTnGaDZUu4GznafWh2DI5rja2d/WvwkXM8UR
	Uj8+St2LXaY4r5YwLY7kueu4jhTjOqGa1OU6AqL8Thr8Ylhc3AhWJScFoxl9rt79Jquo6byqp8T
	mpgfyJeSMQ451PeIMdslk+kgpDr51JX37RuzzFRH6HVi6rttB5OFK9TX47deUfUvaSA==
X-Received: by 2002:a63:607:: with SMTP id 7mr5523287pgg.240.1565141680218;
        Tue, 06 Aug 2019 18:34:40 -0700 (PDT)
X-Received: by 2002:a63:607:: with SMTP id 7mr5523258pgg.240.1565141679498;
        Tue, 06 Aug 2019 18:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141679; cv=none;
        d=google.com; s=arc-20160816;
        b=fjoh6dfhf+zsUL/R59WjEvbpUioEjHyiJVg0+FDAeK36unJUbTePtwea/hzhVxnRXt
         cSrsm2o3+oKV1CfvYK0luwxc9ePwFXnq6EHevKiBD0v07+m4LnJDYbH1+CeUQ1HlQVa/
         a/+nJuvyeOuLP6Mcuua1VH5Vt+L6HqsoULhINY4EODKi3kT0wMdgt3zvSaJXMSsVIj+z
         Vgy+TBfOiE2pFyXi7odMxm3NFbjdaraYk+yFZqe+3qrzpuk+JbLuBVJd4RSb/pce8Z6n
         jVwKxlAZCHeOEfGiejhD+CmlKnVu743+WvjCv9ObrRyTzIb8rn/2R9+9tGtdBui92F5C
         WBfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=DKHKaq6NFr+/iroL8CcIivbiWQ1MdcYe+HPaqS+2nLO+cNxSSrKtRtmFn+UTiBuHAG
         wMIsxsxDD1wXXMD1CeK+ZyryfWg0oIU5+iealHasxsMP78wrUWj0SHUw+hQcP8m9BHfw
         ZNCBKw5FxvBswI37fqn1+s/rPYSsy52Dp2VsSdr5/GORpAUyEZioNOD9tvHN13IDvHNc
         92X2hA7tHoZUHdw1eAh3KCN47rlmL8AlL9Bm/EdkMsBQ1DAX1cVPTBYzJYWaeK+cot5g
         NvopUUYps25UoqKasQV+M1dsh6k53p6tNwJ6STsXU4fDvCDzP/i0qA3j7SYkEAOJqB4I
         Vtlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WuyyNqtp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj2sor105774840plb.52.2019.08.06.18.34.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WuyyNqtp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=WuyyNqtpvvlvZwulsOSyl6jjDfFZFL7/Zx5rMnqGOdxDRsEuGcdgN1IewvAvlX+Ui3
         X7btLnm2F40F8RrpBhgVrMU3HOKje9DtE5nK+fpNzyjny+e0S7JZDS2kjkLoxOZDXhQl
         8/grXg9y3uP/GW5F5PAwd4bWzrVFH3BCp78Eig9BKFd6aIXye5gDuBBhD5viuX1OApXQ
         9VIP+L4AUKM2VFr2nldHjLjmSVNA49QX09uR5xAkxNN9xQUujG5Q/Q0AKTjDZbsxdlOq
         g4tQx0EnIYd52Zy5p9V4faNYnaj9xyaWhFJDGaxmSVhObIkgzad4uex02Ars3KOUlzef
         YWIw==
X-Google-Smtp-Source: APXvYqxeu3U+gXlTZOXb8hdX/T/5F9QSVWlhZwpRfNn+ISG+GmBUrBJWAvgFajanndvmV9JUd/JHZg==
X-Received: by 2002:a17:902:a606:: with SMTP id u6mr5434497plq.275.1565141679262;
        Tue, 06 Aug 2019 18:34:39 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:38 -0700 (PDT)
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
Subject: [PATCH v3 34/41] goldfish_pipe: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:33 -0700
Message-Id: <20190807013340.9706-35-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

As Christoph Hellwig put it, "set_page_dirty() is only safe if we are
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

