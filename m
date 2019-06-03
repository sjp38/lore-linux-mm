Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12788C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEF3127421
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KWmY1/MT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEF3127421
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4224F6B0266; Mon,  3 Jun 2019 12:55:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ABE86B0269; Mon,  3 Jun 2019 12:55:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 227596B026B; Mon,  3 Jun 2019 12:55:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECE986B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:30 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z8so8120278qti.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=TMNTkBlmDGgOOZrctIfCYuVqOYCJYB+OoUZL57F6fkg=;
        b=heYPyJYhUKRc/j88IgMwgVlo5pIHX74nFPht8M4p89wLKhmsJmZQwa+SrayI1y1+aH
         4DICV9QMZ+ALciqGi4HvEFKzW1u8lNqBID0b09Wse1E3g2yU3jYEjdY/x3SGuLZtwNqz
         74saEDZIKa0QP2SCC2XKIdwu4LXsBGWAz7cettPyLfPLo2Krc8w3Q3IFV5bTnWB+SjXa
         QqFxV4fkNPXvPFCtdhF6F8H+3TkM5doEwST2lbb/OIWGFbZVWwZJ0Rnp8NupyYMTSyLq
         SwZcVb1/0eFU9a/TORSRqehtPX3xk65R5UsTe7GjKB/VxYJSfnXFlVJ9gjpEW114SrLZ
         IADQ==
X-Gm-Message-State: APjAAAWuOZ7wWmv1FI01ZL8nkFmDpty1U9iEKHOgmnheVGWw0JWbFsqR
	fBl41jtvde/Om+SIwDAZRHZyJZ80JAEK7UEJZTRakCxJV5elIT83aRGfr0MIQgFHFUHgjbrOFjZ
	UDfTdzf+KQewn4JFsqA3Us6Rp7jO+acy636aBgYOlMhdCejqINuKbmlEkzrC9cTLOjQ==
X-Received: by 2002:ac8:156:: with SMTP id f22mr6832572qtg.58.1559580930626;
        Mon, 03 Jun 2019 09:55:30 -0700 (PDT)
X-Received: by 2002:ac8:156:: with SMTP id f22mr6832535qtg.58.1559580930088;
        Mon, 03 Jun 2019 09:55:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580930; cv=none;
        d=google.com; s=arc-20160816;
        b=paZiWRhMnDIzmZSOph5ZF0qien+yIFoA04/a9pRawtqJ1V0MWE5zFBkLkqA7Kn4mpS
         //XgVHP4ZIo+Ys0UAYSLH+Rl6NwMZQwtpD61AS933nEYQ8sXFIsHVtAQuRYdP8m3spy+
         0DbHoqmfKcptE4VmF2tbaWvModsVZISM5Q0Z1TBVIvwM6CCNtsyYVHYPy6KlfMwVaUxO
         9VBllnfPDQLe6SCdSY9PjBOB9/Oo+KVgthLUBovTF/19jBPnX1w3zQnOejpnGuS75+sy
         6GJVtHcRgWG7+yP8TOD+EDm2gtXyBLKTLtgDyrpiyr3UmCFrH/aSPY/Sf3WpkUNNL8nr
         sZaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=TMNTkBlmDGgOOZrctIfCYuVqOYCJYB+OoUZL57F6fkg=;
        b=FNt2presVFvBMoN9s+VM2ZEmDxCg3b2/wrQXZ9ZQEtvMtHo4QwFEl0vgiAKuwms+cL
         a1nx+a5IPBq5mANlmfb3OMeFMsm+FoUoaibLU84MeSeSg/ru/ys1OMCGd2rv9fQBgu70
         V2lEFpnSWJCgn3idNgKf7pRpD9WaZxyjc8msRcBMRbIwLQHyU9EewcFi/V7EA0GikVm+
         NWawR1OR6qw5zfDbzCTncqKWoKgQ3PdkCCFrGAiH1BXOfoJUCy+7VSzFJPd3dQoL9A/l
         gHxg5qTFP5cQLlP8y1ULKSYrqGVEqVNOMYuTl9oJfg1El9xxxgsnCosvhXid2gkBoZcr
         WJEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="KWmY1/MT";
       spf=pass (google.com: domain of 3avh1xaokcgyerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AVH1XAoKCGYERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e34sor1732830qva.31.2019.06.03.09.55.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3avh1xaokcgyerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="KWmY1/MT";
       spf=pass (google.com: domain of 3avh1xaokcgyerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AVH1XAoKCGYERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=TMNTkBlmDGgOOZrctIfCYuVqOYCJYB+OoUZL57F6fkg=;
        b=KWmY1/MTf2lCSA8LP774r8p0/RElUafoWRXpiTV5M0FssBvd2DR+JnorkPH/h4Y5+f
         yR9XiiiNdq2i4QfOjofZ58b2UAQfK20Q+cucasNJuK58SVUF0twT9Bg5tEaVarSUnpM0
         CkXfb2ETfWkZvMjhhmX2MfDgGW4xKH4IotNUPi45ZU95oK+BdGaJ73sBg/cX0kzx4m8b
         MubK1pKIg9ehFkgM51KidZa6DmQaV4zELWE1kuJ9QUfecA/WQ31VKLS+QtHdLvI4uobs
         geOOZXZ26xHTUKbG4mCrjgzhEEUQSTlmmrjiggpRSIEqoJXM210SSB6rrtJIQUmyJUQs
         1hHw==
X-Google-Smtp-Source: APXvYqyPiXiZoks5Ggp2WbCYXPXwRsXJyBinTtF4q2J+DeL6YZqEYLLUcsyCdMKT9rkSKMCpecR3goEaERoY/ZM9
X-Received: by 2002:a0c:d013:: with SMTP id u19mr1987564qvg.136.1559580929777;
 Mon, 03 Jun 2019 09:55:29 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:04 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 02/16] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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

copy_from_user (and a few other similar functions) are used to copy data
from user memory into the kernel memory or vice versa. Since a user can
provided a tagged pointer to one of the syscalls that use copy_from_user,
we need to correctly handle such pointers.

Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
before performing access validity checks.

Note, that this patch only temporarily untags the pointers to perform the
checks, but then passes them as is into the kernel internals.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index e5d5f31c6d36..9164ecb5feca 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 	return ret;
 }
 
-#define access_ok(addr, size)	__range_ok(addr, size)
+#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
 #define user_addr_max			get_fs
 
 #define _ASM_EXTABLE(from, to)						\
@@ -226,7 +226,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -234,10 +235,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
 	void __user *safe_ptr;
 
 	asm volatile(
-	"	bics	xzr, %1, %2\n"
+	"	bics	xzr, %3, %2\n"
 	"	csel	%0, %1, xzr, eq\n"
 	: "=&r" (safe_ptr)
-	: "r" (ptr), "r" (current_thread_info()->addr_limit)
+	: "r" (ptr), "r" (current_thread_info()->addr_limit),
+	  "r" (untagged_addr(ptr))
 	: "cc");
 
 	csdb();
-- 
2.22.0.rc1.311.g5d7573a151-goog

