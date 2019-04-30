Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E58A6C46460
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96F8B21734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eEiOGFet"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96F8B21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22A206B026D; Tue, 30 Apr 2019 09:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DB416B026E; Tue, 30 Apr 2019 09:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D386B026F; Tue, 30 Apr 2019 09:25:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC2AE6B026D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:55 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id b16so2349065vsp.19
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/erHdYVyxDvhPu3v7RMhd3dO9bpNIdyHyuRFKthPw/o=;
        b=IHq3Wr4Huctx9OYtdaB+/9iMaJTLKoh9m2dAPcZY+o8TIcvHnyJgELyQ20PBB1329G
         J21kEhKed82q0HR5+SG5LMNzqEc1UtHppAc+tJhXu6kAekaluXVnegimMNddUA2V39Vf
         cSy8/EVDwfS4VN55IXH50vg7MfhiDIzs3GOiKN0ybWNAyDdYPeSsI69xT66rjahH1w1H
         mHPqIh4VNNuqbb4Io7BGiaf+F1wLjSKbxlUO8gUPGb9411bR34sh2TGRQcRiRjMUp428
         e4B8vFbTiXcb3YMzPeD3iIW7fmcZaXj0bX3aV/vouMF4Nr3Z4TlMVMEC/pJ1knhX41Z+
         vTdA==
X-Gm-Message-State: APjAAAW4wwW1wHFpOAy4nW+HcFLZZaLw4/8IL2Oscd71oJvBv9GR800B
	gvGpQ7NHt52PIW27JeMe9bLzU5V4CIZ3Xki4KiV3JfHBnpigEnCgjuSlwp9N6cly5WDcc/soLum
	x25856+I5I7iVdwPrh/MzOECCdeOHtU7tmU/6w3sjKmZba2LmmexlU3dWwgxG/HAFPQ==
X-Received: by 2002:a67:7a43:: with SMTP id v64mr36545653vsc.54.1556630755501;
        Tue, 30 Apr 2019 06:25:55 -0700 (PDT)
X-Received: by 2002:a67:7a43:: with SMTP id v64mr36545622vsc.54.1556630754825;
        Tue, 30 Apr 2019 06:25:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630754; cv=none;
        d=google.com; s=arc-20160816;
        b=oriHFj9TLFEeTfWVEvGDUvyAcuv6WD6vNlrhNzfHj1hPgTfFitF0qYTU7ezODF88Nm
         BgXv3omhZcQECYgO1aUvisF09MOXJC4PCLQW8FwvOsKX7SPcyAlVXW2O9GA+H5EspF82
         O6FiNoVP4rE12tQiYIsxyTLOjuxqQ9zhiZD56mv7Yj0gJmtUj5mk3Ig6lUrZRRVceonN
         RMMOrmyHtAEQ+PV76iogYU/gmGH0jXjzVY3t9BaDAtsA0NNh9MTprW60ug4nVp/MaSYU
         dZsJrcJ+kOltt9rgNhXp/BsgQB1mVSFJI6rrgGNDQE0Rd4FFA3DsEkc99eozDyi2QM3d
         G1dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/erHdYVyxDvhPu3v7RMhd3dO9bpNIdyHyuRFKthPw/o=;
        b=Sd0q12FVI8GPOPcdrrpai9djXJgl2ad7HCJPMsQp9JbhQka9RsLp8vStwxYXsW+VSR
         Z9xllZFuW82JkYoj/g48ugL7X18XVJey5liX/txQav02JBgynORCYJHM0D6iuZzFPaLR
         JptTFlFyXTv3KoiOvc//VV8shx7wwIJKqanidud4RyQv0PuPfbrbVQOvvW3CUUX5nj45
         Xzl1LPesxZeYDplEhHm23fn+FZkKP9on7o0zc/pHsEepPBTi+cXfYIp/9OYkBDT7GlSK
         /4sGTkE9AnR200uBtn7tHlTNXVxFKuJAkTsqQVhgwBndoFK6dAOlgRo8zCQ6QxrElqPn
         edoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eEiOGFet;
       spf=pass (google.com: domain of 34kzixaokcikn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34kzIXAoKCIkn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g12sor179954vsq.37.2019.04.30.06.25.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of 34kzixaokcikn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eEiOGFet;
       spf=pass (google.com: domain of 34kzixaokcikn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34kzIXAoKCIkn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/erHdYVyxDvhPu3v7RMhd3dO9bpNIdyHyuRFKthPw/o=;
        b=eEiOGFetYWxih+SqIZFzGNfWcb2WG27fgr8umX6U99zGn9TVk7qoyvUJvyLbyO9646
         My6AFQXfx+E54pBbdCbbmUTy552nSiekbu8p+Z3EjOZkkRzKh6/KPKq2xMXR6PGCbeOC
         fF7Wnybo7p7oNGCxEtdGcC/SjUjb33krZmpxfplFBazN0BgfioX0FSzySTA4N97gTFrT
         W6ijBCliSwnkOOpdiWk5kSemwYixok6PKUQxZHW6VplcdEwGvrCZqCKdW+XjRywAL4b4
         tr3KgVn6nyJgYRcK+gwURasQznomoMLJd50NL8tFT/I0TUKbeATfwfeLLEXDX2wH0kWJ
         cXSQ==
X-Google-Smtp-Source: APXvYqz67px3tLUaZFP489IW2cHQSs+LvJjC7bfPcwFfPsiBelEm070ukqvUpFmAC3UEaQxQ+Sud/QNcvCPvUR/K
X-Received: by 2002:a67:82c8:: with SMTP id e191mr36596964vsd.24.1556630754448;
 Tue, 30 Apr 2019 06:25:54 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:08 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <9a50ef07d927cbccd9620894bda825e551168c3d.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 12/17] drm/radeon, arm64: untag user pointers
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

radeon_ttm_tt_pin_userptr() uses provided user pointers for vma
lookups, which can only by done with untagged pointers. This patch
untags user pointers when they are being set in
radeon_ttm_tt_pin_userptr().

In amdgpu_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
userspace pointer. The untagged address should be used so that MMU
notifiers for the untagged address get correctly matched up with the right
BO. This patch untags user pointers in radeon_gem_userptr_ioctl().

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
 drivers/gpu/drm/radeon/radeon_ttm.c | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

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
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 9920a6fc11bf..dce722c494c1 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -742,7 +742,7 @@ int radeon_ttm_tt_set_userptr(struct ttm_tt *ttm, uint64_t addr,
 	if (gtt == NULL)
 		return -EINVAL;
 
-	gtt->userptr = addr;
+	gtt->userptr = untagged_addr(addr);
 	gtt->usermm = current->mm;
 	gtt->userflags = flags;
 	return 0;
-- 
2.21.0.593.g511ec345e18-goog

