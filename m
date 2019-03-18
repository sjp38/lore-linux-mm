Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F78FC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1045420989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eTZPglq7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1045420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4183F6B0007; Mon, 18 Mar 2019 13:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A0CE6B0008; Mon, 18 Mar 2019 13:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 244176B000A; Mon, 18 Mar 2019 13:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67796B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:17:56 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 14so7623820vkx.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:17:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=dK6NFXj4nMD49GkuWWczZHWtp72k3kGK4FubVczMpW8x3sAx3gJJtj1rS6UlpFph7I
         CyjDDy536/yZhuEoLVt6MT1g8dv2o4EWb5fp96Rqs4WJ0yEnK2NOZTA7dcporUvrNQnK
         AUzmEzVTAoRnwDlNBrvt1Mgpr6aDyAFessFzapUYIhkWLRgmDiSWm0kSgOoC0+BDOCcD
         0e23TuosAZdqf0sII7xo6HYE0GGYCNcffPxKzNsmsNldZ2cA9PJL+s+4GiebpOU5cH/B
         OIuXAebkBfTBNV/cHrCeXNAWRCeLOjMM4hdqAcO97hbnGunbJ7UMr1JhjeZ1rhP6Zg3J
         GI1A==
X-Gm-Message-State: APjAAAVuFwPfV6TIEynBivyK8ywpBdgzhIHc+ta7NzvF0CtO+KWNAAiL
	maEl6AlPMAVM1Z6esTk8A0l9BOgzfNz1Smcz/8scFXd4zV78li2+nbP/OrC3+8daUuk+U9/3QAg
	u9PtxwezwX7CExxxQYtEDMbzye+o1Dy053AzqWywnVxzQ+X+uoRXa9Mt2FggI+piwgQ==
X-Received: by 2002:ab0:2814:: with SMTP id w20mr731768uap.97.1552929476526;
        Mon, 18 Mar 2019 10:17:56 -0700 (PDT)
X-Received: by 2002:ab0:2814:: with SMTP id w20mr731724uap.97.1552929475585;
        Mon, 18 Mar 2019 10:17:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929475; cv=none;
        d=google.com; s=arc-20160816;
        b=KAz2IuBWJAqLuLf7pDmnsOxbXpStN0yd7hv1EwBELSOLuxzzjuIYTV22QVpDW0YJNA
         HMkSqBxtm0VoaQiDj3PTfSqvctaTmL6c2astJK94ez4H70VClfy2OmxdZmby/KKuBhGJ
         0BVTkEellhj+Q929fj8aOmr2z4F8R9P529S+mxF1R6tEyBRScnC0eFoDMMIpkeCL3Ara
         O198tVFJkvg3PmpkmtbBVXOd2L4zUThLFskiHE+e5wixYxPseTDTKDk2jMWhSGqHWaDP
         Y/kOFAYuZgqit0MhMOdxUZ2JPqvdqIHyQTVz7rtSYwafXd1pqsQI1ipQx/sO75VaMUuk
         eFXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=yVDmFBqecF3kg3x6izCMefPNXNIVSzFbVmE7zyuZNuThA0kNBNlVi1WUhZVd/Nl/WL
         zeTxAeZVnqZhC/RorWimqYY1HgRg2s7hSOAjF7qRZX1kaEwoffxowml9uft59KgJkeyz
         OV9Wqt7KM2kV0Zcg3u2f4DetmK/6CZNkMpHZhV3rjjui8xr0ikYrSmhBPtfZKdgJKviT
         S4FR6mDCCW3gnChKfk7YD+m6LuU296wUQ3tAyUr6FkQfohuIsru1Boz8kCPoAo6D8qQ4
         5gM72t2VpK6VGXsOo8Kn7OWk15vWWJwSzXzwlpIYaMRABxzm1mPxRQ7sJJC6bp5Zq99+
         yzDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eTZPglq7;
       spf=pass (google.com: domain of 3w9kpxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w9KPXAoKCJIw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u134sor3412323vku.5.2019.03.18.10.17.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:17:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3w9kpxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eTZPglq7;
       spf=pass (google.com: domain of 3w9kpxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w9KPXAoKCJIw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=eTZPglq7PxVqxdqVAjoMC4HmmCrWD8Td2oOWhHZFu/cW19YPVAKsaJLDurjgd2ljVf
         XFoitnM7dNKXaO1X3w5n48lJ0Y+z6lMVYoHTi6MyqIKBKDduB9n8l/eQ3eoQ6ApOGJcf
         g0Ut1Mty7B6R+MM5DXRurd3w783o+tqjI10hk93IissEzK7cyNctMDjvmU3Tdk6WDEwH
         ffIMuMSLEoDbieTKF2ybjM0vJlmx+cWPNY/uy7bo6luMmancF6Vim1Jp4tv/8hL6d3pb
         M2HFyE+DxIM6V89Ha75sQlU/Ar8a05rWTSWi6zpfjkxsTGWw3NraARaPUHt9My5Uw9OY
         7lHA==
X-Google-Smtp-Source: APXvYqw1yRv1Lvlj4b/qzRYNiehInvLnccniboB47LbD/6n+0FpFdxyh/c9QXVRmnP7ZYupHxKhIzMKUChtQA6Na
X-Received: by 2002:a1f:1e4a:: with SMTP id e71mr11807432vke.2.1552929475245;
 Mon, 18 Mar 2019 10:17:55 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:34 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <f7b263a20223da2b8b26f6a5b0d84a575af28010.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 02/13] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
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
2.21.0.225.g810b269d1ac-goog

