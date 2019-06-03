Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C65CC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13A98274E4
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uyCC5R6P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13A98274E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 818F56B0272; Mon,  3 Jun 2019 12:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A2F26B0273; Mon,  3 Jun 2019 12:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 647086B0274; Mon,  3 Jun 2019 12:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF116B0272
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:01 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v13so5428438oie.12
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=J9pRn7M3NANi3nsm6t0U9rkGUXnmKvJ1SqswIr7oBNs=;
        b=d+dWFILoYn7kjDYFhxsZn+HsQZQNLcb8S2Dm6A6ynOufDJRcHi+bIcMUo19uONiyo7
         p9k98y3q2IeowKTvji+/InU3xE913PySDzYTI6rHUFBOz5awMmo4JLoroh9vhECKWVL3
         qoJxnbOAZopUh1zSFPXNRUL4wqb6tyW8lCTuk1TU3lr0BBArljcB7qxt7IkPadQsX1B8
         zKypQNM9ZdQLYTSkOehZ3IPtOmTdd8+Eu7eEe8EBMfUbCZiIxJjQtb4vaFdZPqLMbFLT
         0H0gSbD6agN/i6SZAS0hUZpg//CPtPAr9tG/T+PM1XchYTgviNYNL00tBu754Pt4OCjX
         qBMA==
X-Gm-Message-State: APjAAAUnWCsdDRN8CVIyDsKVC3Id1Gn5kipHz8u+3vT9vJ7a0+GUwa/k
	Bc9OlU80Qjkl/Kj23nKzRUyF7A2fCm5LXX6Q6yCkUJfwkW7iCtUCImzlVlorAv1IKg6Z2Tw9Svb
	yDxiItTbOCIo24ePU0iqn3hcVoDBziG4xDVsf1IW0s724u1TpjWPFdKCuBgCFa4MmlQ==
X-Received: by 2002:aca:4e89:: with SMTP id c131mr142003oib.57.1559580960720;
        Mon, 03 Jun 2019 09:56:00 -0700 (PDT)
X-Received: by 2002:aca:4e89:: with SMTP id c131mr141973oib.57.1559580960099;
        Mon, 03 Jun 2019 09:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580960; cv=none;
        d=google.com; s=arc-20160816;
        b=G0Q54c0AESo8jB3kOlRAuku73VVEeo5wAiZ/B/VDs9ParIuf4fb4YtwNi02cayD9K3
         iPhpdccosoAH+gz3jlC8UTKAo64YCO2oSNoiB3yBnoysx2lpD+j5FA/uiZ6PIX/W+Ar+
         8Hp5+PYxUTndHWPRa99wa0FyjVszZyQ0/GKlDVWUm+vG30haKrQhvAyjEb7mfC0MQOU6
         kwJ8MX0/KLdlYry5ycvx+dK/RJI5MfcgID2Pw7KIcBVGaeP3iKSakXY9AUOJDJ/22vqB
         TyCLLeX77nZfQA582lnt8xd+Vb6jIQSCQ3dBSjCIN9IAFsNZc064QzDjICseU7b3fjBG
         EfRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=J9pRn7M3NANi3nsm6t0U9rkGUXnmKvJ1SqswIr7oBNs=;
        b=lAmW+wrxeOD5szPhlD2epT7qzZ6q7YAf8lam4DGXh9mK6ataEsS58Pg5JH3izI84G8
         8+QyQLpfdcRXtudFguhCVwKX1V17PRQnp9ZWDINf48xC+sQUmy5zkDJkplWowDAeRAK+
         bexZw/4x56OZgZFxZO011WpeuMMF6UQlQjfe7BVj/XqKdYJcao+hKcVVNgJjq6dSD2ic
         gYVS0p1IjmviFEpCpvVpEKKrRLNhHh1p67vTiwunzArblcsZgAWHENxG1RT5/rdyV4E6
         EJzC2e5OoQYLxbclATxon61S+zThiYlG+9TDGse+EDd7H7eR8ykS7PP+uxmYhONLjOZl
         hB8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uyCC5R6P;
       spf=pass (google.com: domain of 3h1h1xaokciqivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H1H1XAoKCIQivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m2sor911696oih.174.2019.06.03.09.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3h1h1xaokciqivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uyCC5R6P;
       spf=pass (google.com: domain of 3h1h1xaokciqivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H1H1XAoKCIQivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=J9pRn7M3NANi3nsm6t0U9rkGUXnmKvJ1SqswIr7oBNs=;
        b=uyCC5R6PocJkucx1jg/Ao87LrvuuxuIBF6MJgtDNhRfSLGfd93TT+616KNBdU1kmQ0
         AgUDtRxuemeCNPWARnIzmKXOHJHBg+nlDVnGcRWa1zFo9sO/boLQmVSMKTOceUEyeuWg
         mQemhEJH0YpA4zNTW5udZ12GKI5bnl80kC7VZlC60TPzrs4d4KpnJ4TkMFczujBnqjPI
         s1PIMD6Bv9mJiTZ+Ezsulw1mODRNfzAxvwpKccvPVlqp//q9tEM3ODpqGbBulPCkTHr1
         l2f+hVLNHUHhV92giHpjab5jQ7AF27XvPV9Duk2JrwjNtkOIOBAX18N6EpfDx4AK8S9m
         dKQg==
X-Google-Smtp-Source: APXvYqxkxhXEjx8ehUwO+4U+/PSwW95cfpd51BrO1CGROW1JbuARWLoPLbgzmMBGokFlEw6Kw7ByzaocLX6whXWc
X-Received: by 2002:aca:4341:: with SMTP id q62mr1665112oia.140.1559580959661;
 Mon, 03 Jun 2019 09:55:59 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:13 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <f293884fad5f741b9202a9db6006f4bfdaedc2bd.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 11/16] drm/radeon, arm64: untag user pointers in radeon_gem_userptr_ioctl
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
	Andrey Konovalov <andreyknvl@google.com>, Kuehling@google.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
userspace pointer. The untagged address should be used so that MMU
notifiers for the untagged address get correctly matched up with the right
BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
provided user pointers for vma lookups, which can only by done with
untagged pointers.

This patch untags user pointers in radeon_gem_userptr_ioctl().

Suggested-by: Kuehling, Felix <Felix.Kuehling@amd.com>
Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index 44617dec8183..90eb78fb5eb2 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -291,6 +291,8 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	uint32_t handle;
 	int r;
 
+	args->addr = untagged_addr(args->addr);
+
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
 
-- 
2.22.0.rc1.311.g5d7573a151-goog

