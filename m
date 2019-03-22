Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F05EC10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B50AA21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Zbt4AiAW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50AA21900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 462536B000A; Fri, 22 Mar 2019 09:21:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40E556B000C; Fri, 22 Mar 2019 09:21:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B13B6B000D; Fri, 22 Mar 2019 09:21:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E23A36B000A
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:21:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v16so2332815pfn.11
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:21:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hw3ZtZSh4y78LcwFC7knlBZdOdzIfUNtqXkI2P++IvI=;
        b=lbA/nvkpwJBz6/JCpbRJOYqvx7A0uREXWGOl757It98fVLT0gUarit4riq9lUJsgIJ
         cjxutOOq1xrinS9v+L2jbE6MPHnWrhgilBFIyFjA1QBXSVc3rOvzseDkvAi14LIE6LHL
         +QawE8jTLtGYomA/FcQvlgdIpFVLAAEmR0C7BfsVoQQnU3MtxREyrlLBHxnI7dNmz9SJ
         SY5VMsr9N2ZuLWgIzIGpJ//X3Vf+y3Q9fYahF8QgyzzfYpGoTm1LsTVgw2DduD3Ytazj
         /JjTVBGqicV8JjjsGXdsI8rZDr+aPY4HOC+gRTFRHRfEnzmh65JNSFc2fa8acp8ePVOT
         hGBA==
X-Gm-Message-State: APjAAAVMsqbsplgjLeKMl8SYpfDZ9OKjyWZVUuhP5Jkk3BZQJ81w8Wl6
	G0SaSxfvJeIiX3u6KPUYdQ1+1rnCwp3/Ekws/PRHC2W/DpMQx9p0t+hhII89acqoeRGjdttIqdQ
	ypJUAxfn5QRt/CH/V8UXlOFnVjE+q9WvHp2yzBhbKg0quFzm9PvBoBsdMP/kQHCIK3g==
X-Received: by 2002:a63:c64c:: with SMTP id x12mr8919530pgg.285.1553260901533;
        Fri, 22 Mar 2019 06:21:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1eww7jSuzgCztfx0rxgUxO0PODk462BL+aUp6YCmbCLZPUMYFQSEscM47C8NWV4DZ2Qv/
X-Received: by 2002:a63:c64c:: with SMTP id x12mr8919465pgg.285.1553260900710;
        Fri, 22 Mar 2019 06:21:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553260900; cv=none;
        d=google.com; s=arc-20160816;
        b=xv49CH4mwvIvMD6JEM+wzaiUtKMKDqh6HPApc0QrvPkderEGzlp6vjut5PRxfGqB9b
         atEOWt/a6j4sHj3srsYpWYrv0IsIXCSsL7gEsmmo6Bpzm73M9lUJ0WUMK6GwzvZYuaka
         6xxlRt1eqQ+eDEUmioMn+wbFGOvDK8QxKOKRwDsgyquQIP8OQdxaz7il1q7nXCudCjjD
         eB1AOkjlwVuY1h5HQqaFYMHeOuqDtxwTlU5cEc6B7sEJgmPdTqkcx3nMIK9T6SSTJJ5s
         x0olQthlYE3StKVUhT6ArbHwZpd9+/3KcA0382zgpuDJnGyIJ4EJ2X2Cry54z7TVTeyb
         Di8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=hw3ZtZSh4y78LcwFC7knlBZdOdzIfUNtqXkI2P++IvI=;
        b=H7Dg+BEcMxGE4BncXEdVtJj/U7/DzA/DjV74r+dC01/CKi6x8V2sjY3O9NxJNjafDQ
         19rBIxX1yB/ai5TmJLE2lAT1UmVbUgQrIVvqCGMFOu6TXUFkikNrTMj4AKkjSyt/Cl5R
         8+nIlcOAXC4MlUGecZBr2jXNj1TOPjSZ0tpba4iLOWNoUA5QdB9YDuTncZP0n56TSXRq
         00jOqDPvk0jhE5JcjpPJgANYfKRNKRV7uVkj4bbljXFDJwa05ZU0VOSIfhppMbbhdRK7
         iGhZs/KsHa7oyWuXWTiP3ciW4VwEmlUUQPqbKCdtdeydPBMsCDYtqWRvsYptHIuhGmR3
         WMTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Zbt4AiAW;
       spf=pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o12si7374378plg.221.2019.03.22.06.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 06:21:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Zbt4AiAW;
       spf=pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hw3ZtZSh4y78LcwFC7knlBZdOdzIfUNtqXkI2P++IvI=; b=Zbt4AiAWGBY6okvEekZtK6TS4F
	PTLe64W03umLD5nMSHvoCMhFEc4lCxttGX4EneARFbw7Wk07uvTnz/Ir8Hl1nAuKuj3nWtYcwKHfG
	4lnt+VewjSCFLnWQf0H6NwJw0adquIeo05Oj6qlq6AOFapqexQfI8VP518uRb7Pi5IqICBdl92ARY
	tDAnHXgUGavzntghHV+Bay6zLlMg1KYzVuN20T34X59Oc8MmgfVAJgxJQwa0GUnqoz9YSMbg9h/Ow
	IH3z+678WV11fgVbeRfilpWZX1p31/flKDOsK2UqdbN/QAWsLrzzQAqzjhUf2yTf9GSLzrZZqdNLG
	r47bHwFQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7K6x-00047T-Fh; Fri, 22 Mar 2019 13:21:27 +0000
Date: Fri, 22 Mar 2019 06:21:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/4] arm64, mm: Move generic mmap layout functions to mm
Message-ID: <20190322132127.GA18602@infradead.org>
References: <20190322074225.22282-1-alex@ghiti.fr>
 <20190322074225.22282-2-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190322074225.22282-2-alex@ghiti.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> It then introduces a new define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> that can be defined by other architectures to benefit from those functions.

Can you make this a Kconfig option defined in arch/Kconfig or mm/Kconfig
and selected by the architectures?

> -#ifndef STACK_RND_MASK
> -#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))	/* 8MB of VA */
> -#endif
> -
> -static unsigned long randomize_stack_top(unsigned long stack_top)
> -{
> -	unsigned long random_variable = 0;
> -
> -	if (current->flags & PF_RANDOMIZE) {
> -		random_variable = get_random_long();
> -		random_variable &= STACK_RND_MASK;
> -		random_variable <<= PAGE_SHIFT;
> -	}
> -#ifdef CONFIG_STACK_GROWSUP
> -	return PAGE_ALIGN(stack_top) + random_variable;
> -#else
> -	return PAGE_ALIGN(stack_top) - random_variable;
> -#endif
> -}
> -

Maybe the move of this function can be split into another prep patch,
as it is only very lightly related?

> +#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
> +	defined(ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)

Not sure if it is wrіtten down somehwere or just convention, but I
general see cpp defined statements aligned with spaces to the
one on the previous line.

Except for these nitpicks this looks very nice to me, thanks for doing
this work!

