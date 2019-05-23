Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2124C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A98620863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="S6wSpgNj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A98620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E4EA6B000D; Thu, 23 May 2019 10:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149F56B000E; Thu, 23 May 2019 10:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A6E6B0010; Thu, 23 May 2019 10:09:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4A4D6B000D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:09:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v2so4948437qkd.11
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:09:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=qhnHCAtijSCNn26wV4yMPm3jkOLzRQ/9bsrbyHuf06HT54z7HHkh/VOzxfySsvb2/H
         nqLIRmoyJ2qP3dFPcAzBFAk3LmXbqSWdlw5KHCiz5Rr6RkOn0by2OAZKhp5R68Zvk/yz
         3IpYc713rQkQvqevi5kq666SPjBdC6gDHc7lKNjwH+5BpEpdtkQ17W6IMv3BdmlFQcgs
         vCnoZnz3O1GqmrMp5MTGmNb0j/B6retRTEtbnXna7CenmlloL/aWt11hr1MlpcyCt9kr
         sTmd2rcS7FM0X55qqLEhnltIN0aOvSsHG7YDaPZtEayBwsysbsg485S0iXzuGJ/Qnvo8
         O4aQ==
X-Gm-Message-State: APjAAAX5nKPukam7qvNRcJoSgd/Lr15Xcr1QE+1e+AJ91cAOnLpUmQbT
	BtRWKOjUXrM3UBtLfqlzNGXBfMIfEYTjPynnauI236+kBuBdNn783HBUJ8azeyOIBJITyIksnni
	bNwpu9yK/Y1v8foXfVDxwstnlIpBjVtgnUt1LsKkuKi7i5wt2pF+yjXkZQNTbT2zkyQ==
X-Received: by 2002:a0c:9679:: with SMTP id 54mr67094652qvy.168.1558620549474;
        Thu, 23 May 2019 07:09:09 -0700 (PDT)
X-Received: by 2002:a0c:9679:: with SMTP id 54mr67094570qvy.168.1558620548730;
        Thu, 23 May 2019 07:09:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558620548; cv=none;
        d=google.com; s=arc-20160816;
        b=UK5jtB52IDE86XYXYGFdsX6LHWqXep7hq0vBw3dRkLA/bOV02FlcKu7F6xyxTWgxtt
         hit76HhCtWQHcDAHWRN250CtZWADfqacJGoeHFRKDVBY8LETSeptrz9q6vAj1PUlLyei
         020MqSFaDWowrIK8ipibXhdsmmfFof6UFYOcrlwZMd30yrv6eO3GmpRebCLWd6EVTWze
         PdHc2F2K93Lz1PtNP6LBzRPQ7rWADo1yryOC+TdLvLhBV0M8hzArk056kJ4gCQkMpx+c
         FNeuH0MjtM8LnukXPjZRxZcUWPhwvTt/NSyRm/nyKq8JVq1dg0ofNsDzIf6afQPhXwsr
         MEiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=va16Dh+qz5TNIt9eksLRq2DgLelwfrVMHEI3N4xL6liuMfX8Z8kWVxTniqb1fVUHxM
         O0NRSLKlh4q3V3VeClbNmXJtAPwPgk7PlhWhBcyhknK1lJ6bgLNBg4a6rILUecweb/yL
         np3gETsiErGHjt0V6WXqQNbYSWK35+EmfC9q6ljGsnuhTzbxehYLOvn6quaOJ0nQc2Ok
         PJASk/eAJiQ+GGOro6W9ieAFEFe9sSTvulIccBAKDetBGtK9YsHUE0o06GXmcwRLXm+0
         25/dic3CzlMM07sb9/8dfnkEeFKwnnB+G/QTC3nswh68FYZe3ySjkHrDTPaJIf214HNf
         2Uvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S6wSpgNj;
       spf=pass (google.com: domain of 3hknmxaykcf8difabodlldib.9ljifkru-jjhs79h.lod@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hKnmXAYKCF8DIFABODLLDIB.9LJIFKRU-JJHS79H.LOD@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l18sor6603346qvq.27.2019.05.23.07.09.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 07:09:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hknmxaykcf8difabodlldib.9ljifkru-jjhs79h.lod@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S6wSpgNj;
       spf=pass (google.com: domain of 3hknmxaykcf8difabodlldib.9ljifkru-jjhs79h.lod@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hKnmXAYKCF8DIFABODLLDIB.9LJIFKRU-JJHS79H.LOD@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=S6wSpgNjmbCtFUus2QjJRqTyIBPMAaNkKeh9nwyrwXr2Pzte3ZJmjZTd35nf8Jiwp8
         G9GAkzUCb8+zWUG4YDPxD0Nv5k03HZgq8/Ta/e/7PgHhNu8mfR0SwqT1rxSGDK8qDO6C
         hD/3qvtk57/g0uj0dMoh9/zw8YXxL4ZepOVtxBed7NZvBb59J/onvCvzUkf7SQfdhutw
         i5udRpMuQdrbEORaIzsRsj3j8E5MX0ytZg/ufaaKzcaTASlDtmnjOO5IdJfOHR00/Cjw
         0b+LHRaugR4iGA1B8XlmuIQqf18DU/ewjMiyqblDsLmwtdShh7TI8ujY/H31JUehVwT4
         zbaQ==
X-Google-Smtp-Source: APXvYqxq75VICyIA1vT5UP2e06N1oVHwb0PX7bkc+F7+9NiaaTyuWWOp9etgrukRuGPGuDjKjiOg4kbrotM=
X-Received: by 2002:a0c:d2ae:: with SMTP id q43mr68355733qvh.96.1558620548425;
 Thu, 23 May 2019 07:09:08 -0700 (PDT)
Date: Thu, 23 May 2019 16:08:43 +0200
In-Reply-To: <20190523140844.132150-1-glider@google.com>
Message-Id: <20190523140844.132150-3-glider@google.com>
Mime-Version: 1.0
References: <20190523140844.132150-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v4 2/3] mm: init: report memory auto-initialization features
 at boot time
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, 
	James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>, Kostya Serebryany <kcc@google.com>, 
	Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Matthew Wilcox <willy@infradead.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Sandeep Patil <sspatil@android.com>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Print the currently enabled stack and heap initialization modes.

The possible options for stack are:
 - "all" for CONFIG_INIT_STACK_ALL;
 - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
 - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
 - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
 - "off" otherwise.

Depending on the values of init_on_alloc and init_on_free boottime
options we also report "heap alloc" and "heap free" as "on"/"off".

In the init_on_free mode initializing pages at boot time may take some
time, so print a notice about that as well.

Signed-off-by: Alexander Potapenko <glider@google.com>
Suggested-by: Kees Cook <keescook@chromium.org>
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
Cc: kernel-hardening@lists.openwall.com
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
---
 init/main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/init/main.c b/init/main.c
index 5a2c69b4d7b3..90f721c58e61 100644
--- a/init/main.c
+++ b/init/main.c
@@ -519,6 +519,29 @@ static inline void initcall_debug_enable(void)
 }
 #endif
 
+/* Report memory auto-initialization states for this boot. */
+void __init report_meminit(void)
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
+		pr_info("Clearing system memory may take some time...\n");
+}
+
 /*
  * Set up kernel memory allocators
  */
@@ -529,6 +552,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	report_meminit();
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();
-- 
2.21.0.1020.gf2820cf01a-goog

