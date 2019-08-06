Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01635C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:42:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD612086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:42:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD612086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55B806B026B; Tue,  6 Aug 2019 04:42:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E5CB6B026C; Tue,  6 Aug 2019 04:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 386F16B026D; Tue,  6 Aug 2019 04:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9C3D6B026B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:42:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so53385779edr.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:42:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rG6e8LoqBh2XHaVq7F+hfldPruTmFehiVX4YY5vROA8=;
        b=RQVL+UlNPZ8BIIHnAOk4M7pD2hJLbUWR2C6KxWznAhD0qw1HE5B1vrTZryX71wLGiI
         9/stzcHt0UaqSEU1B694ujZF3uXOEBlIuGraZaRDfOZQUehzzogFeWhDMPlA6ijhBDmV
         3r1uR1ELZBH2GmrS9y/diE0OAJ+yZyNE5Lqix0b/Zse/0AE644nw9Wlh0a0cx+Dt22Pz
         yOlfm1QwdxA5k1UekAKeJ0Zim/BhSSZI0L54aMfslw0o2QJiMoeRjiyibiJol5GM8v/k
         JfVnC1UV2hJQMYjpzdPBXbLcQc74DG1ZIi85C25DR8b6swbg4QBYk4a/dA3URtYgl1dM
         n0vA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV+IbHSvYSk+54Jd4rWli19plFXP+CYFgTzwWRe8TtE0XaAgXJx
	cf9G97vtgS1ITW5RjQ7z55v3F9GdP1XiYDSHJllrjOWfwbak8+GikExdGcJmboT6EahEeRyj9x5
	ilLZeuXA+0mc/5LrDpFzRwgvXHtkcah1duxx4By0vl1uSKGwYd0hkDTllsqQeY8A=
X-Received: by 2002:a17:906:f0cd:: with SMTP id dk13mr2060434ejb.84.1565080927458;
        Tue, 06 Aug 2019 01:42:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOlZglzPLUdyjeel0/4vYu5642ymszME93xBtOQrADS6yVcfLdvtxvVUKAfa5xyEXyVZom
X-Received: by 2002:a17:906:f0cd:: with SMTP id dk13mr2060397ejb.84.1565080926710;
        Tue, 06 Aug 2019 01:42:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080926; cv=none;
        d=google.com; s=arc-20160816;
        b=bNlWvoK8F7cTops8gPwDKxnQIC9qQNQ0vOFv2AIAZZl6tIiXNbvqh2YROKYeN+GyXL
         OqFN/H6g2uuQCn7JFTkL4doqMeKyeU8exuA8FvjeXuMdvUG+o2+AdS8/3r7HH08pFU8g
         dah8WYFs0kBPM9WYayBVZJWbGHUq90iuF21aPoAJ8u+I50vhxrjpLgSVzSjiWACldyKv
         cX2kopqnqXOut/aeBcMI3v5i5Euif4t8J2st01R8sU8KGNK14wsRq3NR0xWFApovnvrQ
         IR3OBvjUR5XX2pgv0Daeum3vkXAyc4D9U5loiSPmsShiVZIbrIfKPFdXfgHjRi4j8Mgr
         F0Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rG6e8LoqBh2XHaVq7F+hfldPruTmFehiVX4YY5vROA8=;
        b=UgCZVVAGq0MxYhctFm+w6gs3s7GU9gy42fAJqkU928QLN8ifVIMhbhJMF3nA7+kYid
         XUwwN+XGVPCZdTOa4r7gvpgM668j39UGkaiVUY3QdbsxauFrzczsryJzF7K0DXD5LNi9
         0F2ULVYrDVlBy4Dub0PeAkuBhtue2My1rCo4Bu1NI1VUA+EwGZ2T0KLyWCHOEAJr/AES
         n/A0GhbOg9p64AL7g+EBCiUjSmIImJY8d++GbO/2TSopi0cm0uLOGHRZ+RE4Um9+fUhq
         xLnSMiBUWDpN8ihdcEtAnLn4A/56sjZT/H5WibhmBSU6alCAO4VQxyU9fSaeD1qU27fC
         5SEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q25si27029746ejt.301.2019.08.06.01.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:42:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B55EBABC7;
	Tue,  6 Aug 2019 08:42:05 +0000 (UTC)
Date: Tue, 6 Aug 2019 10:42:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team@android.com, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806084203.GJ11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805170451.26009-3-joel@joelfernandes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> This bit will be used by idle page tracking code to correctly identify
> if a page that was swapped out was idle before it got swapped out.
> Without this PTE bit, we lose information about if a page is idle or not
> since the page frame gets unmapped.

And why do we need that? Why cannot we simply assume all swapped out
pages to be idle? They were certainly idle enough to be reclaimed,
right? Or what does idle actualy mean here?

> In this patch we reuse PTE_DEVMAP bit since idle page tracking only
> works on user pages in the LRU. Device pages should not consitute those
> so it should be unused and safe to use.
> 
> Cc: Robin Murphy <robin.murphy@arm.com>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>  arch/arm64/Kconfig                    |  1 +
>  arch/arm64/include/asm/pgtable-prot.h |  1 +
>  arch/arm64/include/asm/pgtable.h      | 15 +++++++++++++++
>  3 files changed, 17 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 3adcec05b1f6..9d1412c693d7 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -128,6 +128,7 @@ config ARM64
>  	select HAVE_ARCH_MMAP_RND_BITS
>  	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
>  	select HAVE_ARCH_PREL32_RELOCATIONS
> +	select HAVE_ARCH_PTE_SWP_PGIDLE
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_STACKLEAK
>  	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
> diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
> index 92d2e9f28f28..917b15c5d63a 100644
> --- a/arch/arm64/include/asm/pgtable-prot.h
> +++ b/arch/arm64/include/asm/pgtable-prot.h
> @@ -18,6 +18,7 @@
>  #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
>  #define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
>  #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
> +#define PTE_SWP_PGIDLE		PTE_DEVMAP		 /* for idle page tracking during swapout */
>  
>  #ifndef __ASSEMBLY__
>  
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 3f5461f7b560..558f5ebd81ba 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -212,6 +212,21 @@ static inline pte_t pte_mkdevmap(pte_t pte)
>  	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
>  }
>  
> +static inline int pte_swp_page_idle(pte_t pte)
> +{
> +	return 0;
> +}
> +
> +static inline pte_t pte_swp_mkpage_idle(pte_t pte)
> +{
> +	return set_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
> +}
> +
> +static inline pte_t pte_swp_clear_page_idle(pte_t pte)
> +{
> +	return clear_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
> +}
> +
>  static inline void set_pte(pte_t *ptep, pte_t pte)
>  {
>  	WRITE_ONCE(*ptep, pte);
> -- 
> 2.22.0.770.g0f2c4a37fd-goog

-- 
Michal Hocko
SUSE Labs

