Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A144DC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 578E820B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CbTDaybx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 578E820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 265896B0280; Mon,  6 May 2019 12:31:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D496B0281; Mon,  6 May 2019 12:31:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12CFF6B0282; Mon,  6 May 2019 12:31:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E66A96B0280
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:57 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q188so7874084ywc.15
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=40kxRsKyA2BTdfRG/8ycbW9cjWXHDWQTNAmN4QMp2Tc=;
        b=IQXDIRB/fgPD1h4cBXN6Eto8sOPUK609MOtDRXCE8YuL8wOE/Vt2wshpOEB/9+PpHX
         hwA7XMlzjTQsfztU1HHUW+cZC2zzvUqgE2TpuCJnYAh+0UEA/cnfwi5fmmgvdl3S0nJ9
         rVTdvySCWPcgDSXFXgFgdh3Evmc4pxD2qY9GM1xpmG3JEply068pvQLrO9gr7hW7C5b1
         I86OAL1a6DJ2ms3N4vK4gtlm3S4Em/XKxq9uwAkaJJ4pakVJwaQCpLOclJc1DBbb2UK4
         uCUCuMVP5/ppdeKawuvt+oBgbLSkZh+egCmQ28kz0EgTuJHUOp+YF84CNopzCo+xUN5U
         COng==
X-Gm-Message-State: APjAAAVmo4G2oJw9/otkhmB4hmH6Djtt4BYwP6DqMnLUPXKDw4QPcdpT
	uxMF13MJccGZj1rsEc9EhFl8vx+sJs6Ur17Si9rmtxbxoukTc0UgEnlbZOLkSrUntmH5P075q1S
	AgG44sdeTomsAK7rKzqpGgxeLgK3BG4He//esQzs6TImn16ErR98R16Lb0Y7AP/dQAg==
X-Received: by 2002:a0d:e0c3:: with SMTP id j186mr18058551ywe.160.1557160317678;
        Mon, 06 May 2019 09:31:57 -0700 (PDT)
X-Received: by 2002:a0d:e0c3:: with SMTP id j186mr18058516ywe.160.1557160317120;
        Mon, 06 May 2019 09:31:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160317; cv=none;
        d=google.com; s=arc-20160816;
        b=s4aKG0iPU7UusFw32zXF95qy9kC2LNwvP20Vk0w0xU1lcaDU7JQ7KvR1iStDLrXNC3
         EC3u6RB8PDs4vh72B8nU8keD3UsWry85oWV8z9QlKaS5PXoE3tk1coBLm9oY7JVgOJLr
         16COgt8HEbEFITACbcKi/7Tk1q6vI4nP6BZjf0H1vhplT87dwEDFHAHviJHSk7A4w1EZ
         Z9pM982nrvEMJItYVGWh6YVSW9AhsGVFnHgWoZvcXiALVhq2y62+HwDgNMDEMrs7GR3i
         TnVNWaRkPq+MoLpJ2zohku7uzF4sgF6F98NeERWRM2IXVOO5lDHEhlALFtebWKJPqbvO
         rKiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=40kxRsKyA2BTdfRG/8ycbW9cjWXHDWQTNAmN4QMp2Tc=;
        b=E1HXAo3/8rG5ul2teCcQCwSFCEDSJKM8ZP/gTUF0uEUHudgq+vGx8o51jnvEhhyI21
         v2Q3qUF7kRLkxTv54DRV9x8lHfYIHiHfhjuH6AjOBs4RzhUe2M+PwIlKSgvJcOzLd/2V
         uZgbg3yk45FxEhcnOcMWxFBFOwwJXDKRnnOt4EorD9FpdhqXCO4Da2YjHOs2Dpl+K8Te
         ZzSxGVuGpdx2g8NQ0NiLq4j2SDWoX06GlbBiSPlDy+fY6vTKtX5h24ub/YWlaR0NXHSL
         U3jcFOW9YVEJir53EipYTNv6R0KZLF9Du3rm6FpB5D3lUNqcZGLnMWC6WfxPVIbZo0hv
         2KgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CbTDaybx;
       spf=pass (google.com: domain of 3fghqxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fGHQXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w7sor1844907ybe.185.2019.05.06.09.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fghqxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CbTDaybx;
       spf=pass (google.com: domain of 3fghqxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fGHQXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=40kxRsKyA2BTdfRG/8ycbW9cjWXHDWQTNAmN4QMp2Tc=;
        b=CbTDaybxwiO68FYaqEU987JbmTIWC/O/zmn5u4LAT2NjIg4zrx3ZZpTdEat2IZI7Zr
         UMjh3JrD6tSSJSHiA2J1SvwKqxkOFH9jD5t4pSSsFkT8XO0YzO5s2D93y2Fvv558QDT8
         PC2RKfy08bb/yMf67M9jkhQd5jNijh0tU+IEPR6RStdwOkRtKLjro1177XiqKVVA8CKn
         7nvBlr71nBnQ+GeGRfOaL9uXIjXsWpEFZPxFZ6iufv0v5siPwgW5vA64wYvStilJ/+ml
         T4dkOygYLm3ryZPhfxVQJsF9+4XGOGyyv3U3USZs8bMzVBnZRwvcMGmsqol00hqY8fWp
         TxbQ==
X-Google-Smtp-Source: APXvYqy7sMh67zqP2gW9MSWmQP0vNhHkuufaU8XQ9cxxJZb1a1Qrmr7t2Ui4wSymuQ40ovJdWXqcMvlrm4Ub8jqq
X-Received: by 2002:a25:c5c8:: with SMTP id v191mr18795942ybe.52.1557160316771;
 Mon, 06 May 2019 09:31:56 -0700 (PDT)
Date: Mon,  6 May 2019 18:31:02 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <69a675a5c48fa2572162338c51a1bfa2a3ced27d.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 16/17] vfio/type1, arm64: untag user pointers in vaddr_get_pfn
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

vaddr_get_pfn() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/vfio/vfio_iommu_type1.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index d0f731c9920a..5daa966d799e 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -382,6 +382,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 
+	vaddr = untagged_addr(vaddr);
+
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
 	if (vma && vma->vm_flags & VM_PFNMAP) {
-- 
2.21.0.1020.gf2820cf01a-goog

