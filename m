Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27A12C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5BE2208C3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:38:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QVUrmXjB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5BE2208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7111F6B000D; Wed, 29 May 2019 08:38:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C29F6B000E; Wed, 29 May 2019 08:38:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B18F6B0010; Wed, 29 May 2019 08:38:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35DA46B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 08:38:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 28so1802832qtw.5
        for <linux-mm@kvack.org>; Wed, 29 May 2019 05:38:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OTSVci+9HQFGuKiIh59lqpYGkMYL4TSES3kfTgmqHdU=;
        b=b7Z2YnGDWnJwOWGLcxxB2LHRCe5TQHof1pQenMkcfjJYZslQROkJps0rdaCMvb5On/
         ZROZt8y5SovcZYhQRi/yVBPOH51uNjpJjywmSRaecuZAKTyTztvBCIlLREmc+6FKdpXK
         MKytKrFLYl4dhebzEFby/Pbg7PASnRfqTp649gaUY2ShtyZhRUvVhDuhY8/Y3LvTpC1O
         yWqXf8n7ATAWb3Jp7krMLjDJ44G1zJerKtpTOOsCpKyY9uReqKhgi0hMNJ47r9VTkJ4M
         Ou1vbA3IiKzk6opm1yt6jr2KHDqeEUWApPAI+KwQs7ogHLXvTXaQ2hoTplE2hH4W0Qg4
         LYWw==
X-Gm-Message-State: APjAAAXlb/U3+iCn98o3i74N/N0GHr9BGCvDwJip5oGvKJ0zpgpjfK6d
	weaekG3Co6aug5FoTvqB+qiguYVwAJgcmrUNRqbRsk05fm4qD9t1OfPAQSU07PdRTNKvd5oWd8P
	8zNkBMEAu95mw8PUjdwDS7k8exjN4GsHkdQdSaFAKecShidkz9cJeVcpnxp8iNfAlUg==
X-Received: by 2002:aed:2383:: with SMTP id j3mr10796766qtc.313.1559133513985;
        Wed, 29 May 2019 05:38:33 -0700 (PDT)
X-Received: by 2002:aed:2383:: with SMTP id j3mr10796721qtc.313.1559133513393;
        Wed, 29 May 2019 05:38:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559133513; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2Qhe/Iz9pLRpsrUV0YZkL4P8cBeTP46RfqCVtQlCUDOHrVaOP+mEDJR95MdiLugCj
         RJxmnWhZ9ZdXdwsphQVJbSrRAtUk8bO369BoxSoKEKvflN9OvF2pYUQbU56kagv44BM3
         unbCwfIJv4jEiOlIZax6vJ0GyegiRjwI6+NF+JZaKL957/ySYzOfXhJlpCnWdu+iKnfR
         Ki+tdy/REUF2v60iYy7XDvld+1Cm48DJS4q6NElV9mdisdjXu0MoKdofzgzPozrq2aCN
         JAMjiGxzCaueJrVAlD2jigF/sCnuS4K+w0gnj99KmFqflSkTgdk5mVSv/ATx6V1Y5GQM
         OmHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OTSVci+9HQFGuKiIh59lqpYGkMYL4TSES3kfTgmqHdU=;
        b=HfVsj850a34o2Gjdk88TIcTEPs5ec/Mh/Jwat4nsAA03dRPBih6O3pbWdZHraCb1dK
         Y1a3Al1lfW/xP0vLZoLUTPjtKjC2bMTnlG13ahDKPOwIAqxWAYWwL/mUniRqLec4gD9j
         K/wBxIpss0EIkwOQwKtJCvfIJejZefO2X9RctbSgy1UrEMAxtCK+ZHFt/qfSs2Dxi9V8
         xt1+rJ4QsKxcCtXTREOKXWWQ6IgDbJBapHd9mbrGkoy0jHlYykyRJYugt8xTqqOutkBQ
         qmnvkUNFoGY4mOhn2fe9yWDys+hAFJo4OE/zmF3h0kWRGyY+H4fyvEshomZ1mVG/qfAf
         kqPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QVUrmXjB;
       spf=pass (google.com: domain of 3sx3uxaykcoosxupqdsaasxq.oayxuzgj-yywhmow.ads@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SX3uXAYKCOoSXUPQdSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m13sor8948553qkg.139.2019.05.29.05.38.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 05:38:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sx3uxaykcoosxupqdsaasxq.oayxuzgj-yywhmow.ads@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QVUrmXjB;
       spf=pass (google.com: domain of 3sx3uxaykcoosxupqdsaasxq.oayxuzgj-yywhmow.ads@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SX3uXAYKCOoSXUPQdSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OTSVci+9HQFGuKiIh59lqpYGkMYL4TSES3kfTgmqHdU=;
        b=QVUrmXjBtd4xAGA041VU9vn2Wo24J0G/ryDcfbSzyIaXXA9eT1e/5dNi0QJEzMBCWq
         fN3WkgM5gqMR9l0iwxBy9vH+tbNaCYmzc3eMgJngHj1kSa5AtgjWh5+5HjO/QfCZpvY6
         Jb+OfcJFPlWhCrVMcT9BX7VIzn5XFynOaCCkftBB3mbVd1JQuJaHm0m7kyXHACmQ9cgW
         9zAnA35gH0p0YX9UacAq6LYdKrQ3NUIsIStqgl+m5S9sxABy/LK6SgMc6qA6s4YfiEYT
         SjwPmB5DRuLJ/T8J4jYw4vuR8yqEzw06eiiDOGT9MuQeYfiVfkXQYF9mVBXb/uZL2taU
         nQYA==
X-Google-Smtp-Source: APXvYqyuj6WNrP123438HFtnTx32oR/o63x7jglpOtKNMGuuQ+g2SgRyW1Nxym/uXkKBa07I2QYAnrLim8k=
X-Received: by 2002:a05:620a:141a:: with SMTP id d26mr6791202qkj.32.1559133513103;
 Wed, 29 May 2019 05:38:33 -0700 (PDT)
Date: Wed, 29 May 2019 14:38:11 +0200
In-Reply-To: <20190529123812.43089-1-glider@google.com>
Message-Id: <20190529123812.43089-3-glider@google.com>
Mime-Version: 1.0
References: <20190529123812.43089-1-glider@google.com>
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
Subject: [PATCH v5 2/3] mm: init: report memory auto-initialization features
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
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
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
Cc: Marco Elver <elver@google.com>
Cc: kernel-hardening@lists.openwall.com
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
---
 init/main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/init/main.c b/init/main.c
index 66a196c5e4c3..9d63ff1d48f3 100644
--- a/init/main.c
+++ b/init/main.c
@@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
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
@@ -530,6 +553,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	report_meminit();
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();
-- 
2.22.0.rc1.257.g3120a18244-goog

