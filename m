Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A109C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB7D020B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kEClrhOV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB7D020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60F386B0271; Mon,  6 May 2019 12:31:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7C36B0272; Mon,  6 May 2019 12:31:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FDD96B0273; Mon,  6 May 2019 12:31:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 314736B0271
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:39 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b189so13718582ywa.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=XsLXWNDlsBBI0M98p6y9Vt03OYjBcfLHAOwfOkL6Mk8=;
        b=VhbOS8Dx1ZhqITs6BCtxEfHU74n6w7qjuSxiYkYdxb4pIAo5EUukQ0CUqHgYv+jc06
         Ir2ZbhnYTiK62602xZCSJLSzUIFkfZeA+2n3ry7jrPBpemcByjXMrC66X02biJta/zFR
         priv4Myey7fbfJGjnl/nvVgzURnOGbkXkvDegYbD86MSEzstlon2036vqYVC1iiYokAa
         Xe+zF4nTJ2l7hiYd6oAud9srXF1EIa2ddRKOLDNTfwsO9ti8lExkWyXBpNsqttGwvhiF
         bPeUKA3BGrTJwrc0aRxn/V0I60H0tpzhTo8cH4wB7XulEcuSxao4BXoA0YgOFUh07yye
         xhlg==
X-Gm-Message-State: APjAAAVEogNr0hvVRJfGDPxBTPdbZSHT183Yx37YDVva2yEMZ06999k6
	DAnnBU8NK68MHOk0yrDPeVbCcE+vQDOnyodHbQUx/wGSgNfHpCf1w0KaXmc1NaKhoLnuUgC+JiV
	PjRzdf/lPpDoVc6TvUwaGlE3MZKz2KTzsCoKwrMK5jhMn4lUYnIhPZ1SEb3k1nzapLQ==
X-Received: by 2002:a0d:d60c:: with SMTP id y12mr17164792ywd.64.1557160298953;
        Mon, 06 May 2019 09:31:38 -0700 (PDT)
X-Received: by 2002:a0d:d60c:: with SMTP id y12mr17164744ywd.64.1557160298210;
        Mon, 06 May 2019 09:31:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160298; cv=none;
        d=google.com; s=arc-20160816;
        b=cmIGbBfY2aaMzjNwZxz6CsN0KvY0v8io6QxS5WSuNpALbiBZ0EnwMLjmCFq71aRhNq
         IjUGrJan3vD9BodjZyfEqlNRo84mVV93DLiuc78T3QV7mLuMpnGKKGBp4fXCkbywZEcv
         szUmq2vUMnRp9MVyrvryZJMj9sH1PxH3gLw+caF0agKNiKcvvB9eMnXfPrPmCxdHDYAq
         1w8Ibne/Xb+7M1G5x5wxNaF3+B9Um0Qj8pgz3lpDEd7vaRHSC2/z8aHymWqSR+RvILkq
         G3Z7tLxc7KMcrBYLcPPaYXRU6zE2QZarjgYDpN76MhGIvY8pqYBZsRIheobzo2WXTX3F
         MzbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=XsLXWNDlsBBI0M98p6y9Vt03OYjBcfLHAOwfOkL6Mk8=;
        b=dV27EdhMYXpFi5HZ3V1HhGd8k8lR2M8a+2bU5pGhIqV0AsnkqvocRfBqfTa/yZNTy0
         qlKVmBPJhhRxJOcPwZGW51mMi6ar9TxEBNAov+UqP49s/Ovl71FU9Qywnf8VcNZzovUq
         melDCNiaZWFLpWkmFggzqw6XYH70cANyaaWGAxbdLR9JYzcVdPM46okULRWpHipi6A9i
         u/Tc9P+5ehoxWmBrDdayf9EjuEHDw8ilhiJZtLkZsKbdFiMCoVZyYROYsYA7QqSNZXYk
         I3X5LdA///mPiMB+5Zv6gCOJTp5iVHf51qClVXxWrX7a1ujlO5vUCR4f/3bixSgu8DM/
         tlJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kEClrhOV;
       spf=pass (google.com: domain of 3awhqxaokcfo2f5j6qcfnd8gg8d6.4gedafmp-eecn24c.gj8@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3aWHQXAoKCFo2F5J6QCFND8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b130sor5127441ywb.16.2019.05.06.09.31.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3awhqxaokcfo2f5j6qcfnd8gg8d6.4gedafmp-eecn24c.gj8@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kEClrhOV;
       spf=pass (google.com: domain of 3awhqxaokcfo2f5j6qcfnd8gg8d6.4gedafmp-eecn24c.gj8@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3aWHQXAoKCFo2F5J6QCFND8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=XsLXWNDlsBBI0M98p6y9Vt03OYjBcfLHAOwfOkL6Mk8=;
        b=kEClrhOVjhAItZ8ad4444tIss3a4M0x8Yot0yP0UgDJhkHPz5JJSrKt8hPGcBCGy4k
         n4A8xX+jnj6SxUqb5Teq0gUiCKNzkVcA04YhcbUNwlyz4R1O6RfjMZcPvXzWJ1RdceKB
         oQhTiP7SkvbOtmqbJ2RUuk4j1OYZLTrgQf9mkPglzFxH/VOrmTQ4nsN9RjYlhUC2s+eh
         3RVGdXHQ+PFLeCy7nvUg/hvDRpVltVdy/tgWDjXNd7yymqhFMcWgbq1pcJP1+YPDmRyD
         x5gmgR7lpn+iTAg+S4pO9Zaw/FFLdxShW6UDAYaJnd95g7v5e/84elY+8pkkjOlGa4Nw
         P+ag==
X-Google-Smtp-Source: APXvYqynTJlFStkm7itRuyZbu5fDIV0oTx6a8awLBBeIPofcOk875PcBne7EkMsm55r8chxW1lodIy8g+/aDw2aV
X-Received: by 2002:a81:7903:: with SMTP id u3mr17016403ywc.478.1557160297906;
 Mon, 06 May 2019 09:31:37 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:56 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <30b44d469bb545c608531faf01fb10248ed78887.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 10/17] fs, arm64: untag user pointers in fs/userfaultfd.c
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
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
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

userfaultfd code use provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in validate_range().

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f5de1e726356..aa47ed0969dd 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 }
 
 static __always_inline int validate_range(struct mm_struct *mm,
-					  __u64 start, __u64 len)
+					  __u64 *start, __u64 len)
 {
 	__u64 task_size = mm->task_size;
 
-	if (start & ~PAGE_MASK)
+	*start = untagged_addr(*start);
+
+	if (*start & ~PAGE_MASK)
 		return -EINVAL;
 	if (len & ~PAGE_MASK)
 		return -EINVAL;
 	if (!len)
 		return -EINVAL;
-	if (start < mmap_min_addr)
+	if (*start < mmap_min_addr)
 		return -EINVAL;
-	if (start >= task_size)
+	if (*start >= task_size)
 		return -EINVAL;
-	if (len > task_size - start)
+	if (len > task_size - *start)
 		return -EINVAL;
 	return 0;
 }
@@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
-	ret = validate_range(mm, uffdio_register.range.start,
+	ret = validate_range(mm, &uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
 		goto out;
@@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
-	ret = validate_range(mm, uffdio_unregister.start,
+	ret = validate_range(mm, &uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
 		goto out;
@@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
+	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
 	if (ret)
 		goto out;
 
@@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_copy)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
+	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
 	if (ret)
 		goto out;
 	/*
@@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_zeropage)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
+	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
 			     uffdio_zeropage.range.len);
 	if (ret)
 		goto out;
-- 
2.21.0.1020.gf2820cf01a-goog

