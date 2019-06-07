Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7BAAC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:07:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F8D208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:07:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gBrTD1yw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F8D208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDD8A6B0266; Fri,  7 Jun 2019 03:07:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3C26B0269; Fri,  7 Jun 2019 03:07:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA1F46B026B; Fri,  7 Jun 2019 03:07:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95F526B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:07:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k23so827020pgh.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:07:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3xG2gB2u3ltC4ECXHzkfqk/Rf8Lzs9XYnPxSdw9Djq4=;
        b=Q/6I7yH8x+iTy/HyzPUASgcd/kJ8p+YdpLohkUOmD7DKUx4VGrGagsRJQ/x6n21YqP
         hk6p7GvPFOmDBURoO4u8AzbEL47zKhnvAlrfICUF39Amo1xdgiQV/AvhJ19RBw3LyMxA
         6mLzs9Tr5VV2yUUx1GHf0rXFPGHxzuZI3f55CnxGd271aS48e2/KiCHhu5/KZ/dWYeKN
         RxeFWrBPBhXh5/S4Td+YEYYgb7lQZnkS7SjUvY5f/9Eh6e1W0VhHiy8jxlWYfvkhXQbW
         hx6gEFbekWmPMKqkHUL2RH6pLSzITq4JXIRJ6ZR4ggG6GEIlFF74jV+Enhho1Pfhgpmi
         eerA==
X-Gm-Message-State: APjAAAUEhZTVqwEh1hJJERf5b1NVybtP8ks4Z1Pz+JwtbU26wqHCKvR6
	SnsHQfv+fStWv3BZvUkOvy+nKDiC+GfcX+2DYkz5nzefk9htQ0Zo/Vg8xE5MHAGyzGhjharyPE6
	CKJ+7XSBThJvUF8xV4/Xqm2j+bwPYBAHtozWUB/uaClldoUrzK+nQjph12tuLhpoMrQ==
X-Received: by 2002:a17:90a:ad8b:: with SMTP id s11mr3956320pjq.48.1559891262232;
        Fri, 07 Jun 2019 00:07:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuYfs5Cin7KTmfgs9hAQ03fax/Hdiz63VuN7PEBiFMpGtTWjDCAUzQzUMGTserz6dptven
X-Received: by 2002:a17:90a:ad8b:: with SMTP id s11mr3956256pjq.48.1559891261190;
        Fri, 07 Jun 2019 00:07:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559891261; cv=none;
        d=google.com; s=arc-20160816;
        b=j3YHYhagtVNR3U8ikAfzoL7iXK9Z/QXADHaf9MbcxuvPzEjH4BgB+T8m4682KV9gOg
         r4mT9yd19BnghaKwklEKBfLATxwUR0A9KuTje959UzmDz+CzlUk0/s0VG6+DJ33h4Is9
         7O21H0ARVp+1u/cM/MVvkUbAANIJYLr0zHQTLiYl/dhpjommwijbNGjdo2YWOIPTUexu
         5aBDKwwAxehjR0LPdFMKkMxCpmaPuRa7+MhvPxpcyRxPoe54v9YVfhKtdl/Muq0i3n2d
         lXkwLiUSa2JLufBrn9RoHTgqzVGRS+Mpcri91WqWMjfLr44AMLLyZZe3kgqjhsi2JQ0w
         JCMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3xG2gB2u3ltC4ECXHzkfqk/Rf8Lzs9XYnPxSdw9Djq4=;
        b=JV7Y5dxzQMekyG9M2Z9aCZNM6sDJ4UZypCUqQ2QQI40Xv62buo20++Al3v5s4ZhaLk
         Q8nWhxV3HtD1mQLnAJOCuNBkML0EwWjvJSoRet2Dna8hmeDQo61AmHKvhtZCy8n0h/BD
         dZNCv3bzawbzFYzqNiCMDxMHA/gAX/4pVyh8WVweHJ/R/R3lZK0DCmv6mDLa60BN40Ni
         zxWtySNAlmSdlfFrex/SRomyVPcJbRhEJ5Nz35uAOLTxNxPQNn6f1TFdKTg0DWEGBY/g
         JSkk9pDQbSXSxX4l5vYgirRD6G3Qe2Bnn/6XH/2oA4cSpZHa2Qkhv425CuwtT+SKplRQ
         tvBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gBrTD1yw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s6si1095983plr.112.2019.06.07.00.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 00:07:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gBrTD1yw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3xG2gB2u3ltC4ECXHzkfqk/Rf8Lzs9XYnPxSdw9Djq4=; b=gBrTD1ywQqnghTyPb+u8oUuO1
	n92Hi8a/rdgmVIhQ/moKpSzpN7IRYERjWycGLMqob6ui4vuJ0Lrag517vzAbE44qxJdkCSgxPKLT1
	TPDM9DMcOeTrROrwysz2WUqaSu0h22M6pU9hi1I9cmfvloI+w1dJxzU3J6rnF+OWy4rCb0aDGY2of
	b8kFhR/J3YJz62PeRqL2pk7arp5DAGDnFJX9NMH/Cj3Y2VoHWyDyUjEx/zl3iOjcEreXchO/Uxps0
	vF2ga+x78jDgquKaiphXwBrUEmKnjdaG5QpFvxY68BuCmEZlEwI1DNDpMN8q58R1DKQ6b2F5Av84v
	oC93ptfaw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ8yG-00069g-2e; Fri, 07 Jun 2019 07:07:28 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7C8E4202CD6B2; Fri,  7 Jun 2019 09:07:25 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:07:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 05/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Message-ID: <20190607070725.GN3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-6-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200646.3951-6-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:06:24PM -0700, Yu-cheng Yu wrote:
> Intel Control-flow Enforcement Technology (CET) introduces the
> following MSRs.
> 
>     MSR_IA32_U_CET (user-mode CET settings),
>     MSR_IA32_PL3_SSP (user-mode shadow stack),
>     MSR_IA32_PL0_SSP (kernel-mode shadow stack),
>     MSR_IA32_PL1_SSP (Privilege Level 1 shadow stack),
>     MSR_IA32_PL2_SSP (Privilege Level 2 shadow stack).
> 
> Introduce them into XSAVES system states.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/types.h            | 22 +++++++++++++++++++++
>  arch/x86/include/asm/fpu/xstate.h           |  4 +++-
>  arch/x86/include/uapi/asm/processor-flags.h |  2 ++
>  arch/x86/kernel/fpu/xstate.c                | 10 ++++++++++
>  4 files changed, 37 insertions(+), 1 deletion(-)

And yet, no changes to msr-index.h !?

