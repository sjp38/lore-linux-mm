Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9142EC4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 20:02:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46AE521721
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 20:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46AE521721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1DE8E0063; Thu,  7 Feb 2019 15:02:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7BBF8E0002; Thu,  7 Feb 2019 15:02:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B44A68E0063; Thu,  7 Feb 2019 15:02:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8222D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 15:02:39 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v64so1064239qka.5
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 12:02:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pnFWzImOoCKJOVougHoefMFBbDyHbsXZd3+mZnnIsd4=;
        b=Tda+fub/hByxolATHv5KY/+EvDGryGilZdc+iXAVnXyPsVqnZ2EmIgdM+1hEwZrIeb
         J/1xTYONTvjfwOx/PFVBRFGp2DdYNe1+wn9AidO1z+s3iP9u9aRYF+otpiBgUxgHatpk
         jF+Sl7O0EIJHGOMWZThVtg7hPtQIc6EqMjv+Ru4l2ENHBWMJ7zLsmxMRLZPKJklXY1yp
         kG/2Rt4Mwaag5904LJ9GIW5pPkYCqOYjMxfcgbRZOLDE51CbukiezZ08xTQvdapELW9f
         UxY+zqO+4cyg+DDQA5mVUwG5R7+H8xksxNc500TJJh5HST5d9p9XCnwwmVjf8wQ+xFlK
         Q2fA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub8bX/NC2TAOampsexbCmcr1IlywKJH27BCVGa4CM68yGf0TSPL
	QDYrLNkaElqehfOiWtW/A3wbqNOomIIdazchny0JG4lpTWPG8XRqG75jwLT3JQPP5G+TrdZY+ri
	pcc9GmDVBL0v3gELEqpeRdX6UrWZ6bgE34wI65T0fRjwczP93RaM1LZLTrXdXnvolGg==
X-Received: by 2002:aed:3b58:: with SMTP id q24mr2579216qte.227.1549569759261;
        Thu, 07 Feb 2019 12:02:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IboMFUeM2tQ78flUVXbJqDwQwTV8bmEmY5BYIpZPODr9bbnuzvqT13iwlJV0HFz1U3sPVem
X-Received: by 2002:aed:3b58:: with SMTP id q24mr2579164qte.227.1549569758512;
        Thu, 07 Feb 2019 12:02:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549569758; cv=none;
        d=google.com; s=arc-20160816;
        b=1LS+u4DhqSqs7OYO1MGiTKZdZQQfcwqZpP8Y6oEkFNqM+q65MQv6+Z9W9Wa8R7Hfft
         Ch4BHZZXG5IZvtEIzbuEuwttCQynIEqRJ0RCj+1a4V1Wdq5RoW7XBsNF9bpNlpilXi7J
         5xOBXuqHkDd7Uf6UFZX+SqkN7AwEED2uF7kn3Tivg8fPcjpjTsUCTcmG9V0XXaPZUysa
         IQIzVWfcSHykvH7Q/k0YX1MxG39bZYZhLXsoNM5WrfMJ0wnBwl/04Aq0p9SVKTIamDWr
         jW0R8V0JAgJF/XAFCtNbruwq7Bdc2fWkn0qpVEtu7IwOW9PmY+qOqw++/nUSDXyqoZYY
         Xd6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=pnFWzImOoCKJOVougHoefMFBbDyHbsXZd3+mZnnIsd4=;
        b=XE+HP6wbrt/L6W56QDPTpuSGkX9Xg7l7UGDwWIWNYnFJhRiOlLRuvLik7g6qYaq9ac
         RQmwLU+h8XDcz2M64kOwa/lnw41H4McJeFdhL+CWQLLD9iPiErw8afQSiFU7N73TG7oe
         ATNnRKUX6sWkb0AexJylveu3/NrzOUC1Bg2Hlbl2bDlopC98JR6MJIVG/O4WI8TV+jjE
         5/GCnTl0XR59Y9PmvCNqOwgDPQfpo6dqxgCjiZPLRQkzf8DiPLofZS+UVjHD5CkeV6yV
         UuQCPQpqip2MibOsQ/Mx7jvJFveyF0EwKE98HEeIefN1jRVnQV2Tqg8bt+pPdF7QEdnu
         jXMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o190si1412985qkd.50.2019.02.07.12.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 12:02:38 -0800 (PST)
Received-SPF: pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lcapitulino@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lcapitulino@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 67BD28666B;
	Thu,  7 Feb 2019 20:02:37 +0000 (UTC)
Received: from doriath (ovpn-116-107.phx2.redhat.com [10.3.116.107])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C1C2B600C3;
	Thu,  7 Feb 2019 20:02:35 +0000 (UTC)
