Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6FDBC04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EE8C217D7
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FRME1COe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EE8C217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B76E16B0270; Tue, 30 Apr 2019 09:26:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28566B0271; Tue, 30 Apr 2019 09:26:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3F896B0272; Tue, 30 Apr 2019 09:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84C5E6B0270
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:26:05 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id i203so12808596ywa.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:26:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=5vVbThWFeNTYFxwbQq67jdT1oZny+xOKBFoxX+2Uk7M=;
        b=VsfyEJzBQtiwOwtGSXje0bJBe1OIuoAufYF87emaSBYxDMCX5lt9P6DwkeAv59AViy
         c6/LYvaRZR7skn+2LfF0A6FaRhbZrO0Ccah5PDM5LXi6U6E4w7c41SryI23pyXb2liUe
         bCrF/5J6k4RKU0v9MWKPWMAmB1ixHjSnDQn5iVYXtHo4pvT37klmTxn2NSdL0Vdi+Hi0
         GUsBAsNH1pkFeNF6je2h40ju0Ydt72xTBqc0PoVV1POL2VchoWYDyOIJcPYlyGEUIWui
         CHoJMFrfGlFiIBSimzkW69md6PKFkVeZLiJ9CwQ0HWJ4VlzmZJtEKIpTMdtSzpuTxds2
         GIng==
X-Gm-Message-State: APjAAAW5945/ULU6Tk6zfC/A15y/QgkYzUBpTzuJ/AYDGzTuivse1r0p
	cJCzPAiyZ03Bzt8wZfA1EehQRMn0t3IcaDmgK3ojdLKQ8Fe7QEyG3vF4Pm8gN/0KjlLQtSUf2CZ
	Zw6PKHbmp2O6/g9W73+zuXU8CJ7BqQT6dTZP/Ypnee5yAcFAI5PxeQwSwP3ATW2IwyQ==
X-Received: by 2002:a25:844e:: with SMTP id r14mr55405856ybm.305.1556630765254;
        Tue, 30 Apr 2019 06:26:05 -0700 (PDT)
X-Received: by 2002:a25:844e:: with SMTP id r14mr55405783ybm.305.1556630764387;
        Tue, 30 Apr 2019 06:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630764; cv=none;
        d=google.com; s=arc-20160816;
        b=ZcHFweCQzBHJ+00X4fUhZLyhhByy6XGDtEnjRnnBydbeElq7PfFqv3QpiG4EKRbW3Z
         VkCfkfOBVbP9zLi3G3ppzjcl5+LbzSq/Mwux93LoihjZX1/1v0rRtAGgLp5WJjSbllAh
         rHajEHR9II7OTe8eeGyMM1uwO6XNNUzUForWpHhkI3ti365CUdisY9AfMjabHS+UK6ay
         TXU7Lw3XLv6tTejdkRwheboCLBvmJcC8tjFm2txBjRNSWS0Hjrqrhku9oBgbtfKb0Mpv
         5ihzCCc/8/zfg8BLDy3LRWrB6wiX/JfYDPRHU5QRhfacyilYd1rSAM79LuEl6Ip02Xin
         umOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=5vVbThWFeNTYFxwbQq67jdT1oZny+xOKBFoxX+2Uk7M=;
        b=sbpavAq6om0lJy7TDXpmkz82Y2hnL9jYhmDFirEwyE2jwqTrwMGVAz2n6w7Vu3Jws8
         k2vrSTuuixnuK8wrKCEPE6mMTRDV0ZzMQNgH6+lv76hvyPmIQFxz+H/oOWebMSS1Q8n+
         mfpakROH7vZvNi47FxaqNZFh2BdAl/Eb4REr6Q8r9hy11BdH61loQeO1okHfsqxYqCNN
         YuP8YhvoVhOCZ6YujJHwdkoqEwdj0XTfcxfeS1n+fOLFbM5TrJ6qhsG6c/96xND1Ecv8
         GQRBE5NtuAtg5HYs9gT/h8qUmSR4zjoHl45iTnGNOARSDTTKep4MtkRXS7o1kfivVC6h
         z2VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FRME1COe;
       spf=pass (google.com: domain of 37ezixaokcjmxa0e1l7ai83bb381.zb985ahk-997ixz7.be3@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37EzIXAoKCJMxA0E1L7AI83BB381.zB985AHK-997Ixz7.BE3@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f10sor2660256ywb.6.2019.04.30.06.26.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37ezixaokcjmxa0e1l7ai83bb381.zb985ahk-997ixz7.be3@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FRME1COe;
       spf=pass (google.com: domain of 37ezixaokcjmxa0e1l7ai83bb381.zb985ahk-997ixz7.be3@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37EzIXAoKCJMxA0E1L7AI83BB381.zB985AHK-997Ixz7.BE3@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5vVbThWFeNTYFxwbQq67jdT1oZny+xOKBFoxX+2Uk7M=;
        b=FRME1COezh5b+xsqn4P+Wuk9kST7usWvir2xQhAmIzYbqhd+Dle1XM/PaJl5NwGBwF
         z7/SMrTqJtHy/gO4CF7xbqlFAwpIk8PwR9mnXkXEY1b5HFuyeguAZJRX9uVnCx/+N6Cg
         GdXjue/eQFQ6wfKzJUzNubo15IJ6ki/RwkeGwPRaQhUCcsmSJMlmZ6DdqtqFu3fOL0bX
         01e0qP9aKT8hITIugatecY8TuWXLv4w13ho7n2rx3qvyQwxwSmnnV+ESWDP6rPMjBLm6
         9em8VBa1zwsikfNNQo9I2iNQIYFHDIjY+xXevJ0y76Ma6MtOAyKoTjWTXLT8lERzPHTd
         0Kew==
X-Google-Smtp-Source: APXvYqyv8kHiq9IuRt8k8uxL630nsRVEEuszbAKJggJOMl5SWFBjzMAnW0IWxRwAYYoqlPXLLWZ5sEsVnC5FF0Vx
X-Received: by 2002:a81:3c89:: with SMTP id j131mr56890450ywa.183.1556630764032;
 Tue, 30 Apr 2019 06:26:04 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:11 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <1b2a46dbfa24bde41f11cff6f53683a5ea5915c7.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 15/17] tee, arm64: untag user pointers in tee_shm_register
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
user pointers for vma lookups (via __check_mem_type()), which can only by
done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/tee_shm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 0b9ab1d0dd45..8e7b52ab6c63 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -263,6 +263,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	shm->teedev = teedev;
 	shm->ctx = ctx;
 	shm->id = -1;
+	addr = untagged_addr(addr);
 	start = rounddown(addr, PAGE_SIZE);
 	shm->offset = addr - start;
 	shm->size = length;
-- 
2.21.0.593.g511ec345e18-goog

