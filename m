Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE9E3C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A6AF2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:31:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PrfN5Q8z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A6AF2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282CC6B000C; Fri,  7 Jun 2019 03:31:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 258D06B000E; Fri,  7 Jun 2019 03:31:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16EA46B026F; Fri,  7 Jun 2019 03:31:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB7E26B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:31:18 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so1017543iob.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z4s1HU+Ta9EFcVv62Up/dxFFdolam58FxKGBkLAELZE=;
        b=PgH2rmEqM8aNWyzQOPOlgCBP+n/XaLBGk7c6tN7rXSlLCBD7ogWnwrSS5vsnEOYW27
         jk1vfD4Ifq8EzfB3liVzz1KpIIJaZWkWhua0M8Zlst/S10Zc63OGRt8r4lk3q3LDRAIO
         nhgx8b1TmgjcDfjzatu8pz2QnnHA7ClRN72ZtKeSgsXO+Xt4we+aKu3MLAXYkvThlOwR
         9YGuezyzjmecwmIYpzWMei5SaxbXBHlWDYxSD6tLpPavFI3oVhVm02xTh5h37FkZVgHa
         G04c2mRa9Nsqo7eNNyS+/ej3GFnC/AT/u8vXPcpoeANZ1K+c03OIhwE4NkEx/dUK+vpB
         cEuA==
X-Gm-Message-State: APjAAAXDXrx9Mb0b2R/JGMDamvmR6GE7LC0EUOYGLvzIHm9nVQTl6OL4
	u+Yfq9dmFzYHxYPDjqpcMdJ2bD+ow3ac+hL2HmPjBd0gCDfGIR+Twtd7x/+aMm7qOYPBpPTInj1
	SkojpPaWRNWJpmfnQdWY1n8GRpGIux3ojjU8TteSryo7ZhH0xhMEJ5YD19IrYAtnWfg==
X-Received: by 2002:a02:ac09:: with SMTP id a9mr16926773jao.48.1559892678634;
        Fri, 07 Jun 2019 00:31:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOXjjTd0rV56FNjo/cNSU7A4q/bgwSG66sY0bSrKq7ZLP4EF7X0Rhr3zSnDe5It00LKMUT
X-Received: by 2002:a02:ac09:: with SMTP id a9mr16926745jao.48.1559892677980;
        Fri, 07 Jun 2019 00:31:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559892677; cv=none;
        d=google.com; s=arc-20160816;
        b=BHykZ3816xOZ6e5ogkQb5vDcev7/nSyc5xdzHxVQTwEizF8ungAueHmP87SJ3VZTBd
         gd4xkNh8VTzBOmO1flPMASx4eZjHQJqsrpdUcQmVxgFGEou4CGdd7TgB1cUm9GzzFNOw
         iTLTx2X5uZndh1e28ZHHqO0Pq9o1VyhAVt/SvZ9rzhHw7YT/IS6rjYBAyffB35ltw5JN
         Ky65s6WWca+/Yvdt4hbCaMuQtDBuSiO5RKgWj9zMsOBq0xJ2L0MBCac8bs08dqxCija7
         HPDEkrLNCUlxj1/z4ILsaxQ0XpkkdkmdK8/Y/UY5CvBU+oSz7dyjtqUah4Jxa6UkUE+j
         Xn1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z4s1HU+Ta9EFcVv62Up/dxFFdolam58FxKGBkLAELZE=;
        b=WuoBDz4Rj8Nvd/fJ/tZPoNvci6BbN4XILorsUzQkYumXGkRe1IKtzKa+aNDJom8/vh
         arAeaSKNq+HcIMOCnrTYptvqKMJUM6Nhuj/GWHPYPeMZT1OYkwsU877Juxgy/b0NqhBQ
         yksFJaI2Cj4sa4xeHKtYT/pUvTQYJdWQEFuIKFdjh/ffsyPjLMNuhoMA5Ei3Hz7iLaBI
         OV18/5p4YaKYKFvQDfcJllSE/LQ3RWvJtyCAqnMm01wlgSQhyjFeck+5k446ZKTsfMz2
         7AH2DtGppelx8fkVcjtvakwxuUV2JDrGkKVk9CBuoMksHu4O5eQ8v/8yL1nLXZzFshkG
         Hitw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PrfN5Q8z;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k74si764006itb.3.2019.06.07.00.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 00:31:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PrfN5Q8z;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z4s1HU+Ta9EFcVv62Up/dxFFdolam58FxKGBkLAELZE=; b=PrfN5Q8zV0PMbJwOh2nSW0qEu
	whA3bMeZqjYW6FVebCOMZ+jOWcBf+KwA1YjMeNgOsUt0oXjsFsVtbgVjMkkSB2lXZiVsntQd5nIpO
	GW/QhqhGfYGi3P0N9Kz2wphjaFQrHbOZos1aDDyNXV9IIbRjza8ZimXKp7rc3KXCR2qUaIUDiJx4D
	5rSOUPZEafMrNVJUJROE8lISqEQD1e32yciSw6rgIUWvfgxL1u89OkOz+Hdjo60eCuPyV4oJuq5ZI
	jCvlk67LYXzyPmh1q9o9aYoPPzyR0KFRwE/m9d1Eb5wGETSQGDQ/SGHQzPTldrqSlG+aLohd+cQ4E
	nfdyfn8hA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hZ9Kx-0002HQ-Ah; Fri, 07 Jun 2019 07:30:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E4942202CD6B2; Fri,  7 Jun 2019 09:30:52 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:30:52 +0200
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
Subject: Re: [PATCH v7 15/27] mm: Handle shadow stack page fault
Message-ID: <20190607073052.GO3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-16-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200646.3951-16-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:06:34PM -0700, Yu-cheng Yu wrote:

> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 75d9d68a6de7..ffcc0be7cadc 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -1188,4 +1188,12 @@ static inline bool arch_has_pfn_modify_check(void)
>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>  #endif
>  
> +#ifndef CONFIG_ARCH_HAS_SHSTK
> +#define pte_set_vma_features(pte, vma) pte
> +#define arch_copy_pte_mapping(vma_flags) false

static inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
{
	return pte;
}

static inline bool arch_copy_pte_mapping(unsigned long vm_flags)
{
	return false;
}

Please, this way we retain function prototype checking.

> +#else
> +pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
> +bool arch_copy_pte_mapping(vm_flags_t vm_flags);
> +#endif

