Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E4DEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDA5B208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ABmMcgz7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDA5B208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A42C18E0010; Mon, 24 Jun 2019 10:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A5E08E0002; Mon, 24 Jun 2019 10:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845048E0010; Mon, 24 Jun 2019 10:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB5B8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:36 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id b23so3937170vsl.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=28kCgmnVQJn+BZTUIaDgZIVH/xo2y2bOHrwsQUj+YbM=;
        b=GiY3knpd32rmMIgPy0gHOp67a2YvwIbwHQjbWnO5BSspwmyatdUqoHXNTBKR6aRx62
         N7ZexSPYwxpHjcKsxMWHXPe0i6o6wQHhbosF4Mmt6LTFAsrV4nPaIYrwodrVfBrI4g4b
         JeKkwsaU2b/8m7dLisabrnkptwCP0cZbWeSxIIFd1QSCmuZs+Q5l1koMIovxQGbcsRcA
         FZ1myIG8kCJY4df6YFfhbmICH7Ayym/wxA6j/8WxITFd9Y97WL41mqjWVNcGLzEZAOj4
         kRL7DllaQZfCcPmhSydd5HuhB/+Zqkm2KDEs21fbuKFkWgrAq/hQtExjDWhrVsMV3oLI
         dGAA==
X-Gm-Message-State: APjAAAUYDmlCVQdJBNh3qh3JpkM3hmQFkMEcOaBYVcy7u6rTPJb6liXd
	OCcrKgzMukDkf9PoPbKQ4Ow79yWzICqNQCBq32gfMYKT1ZNhfgWR85vJobZURyFte/3Pp0BGhMY
	hOuEXNsKLlo4P6BDnRui23rLgVANWOlurvYZm4Th9mKHesYwcWQzIgbZPYcdCI5mFnw==
X-Received: by 2002:a67:7c92:: with SMTP id x140mr71027023vsc.229.1561386816013;
        Mon, 24 Jun 2019 07:33:36 -0700 (PDT)
X-Received: by 2002:a67:7c92:: with SMTP id x140mr71026992vsc.229.1561386815419;
        Mon, 24 Jun 2019 07:33:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386815; cv=none;
        d=google.com; s=arc-20160816;
        b=jTWrRV9sPNk4/1VByLypdZ8U8ym/JeFBqWhFO3UsmNRd+0mx8HhMPRALg+gjmmW8YG
         b1TSwSSObbQzTiIvBb6tO8Xalb2LTo+eorCvOHUM8gNZyLkT1MNekDtiL8RzxUsOpOvL
         O9z3mhHUXoNe/LxlSDl6VxX1PykI3dAGO8aM5TFwRKnNx8z+6q3h547hsOhmWakmX36+
         BFR1oES4f0oiFcuwt8OE9bGY8Yk79qVEIk8Gevic6InD1C7SY8zNTa6VfaFmMeYs4rzv
         QL7KiIHB1qXHkj8OPbMwKB+KSHp6+/l65gsQIjP+Fa5kpG9DgT7o/TNBiuySItb4E4aR
         i/xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=28kCgmnVQJn+BZTUIaDgZIVH/xo2y2bOHrwsQUj+YbM=;
        b=iVY/3PzbQKumB90MEhOEdUHoYlwo6jNdJxhD1IIxvodsKbw6BhN7AzO2W/O0+1WEzJ
         avgnLwOtc59zQAg07I0iLbWsRBPeZkTk1JeEgRaNBdbBj0i8jRWaISrzesZlTg/ZKOjr
         hUYr6Q4vcANMRZHj6pew4OM/Ntqa6VDR3hObQUWZJAfZKHZE5dnhgkgmSDQdDdON1qQ/
         HLphH31JGH7M6eCq3AlPmDwjnz3LKLtygjC0GHY+/Iq5S7z4Y/ieK9jGoTCwpZvJ0Ic2
         KQ46v/F53cYSoYl6BA4lyr6kfZea+gMRVhkJ6Ime/VzcE2qCdBm7eGp4vpdXPNfHpd9v
         mPUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ABmMcgz7;
       spf=pass (google.com: domain of 3pt8qxqokcc8lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Pt8QXQoKCC8LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 64sor3541541vku.66.2019.06.24.07.33.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pt8qxqokcc8lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ABmMcgz7;
       spf=pass (google.com: domain of 3pt8qxqokcc8lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Pt8QXQoKCC8LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=28kCgmnVQJn+BZTUIaDgZIVH/xo2y2bOHrwsQUj+YbM=;
        b=ABmMcgz7AotklEeh4aKRTIHhpGJQax1zmT5GPHXjwooqibRCX0X83G+wpDe15X0SRe
         HXe9A2NvGDpBCmPVnJWVtQfrGpLCbLOl8a7QKidgVQZS583p/fioInBWA7fnqQUcPu7U
         DvrTBHAjvD9bvEv4FtgsxMoYukH2FWhUY0cxk16hnaOXVOPeSCjP81uMpB44OL/S9lPI
         aBpKDHVXZkog9XLBmaqt8fwsR9QWzkmPDHX6Y9oJS6A6dF2fyXmif514CVj9w8GAfMxh
         0cWaNfDCDK5rhCagjFyHYvWusLBZwBz8roAGGf8iO/F/Oiq2iyr+j9wwDpgGJziFwszL
         TQvQ==
X-Google-Smtp-Source: APXvYqxFRRLv3BUPtPxjHGRaBJrhiwF+VRuSavZL/k035Tv2azTfOuV+FpSvTW5kRizXDXNW3SNuKikp21TfCtFX
X-Received: by 2002:a1f:9748:: with SMTP id z69mr4561739vkd.25.1561386814933;
 Mon, 24 Jun 2019 07:33:34 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:54 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <1d036fc5bec4be059ee7f4f42bf7417dc44651dd.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 09/15] drm/amdgpu: untag user pointers
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

In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
an MMU notifier is set up with a (tagged) userspace pointer. The untagged
address should be used so that MMU notifiers for the untagged address get
correctly matched up with the right BO. This patch untag user pointers in
amdgpu_gem_userptr_ioctl() for the GEM case and in amdgpu_amdkfd_gpuvm_
alloc_memory_of_gpu() for the KFD case. This also makes sure that an
untagged pointer is passed to amdgpu_ttm_tt_get_user_pages(), which uses
it for vma lookups.

Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
index a6e5184d436c..5d476e9bbc43 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
@@ -1108,7 +1108,7 @@ int amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu(
 		alloc_flags = 0;
 		if (!offset || !*offset)
 			return -EINVAL;
-		user_addr = *offset;
+		user_addr = untagged_addr(*offset);
 	} else if (flags & ALLOC_MEM_FLAGS_DOORBELL) {
 		domain = AMDGPU_GEM_DOMAIN_GTT;
 		alloc_domain = AMDGPU_GEM_DOMAIN_CPU;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index d4fcf5475464..e91df1407618 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -287,6 +287,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	uint32_t handle;
 	int r;
 
+	args->addr = untagged_addr(args->addr);
+
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
 
-- 
2.22.0.410.gd8fdbe21b5-goog

