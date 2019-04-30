Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB41AC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9345321707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WJvgA7Fh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9345321707
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A19BC6B0271; Tue, 30 Apr 2019 09:26:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2946B0272; Tue, 30 Apr 2019 09:26:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86A9D6B0273; Tue, 30 Apr 2019 09:26:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD996B0271
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:26:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o8so9046138pgq.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:26:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Qo5FEqXeJKdpmXvqV1aNmsvS1qf4QOcuAEvGRZnbU+I=;
        b=c6Q9MGBFteytn5ouLvjU/wvk+PWrXLdECNqDI+hAy5saBjsaZBN7jQANv8lkFcx1w9
         5sor/tJIeJjbn8OJo9kfCqWzWTFSiw6thI/m6I7hPlJkaXQIUBfNCabvItccHyOeA+vc
         js2G7BRNjjKGYldV4GJC/fiaHTGoHMqLyKxIt9w4rjWtb0hUHQI257aaRetm0B/4NANa
         Z0E5H8s1v6khtpZls2nJJi+DxscbnYosIkocmGd4m/CDPpcN24GH7y7xhEf1YvYUiM0e
         R/NeORAc5PEEgv3BHB83726D58jiYH2xmX8e3uzp/I0mQX0s/MZX3LXjefhSa4um/NXz
         7RvA==
X-Gm-Message-State: APjAAAV+ymCzleyBb5TPBUgKM+CbdpNib6dlH69RPH4IS1UJZZswUkDt
	aEkcjetq+hFAmI/Hx7Z9zviWdimAdnpw8/bHmwqwPEGWESxex7bKawQzU3SN8h+GQR5h2fgeP9E
	+xyDD53kZEdi1p0uQvjSMwSGLpEeqHaidTp48XEVzHULPtQulhq6S/0A4NLgIrd/V4A==
X-Received: by 2002:a65:63c3:: with SMTP id n3mr51596977pgv.170.1556630768886;
        Tue, 30 Apr 2019 06:26:08 -0700 (PDT)
X-Received: by 2002:a65:63c3:: with SMTP id n3mr51596886pgv.170.1556630768045;
        Tue, 30 Apr 2019 06:26:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630768; cv=none;
        d=google.com; s=arc-20160816;
        b=omylDuP/vDQyaFIuOMlXy0jvPejYhkph88IJJjzvjYFsyzlN7++m9oIsZ6RNxT1z4g
         e7SKRjl6+kea7okOkWjUSzwjMV7NcDjzx8MeLCmFRBEXr8cHQEG2yJQRBaMX76GDmD/T
         i23zrtB6kcJTRyVobj1rt1KL1GZ5gUUnWlwc+FVU5BwIDv2QHtv4vz4Xc4T5Otxt9bMy
         ox+7cDxofKF4Tp3MxODhJDJOK32wxxEVcDkbO2bv/C/Rb466/F27PxsK1XJP72INg4Wq
         M0fbkTLSzm/r1EPQBcMvQCHMlA8apfg/x55D/JIs/ld+QFqOX2QEKWc65kid6CERkI+s
         AwhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Qo5FEqXeJKdpmXvqV1aNmsvS1qf4QOcuAEvGRZnbU+I=;
        b=Wes0LKP5n1EKzqtlxN09Ecc8OLzcKDDxHHuXZIEKbjGXcL6Zt4//SzKNcsJhUhxIG1
         zFI/S1/59PWdiUW1q+7JJrxPb6mkwz6+tD65n/2N5nLvfhEpBapWJnTP0z1kxz/NhzFc
         swtuY3lSuDROCMsS51g0C8HAHtN6bQZ3bgeV09cRANFXmcGaTNon701IX4lz2BNqrnOO
         V1MFapFIOHIV+VKkccCwlUZvrFNFjIMfb7OWGxN/Ry6T27VLNp1LBEx1s2gHdPoOKr75
         7WkGVjTd25Hy1qduCmLT+pAwtqo4LG2sxdXywne768kNaHqUPI2NuZy0t9axH9aAY9sV
         vR9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WJvgA7Fh;
       spf=pass (google.com: domain of 370zixaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=370zIXAoKCJY0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j23sor11747451pgh.83.2019.04.30.06.26.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:26:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 370zixaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WJvgA7Fh;
       spf=pass (google.com: domain of 370zixaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=370zIXAoKCJY0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Qo5FEqXeJKdpmXvqV1aNmsvS1qf4QOcuAEvGRZnbU+I=;
        b=WJvgA7FhPH4nnlwUD7/cK+UGsQvztnpEwl/EwgwpETKSn2jcm2n8vXAJ5vmz+updJQ
         hv5vQG7S1TSnGIvsNFWmNlDJOuMgBbHPDTDqE1/Q7BSkSWZGsQSxWFmbI9EyZ11RD35O
         PoWicUER0x2L/roTgi03inDjhawM/RefWqQ0HU9dp3Bfb6piRBIYbrmvMjy86XgTN3si
         Ctsvudz1bGthwFBvr6qlHQElPSiMTUZTlDJzHWjXIK5Av3TkDr+6XQPdcLfX/oczYas3
         y01MzwmNMMd59RGZLYJMIFoZY0gr9B1FAyRfwBPJvm7Zd8dDqsp5xcnwSnBCo7S+GHIh
         eAtA==
X-Google-Smtp-Source: APXvYqzC1lVWU3xOxPIpeGY1IySKfn9D9N99TINTSZcSwcwIPCbrd75tIMQec4oX3DSqqzuBnQc6miaAqMAhwGUH
X-Received: by 2002:a63:1d4f:: with SMTP id d15mr64183239pgm.347.1556630767405;
 Tue, 30 Apr 2019 06:26:07 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:12 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <c9ef2282b1860e3ca6da28a4d599c24ff7147bb7.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 16/17] vfio/type1, arm64: untag user pointers in vaddr_get_pfn
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
2.21.0.593.g511ec345e18-goog

