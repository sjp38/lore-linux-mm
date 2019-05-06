Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7FDFC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A203A20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZSFHbQPv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A203A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CFD6B0275; Mon,  6 May 2019 12:31:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4DEF6B0277; Mon,  6 May 2019 12:31:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3AEB6B0278; Mon,  6 May 2019 12:31:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9A706B0275
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:45 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id p15so4532935oic.11
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=eYbhxmTmdaiTVlq2aRmj2n9QkL6CX4/S4opJ9oDHFhE=;
        b=fD7qdH3Odp8kVHZg3EL7cv4XYcSSuLboJFUSbI9ZvQ4iWf8Turx4qwURo98rAuMm6k
         fbJasEom0UMmJ7go1i8Wr6UZox6nuLaE2EUSTxigVtskMoSWiIrWjYliEbANE44ERZLl
         jHmd7x4u0wHR/1XaDTjcgcKKLZHo30EU9AZC6vg6oUbMgc83hzJSWwa75iMvrncp+6F3
         4z3KpWzhc6EVaC27QvVO20KGgo9NYuEXwGCS2V1h70X7SRgBJTLDF2U+CPwRaoqD1uKd
         yDBWD+qKFuQhsHDSx4kOsBuG9Gn6Nh4HX4AkiobSlMgvUQCg3fKSmQLR/cGMFG7uUr2B
         v+Kg==
X-Gm-Message-State: APjAAAVlywf2Fn6gPP6cz8wibL/Ze5xuRkg3YJnfMe9aCLji8hRmdfb/
	c8CLqNZtZBtKZQdqhUKj6Poi2EcdZMUIfllZ7eDxvSXZZ7+uk4D1X+NqAou0ZTiHTPpHh/CtZsV
	SkRX66eH2dcKlUKXWidrl1B7SF3BpKybimF2vi0xB6HC/+wIb5SxUfq2pQIRUVwpmgA==
X-Received: by 2002:aca:b30a:: with SMTP id c10mr1740788oif.74.1557160305300;
        Mon, 06 May 2019 09:31:45 -0700 (PDT)
X-Received: by 2002:aca:b30a:: with SMTP id c10mr1740735oif.74.1557160304486;
        Mon, 06 May 2019 09:31:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160304; cv=none;
        d=google.com; s=arc-20160816;
        b=J5xyOUc7PSfkoHqXoBfBjxDZwDyQAYdvuDx2Gc3rF2Gbrt8o8ZmS7zkEDHeu/F0OsJ
         fhVraer7XegbWMSBzK8O4yiwXeo7imAEl0fcPAI9PGPLMGuj6XRXW5a5zxlfvw915n1q
         L8gl+gF/ajXywUoD+A/uyjP2ufRliDhuP3IBje6Pz9rMBmqdv3GfVRqY9+GA3DrwNQOx
         T6SOI8sI8K6jcH36FTUP1FdT5KVO8O8i9htHkMaqqXCVkqvxEy1axu3GVNpPkIkK6m3T
         k+A30E7WUgNZnclSIBkSbJsbEhuDvKU95RJYyqZ8CRnnsoaLemfXGHMCaGCnldDlBnep
         N8qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=eYbhxmTmdaiTVlq2aRmj2n9QkL6CX4/S4opJ9oDHFhE=;
        b=zls7cO5Qq0J4qMsp7ShyFLpPF0Dx4pjG9cCpNUBmjpk+NUH0yhMxk19aRp65u12zjW
         EKX6H5XtLH6ConGz+EQ63S/uxVp8ZO5r/iCyNPjJ2vdAay1Apdt/ftHMs6lU24D9hoR/
         /yCpoUEET0xgPcoy/o82HHV3JpTQoI9wjtHMhDMXpzd+tU8FKImGhkQ1rNL3CmIjLyjh
         rJ07xIQqH7l8laPFSX/I6SiPTQxR9HtGoImYshXFFxb5Jy6YLxNfsd6jVgee9/uyd8Zx
         5u6ttEvJKqmgq84gBwzUoVJW6urRs4cBKyCvg5Z5L19O0Vv7e8IPDCiCYyc6eKuk78tk
         HxEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZSFHbQPv;
       spf=pass (google.com: domain of 3cghqxaokcge9mcqdxjmukfnnfkd.bnlkhmtw-llju9bj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cGHQXAoKCGE9MCQDXJMUKFNNFKD.BNLKHMTW-LLJU9BJ.NQF@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y6sor5040314ote.22.2019.05.06.09.31.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3cghqxaokcge9mcqdxjmukfnnfkd.bnlkhmtw-llju9bj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZSFHbQPv;
       spf=pass (google.com: domain of 3cghqxaokcge9mcqdxjmukfnnfkd.bnlkhmtw-llju9bj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cGHQXAoKCGE9MCQDXJMUKFNNFKD.BNLKHMTW-LLJU9BJ.NQF@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=eYbhxmTmdaiTVlq2aRmj2n9QkL6CX4/S4opJ9oDHFhE=;
        b=ZSFHbQPvMQhkrf29+rXmES4x80rxWQfO3CRg3EirSkEvMHaN6TChbsHuGqG8tqYPqI
         EOCA65HA1vwG2VBAq4EN+A4OM16jXXWhM8t5gUCVAGxaFpj7A96cWjckSSXVB9ifgUBP
         JPRXtbLz3WvjXz6TEKimgkTZH4CSKnvPcLkcG+UwjiKkw5OJqJ0dywa/iWl3MUEMoYLx
         yX/R0TAlH28V7Dy/lDpZ2CQKiEy+5rLrSQMyM1Z1SBWcw4VX+lOfzjflOLQGIDoNcKIy
         Lw+nu7cdx5CVE6SIyoKDCFcQFHBzYbom0atBI7FulTuqD2oMzEvZRTJLiB0pdkfBeBX2
         irnA==
X-Google-Smtp-Source: APXvYqzdzQlfaHkw0Qwo4QQtxGeWhxSSS13Ps1SOtj6ReWwWjESZwRkhi/LnnldOgTKgizVRLfncWXFiUgbgbiQx
X-Received: by 2002:a9d:7d04:: with SMTP id v4mr16958653otn.185.1557160304159;
 Mon, 06 May 2019 09:31:44 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:58 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <03fe9d923db75cf72678f3ce103838e67390751a.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 12/17] drm/radeon, arm64: untag user pointers in radeon_gem_userptr_ioctl
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

In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
userspace pointer. The untagged address should be used so that MMU
notifiers for the untagged address get correctly matched up with the right
BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
provided user pointers for vma lookups, which can only by done with
untagged pointers.

This patch untags user pointers in radeon_gem_userptr_ioctl().

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
2.21.0.1020.gf2820cf01a-goog

