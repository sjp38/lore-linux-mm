Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 777D7C10F06
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F1672075C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yEf938ID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F1672075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 224126B026B; Wed, 27 Mar 2019 14:03:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AE716B026C; Wed, 27 Mar 2019 14:03:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 026036B026D; Wed, 27 Mar 2019 14:03:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEFCE6B026B
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:24 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so14525817pgx.11
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=t7SDwrJLdFzHmoE952yAwrB6/dUOEo0V82SWqIjaM/4=;
        b=X47aPP5mr4zfS5fDOoghP7DjvDvQ+mwcX9lM4uHRXB+7x7is7yJtFXjFqWRfzQ6Wsl
         fD3SlQxtBeDyUGgWiT/TDjveMlz1WaJ3Ykw9kwLecO1UWctQbcmG9XjONdTRTUsPHoHZ
         11TIvEltSxjDabRrGUudtH04ez5g07622MOmOJ/e5bf8HLrAMlYXTAJqWujrWAhZpux4
         F1Cr2U1f2wWDY8kwNb+qAg4JBsxCWThUYB3YPQAj2In5eAmrWG1ut2SHEWY2P+1+LiKw
         BPFevkmcNNpxuzWLm+a7klgQoalQOQOpR874WPzSb2BXjaFhyOm0CgW6+MsEEHV2+rFB
         egOw==
X-Gm-Message-State: APjAAAVkHNLiKf7SpbgHreIMCmXcJsb8QOVJRBoBPdCmSQwpRNwVsJye
	0uPDELwgPh0aToRYiCU7XtbcCWnB83PJef7qCQFxthJtDCcHrD3BK8q9kasbffSx6ct3I3wce3V
	CaN6rkzrZ2zivISmm2YYYjJjarzrb3xehqEqLe9Vy1ep5u4s85Oo9h8mUu3mFtcM3Jg==
X-Received: by 2002:aa7:82d9:: with SMTP id f25mr36378565pfn.45.1553709804325;
        Wed, 27 Mar 2019 11:03:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfRR+dya0iHm3TpPOd7OrsqwUD1D8OAurkBuzMgM0Jt8ZuTk63I5wy0/jY2u4J9ST2U44T
X-Received: by 2002:aa7:82d9:: with SMTP id f25mr36378489pfn.45.1553709803543;
        Wed, 27 Mar 2019 11:03:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709803; cv=none;
        d=google.com; s=arc-20160816;
        b=tingKSys2ycXE0SuLBLC9Xj/fmJnEHVBdrUf3lwRLyeoDbDOcRMWpYNUgYomhoNFDz
         4VYpDOagXIdGepyiz/uarX9Ra3GUeYBQDTtciEtQ026b+BG9TiaDlxVx+DRi8Sz/h0yc
         6A8OS7RQPVXGtC1C8qoRG7c9lFWaycykKVMvmIdm69JKK+YNNYU2F6JzgA9bzcjbn+Ff
         KUfW0kLHAYf24pIkge9TlLrT7WAUfPAJc4zNc1jhyAKWdaqak8yX2ffg/ivicHNbIUms
         5KMDhjwGxX7O1Spbjh9dJxapgv5tj2edcnqWnn737OpvswOfoxeX7S9iKepCK6jnSir6
         2Tng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=t7SDwrJLdFzHmoE952yAwrB6/dUOEo0V82SWqIjaM/4=;
        b=fTZMjvykKaJCBhZGXchAkg70Cvr4LlOP32rFzdzxfoWSUxP1SWEIYcapaMGyljcI9n
         F6J52WCYoAnKsMiret7He7czg5PSMemEoroljYAm3mRpB6dMpRCJUQxNS5+3Ng+0Jxk6
         BS0caJt+/W83gec7JeKanXOKtyVsyJ8FlV7Lh5obdth9sSeVaxV9VuafCFxR5VG6s8mI
         01psyscE/R+2bMVIDYgAKWeaDB1jsuTi2JqysL/ewQl9JNasJ+TTJSwOghFeu4kbzyC9
         a16Y4YHvOLJhmp1S0D13j71tIexBofUx1JFxLb4XlCnKV7qhFvLo+G+azVPyy69eQuzW
         bVkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yEf938ID;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k17si18372865pfa.181.2019.03.27.11.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yEf938ID;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AA8E92177E;
	Wed, 27 Mar 2019 18:03:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709803;
	bh=UNeV/CEiqTpGckZzIp25/uCRYplK5p5pIYBYfUU7yIw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=yEf938IDBtskcjfTktcRTEC9eFAhYAXHorTLb8XNZGzEpvBD7i5jzUHnTf/5gNsXn
	 VdEsSX7sn+13JF7VO67XhtiyfjUKcy+vCpz0m9QOIUDQFbeqbniIQvQv0mNzVSJMmt
	 0+lhv4P0Vdjd+mBg4tAkF4b7zxhVQP71VHYMdgQ4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 045/262] kasan: fix kasan_check_read/write definitions
Date: Wed, 27 Mar 2019 13:58:20 -0400
Message-Id: <20190327180158.10245-45-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Arnd Bergmann <arnd@arndb.de>

[ Upstream commit bcf6f55a0d05eedd8ebb6ecc60ae3f93205ad833 ]

Building little-endian allmodconfig kernels on arm64 started failing
with the generated atomic.h implementation, since we now try to call
kasan helpers from the EFI stub:

  aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in function `atomic_set':
  include/generated/atomic-instrumented.h:44: undefined reference to `__efistub_kasan_check_write'

I suspect that we get similar problems in other files that explicitly
disable KASAN for some reason but call atomic_t based helper functions.

We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
that the compiler sets instead of checking CONFIG_KASAN, but this in
turn requires a small hack in mm/kasan/common.c so we do see the extern
declaration there instead of the inline function.

Link: http://lkml.kernel.org/r/20181211133453.2835077-1-arnd@arndb.de
Fixes: b1864b828644 ("locking/atomics: build atomic headers as required")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reported-by: Anders Roxell <anders.roxell@linaro.org>
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/kasan-checks.h | 2 +-
 mm/kasan/common.c            | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index d314150658a4..a61dc075e2ce 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,7 +2,7 @@
 #ifndef _LINUX_KASAN_CHECKS_H
 #define _LINUX_KASAN_CHECKS_H
 
-#ifdef CONFIG_KASAN
+#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
 void kasan_check_read(const volatile void *p, unsigned int size);
 void kasan_check_write(const volatile void *p, unsigned int size);
 #else
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 09b534fbba17..80bbe62b16cd 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -14,6 +14,8 @@
  *
  */
 
+#define __KASAN_INTERNAL
+
 #include <linux/export.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
-- 
2.19.1

