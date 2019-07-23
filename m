Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B6F0C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC088227CC
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t2L6A3co"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC088227CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590E08E0015; Tue, 23 Jul 2019 13:59:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5421A8E0002; Tue, 23 Jul 2019 13:59:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 457EC8E0015; Tue, 23 Jul 2019 13:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24E3A8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:53 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so39165614qtn.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=bykoKqk+RfxIttYDE7/GdnEkPwV+NEF/LkGgW6aheBM=;
        b=giMVhOktPHlmh0ouBUgnffuPgL9CGKw1yOKAbGH8XbKdWX9xZhseTR4RZMJHBQR95g
         ADR5sGgt4HbLNVoSXEsJYtKlBdzOeAqF1qtv9uPt0lUKuoPxLPvKSDitWpx0Y/m1ov27
         Y0rWkoGDVjGe32LxYZbonkMKi6lrjz6DSOsuNurCFIZ1uCYU6Vk3PWHaIiDcJVP3FISy
         spCyVTmErLBZou78VYOeUmYnpNC8sTHMUNrIFwWIYF1rZHv8TBBlKqN8cN2VtK1i+Tly
         vVB/Zc+F47Sq8rhe21x8ZX/MyQutlNXoGsf8uCX7iW+zPWpigVCqU4fwXu1QdVw0D56f
         7gzQ==
X-Gm-Message-State: APjAAAXig8UhZZv4ZrvkDMYdg4EPtjN4QgIzucGizmuPk/YXJy94XqSq
	GwlfdnqG0ttrk8caFZMe13/MAVmdc/GRILp9s2YtKei2amotr0c/hFyCyWJfD/PSFmASgto1DfU
	izhG+/g1K7Va/3bJA3hbXbZ04clFeNwwuX6Cde+9nweRb9ykL7J5OqpARi+gntTNaPw==
X-Received: by 2002:a0c:ae5a:: with SMTP id z26mr54966638qvc.65.1563904792907;
        Tue, 23 Jul 2019 10:59:52 -0700 (PDT)
X-Received: by 2002:a0c:ae5a:: with SMTP id z26mr54966624qvc.65.1563904792278;
        Tue, 23 Jul 2019 10:59:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904792; cv=none;
        d=google.com; s=arc-20160816;
        b=TydopOLJh5jtCvs1rj7X8oNipfOx/OZSQCy87wnwpTY2Q2FHFFsJQLPQL3WK5MeJHM
         2BiGdtvUt/MqQJTp6ybIX6hAtLcYvlnYO85Kr7EkhXUt8oKqyq2warmC5Bxwoc5dUIvI
         KdZBgZAp7yaZfL90z2npMEWFT/hdT+hLl6zvJd1wiyp7S/84rJKA5YMV7uqmSSYeCTMu
         xSqquttcF9yg9g1eEavYqrpAQOQwR3Stv6863o4htWKlwGw1XEPDBFxXwL9H4X0DtMPR
         xCnj/vSC2Fq9Umggf+oVgXJPvm5cjQMn958OPprFgqbKQXVl8y6NCLATzyjZGTy7TPF5
         BjAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=bykoKqk+RfxIttYDE7/GdnEkPwV+NEF/LkGgW6aheBM=;
        b=QXzp7BME/ngc0z5qpPuPuT0k2h90ltXCY+jYxKyzXN+ZRpGok2MS9K7CRAKjWgX/CO
         DXaWK0Ahi2k8I9bWS8cwuQeNcjPAJxVAzeBgAQyk6nobHtQmhY6Fn5OgiiwnM8MVYwXC
         9dBlkbf4p88jVNSIUejWFYG/z0oKCKLntI1+Ulk6tP1mwxJ37S08ehIxm7eSehIlwXWo
         rIlQ2BwHWTnmjnQOcqlNnKeyAgz3FPodcvFs/dFCOglUtNqFMSClJabcDl7PXuFlYWFW
         iYppVWXyBcP68twV2r61UqFXHwLMrGrzT38biYRROKB8OhlRoqdNUc1voo9liSdwwgYR
         ugqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t2L6A3co;
       spf=pass (google.com: domain of 3f0s3xqokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3F0s3XQoKCHoYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i6sor58164535qtm.38.2019.07.23.10.59.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3f0s3xqokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t2L6A3co;
       spf=pass (google.com: domain of 3f0s3xqokchoylbpcwiltjemmejc.amkjglsv-kkityai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3F0s3XQoKCHoYlbpcwiltjemmejc.amkjglsv-kkitYai.mpe@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=bykoKqk+RfxIttYDE7/GdnEkPwV+NEF/LkGgW6aheBM=;
        b=t2L6A3co0IUcO5jJEupAYqmfSwA1Pmfl3+ZcIn/5Q85mp2WLmhw1iqLCswQ9as3aOF
         a0D+pYMEhkdmm+KSqXmSiU/lD0Pz3h6uvkPAeVEHs1IFoAwnv5BA1YbF3d7nwG6M8iRR
         Z5NEOhmfG5y3nopQ695DATYQQfXAIYJG7yd7F+lB9VoEza1F669VXhs6jrCa2pvOvN6l
         r1p+w7pUdDXihW/3CqVYzRnheU9A6fqtUiCr4NASapwor3nhJC+/jeMNYPGIPNIFjoFu
         E4g9GrA8tUOQtGrCF4JaEQ7hr5aZJYBDV43aYbaG/BPoNEA3mTX8DLrogiBkcDNJOYJ5
         rrBA==
X-Google-Smtp-Source: APXvYqzy6KvMjkfI7Gkvl5k12zd++ICAyNUe8J8soJHrycJkzCW148ZA79khH20QvBebUrjeGJ/TSw9Gqxxo1fEA
X-Received: by 2002:ac8:7251:: with SMTP id l17mr54199388qtp.277.1563904791730;
 Tue, 23 Jul 2019 10:59:51 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:51 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <87422b4d72116a975896f2b19b00f38acbd28f33.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 14/15] vfio/type1: untag user pointers in vaddr_get_pfn
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
	Andrey Konovalov <andreyknvl@google.com>, Eric Auger <eric.auger@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

vaddr_get_pfn() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Eric Auger <eric.auger@redhat.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/vfio/vfio_iommu_type1.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 054391f30fa8..67a24b4d0fa4 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -368,6 +368,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 
+	vaddr = untagged_addr(vaddr);
+
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
 	if (vma && vma->vm_flags & VM_PFNMAP) {
-- 
2.22.0.709.g102302147b-goog

