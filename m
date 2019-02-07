Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40CACC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A342175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A342175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 920778E005B; Thu,  7 Feb 2019 13:21:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F84A8E0002; Thu,  7 Feb 2019 13:21:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F4C8E005B; Thu,  7 Feb 2019 13:21:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57A5C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 13:21:09 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s65so646292qke.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:21:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wI96yv2CwKA7oYA948d9pJkSWIisPu0GCXw4PPWmBaQ=;
        b=glqCyDyuxdEUSjm++oNzQz4kHBgHES4j00goYK1ErrfeYG+2Q9/MKpnivMk1De7HAE
         c3MEIjn6EeGIjE3ov3R1En0yFaaQSQ3veOoC8ujAAXrtGWc32sP4ood4QYY4lM/E47pw
         1BiMeC8k53JMkdkSZqdJxXDlskCYdCNPMxtm9Kej1J6ztD7HiyTBZ+BX6ym6Ft2rXBBc
         Dy/HlxJOVRbH+tNUvDtBj01YMO94FdpR70Q9pHpcyY8/V4MURy//si88OImzxSQ0uDjx
         KlEu4f7BecCI2/qYmTQGPest5KhtlPD7x3iCRsE0gO/GxZLldde2CT4xPxee6HpTn5QB
         0Cng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua3oCVJbPnuCpRVwdl5yjBNBBcSLRRI6UywpJewQV9SUAlNPUGF
	K7wrnI37I1GQmmp+xZqsFUsaRbpP91BMo1qTSN8GJKWTRrl2wLh5pTHktLmUOUv64f2C5CXhnXH
	SUKZWbPs4cznzAbMDTRt1NXPI3Zj6BnWAo7mcKQXL9LU30nUFbRzDFzAXPbewX7fvrA==
X-Received: by 2002:a37:7347:: with SMTP id o68mr12558257qkc.13.1549563669123;
        Thu, 07 Feb 2019 10:21:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSAMzczFihbIdRK4TSwKKzhXhdSGTb/WMkR+dSnPOj+ULq7buLupHnl13AYvoE8bzadT2s
X-Received: by 2002:a37:7347:: with SMTP id o68mr12558207qkc.13.1549563668341;
        Thu, 07 Feb 2019 10:21:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549563668; cv=none;
        d=google.com; s=arc-20160816;
        b=UNx0QHCcY9UwHirsJ/J83aoZ/sU6Cg4XP42k3rjJgAGQd1ESas7RCGBKPQKCrMB5hY
         X9fVDn12bWS+g0aMauMe+Udf2HmdCUWwjVjJr7fftmMBihXz/jqGYrnwx+OcUhMRol2a
         hPN110JB76cKO4phwDR9Z/umj91OP4h1VnXy8UHfjoUnP/DJRi405D68XCtBLVUe/IY+
         yCwZ4q1/7LaYELzvw39VzPIIgKYxy3/GtWIvU1dmz9no1JKEvWfLDe3NT9BWV3y72daW
         eHz6n9jdh3N1vmuzd5F37oBvqUL1tSyyFRnm8nplXCA4nbof5wPlLz1zOpJBszWlbzJr
         Vc+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=wI96yv2CwKA7oYA948d9pJkSWIisPu0GCXw4PPWmBaQ=;
        b=JOwqI9u9/XOtNLPGQRNI/cQy1/BaQrOJEnLv4tcdOE9XPd+3ohzV+FFXwPdskRz14F
         tYri4tbYjAXnSsrVuapsOMTGfSryQyKTnVFxnbpN+kouGFikQIANm9c9t8ZMKgqmKBaM
         eBZGpyebIlsNuYS4ID/xveHhjFTjobAic9xciduueNUyQBd9CFF1Vh5AqVJW52cPYJ37
         nd/kK1IE06Q9kWe/eVDcijWGzjIugCQwZJIeMAe+Z+W0sXbFobhsONwGfjj7AuoGH+ZC
         2Fkt2FzAM11ZZ3NZaPM7FEPL6shKLHQubntjDOOkLcJr8u3aPWenp36GImRYMLAaSzKG
         JsMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f64si6290187qva.93.2019.02.07.10.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 10:21:08 -0800 (PST)
Received-SPF: pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FEDA5C9;
	Thu,  7 Feb 2019 18:21:07 +0000 (UTC)
Received: from doriath (ovpn-116-107.phx2.redhat.com [10.3.116.107])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 324EC600C4;
	Thu,  7 Feb 2019 18:21:05 +0000 (UTC)
Date: Thu, 7 Feb 2019 13:21:04 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
Message-ID: <20190207132104.17a296da@doriath>
In-Reply-To: <20190204181552.12095.46287.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	<20190204181552.12095.46287.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 07 Feb 2019 18:21:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 04 Feb 2019 10:15:52 -0800
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Add guest support for providing free memory hints to the KVM hypervisor for
> freed pages huge TLB size or larger. I am restricting the size to
> huge TLB order and larger because the hypercalls are too expensive to be
> performing one per 4K page. Using the huge TLB order became the obvious
> choice for the order to use as it allows us to avoid fragmentation of higher
> order memory on the host.
> 
> I have limited the functionality so that it doesn't work when page
> poisoning is enabled. I did this because a write to the page after doing an
> MADV_DONTNEED would effectively negate the hint, so it would be wasting
> cycles to do so.
> 
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

Does this mean that the vCPU executing this will get stuck
here for the duration of the hypercall? Isn't that too long,
considering that the zone lock is taken and madvise in the
host block on semaphores?

> +}
> +
>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>  
>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> 

