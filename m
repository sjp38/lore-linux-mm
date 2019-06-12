Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD09DC31E4B
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9732D21734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hBGTTVG6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9732D21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317CF6B000D; Wed, 12 Jun 2019 07:43:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F0496B000E; Wed, 12 Jun 2019 07:43:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2069E6B0010; Wed, 12 Jun 2019 07:43:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id F35596B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:43:56 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id l3so15212563ybm.18
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:43:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=YVD/WVehggR5Wc73HNU/6Lbl/J+rO7t+BXcE3PMRRDE=;
        b=U7zrI/yy8Zpjm26GR/yDdccmGRYkzIZ9u/us0GGSaGHK5tgIdzWBaj4tsEip1OMvIe
         hciCkkCuDfSuw9Yar0ETWJfF0fFgCHATlxgrkgYIGJmE8qGmxYwYn2QNa/QndaYV1ID9
         4dFMaWgnH5vttL27pePihnK2PM4ld9COVH3B6UnXSbZf0AwzFJOKK8kjQgI/N/DncNOn
         LCNhlN2KgxgBxOvia3uqvrqvG5s9mj1fwIUyVNPwjUABuJP3SpB/+60w0Go9WZKAcypI
         eOf+Bbt7+fuHPBNA6a+g5N5zANtns2QnXc1OWvkNAwSfo5jwY4ieoKFaaAN3U735BbY9
         xP4Q==
X-Gm-Message-State: APjAAAVbDFmaIlLx+B7XCDVDblHTXio4+9hHlGm2tJDQEiingGbGvLDL
	YfIOzMyGg9OLHd7mzJvnruXh/qKTMlqq3X2LfmM+rrUD5pTE8sSV/rUOSZvB4iNxvrHzy2Ebicv
	+RDjdTdRqLOoNrBl2XuTbb4Nk8YaMIeN+ZCyIh3hk5N9XbONVdTF3lLWGvzUl2HUAjQ==
X-Received: by 2002:a25:3484:: with SMTP id b126mr9802038yba.452.1560339836747;
        Wed, 12 Jun 2019 04:43:56 -0700 (PDT)
X-Received: by 2002:a25:3484:: with SMTP id b126mr9802022yba.452.1560339836240;
        Wed, 12 Jun 2019 04:43:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339836; cv=none;
        d=google.com; s=arc-20160816;
        b=wd+XSqHA2cbf/v1zYdTwCa7TUQeLUgw72YA1LBSM3ZesXGPaP9PB6M+egRm61NvNUN
         QHxJYV1jMUDVy/3fbiLbemTfP+vkBH4Ef6gxRFu7Gz5YZA/j0OPZO+fa1yeUSzb/2THL
         UkGQ0gnUWDKPW2ve0Soxk6W59Ie/dr/JjXehrDQKnLiuh7LrKANZg9iEmBNhmrkhuvLf
         oy7ivs58cTr3H11NL101vk5812ZbTyNSpq0AUAqtuZhLayI6EraRatO3nthRrypBlwJe
         a6wTVB+WDgWQtrgaPexcEUeSALSrE/4l3xKZKRmmsqlw4BxGpPP2nQyI/BGTe3q9ICzu
         Klaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=YVD/WVehggR5Wc73HNU/6Lbl/J+rO7t+BXcE3PMRRDE=;
        b=EKHJPhheIDK8HiB9lv6Jb5hWApGvOC69AhIBlDF+dFi27Dqw3gggOiYqxNNuVrROkC
         KoFX8N/MYSh9YUlY6B1csOw6Xm6nZHSmhtaHMbohrm/5NUezAOQRHeLKAugyGzMpmw0x
         VfKXOel5jOqUnNxD594S1TUl7+q6vjdVGNFjUoDCh+nbXrKKJ6fJDx4PRmpVAYCD+lAn
         IPJzsVOY+W/RDfilOZSDdzqbDa2D6tI0XAKVS2wI+4C6G43CzzHZDzEc8nVj5glNsEKF
         psmeSifuCaSOV0x5ZtcQLEDFICeaZCMSCZ9w5v11gWdEcLkRRXIY1g+Sk/zlS8MjxYzK
         4+VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hBGTTVG6;
       spf=pass (google.com: domain of 3e-uaxqokcdguhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3e-UAXQoKCDgUhXlYsehpfaiiafY.Wigfchor-ggepUWe.ila@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l186sor4871234ywl.166.2019.06.12.04.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:43:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3e-uaxqokcdguhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hBGTTVG6;
       spf=pass (google.com: domain of 3e-uaxqokcdguhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3e-UAXQoKCDgUhXlYsehpfaiiafY.Wigfchor-ggepUWe.ila@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=YVD/WVehggR5Wc73HNU/6Lbl/J+rO7t+BXcE3PMRRDE=;
        b=hBGTTVG6ghhZ3+0guLELKJ8wGbky2Qh0tZY2BONpI+zCvbTSjhlIF7W0/JokOx5TzR
         VO5Rbf4FBD1McYuvKbubXsd/VFsD/O7BipMIP18RAMdpnsTMlCRbLlZbiP7oKXwSNsh/
         7N4rlsaJS9M2NXxtFUlEJJPsr6p+or/nlT4Zv12ZmDZup6gUVLdgoPgHeFDcpmGNRrjd
         3ALIrSuYojaH/pslqsc0jXMozZhljZkCeYnT4XFg9eFUPMSJzEQdr0RcX9d6uIudOkk2
         t4M2C4U//NS1sNKKoHlt+ReZpRZW4iLnE+17ISBaStJwmRniOrfV+Za5ClmC/tGhrMxn
         H1LA==
X-Google-Smtp-Source: APXvYqzC8DIDqxpBDUE3Cs2MqoYPwBYxauFh78Yi9sE2QOVumKFBSV5WM5ycdrw0GZ9JIDvcxx34zgkY7MRSX6GJ
X-Received: by 2002:a81:9947:: with SMTP id q68mr46506819ywg.197.1560339835908;
 Wed, 12 Jun 2019 04:43:55 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:23 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <4c0b9a258e794437a1c6cec97585b4b5bd2d3bba.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 06/15] mm, arm64: untag user pointers in get_vaddr_frames
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

get_vaddr_frames uses provided user pointers for vma lookups, which can
only by done with untagged pointers. Instead of locating and changing
all callers of this function, perform untagging in it.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/frame_vector.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..c431ca81dad5 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
+	start = untagged_addr(start);
+
 	down_read(&mm->mmap_sem);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

