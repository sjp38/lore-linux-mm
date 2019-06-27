Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEB79C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:03:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83E812053B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:03:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t+pfh+q2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83E812053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 333988E0009; Thu, 27 Jun 2019 09:03:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BD2F8E0002; Thu, 27 Jun 2019 09:03:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15F468E0009; Thu, 27 Jun 2019 09:03:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDBCE8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:03:35 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id x140so688380vsc.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:03:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=OCF23Pr17AXTF5/a5RkM1HLEq8IFK29XZ/7ie+p3H9rFn6Trupt5HlVTqcNymJDTPI
         A3DrwT4dNwEkOYFFYYgSQ5AJ9y7NXxiJFhYK9wthISoU/t1HxbGs1XnboI/yTdY18ahj
         KPsymX2iE3xm8FPaLDTgVYkNGqOLJgGp5iSSo/OlCefmWVyfJ1jZ6nKg//myyTscqgsU
         3ekdClc7cLuUX9Y//6sG4zC8Fj79JMxjlEDyruOqaHq9SpD9/ZgCDc2FY1tQV/d5Luwx
         p83OuxHRxS5P0PNDK+RKiHODs34JY7pukCsw5uwUTaRUxNAGWZmiIa1GuEVnit6ZBPIX
         8RMQ==
X-Gm-Message-State: APjAAAV5e/eqQzYjClCilmf4L5b+WYpcpopNr+G5+lANZ4a0IzN3wP3a
	v6gFUDCDO2lobdtdCotmBlbAMEPxuAmZLmoXO9ApunZOxArrwhZlpOetQLcggL58pds9LkFEj9c
	kQchFhVPkjgFHdaBxuJu8gVYFdRJMwHWwwbdr8PvSt+WLM9v67+UI9+MJwR+6S4P/MQ==
X-Received: by 2002:a67:8ec6:: with SMTP id q189mr2398989vsd.43.1561640615427;
        Thu, 27 Jun 2019 06:03:35 -0700 (PDT)
X-Received: by 2002:a67:8ec6:: with SMTP id q189mr2398856vsd.43.1561640613097;
        Thu, 27 Jun 2019 06:03:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561640613; cv=none;
        d=google.com; s=arc-20160816;
        b=CZVy8ikLE4hehos58+SeaQ7v2JHaX8RZTfO9i1lK8If3A7/1UC3wfqIT360RBHMqt4
         h1ZqiYbveoOCjVTNIjXdON7k1Ig+0OEHXT0A4jKTPjf+OfKYNbYzBCSW1cqzQJ1t1Lsh
         ttX1eh8TDSGNlfkCwemSqmjvcELafUEq5CGPf8ZD9mpXK/S2Ghui1s0zy5hIjCGClivl
         R1Xh8dLqgrxGTbZagUJgRqeWytufIYu091/cuCjW7/HA2vOaoR67dDnWzNQS8s4rHB8T
         Uf7SLRSmyIV8cXYMNxThX7acgEy9wGO+imIqmD52/4Pz1eWrUyfs4nrBxcWgsFSaUAkf
         t0iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=kbb2wMCI5LDp/i+RBKorIR5yWr8tKIzl4z+CLC5izX2W+kkWhwJfYMiJJT3D+xlR0j
         OInzNuL0i9UjSnPzSAa8s/UTT4xILARCL3AtQrcBOsdruLtdLAtzgh4mvr1Jy/sZ8alM
         fmfxizPztb3awCwgxh8+iY/VyqFalHSAhs2w5A2bSNv1uBj8r7YBpVc8GTKraLC9aJ9y
         944T4pT7d20Qvl2DsZeybzNaSy1/LYQgesW0Xw2oBAuLrfOkI0QimSvrvDxqmqtqP+da
         m3/5bpgRWJNj3c4VXZAv56rSig8ivbgpf6Y8Jgd4KvaPCO3Uq5CjkxoUwHh+JZudrVY3
         aswg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t+pfh+q2;
       spf=pass (google.com: domain of 3pl4uxqykcgmhmjefshpphmf.dpnmjovy-nnlwbdl.psh@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pL4UXQYKCGMHMJEFSHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m185sor1041784vsd.100.2019.06.27.06.03.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 06:03:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pl4uxqykcgmhmjefshpphmf.dpnmjovy-nnlwbdl.psh@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t+pfh+q2;
       spf=pass (google.com: domain of 3pl4uxqykcgmhmjefshpphmf.dpnmjovy-nnlwbdl.psh@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pL4UXQYKCGMHMJEFSHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=t+pfh+q2u5DSP6mSeIK1r67ErcoQ4NQ8UsM5O9mGBYMiMCyv5PvcnnHkKNL/S8BSql
         eOA0/MWF7e5MR4sM/kFj2EDJhvTYzaDf++QwCyebCHUw/KNaIzSHf5WKn4Dt6RpqL+ql
         DmRJwW/0Je2MaVg41STn0p9q/VP9o0K/qRm0CtcgkzfRUbMccg2EyCxV0U/JM9UsEnlO
         g62cz0FUurVCddNaeP0ka5lwPT55dY+FEab2GfRuP0XKPq/hulqwOgsctIchPeVNa1M3
         ZUJnDFJoRj5ZCGnNG2BOWe67YpXjddedZW0akWlAupL03a82Bk0h6zX7lm6X6NrlCOXf
         4+1A==
X-Google-Smtp-Source: APXvYqzHT3CTIJYzDrs0X3XZhQ1nNpPSVhzaXrDUP0P/c7kcHUZJG8WqtMpRqCMlOADbxQ/YidQWVk8aekg=
X-Received: by 2002:a67:bb18:: with SMTP id m24mr1257345vsn.201.1561640612036;
 Thu, 27 Jun 2019 06:03:32 -0700 (PDT)
Date: Thu, 27 Jun 2019 15:03:16 +0200
In-Reply-To: <20190627130316.254309-1-glider@google.com>
Message-Id: <20190627130316.254309-3-glider@google.com>
Mime-Version: 1.0
References: <20190627130316.254309-1-glider@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v9 2/2] mm: init: report memory auto-initialization features
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
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

---
 v6:
 - update patch description, fixed message about clearing memory
 v7:
 - rebase the patch, add the Acked-by: tag;
 - more description updates as suggested by Kees;
 - make report_meminit() static.
 v8:
 - added the Signed-off-by: tag
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

