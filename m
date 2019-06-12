Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10159C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B622C208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SFF/l4UF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B622C208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F4796B026C; Wed, 12 Jun 2019 07:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC816B026D; Wed, 12 Jun 2019 07:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F247F6B026E; Wed, 12 Jun 2019 07:44:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D19E86B026C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:18 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id j128so5490332qkd.23
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Tg03Gniv02ZbxFz4TR6ORKJ5z+YRDkk6YMGCeNMzVJA=;
        b=PRPHs7IZBOcUahFv2xcpHoR1YX4NPGK+BaaejAEgU06pzRaAaoqX+WDb5dbG1mBejR
         fgnZy3hwokDflaK60hpvEeXg+D+1iFiGeWnZN3pnhB8WauOB5km/bVMpMUef/ags/RQm
         G4ts5l3ty1fFXXNwEtgFoqRcPxeD73oQm3BAo5ehdQeI2mC2Hh3G50W2CiT+TLsJK9k8
         hijz0CIBTEWLXge4wnpnFid8M/lPtlvGd1/LXlxHijOWY8hYyhxm8OX410gRB8OFWN6q
         EtPkDsnUBKj0ueZppQx9TsrrQtpzZwEvcx8qluOmVPh3jyTsUAdkv5rkFA9UGh2QC9LU
         zBRQ==
X-Gm-Message-State: APjAAAVm6lgsCls78uUd8jVO7s15ZhYhF7d+uJs+Hi4pqgn13n1swSsr
	nHuhceidDqMxNC2sTgJmv0N+1j6UT1TmAtJ/t8qRx9afkJ1IEkDQcGD/ukjhNXbJNythN2CwFv3
	8V4cptWWlueztO/4sIYxVKLrmTqxbR9K0FLBgMN5un1dUEAAucv2C7807cNRp4YAryw==
X-Received: by 2002:a37:e40a:: with SMTP id y10mr8480297qkf.303.1560339858638;
        Wed, 12 Jun 2019 04:44:18 -0700 (PDT)
X-Received: by 2002:a37:e40a:: with SMTP id y10mr8480244qkf.303.1560339858046;
        Wed, 12 Jun 2019 04:44:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339858; cv=none;
        d=google.com; s=arc-20160816;
        b=q0AhIo0kjptyxzNh9j0azvqm5sfFJW2hdQlny1DzpgHvqSvx/ZOlnVQ6qE9w/WxRgf
         0JBbw6994mwMrasYJtnrgXg2bA3ayODJJVcCbiGu8mJHIGU89K3N1wv6FZ2jtuxxdj//
         7iVam91U6OP85O6czVLjGCtA/KpoR6eY+ursOIQJYmH+b97eKbUgNcGDi2znu4SnugB0
         cZXYZ7lVT8vFZmt3DSO5QB9EBT/r4qh/6VWjrI7do1ZgHD0Ilnip2ziqt0QZVesTrbpY
         XirCoKfWf3DuMycnmT4R9F4slm/e/C7mP51U00R5pSVmkne/Cde2rVbBlh1/pkkHmCKD
         ltAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Tg03Gniv02ZbxFz4TR6ORKJ5z+YRDkk6YMGCeNMzVJA=;
        b=xSmVnNtMRwf1B0MscC5Ofhrm0biMLwnvohsfje+4fjIN2Sc3GOn3hu2wVbJRxH4R8x
         X50SF0xYfbqut0qXSUa9QEO39dr4CbVbHG+IP05aHR3A9IN0Ak49+orUHl7aAHz7xik5
         QnY2ADbS0kO5YCYgzGUdGobJp9RM/rGCYQDsno6uEV4ZqAqjAiEcwUFwd/KXqE93t2/O
         wmPZLeCkK8jM7JynYNAwz4MPCuSUh7NfIOM6YeU/173URqw4lpj6HBzKIguPbqTPbBLn
         x4WkEiv6/UNLore9yC6nFzHL5VsAqHsl6o2O+TsS07CKUEiuIEl6Bit5ZrTGKiHf+Wsl
         ndgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SFF/l4UF";
       spf=pass (google.com: domain of 3keuaxqokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3keUAXQoKCE4q3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g28sor21481810qtb.3.2019.06.12.04.44.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3keuaxqokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SFF/l4UF";
       spf=pass (google.com: domain of 3keuaxqokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3keUAXQoKCE4q3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Tg03Gniv02ZbxFz4TR6ORKJ5z+YRDkk6YMGCeNMzVJA=;
        b=SFF/l4UFcejexpzLF8WLlQfmQ26wur6/Lp5UaETnaEcEawlk3l/6lGLaUMMooAgs8s
         H8BXtM8Po2kTy/ERZiKnsQjpEuZwCfivxhd6SyQ7RL+iB0sQfj/clPfIeMIPz6uKVDLv
         xUHwWlMKGfxD6gcgGhDGYlQ/8FvPYT93r6i2RnedCW6E6xVhUJOencUb8rKP9J6i4iHL
         r+rptZFaLXc6jhn3wSb4NX5Q2zQt78sd6zAnhaXM0vfZ1qtib0qyN9SWZBmopO4jCPUZ
         R6Ny3CDz7f0jULr5eWdVbsgq1nlATw+QzZpUThV+z5VYuwsEypjY/9FNseoLEmXCwIbk
         +Rew==
X-Google-Smtp-Source: APXvYqyCeVb0C2VnUmKvZl/NXpmzEb8PXfZVfFDAeRPGCnyVezO7o0ITR/pw5X1cgaGDH/zdBw+sIaHhGO7/u0mq
X-Received: by 2002:ac8:5485:: with SMTP id h5mr67932284qtq.253.1560339857730;
 Wed, 12 Jun 2019 04:44:17 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:30 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <9d68d9e7f9f89900adb4cb58c34ffe532dfb964a.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 13/15] tee/shm, arm64: untag user pointers in tee_shm_register
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
2.22.0.rc2.383.gf4fbbf30c2-goog

