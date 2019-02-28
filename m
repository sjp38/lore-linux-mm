Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B98DC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 366822171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:20:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 366822171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4E718E0007; Thu, 28 Feb 2019 07:20:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23A08E0001; Thu, 28 Feb 2019 07:20:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ED648E0007; Thu, 28 Feb 2019 07:20:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 485128E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:20:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i20so8432470edv.21
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:20:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=uXoI5re6uzdWnU878EneLrgpYrcELqe0YZdfW+jvy7o=;
        b=iPJBGkwjBMngBrGANp5OhGjVnRkgF/95z3EUnzcmdhguYAQurcZpF026/RV4wM5Mgf
         hAP0yPV5phtWgPr4GBlBEnnWgRFCh7KxwKas5knHgJOsI2LYKI12NbCYxZU73oIZKPZi
         /JI/Wt5TqwpoHeOoXFGzkaZ4Lvbzvx38ZA4Ufjo9hDR9jTyEYVn9YsUPtxILygINvmpR
         Gi1wftbOqiSIX/v4KVOmPecv5B0jWbaEqqJC8eA5Rt4DWItxBkaTl1kwGpjTNUDEj7gS
         T+RUj5PfkibmqwnRhdUIwHLtGwGOVmESQVgkwHa9JB92YLe/tvWvIEfSrY2OYDYh7wuB
         Ls+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubWKrHvNgj4bcwve9HEUckU5fkHoGbyA2tfsromIm5oEht3i8a8
	DmqmLehDNnf36mH0FpfFOMnQaJK6bQlUYb5GxucuuYY6HPNR/cfkZUFDz0pScYsyYe4BaRRZSbg
	7fF1kmboTSKy9YH9zbfdIFNu5eTbonuBqQ8V8h0H+R52/DpIZMxSaURPm6528Q6HKgg==
X-Received: by 2002:a17:906:4ada:: with SMTP id u26mr5278344ejt.191.1551356406831;
        Thu, 28 Feb 2019 04:20:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+O0wQeqD05bFwZn+yvh0ZWXcUY9N3JjGjQzb/G9xhOeRT85rgGMaDEkQUuBgKYNCjQhGr
X-Received: by 2002:a17:906:4ada:: with SMTP id u26mr5278296ejt.191.1551356405857;
        Thu, 28 Feb 2019 04:20:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551356405; cv=none;
        d=google.com; s=arc-20160816;
        b=Hm9lT7VOfSJT4bM4k5W6w0/tFkCVUv+Zf/2wcohT0MFt1K4R8V0iSGiCxoqAUzyqzT
         4hh3IxS+v87y3L6DgWZLiQP3nXSsLF40Ij1iHnsppEv8EtIe9hdQmA5nQp2kcKQ7hXxk
         DFOhoPnasSYxxx/mVGkfXpBYIezYZvMm9ns/XjAW+NSM1tjpsZtX40Hkzai+cYdBtuqm
         Hb/2teJgdOu1anvCcKk59FJgXZ/v98jjNamnEHdCAbIzTR9F0PXez21ajNOtSpPBuhKZ
         3yJRknVfTTcQkrlJGkZYeaeGqHsGuSvA7pGsKVKRmEKa8BemFKUV1ygkM7b39KKfFI8/
         kB4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=uXoI5re6uzdWnU878EneLrgpYrcELqe0YZdfW+jvy7o=;
        b=AZMd/1ZS2egDU9GHgFjRMEiqW39x+f/ySFEwe6B6rAVItSdFri2vkD2cy5q1wYG4Ms
         L8ETiMsZ05wXdhx+I/61XM+pvsl4hfPi1mox5wPZgyHBLrB7oNXus9F7x3r3fsKIGZwQ
         i3NoS11Mh5odW2wUFOWvJdG2mV7bVC+UlbbJWpE7apTdYmpsE9uToirvl1WqqVu1F7gn
         W3Zf89KQzZBF5B/f1J47vLgdlHvWILB5JnvSxVM4UoRje/xJG2wo0iboyRn2y5OYMcob
         zvyOawh45rU58o7QVllLRRoY6OAI6yMMShyUpDK+gemkEftrt7wANEwfuRAnGGOL3HbK
         o+ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z40si3711983edz.338.2019.02.28.04.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:20:05 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AB20DAE0F;
	Thu, 28 Feb 2019 12:20:04 +0000 (UTC)
Subject: Re: [PATCH v8 1/4] mm/cma: Add PF flag to force non cma alloc
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>,
 Alexey Kardashevskiy <aik@ozlabs.ru>,
 David Gibson <david@gibson.dropbear.id.au>,
 Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>, Matthew Wilcox <willy@infradead.org>
