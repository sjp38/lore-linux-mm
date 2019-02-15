Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77F41C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:09:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 414B9222BE
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:09:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 414B9222BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D36968E0002; Fri, 15 Feb 2019 08:09:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBF188E0001; Fri, 15 Feb 2019 08:09:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87A68E0002; Fri, 15 Feb 2019 08:09:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEEB8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:09:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id u19so3864798eds.12
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:09:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9mQ6ySwwfLpY9qTN0K12N9m3XcRwfoKFnvN9Lw4/iPo=;
        b=eI8WYE6h2qWykzd9jzkVmNkFTxMjDufQ45XW7Op/04tzt7s5F5QhrvPGpAFyRkh5Nw
         hE01jKjIrsyI2wFfuySYrfKP2Gyk6LL5KgpUFGnrHoy+fvzoxiT2fyKcL0AJ4f8xdYRk
         8sN8fR93lhGFz+fnS2ol0PrPvEu4Sw7PZ5GZKvZLNpIURTakQy2AcncYYr5iVZBkfeIp
         civRaNDqokFKmfExiUyo6h3anPFakIT29jTH746SEo/XEPGcvqfmC6I7QD9o8MADLDX6
         O41R6GzrLRgGdj0vX1ISfcAxOlrZgrFUEFHOWiEY9eHRUaBQG45HHN5rAgkyTMchgSQA
         qbkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuatb2hpNorXDcm8jrtT+sfWzeneqk8yNevQn9h6rhVmvSVHuFs3
	viVdUDogg/NuvCxM5x+FTXuWmQdw7Lh7CAfNfm8yd+rt/oKiGN62DqEYFx86Yr5VIMCKW5yDdqA
	bSG1M0xAIKl5lTSWu6vNfseiNs4nyAU2v5c//trqRdq3JgQsQN8DnOip51I3DRcjXxA==
X-Received: by 2002:a17:906:115a:: with SMTP id i26mr6564228eja.116.1550236193897;
        Fri, 15 Feb 2019 05:09:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYIIVNuPhlDx2mnUVMK/WdgJwoBXBEYDWnCM3TdlvQdFle+bYBgPWyii47R+1e2rGbsh8l1
X-Received: by 2002:a17:906:115a:: with SMTP id i26mr6564176eja.116.1550236192857;
        Fri, 15 Feb 2019 05:09:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550236192; cv=none;
        d=google.com; s=arc-20160816;
        b=tczPddC8P9vd/PEWaQwRojSwfohrFOWIBMh4yU2lFU1O3hgnr0Fw7lQOCWWXN+anlX
         4rqHYdiM3FWpKnrOTMZSJ3p72E+Jj3WT8jKkxMxpc7K/AbN3m8QSQJYHqrJLTahQpPub
         6lMV9PgVx9Gwsr2tzcGs9IxWfRa3LY2TPEERsTxd3m7bbRqycGpYwYKbLzxbi+3/GAI2
         /40cOuyaRrMEIfSjTi1Hw/2JqtMF38FeXdLtYLo2nevESRxw22lUOTPX26DQe1wReQDH
         g2skzB9rKYC9s0L8qwlteW/AsSmISsmqYbDPbDRlVrrvgtpYkQLbQCIf95H/pHSHlYXa
         7fGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9mQ6ySwwfLpY9qTN0K12N9m3XcRwfoKFnvN9Lw4/iPo=;
        b=mqrClavtDQsCfsbMd49Gs1Vai59kbwXpE1ZGEyV4LLv3AwBd6LWCpA1hhEu9iJnmih
         vUONkgl33w4GF62PReGQThYa9x6VAG9RCSi3QfvKIpDWnhq/gUnEqlb16uH7bIHj1hDK
         VvJ7Q91uzXyYLrmK5DR5Ij3lmzqEryfzrqLdbrZ+94pBp8EkJ0A8tUoCtpOr5W3waVP+
         Dae23l5JljVpxYxjPZmUkd5g0i95s391v4H7EyKzq0fvgvlBY7JTy6NjnQ6xGLMb7gq6
         aTwNFcCIYW7TbFUMpHvI9VoS63h1wdxLFQ0FW39M+kebECtk8wRbU55dbhSHh1SxMxEf
         Ny+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 92si2059632edn.212.2019.02.15.05.09.52
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 05:09:52 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5EA9EA78;
	Fri, 15 Feb 2019 05:09:51 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3BE993F575;
	Fri, 15 Feb 2019 05:09:45 -0800 (PST)
