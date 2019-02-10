Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84364C282C4
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 446D821929
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:49:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 446D821929
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEA2F8E00B7; Sat,  9 Feb 2019 19:49:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70F28E00B5; Sat,  9 Feb 2019 19:49:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3A1F8E00B7; Sat,  9 Feb 2019 19:49:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 762C48E00B5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 19:49:36 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w124so7782023qkc.14
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 16:49:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=RUkKFTS85FoXbRyygGKOUvPm3q46TzJX+NNR/xpK20M=;
        b=t+DeCBBVm5lcZJkW47A58unUON+qnhNg8an61xdcha6Gyy7j5LQjC/X6Mrnucvsy6r
         8uWjOq5hWXilnW4B+Jp/Nxsro9m8Ml1vhy8z3+vJn6WTaU06AguheaXEvxkqByt+DLnZ
         L2oFKulhWSeXI0ObYbqYtWIjq3HepgfOI3K4b9mmO+1kO3vQzMQel+23BthKMQDhLRwc
         z1oLpBpmFsuFKAGmBctQB0f48bvYDxguoKeM7yWEnnkdne6hO1Dsar24QL4PLGDt9Kgb
         NUR+aQjFb6sTmUTZQT/gayop042IjD2FIDNTVcWbJeawRJDiICXwKS8unNTMWB9Bl7Lu
         Cpsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZeTAIj9C+yHORecJcfI+c2qObJOVsXVvc/u6xoFNXm81n467/D
	jlejX42DcPtWE4mBBGODEGsXyuvzLVzLAoqfRfYvrdWt8WSyQLGYM5G3UHpN2iFyW8mSmok4ZWU
	3YiaqGmr/Jb1Gq0vw6NUl+1PFTWxPnw4UBHjhgw8GuALXsck3rAkQJBWqlNhUL3xzrOnHwSDC+4
	71cecisWtpGi3GdOsOQtdMgKR/X98QYnPRagXis6AjiwpCpLV+Ci/BhMoBA+s5VVB7EK7OQF6RY
	T5ENAlMCohEIMRgn93Sjb9eDTaqCwivKLGa4wtSPWwf+3N3BDijLQxN74PN9zPSd7UF/c4ALG9u
	vRQO/iv3ATsVjxMyT0iVD6C6vOCD1S6IG7C5fwwWgXvCz9n6u9RviqqsNkZTw2rqp1+veYP81jC
	f
X-Received: by 2002:a37:7442:: with SMTP id p63mr21071424qkc.320.1549759776153;
        Sat, 09 Feb 2019 16:49:36 -0800 (PST)
X-Received: by 2002:a37:7442:: with SMTP id p63mr21071407qkc.320.1549759775499;
        Sat, 09 Feb 2019 16:49:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549759775; cv=none;
        d=google.com; s=arc-20160816;
        b=CY9jmj3NxjwZYazaMZkjWW/ssDUQYBZuxkD/hWV13XrVdJECLy1yz1aew5vE3/u8bw
         9LT1NZ7mpcYGyBSxuaJDF4E+UKu6eH9hUyU417aV/YN0MUCWHbfCexStl3wMm3PvAZCG
         rG6JrfTj8qBrxq1lJ5cm4vv+Yjsq8+pbQe1Y+NdvcOoQ5yziTK3jUNrbjVDgQQdp5dz6
         +b1kkZdPW5FRA2K0rLu+3alIHjS7axS6Sg0Iq7AN/5f/DwTJPnb09YT2xyvHgiKDaP3R
         FvTdNJZy1NLrK42P7T9VFk2JwcPO4vCCUF8imyKHpCd8eNTx3Ur8O3dnA60KApTRmqED
         mU3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=RUkKFTS85FoXbRyygGKOUvPm3q46TzJX+NNR/xpK20M=;
        b=zhjWPLnfxUjBERQicrKA2oJduTMGyCfegtTiQJj/LYQN5nT1fYHOuT6yD/zM1X6EYe
         yAYfrvxEmpywHEdy6/7ATYD97epIxW1PYjovcflYVWJeJxZsC+W5jpEYIyGAhtJ6xl+x
         5684pvTQ98zTWUyU97bSRv3F9VR/j6TKOUoNNUI8Z7w/PoY9y0C/y9qm8gpIffE0+RRe
         e0dQOHbnrpl7fhFVSmvYL07PZYRCVCGVXYFqQsekxMGshpl2+A0jSm87JnZUS8MU/GvL
         q6IguTTGRF4J/nr8bS2qu2ZfO2pSmEdbwqJXD3AG7iDTDT9efPFWe72aKAv69f9UD8Te
         J6og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g65sor3698095qkd.1.2019.02.09.16.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Feb 2019 16:49:35 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IZrOS4xixlnOrA12cEVvQYc+GOESwsGu6yDE0QQ6J97dBoIDOR6uKBT125l8m6fyCB1L/ihlg==