References: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
 <20190227144736.5872-2-aneesh.kumar@linux.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <1d083bf9-0beb-0c49-9aab-c6bc14da46ea@suse.cz>
Date: Thu, 28 Feb 2019 13:20:03 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190227144736.5872-2-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/27/19 3:47 PM, Aneesh Kumar K.V wrote:
> This patch adds PF_MEMALLOC_NOCMA which make sure any allocation in that context
> is marked non-movable and hence cannot be satisfied by CMA region.
> 
> This is useful with get_user_pages_longterm where we want to take a page pin by
> migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
> that we avoid unnecessary page migration later.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

+CC scheduler guys

Do we really take the last available PF flag just so that "we avoid
unnecessary page migration later"?
If yes, that's a third PF_MEMALLOC flag, should we get separate variable
for gfp context at this point?
Also I don't like the name PF_MEMALLOC_NOCMA, as it's unnecessarily tied
to CMA. If anything it should be e.g. PF_MEMALLOC_NOMOVABLE.

Thanks.

> ---
>  include/linux/sched.h    |  1 +
>  include/linux/sched/mm.h | 48 +++++++++++++++++++++++++++++++++-------
>  2 files changed, 41 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index f9b43c989577..dfa90088ba08 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1403,6 +1403,7 @@ extern struct pid *cad_pid;
>  #define PF_UMH			0x02000000	/* I'm an Usermodehelper process */
>  #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
>  #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
> +#define PF_MEMALLOC_NOCMA	0x10000000 /* All allocation request will have _GFP_MOVABLE cleared */
>  #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */
>  #define PF_FREEZER_SKIP		0x40000000	/* Freezer should not count it as freezable */
>  #define PF_SUSPEND_TASK		0x80000000      /* This thread called freeze_processes() and should not be frozen */
> diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
> index 3bfa6a0cbba4..0cd9f10423fb 100644
> --- a/include/linux/sched/mm.h
> +++ b/include/linux/sched/mm.h
> @@ -148,17 +148,25 @@ static inline bool in_vfork(struct task_struct *tsk)
>   * Applies per-task gfp context to the given allocation flags.
>   * PF_MEMALLOC_NOIO implies GFP_NOIO
>   * PF_MEMALLOC_NOFS implies GFP_NOFS
> + * PF_MEMALLOC_NOCMA implies no allocation from CMA region.
>   */
>  static inline gfp_t current_gfp_context(gfp_t flags)
>  {
> -	/*
> -	 * NOIO implies both NOIO and NOFS and it is a weaker context
> -	 * so always make sure it makes precedence
> -	 */
> -	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
> -		flags &= ~(__GFP_IO | __GFP_FS);
> -	else if (unlikely(current->flags & PF_MEMALLOC_NOFS))
> -		flags &= ~__GFP_FS;
> +	if (unlikely(current->flags &
> +		     (PF_MEMALLOC_NOIO | PF_MEMALLOC_NOFS | PF_MEMALLOC_NOCMA))) {
> +		/*
> +		 * NOIO implies both NOIO and NOFS and it is a weaker context
> +		 * so always make sure it makes precedence
> +		 */
> +		if (current->flags & PF_MEMALLOC_NOIO)
> +			flags &= ~(__GFP_IO | __GFP_FS);
> +		else if (current->flags & PF_MEMALLOC_NOFS)
> +			flags &= ~__GFP_FS;
> +#ifdef CONFIG_CMA
> +		if (current->flags & PF_MEMALLOC_NOCMA)
> +			flags &= ~__GFP_MOVABLE;
> +#endif
> +	}
>  	return flags;
>  }
>  
> @@ -248,6 +256,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
>  	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
>  }
>  
> +#ifdef CONFIG_CMA
> +static inline unsigned int memalloc_nocma_save(void)
> +{
> +	unsigned int flags = current->flags & PF_MEMALLOC_NOCMA;
> +
> +	current->flags |= PF_MEMALLOC_NOCMA;
> +	return flags;
> +}
> +
> +static inline void memalloc_nocma_restore(unsigned int flags)
> +{
> +	current->flags = (current->flags & ~PF_MEMALLOC_NOCMA) | flags;
> +}
> +#else
> +static inline unsigned int memalloc_nocma_save(void)
> +{
> +	return 0;
> +}
> +
> +static inline void memalloc_nocma_restore(unsigned int flags)
> +{
> +}
> +#endif
> +
>  #ifdef CONFIG_MEMCG
>  /**
>   * memalloc_use_memcg - Starts the remote memcg charging scope.
> 

