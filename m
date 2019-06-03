Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91A8EC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49CEF274E4
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ic80Nhco"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49CEF274E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE73F6B0270; Mon,  3 Jun 2019 12:55:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D721C6B0271; Mon,  3 Jun 2019 12:55:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEA886B0272; Mon,  3 Jun 2019 12:55:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 953FC6B0270
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:54 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 97so8085979qtb.16
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=V8W9/R1INxLH8IpjzMBaweiOjVPk4ghaGGjHQk6nF0Q=;
        b=VasU/gcF5+i0wWIOAgSv/rVqIP6Qv93vY6OSYelSHMOHi+YJf07SG7Ajt63j6tyiPa
         yKYRa7vOtU05eXX0jvBo/0ySndBxSHfBcssRBbIPt3Sthlx6h/NRLaU2E791OVu8IryK
         gHwyT/nBlrQAGAcKCTYdQeaWyZDYYx7eA5o8wMblT/3XpNqEsX5PmleqJ0nuALmlDRCS
         oBxSCUhIZwAVYJIn47EtNmprLQQegOZEfLQVX0mWs7Ycko46OXxVp2fDGFK5nvGoj0u1
         /FRbh48JUaHfJ5GmQM/LzEGTwDEsvBNjnzhQugRbs9DCAbnOs4ImC9ir85lo3OamvwV3
         YU+g==
X-Gm-Message-State: APjAAAWWgNc/ORC2GAYA2wmjZXH4oaPNgbh3f+kmqGg7QgK9MsXT5u8J
	go+WgjTztXLtTE5nMAKENrqNBy7+8LPAGS+H+vvDBkXQ/D5Yw/pO0RRAb3otZqpRABNKsW1Woek
	S6CbX4G4E6jZlk0x95VwG8D9tdFXZgYI1uLIp9AYEua7aLaOsfnXdQAlrlneoVA1fbQ==
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr23083733qkj.49.1559580954304;
        Mon, 03 Jun 2019 09:55:54 -0700 (PDT)
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr23083712qkj.49.1559580953741;
        Mon, 03 Jun 2019 09:55:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580953; cv=none;
        d=google.com; s=arc-20160816;
        b=ltSpArDGJ/xv3eQhXKYWCmizoAvOAhi5USXdkugs1n9zdJ0tjIgBCYXR3yVcdxkgs8
         gQrnP+3lL6MQJnCEWh68d8VGXpf6Hb0v1eX/PLGbDZGOBXoEtuid/MgKRKlfXkfBogFa
         mEUiaBfB8FyHe522DedR9N2LLCbzqQcUSimiyYSDx/hywSDEz4R7WGg7bFpSWt4gNHD0
         ff0MBOME0kwxlqUK3y2JkUSijrEtgHOrCQESGgSb5TDTYhW7QeV3KSbgX21cubsWXpmw
         vh5OqhGHpXtqJ1CY9VK/v+O2XKFfL3l4/ukczeENQ03NGlgnpQs+uOctu1PzAae8ZAFg
         gnQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=V8W9/R1INxLH8IpjzMBaweiOjVPk4ghaGGjHQk6nF0Q=;
        b=qehjLtt7SYjpLaUApewpKJUmFxGCNMxLIR7aXrmWjnnl+bYaSaLNl3RORTZ+DkRwID
         w07MY37v/ir5AkLzJEDCbAgKlLmHSaAd2+RwK6e3n9RA4MxgElrRm0MA4pFQSVPx5VGv
         1IerXwDq9FF6XqAwm1fMF5NJX5rxsvcHGDIoDphgMy8tiw+t0iEqZ8ceijIcFMZVSgfz
         Ek2psC1NtehL5B/a/fW2wD3+pyD/9hohGQLJSlvRUiavxbdb63YV6vzNPJEpcCSpCJQ4
         994e+1DM/7Dm2kQMzlgWexSy7FY/kibV1ByjkTqJqCbsmZSJ9vDSpTP6Hmy6724OfHqf
         e/0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ic80Nhco;
       spf=pass (google.com: domain of 3gvh1xaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3GVH1XAoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d68sor1298848qkb.62.2019.06.03.09.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3gvh1xaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ic80Nhco;
       spf=pass (google.com: domain of 3gvh1xaokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3GVH1XAoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=V8W9/R1INxLH8IpjzMBaweiOjVPk4ghaGGjHQk6nF0Q=;
        b=Ic80Nhco3iRVjaadOA8+znksGsevCWKjr0xS5FrfRT68EY2GjH7FNqxQ/S059IWRME
         Uk1bw3K6alaW8N/9Rs9bh2+EZh8EcVJH3cxi1ame2GYHVGzkN7Qz1H1smlWX23XCNo3x
         XPf9GSBwjp2Wlg5+Uj+WrIp+Jk7K9IWrhUgFda1FHXXV316C7cTRBKd5zQOn+A1+5Aft
         F1iszJDrA1FKS5eHvaL17A52p/3BNscmam9+VyXB7pU/EsAF/YnBaqcEkTUbGMZM4HOi
         O4Y2Ewn60j/2WNgR2OxufWSoY1qQbeSPNPwvgeO0aN1frIK5bxzhsw5VzJiPVQL++TeN
         2Fgw==
X-Google-Smtp-Source: APXvYqxbJDGUw94i6RNaa88fy33raOhr5MIqE66YRUj/nWlTewQjYqVQIrvYFblxs7ri2FDDMOtmRTjTXzyL1IBV
X-Received: by 2002:a37:6782:: with SMTP id b124mr6422877qkc.242.1559580953075;
 Mon, 03 Jun 2019 09:55:53 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:11 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <7d6fef00d7daf647b5069101da8cf5a202da75b0.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 09/16] fs, arm64: untag user pointers in fs/userfaultfd.c
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

userfaultfd code use provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in validate_range().

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3b30301c90ec..24d68c3b5ee2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1263,21 +1263,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 }
 
 static __always_inline int validate_range(struct mm_struct *mm,
-					  __u64 start, __u64 len)
+					  __u64 *start, __u64 len)
 {
 	__u64 task_size = mm->task_size;
 
-	if (start & ~PAGE_MASK)
+	*start = untagged_addr(*start);
+
+	if (*start & ~PAGE_MASK)
 		return -EINVAL;
 	if (len & ~PAGE_MASK)
 		return -EINVAL;
 	if (!len)
 		return -EINVAL;
-	if (start < mmap_min_addr)
+	if (*start < mmap_min_addr)
 		return -EINVAL;
-	if (start >= task_size)
+	if (*start >= task_size)
 		return -EINVAL;
-	if (len > task_size - start)
+	if (len > task_size - *start)
 		return -EINVAL;
 	return 0;
 }
@@ -1327,7 +1329,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
-	ret = validate_range(mm, uffdio_register.range.start,
+	ret = validate_range(mm, &uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
 		goto out;
@@ -1516,7 +1518,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
-	ret = validate_range(mm, uffdio_unregister.start,
+	ret = validate_range(mm, &uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
 		goto out;
@@ -1667,7 +1669,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
+	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
 	if (ret)
 		goto out;
 
@@ -1707,7 +1709,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_copy)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
+	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
 	if (ret)
 		goto out;
 	/*
@@ -1763,7 +1765,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_zeropage)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
+	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
 			     uffdio_zeropage.range.len);
 	if (ret)
 		goto out;
-- 
2.22.0.rc1.311.g5d7573a151-goog

