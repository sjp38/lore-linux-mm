Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A02F5C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B2E421B18
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:58:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B2E421B18
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07FF8E00F4; Mon, 11 Feb 2019 10:58:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D91D08E00E9; Mon, 11 Feb 2019 10:58:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C32FA8E00F4; Mon, 11 Feb 2019 10:58:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFC48E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:58:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l76so10120628pfg.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:58:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q30GnaniTrg7kIY7fBNLlyCuQ47JKmP6sHOl3fLaWgA=;
        b=gd+K+sl1FOku7DSa0oOjj8ddkc4eBOmLfjqOV4hTTotvOQHZlirUXq0V+qIKLpvbST
         ToFt3VheFJxBQWWWD0sRTiZhke/6g4yWM1GvD9R/lQ3ioP+Or2FJGnIwYB25ZVPIjx1s
         i0JJow9qSPEo4bN1AEyoI2Iq+2vsUzCT4Lnp6s2kwH2Jj9AyZk9AXXh6Sw1H5kKi6u4z
         90a1e+4x6iceZ3uSNRjsMUjjMSHdQMEFd/pUzrUFEXf8ZFk/kcTOSctxQd55yBu0j65J
         SUFbcIi/T9W81y/F8xyM1MK3Mnkec7nBn83FdYxfRBcraXQBX8wGU5OzmM7W9BvhxQtu
         YD/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYAqphFpBK3fMpKFSf6CiwPu2fL8siTLyOAj6BgjWYaHdceClS4
	I0uuE5FOwlFaYmiPZ5sZxbSbOoIDMAsKyKBnjIkvFx583CBebbrGpty1E0J1TpWXs0u2xAE3G3Z
	weQTxq+nS6PhUlwOeugWlwj36JMWvTSD5YFjcW5sRDB4idJvOypSBZrGobmNy5UwKEA==
X-Received: by 2002:a65:4381:: with SMTP id m1mr33384687pgp.358.1549900710149;
        Mon, 11 Feb 2019 07:58:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9gIJoMCQa3jaMrH77JyidtlnOcCrJNgRD5U+QIeH1mXR2HRphx7jbLBH2CstCosY/TAVa
X-Received: by 2002:a65:4381:: with SMTP id m1mr33384622pgp.358.1549900708937;
        Mon, 11 Feb 2019 07:58:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549900708; cv=none;
        d=google.com; s=arc-20160816;
        b=DJHfHVKI6m/WLYt0MCt5/M8szdMcljXKTkZmfAZHMr+C7g8pyCiz2D+c03Qi8tTMsd
         BCIvnghOePIllwQ+dXSvb7EO9Czb+3Bt9/rsV/z/u92WqCVhgDxl2RWCyEaHtrna9yn+
         SXlO54NB7zUhIPqzEd/L/Lnaw7Y2kRYKaf1+MqSW8CJnSDr5dSDo1P+qbdNImvzvbKtI
         T1O8QvxASvEq1SQFPKoMllD+yiHRIpKuDyTLRDuw8fABeJQ59CjdQoM+ooELqHrzIbKr
         2gdoh6E8lawpOK8UEorOrSnQMJSxuoSZtn6E0GbMKwXj84H6SOzNBo7PadLlnn2kPAu0
         KrKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=q30GnaniTrg7kIY7fBNLlyCuQ47JKmP6sHOl3fLaWgA=;
        b=yn7ew4EkRV12WFNPnuaIXbf+LX6BFLBc/bevj+zHqmRDv9nPs9MeQyvAiq6shTfEHg
         L2SBkfYVF0L8V2J06Cp6z2ZnpLYUp00BWfX05mMFOeUOs92b92fOWMWWdr4WwWQvaHvf
         Uk7HxqPpHNlwDLprwwDXDxDHHK9zIHfrfF/wCBMi5pLDYxGmct6PVWbXDQbSbfjAO1De
         /3Pf0GU96MKzDj304FpvIOuZxYZGfmaUJykArZCiMRrYuZaASc7yiXcmmfqRIzz6nqh5
         /gEkG2PoY/ajNtAyCL5AFb0oKgyaa+XneqitWoOLce/95w/iVVjSnwEixRD6oA7/GeTz
         QECA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j192si9983499pgc.415.2019.02.11.07.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:58:28 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 07:58:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="115325426"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006.jf.intel.com with ESMTP; 11 Feb 2019 07:58:28 -0800
Message-ID: <a5b698b0f85667dba9b949dcb6e65a0d806669de.camel@linux.intel.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Aaron Lu <aaron.lwe@gmail.com>, Alexander Duyck
 <alexander.duyck@gmail.com>,  linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 07:58:28 -0800
In-Reply-To: <5e6d22b2-0f14-43eb-846b-a940e629c02b@gmail.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181558.12095.83484.stgit@localhost.localdomain>
	 <5e6d22b2-0f14-43eb-846b-a940e629c02b@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-11 at 14:40 +0800, Aaron Lu wrote:
