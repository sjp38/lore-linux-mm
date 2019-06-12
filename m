Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2392AC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2971208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iMRCrqRs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2971208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58B0C6B0005; Wed, 12 Jun 2019 07:43:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53B136B0006; Wed, 12 Jun 2019 07:43:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428346B0007; Wed, 12 Jun 2019 07:43:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25DD26B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:43:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c4so13506940qkd.16
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:43:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=pF1pY6g9sgHe6SSJdZReBxN/hHHz/1mBqQ4jLohhQOE=;
        b=O92sUj1DXynG0tVGzcK8yvKPzEKuAfzr76KKJaPxRJrr8/9y0JHbFtwuwenRgP67rt
         +tu5gDCLkYafntuKXUVnuTDyH1i/Zz4wjDG2GvZdKck2SRSwwNB9XLiK737mIhkNCaQI
         KUgemlA4WijD++e/OXdfmn36387Lo/RBqRDoT4uI23ddXm30gTbNQuSVRuOs/ntuexem
         w982AGJCXGGRLmEcHZC+EAd+jMZwEw18O7pYQsHo1G7VxG9gIYfCOOK8ENFPhXHGz0KD
         PUVMF9glhbUExC6OGDa70Vq5rUZrVIlLJA37i36UEXB1kvcPwXHX2ZMDjJT8s4hkJ6Lw
         fQ+g==
X-Gm-Message-State: APjAAAV/JiO3NI/KbQ2nA8SIAJoryXoQWAOnatK73Cj/ntXlhKEUo5CO
	Jb/nV6L2n+5dGt3lDbHTshWKyrscpW5xkj40cYbfmYZjaBnt+nluC22k09qKXJX9f0O1WCM9Di/
	/JOfRHqgIsxSTkYaalu8OPzOaLI4XRpswggya1AhkCfzViRqfgl95AH5M5rq0ur7VUQ==
X-Received: by 2002:a05:620a:403:: with SMTP id 3mr64048088qkp.204.1560339820894;
        Wed, 12 Jun 2019 04:43:40 -0700 (PDT)
X-Received: by 2002:a05:620a:403:: with SMTP id 3mr64048038qkp.204.1560339820295;
        Wed, 12 Jun 2019 04:43:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339820; cv=none;
        d=google.com; s=arc-20160816;
        b=AGw4pWwJVTvgGJCSR2H9zAm13NlsiYnSAuTCgvmkzRoIiE3Nt5WCQd0mohmfosiaOe
         4YXsukiwb5sDPRevVvKniFeN116jRH1ekdgYuw/66kcnai6wxQCBFAU6mp6eOas+IC+A
         eGdp4Bkil2ydyx9TABgjMWh9XcyDghvRXcajHvCcyCEqgy6tgkQYTC6KiOFssaOgqLRL
         7c+GgkUUR/gzsuj2hEOb4v7kV1Zdh555A9x8jw78UU3ByiW4O7SdovvAH1FNSREe47ro
         Wjr1lLWDnxrh+mweqcO1vr7aLeZ5s1ZwLYcmRcMd17L+V7bvuWzRsGUo2xwjLsbqWMoD
         THEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=pF1pY6g9sgHe6SSJdZReBxN/hHHz/1mBqQ4jLohhQOE=;
        b=Qp9KoFg4l6I+0ZdkpzGwx1Gu/zqSmqnQHSp7BR6mjALBYRSlPobhGupPAxECB5xOVq
         oW5zKuN/dx9ZBxA0ng9SQXrjkLabqMWRpNyD7bPc2FEIckpspmhOWtd02lJb430XiM4r
         mVdsbMQakAmAoYqukUlrFXr/2hoRXxzuVo5l1z1tgPZF7dH2ZZ7ueUszTIHd1F+nnWpK
         TOPeYwnc6Kd2iUT7+wLHwW8i8YnicyxfOqqCpTeEGAG47zAbQeeR+dAYeMO+Us9+7X/N
         cJkL08vOhzTW1Gbk365G1dl6N+9u68oI2BQR8DnnzQZMRbqRNiGV9jsnZ5d0sAOGX80Y
         zlZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iMRCrqRs;
       spf=pass (google.com: domain of 3a-uaxqokccgerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3a-UAXQoKCCgERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f1sor8984937qkg.90.2019.06.12.04.43.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:43:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3a-uaxqokccgerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iMRCrqRs;
       spf=pass (google.com: domain of 3a-uaxqokccgerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3a-UAXQoKCCgERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=pF1pY6g9sgHe6SSJdZReBxN/hHHz/1mBqQ4jLohhQOE=;
        b=iMRCrqRsfaLBvoWwOfr75mSJ/VPfvlbAFbDtrOANqSuL+z1aGCJpTI0vsQBJ49zvkV
         9E9fBJ+sa0296EIJ5umEi+BHGLGKU1WldUfLsc5lzjtqovn6xo5wnnj4Lmb0O9PgfLXm
         rcwLyJjNEekU9EtCutlVconxtA95VHk5TlDWuAVOA+JWDgv52TV4yWWRYEX7ZgqRnURM
         Eul1F8JBswSLtsZ6lUMRapd1H2weXhkqX5JahODOopa1MhAlxblNV2Op319cxPCbAAUf
         9L64VhEstL8JTyQhso+M/6lNjrHhHWa2qS+F7je7+fvMkiPQ8oGbPBPAqN2Cie9HgxaI
         uOrg==
X-Google-Smtp-Source: APXvYqwDKTUvtDmA6SMmQkKz65W969SZufp61k02G9fCL+2/fp67qf94d2M1YkNH+hXtOrCQMRSpsi3TuTa5t/Fk
X-Received: by 2002:a37:6b42:: with SMTP id g63mr50597391qkc.80.1560339819968;
 Wed, 12 Jun 2019 04:43:39 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:18 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <9ed583c1a3acf014987e3aef12249506c1c69146.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 01/15] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index e5d5f31c6d36..df729afca0ba 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -73,6 +73,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 {
 	unsigned long ret, limit = current_thread_info()->addr_limit;
 
+	addr = untagged_addr(addr);
+
 	__chk_user_ptr(addr);
 	asm volatile(
 	// A + B <= C + 1 for all A,B,C, in four easy steps:
@@ -226,7 +228,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -234,10 +237,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
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
2.22.0.rc2.383.gf4fbbf30c2-goog

