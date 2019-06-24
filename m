Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C908C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB2C6213F2
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VLugRRxW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB2C6213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363DD8E000F; Mon, 24 Jun 2019 10:33:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED7F8E0002; Mon, 24 Jun 2019 10:33:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DC678E000F; Mon, 24 Jun 2019 10:33:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF6C68E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:32 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so17197409qtn.14
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=xV4GbhfwTJs/VHD3XxRc3myky/6/dZivHKwnC5uKFNY=;
        b=jGls6IfYfz+7LtIFwxfnPIngf7G75MWHwvXRLsCGFz6MXOws4ufdaBamIuOALk8QD+
         yKUEWfPRLg8RP6Sw2JgpSJkGYeMWyEOzkPgtfVqvsDCjcaThx20WgcVN8X4d/qHDtPSc
         H4TILp+8vulqOeSkRSMByIwN2Cqv+3dj2l5jPZeoc3aEaQHjuZxEcJ0xy97Kb+yinw4/
         hkXQ6cO1ab52QxTRprOw9TZtDi1vjUVCNQ93iLHYlvpLUJxzHrmpwaCi6NPmkNvjzgON
         dJpcYF0ZIze28+oF4hGcZ5TKRlfbHP1FXyGKttgCAyCvFzYD5pK11NRGw/AHlRpVi7CV
         2Lrw==
X-Gm-Message-State: APjAAAXPfvyqsie9CQwuOedJp2KhyxL/RSToDt8yo5ANIP7w9P1RgsSo
	+e1C+NyTTZHmmNYWWsMuSzlIstyj+kblbOnbGBtggUC6ST0mGXiGuG+S5fYCzdXH///urdLfVS2
	G0DWdU7LaM5sAyfhRpBWKU9JNevGzhwO/SPyE8SF8Poss1ijJbWweIk79dfTqr4geFw==
X-Received: by 2002:ac8:16a2:: with SMTP id r31mr128054296qtj.302.1561386812729;
        Mon, 24 Jun 2019 07:33:32 -0700 (PDT)
X-Received: by 2002:ac8:16a2:: with SMTP id r31mr128054260qtj.302.1561386812159;
        Mon, 24 Jun 2019 07:33:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386812; cv=none;
        d=google.com; s=arc-20160816;
        b=S8yslcgo9EC9VpDXnCkumQdYEPMRZAU5iUmtWAyS2vLpkXzJoAdcRFhai9KublXATK
         H4+5ntJcQ1b7eil0H2scXGC1cvW1XelS932q9cnHEutfDpvjYhwRz7dX1IauTIin0di1
         6E43kQnXusQ0yM9LGOyCKVm+SNikejlKBIaxq8FG2ny0EGUotkpTdPvmPP1t5pU+FLA8
         YXosFkI3jemRspOCaKb6q3rGmldi5lLZaxy0s0uM2W/PdyCww+Op6TsPYQd4tFlOUjlm
         A/G4bN0jqUlUynYixWqqUD7xrzrpWfZqOYJjerDKHu7GOhhplt0SN9jxla7zVys+W0Aa
         qgtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=xV4GbhfwTJs/VHD3XxRc3myky/6/dZivHKwnC5uKFNY=;
        b=HlWSqF7OaK9vhpqwDkcPtmuF/dwSSz2scRciGWFaw/YX2XHitlSS0Ch5ThlTFkdFnV
         cnmxKr8tTZ8vEXIzSwlacTUiOZdbMOCMXtrYWcw1k+MyE47nsgCKVQ9QdE39rbMPk/Gk
         8FHNo/4JcmV/4DVtYyuyQVtTepwuO+5ztEZIZ1sVrjLGM1Wp4F2iIiwn3s3XtvY0b2Hf
         IFX9ygU9ZYD7+TfQ6FZfLvtUtWL2mCYiNqaDeCNg2dM9bh8YpswouXqd+e2AeHD63fIU
         qEIjxozJpjNgQLXwD4VD9vH+3bCpVyRmBvRD4eBkFaUjuaC+UP6doO0NDEID+eNRXcZr
         dZFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VLugRRxW;
       spf=pass (google.com: domain of 3o98qxqokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O98QXQoKCCwIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g3sor4673822qkb.90.2019.06.24.07.33.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3o98qxqokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VLugRRxW;
       spf=pass (google.com: domain of 3o98qxqokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O98QXQoKCCwIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=xV4GbhfwTJs/VHD3XxRc3myky/6/dZivHKwnC5uKFNY=;
        b=VLugRRxW8NzEgheS31MNVa1Sf0NPG55w1n45MRa1PCRLK9hq7S2jBGoYLnFMFiHI5i
         hpX0xoMfsikUNRg8wsT/s7FiLojNQJbMZrLaUF3hUbhIT0quzLCgUnw+iuzryEs61l+O
         Ve0OmRPuLrSa3geOriI62VfPQqKbergnVirL4Oq9bZbq3yOHL4EORN4ukQhnIooC4ZN9
         PZ1lLy0eIBkrTz3zU6usqrjjK7ENTukF79xqMm8AaDpm29IyoVXUdy6JraPyjXn+72vp
         F+QX4V4XVS+gqXq9OgmVKgBE0AfC5B+46IUnSBLokKMZbLpJOxTVnXtB640hiGZTFThT
         nCTg==
X-Google-Smtp-Source: APXvYqwe8X+4yuXQ7UlZtRYriaSj9tE/sKjuV5CxgHmn3yQIPlD9lif2nlCyzd6rbdataPXUKZA07t9k3oZM6sHi
X-Received: by 2002:a37:640f:: with SMTP id y15mr50777872qkb.79.1561386811824;
 Mon, 24 Jun 2019 07:33:31 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:53 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 08/15] userfaultfd: untag user pointers
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

userfaultfd code use provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in validate_range().

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ae0b8b5f69e6..c2be36a168ca 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
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
@@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
-	ret = validate_range(mm, uffdio_register.range.start,
+	ret = validate_range(mm, &uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
 		goto out;
@@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
-	ret = validate_range(mm, uffdio_unregister.start,
+	ret = validate_range(mm, &uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
 		goto out;
@@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
+	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
 	if (ret)
 		goto out;
 
@@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_copy)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
+	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
 	if (ret)
 		goto out;
 	/*
@@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_zeropage)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
+	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
 			     uffdio_zeropage.range.len);
 	if (ret)
 		goto out;
-- 
2.22.0.410.gd8fdbe21b5-goog

