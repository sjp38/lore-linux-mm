Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A4BCC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14C08208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p3ae0HY/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14C08208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1B68E0006; Mon, 17 Jun 2019 11:11:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B71AA8E0001; Mon, 17 Jun 2019 11:11:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A60888E0006; Mon, 17 Jun 2019 11:11:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88DBB8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:11:06 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so9377482qkj.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:11:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=J2xlT5BkG4PHe/4/nJk7BmFqwoJl9sRtUfXxrBXjMCQ=;
        b=TwBcB14k4gX7Wko5OK0lAptTRKacjxj1ETsNWoatO3wZCpwjrfBjTEGKw4836RiyKJ
         z963MrnL6L6gtNlcBdH/1J2/iVa+zhHsGbBOVkWGvO1KKjluaP/4DSsNoeZiAnyKksoz
         anC6QVvGJQg68F6eW60cA+Iqc5Qz0eDpnis9K9l/B1fq/fkBML50mshVIA0lHgNw2X1H
         1vX1G5mPP6dia3x2csoDy5n46g7/EhcBqd5SiIISnnf6k6dgaXd+Y1xUA/h6U8zHNa1j
         FfHTuQBouIvOEsrW4pX4jxmD/nsmpcaGsw3fahCcTRPdLge0YhtNKNedZBD1xkPlvf2V
         2DyA==
X-Gm-Message-State: APjAAAWf7fQYYuzyb4x8WFTDx2ZK3jfPnsZruKR5B4QnCTvESZzIge60
	b00Mro43GGfCY1WgPoF4WqarSNxeSbJdPA749fFccLScO4UjKI00ktiivgWcikQK+SZvzgipKJZ
	mA3VXwNVWonwwPOCiNuLsimKIOkW5iXekATYh68uxvJJKTq5l5uiON1eNBo7LmeKRDQ==
X-Received: by 2002:aed:21f0:: with SMTP id m45mr80645691qtc.391.1560784266313;
        Mon, 17 Jun 2019 08:11:06 -0700 (PDT)
