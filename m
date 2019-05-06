Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7155EC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26E0320C01
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fxyQnlZp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26E0320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E40C6B0274; Mon,  6 May 2019 12:31:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797666B0275; Mon,  6 May 2019 12:31:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ABC86B0276; Mon,  6 May 2019 12:31:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 493E56B0274
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id v123so26348769ywf.16
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=djVJuNgpi4hl4AvZn47gmwsvHOuvfT3jzvA6F10IO5w=;
        b=OPErGSm22s68q/61XA2uYsEXmgG5eNAR+mQGuXGx8qbHNzwiLgHIp1yEQ+FKiyIOV6
         yTvrfDON9RM+lMV7k36/eSZw+EP3iV9dugHynuo0ODxWwO3my1wSwPynqlE3RtpdKkeV
         2RzlX9mvUn987Hd39YYbbOpO5NHSmXynhKAR/KbeNkBon2KDiTof7QEn+hxFoCUgeQue
         j0ulrwYl/OMI9cf06bwll8kN7jF3VMP5iKzQMOI2OndQGc0MAY3FNSyQ2SWZMJR6GiCP
         4tQ1inPD2PwIfQ1XZVyZNcIH5YrV2LBy3FaDTGUsH0CY2Vp/tiYpGQZUgFUE1CEC9Dbn
         7GDw==
X-Gm-Message-State: APjAAAXBQP9icYCWNq+xJq/l8mzoPrlmewPtF8bH/uro7Uh27E77FGfz
	NWminWgO3mwoJFKA58vjmvHdyXtmQbc4WErPWiECv/cS0BQ57kLlz6BaQVUPydfPksOSyWj88H+
	dA7uJN5ypYTEtOLbzuRXTZhfBv1tZd1QvSmfBAteReN3li9IPUhzYrCw6Aupj/ys4Uw==
X-Received: by 2002:a25:d2d4:: with SMTP id j203mr18472232ybg.354.1557160302057;
        Mon, 06 May 2019 09:31:42 -0700 (PDT)
X-Received: by 2002:a25:d2d4:: with SMTP id j203mr18472195ybg.354.1557160301418;
        Mon, 06 May 2019 09:31:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160301; cv=none;
        d=google.com; s=arc-20160816;
        b=DTlzRRRboVwFCvE4Bq6RiIG+712Y+T4LA68uPhrjUjjUj0tw1Jlawdljq+nNbSzGZp
         XfSnDHixfS7erSxMKgfR9+zWHYVECJxstEduvXlx5bNqtZ8ZpHbotqWzYSyr7GyDtF/o
         2jnQISQcb9zDorF5SynkJ3oMPWpTS7Y4UrNS16HdUCWmGTeRSL/Rvlh3+MFMgYxy2jdC
         vAhtDeFrrZqhCUA3KFUp5zHrvWH9OsUTb+2/ZGCyFbqzc/tKVT31erzS3PvWIh2apqvi
         +g7AMHOGCIDHfwXG0+0f7u9/p214Z4wkK7z7knX6u8OA9jeipDnEYD2L34fbHQlOhT7s
         uANA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=djVJuNgpi4hl4AvZn47gmwsvHOuvfT3jzvA6F10IO5w=;
        b=KoVW+1LRqxjP0UZsaQKf8OAXdm3QIchASvfofUOnyp2SPN+HMixvUG+TDU8GFNggll
         /IcW33W0IIRTSMiyg/9wUEdtSo4HTlD2VNY6BLjkNDnMiyCm+7TpB81u2LZDiW/BwhMC
         N15TnCG4mXLT4MQLlSEhXT39AseXsCAZKA5CleQgssSJts+33gyq/QBB1kO09/YoqWtu
         sQMVucTV94BG0l+bjJmZ0jVjTvdWZHce4xbZxbPjBVYjpWXt7Sy73raFupUozzO18wgL
         g5NQATOmfsHKyPCyb2x2mc1gtID+8EED91KWg0QN+ccpvXty8DUKJEx2SgTPOotZtkX8
         5aDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fxyQnlZp;
       spf=pass (google.com: domain of 3bwhqxaokcf46j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bWHQXAoKCF46J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d124sor4864971ywb.205.2019.05.06.09.31.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bwhqxaokcf46j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fxyQnlZp;
       spf=pass (google.com: domain of 3bwhqxaokcf46j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bWHQXAoKCF46J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=djVJuNgpi4hl4AvZn47gmwsvHOuvfT3jzvA6F10IO5w=;
        b=fxyQnlZpVUSYjQyqKRvVjTFbSpnAaN40vHoDyTt86Wr9XkiWv6H47O5fV6+YfqSjKb
         ya9LAHunO5tkq38NxGwIBHRUa8t3xRmbLIMp/Ei/Ay4bKwx0V2sP2cpbt1VZJxkDe/I+
         9QcnUwoNsbvRkE6TQ1eqETcSj1FHDhcRF+86nS+29Dm7yx2+fQzWUL/UiXGimZGBqjEk
         x92RLHdIO29i4yL8cPFFrUa5OfqGP4F8w4+T2ndS2TLCjkCTICe9DBa54uexWvxllQFG
         iUS8CZcMLYnxYz/mG/GVZOcto/nPYEof7WD9aPSyYBI6CjVI7kE5mMY0QntuPkboh2oc
         AONw==
X-Google-Smtp-Source: APXvYqw1IXBcBTBvqlPhK0DepGTPQ34Nul5KO/wJ08CLzILZcvtlszbJT4QAmRZRcoo1MWPuYSMoe4MfIRPtaEwV
X-Received: by 2002:a0d:e60d:: with SMTP id p13mr8305580ywe.155.1557160301102;
 Mon, 06 May 2019 09:31:41 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:57 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <84676a97cec129eb7a10559ceae2bec526160ad6.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 11/17] drm/amdgpu, arm64: untag user pointers
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

In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
an MMU notifier is set up with a (tagged) userspace pointer. The untagged
address should be used so that MMU notifiers for the untagged address get
correctly matched up with the right BO. This patch untag user pointers in
amdgpu_gem_userptr_ioctl() for the GEM case and in amdgpu_amdkfd_gpuvm_
alloc_memory_of_gpu() for the KFD case. This also makes sure that an
untagged pointer is passed to amdgpu_ttm_tt_get_user_pages(), which uses
it for vma lookups.

Suggested-by: Kuehling, Felix <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
index 1921dec3df7a..20cac44ed449 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
@@ -1121,7 +1121,7 @@ int amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu(
 		alloc_flags = 0;
 		if (!offset || !*offset)
 			return -EINVAL;
-		user_addr = *offset;
+		user_addr = untagged_addr(*offset);
 	} else if (flags & ALLOC_MEM_FLAGS_DOORBELL) {
 		domain = AMDGPU_GEM_DOMAIN_GTT;
 		alloc_domain = AMDGPU_GEM_DOMAIN_CPU;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index d21dd2f369da..985cb82b2aa6 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -286,6 +286,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	uint32_t handle;
 	int r;
 
+	args->addr = untagged_addr(args->addr);
+
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
 
-- 
2.21.0.1020.gf2820cf01a-goog

