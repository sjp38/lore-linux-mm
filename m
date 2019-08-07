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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F272C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E927D2173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WodjfRMN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E927D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6834A6B000E; Tue,  6 Aug 2019 21:33:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EECA6B0010; Tue,  6 Aug 2019 21:33:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3003E6B0266; Tue,  6 Aug 2019 21:33:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE2F06B000E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w5so56028586pgs.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=NZcNfI7whKxwf28cR21Oh/tbCxj6KLOvBYptJPs6QryGsDUAYTZPPW2KC/8Nof46kp
         FnWY9nxbqHniBBTjql8ObZdHix9vzI4IBV7zJaYR4xGIp8tOnYIDBEu4v/nhC0O4jIb8
         aaJWpQBJKf7BZvPxiy/h7nm1ubedbXJ4r7zN3kAyfNfoiiDdfmjm9JQZHnVOqOnIMUuz
         1f4lnWlQVB/eJNmnIqXG9uGfIKUJj1L3yj6HR5dGT04b3ix10K1OSNV/pz5dWrA1/AA2
         8NHbqQRy23dcJUNbZ0qqwuOI/f0o8whLz5F7g/2648RiU5HCM8+HUcIDtX7WvfVwllmh
         4Rtg==
X-Gm-Message-State: APjAAAXLeDfwtVQ00lnBMfD/LdUOsWek2pVtqu52hPPs0/RSeVpkklJ6
	gNzC2acSzKO0oN0udfsbaTMYjuWUBqGGD6YaxMuvW95WkzN7fo5E1Ot1PTGJniX6a1wNwh7kymt
	RoZ1yRMuhRVEO0LrT8yOt5zPZ3IIfBepFF9rnKCEvchBaqxfBQ0WsmQfGFnShGNwshQ==
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr6083472pjb.34.1565141636650;
        Tue, 06 Aug 2019 18:33:56 -0700 (PDT)
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr6083435pjb.34.1565141635996;
        Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141635; cv=none;
        d=google.com; s=arc-20160816;
        b=oJPs2PCguusICjZW8x8w3DC1LUGzXjNWjmcWAFi6p+m8pecjKd2xokArc3XkLgwYRu
         FXALM01rsN6H3A8dAmU2eZqRvjjdy5rwLR8fIbBFukeqpw+ataMt9nCKab1VjxGOV7KA
         APYRejHEGvCXjRk8lXjqZBP4dsMD7P2MgXwblJ9JLDqKWn5LalM5SiLHlqDutHpbeSZ7
         iSlqr/2787OzzVOKkqr7DhrhlQUvg2eHPxMSRkXpG9DNgETVp7DYXw+YP45JBhJEzAwF
         WmSz1fY31citGovbbYmVY+olRtHX8NDd55wmZ5BeKA8HFy8ZxThqKM23qwO7LDyhYiuQ
         2deA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=PO1mTSTz8gTuOzVOH4KGDfqm69iUUg7yVlZGcj/Ys2iEQme3lvsl4DnAxCCdFZ7gZx
         nQUdpB6Nk40fwtyLq4N/nY84IeaqlSkmPp3Y1/8OVmtfyy8GqkVPKzUXdsjGNDry+ckc
         I5JGp0qXUgitZzbrA4RemVOsRDPXtYXm/OyxIk4/GYuAC8wTPGIXJ593YL363oWyLG9t
         WIqU1uP1N6Ow3QcdDSW/VwDTWsN1baNTIFuruW8YGB3SZ5IG2yZ5JfCVLDPavtu7CtfU
         ATVZv/PHfdjpLOGwHc8pzvJLTJV+r8bQvnarSnSQIpjw52KlhLhBNhsebgjyNMAAQssJ
         A6aA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WodjfRMN;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor27026409pjv.3.2019.08.06.18.33.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WodjfRMN;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VkIZ9MNYeaRKdR8dFo+dHbwqWBHsgbjux0NTtbbQ8Os=;
        b=WodjfRMNXRpfn8eDFiq237p2GDsP83iVPB5OCq8NqovKXXtmSfGMO2YcZK3qaRiOMq
         V+1Wp3U4Ouo1tRWYwqfWu9duqPs4fCXrKz87Da9i0IezRC3CosqffIajL738UQ/eBy1Q
         8bGkemq1iEa5/xtBXuYNtAC1RV+0n9U9hgutinWmqUfG/v6xBvqP7GCtby2XRnRchtz/
         0cYIJLRbrEXn7xRE/60/clx008LELTPxuZr9t/SYNy+7x5xLG72AD6O6vZ88uF2XgMPR
         ACpc5Lz6LUvFr+xpSFpVcKN4ZMG15RxRazNc9G/jbrPxZR9s341vQyb0SHXjN70nitnK
         1NJw==
X-Google-Smtp-Source: APXvYqzbAGNeyGcbWdWkzYvFP0KeX9sV24V25gxtoPIbubmiIgKmQ4weQ/h5itUQb1wb0VhoIYmEzw==
X-Received: by 2002:a17:90a:5884:: with SMTP id j4mr6207412pji.142.1565141635740;
        Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
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
Subject: [PATCH v3 07/41] drm/etnaviv: convert release_pages() to put_user_pages()
Date: Tue,  6 Aug 2019 18:33:06 -0700
Message-Id: <20190807013340.9706-8-jhubbard@nvidia.com>
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

