Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19F78C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7C412145D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EdyxEJFn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7C412145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821CD8E000D; Mon, 24 Jun 2019 10:33:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 783948E0002; Mon, 24 Jun 2019 10:33:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4898E000D; Mon, 24 Jun 2019 10:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35DF68E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:24 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id b70so3939916vsd.19
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=6wOlIN9RCqtC4EMjbsO9NIyMZhz6XW377zGYJAhhjSw=;
        b=H1suACb/UuQCg6aEAPpvCOmhfkHkqtKDLfBnB1vY+7zFDrxxsZeZc2Nr+pLc5OzTPR
         Gc85dtWzwrn79+PdSZPxS/kCnfNay3LDDkLLs14Q5o1ce1d0BAhXWLr313boCKLJpmX/
         IkPAowRj6i6MiYe8S2rE7QsL7N9btF9HfJFAc+yEQARuyRS6mwdz8NBXt9ee6Xin7EI/
         +Jx11QdT+CH6hSYhuhwzFJVP47kiJtSPIJxebNXPKHwK5lRnngn0sRMwJKhpB+I2girm
         nK5c2dWnQVSZ2gdTvJ9pmoG7dAQ98Bq6/nVVchhNV86Bvcd9SFiFWSKSY6C5SzAOp7wj
         iuzg==
X-Gm-Message-State: APjAAAWAq4ZYJTzB75uX0O6iqrIYHCrqjqtuMR2dqKPui90dmsRIfcZg
	oPtGfa5TKbKQw1HIye4YfU95Z8L/jaPXf/vsfrSVximrgXgmYIoIlSl91d3krn3sHsZ3tcYzN1X
	82ldSdpDeILoheelhCv3a8H50ory8lnmyYJK8eyaqjUXA4F+oJ208KuRyInFb9TX7pQ==
X-Received: by 2002:ab0:74c9:: with SMTP id f9mr20933121uaq.18.1561386803964;
        Mon, 24 Jun 2019 07:33:23 -0700 (PDT)
X-Received: by 2002:ab0:74c9:: with SMTP id f9mr20933086uaq.18.1561386803393;
        Mon, 24 Jun 2019 07:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386803; cv=none;
        d=google.com; s=arc-20160816;
        b=m49ESWIQzV55qtVXfftohqhqBt2xbbFZk834bazTXsiakKn456HUI4SjnZeTtjp5V9
         9eJ2weuKtp3Sctj5DGCZ7FZeIov7U+lXptTiAY/TeBFCaoqEoduXocC7kVAoU6w49/Ps
         AAcjlAu3I2M20NBnbqyc8L1MKy4t8P4r92DzL0LmQPUYMx/nQi9iGOrcoEMsTxF70ggG
         A47kcoxikVc6TWofW4Rso5gNc78z+K3Qw8AFsWz/Hc74txXgy+L5nfovad6cNLUiF9MX
         dFFu7pXZN+entP+T4U5/x7w9+AUACaVnGqMbDhhA8wawyGzdXr21I9P6yGF8jz1yPyzJ
         gz4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=6wOlIN9RCqtC4EMjbsO9NIyMZhz6XW377zGYJAhhjSw=;
        b=Wvva2JEsJG6tOJJkjtNdsA77Nqta7AEOiIzuXVEH+aoR5RgGmVu4JlA2zGeNJGFVCS
         TO/rs37yAh0le3ZzHNLQ5H2ZcuBpSgtQuL+G67jajLZS1ICNQVoULQ1ZJthaCSl64QQr
         LqzjnDzEyWi8SIHOndlReXXaDxhwIFIGMSP1tA24K+onCBze9f8ZLgqYWKhSrEpBmBr2
         xn4WvepsIiu1J65/Or9dy2ToTafgjXhTbfCQoSZ95zmK1zY059ji+07Ygb3YoIJSC9Yr
         eMxPYTP5cd0z6Lgw7DSqzuagT9KPg/hzZo/mmyFyZ8ZTc0w6MbccPCjjwCag+VRe5sCK
         AA/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EdyxEJFn;
       spf=pass (google.com: domain of 3m98qxqokccqandreyknvlgoogle.comlinux-mmkvack.org@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3M98QXQoKCCQANDREYKNVLGOOGLE.COMLINUX-MMKVACK.ORG@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p10sor5725534uap.25.2019.06.24.07.33.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3m98qxqokccqandreyknvlgoogle.comlinux-mmkvack.org@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EdyxEJFn;
       spf=pass (google.com: domain of 3m98qxqokccqandreyknvlgoogle.comlinux-mmkvack.org@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3M98QXQoKCCQANDREYKNVLGOOGLE.COMLINUX-MMKVACK.ORG@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=6wOlIN9RCqtC4EMjbsO9NIyMZhz6XW377zGYJAhhjSw=;
        b=EdyxEJFnWG9rQS7GXNgeJyNTxEu5LtqPTYYbN/QLe+5zlbDexboGyDqBC815Hrokjj
         qfAzqSeaTKPFvVv9WWYIndqnAPiRljjB3TIDjGP/0IMssQbdVP4BzrpsfzCXDKI9BDHt
         WeSswvJDxczfbCTt3IQqYPH1jX0VOQ5O+GZOEn825FLst0HqKs8RjnFS0DrDqqOlKlcm
         +N5mzxkUilj5uw0wDqYjDhK1/db8t8dLQzbwnNuEhal4y8tjJfxP9svgAu0LB4ORTyVD
         OZMU426HgS0vYo8hjqCwVk8ERda/jHZQ5JXLr2v38JKqFFajbtzb+/rl5BB+KXJN5rjD
         80IA==
X-Google-Smtp-Source: APXvYqypfx2HThdGezp/oUedjYKv44Fb8n5lNK45oyS/vOtxc58Rwt4c9Y+yK17e0xs6J7fV+AYN9l/kG2KmENab
X-Received: by 2002:ab0:5c8:: with SMTP id e66mr54849002uae.10.1561386803022;
 Mon, 24 Jun 2019 07:33:23 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:51 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <cf7bc20a86d45f690c211ebf284e9ecdaf6d4869.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 06/15] mm: untag user pointers in get_vaddr_frames
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

get_vaddr_frames uses provided user pointers for vma lookups, which can
only by done with untagged pointers. Instead of locating and changing
all callers of this function, perform untagging in it.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
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
2.22.0.410.gd8fdbe21b5-goog

