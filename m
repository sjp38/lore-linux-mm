Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3D42C04AA9
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 821F821743
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cjAZo1be"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 821F821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053F46B000A; Tue, 30 Apr 2019 09:25:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F25266B000C; Tue, 30 Apr 2019 09:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0FEE6B000D; Tue, 30 Apr 2019 09:25:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A98066B000A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:25 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x2so3692310plr.21
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=IkuD9zPPDPrNqKOg+1EuZo5HlTMskU88lY/hO73XGBQ=;
        b=m0GMR+SC/Ni2qZ0zGWP0OK62rg0sIhvzpJudmXeCPhNNNSeYG0cNqz3Vb9d532S7nb
         jl7c03ES0gVVCAm+vWnTwef5/Xr9OHwXANtxykSGYlL1R1U2zxsJrF48A3OthbEN+EJ5
         TE9qgUq1Z3QPX56CAVs7aqxe0oVEBuf9PUS8LSxA4uUW3RrMyBf7aqjFHglKILMeM+uT
         cRvjpmpYdPihgpBBNl7rfMuPU193wN305QY6TonXMxSWiuU/njO7F6KHGKo5b2F4nl62
         oPcCZXMJlbS4STdniGZasP1v+dBZ3HZpgvKENgrU7rtLOdbFjjiGwGudBGzd4MeuFzxx
         w+Mw==
X-Gm-Message-State: APjAAAXXdQnwAFmIam4YbR2nFo51FYtD0Vo01p1DQbl+LXBchpnCXKVD
	8FJ5WdU9fSHFvCOthsdJxL1mmyHh15AS9Kd76mWmL0Id4NU9M5wDFAm5nMjJc383CHJB+1P4IKY
	3fi8KpIXc/ohDw/3jXwtvqJ1c/2srdYJ2JtHSx4rF4bE5xyOAxDKFDD2s8EREJTdGgQ==
X-Received: by 2002:a63:f058:: with SMTP id s24mr12854076pgj.257.1556630725200;
        Tue, 30 Apr 2019 06:25:25 -0700 (PDT)
X-Received: by 2002:a63:f058:: with SMTP id s24mr12853959pgj.257.1556630724186;
        Tue, 30 Apr 2019 06:25:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630724; cv=none;
        d=google.com; s=arc-20160816;
        b=0YMAEWo/mQBwlnQgX7Ty0TL1bQVvAvwFArsTv6evCzXhEIJVQq8kRFU47M2r6D6I5l
         3dY6T+wC0qIrKRbi4lT8jcdPjiJPg61zldp/HL30ltxQ/VuW3++UPgLbsDek7QLOl5PY
         RTGHybsJavnSYMxNP3NPCd2RK6pTXA4quITxrEZfeShFIEmWwnLhUWZO1DumAlOKNlDT
         yapqA9cGbblmrtkCcWWyZcBMf0yG2K/CYChgJ5+069bbg4QbRaECdWr8st8KNTGF1QlP
         0Ii2SFaMqto1jjYMlzsD/PnLmBhc8TfxevYW9/j6lOKgKJwLXMU3Wz64KUvwv7DA5lKj
         8N+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=IkuD9zPPDPrNqKOg+1EuZo5HlTMskU88lY/hO73XGBQ=;
        b=OuyvMmD0ugamfp3ALlwSigbfpBZRR8xGG0IhbTG841/ycpJZPBLX9O7brUFND4uXYx
         r2+D4Gobqxj3BCKf+m94Lr2Sj589E8anWR1H05P0QvPJrzNa4cTGnzMJoasWMfqRCsjR
         pgWl+X729FrUqHp2m34UBM4l3SgsERL2kl4PG73UC+nMOdmeieAbhwHoUau5ElUqiwAJ
         7rg/Zhm7oRHRPNINqS1yX+52uI+i9kIJFBgqXXaWpJaLX6xvOIdoqsbvdhFWQQKxbOhx
         985PPHasw39iPLR1lvbEem46lC+MqnSibDE6WdAQJOktmmG4X2gPUgK3QfuRY0MLFHma
         rN3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cjAZo1be;
       spf=pass (google.com: domain of 3w0zixaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w0zIXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b23sor11810188pgb.41.2019.04.30.06.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3w0zixaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cjAZo1be;
       spf=pass (google.com: domain of 3w0zixaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w0zIXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=IkuD9zPPDPrNqKOg+1EuZo5HlTMskU88lY/hO73XGBQ=;
        b=cjAZo1bevEgDG9f0Gp0lCqBUDVGf7WH9HfahHvPYK3yXKOMpkTJl6c0Qs/+BaViS4F
         SVbEHv0pbmF0M0fXn45Xz+XZ5NA51A6Q84gce81tqYq+4vQ4fSd4Vfr74XM9VMTqpEUn
         hpbIVHi0Y6E4lGzikQQHuG5LSWrNkshsuGLGjPRywGWJWT4PFmQUF2llhQi6ncC/Vlfh
         XyXZ2xzPVmh+mASSDoCOMBPHpUNh2v+x16jbihEdr4DI6v1V/jUL7ilAE/v54hqYIVN8
         AFB4b6bLnE3ptsM0NTOpxh1giv5Af/8Vei/jZ/b9XgJhABJa8DnBXyZnippbFF98erxD
         64TA==
X-Google-Smtp-Source: APXvYqxwzeO4aaEq5t7dlXsyLEMZLxNA1xUAM/PWlhFhSshLHzTvKlXrQBr9Il+4R5AJQuOw/QR46XMvR3q8fhhC
X-Received: by 2002:a65:534b:: with SMTP id w11mr7522791pgr.210.1556630723459;
 Tue, 30 Apr 2019 06:25:23 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:24:58 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <29b7234f48a282037bdfc23e07ff167756fca0df.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 02/17] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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
2.21.0.593.g511ec345e18-goog

