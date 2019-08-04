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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30C06C32754
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB0C4217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P8+hbDz6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB0C4217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81FB76B0273; Sun,  4 Aug 2019 18:49:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 731D06B0274; Sun,  4 Aug 2019 18:49:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537C76B0275; Sun,  4 Aug 2019 18:49:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 147D56B0273
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id p15so7779589pgl.18
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=mBSoASXNCUiXlWGgRU4VORxj9cfcH38flqsz9IEDc97GkIh4L82tNBrsfWwu1TBcQh
         H1mRfzIYiyjXY+0adKCZFARNjuvUd8Wt8uyPVswcL44WbBflqxN1uuYthZY2g2P6LvkZ
         9lrRod81aDrimTCgfB15i2P7MaeayAgxDQ8LmEZMKc1M7jywSOi4L1Mq1WH0TnvUxu2k
         RGDrpFOUZl5EKD/BrgsyRLm6laRQ4LDLm/kLKHdQFrGGiBYLHungmHOeoa8M9/KToQQp
         tAFumR7JkoRyS8DYBkw3/dbdLZ8b1XJgsrPP0OCuj0qzQydO/J2D3Jzkg4FWN2GlQTdc
         qJ5A==
X-Gm-Message-State: APjAAAV9FVMSQOIYAObyQtgPgcbTqdk1zAzYdULHzfnN7f3CWvznN4nX
	T7hTTlWu8grMWMhTpDEUnRifnjfTlkYMDqnhJ/1xzWwJKEh7FDUubUJJCK4z7AwS+LTrzLeVbaS
	xo/3LgapqmOr8L8QMipirYaZ33PbaYNrEOukggH4wOEiZqvFc4+atQ4WP398VvYv2lg==
X-Received: by 2002:a63:3407:: with SMTP id b7mr22111207pga.143.1564958990673;
        Sun, 04 Aug 2019 15:49:50 -0700 (PDT)
X-Received: by 2002:a63:3407:: with SMTP id b7mr22111163pga.143.1564958989747;
        Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958989; cv=none;
        d=google.com; s=arc-20160816;
        b=SkATWp242p5Y+wKAlKsLaMDyhHOSxuPiyus6dS7dQ0eKmxzcFzrtbHAgwwsI/k2mtf
         eeKUmykwkHWPtUzIveIlobNENh7kXBCYqjt0fBpNqo7vTNlXDOCE4NA97ErR1S2zJBuW
         mrwQJwcMagCPXRgo7WJCTDl7TZkDDJ+GE2TOprWf/qSwigcyNNveC2CCq8pu1bkRRsnV
         yPX5H0/Hi094SSx78+x9wp/c4Yxw5qY8/pCQ5hMYgxW/kGtac+2xU4yq/c8LPYvAtleU
         OVImk4JamvTytWGSjLt0Yf7TmyqeSx6l0wNzY422aTWS1u6wX2sycZLJHwJp2yEV/Wva
         kaTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=gPUAzly7P4g8+zzUL2kJqfhdt59X4nyGo+LfeBbC9pEglQKNkPC/Hn86IDM8RqBbYv
         C4Ha1mNi6tENcbQHCN+47x6IOMTCnVCdPLxZ/tJI2HEefAHNJSUV81VOdNSSuSNuuJW6
         yLCxDY5xgCgY4Y/LvlT1iQ+eFsFWJjBfIbH4gM0afJWcvarXOQD1eb4x2lVBnAZmZbJ/
         FGXIedquCwVPaoVkFzO70B16MFYvu9XCBbmGqYGi6+fBHf0ZdmA5iH+KW7M6Dr4dsh0o
         Nsl5B7dy75SbVeShVVd7CHzb/q9+3kO4Can+5a2t0TL5nsz7eFO9gG7DRB77HdyzAUaJ
         PG3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P8+hbDz6;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor6723143pgq.9.2019.08.04.15.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P8+hbDz6;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=P8+hbDz6iDdAtFosRygKfZrawOprY/RqOz+jkdBR9/iAK9lQTDaHpPD0YVzeAsadTA
         6buCCtQt6FcRN+b9XggnJ5bqnrb15u93xXHo/kWkRIj/AEZJAg96rbyj3hSasGDU5QMN
         kLomBnFCn//tdm3UAsqLPAHdx4izNhPtZ1DR2n/EeVgTygzhGs4N/AXfq0vWNV5wg6OG
         nDjWxo9WfIwu4zNuVNFOgCWRwLE7DfTE0h0+OhqrWzWxBngYRK81NL6ifxTbjwc0Tsbz
         dA0CzQ264QnjubFwn/fuuREzrVo+nBB4mnVLQqsZ8A+pWd/WcxXuqwIjuSU30F6iEjCB
         X4GA==
X-Google-Smtp-Source: APXvYqyegNlmLCsE27HWcwEQVob39MHAl+cimFnsXUYquTno1Yk7+aU+Agg2DBt67SqnkuavcPllBQ==
X-Received: by 2002:a63:29c4:: with SMTP id p187mr82820390pgp.330.1564958989494;
        Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
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
	Al Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	Rob Herring <robh@kernel.org>
Subject: [PATCH v2 19/34] fsl_hypervisor: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:00 -0700
Message-Id: <20190804224915.28669-20-jhubbard@nvidia.com>
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

This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>
Cc: Rob Herring <robh@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/virt/fsl_hypervisor.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 93d5bebf9572..a8f78d572c45 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -292,11 +292,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 		virt_to_phys(sg_list), num_pages);
 
 exit:
-	if (pages) {
-		for (i = 0; i < num_pages; i++)
-			if (pages[i])
-				put_page(pages[i]);
-	}
+	if (pages)
+		put_user_pages(pages, num_pages);
 
 	kfree(sg_list_unaligned);
 	kfree(pages);
-- 
2.22.0

