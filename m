Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63E16C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 154EC2063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bMyL6O7m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 154EC2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82FF96B02A9; Fri, 15 Mar 2019 15:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8068C6B02AA; Fri, 15 Mar 2019 15:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71DD56B02AB; Fri, 15 Mar 2019 15:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 333806B02A9
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:51:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m17so11258184pgk.3
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=HBqdcrrZbnaUQvnw2SuV9xpSHs4pKIOHqIC9BZ3VFKg=;
        b=JP51IkOLGUfVWJJsNYN13Ps0HWH8EaeJpAzp64uA5HeP+ocSnNohB7l7Bgw1xjEUGc
         HiOeNNXxTxJ8uQpz1Np6Y/1/0o5Kiphp1AGrWormhobepuS9pcZHkk9AL30wrd7kA6pA
         8A7K7nOVGuEpmTKU7iC8cK568xfEaTpnR3gMjpc1y74N3j5OUMSzhjfF84WjioKCQG3X
         DT4u5L/FtEOVpZfcGuxgfFAddaPINtpOAV7vAuAb318AmZ3vgPorF3n7I6nRC4vXS4HO
         6jF9tQlpd2KRxcRVI5iH/kWNH17YcyEK/supB4ry1RNTr74rFf7ru/+C/CCMqYITnCVl
         pk5A==
X-Gm-Message-State: APjAAAUSgtVFzQfYnCQc8qz4EqUeRkLPOdPvtrkcxnUQP/R2m1NGnfHQ
	5/yDGUrIoJnCo8Pd+QnBdqmzqzBV6yS9vKK5RNPmnmlkHkQEZtP8olqF6uqjCf1qAPEinXV5j69
	0b4oacP4NnJBNC4i2L5P52haeK49X45tEyq0jPhcoIFfJabXP54+7F7AYK7ZpJ1LtzA==
X-Received: by 2002:a17:902:aa90:: with SMTP id d16mr5865052plr.250.1552679511756;
        Fri, 15 Mar 2019 12:51:51 -0700 (PDT)
X-Received: by 2002:a17:902:aa90:: with SMTP id d16mr5864979plr.250.1552679510692;
        Fri, 15 Mar 2019 12:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679510; cv=none;
        d=google.com; s=arc-20160816;
        b=NWQTpRNPJ9ZMazH1vLZjzUT9twt3zdtbrYIFNC1iGcljmxIc+qyr9s018pUJKOJUij
         a3FeKhbfWn6Cp6YkkWfP99rGCDhpGJh2ZlX+eJqB8SlfDdWChmTU7mNPTDZ9XMicfO0t
         OBAbZd/Ahdv/FxxGlBubBxjW+PYAtknml2bMQVDcK9I80KhsrekncVeZOfOXyWA1Nuzp
         Gn+B/RPTji8G1eL3duVuVL+dufTiAOUO+t4qK3gJ8le2U1Dtfep09JVjsmf4tOE8ZGHa
         CkSUVN4krh6CnI74Z8Iuex3KK8I9xPOHv/NFFkq4mwCnUdGkf22I2kX1HCwgl5XSx6Zr
         Dk/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=HBqdcrrZbnaUQvnw2SuV9xpSHs4pKIOHqIC9BZ3VFKg=;
        b=iLvHbKHU9heyhn2oth7+Mz3pHnsjWrEKFISWKT7tAM+yaDx1cuiVm5aBg6GbSLyX1m
         /ktoJxeMkVEkFcVQ2R4TMZmssvlMDPfJqQsdKfzvDIpTbSPcQv8zN2PfnFdKkeBBIhe4
         5xt81YAnx5HKjp+lDzXFrVc/jYfntj++/NgayAzFyYFhcBPXuqEwUsO86tlsjeagOkxh
         KhyzkGGDjJThAgRYE4cCUeK+MA/iF/Teb0Oy9ToL7fnJT96+6SEYcBBmqoQfQgwwCsIr
         yc4BKVxyX1BpnbdQ3ZTW+IdscZmGX7+3QWp4rD8wVrHJQhr7bVBE0Ko86DQ0lYZtWhO0
         R2Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bMyL6O7m;
       spf=pass (google.com: domain of 3vgkmxaokchutgwkxrdgoezhhzex.vhfebgnq-ffdotvd.hkz@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VgKMXAoKCHUTgWkXrdgoeZhhZeX.Vhfebgnq-ffdoTVd.hkZ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t7sor4686904pgv.20.2019.03.15.12.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vgkmxaokchutgwkxrdgoezhhzex.vhfebgnq-ffdotvd.hkz@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bMyL6O7m;
       spf=pass (google.com: domain of 3vgkmxaokchutgwkxrdgoezhhzex.vhfebgnq-ffdotvd.hkz@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VgKMXAoKCHUTgWkXrdgoeZhhZeX.Vhfebgnq-ffdoTVd.hkZ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=HBqdcrrZbnaUQvnw2SuV9xpSHs4pKIOHqIC9BZ3VFKg=;
        b=bMyL6O7mL3v0PpvhcraOwU0+T0KPIFPV/p7nmVTvmipE51X/RVpxp6XgCeUgtieP7G
         ixioELJzjz0dEoQWCYr0YK3/FbXsJYHqdPSXpUIsBdn1yDDXj6QnCZ35FOYA8i9HT63C
         4NxOaja1Vj1CohRqNK5BDjm+Ej2ZsDeLIYnjGIPj/aDrjQ9HbzCW01i4AWSy9c6BCqBH
         VOneIHkae9V1wBY19FpITt5gyzE2kQ3GzB4IuuJ9g8/ByewueOS2EyupEZ9Fn2xI7TMs
         eSLl2rv00PucX+Qh3Q1GWwU/1iBbczPrTond0HrvoOUHVc5VY5X1umF2QYAhZzj9B3zd
         L8hA==
X-Google-Smtp-Source: APXvYqwlT5i1jX7khcwaLfGY9H0rl+oWt5KckuYgCZmSJDPuy2OzcL+WBdRis5ZekWALtZsnFbHnM5bpC2RyyAOF
X-Received: by 2002:a65:52c5:: with SMTP id z5mr2165417pgp.71.1552679510299;
 Fri, 15 Mar 2019 12:51:50 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:26 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <f7b263a20223da2b8b26f6a5b0d84a575af28010.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 02/14] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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
2.21.0.360.g471c308f928-goog