> On 2019/2/5 2:15, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Because the implementation was limiting itself to only providing hints on
> > pages huge TLB order sized or larger we introduced the possibility for free
> > pages to slip past us because they are freed as something less then
> > huge TLB in size and aggregated with buddies later.
> > 
> > To address that I am adding a new call arch_merge_page which is called
> > after __free_one_page has merged a pair of pages to create a higher order
> > page. By doing this I am able to fill the gap and provide full coverage for
> > all of the pages huge TLB order or larger.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  arch/x86/include/asm/page.h |   12 ++++++++++++
> >  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
> >  include/linux/gfp.h         |    4 ++++
> >  mm/page_alloc.c             |    2 ++
> >  4 files changed, 46 insertions(+)
> > 
> > diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> > index 4487ad7a3385..9540a97c9997 100644
> > --- a/arch/x86/include/asm/page.h
> > +++ b/arch/x86/include/asm/page.h
> > @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
> >  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >  		__arch_free_page(page, order);
> >  }
> > +
> > +struct zone;
> > +
> > +#define HAVE_ARCH_MERGE_PAGE
> > +void __arch_merge_page(struct zone *zone, struct page *page,
> > +		       unsigned int order);
> > +static inline void arch_merge_page(struct zone *zone, struct page *page,
> > +				   unsigned int order)
> > +{
> > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > +		__arch_merge_page(zone, page, order);
> > +}
> >  #endif
> >  
> >  #include <linux/range.h>
> > diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> > index 09c91641c36c..957bb4f427bb 100644
> > --- a/arch/x86/kernel/kvm.c
> > +++ b/arch/x86/kernel/kvm.c
> > @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
> >  		       PAGE_SIZE << order);
> >  }
> >  
> > +void __arch_merge_page(struct zone *zone, struct page *page,
> > +		       unsigned int order)
> > +{
> > +	/*
> > +	 * The merging logic has merged a set of buddies up to the
> > +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> > +	 * advantage of this moment to notify the hypervisor of the free
> > +	 * memory.
> > +	 */
> > +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> > +		return;
> > +
> > +	/*
> > +	 * Drop zone lock while processing the hypercall. This
> > +	 * should be safe as the page has not yet been added
> > +	 * to the buddy list as of yet and all the pages that
> > +	 * were merged have had their buddy/guard flags cleared
> > +	 * and their order reset to 0.
> > +	 */
> > +	spin_unlock(&zone->lock);
> > +
> > +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> > +		       PAGE_SIZE << order);
> > +
> > +	/* reacquire lock and resume freeing memory */
> > +	spin_lock(&zone->lock);
> > +}
> > +
> >  #ifdef CONFIG_PARAVIRT_SPINLOCKS
> >  
> >  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index fdab7de7490d..4746d5560193 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> >  #ifndef HAVE_ARCH_FREE_PAGE
> >  static inline void arch_free_page(struct page *page, int order) { }
> >  #endif
> > +#ifndef HAVE_ARCH_MERGE_PAGE
> > +static inline void
> > +arch_merge_page(struct zone *zone, struct page *page, int order) { }
> > +#endif
> >  #ifndef HAVE_ARCH_ALLOC_PAGE
> >  static inline void arch_alloc_page(struct page *page, int order) { }
> >  #endif
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c954f8c1fbc4..7a1309b0b7c5 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
> >  		page = page + (combined_pfn - pfn);
> >  		pfn = combined_pfn;
> >  		order++;
> > +
> > +		arch_merge_page(zone, page, order);
> 
> Not a proper place AFAICS.
> 
> Assume we have an order-8 page being sent here for merge and its order-8
> buddy is also free, then order++ became 9 and arch_merge_page() will do
> the hint to host on this page as an order-9 page, no problem so far.
> Then the next round, assume the now order-9 page's buddy is also free,
> order++ will become 10 and arch_merge_page() will again hint to host on
> this page as an order-10 page. The first hint to host became redundant.

Actually the problem is even worse the other way around. My concern was
pages being incrementally freed.

With this setup I can catch when we have crossed the threshold from
order 8 to 9, and specifically for that case provide the hint. This
allows me to ignore orders above and below 9.

If I move the hint to the spot after the merging I have no way of
telling if I have hinted the page as a lower order or not. As such I
will hint if it is merged up to orders 9 or greater. So for example if
it merges up to order 9 and stops there then done_merging will report
an order 9 page, then if another page is freed and merged with this up
to order 10 you would be hinting on order 10. By placing the function
here I can guarantee that no more than 1 hint is provided per 2MB page.

> I think the proper place is after the done_merging tag.
> 
> BTW, with arch_merge_page() at the proper place, I don't think patch3/4
> is necessary - any freed page will go through merge anyway, we won't
> lose any hint opportunity. Or do I miss anything?

You can refer to my comment above. What I want to avoid is us hinting a
page multiple times if we aren't using MAX_ORDER - 1 as the limit. What
I am avoiding by placing this where I did is us doing a hint on orders
greater than our target hint order. So with this way I only perform one
hint per 2MB page, otherwise I would be performing multiple hints per
2MB page as every order above that would also trigger hints.

