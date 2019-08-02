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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD59FC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 952C42080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cXVKp+Dg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 952C42080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61D6E6B000E; Thu,  1 Aug 2019 22:20:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6346B0010; Thu,  1 Aug 2019 22:20:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D37C6B0266; Thu,  1 Aug 2019 22:20:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08ECF6B000E
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so37489366pgh.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pwlX9Z4uen7Ts0pUwmBLgDhtihaB/D0UZN8JDoMe4ZA=;
        b=NRMUcULKNxQewzXrDbU9TD+2bxY/9kvkWhZrBcJLfUkAZf/ttBOppZXGV/LE9UnWBR
         NQqJbFrhh+0y9QA3nKDIKqrRiSm/OvkQ2fR5PP97LN3aC/eA5Q6XBsaFz5wgx4YZO60J
         j+8g50aEIJGt1dLBzKurUWy5GKznuOFfvDtYZeULiIYDbUzyuHUvthBCh4SwZmf8OxiI
         Gjzkbvp4tKmGNlIjIUnzWSKyF/tciiC2PAZm+RThBM9QXmzJ5pd7Oqi2iNPaJbtDI1Tj
         qoqXZyi+p04rCmuSjTY24+kLpQIHSfqyxX2TjQihbi64PwHl6htQMKDkqastFs3X//J+
         DfWQ==
X-Gm-Message-State: APjAAAUOsVKQsOejz9mYvqhK7CrPA1q0l7IhZbNVE6mCTPVU2vWwsdio
	TWoCiVApkhl4JCkf80VCypNaAOYSX+77vnZ+h/SMqRlkZOvsqUAk7xt+18h9lLrXwBp7ZkaBtBc
	y8LTLEZ8DjT68OxOt0hkUbgfk7lNvJIeSyLK170CSP2EK686avkBGJLUtj27KaRcwBQ==
X-Received: by 2002:a17:90a:fa12:: with SMTP id cm18mr1846362pjb.137.1564712420732;
        Thu, 01 Aug 2019 19:20:20 -0700 (PDT)
X-Received: by 2002:a17:90a:fa12:: with SMTP id cm18mr1846315pjb.137.1564712420087;
        Thu, 01 Aug 2019 19:20:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712420; cv=none;
        d=google.com; s=arc-20160816;
        b=1FoCN3UHSm6Ir86nNgT+iwXChylMzvZyQ1qdXuljihN3icQEI01CiurbXmEUbJP+Zp
         wJ+VNnSjirdRlUwGZLIHMVFBlKDY/b/LmRhhDsGewe87jVSVcp0991eWRKtNIPjjCm4u
         NgvH++LV6zX+1xaAIuKuG5UTAnZYASd1jNXcxnV1e7pS6rOIACIpNSFNO+MULinaa8Tg
         QV3eWU1AwZLcy8qMYOHfB5jxqDuWgWkCCGHWsV67FlUCbl8Xgi87PzztPPXVZdAwLc2T
         lzJ5JhtTmvYa0zwAdb3WXHOwM4xsGhlh0kYcACezOsvujwSDfnDhQcaleoewrZLwtnG0
         C/Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pwlX9Z4uen7Ts0pUwmBLgDhtihaB/D0UZN8JDoMe4ZA=;
        b=Ogd6eFk4qH3PUXlRMpRyGFwsSXMg3sc+mzxUMwzspfROX4KyPKuL3nLcM7044EScNM
         0eAluktA4SP8WBKcblOf8VTOcHZfAZAjgeAcvpB4cSlsluKDC0C7IlOudCrJe8PkbaFT
         mW6f8CWI1fEBVwlQsJQASz2CBqpgVNuV4F701BiJR696krjQ13JRhiGTAl/ND+qIucD6
         bCKFMtg9/BdNjAJElia8Tjvq4uZAEPtvUrJd9O1C4vy4cHv6qylvEi5KlfXDti1d+qui
         2npA7/pc4EnBRePOu0HyW6pa+1rK8wRCzGaCveDFvWmbQGHj2lR/sXucCor37DPo9M4I
         TcTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cXVKp+Dg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11sor88973814plk.18.2019.08.01.19.20.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cXVKp+Dg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pwlX9Z4uen7Ts0pUwmBLgDhtihaB/D0UZN8JDoMe4ZA=;
        b=cXVKp+Dgxhj784uTGfvPyG1yYJG0TluF022pFhUyHpRdik351Pihe9of7XZeuP0Vwt
         h/i6WlGcIKVNKfHSeDSEUHKJX3j3X/NshFFci/lhMH4/SgEjIokRiJ+YouFN6I+GBm4y
         zUjQOfq6557LaDfB1SW3dyyvMia7x+7GSnkQpaKA5dSoAhqdxSb/NVVqK5YIHjTvA0IX
         6H4EsdOomJX2kg/hRhJVVxm3sX/zmn87r9Fum/tKlkDFYTmAnDUVoJ7rlCgUuzHH8DwS
         QuPnhojZwqXr2XSW6HhlWm7VIgfEjZi50Ea1bZ4R+3m+Y3fnnezSFaVuWGen2JpYqC8g
         nI5w==
X-Google-Smtp-Source: APXvYqzjw3eL+xmFFeLCY8pAtt0uU+dboybjV0Tj2XnMiuSE8KPva7u+GlTOi6iXLJ1oNBX2ZlUCDA==
X-Received: by 2002:a17:902:a413:: with SMTP id p19mr129958448plq.134.1564712419691;
        Thu, 01 Aug 2019 19:20:19 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:19 -0700 (PDT)
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
	"H. Peter Anvin" <hpa@zytor.com>
Subject: [PATCH 05/34] drm/etnaviv: convert release_pages() to put_user_pages()
Date: Thu,  1 Aug 2019 19:19:36 -0700
Message-Id: <20190802022005.5117-6-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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
Cc: "Radim Krčmář" <rkrcmar@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
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

