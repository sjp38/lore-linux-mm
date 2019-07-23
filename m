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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C854DC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817032239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VYKldQtW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817032239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73E6B8E0012; Tue, 23 Jul 2019 13:59:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 717178E0002; Tue, 23 Jul 2019 13:59:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5415F8E0012; Tue, 23 Jul 2019 13:59:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3076B8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:43 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id l80so19578475vkl.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=zUOcAU6p00loQ1nrwWD7GDrs3KRhifPlQNEkBCXrSQU=;
        b=n6DNkaCdntybi2RBTFtM+r2cz4neg50/J5m38F3IK2wy8H67XiFSBHFC9UfAR/xmVZ
         CfmpO0e693Cttdk5pR9fNEkz51lEYb1/I6YqH1rSVxWvA4u8ypxAKmZ3XF1QS9udR0a+
         GRxvUACcNoA3Fta9QnQLKLWnsZ1Q9+9+LT/IYOxF6NDJn+ufS7dEu2GS7z7Gk/Yd7kDe
         Z0a8wBgSt4JpGC2MMWbiXZW5/m22FFnzhXcYR48H/gEEReFE9wWaVhOQrbsBQ8QG1Lpy
         ypdgPLEfBZVRWruI8rl4yGYsTzme36UljbgOar8cs/UEsd22wJRit7aXOu5PYLF0wL/m
         1zIw==
X-Gm-Message-State: APjAAAUyg3JN3Uo5XxaoZOSJr4OwMxFYYAMDnAp1Rq01sj6j1WTH4g8l
	KqqzUbmJ1ieFhWLNw6iJwWrLCTk593XwWyIHq1rmezOP06WVjecFTszmil4Fl/B7n2JwHaPBxZL
	1N3zJ9EsdZHMawxgGcjeQOmq5nm6jeP4gESZrOavuZXou5EC90Zc/kFCKQQicmep5Ow==
X-Received: by 2002:a67:ec42:: with SMTP id z2mr48631416vso.218.1563904782960;
        Tue, 23 Jul 2019 10:59:42 -0700 (PDT)
X-Received: by 2002:a67:ec42:: with SMTP id z2mr48631373vso.218.1563904782405;
        Tue, 23 Jul 2019 10:59:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904782; cv=none;
        d=google.com; s=arc-20160816;
        b=OrgudGr5AC+OHsDiRbnYT2QkgEFHOsCGMOi23OGoPdgL5YyYJUBYrX4kxFRVRCfzIU
         q1zvxcanGGkZG/95Z6zP4MQJcqeZmYntn8tbxNK0cBjXvCFHftcspigcBpOlGO/GLSM3
         jQD3vaZdNgyGDqUZ92rOtpHW9AWaqIbK3Bn/xQssTA24SH0q/FCfQ8I7K5418zrSoL47
         Cx+EF95T9msfG44DvlMyAanARsVf/rNZ7GugWeZ4rmD1M6XuyVW7XlgPRK0tF9YNF7hW
         mRNpBUiKJOo3cJETMMLQxFyniVNYm1EayreVz1RS35LtW13dz6Hn4DZjLD7C1iqUPUCf
         zv5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=zUOcAU6p00loQ1nrwWD7GDrs3KRhifPlQNEkBCXrSQU=;
        b=XgBPep2LG+oPcsqocPGCyaSjRWgsvzmbeDQqmQho7YYbZ9rUxdtxbJBlGzFd+yj6pR
         c/av4mNWDJtAz19i2O+J1XQ4jIiVcmyH4pCGPyS1UZ9TXuexocFMcyZrQotNPEUzp7gh
         lM2MhXtx1AUALJ9hHWOSDkjwtrsx+0/0H/KpLfcM8LJ0MCQIMVzVqiScG7C2SDNq6Cuv
         tSJALFzFCVkwug8Jy/c2Jkf9BGkiIX2TayHkdHyGGO/HTln4/cfQzx5dUlHqssHduRL6
         EB6TX+fA7WcnXMsAOct8y4CjC4g2pOrA0NKiiz7MEFywB8bEXmtnw2AjEsYkB+prnwFO
         mYJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VYKldQtW;
       spf=pass (google.com: domain of 3dus3xqokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DUs3XQoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i22sor7624119vsq.28.2019.07.23.10.59.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3dus3xqokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VYKldQtW;
       spf=pass (google.com: domain of 3dus3xqokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DUs3XQoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=zUOcAU6p00loQ1nrwWD7GDrs3KRhifPlQNEkBCXrSQU=;
        b=VYKldQtWxdBSrLk5sLC9xz+aQwiA+p9laEjbuJhQ+y14MW59AQItVZb4XUBX4o3STS
         L9JnHbRkn9qNr1J9IZZM0iJZeAOF+VZrFXTsiwFOiScu2zQivLlflg4hR7bzjUfOiPul
         +YlOCB2JPa3W1380wQB/LrhFWVtaDyOhlYe6qKxweJSR67HRGh68c9IWX3GDOjZKGFb5
         Q62/4pR5YzdGLIAhcCOdymu1+C97aJhL6hmlz2Cb/a02TQdVA66PchqiCSNf3yPDUKCI
         sPIwmB/L8x0Lmk1aIlxXadTx8+U7n7WnYlELCxDnDvSJNs7fU1kWK2fSsF6MBML60HXD
         zTzw==
X-Google-Smtp-Source: APXvYqwKLPKDYRl/Wu0ROV1RQ4E/ZMl8ZV1EzuXeG4/TJA26mw9Ne5fKh3z8AD7u+iNI3pn1/I9GUafVuAQJAaix
X-Received: by 2002:a67:d60e:: with SMTP id n14mr49253950vsj.213.1563904781800;
 Tue, 23 Jul 2019 10:59:41 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:48 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <7969018013a67ddbbf784ac7afeea5a57b1e2bcb.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
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
	Andrey Konovalov <andreyknvl@google.com>, Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 753479285ce9..6ae503cfc526 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -377,6 +377,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 	 * again
 	 */
 	if (!ib_access_writable(access_flags)) {
+		unsigned long untagged_start = untagged_addr(start);
 		struct vm_area_struct *vma;
 
 		down_read(&current->mm->mmap_sem);
@@ -385,9 +386,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 		 * cover the memory, but for now it requires a single vma to
 		 * entirely cover the MR to support RO mappings.
 		 */
-		vma = find_vma(current->mm, start);
-		if (vma && vma->vm_end >= start + length &&
-		    vma->vm_start <= start) {
+		vma = find_vma(current->mm, untagged_start);
+		if (vma && vma->vm_end >= untagged_start + length &&
+		    vma->vm_start <= untagged_start) {
 			if (vma->vm_flags & VM_WRITE)
 				access_flags |= IB_ACCESS_LOCAL_WRITE;
 		} else {
-- 
2.22.0.709.g102302147b-goog

