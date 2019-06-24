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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B797C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C483208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tMmuoJLk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C483208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05C48E0011; Mon, 24 Jun 2019 10:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB96A8E0002; Mon, 24 Jun 2019 10:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9569F8E0011; Mon, 24 Jun 2019 10:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 744C28E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:39 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id p64so6453267vkp.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BJsyngqG/QyGrxCP5QV1VgvY/ZIDb46yXFdUWUYcJjE=;
        b=GxDl2Ug3RKsW7QfUJuKa1MdI7jNDM/dKAOAyVwJSzCzq7DmMqWZ+hE9k7h5Ln1wak5
         psQuKBBYD7qMY1H8Ws5Knpu4ayDqa02eRJ4ERu2X+Pdbj2ZA8cv2HJTlPT6uyWl6NU/t
         jn5742pYod+sP8A1YMPq2v4rdXaUIIHO17Z6kx6uXil3zCMSSfDHJiupXxZKw2wftqYF
         KsVLn+8i/nnSYtzncE/ehMap0u3MkYBl8SU6hzFY2ybm4ahMmcPirme2RgCpOGE4Qcmy
         ntp+ucJdtrluqHUbDaQTZgA65f6hOhGYF50fk5aWLgi/cjKHSeAEMkyc/MJ58YkDQ4NR
         VS/w==
X-Gm-Message-State: APjAAAVfgDYeOl0ozPCrkkSYr/KGPLOH+0rkRnNXvDtKGyy9xC0pWHGD
	Yz9Eywxht5sgA+y7tlG75E8mIpu/Sx6YUbMAZFxaCIgI++cQrNlukpP+WlqYjRk2y+UBURjt7SO
	AVXi3FuQwLZ4qLHeHTquy1Y574YoPI71oQzonaC7Y2CnPtH5OAXEyw88ez4DIdgoD4A==
X-Received: by 2002:a67:e9ca:: with SMTP id q10mr62076963vso.105.1561386819177;
        Mon, 24 Jun 2019 07:33:39 -0700 (PDT)
X-Received: by 2002:a67:e9ca:: with SMTP id q10mr62076929vso.105.1561386818636;
        Mon, 24 Jun 2019 07:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386818; cv=none;
        d=google.com; s=arc-20160816;
        b=KU2/Z+5RCAANICCozf7Mzo9peMeapMJfOz8NNSvVfLTiaVJIeIqIVDi3OrtANnLlwQ
         76zGrKuR6LKVsfOKrxHESw6inRgqzNZCIcmTlPXUk5NERA8BZIJVzboNwmrHog/NjuR9
         8EVxWxA9GcUVlBaKYLiJQLzWT9RTnxApW6l946isXyUzXjgxWRS7VbY381X9d9Hm5TpL
         dSTZuLt7bqMcUObpkjRAJ1MRA6k61bNGsLT91axAquVJy5uUXqYwGA0HMBpug7Vp0Q/3
         KrNMVqaIBdzsXZ6tayj5P1b/jn6wFoz0CObR7TMX0AERKLiCGnOFIxnFB7U0+Ex8b4Cz
         4+dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BJsyngqG/QyGrxCP5QV1VgvY/ZIDb46yXFdUWUYcJjE=;
        b=n351q5cSXSD7bdnVu0aUMTKwWH7akC7RTeRGFli4KWaqF+GJz9gKHUcZAtTi8/1Onb
         31y/oGSywp2oh83IdYbzD8KcTfy5ZgkwreoDUowgSuM3JUnu3O7kiKZ+BOK/XJOpsa/P
         od1eKt9NkCRt9UG0JwrVmbXcPhTtcuuAzhioOm9hSfZbgjT8iszY8wyHFMQmqgQyjv0d
         gK5/ulw2eGt1c0Be/iorDtDqO7HagdxukSuSlDvIDuPBN1YL4PGegZbv/NHiEBU4qu4d
         b79AXA0Lmz3boHwKsL464AFp0smJPWEftXV6tJGr3nQXMtxcdxO/s5he/BY4bsno0ggc
         vMAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tMmuoJLk;
       spf=pass (google.com: domain of 3qt8qxqokcdmpcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Qt8QXQoKCDMPcSgTnZckaVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e21sor5671280ual.11.2019.06.24.07.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qt8qxqokcdmpcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tMmuoJLk;
       spf=pass (google.com: domain of 3qt8qxqokcdmpcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Qt8QXQoKCDMPcSgTnZckaVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BJsyngqG/QyGrxCP5QV1VgvY/ZIDb46yXFdUWUYcJjE=;
        b=tMmuoJLkJJRlr97nWuw9yp1dhBnjJgJJVctCCMOkVQAwVufIWjtRSJ98DeVWMAUpL7
         c/DDMKTfXjJ3AunXbS9PbtesoR3v6FwAquf/mPo2ipW5m7uKq3mz622OTJgF//P41VeY
         uBPVky3FH88ifuyXm9IjyMmdhNWu2I8INL87p4oZ1vAogbY0BRq3PmSNaYTl1n/7bnrO
         Lc9PPi+EV8QQhe4FjeigOim3EKL5tCU2OhJP5k8d+H2v0cMsX/+SwQBn01vR1S+aYe8q
         kmK501SZalx1YaFY0Y1ChZDATvY9Cs1dirj078l2AUk0ox9yU2Ud6XA8n+4rc4SVim6s
         D61A==
X-Google-Smtp-Source: APXvYqxgB5X/aCbKs9hmuZWtlXYS7x7msb4DLFufqsMoO6mME7B8su644ppdcEygFH1GnaKdKATNFxnkdsXw3C2U
X-Received: by 2002:ab0:7782:: with SMTP id x2mr22851192uar.140.1561386818133;
 Mon, 24 Jun 2019 07:33:38 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:55 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <61d800c35a4f391218fbca6f05ec458557d8d097.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 10/15] drm/radeon: untag user pointers in radeon_gem_userptr_ioctl
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

In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
userspace pointer. The untagged address should be used so that MMU
notifiers for the untagged address get correctly matched up with the right
BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
provided user pointers for vma lookups, which can only by done with
untagged pointers.

This patch untags user pointers in radeon_gem_userptr_ioctl().

Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
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
2.22.0.410.gd8fdbe21b5-goog