X-Received: by 2002:aed:21f0:: with SMTP id m45mr80645642qtc.391.1560784265719;
        Mon, 17 Jun 2019 08:11:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560784265; cv=none;
        d=google.com; s=arc-20160816;
        b=TEeuYZA8paTsIZhoeTavfPewSFGgNgYrQWRg3jmNz04w/Dt9mvBiyxQSjyjlP2piL6
         6FsRTn91GPsS458mAm71YyJzroy9xPHJG9wJWsbwY/4UDRe8yJxiW2sWJsAyXWThqFC7
         MWyX88ysT0YCFl/Kkpiq0MXgDhCJWK7hVpxeh6QipQA/wPx4zbH94ztZIv4X1bVjM0rx
         tKXzlkv9/4ZLss8VveUKo6R65m7YKhB3Ta+i/0b5yFFfsymaRUNk03MXalELkKS8L7k/
         zVKxJJj/K2bPHRA9TNtKQPkYhgotX+UYvBdu2K4Sth5lv+Pw3Xk7J6QFnWTiYQl5agPy
         lYYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=J2xlT5BkG4PHe/4/nJk7BmFqwoJl9sRtUfXxrBXjMCQ=;
        b=0ker+IqWY6Vm+eY7hLROG+mlLTefSUTIubLvsgB5lYOXrUuwp5aRg5HAqFGVnqsRCW
         Iv/p4KnYD497ZfFuZEZmxXOccjJ68DP7As7G4qoKhhR1C9XdWZE/ANG4+H7rvpPdmLCF
         cb+PEbzrs6mrmVr8ThMu5c6+HVtzgu69CERr64RgreqZEOKC1JcyejqUTsCgC4Nm8hxi
         S1+ohCPrlH2if11N6pW5UL57MV+7GTCu8e4qMwioJUTFqnI5ePamf4/KEbc5KV2ph6wq
         q5n5/ltg8tBYF8vtNKB2X3oU6M7k6n5x4kcLKM19WGxX6KXlY/86Q5+wTLSyZFnL0YKl
         TPPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="p3ae0HY/";
       spf=pass (google.com: domain of 3ia0hxqykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ia0HXQYKCPAYdaVWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h58sor16483156qtc.11.2019.06.17.08.11.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 08:11:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ia0hxqykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="p3ae0HY/";
       spf=pass (google.com: domain of 3ia0hxqykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ia0HXQYKCPAYdaVWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=J2xlT5BkG4PHe/4/nJk7BmFqwoJl9sRtUfXxrBXjMCQ=;
        b=p3ae0HY/O3HHcM6wSMM9Tz76pUtauWYXmpaYWMuj4cFJ05HA65ucJNAlfWzvMGlmaS
         lxOyugNBCdTPBRgvKdpVxDPPMXLwju022Pe2+adIc0cy/7WN15Piv/GRhyXgOlK1N9zO
         Qt2SUknDwSdhIbbMc5QJx9l8NVVrJY3o1UR5JRK4IgEsJvZln9vb6KepjjdnvNbApfcs
         9jLqp/1MVZVCrmLGqeLqmR5Z+Lsh9JlA14qkOfLbd3vfbUIUl6HfJLDZnERhBTPjT9L6
         HBY80N8ck39V/TG1wmfxgzmwWsr1L0U03y9/v2GIsZIlHX+iQS46D3BFyn2y3Orggm40
         ws8A==
X-Google-Smtp-Source: APXvYqwW8bb+vtL/Lysm9EpPCmcTXzOQ2ut1uDpyQmfhMuaCptVMX9tFM6WT2buC0hsqYxHSzW//c6xIsSk=
X-Received: by 2002:ac8:394b:: with SMTP id t11mr73550464qtb.286.1560784265391;
 Mon, 17 Jun 2019 08:11:05 -0700 (PDT)
Date: Mon, 17 Jun 2019 17:10:50 +0200
In-Reply-To: <20190617151050.92663-1-glider@google.com>
Message-Id: <20190617151050.92663-3-glider@google.com>
Mime-Version: 1.0
References: <20190617151050.92663-1-glider@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v7 2/2] mm: init: report memory auto-initialization features
 at boot time
From: Alexander Potapenko <glider@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: Alexander Potapenko <glider@google.com>, Kees Cook <keescook@chromium.org>, 
	Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>, 
	Kostya Serebryany <kcc@google.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Matthew Wilcox <willy@infradead.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Sandeep Patil <sspatil@android.com>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>, 
	Kaiwan N Billimoria <kaiwan@kaiwantech.com>, kernel-hardening@lists.openwall.com, 
	linux-mm@kvack.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Print the currently enabled stack and heap initialization modes.

Stack initialization is enabled by a config flag, while heap
initialization is configured at boot time with defaults being set
in the config. It's more convenient for the user to have all information
about these hardening measures in one place at boot, so the user can
reason about the expected behavior of the running system.

The possible options for stack are:
 - "all" for CONFIG_INIT_STACK_ALL;
 - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
 - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
 - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
 - "off" otherwise.

Depending on the values of init_on_alloc and init_on_free boottime
options we also report "heap alloc" and "heap free" as "on"/"off".

In the init_on_free mode initializing pages at boot time may take a
while, so print a notice about that as well. This depends on how much
memory is installed, the memory bandwidth, etc.
On a relatively modern x86 system, it takes about 0.75s/GB to wipe all
memory:

  [    0.418722] mem auto-init: stack:byref_all, heap alloc:off, heap free:on
  [    0.419765] mem auto-init: clearing system memory may take some time...
  [   12.376605] Memory: 16408564K/16776672K available (14339K kernel code, 1397K rwdata, 3756K rodata, 1636K init, 11460K bss, 368108K reserved, 0K cma-reserved)

Signed-off-by: Alexander Potapenko <glider@google.com>
Suggested-by: Kees Cook <keescook@chromium.org>
Acked-by: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: James Morris <jmorris@namei.org>
Cc: Jann Horn <jannh@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Sandeep Patil <sspatil@android.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Marco Elver <elver@google.com>
Cc: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Cc: kernel-hardening@lists.openwall.com
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
---
 v6:
 - update patch description, fixed message about clearing memory
 v7:
 - rebase the patch, add the Acked-by: tag;
 - more description updates as suggested by Kees;
 - make report_meminit() static.
---
 init/main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/init/main.c b/init/main.c
index 66a196c5e4c3..ff5803b0841c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
 }
 #endif
 
+/* Report memory auto-initialization states for this boot. */
+static void __init report_meminit(void)
+{
+	const char *stack;
+
+	if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
+		stack = "all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
+		stack = "byref_all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
+		stack = "byref";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
+		stack = "__user";
+	else
+		stack = "off";
+
+	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
+		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
+		want_init_on_free() ? "on" : "off");
+	if (want_init_on_free())
+		pr_info("mem auto-init: clearing system memory may take some time...\n");
+}
+
 /*
  * Set up kernel memory allocators
  */
@@ -530,6 +553,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	report_meminit();
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();
-- 
2.22.0.410.gd8fdbe21b5-goog

