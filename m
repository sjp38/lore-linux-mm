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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76039C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A0A21842
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DhwBCoFC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A0A21842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB1BA6B000A; Sun,  4 Aug 2019 18:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3A286B000C; Sun,  4 Aug 2019 18:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8F066B000D; Sun,  4 Aug 2019 18:49:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDFE6B000A
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so52121843pfk.14
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=AazOPGQOkJRSwf41cxvkOl6L+sRmmkji9cpBczlR8yo1WBZCCRZ9H9f9C6+mKGznDy
         lvtzAiYXNwULCl/uuBUAwQ1pyO3yTBPtPeQWCufY5iT9SraZg9MdOT71XnY/oxBkreZx
         uPVtH7ZGySaeTgUTlZdOim3aHoXoxYPCrMdVp09J1JWq98HIjFMVLy4iVIYJ14rYRlkq
         TDt4rSGYCl/oewofGga93KWK/8JgZmTDDERz+eUTq3/J3xCnKqdecxQTusHIks1IA2Ih
         bnIXc7CLxq5RF4QuG7c+Yf+wYjfYHhaLAekWZTPPKEeQaRo12VC37ouZP9IORDr5eWeb
         E3+A==
X-Gm-Message-State: APjAAAVrVzwXpsdRUq3lgWx3/KYaYM47LMcRWh4nCyGAtMVkc1lbNQvD
	AfKZOOvwPCTK6S+dcS8DzdG2RaA109ekB+lo1ZkkZLeZWhNp8KZ86mNghHuZNYVk++ySYXf4nJf
	ikA18RN8UyTZ3IGjeOWAecsN5ynig9BBvKe8GMV6G36kjXJZzijBS6KxaQ3TTzbVjVw==
X-Received: by 2002:a17:902:8490:: with SMTP id c16mr144652986plo.1.1564958968150;
        Sun, 04 Aug 2019 15:49:28 -0700 (PDT)
X-Received: by 2002:a17:902:8490:: with SMTP id c16mr144652956plo.1.1564958967252;
        Sun, 04 Aug 2019 15:49:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958967; cv=none;
        d=google.com; s=arc-20160816;
        b=OTcGivCCgobdfVd0Vel8lY283Nz52IAx/doWw+TORDXx1DWEUMh4gka1UrS85IJnEk
         vP23yQBqsY3tVZnv8UyVBP2BHbaX2mfVAGJAexwbsNkny17bnI6E3Yc5jZ31iO61TS0b
         sfLxO6wDjo7ZvrXPNe+74cU8/KrW8+7ZZxUhaXix0YvMWbYip7GsJlGLOy4Xzkgs4OSZ
         nfr6E8sOYzaT4lwy+zDaLrCIdgA0Ue9TEtabggCuUdlByVwp7ue9tLK07EbGlaeov50V
         8xjRkgA56lHv6EB6m6hbC6TAELEzTBjtdXITUDBA5xzCCABoeGvQK4bh2EEeyTCR5g+J
         BeOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=dqLa2a6fh5Iwb+qULS8Ml6z5XB81uUhNdL270M7uagYHpKk/zehowsf65CTw+l6ys8
         pucNQyynvjWjosoTrjW+gwm2sYhJ+BZR5F3aZjZOkfTX7gjEUIgGZ9+DWwSWsojTyvbK
         kZ5WqrVzqyXi4kRHqgNUi3FtFT0KVAhzQp3FvssebuIQZoEhWulPTHlKphxObso60kWB
         aMmAdYBPjCQtjeMYXu6JCF2s/key6Ra+FMDv3TngdHLVk+z8onvFw9MkpnQYgM717sjH
         FjJ4F4eAqki5r95RXp/A/on5ilp3x2FBCym3B8SfxTKUIlJcKSMLekL8Kja75lJxMkVY
         0Qig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DhwBCoFC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14sor9605117pgl.40.2019.08.04.15.49.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DhwBCoFC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=DhwBCoFCjpXXdmoliRK4JR+mRQlogKVYcH9LUuFtCy5jqYLU3k2OV3s9LP9elRQpt2
         2Qt+Jvy9o/orbaOtkd5nujRaPffgwNAgLXVc5HDVur7G30S2Sl9zwlVnpzafHXHFDZ1Y
         umZN5BHQdMTYT4X05o9uchQBU3Ah8LnDb0ocwD8ZU/M3RqzWJ8pCyTsH7SaHwW7GrjOD
         aK4wvB8Fvq+qEmTkGzq512g25DZ6euAbWJjnzFQ81OfVHghvVkS7cIlTWY1k0D9tavPD
         XawoZ7kFyduEl8FG9r2zLh1TsUY0NTur+fJ3ZJLf5PCbd+OiidMkSeuctXmr4WSpmpht
         zqKQ==
X-Google-Smtp-Source: APXvYqzRKprB2NEk077YJTrqhmGmbwyku3vUkgW0ycQFuEdLCQ5MyA814ojj8/NKptlwnKhmOHLKBQ==
X-Received: by 2002:a65:6815:: with SMTP id l21mr45892702pgt.146.1564958966963;
        Sun, 04 Aug 2019 15:49:26 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:26 -0700 (PDT)
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
	Joerg Roedel <joro@8bytes.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>
Subject: [PATCH v2 05/34] drm/etnaviv: convert release_pages() to put_user_pages()
Date: Sun,  4 Aug 2019 15:48:46 -0700
Message-Id: <20190804224915.28669-6-jhubbard@nvidia.com>
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

Cc: Joerg Roedel <joro@8bytes.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: x86@kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/etnaviv/etnaviv_gem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index e8778ebb72e6..a0144a5ee325 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -686,7 +686,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
 		ret = get_user_pages_fast(ptr, num_pages,
 					  !userptr->ro ? FOLL_WRITE : 0, pages);
 		if (ret < 0) {
-			release_pages(pvec, pinned);
+			put_user_pages(pvec, pinned);
 			kvfree(pvec);
 			return ret;
 		}
@@ -710,7 +710,7 @@ static void etnaviv_gem_userptr_release(struct etnaviv_gem_object *etnaviv_obj)
 	if (etnaviv_obj->pages) {
 		int npages = etnaviv_obj->base.size >> PAGE_SHIFT;
 
-		release_pages(etnaviv_obj->pages, npages);
+		put_user_pages(etnaviv_obj->pages, npages);
 		kvfree(etnaviv_obj->pages);
 	}
 }
-- 
2.22.0