Date: Fri, 15 Feb 2019 13:09:42 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, torvalds@linux-foundation.org,
	liran.alon@oracle.com, keescook@google.com,
	akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com,
	will.deacon@arm.com, jmorris@namei.org, konrad.wilk@oracle.com,
	Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com,
	chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
	andrew.cooper3@citrix.com, jcm@redhat.com,
	boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
	oao.m.martins@oracle.com, jmattson@google.com,
	pradeep.vincent@oracle.com, john.haxby@oracle.com,
	tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, peterz@infradead.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v8 08/14] arm64/mm: disable section/contiguous
 mappings if XPFO is enabled
Message-ID: <20190215130942.GD53520@lakrids.cambridge.arm.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <0b9624b6c1fe5a31d73a6390e063d551bfebc321.1550088114.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b9624b6c1fe5a31d73a6390e063d551bfebc321.1550088114.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Feb 13, 2019 at 05:01:31PM -0700, Khalid Aziz wrote:
> From: Tycho Andersen <tycho@docker.com>
> 
> XPFO doesn't support section/contiguous mappings yet, so let's disable it
> if XPFO is turned on.
> 
> Thanks to Laura Abbot for the simplification from v5, and Mark Rutland for
> pointing out we need NO_CONT_MAPPINGS too.
> 
> CC: linux-arm-kernel@lists.infradead.org
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

There should be no point in this series where it's possible to enable a
broken XPFO. Either this patch should be merged into the rest of the
arm64 bits, or it should be placed before the rest of the arm64 bits.

That's a pre-requisite for merging, and it significantly reduces the
burden on reviewers.

In general, a patch series should bisect cleanly. Could you please
restructure the series to that effect?

Thanks,
Mark.

> ---
>  arch/arm64/mm/mmu.c  | 2 +-
>  include/linux/xpfo.h | 4 ++++
>  mm/xpfo.c            | 6 ++++++
>  3 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index d1d6601b385d..f4dd27073006 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -451,7 +451,7 @@ static void __init map_mem(pgd_t *pgdp)
>  	struct memblock_region *reg;
>  	int flags = 0;
>  
> -	if (debug_pagealloc_enabled())
> +	if (debug_pagealloc_enabled() || xpfo_enabled())
>  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>  
>  	/*
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> index 1ae05756344d..8b029918a958 100644
> --- a/include/linux/xpfo.h
> +++ b/include/linux/xpfo.h
> @@ -47,6 +47,8 @@ void xpfo_temp_map(const void *addr, size_t size, void **mapping,
>  void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
>  		     size_t mapping_len);
>  
> +bool xpfo_enabled(void);
> +
>  #else /* !CONFIG_XPFO */
>  
>  static inline void xpfo_kmap(void *kaddr, struct page *page) { }
> @@ -69,6 +71,8 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
>  }
>  
>  
> +static inline bool xpfo_enabled(void) { return false; }
> +
>  #endif /* CONFIG_XPFO */
>  
>  #endif /* _LINUX_XPFO_H */
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> index 92ca6d1baf06..150784ae0f08 100644
> --- a/mm/xpfo.c
> +++ b/mm/xpfo.c
> @@ -71,6 +71,12 @@ struct page_ext_operations page_xpfo_ops = {
>  	.init = init_xpfo,
>  };
>  
> +bool __init xpfo_enabled(void)
> +{
> +	return !xpfo_disabled;
> +}
> +EXPORT_SYMBOL(xpfo_enabled);
> +
>  static inline struct xpfo *lookup_xpfo(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> -- 
> 2.17.1
> 

