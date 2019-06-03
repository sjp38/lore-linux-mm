Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C446C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1779327515
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Iulw2LDX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1779327515
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4F2E6B0271; Mon,  3 Jun 2019 12:55:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8D0C6B0272; Mon,  3 Jun 2019 12:55:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 842ED6B0273; Mon,  3 Jun 2019 12:55:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1E86B0271
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q13so4406349qtj.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=QTQ4ZZ+1ONHvx3iNcSe/c62gqBzIbuX20WtdiRnopfw=;
        b=i1EtFGXOBObOD0zp7mAq9c3cfQqtlWfV0Phs+Zj5ommmvi+vibpelVFbD6Pc+aqozE
         CT69oZA5/jClUyCeH/IyhDeuGZ8o/IKEVQHr6srZBbOC7/Jikh1ua4VO6TabDK/3A7OK
         M9mXfEP7a/dm9Hnxn/nSKV23teLhngEutIsFS5x8gxssU6R/PLvScfXHbEMPgPiCJxcN
         NUa/b/BO6BqEc3nlRPUfk1FehhcyAlIyNHwoqOvqGhz3b8Xm6Qk67/JYgg4jgo0e09wV
         gTf57Pkyzf0mpx7XAwIRDDph6Q9Su250qz/euXTEpv7Sh5NQpyn6oROujWR8MBrMgH/s
         o2iQ==
X-Gm-Message-State: APjAAAU7D1YqB0RxMwKG9B6yT6me73F20TMz7AQW9dMnvtaYFQ1Qj1Kv
	MH55KFjYMNudseOhCCrtYCXWADXysoIQ2jvlUFG6uefQsidjcb2u/vOcqtwzaSLcMLI58jyEbpO
	mR6pT1TnQVAoIwskxNjOSNKksze44Wq6T/ieFBlw599RyolDsLSqBomSlwnYsjDcKmQ==
X-Received: by 2002:a37:de06:: with SMTP id h6mr3880633qkj.322.1559580957085;
        Mon, 03 Jun 2019 09:55:57 -0700 (PDT)
X-Received: by 2002:a37:de06:: with SMTP id h6mr3880593qkj.322.1559580956572;
        Mon, 03 Jun 2019 09:55:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580956; cv=none;
        d=google.com; s=arc-20160816;
        b=m7SInABm/1KHhE0NLbrIJBvLtPpY1cx/PqyI9zxHlAIqKKoDFxOHTIDx2LQ+fxaM9Q
         5iufnzWSDrFR2nePkIYPQKZEdD1yzTEBm79zmd1DDqGT5q556RABORe/cE4wnX94wq3q
         O+eZt+7xyYEz9hGW2Z1T3n+YzLY0arbEf8cuAwQ6NRK88QuwPB0nKFj6I1DZ15MvZDFB
         TFHJxtt00bs+umTQgF9oGVRGp033ju9oIZdxmUcIHCalKSWYUGqbMARkISx3RFuWFWeA
         5ZSarbWmimft00raox6qANW9hNRZp9xg4uQGHffkm7ID2eozsAa7n35Qdul6wuDPYyCZ
         o2cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=QTQ4ZZ+1ONHvx3iNcSe/c62gqBzIbuX20WtdiRnopfw=;
        b=kmM2rahryE4zeLtsos3cp5DStK5wRQonI91rlBoC4KPJLYL9h4XNUY0xt/ekVckjEc
         j/FFCzduPyYN7rDRYU1QSMf3hfGJkgW6BgJm9HloLJdaeq6HK+1bDJyYWA8CAS1nXv8s
         9XaVulbWqokOwn+QPWL/cwk7XGC1WI4/O31gG16MhTh/8WcaV0SuID2eUrjeU2vCEMxx
         f39nmFAM3SPiBtNwQuy4I3qDm8QXZLVvUSHURCTo2zuXcGNGCaznNn3liCiv1RUMy+u8
         eyRaZ/1uemxcO+1XFylC1fSMss580DIZYd32HgFsUkQFtZPcYYgJAr1b8kKVrWX14Jrc
         qGOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Iulw2LDX;
       spf=pass (google.com: domain of 3hfh1xaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HFH1XAoKCIEfsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w8sor1276048qkf.56.2019.06.03.09.55.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hfh1xaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Iulw2LDX;
       spf=pass (google.com: domain of 3hfh1xaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HFH1XAoKCIEfsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=QTQ4ZZ+1ONHvx3iNcSe/c62gqBzIbuX20WtdiRnopfw=;
        b=Iulw2LDXuMXrguiNT2nc8pImmlAd9SEaHxzy+PIXZoC7Ry1861+IgSJT7msXK0lxjW
         Stlg9JACJI0q7DDqW7dFD1lXLlRa2BWigOxwo5Vw8cFe6qNirKkII0FhPNgtUk9+cp1T
         aHJGoLoDr4Q8979Fk7TFLPwhp9/TzWuYwglUurKj3rFU9GpRJ5xL6D7/jxXgMSu4llum
         hXs/FNVkTTazIDAfHhBMirRaAiVUM4CzdwvnR1yvQzgHmFdNai1A63k4wvi7etXyFGuo
         QDD/dhSJypo/bxB/7BkdNMWk1BD1fsQcPpD2mwu3O8zxH9SkplM6OKzkYqDvbWZfOgAq
         9GzA==
X-Google-Smtp-Source: APXvYqynCi8uC9mwY5hf72ttWfEiYBsQ+6wl0nvKi3Uj+AQb+Ufw5GSOsuV9qYkE0ai47XUYEZWA+IZ0Az+FoQAg
X-Received: by 2002:a37:8002:: with SMTP id b2mr23304828qkd.289.1559580956267;
 Mon, 03 Jun 2019 09:55:56 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:12 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <47d4e95b61013933ffe4f0be8832d03179d94b27.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 10/16] drm/amdgpu, arm64: untag user pointers
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
2.22.0.rc1.311.g5d7573a151-goog

