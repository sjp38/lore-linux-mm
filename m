Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37B11C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF40D2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ihFwqktA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF40D2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 934816B0266; Wed, 12 Jun 2019 07:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E2906B0269; Wed, 12 Jun 2019 07:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D2766B026A; Wed, 12 Jun 2019 07:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58EAC6B0266
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b75so17010219ywh.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=49lyybNUomf5TPPaYx2MdHbLNYXxhntLqw2Vq4fwp4Q=;
        b=Yt+PzfYo8qSZud0DwxwmvkR5vwfm2ZRrfl7r/j5VGEdTBLt70NohEN4FRrY9U/hQIe
         Wlom9oISWHJ98qsznl0bZSR1X/eDvaYx5CeU8PuxsDls+TNvknsFu3v/wQk+CsXc64+M
         lPfJ4/nQSxtRTfoxwKlJzZZv6ud0LV7812uTJwnPY+2B6bYC0V7yu7M9nKDi2UsRQmhK
         FTQwvBDJBD9pseGeF7mAgRjgwsItGR96vNoUggHNLFB8nmiZYBBcGOCbewuDpFzbMoIw
         qd8KATzDaRNLJC6akQAZFHEWRnASTEkmZPH03gCMxRsYmhEgv9URiOwYvbMvXf+noJSs
         30Fg==
X-Gm-Message-State: APjAAAVzp74JMAKKMuBuhrWLPwm/Bv1hwMHiHqNX23SObS94sh/4Yk78
	0fXdMhY413vW/M6Yn2lxZ+jqYUoX08So/054Su6Zid6zQinNhzcfvZWNMno0Pb8sGh6V8rkp4TR
	AOYWpzQ3q3mqS7mV0ZWkkfcHjhaCIv8Y7XLbdTc7rGkz7Ts70DEsGAn2crGkDTQS6Ug==
X-Received: by 2002:a81:aa50:: with SMTP id z16mr22626597ywk.278.1560339846010;
        Wed, 12 Jun 2019 04:44:06 -0700 (PDT)
X-Received: by 2002:a81:aa50:: with SMTP id z16mr22626580ywk.278.1560339845448;
        Wed, 12 Jun 2019 04:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339845; cv=none;
        d=google.com; s=arc-20160816;
        b=dLrDv1GJTRB4JpNNFWMEBVn+WRgeXDj/qbfBtlcT60jAY2v7VkSTgqj4ZwXPrq8pHT
         1QDJNHp9PeYV5O/JziGgH7dm4sXfLAiZDbjXGr5m8efUXSPeWcX6IrLJNUG4WH0lOT0s
         ySOZQznZZ9Z2g16BBl+YccdBIYiLZVXEjGfO7XQR7sB3d+SIFPJS9MLopq4FYEe9/fod
         Qz2WnG6JtUZaiR9oUVyb95YdELANEMN/9dGmW9iObygLDnaViVl1uxgN3AHpzuulqVTF
         p+4dlmmsgd4SixtFP+Q+9gAgEPk9fqUAGdvGwFTLADK1dTTdzSUnUUebSgs0/xRxTMeH
         yiDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=49lyybNUomf5TPPaYx2MdHbLNYXxhntLqw2Vq4fwp4Q=;
        b=LF4fHXRp/vxQ0CT5r6Yc072OLuYtYqd4swmteEXcaUpuWvAD6cFUO2sJkIgIArgQSi
         6Ru4IFvLxNMg0Hpm5QATjHIhBQlKt9vI4uFiunCy/h9tXf6UKhGXzHBFQ1PtskYvvCMV
         bpqCttOvFNBkAom/XwRb4JQZHoDrHE0R/XSLFSSKxWfY4d7FZ8d1ECPKYeau5WUfBdRf
         1aOLhcnLoyTvASwoeZX8xE3tBPU2n7ILw0wArmkIb7waVfHpp1xNEid/rkGdgzzMyYna
         5Z0NatKVWkyX5Zu4GnRNuEL2mRbMLEpOFVotZtPHY9yDzJMJcdPrqP5hPVWAuO+SB2xd
         zw1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ihFwqktA;
       spf=pass (google.com: domain of 3heuaxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3heUAXQoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r124sor8203830ywg.55.2019.06.12.04.44.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3heuaxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ihFwqktA;
       spf=pass (google.com: domain of 3heuaxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3heUAXQoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=49lyybNUomf5TPPaYx2MdHbLNYXxhntLqw2Vq4fwp4Q=;
        b=ihFwqktAIqrJiTQwTjUhK+MAdfOsiouWKHqO7ZjSSZRmzOCHa96d8VJOaNVIZNxAcO
         AN6aXPp/RE1MrQ6zM8JJXD7nVRwFFfp5nOw9hthmPYYo49089cBtVFaOKAL5CUs7PfyJ
         QVJHzuksJxoSuikR4fgviWI+uxOP0qQaG3AiODD2sa8fpyWPMeWsTelFk8q9IMn10OKD
         +UNh5Ci6TXkOO1z7q/a2BisVOKAv5AoSV7//DSqtdeKoVvYLLBYkbZ3uB0cH3pp+Kewb
         rQGpoPMvtpdogBshUOOc5uWdI95iNZkAb+XnamPk3rh+8KJ/cKljnQO2b6iriftiFlMR
         wRJQ==
X-Google-Smtp-Source: APXvYqxF+/T3yPkem3l6CI+bv3/rmqxcJMbV/vABJbuoyeQcWj2Unps+PKPx2+cODkSgswAOZakXvU9OwOpzOWtl
X-Received: by 2002:a81:2717:: with SMTP id n23mr31165867ywn.423.1560339845094;
 Wed, 12 Jun 2019 04:44:05 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:26 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <d9cbdcc3c4926bf70fe0014110901a0755e8e869.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 09/15] drm/amdgpu, arm64: untag user pointers
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
2.22.0.rc2.383.gf4fbbf30c2-goog

