Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60A19C04AAF
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13FCE206BF
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:26:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ASs9/AsK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13FCE206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F1446B0005; Thu, 16 May 2019 20:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A18F6B0006; Thu, 16 May 2019 20:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 891266B0007; Thu, 16 May 2019 20:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50BB36B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 20:26:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s8so3207575pgk.0
        for <linux-mm@kvack.org>; Thu, 16 May 2019 17:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=ilDv0+YTa/WnY3XhZH80fN4U1WpmetjpQlVMabTh6tw=;
        b=GStyDa83CNPK4T7hQ6mS5AVNc7PgEVMhKt/S20eag9Ef3fvJNVG2HneNoNWuhnnjs9
         dCYKpNWmbLvRVwn2Ta2Us8im97xKl6rGRyPfZEKhDek07qw1aMxil48fAMKi3gWpKbXo
         cB71RH7o8KSQVJwgRgYPSigUO3rGQctaZek9OiG9pWRLQHOh19/KR1ZDFTu5vW8v46ib
         NSyjE9+KwhoinWhgcQU0ft1WQoaVDOWplcPKeRlTqzqRUr9orOvg1RxSUb/+CMGA7/mc
         4BSAgBenMqMcvVnSFOFb2ww+4XPwCEXjReNuMDcHrrkvhQxY1dkDCRqJ5KBDpPJ+sjgR
         TXfg==
X-Gm-Message-State: APjAAAWy+iVJXkpvI+Y+v+CtLSR8GsQRwixhXVHf7Mtf6zjc1UJj/n0l
	BwrPPomrwLTmpQB1iTVUoz/RbsbzfsPVYyGuCtV1Rwqcgcn0ujDF+sQF2ZWuykNUMq2sGSmk8PE
	u6axpGT+lxNTANuhgxdygAIwjGgL+rY7TXD/4GXKlQ5zRB9+MwOKVkwgO+JnL6gNH+g==
X-Received: by 2002:a17:902:2ba8:: with SMTP id l37mr32853138plb.229.1558052773790;
        Thu, 16 May 2019 17:26:13 -0700 (PDT)
X-Received: by 2002:a17:902:2ba8:: with SMTP id l37mr32853081plb.229.1558052772904;
        Thu, 16 May 2019 17:26:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558052772; cv=none;
        d=google.com; s=arc-20160816;
        b=botbJJTOHdu/YjgPSxCMOZp+rJpz6i9BCTcaEHyZihS2xAsZ6yPpQchNHCFjFGy0Yi
         TEVRBDbqguBQi07zX0t2yFk+mrNv7suPVpA5FwrCrNhRKMthdRbpcZJkEcor6A4W5CJ7
         rTZvk6k/An3SOhbgHuOm/nYlXd7f7gIKXKdpAH+VY547Zdr+3eqWRjVuU1/gEGEf1spn
         yCAbKogySMZhaRksjk6W+CGJN46lIeqtbDucshGrvle74m+Ad1U9Oc8kw3dB6f+HEHJv
         qGTuRUrGgguPXF6dWTATOunzllT/MiO2Q3vvT/Gp5j2tc3wMQAFV9/RHGPo/cSI5J9rf
         HK3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=ilDv0+YTa/WnY3XhZH80fN4U1WpmetjpQlVMabTh6tw=;
        b=mOqvBnboItbbVeWAZHJT057pZjeGVpO1atG1CVQd5p1M09s5FP80nK/Nk3FJrPjaTE
         +FCjrNN0pDttTcExz2gpBSI4ynu4qKzx+fSmyOoUtR4i8gdgXFoGmEpNdp5TaC320X4F
         RXsamhFQMfgJftoYXYwFbVJS9hU/pufnlBprxYgDcDxFFarwA0M1SfZ4lmj7ZFGvzb1V
         OWXqrLHqXDILsxmAHJRF4W/TxipsdxVKayU0RrMpBRV2hFiqwwLzEmOm0sWlIqw73V8s
         GyM4TRw1w8kNr9FWbMGufsflMLBuNiCc3YkYD4WhkyWWpc29EDqPNU2PRydD/gIv1UkB
         QpSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="ASs9/AsK";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor6928291pgg.5.2019.05.16.17.26.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 17:26:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="ASs9/AsK";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=ilDv0+YTa/WnY3XhZH80fN4U1WpmetjpQlVMabTh6tw=;
        b=ASs9/AsKmgukkUd8ZkGKrmFLrJLHhcmjh9zttsNZWu9UiLxwGqq+jTPLZfvADEE6BT
         0wo7n9b7ck3n1cRmgHDKeiMzhg+VhnE8FHKem/W4KuR+HtEfYDi+njtYVyXvv+cb4FKI
         TheGLDDVwvh9uyy0Qq5Jox9zPBUe3teBFpXhw=