Date: Thu, 7 Feb 2019 15:02:04 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck  <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
Message-ID: <20190207150204.7b305de7@doriath>
In-Reply-To: <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	<20190204181552.12095.46287.stgit@localhost.localdomain>
	<20190207132104.17a296da@doriath>
	<34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 07 Feb 2019 20:02:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 07 Feb 2019 10:44:11 -0800
Alexander Duyck <alexander.h.duyck@linux.intel.com> wrote:

> On Thu, 2019-02-07 at 13:21 -0500, Luiz Capitulino wrote:
> > On Mon, 04 Feb 2019 10:15:52 -0800
> > Alexander Duyck <alexander.duyck@gmail.com> wrote:
> >   
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > freed pages huge TLB size or larger. I am restricting the size to
> > > huge TLB order and larger because the hypercalls are too expensive to be
> > > performing one per 4K page. Using the huge TLB order became the obvious
> > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > order memory on the host.
> > > 
> > > I have limited the functionality so that it doesn't work when page
> > > poisoning is enabled. I did this because a write to the page after doing an
> > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > cycles to do so.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > ---
> > >  arch/x86/include/asm/page.h |   13 +++++++++++++
> > >  arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
> > >  2 files changed, 36 insertions(+)
> > > 
> > > diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> > > index 7555b48803a8..4487ad7a3385 100644
> > > --- a/arch/x86/include/asm/page.h
> > > +++ b/arch/x86/include/asm/page.h
> > > @@ -18,6 +18,19 @@
> > >  
> > >  struct page;
> > >  
> > > +#ifdef CONFIG_KVM_GUEST
> > > +#include <linux/jump_label.h>
> > > +extern struct static_key_false pv_free_page_hint_enabled;
> > > +
> > > +#define HAVE_ARCH_FREE_PAGE
> > > +void __arch_free_page(struct page *page, unsigned int order);
> > > +static inline void arch_free_page(struct page *page, unsigned int order)
> > > +{
> > > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > > +		__arch_free_page(page, order);
> > > +}
> > > +#endif
> > > +
> > >  #include <linux/range.h>
> > >  extern struct range pfn_mapped[];
> > >  extern int nr_pfn_mapped;
> > > diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> > > index 5c93a65ee1e5..09c91641c36c 100644
> > > --- a/arch/x86/kernel/kvm.c
> > > +++ b/arch/x86/kernel/kvm.c
> > > @@ -48,6 +48,7 @@
> > >  #include <asm/tlb.h>
> > >  
> > >  static int kvmapf = 1;
> > > +DEFINE_STATIC_KEY_FALSE(pv_free_page_hint_enabled);
> > >  
> > >  static int __init parse_no_kvmapf(char *arg)
> > >  {
> > > @@ -648,6 +649,15 @@ static void __init kvm_guest_init(void)
> > >  	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI))
> > >  		apic_set_eoi_write(kvm_guest_apic_eoi_write);
> > >  
> > > +	/*
> > > +	 * The free page hinting doesn't add much value if page poisoning
> > > +	 * is enabled. So we only enable the feature if page poisoning is
> > > +	 * no present.
> > > +	 */
> > > +	if (!page_poisoning_enabled() &&
> > > +	    kvm_para_has_feature(KVM_FEATURE_PV_UNUSED_PAGE_HINT))
> > > +		static_branch_enable(&pv_free_page_hint_enabled);
> > > +
> > >  #ifdef CONFIG_SMP
> > >  	smp_ops.smp_prepare_cpus = kvm_smp_prepare_cpus;
> > >  	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
> > > @@ -762,6 +772,19 @@ static __init int kvm_setup_pv_tlb_flush(void)
> > >  }
> > >  arch_initcall(kvm_setup_pv_tlb_flush);
> > >  
> > > +void __arch_free_page(struct page *page, unsigned int order)
> > > +{
> > > +	/*
> > > +	 * Limit hints to blocks no smaller than pageblock in
> > > +	 * size to limit the cost for the hypercalls.
> > > +	 */
> > > +	if (order < KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> > > +		return;
> > > +
> > > +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> > > +		       PAGE_SIZE << order);  
> > 
> > Does this mean that the vCPU executing this will get stuck
> > here for the duration of the hypercall? Isn't that too long,
> > considering that the zone lock is taken and madvise in the
> > host block on semaphores?  
> 
> I'm pretty sure the zone lock isn't held when this is called. The lock
> isn't acquired until later in the path. This gets executed just before
> the page poisoning call which would take time as well since it would
> have to memset an entire page. This function is called as a part of
> free_pages_prepare, the zone locks aren't acquired until we are calling
> into either free_one_page and a few spots before calling
> __free_one_page.

Yeah, you're right of course! I think mixed up __arch_free_page()
and __free_one_page()... free_pages() code path won't take any
locks up to calling __arch_free_page(). Sorry for the noise.

> My other function in patch 4 which does this from inside of
> __free_one_page does have to release the zone lock since it is taken
> there.

I haven't checked that one yet, I'll let you know if I have comments.

