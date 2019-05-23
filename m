Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9368FC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4651F21019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kwxaN5TX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4651F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE60D6B0007; Thu, 23 May 2019 08:42:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D482D6B0008; Thu, 23 May 2019 08:42:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEAFE6B000A; Thu, 23 May 2019 08:42:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91A016B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:42:36 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id h22so1318411vso.18
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:42:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=Xxkahhr7yBFrS/BLPo5kRQLDXLIZyZVBbNQFJ86X/pwway+ct+3E7fOHtPfRNcHAwp
         2Ry/EzJLF05cwIMYzRX9NVffyjDKdLHmfdkBdbO9oh8ClR1frmoZUE/Bd4VyLrpPt58x
         DpQpeVEGi6I9QbGoSfghp9SSKb4lLJOT/Zf1qV59Q2+eVAq2FEK+I7yXrg+KAb9Gzg01
         1zXzmJG2MLUJencgJ99R2wHg4C3a5M5O9FDiKG2kg+cE7N20X0JAZxM6WHLFaB4KWZe3
         gfzWc4rmrp6tzi0+OC5PU1jxsFRNnoaalzXxVWarQZ/JJzeS6wKpt+cxkEFuvLPzPg/C
         zFkA==
X-Gm-Message-State: APjAAAW9oBMDoHKhob/d1yxMqL9Gm9kZDQc1va9kud/qpjVZjHvc+9w5
	u4nk2aMCgk2OxsdnRaGKWzx5N9Jmh6TDWWxVrnouixBg5TDsE2i4fI7N/7fiivB3APfprMaI3Eu
	iwNCTXdc34eGGkTOCvCYRUfj1m1Eu76gJcOQT5khksPtnyUj5czC8PQiZmLnb+ZzJRw==
X-Received: by 2002:a67:8e01:: with SMTP id q1mr673322vsd.1.1558615356170;
        Thu, 23 May 2019 05:42:36 -0700 (PDT)
X-Received: by 2002:a67:8e01:: with SMTP id q1mr673301vsd.1.1558615355585;
        Thu, 23 May 2019 05:42:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615355; cv=none;
        d=google.com; s=arc-20160816;
        b=fubk4oSEotanEg5IXw8/l4He3/+CUIMscTxnNOjHPSuhiI8NC2aM4e7myTbLQBiElt
         UeJ2ecUnvnzKtBDCqD6hPpE90+pBcJO6ylCF0R8iXIxvTg5AQRhr3292A7usoIIkwOtX
         kCAJjBu1M/YMzva1suiyXeEn5kJx3YGhCuzNj2AVqWBc6bksFx9zBBglcPxJvdr3TVLb
         hJogEky2fSMztvv9cpB9xImOgQ/VnzCKuUZWN8b/keBB5PVZjZLOcE5SLV/bDDrq7nKg
         1BpDE9KjJQJFkyRooR0ni2rZ3fOKxTCEuqtLa41Et98FGGW8ZzVXjI/rzsaoBuFh8ONQ
         8NCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=es2PV5gH5wYRePwTuj5sFjdOSmH2k8vqzoRkwk4OhBIz/LkYJgQxo57pcgoWTS2+sD
         OnHchJkKl7J1iWM8znzMqy1pr555O0GVufcQrQO6LGyAnEpKGqynO4Vrl8V14y/woEAA
         96NUwlHx0Xyszr2ZCsstSuQkN0NxXZb2raeW63dVe151uC/rIjO5JuF63sTL2FaFFb1z
         UlPH+Uo6ehJ5TP6JG36+G62c5qM939Wfnl0ZiRb74Sj5GrZAoj/9F1EfOdM/Wkztddjh
         UHJsYiwebiRSSjv4bBkwOd+6WVPgusKGncAOfGZX+GQ5HS/folKRAtNAbCWu4Mul68Oo
         hrmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kwxaN5TX;
       spf=pass (google.com: domain of 3o5xmxaykcowuzwrsfuccuzs.qcazwbil-aayjoqy.cfu@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O5XmXAYKCOwUZWRSfUccUZS.QcaZWbil-aaYjOQY.cfU@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x4sor8833929vkg.36.2019.05.23.05.42.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 05:42:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3o5xmxaykcowuzwrsfuccuzs.qcazwbil-aayjoqy.cfu@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kwxaN5TX;
       spf=pass (google.com: domain of 3o5xmxaykcowuzwrsfuccuzs.qcazwbil-aayjoqy.cfu@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O5XmXAYKCOwUZWRSfUccUZS.QcaZWbil-aaYjOQY.cfU@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=NCAxoLMPldvKQMidzNTr8hyOEHq1jSHIcOt+CxAESVs=;
        b=kwxaN5TXi2fzUmuexBBY0GXWxXPKI1jjIZBR+Z9tiHoEQ/9ujAqPr7MVyXRNhvSd9+
         AK6kCkOhJm5SbE0jSM+BNskxXce/VCkWz+Q+nhHVzGM9EiVIxQWQw6xGFRwc293n6pL6
         UjuOZc6NpSLuxS9lgkZ9YHgOqEJdb30RHbq5NVEGKZ2RrMvsO8eGym5LjADg9LCNz+Mj
         M2xn9+Ia0uIgVsD4bzKVJvdYZBbu08DtKLv/k2Kp238pWpoARR/ey5wwSaCTCcg+zg5u
         IdrKv4BJiVUrPXZyjmF08n8tXNbuPmuj2yNUQwZ+XjwO6HLAiarXc1mbTJcvhpLSEk3Y
         /qnA==
X-Google-Smtp-Source: APXvYqyogFkZZsLOf7+neUZRBCYC8MGU1KnLcLqehoJt4hw5P+8oApijqvC8NaJniUHj65EbWsPUM/NXYM8=
X-Received: by 2002:a1f:944d:: with SMTP id w74mr1575300vkd.38.1558615355140;
 Thu, 23 May 2019 05:42:35 -0700 (PDT)
Date: Thu, 23 May 2019 14:42:15 +0200
In-Reply-To: <20190523124216.40208-1-glider@google.com>
Message-Id: <20190523124216.40208-3-glider@google.com>
Mime-Version: 1.0
References: <20190523124216.40208-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 2/3] mm: init: report memory auto-initialization features at
 boot time
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

