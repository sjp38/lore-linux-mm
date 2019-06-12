Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46294C31E4A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0107A2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IoAMjSO8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0107A2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A7EC6B0010; Wed, 12 Jun 2019 07:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97F0A6B0266; Wed, 12 Jun 2019 07:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86CA56B0269; Wed, 12 Jun 2019 07:44:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 646BA6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:03 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id r17so1924524vsl.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=0pRrtQh1WGSItgbOKTKHJXYw3ig9cf9ovTOOwQBNCxo=;
        b=lEWWsJLu5wV12rUH0ZmzrvJCxf897y4VLbn4X/Mn2ybY4kgOxxFO7JdXQwbrPuPEMc
         VfmW8/gqcMwS7RcBWy6/r1Z4qY32LbmsOktjxbrSpc8I5DufXTmwyi4JK6iEnESBsYid
         zoLSf2ahSkQ11SFPnA9QuTvUsNv5RJVNQAaYFLA/fo9I6emc4ki/OnM/w2cWVSwJ7ZDU
         +SbAr7mQjgVZnAbc7LtwFXHGj57trNHz7lmoaOBodtN4MjLHhsGKQoFKuIdf1Ah2YCIR
         AG4GdwQlf2poNV5C4qN3shVVHEJYaAMUriyGPhzWhckqseryNik7/vZNaJ72AaDJrvwH
         Ri1g==
X-Gm-Message-State: APjAAAWqc8ANKXU0XwyYKNlcekrr4qCIACAed68GsT0cDWYHYRzVaGL1
	E9BqKhZDaJfxpQkl96HjW2c6Neg7HFNHFB/8lFY+7iR5ZevJ2rCvre+ZzNIYslCJYLbadnS8KMv
	lhGW4CFKIKzhkWAPoyMUvjNEMjIJkl0nN8uv92XfgRuCDReMn8+s0p/gEBand/g3k6w==
X-Received: by 2002:a67:63c2:: with SMTP id x185mr45006053vsb.166.1560339842986;
        Wed, 12 Jun 2019 04:44:02 -0700 (PDT)
X-Received: by 2002:a67:63c2:: with SMTP id x185mr45006029vsb.166.1560339842439;
        Wed, 12 Jun 2019 04:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339842; cv=none;
        d=google.com; s=arc-20160816;
        b=y9ll2+ySEnxgGTAgtYGohgz2G3xVRaxUan4KTk2uodtDpKYPTTX8Rg8PwaYp2wHY1z
         2pi+3+mL2TkpfNoNDhPVg+dVEgnqycB8o4AI63aUZEKSAVF2gySa//cf7mp7i0VIn/m0
         djkIOpSlNKUiH1mzLV78RpnMU6D4hH6lVi93NyfbMcm5VKk0Aq2ugbzDMWob4xhcC2QC
         H8lyQJsbsE5izi7C6+UZDGKgHvpE9180v1FPNu01v4gysuYiZP8/v5CVfMvd/yL8FpmO
         pDnJ/dOZXAKdMaEZaaP8Zcx99g6xOhJ5ozQ/3arBn2hjpmyQMnXyxlUGnX/kkUtI2R1B
         yNPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=0pRrtQh1WGSItgbOKTKHJXYw3ig9cf9ovTOOwQBNCxo=;
        b=qqFziYhmFv1EXKYWy+Ov4hGOW/ZgOWu264gBoEifpXxWzmiS287sYmShSlHDj38yiR
         HNffYerkALehn3nfgLUlWu9udhkI/TPm0UMAK2u/M06v2wR6kTrnjHTDKyKq8LbcmW3M
         lFrgRV4psTTxZvww8ANKRlXWIwBXHDeXC0m4qLNRxVo2OyZ+MfZbVaLImT9wKy5Re2sU
         SIyPirR9yKC4eRLacFdsW5qQhxBL9IUmf4E4FrQh7CpYMEUnun29jxh1Bk2K+dHkMZ3G
         PgVsFqAsMPqB4B3SdAUcpX3t2ojRT4uO9648jo2txp9lMLq7GkAHTgvUYr4UwiPzFMfM
         gJtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IoAMjSO8;
       spf=pass (google.com: domain of 3guuaxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3guUAXQoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h15sor7072807uac.44.2019.06.12.04.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3guuaxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IoAMjSO8;
       spf=pass (google.com: domain of 3guuaxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3guUAXQoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=0pRrtQh1WGSItgbOKTKHJXYw3ig9cf9ovTOOwQBNCxo=;
        b=IoAMjSO8LpV9sQ4rhyGuwSi9qAWnWdJKm92qjIFlDfIzZK27lRdtbBpUTTqSsHKQqq
         mk4pY6s02uPltexkWHMnxfPS6E14WpHQTBtMuXD5ciPLmKwQYfFZ7D/irHKINjpULcIC
         qesPb2LJHGU1U+hg3Lnr8sbHR2PLa6XJRSA+MwutfJ1QD1fm8gchvdk4JFKcehQpLj7U
         rwlJqHzorntg7c/BDSuoHH78gq9KnzX7dlAs2pxjWc6C1dDkPCqTKTM+gMG73nj/ByrG
         HBTS6w/3UTjUct6MrDb5Sf2LP5/PYv9l52cM1MNahSes/06CDdeCzTIAFl18VFOFWLlP
         HuBg==
X-Google-Smtp-Source: APXvYqyhjQEo4g9YND5Fe8F9dcUypnQYf8jfozQHANwshchy+6+kG6ludLuigCmoO08U0FojfDlhn98Rsb9Khi5b
X-Received: by 2002:a9f:25e9:: with SMTP id 96mr28666032uaf.95.1560339842024;
 Wed, 12 Jun 2019 04:44:02 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:25 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <e2f35a0400150594a39d9c3f4b3088601fd5dc30.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 08/15] userfaultfd, arm64: untag user pointers
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

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
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
2.22.0.rc2.383.gf4fbbf30c2-goog

