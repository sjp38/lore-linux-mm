Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86D2AC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F9AC2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:34:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="GJB5bsI3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F9AC2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFB4B6B000E; Fri,  7 Jun 2019 11:34:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAAAF6B0266; Fri,  7 Jun 2019 11:34:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFD176B0269; Fri,  7 Jun 2019 11:34:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7262D6B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 11:34:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so1616626pls.1
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 08:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=KfsubRPhiyKBXFr1tZvtiO/czPIi+jUPbPm10i13Y5g=;
        b=haGDsd8VqqN+PhJrO5x0p5viQ387OiPK85S24ZqzD1E5p6lZDxx50fi3/aNLoj/knA
         9RBTKcUcYn+ePcqnQVX2kpKybusIBguihCKYk5uIiLXIpLHks14zsyS+4Hz0twUV+x8h
         L/TYxwxfUa1NGMomfOEYkAUo7ItiwWhi7M+FpD68d1SNRwy/thfsSlkIsytrn9YtqM4x
         jxOWi3aqPYIzaGzkWMA8UvyUVDUdhWpz7PkmmRpAxM16abFL6pHw1DQkb3MDXWHewNxI
         1lmNWNDEUxWfNN2jGavOyRQzSBn9nNfXg0iV6ogFar+ZP5CLV5RUo++sdEIOzBVDSvFA
         Hp5A==
X-Gm-Message-State: APjAAAUCzFAfs9ztqpuKDCtmNBdLDWDn8O7VYPD4r3TBraCJ6clXULRF
	UylZapzCMVFppIf2tnMbsZ2cTIt45qS8KeCf4xYaR7vL02hbFGdnjnMi3wdIAJ4H+CidGHJSz/9
	CG/p4wo4q4wO4Xayj+scTPsSiCs0lBiYJ1N3VHQU0DBxz8icKItVaS+tfWOPUOQUe/g==
X-Received: by 2002:a63:5024:: with SMTP id e36mr3461996pgb.220.1559921698000;
        Fri, 07 Jun 2019 08:34:58 -0700 (PDT)
X-Received: by 2002:a63:5024:: with SMTP id e36mr3461887pgb.220.1559921697008;
        Fri, 07 Jun 2019 08:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559921697; cv=none;
        d=google.com; s=arc-20160816;
        b=sv56QHd96JLZdOK65uE/i2yeF0vJYToODWmLZnDtNwf8zMUtUJ0WoYSC0HotH6TXp6
         i/2ISzPcF8P0QW3QBpMJ6srKsngQwRyfOd8c1TlOyFnPlOnBH6brDtPj3ngY8lX81ROY
         QKJn74OVqkC7g2GRDZ6iSTrxXRwOHxVmzappfEBVP1r0j87B5a+xR48unYT8DCDC+Ev8
         +KGvS3J2sfqjvTRXynN+1xxDi6fqGgqzWiVqPvuG5ytMP5e4299IiUYp433rkvxQHotr
         1z0AiRnDC8za/zaNeJrngy0ojd8yuoqP1qOuRyDjepjSq3TtjgoOu7n0qelVEqgm7wgZ
         W8jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=KfsubRPhiyKBXFr1tZvtiO/czPIi+jUPbPm10i13Y5g=;
        b=SEQ3HDcSP84rCKG61mMNsTbOvnfSCTk1LfpWRzOnUjQAHCeGse/0Hwx58pQot97QHo
         Ore7/KItSje7FSq6ni8wT5+jFkBmAheJAiH4Q7ZXDfaVDu9tE0wE2Z/90DRZ5DMfvJlP
         JCiSyTB1zrcGtaCGwrqla2GJ/BVPipKZs7FUE+uooAM5P2dD0UQHIxrl26iLTNgh/nsU
         8phcbqHo2nT2J+c2feks1G7dsvB4kKfZShNrLsha219P2c4SG08aqkLjJVyZzoHNTNl6
         YKb4dVmXyBsAQSgfj4UsZoyEHo2IoVKXys3sG9obpGqUaLEE0VJeDjW6e4iQ7cefdm+g
         yJIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GJB5bsI3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor2173321pgs.32.2019.06.07.08.34.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 08:34:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GJB5bsI3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=KfsubRPhiyKBXFr1tZvtiO/czPIi+jUPbPm10i13Y5g=;
        b=GJB5bsI3qmo9VsdAbqA/U+U5Ba57SSzH5rgLLx9qAGERoHL+KwRa0xOm2zhZbkPdwE
         Rs5IiU+m+yotBhVrT/8BxUFHdukj0LELAt2c4gm9wycVNeo72sTiQ+EBRHAfP/UvL1h7
         Xkq2rZTAhzCRADZtQaiZ2neu2LGMv+agKeapY=