X-Google-Smtp-Source: APXvYqwlMKqnUliknBdwEvFPxguLJNac2aseYZx+RJq6e02esXvj8m81/U384KtDWip6FxOC9kYkMg==
X-Received: by 2002:a63:ef56:: with SMTP id c22mr2023348pgk.13.1558052772428;
        Thu, 16 May 2019 17:26:12 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id r64sm14143496pfa.25.2019.05.16.17.26.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 17:26:11 -0700 (PDT)
Date: Thu, 16 May 2019 17:26:09 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff
 allocations
Message-ID: <201905161714.A53D472D9@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-5-glider@google.com>
 <201905160923.BD3E530EFC@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905160923.BD3E530EFC@keescook>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 09:53:01AM -0700, Kees Cook wrote:
> On Tue, May 14, 2019 at 04:35:37PM +0200, Alexander Potapenko wrote:
> > Add sock_alloc_send_pskb_noinit(), which is similar to
> > sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
> > This helps reduce the slowdown on hackbench in the init_on_alloc mode
> > from 6.84% to 3.45%.
> 
> Out of curiosity, why the creation of the new function over adding a
> gfp flag argument to sock_alloc_send_pskb() and updating callers? (There
> are only 6 callers, and this change already updates 2 of those.)
> 
> > Slowdown for the initialization features compared to init_on_free=0,
> > init_on_alloc=0:
> > 
> > hackbench, init_on_free=1:  +7.71% sys time (st.err 0.45%)
> > hackbench, init_on_alloc=1: +3.45% sys time (st.err 0.86%)

So I've run some of my own wall-clock timings of kernel builds (which
should be an pretty big "worst case" situation, and I see much smaller
performance changes:

everything off
	Run times: 289.18 288.61 289.66 287.71 287.67
	Min: 287.67 Max: 289.66 Mean: 288.57 Std Dev: 0.79
		baseline

init_on_alloc=1
	Run times: 289.72 286.95 287.87 287.34 287.35
	Min: 286.95 Max: 289.72 Mean: 287.85 Std Dev: 0.98
		0.25% faster (within the std dev noise)

init_on_free=1
	Run times: 303.26 301.44 301.19 301.55 301.39
	Min: 301.19 Max: 303.26 Mean: 301.77 Std Dev: 0.75
		4.57% slower

init_on_free=1 with the PAX_MEMORY_SANITIZE slabs excluded:
	Run times: 299.19 299.85 298.95 298.23 298.64
	Min: 298.23 Max: 299.85 Mean: 298.97 Std Dev: 0.55
		3.60% slower

So the tuning certainly improved things by 1%. My perf numbers don't
show the 24% hit you were seeing at all, though.

> In the commit log it might be worth mentioning that this is only
> changing the init_on_alloc case (in case it's not already obvious to
> folks). Perhaps there needs to be a split of __GFP_NO_AUTOINIT into
> __GFP_NO_AUTO_ALLOC_INIT and __GFP_NO_AUTO_FREE_INIT? Right now
> __GFP_NO_AUTOINIT is only checked for init_on_alloc:

I was obviously crazy here. :) GFP isn't present for free(), but a SLAB
flag works (as was done in PAX_MEMORY_SANITIZE). I'll send the patch I
used for the above timing test.

-- 
Kees Cook