X-Received: by 2002:a37:7f41:: with SMTP id a62mr21745612qkd.247.1549759775240;
        Sat, 09 Feb 2019 16:49:35 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id k66sm6420163qkc.25.2019.02.09.16.49.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 16:49:34 -0800 (PST)
Date: Sat, 9 Feb 2019 19:49:32 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
Message-ID: <20190209194437-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204181552.12095.46287.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Add guest support for providing free memory hints to the KVM hypervisor for
> freed pages huge TLB size or larger. I am restricting the size to
> huge TLB order and larger because the hypercalls are too expensive to be
> performing one per 4K page.

Even 2M pages start to get expensive with a TB guest.

Really it seems we want a virtio ring so we can pass a batch of these.
E.g. 256 entries, 2M each - that's more like it.

> Using the huge TLB order became the obvious
> choice for the order to use as it allows us to avoid fragmentation of higher
> order memory on the host.
> 
> I have limited the functionality so that it doesn't work when page
> poisoning is enabled. I did this because a write to the page after doing an
> MADV_DONTNEED would effectively negate the hint, so it would be wasting
> cycles to do so.

Again that's leaking host implementation detail into guest interface.

We are giving guest page hints to host that makes sense,
weird interactions with other features due to host
implementation details should be handled by host.




> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  arch/x86/include/asm/page.h |   13 +++++++++++++
>  arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
>  2 files changed, 36 insertions(+)
> 
> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> index 7555b48803a8..4487ad7a3385 100644
> --- a/arch/x86/include/asm/page.h
> +++ b/arch/x86/include/asm/page.h
> @@ -18,6 +18,19 @@
>  
>  struct page;
>  
> +#ifdef CONFIG_KVM_GUEST
> +#include <linux/jump_label.h>
> +extern struct static_key_false pv_free_page_hint_enabled;
> +
> +#define HAVE_ARCH_FREE_PAGE
> +void __arch_free_page(struct page *page, unsigned int order);
> +static inline void arch_free_page(struct page *page, unsigned int order)
> +{
> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> +		__arch_free_page(page, order);
> +}
> +#endif
> +
>  #include <linux/range.h>
>  extern struct range pfn_mapped[];
>  extern int nr_pfn_mapped;
> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> index 5c93a65ee1e5..09c91641c36c 100644
> --- a/arch/x86/kernel/kvm.c
> +++ b/arch/x86/kernel/kvm.c
> @@ -48,6 +48,7 @@
>  #include <asm/tlb.h>
>  
>  static int kvmapf = 1;
> +DEFINE_STATIC_KEY_FALSE(pv_free_page_hint_enabled);
>  
>  static int __init parse_no_kvmapf(char *arg)
>  {
> @@ -648,6 +649,15 @@ static void __init kvm_guest_init(void)
>  	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI))
>  		apic_set_eoi_write(kvm_guest_apic_eoi_write);
>  
> +	/*
> +	 * The free page hinting doesn't add much value if page poisoning
> +	 * is enabled. So we only enable the feature if page poisoning is
> +	 * no present.
> +	 */
> +	if (!page_poisoning_enabled() &&
> +	    kvm_para_has_feature(KVM_FEATURE_PV_UNUSED_PAGE_HINT))
> +		static_branch_enable(&pv_free_page_hint_enabled);
> +
>  #ifdef CONFIG_SMP
>  	smp_ops.smp_prepare_cpus = kvm_smp_prepare_cpus;
>  	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
> @@ -762,6 +772,19 @@ static __init int kvm_setup_pv_tlb_flush(void)
>  }
>  arch_initcall(kvm_setup_pv_tlb_flush);
>  
> +void __arch_free_page(struct page *page, unsigned int order)
> +{
> +	/*
> +	 * Limit hints to blocks no smaller than pageblock in
> +	 * size to limit the cost for the hypercalls.
> +	 */
> +	if (order < KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> +		return;
> +
> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> +		       PAGE_SIZE << order);
> +}
> +
>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>  
>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */

