Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E057DC04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92D5921734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="btEcp2ne"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92D5921734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3611E6B026C; Tue, 30 Apr 2019 09:25:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C42C6B026D; Tue, 30 Apr 2019 09:25:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F0206B026E; Tue, 30 Apr 2019 09:25:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA5DA6B026C
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h196so4278380oib.20
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=+qKylFjMLP53K9qAejYeg4zQoAltlSq0MdIVnvcZCpk=;
        b=hbXkOwyjPf6oLgktQALbfnXLHXyNHpiF3VWgk0lYL9/jrTIZ3qS9l58Svhh1Mukv4m
         zUIq0aaAWW9SpM/GyvurBG0svCcSS6P/jL8AC4/37gpIrmWpVSs0PHIrtt8iXoWmx7Hv
         6xl227f+SSMq+t05L/mnXb10GJINTiu02AxxBEFyoNJoJw6pckdVDCF4ZkGMSGRW3dON
         ix7a/3snMaRjZmDU/OlyNI9fJRJn+QME5VBbQTp4I1SNc8MiLSmDl7JV/2LHWNPP6Wec
         BGP5M410oiA0OU3t7PwE5ZQ+AibGn8lMt4oZ/t7ta/eOKc9MIWTZA79ARtJskQz3ElEs
         LhlA==
X-Gm-Message-State: APjAAAURmMieSLZZ1Ai4vrSHXedKHLowbTJssm+euSrVRSKXQkvQivwm
	7Ma3fNQFdBR0+YO8TZ4P4/TZl2YyQ+apCPp3pWpGVLsHDKg3lGIJUkkDvj/IL4FysBhypwlJOyl
	yZIpYy5/S2b61Gm2NrTbfpFxuI4jQYxG5tk5tBA8NJ2SRXt2T0UrGLHud6BO/JqlRXw==
X-Received: by 2002:aca:bdc6:: with SMTP id n189mr2975886oif.77.1556630752464;
        Tue, 30 Apr 2019 06:25:52 -0700 (PDT)
X-Received: by 2002:aca:bdc6:: with SMTP id n189mr2975833oif.77.1556630751698;
        Tue, 30 Apr 2019 06:25:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630751; cv=none;
        d=google.com; s=arc-20160816;
        b=HG2W2WhwyulFhrV62pYrSsMBTLhVM12KXEQ1pfQVDBVIpMOgr9kAqN7Dmdrirh563z
         cQzD53xNLe7dkBqm6b9M+QRNxJ7Qdo9OVYBoPtLte5p3up5CO/CKOURoREnErbMzmAXc
         2tT5VioGc6NoXuG6auIDxZplNOwzHytojcRYdNMx6PWD5pPAvLcJ9UIiL6NaLVorUGwH
         VKgGfrL5ZZEg/tC4/cV32yExxzkMqUKY1lqbzNZNIUBQhyzqp/D01t/OkAGyl7umjmZ0
         WugDHRTuSp7KkMUMAJ+wtv7cw3/VRl7+hGKDBglLrQ7FOFA0uXolFth8ZxgXWmLlHaHD
         lYUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=+qKylFjMLP53K9qAejYeg4zQoAltlSq0MdIVnvcZCpk=;
        b=ZoeBfqiki/NQJL8wG7iIRk6npJeRO/bHLY4FE5u7SwSaLoq7rumyMnZfwoapj+dbIz
         1k9Iwrov9uxbxi34uK1lhrczv2SW115nZJ7FU3iY+G+6+eUniuCH0lQq6ohEMV0Pxbgr
         dfUmpjFMK6Jj+VnqdVeFaPA0d9xdPi5bTzJLSUMS9hMK7Y2yDGwnkVErhYJ4SuzEQmN4
         4R8Q17iMXkYzVhfVeunKfshrayV4g7MwZKqizpxAyDA9GYWnPEFjK7jaPtZcBR+OJ9Gx
         U+U5etaWbvEd2bUrnM7E/SsOIOP2RPr9UEOVu4W+BP2ob9gVaqO+U/XmMshXGuTn5pHb
         sqqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=btEcp2ne;
       spf=pass (google.com: domain of 330zixaokciykxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=330zIXAoKCIYkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h7sor453485oic.18.2019.04.30.06.25.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 330zixaokciykxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=btEcp2ne;
       spf=pass (google.com: domain of 330zixaokciykxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=330zIXAoKCIYkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=+qKylFjMLP53K9qAejYeg4zQoAltlSq0MdIVnvcZCpk=;
        b=btEcp2nedxD/RSSqWCBp6Rk8cMJhftnRu9ZW20tW9H57Xw0aRxokGUkdPaQcz9rkFo
         41vHcxVyWnumGF2h8AA/tvaQ1eb1WCyLG8jJc1HuBhG3r5Wd1fM3SW30CuGnpg1TRhOv
         wnQvFrUnasvGEjcZv5QbKz23EvdFctZuk2lHQH4EeEAFL4Kx+vSjlXZtQRydk7j1idAx
         /UUAwj84w5Pi95UWsOVe8tS152xj2ZfcEWPp7jNQzN52h4BmJiS1Ku9e/jk70X0Z2EPY
         SDSyNof0IogZBTJr94e5UKMwPIftjzOfnH+SY8xUjb5s8afDb//mLKaZWdWGUI38Snzl
         JsbQ==
X-Google-Smtp-Source: APXvYqz7KleMfXSb2xWhqBUaqWJTSwZR2ghM1vwfjJsnESBwGEPHMng/yx10KRFE5q5G6LCNFaFlFnciq2Xk09j0
X-Received: by 2002:aca:4e83:: with SMTP id c125mr2833389oib.13.1556630751340;
 Tue, 30 Apr 2019 06:25:51 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:07 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <2e827b5c484be14044933049fec180cd6acb054b.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 11/17] drm/amdgpu, arm64: untag user pointers
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

amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
lookups, which can only by done with untagged pointers. This patch
untag user pointers when they are being set in
amdgpu_ttm_tt_set_userptr().

In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
an MMU notifier is set up with a (tagged) userspace pointer. The untagged
address should be used so that MMU notifiers for the untagged address get
correctly matched up with the right BO. This patch untag user pointers in
amdgpu_gem_userptr_ioctl() for the GEM case and in
amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu() for the KFD case.

Suggested-by: Kuehling, Felix <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

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
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 73e71e61dc99..1d30e97ac2c4 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -1248,7 +1248,7 @@ int amdgpu_ttm_tt_set_userptr(struct ttm_tt *ttm, uint64_t addr,
 	if (gtt == NULL)
 		return -EINVAL;
 
-	gtt->userptr = addr;
+	gtt->userptr = untagged_addr(addr);
 	gtt->userflags = flags;
 
 	if (gtt->usertask)
-- 
2.21.0.593.g511ec345e18-goog