X-Google-Smtp-Source: APXvYqwMPVOr9kcYblLhVYRdwJwRq6N4UsAMHzOFfp9A95scFiuSqPvBYn3TQCVYvQqEcz8eubkISA==
X-Received: by 2002:a63:2109:: with SMTP id h9mr3320579pgh.51.1559921696599;
        Fri, 07 Jun 2019 08:34:56 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id r77sm3215811pgr.93.2019.06.07.08.34.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 08:34:55 -0700 (PDT)
Date: Fri, 7 Jun 2019 08:34:54 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Laura Abbott <labbott@redhat.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Matthew Wilcox <willy@infradead.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Sandeep Patil <sspatil@android.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Marco Elver <elver@google.com>,
	Kaiwan N Billimoria <kaiwan@kaiwantech.com>,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v6 2/3] mm: init: report memory auto-initialization
 features at boot time
Message-ID: <201906070822.CEF77C844E@keescook>
References: <20190606164845.179427-1-glider@google.com>
 <20190606164845.179427-3-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606164845.179427-3-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 06:48:44PM +0200, Alexander Potapenko wrote:
> Print the currently enabled stack and heap initialization modes.
> 
> Stack initialization is enabled by a config flag, while heap
> initialization is configured at boot time with defaults being set
> in the config. It's more convenient for the user to have all information
> about these hardening measures in one place.

Perhaps for clarity, add this to the end of the sentence:

"... at boot, so the user can reason about the expected behavior of
the running system."

> The possible options for stack are:
>  - "all" for CONFIG_INIT_STACK_ALL;
>  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
>  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
>  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
>  - "off" otherwise.
> 
> Depending on the values of init_on_alloc and init_on_free boottime
> options we also report "heap alloc" and "heap free" as "on"/"off".
> 
> In the init_on_free mode initializing pages at boot time may take some
> time, so print a notice about that as well.

Perhaps give an example too:


This depends on how much memory is installed, the memory bandwidth, etc.
On a relatively modern x86 system, it takes about 0.75s/GB to wipe all
memory:

[    0.418722] mem auto-init: stack:byref_all, heap alloc:off, heap free:on
[    0.419765] mem auto-init: clearing system memory may take some time...
[   12.376605] Memory: 16408564K/16776672K available (14339K kernel code, 1397K rwdata, 3756K rodata, 1636K init, 11460K bss, 368108K reserved, 0K cma-reserved)



More notes below...

> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Suggested-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: James Morris <jmorris@namei.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
> Cc: kernel-hardening@lists.openwall.com
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> ---
>  v6:
>  - update patch description, fixed message about clearing memory
> ---
>  init/main.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/init/main.c b/init/main.c
> index 66a196c5e4c3..e68ef1f181f9 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
>  }
>  #endif
>  
> +/* Report memory auto-initialization states for this boot. */
> +void __init report_meminit(void)

Sorry I missed this before: it should be a static function.

> +{
> +	const char *stack;
> +
> +	if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
> +		stack = "all";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
> +		stack = "byref_all";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
> +		stack = "byref";
> +	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
> +		stack = "__user";
> +	else
> +		stack = "off";
> +
> +	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
> +		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
> +		want_init_on_free() ? "on" : "off");
> +	if (want_init_on_free())
> +		pr_info("mem auto-init: clearing system memory may take some time...\n");
> +}
> +
>  /*
>   * Set up kernel memory allocators
>   */
> @@ -530,6 +553,7 @@ static void __init mm_init(void)
>  	 * bigger than MAX_ORDER unless SPARSEMEM.
>  	 */
>  	page_ext_init_flatmem();
> +	report_meminit();
>  	mem_init();
>  	kmem_cache_init();
>  	pgtable_init();
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

But other than that:

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook

