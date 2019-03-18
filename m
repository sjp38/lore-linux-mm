Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37922C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEAF920989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oz1fvLMf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEAF920989
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 021216B0008; Mon, 18 Mar 2019 13:18:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC5396B000A; Mon, 18 Mar 2019 13:17:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3FDF6B000C; Mon, 18 Mar 2019 13:17:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB2636B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:17:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id k24so13905769ioa.18
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:17:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=HxReN0+nxDw+JhPv+riNv28HRbVz25Ot/mSTQ8BQqgM3silxGDfCFgNQUVzXglqabe
         rLKYvGzDX1t2cjfRPTQ5YQKxzGfQdw3XDHiLXzdxlWj9SLfpUdXxhfcgnbVncZX5HgjA
         k4+4IJDJxnKGttYShYZsK1zZtBUwo/xiK4THdfk8XOpTqM/4n1aEukXE131LaF7CpjjP
         C2uyWmO4XdkKKcUokuBQ/6skRr1+yqT7Zsgc4Jb0D2rP454dJ9NwXoqB0B7yra5gNpsN
         6JcaHJcWnjlKtTEPd90ezdV9mqEJNV9y8rrGj2C4AwF9hfLQSnVJ0F3nNWsA4sMTEExo
         c3Tw==
X-Gm-Message-State: APjAAAXlws3vCYyEL83DaQWaXUFLY1HH6VkqxgEFRRXXfrMCqe1pDshR
	EJVRtQCxnWTkO8t9uDGcWBS8W4u4fZBvSgUXy4iOVlB2GIxhBQDm+RVZxK8B2RcwXXItFlL65oS
	tmya/zxqcGAhrVRegdaUlHBy8KlkBxGD4YBnVhQ63kBWhH/UAlboKqYTnrK8wK4M3kw==
X-Received: by 2002:a5e:c019:: with SMTP id u25mr12267457iol.104.1552929479441;
        Mon, 18 Mar 2019 10:17:59 -0700 (PDT)
X-Received: by 2002:a5e:c019:: with SMTP id u25mr12267406iol.104.1552929478545;
        Mon, 18 Mar 2019 10:17:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929478; cv=none;
        d=google.com; s=arc-20160816;
        b=XW7P3L4UACRRQwunHL/17oRVkLi4PrCxDkJ+JsITjzxYi1tBVk2SUw6qQMaLBfKCog
         Agn1XWp/MltfTaUYsNUbC5jL28TiyTeiHYkz5qX0QmkwCgfRY6yVmj4gFIPLXRRP0B6x
         +TgT3ORZ8t9S6hl+OhPYNSLoA6KUHc9pZY1pAMP5a7C/b9h5sk9+h+7JzYlaE0S3cj63
         IrWJ/rvK+kwaK2FOmGn6HaLZp7nj5RPx1YUBGtc19xgb2KFnyULxOeVToFJ9itm6td5v
         XQgg7N0LA36NRZoT86XEzsxJYD6mFlXsCnbUHXHKPwqhaHl5uZq7brI6Gf5Fv7oEcNTR
         mMYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=lP7xAdkfF1n21XHpwqkt+rVQrEjupLwK/TOgsOaZlsPlKR8YSU/s/4FmIuiZROph97
         NXheqihEsSBD4tOkBim1GLjr1uw6UCLEPqIWFizC0P2VGli1WWetsMxPXIuTTEQwVBa0
         OlcwrU3pElmheSb2I8fsn4ecIaHH1Mh1kCLlt3Wha2YLTiAVwag2IIPfPawnGHQC8E8j
         hwaUzE3Z4tlyT+SUWiOKH4aqZ6GMgmsuLFNwHB+paw3RM01YgiRCNPTCdReW0DtfCxiS
         CB3SZiwT6arqUttiRyVp60QNWqwR2AzBAzCY0hQxm5nC+AUWFLNf6NIbi79l+vHDA2xk
         2zfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oz1fvLMf;
       spf=pass (google.com: domain of 3xtkpxaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xtKPXAoKCJUzC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y71sor16820680itb.22.2019.03.18.10.17.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:17:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xtkpxaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oz1fvLMf;
       spf=pass (google.com: domain of 3xtkpxaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xtKPXAoKCJUzC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=oz1fvLMfcGfF81Olx8UNQHEZSNueq6Qn8HIXigOddOJDAD2tg4UjJfuFuQZjoILWrg
         CZQbFlcBOVlSuoBIyl+jHf6+DdY1aYxqiZ+PbKmfk+lr5pHfcoSSl29R6PrgmkRv2+Vt
         jaBUYlq/IjUpt3LjnPub3yHlYsiou77HiwqH/RPJgcNyMlQiwfZhgtvbqZ2qkfe+w8YV
         JszqgrO+qE+QbtWQuzywwpj8p6QWhPyanRNQsRRsaA1VHxFYfquhluxhBFXc65JKlppp
         Ta4otXITXmaoRx/+KSZjVysEXe12wNPaDhCUR3L2hY/+Bjcp+T9no9YB/s9yH1290+KX
         DWGw==
X-Google-Smtp-Source: APXvYqzY2/zsv7O6GF0gVVMoQ0dZ1/muXN5k1+3Ljt96vcewESoCRYK8ve5Pym7TRNy6ing4+VelgBsDa+oWzLVC
X-Received: by 2002:a24:29c5:: with SMTP id p188mr10832598itp.4.1552929478230;
 Mon, 18 Mar 2019 10:17:58 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:35 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <f7fa36ec55ed4b45f61d841f9b726772a04cc0a5.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 03/13] lib, arm64: untag user pointers in strn*_user
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
2.21.0.225.g810b269d1ac-goog

