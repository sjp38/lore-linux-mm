Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 171F2C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCC692133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lXHRsLKG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCC692133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058178E0014; Mon, 24 Jun 2019 10:33:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFBD08E0002; Mon, 24 Jun 2019 10:33:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC5A88E0014; Mon, 24 Jun 2019 10:33:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5E9A8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:48 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id a200so3919648vsd.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=cqAi+OvlHabK4r0DKR/uDYr47zBS8kkFmriW/t8FK6c=;
        b=FfKzV5MAX3ciuziuSOY8qEcbBL5wgl20RJXX0mnI/kTUYDp2G2hfY43YytHTP4lh3E
         E3iNPjrApomed+bNiUGtdWCeJuQoQE42nPpm2Gk/sEF8Dwvy5AzaLS4KaINV9LxC8o05
         5rvh/NmsuObLR/YfE7ZNcazXgV9GDYRiCz2kBgz+Si1dCszmo/38t0+yAfdLwIHQrpHJ
         bs2BQqcKhB7M7ThjkC8estLn67WC4Xs4uwGPLmuhcsThTCkpaEmOrK7rGTwVbnqzLSve
         vUZyCNAOVoB5kOuS8Ly1FWOMzMSv3DhXqH1E37o2LhdDE7NwtTc47FfA245fO0cNn0a3
         RsrA==
X-Gm-Message-State: APjAAAUq+0CNB1ogHUJwJSdYGUhiKzQnYfRmZjVyXdivSnG9SQN40Fae
	QQQdGw//m3Yc88oJHtPG7+qf3MGNfYSClZb7fm3wAozgZQfRaSJpDnYkUJTfu+t4q2LQ7MCbYrD
	egb7S95jH9TjR31MCIA9W0b0K51WcR3hWcaXhJye4xwr5WF5GqMJ0PgiTTtxJ8w9pqg==
X-Received: by 2002:a1f:9456:: with SMTP id w83mr14530003vkd.67.1561386828423;
        Mon, 24 Jun 2019 07:33:48 -0700 (PDT)
X-Received: by 2002:a1f:9456:: with SMTP id w83mr14529982vkd.67.1561386827867;
        Mon, 24 Jun 2019 07:33:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386827; cv=none;
        d=google.com; s=arc-20160816;
        b=Ayr7h/627B5X/kRsrV4pwb4hE9PIHatL7eQIosQBLNPSAh3U7VzYFWf/Hix3EPNy5q
         kzSFBJQaohZd9smHEW8yp+3axLl4Lh5GiMkIQ4DNfl7I7qwucnLptJjOy4SInOLD/686
         14cB/iI6CxzjYqnd7B0KkD31hl2fMqHVGZrAbg9EivwkNIYkRKmYPQUMa1fP0crroWR/
         q8kYMyjlazBlcQ33SQOWMHuu8Z0F4Z6JNypKaZzdreU+I+3dvfvgM4B8/1Oqazl9pnSk
         IlqEAbMLwcv5Ck9qFp4xz8hD9dZAyHPEfOhKfvN6Y0z1L+pPOMvd1C2iISb7xho2CkJ+
         caQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=cqAi+OvlHabK4r0DKR/uDYr47zBS8kkFmriW/t8FK6c=;
        b=zCM+3KkveE0ZnKj+UUTdAxkyYJQtcZpYtXBLrLnYQeBQRAMWxZOrQXa84cCja9oGtb
         fiFhnWzsv9D5r691GbU0XuI2USkKB8g8Zs07QlZDapM0WNTfyXoYEDH0Y+WYsd7XdJhJ
         LJhmjoRsR8WDFH384+2uWzYQ78MHXUhNPMlK4Q7yBzVIERdg53JlcWCjFtsS3JSMuFCH
         HUC0R6gmgxrCCVTJ3cnlTHJIASqX95L0Qf2L0YBh95DoIsOLH7KHyeozahiLuxs4DBbO
         KlHjiGRmA6DOGBwsgpz/CHG9tSmQyAk024HQauXsSgG7tS6Fwm6VQbtI/2z0Ive8WiCV
         lCPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lXHRsLKG;
       spf=pass (google.com: domain of 3s98qxqokcdwylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3S98QXQoKCDwYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f11sor5880609uaj.0.2019.06.24.07.33.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3s98qxqokcdwylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lXHRsLKG;
       spf=pass (google.com: domain of 3s98qxqokcdwylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3S98QXQoKCDwYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=cqAi+OvlHabK4r0DKR/uDYr47zBS8kkFmriW/t8FK6c=;
        b=lXHRsLKGuntJdIfx4IktI470fGbyq/kS83cL/1CQ6KcaqQfI5cgbGIOLx+on2O/XRl
         TyhQq0vCGRVG2NDDFcvggYJ0wxa3AKn2CR+yK/03NNoH4bycNdBR8ox3sdPwTeSrQLuo
         rHeW6O5U9Mg0jIkwq44zjpbQCUdfc3U4ayQ8Dr3awwdf8ADrTM4zsPAD1J2Hva/3oEGx
         iuAfMdkeDB0VVqrLEmMomvjY9gvAQgEF5ueMNKjNbD3E+c53zhezKvbXOoKR1nLLue5p
         C6JfI9UG0Qq2Dtp4qvSg2UI+NSz05kgH40lBS5dNGwoMFiWCdzLiE4V8NQ/k/pPRpCug
         2y1w==
X-Google-Smtp-Source: APXvYqzY+u8RznlTrOWrBgn25HhvDfTMe7SZyf9e34JUgJZBNd08PatZvu4lGf3zfqdvX7DoXuI91wYnbBpoYfQ0
X-Received: by 2002:ab0:7848:: with SMTP id y8mr60797129uaq.58.1561386827462;
 Mon, 24 Jun 2019 07:33:47 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:58 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <280ca5496fe82873caac306ca76fb40d702979ff.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 13/15] tee/shm: untag user pointers in tee_shm_register
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

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
user pointers for vma lookups (via __check_mem_type()), which can only by
done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Kees Cook <keescook@chromium.org>
Acked-by: Jens Wiklander <jens.wiklander@linaro.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/tee_shm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 2da026fd12c9..09ddcd06c715 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -254,6 +254,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	shm->teedev = teedev;
 	shm->ctx = ctx;
 	shm->id = -1;
+	addr = untagged_addr(addr);
 	start = rounddown(addr, PAGE_SIZE);
 	shm->offset = addr - start;
 	shm->size = length;
-- 
2.22.0.410.gd8fdbe21b5-goog

