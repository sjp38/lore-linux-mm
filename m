Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEAFC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3418A227B7
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cRcOEH0i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3418A227B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80C98E000F; Tue, 23 Jul 2019 13:59:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D09448E0002; Tue, 23 Jul 2019 13:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFABC8E000F; Tue, 23 Jul 2019 13:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9843D8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 5so37135897qki.2
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=mo6ZyD7PJiiiTnkBfnFT33xmRSSjLb2erTRpgEGb4jw=;
        b=AP4yQG3ynMtfmwSOB/wBxM/Z0Mp5sksPGnuKuH0Sb+JJuuA+q0u8WtCIHQhpXe1mTe
         Bc7mS7UvYTTt2bFxm00zJ6zLgzzSRoDV2jSEVbta6gOtDcYDVYxcDNw20JvgWi//63Ga
         +tK97IX/c2g2IQRywLdeUAwi2lWw3wN97hEKKkD/NaMPirGPd0l7mW6kECN5oc1v1oNh
         q8jiJnmWRH/UfLxV6pbQfvmBNhYwRSvpTzpb6uoq82yDZS/ZEY+DK4xFBXnOiXbFknhS
         Xbl1sWnCXxjrSXh8E/TG0t0h/66NDFPh7yBfuieZghWZo8yYIC0S8l6d8JEamnWjC7/G
         pLqw==
X-Gm-Message-State: APjAAAWLfVeZnm8GrkQUrCd2lePqXWJZ31nTBoxLkdyZ1GKTtlTgmhel
	2Caox1EpJIwjS4AeD53eqwd1yVqf99qjHtVH57iS28lwygfcrIivDmkloMKIww6LjSlBSSfzNUX
	XUQv0lmrwA9skEdFT/OTHBmLd7sMsYYRI9zFqqBDfa4JWWV2PbOiZJQ+xXAVVQ3L7Sw==
X-Received: by 2002:a37:a692:: with SMTP id p140mr49586643qke.432.1563904773333;
        Tue, 23 Jul 2019 10:59:33 -0700 (PDT)
X-Received: by 2002:a37:a692:: with SMTP id p140mr49586629qke.432.1563904772579;
        Tue, 23 Jul 2019 10:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904772; cv=none;
        d=google.com; s=arc-20160816;
        b=fm8GxGaBg/z0rX7/wB4uLBD18kFvgFoX9MivmaklgJo0qKDruTmK9+kGpTWfNiGhBN
         Ri6f6q8BlYB0NzedN3AewN8Unv/NsaZB88Zvqllpl4y7zjahlnRV3FvOfI8P7xqiTXaC
         kUPbPVpEo2w4iraQQyOu1aqldbJHr9y2XrB+SN9e7SSlrS44FsfP/geX/6za1zRILXLZ
         wwvfk++0se1MV5LP+HPHljyR2wCujBjLOb5p/csTovaRfZMutbld7PqpHdjOzpMFrvKl
         4J5KyydMY0kws+HjiIhyfYrZodNlxdyNfe8mvVo9HX8YHl601WDBOK4fsUAIrhpzO+Qz
         C7sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=mo6ZyD7PJiiiTnkBfnFT33xmRSSjLb2erTRpgEGb4jw=;
        b=cDBEVWVobXUKrJuAzcoecCdITWWVUayy9ovbVVO7UOJQmdZB8DXXWeVKGyKjERLxo5
         zrKewoXZMY0DgdBpF0vmRWitkXXpjhr5UaDMpKN0+nJSC1PU3/iexZP0u4onBk6sAOWJ
         KQQzNpbVFXf5OCqwEBnxvr2AMck87Uv6akJzsSdqAmdUCsaVFptYy04X7RTrmlmyVKgm
         xzWrQVv+2yzK3X1+YDGm7mevkwG3+LXgy0kwlx26OJ08V+my7rUreo+xEvv8oF7mNlh4
         tkLxFWpdaUMZIG+fpjbWBdhTJqIglgJ8xolOtWojyj24mE7v41s7WCUTfjIBBFxPMFNe
         lZSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cRcOEH0i;
       spf=pass (google.com: domain of 3bes3xqokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3BEs3XQoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f84sor25234583qkb.28.2019.07.23.10.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bes3xqokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cRcOEH0i;
       spf=pass (google.com: domain of 3bes3xqokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3BEs3XQoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=mo6ZyD7PJiiiTnkBfnFT33xmRSSjLb2erTRpgEGb4jw=;
        b=cRcOEH0iv2407FEeEXiGtfbNaRtJQIzg5XbYICzGVGc43sPOA3+CZIMWAHKgebQ1Fd
         NhXvQ2XcNcF8R9x/znx8/B+ZWBuFc0pppCQj6IxF/91ZQehMjq/FUgtTO1kgaD+sdo+u
         g0fX97ge7Kl52ZUaa6b+4pEh6IxUyFSuMDNJlzhUpxY5RLeNi8LIb5QOqygzH5YcXwTw
         u/vwHZkzfH96V/r4aumfuyQXlNmESoQtl9/gLW/U3oOdnKUbG/Ywu4Xo6BgLwOzrtBVU
         Gf76BaPylfmhv0ijCpRq3ZN2WZ9BE8VMsOdxcjRzxf/93AljoTsAfpUOJtPXkeNJ+1FY
         hU+A==
X-Google-Smtp-Source: APXvYqwqXUnbT9S2ecddRPfsS72rTxoBtLQXpIQx9JM0kIhhjvtv5eSOcsPLQ4y/4499Xb23XuIGaF+KOaOVjXRR
X-Received: by 2002:a37:47d1:: with SMTP id u200mr49170508qka.21.1563904772061;
 Tue, 23 Jul 2019 10:59:32 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:45 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <cdc59ddd7011012ca2e689bc88c3b65b1ea7e413.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 08/15] userfaultfd: untag user pointers
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
	Andrey Konovalov <andreyknvl@google.com>, Mike Rapoport <rppt@linux.ibm.com>
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

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ccbdbd62f0d8..6284a4e719cb 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1271,21 +1271,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
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
@@ -1335,7 +1337,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
-	ret = validate_range(mm, uffdio_register.range.start,
+	ret = validate_range(mm, &uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
 		goto out;
@@ -1524,7 +1526,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
-	ret = validate_range(mm, uffdio_unregister.start,
+	ret = validate_range(mm, &uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
 		goto out;
@@ -1675,7 +1677,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
+	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
 	if (ret)
 		goto out;
 
@@ -1715,7 +1717,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_copy)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
+	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
 	if (ret)
 		goto out;
 	/*
@@ -1771,7 +1773,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_zeropage)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
+	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
 			     uffdio_zeropage.range.len);
 	if (ret)
 		goto out;
-- 
2.22.0.709.g102302147b-goog

