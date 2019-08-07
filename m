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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A2D2C41530
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9F9B2186A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iMIf7vv1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9F9B2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A746B0274; Tue,  6 Aug 2019 21:34:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76B026B0275; Tue,  6 Aug 2019 21:34:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BDCE6B0276; Tue,  6 Aug 2019 21:34:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 258FA6B0274
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ci3so6850035plb.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=q1USgCTTypYisHCl/Se0wxD5RtmeUkcARx5avQ5w9QR2d3rfw6dBGG9GO48b0TK/Lv
         h8JvOIm1QlTLDZVZtabh56fqUJj5nEJZ1iKoGAVx7Zi9wSbEUmYc9hFawNzDaIqXCBbg
         YdRXkI8Hzkcsl+wMjHPzvHlp2Ji+dy7GEEE6h0mEL7RxOluCYutzaK//8JieS51bTQ2R
         OFSGBkWtl149PtoVV8Q4bdDc9vDpKY14uPvj9ETOG5V0jf1ZnETFtscxZMSCgHJBERw3
         GIO7oY14jqKX1Mu1DM+lP93fNWS/Aa7OunrtHzZ7nJc3fVEtANP5R4bQBRXOs/8ob6n5
         PJIg==
X-Gm-Message-State: APjAAAUP65cZTdBlAwda4nx5eoVeUiJVmK3pGTzzuCLZBzw9jdS3zUw5
	jCznjxyuorqXWAxZuwvZskXH/4eKbJ2bBmZm1/+M6xdJ+GwBV/XsvBhYaNm9m6kv+376WWGgiwW
	KWJUsmBVQsy3mqT126kBTvp7kHWU2+LkKhHKj4xHYOsHMtmtzFYigZGm//isrEZIteA==
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr6062958pjq.142.1565141659842;
        Tue, 06 Aug 2019 18:34:19 -0700 (PDT)
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr6062912pjq.142.1565141658931;
        Tue, 06 Aug 2019 18:34:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141658; cv=none;
        d=google.com; s=arc-20160816;
        b=ZF/BGHU5rc1agDAKAuk0TGf5g87YMhJkcDvRAku0cgJN0hs2Wl9VR3gA+vVSgqEuTU
         S0Z0P2s2l/CbXrftxeX94HBnubmamyrMi1RpCcyBXXiQqRxuhpBxS31JMpA4tGjR4pcK
         tUcHvOoa5Hw49mz15yQfgXOGTp0QO0IzyOx7OZsSclA3mJe8qnA/KLRj0kPtfmF6cCTw
         kcjMOwqFoQ6yP7GkSocE/gpjY99Cy9lHGhosDfpQdbOex68dXtegD4WGS0E/0bDPRSUA
         JkMoBJk6crbFBVj3+o6mloQhXpFtWZBhkIrwkvOabixooMzt/ufcT7hZeuwBCgyqW5aU
         fRrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=hMVKe1t6yP2AttvHt29tKEAfHibHrmFroSFxHF73XoEjwdBCNaImsojlQ3lmnv3846
         1JIqAKePgP+Peh4uRl7KJpQ2SMfA8d70RC2U3TPLqXgtIXMJZqW+aeInCrhpLYuhouC9
         Hbfoo9l5tL9sg085IhUgMcGRvKkORVwNplIRhpi/QH3D6nDFEdIBEzbKJjS3gKe+Q0Sk
         oP6PgEVks497OkYb45rElG6PzUro6/kRC5JPuXdabkmU3C/gxuPw30vwtrkcsWEMDlbn
         xpp8jR933jOfFafE0pXe4ofViY8wHXp2+VA7gLtpvBNMkcIJenhC58IsTjSoPuA2Lzrg
         eP4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iMIf7vv1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor26289137pje.25.2019.08.06.18.34.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iMIf7vv1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=iMIf7vv1OqjXs/pb2O80RbThn+V5BnR0qPinv0FzH0+g7xzprGLZVDhHDxqDtetcXv
         SaFnJoqNzRoFcPTVGSdSF8TWmFRSDY6HyI/xKEnGPkkBlyCLQ6e2r6EYWiPfaVK2Vmzt
         JZbyLYWCDWgBCgJU9imVgUMeONuNrElpVb025PXYsw4Ce7zDMpi0HqX5tsCmiW5ztLIV
         YDzIY1y6BpKbNCZAoclL3hg7itbVU1NhtHk3aXipSm7TKgtN0MS2OckyNUh0niZVwB8z
         njr19wA60AtVpgYuy80idYiGH3Z0ffMXU+t6KgBLR+IFYvULEDog7RhMgjNZybcJ+5TY
         bmmA==
X-Google-Smtp-Source: APXvYqzEjGdQT4zwHkPHC3zuchqcBixfKdrLByyRaCgYuUpeMBSsZZqsbT+G0enkm62MLPirbgVZ8A==
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr5782148pjb.138.1565141658674;
        Tue, 06 Aug 2019 18:34:18 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:18 -0700 (PDT)
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
Subject: [PATCH v3 21/41] fsl_hypervisor: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:20 -0700
Message-Id: <20190807013340.9706-22-jhubbard@nvidia.com>
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

