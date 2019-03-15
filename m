Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAF65C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C6492063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HPKtN+Ac"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C6492063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE72C6B02AA; Fri, 15 Mar 2019 15:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC5D6B02AB; Fri, 15 Mar 2019 15:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD6856B02AC; Fri, 15 Mar 2019 15:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFE576B02AA
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:51:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i3so9675749qtc.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=yc2TKKK3uyNjx4k/SCg2YsIAkDocczWLqEwyHrZeSHg=;
        b=bJDsiP+PlmWagLv7AWUhVASMZXhwF7pgk/S/O+r9YqBoMKi1QuTBjJMLlX0+pI2Iez
         TWFVLpE0R5wcD/wBeS1IcMq2sdwrUmlI7IqAAyivZOqbxaKCwQbi3fjaj6wd79sam/oF
         8Wy3iPcWBMCcTqaCIDhCZqsG+o3NVkMhIjivQKfC2FM4Ds4OmhqAArb6i6zgLctFtZ8g
         VKXEO/1exFofkZY68SZHnQU4YJ7ikXQ/XgCjlyx52uQIUAzbgSXY0P38L62tqisEwN79
         wELDUYAZmI1oerr3YeOff+HcZ3hToJs/E1XMSQgUXuTiVASNRn1zlCxrBPCTTTR3pj/j
         vhYg==
X-Gm-Message-State: APjAAAUMzH0QdnMA6AmxP3CQZX0b88bTzaWnqezkJxxFoTG5oOiPJTd9
	Lyaf0w+kqkp4z85n5+eVAQA6w5LVsBb8iSU7De2DM2UwvhpvploCJjHktb1epSKrAH/kLEQ22bw
	scOdEtGzdFUSopV+mpt5ghQ5urrelnqAfnzUEa5t4sMa0uStV8ODDJAd2gAYT5/mfaQ==
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr4275945qtw.228.1552679514517;
        Fri, 15 Mar 2019 12:51:54 -0700 (PDT)
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr4275920qtw.228.1552679513799;
        Fri, 15 Mar 2019 12:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679513; cv=none;
        d=google.com; s=arc-20160816;
        b=fUy0p2gx++LsemiOKXhkY40WlXs4HpV9elsdSMbDnSApWKkF556hPmGjZad+E40di3
         otczigs4AlSCDlVprhqM/OMad7lvQ43z0lHdQcB4plmFLYmM6yrMgYt1I+5Y8UYZOek9
         5TSg3Q92Y4Nwpnn87p3DuAvdF1vR50oYYaGq8LtXKaP/lAAY6FzD4LN26jRb/XA+Hylk
         AOv1ooxMjuXeXwsMlYJX6dJyNn6XwfdmkC3HNE49t8r33DXABt7g024+DPlWRURjMZXb
         VwE31KmKaZejZM75ztbLPm/ACyo8nBeUkA6rkvBUQ1ypUMBGIOTQwNY+Enw7j1MjcbOu
         /Iuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=yc2TKKK3uyNjx4k/SCg2YsIAkDocczWLqEwyHrZeSHg=;
        b=hhSuQsVGKxukh2a3uZ03xgWiHHdRZDv6SAs7NvnfxrLmerJ9WMqTwC6IjNYDHdGjGl
         uTjANunmluM6J7xKwY2JW6Ya1SP2iYkvxnoIFh1LV6PJVAGXesKiLEmzfoJLU+hFOHUQ
         jAGxnK5XnY4tlGFY8jpCg+Db/9TDIWZjDr4dlJIRcNgGRWOM1V2DO5nnvag0o780tohi
         PkwSuu6NFEWSo2EKmD266anH4t/vcAGhkYf72B1f5/R7/ozn63ouRk0L2sYuUej1eBzJ
         FBPMkCcQ0eaZddvQDWjGXkwXzn4U/ZwjTydFprkMW8ZzOuu1ME+Pw/LbucbpP6Kh9bpn
         5NUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HPKtN+Ac;
       spf=pass (google.com: domain of 3wqkmxaokchgwjznaugjrhckkcha.ykihejqt-iigrwyg.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WQKMXAoKCHgWjZnaugjrhckkcha.Ykihejqt-iigrWYg.knc@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 34sor3691110qte.45.2019.03.15.12.51.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:51:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wqkmxaokchgwjznaugjrhckkcha.ykihejqt-iigrwyg.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HPKtN+Ac;
       spf=pass (google.com: domain of 3wqkmxaokchgwjznaugjrhckkcha.ykihejqt-iigrwyg.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WQKMXAoKCHgWjZnaugjrhckkcha.Ykihejqt-iigrWYg.knc@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=yc2TKKK3uyNjx4k/SCg2YsIAkDocczWLqEwyHrZeSHg=;
        b=HPKtN+AcCirGFFQHEZAu/mCbNrjYIKj90qShdg/IiFhxen49J0Qdpnr1pcKG7a6Z8e
         JeJ2qVhpKVo0e4MFSlZbzLIR2woDetJaTNND5bdihZ/qbAWcocsa2cvfjheYeB4rsRtq
         VupfRDNmC+dOLdGj40kTGJqU/K4oyQ4V3HkdkM9xosZcLU7jdIpJBpWnC76XUdwc2cRx
         PrBSQsPpZWMh+HxdTYEIi4nHU5c8m+m6PJBso4DlJCsFDkKaGHF5sF+vigRkHjI5UG0U
         RhfFgSuDuzmav8L6Qcw6zbyS+BybgMK3vA4F1h2a+P/7Y7SKXtGu14CbY9cr1/NstkUy
         Z8Lw==
X-Google-Smtp-Source: APXvYqxQt9HPpRfECab7LUPrHAbJSVnQOqRrkiVNkyIaCkT/+WBTjFpEfz28zU++TxipH2bwdLb5/hvYcjvCwg1k
X-Received: by 2002:ac8:28c9:: with SMTP id j9mr3165248qtj.21.1552679513588;
 Fri, 15 Mar 2019 12:51:53 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:27 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <f7fa36ec55ed4b45f61d841f9b726772a04cc0a5.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 03/14] lib, arm64: untag user pointers in strn*_user
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

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 3 ++-
 lib/strnlen_user.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..6209bb9507c7 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -6,6 +6,7 @@
 #include <linux/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 #include <asm/byteorder.h>
 #include <asm/word-at-a-time.h>
@@ -107,7 +108,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (unsigned long)untagged_addr(src);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..8ca3d2ac32ec 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -2,6 +2,7 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/uaccess.h>
+#include <linux/mm.h>
 
 #include <asm/word-at-a-time.h>
 
@@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)str;
+	src_addr = (unsigned long)untagged_addr(str);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
-- 
2.21.0.360.g471c308f928-goog

