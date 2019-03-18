Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79322C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:17:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 398C020989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:17:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZCnCpHap"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 398C020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D196C6B0006; Mon, 18 Mar 2019 13:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA1166B0007; Mon, 18 Mar 2019 13:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6AFF6B0008; Mon, 18 Mar 2019 13:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 980D96B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:17:55 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id b16so9927325iot.5
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=KIo8oWJiDv9v/E/mPPwhZiRciLiKrIvC/baZmziEPvDMghQVROFiYmnjov3Bxb3Azo
         uRy+BJS/aJO8H7UHgoIEjNNyudZ2OmehEZvSlfulLjUeXgG0JgwjDRlVDR5Bp0BlC13h
         9t9QZf4H6FWSROqIXMK8C2KcGfYogMrpzBVXMjYOubF5JVaYXW1BxBUSF5KqMA/dMWdg
         UzmV7MRF7woh9rQbEaQP8pubhY4JGrCKOEC22YNrUi9wHRKYdphpyFidINmJHKpmVIo4
         yQOz6vP5JchAjCl66oF/nn55QnyDyk2i/KmG8YDcwJ3GKZl0YVcHfDQhXB95xB8Q+hxo
         F/GA==
X-Gm-Message-State: APjAAAXKZ8caTS/NCf+HCyJS6xk+1VIUdvHwD1HLImIORrtw01CUCZ8p
	LIpjvZToVxOmQ6aip15yqu9AGal4ttiJrA66/wjXGm3l6beOJc2oZbFGqAkYe9UIN3dpW7wFRhY
	YoLnPGGvofqKm+pzEbFeui06bc6FURDXxl9/mP+oQUaGpekS8jLP2pnP26+opqgDk8w==
X-Received: by 2002:a24:7fc2:: with SMTP id r185mr10597274itc.137.1552929475284;
        Mon, 18 Mar 2019 10:17:55 -0700 (PDT)
X-Received: by 2002:a24:7fc2:: with SMTP id r185mr10597168itc.137.1552929472525;
        Mon, 18 Mar 2019 10:17:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929472; cv=none;
        d=google.com; s=arc-20160816;
        b=E9YwMHUMSISAecvEsan8bxPAWQQ6QJqb40mnXdSEPjP/1xxAC9lh/9xSimkPw4V+lD
         p80Agq3YStiiJOYC7DRwnZlB7GPISRW3gS4GFeiZTyqb8+whY7VcqDbN5xSL/rykIjQ8
         yWAA6GaibDo72aysyJ1tRXHWWrzYRe1YDbk5SnFhbfQl5IkCOXEbjwkMSeuoo6ws0yTX
         wmaQUuntqTPJHlLrQSM4Ac0LhtLn+pQHNDHqXmnnKj1y/76KgVwbcgFLrh7G8ClOgnKi
         Rg6YRNkCX8VvqOjsgcT3/mYsuGlOMO54Xs/bH69DDFsS2KJatJcLHYkPl/n9PPsgJPDK
         UdMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=tTVqcx8tttLBaQqbcwgNYwwoTgE/bBTACWCuLBV7z4rj+e+Fvz9UXgiqOdSl02u7Me
         0sziZGMCa9evMBZIoMIupHS5rKETg0fQfI0idEbpsMwO4pCHpLY/+/noyAP3uWvQwHXl
         XR3YjxMqs9Mv/a6WQc51sSCbcmzKkrolaVim83n0xxyM/kizH98A+FO1F3bAYyzn6EjN
         0e0bMb4NOZktCxwwDZ0vxJCMtysQ4pETMIIJL4uo86bld7/Cor1OvhhG9SyaVnXjOxyU
         XfF5l9Lp+tuHcQtHPEyjC42cqSauUi+Ets+kYbWSEMYe3J33fxUWdcRyTO3rp9pHN2Et
         cw5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZCnCpHap;
       spf=pass (google.com: domain of 3wnkpxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wNKPXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h12sor16672098itb.29.2019.03.18.10.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:17:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wnkpxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZCnCpHap;
       spf=pass (google.com: domain of 3wnkpxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wNKPXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=ZCnCpHapZTf/qLS1N3vuiLVDpuei/65u8OAdfxmbj9C6UycfT7l0asJ7ukPP0vA4Qi
         HwZtqNnAkTEZNxdFQ6ErXg2Ws9tH+1NRLw2LH+z6sEsmpFcEdBiI9Wc+uKPOo3gmlZBe
         qurf9ufUqK/sY8KXNWAv2He9kNybaZ4j8MY9rM8iGvsQzRNy7m2xQuCJRiBD6UV/MuZG
         ZknYNqa6eOMfTCYDnGvBMcFPTyz86UhzqH2sZgKXS34VV/J9Ek9ZWHRf9Zq9g9xbx/V/
         tDLUy208+7acHrCH16I/7nTUTuPpcoiSwjw+gJftawG7U+l13wzbQ4qY22WWvgzkuT8P
         l0fg==
X-Google-Smtp-Source: APXvYqyopOaWYQMzQnTkhFFHOoZPkt1VBsocl/ck7RQXsYYUFcmBQwiieFFWtWCSqUlJhczEtHKAp8R/wIOv7CVC
X-Received: by 2002:a24:4503:: with SMTP id y3mr10296221ita.32.1552929472134;
 Mon, 18 Mar 2019 10:17:52 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:33 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <bee403f76b40f37c6790d144a4142f293e0a7d9f.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 01/13] uaccess: add untagged_addr definition for other arches
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

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..4d674518d392 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.21.0.225.g810b269d1ac-goog

