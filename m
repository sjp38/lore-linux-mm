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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AB5C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49E27217F5
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fH35nava"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49E27217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 376D06B0010; Tue,  6 Aug 2019 21:33:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B4A76B0266; Tue,  6 Aug 2019 21:33:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12D0B6B0269; Tue,  6 Aug 2019 21:33:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAEBA6B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:58 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so49420699plp.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YDBAQLU7S2U/jcsuraEitExVA8qAggFNDXffEk4LOSU=;
        b=m43i8YBvoL0micbIQshbliNpC2Qdk95PSWFeNGDPe+n1SE7lAi/N7010sOb4BA3mja
         sYtrJL6ejOpEgqI4611tQvNaF25wJy3tp/tLJ0R869kNomFki14pLIv3Li+RB7IEQtl+
         +aehu8TX/GZoSCv+9uX7Vtov680zQlAFgOkFeuISpdQup6P2tAqE54zSpQi0Q67PkATB
         C2swLos26EBJh9Om/AWQRqa9DWsugwP9dttFuJOxyocHW85w/jAGxk/JSO410AkWVMRP
         rIDo60+HxwhBfWKLfDWEGn8h7JNoOwly/sr9/xtGKxUgIZCbJULDZCbzxcv97v7XF51Q
         jrCw==
X-Gm-Message-State: APjAAAWYKriUBUslK2L1cIhuELxHuP768tjbonZxY9QND9Cw0h0aZGZi
	8lvVjVRrwXl31FgWtAwp4WHnaUnXk7y2nMH6BqEcOcm3S7tYm4It+C7nvtChBqajvOspNa7TVg3
	IlEdxiqVEKJojdb1c0WiJJKsBFaNcz3WtQ/7vVjSzLfSRCBSewDXNluJe8loNVLeDxQ==
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr5880171pju.67.1565141638329;
        Tue, 06 Aug 2019 18:33:58 -0700 (PDT)
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr5880130pju.67.1565141637645;
        Tue, 06 Aug 2019 18:33:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141637; cv=none;
        d=google.com; s=arc-20160816;
        b=09xsaHNGvqC/ktorTQ6IcdLOTNe7tuS34h8Vc7DnLXsKHCY+mzdNUeL2NZEEV3gyo1
         CyBjX7JCPWl1a1fwLDsh6hTFJuoNaGbA7IEbxI7UY+gGX1NmhlZjobnyC3E59fq4VoHc
         i9gYPEdQoKbKnnaRY7a0qNF+42XCg2NYDz6wFveM1O6sAURYOyaL82sLDgzisiQ0Yd+b
         GMQeV7IZ9c/ujDDI34DbUuqb/vG9SgsVWAKSjYtsOLCLpa/hdfYkZP65Jdqxd74ivfBn
         sOrn5x0aQu1UFP0mXpSLCZ+HBid4yd3Pu8x0TI2/w41tqsr8AdV3myXHdXD28LwhHkzc
         vWFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YDBAQLU7S2U/jcsuraEitExVA8qAggFNDXffEk4LOSU=;
        b=kG12JpBReGos4qLoVfkPaXYLDCVzD9yJp80ASA0eW3SRJ+t7/D/WywDfqMMdD7Ve6H
         Lw72lrPAfmWPAae9PbAnvFfraw2+gF+zHM/H7svbqZ5+sHsGWB+AE0ZfwbAsRv9DPQ/k
         2tqrFhvoUTWghRPNrRZwO5/F+UZ7eSt72MnjkKI20g9P8bfrtqW3lIa6aXAaIR5xQRo4
         27tBN4WYGc/wC0P22JixhVaKWzhKsTIdGOT75Ec5JuLazchnXiuSdlSTzL2BGIF31BX8
         p2iG6mZZD+b5u5U7g4xrQuno9BOu+Oh4EYVNlekvAqvD4l/vznE9ljx+ArgTyBsETkI3
         LvRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fH35nava;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor27026456pjv.3.2019.08.06.18.33.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fH35nava;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YDBAQLU7S2U/jcsuraEitExVA8qAggFNDXffEk4LOSU=;
        b=fH35navam8Lh5O3/qNrV94jl6iS2d0GfzCxk/u0RVGSb5dvr8ME5vr6Nrz7RbT0FzH
         b+0bwfj6a40pZ7ZDEBSPteuD+EtCdatETgtIbhA4HjNGhTvq4/6/8Hfd0cWzD4ACfYbW
         rgRW0nwu/E9vCWm7L7kW1f14dc8w0gfs4RZvtHi6Oflt61RfXIS6VkmL4oCieKfyzE0K
         4m3Xz2o0LiyRj0Y9KXj50L4atLA3dDsoGvMpdRLog6j+z0Lu9QLqi3MvwrgBmW5y8MHT
         21A4qIppa4JRGq/2QNHN+lrWM1Z/51ATanglohKPJpBhZfdY/rs/WBKjHemXIrn3RGac
         3taQ==
X-Google-Smtp-Source: APXvYqxowmB5KY9x5+3VpBUz7AtpjaBcc2B1U6EZUCl5VRWjmEE9hilm+u0BPGPiavOiCOJ108uPDQ==
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr6096915pjb.42.1565141637378;
        Tue, 06 Aug 2019 18:33:57 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:56 -0700 (PDT)
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
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	David Airlie <airlied@linux.ie>
Subject: [PATCH v3 08/41] drm/i915: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:07 -0700
Message-Id: <20190807013340.9706-9-jhubbard@nvidia.com>
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

This is a merge-able version of the fix, because it restricts
itself to put_user_page() and put_user_pages(), both of which
have not changed their APIs. Later, i915_gem_userptr_put_pages()
can be simplified to use put_user_pages_dirty_lock().

Acked-by: Rodrigo Vivi <rodrigo.vivi@intel.com>

Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: David Airlie <airlied@linux.ie>
Cc: intel-gfx@lists.freedesktop.org
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/i915/gem/i915_gem_userptr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
index 2caa594322bc..76dda2923cf1 100644
--- a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
@@ -527,7 +527,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	}
 	mutex_unlock(&obj->mm.lock);
 
-	release_pages(pvec, pinned);
+	put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	i915_gem_object_put(obj);
@@ -640,7 +640,7 @@ static int i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
 		__i915_gem_userptr_set_active(obj, true);
 
 	if (IS_ERR(pages))
-		release_pages(pvec, pinned);
+		put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	return PTR_ERR_OR_ZERO(pages);
@@ -675,7 +675,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj,
 			set_page_dirty_lock(page);
 
 		mark_page_accessed(page);
-		put_page(page);
+		put_user_page(page);
 	}
 	obj->mm.dirty = false;
 
-- 
2.22.0

