Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7CFBC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 632F6215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NtLJcSSF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 632F6215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 143976B0269; Wed, 12 Jun 2019 07:44:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11C796B026A; Wed, 12 Jun 2019 07:44:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009226B026B; Wed, 12 Jun 2019 07:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD6146B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:09 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a17so7599335otd.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=9qcG2BgTwk3XlX0RcWVeDPHI8lhK5DjmwRDy1FE/sPA=;
        b=Rqftxi4i96rlDJEDje1cx6btg7fg9/A2wxYcLSa7QH3WzDELLUGd1vlJGhLer+fz+L
         8q3dz49PaoYS48Kv3/UdEMY9IjeR4dl6GXKEKxMlMHXtWH4ng0OkN/PzOm3v+zk6AaX8
         5Ekgw8Qv6lT6PJew9Et0/En431VuSkhQ7gC/msI/BIrzkD4BrsrkOko0mawRrQC+cNjx
         MEU46fLCHXsoBr0EDac+qS5lMCb6swe1Ht4uFlXf66yaS/ww/TBFbluR5uSsRYTWp+mi
         qhD1un4RPPHPFzKqL8j7GkunwvKDSnFj8QZwyD1fewCXhFRbdudsWeBvEhWE8Cour0gm
         5Elg==
X-Gm-Message-State: APjAAAXa8PcZ22pOZsVoUs1Yz7mkFdntAIAlPdv6xvfA7LG9vF49fxO6
	Yndd1KSpYZ2tauc7K39nOU/bbqm7SPPy9U1v+b0C1sOUHxxDJCZzydc1KqUNNAQKBi7IEHsHQRE
	iKznU9ggGqfzKYRbFqIhX2OwbHdfGYCacuJiPmUDu4pCD4Iry7vOodQjWGRY+6Zl4IA==
X-Received: by 2002:a9d:d22:: with SMTP id 31mr21918802oti.304.1560339849468;
        Wed, 12 Jun 2019 04:44:09 -0700 (PDT)
X-Received: by 2002:a9d:d22:: with SMTP id 31mr21918764oti.304.1560339848661;
        Wed, 12 Jun 2019 04:44:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339848; cv=none;
        d=google.com; s=arc-20160816;
        b=TvVmdRh9+CjxMrDc0QrXFmuI+QhERILBeKNm1ZI9QrOKY9Hq1OyOBjVRecJnQUhhlz
         g9MmjX5ePAjEWX6cSE0lvBmbfQ8T4lxk4qG9QM/Ku5QveumQz7xpGYahrB0YiP2ZA63L
         J1wpppIGL7h1QGOjCNFoob21T1VknTUh2IASfkFDvOfyR3jwfKPUufbrTJY9dn8jiXam
         Zv+FwOTCN5rzJDCeWUZqgln9BJ+xYpmwCExd9jZmBJlkhJMqqbsd4DvzN1ugZv9ONAog
         Vzv0LiDQnX8tiG+FgwdzglsozFXuJImrf3E7Mhljyd2jMcTGFW1yF3qMzO/+TQHxMjRJ
         Un3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=9qcG2BgTwk3XlX0RcWVeDPHI8lhK5DjmwRDy1FE/sPA=;
        b=pxQYq6AAbPuMMNYJLMo12gwwuLfQWc59LZRKuliUHLpMh00ImLTbEXTVHrzhEQ0uJr
         egq6azWL1WVKQlvkCVYvSffhRe/iN7fz7cBugFpGtDPwmOBug1LhKMz+Y22VtE/lfc1F
         3UR5iDfoDA6Jys7fb/4its19wvXMKsZ18MqohsVo7sV8Nup+hJ/hc34EwPLZof3rE+fR
         mWnpJfJBswT7UjzSVa3JGqaBe7nC5Aw/Qz/wrOycU6vb/vG/oKQiTCuaj9wXW5Gex7qx
         bG/Rcn9axxBV0h7Ae49gx5oVzBfoyYvF6vZuSY+sS+bp78xZHPEvCaatNoQCEztZ708k
         eAOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NtLJcSSF;
       spf=pass (google.com: domain of 3iouaxqokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iOUAXQoKCEUhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f25sor7462940oti.138.2019.06.12.04.44.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3iouaxqokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NtLJcSSF;
       spf=pass (google.com: domain of 3iouaxqokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iOUAXQoKCEUhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=9qcG2BgTwk3XlX0RcWVeDPHI8lhK5DjmwRDy1FE/sPA=;
        b=NtLJcSSFMHHu317AevzAQ/30ZKEUOStp0YqobtwksbYseFWqgtaBTFdiHMGyyyf7At
         YDJhLaCkyHoSzl2vKPQ0kqczt1dgoIP6M4Ipn73b/OGJITm9/nwiI3El0EdSAptKyxy3
         b89x7f/UmAMLYhahbGWtvHAEQvqe/KEbHnD9FTBIwA/5CD9mYyTGMXM5MGTE55QAL6sy
         I3ZLX4P7OcoVJPIKw9PZDhGTJmKOWHMHOrsjABMEwlErwDLgIe9+iGkSdgcah0pP/nqE
         b30uAgSnuW/RhTjVNWI3Kw8grpBZAvIwRQ2tzxM9A7fFKVadA2sdBJN3nJtOltKf1dPe
         uUMA==
X-Google-Smtp-Source: APXvYqwmn5LtjaTY+f4hsmtZfAoqdCdKYyyJ3TA1JpFnaOV6Nu/BG+R38vnyWSwcum180MP3Ic/YmQmm8bwHU1r3
X-Received: by 2002:a05:6830:119:: with SMTP id i25mr175410otp.288.1560339848209;
 Wed, 12 Jun 2019 04:44:08 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:27 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <9ba6199f01b8e941404b18bf8f7079ff384fb60b.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 10/15] drm/radeon, arm64: untag user pointers in radeon_gem_userptr_ioctl
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
2.22.0.rc2.383.gf4fbbf30c2-goog

