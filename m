Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 899A3C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:41:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47712218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47712218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AB5C8E0114; Mon, 11 Feb 2019 12:41:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5341E8E0111; Mon, 11 Feb 2019 12:41:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D52B8E0114; Mon, 11 Feb 2019 12:41:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAE58E0111
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:41:20 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k37so13695850qtb.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:41:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=KKQvcF0oLxwEocMRsqRiTYer1w+ohxCcDbTPut2AcyU=;
        b=Ip1JBMmIpPBGAszhIzyyRqFQcXOh5MelCOdAeI6cUjHf5O8Gq6GIfxICYVLee/Z08V
         sAsJKk4JHpFXA78IvUDEhnqhBNz1jWi3lkllgAAy8UGAtj3BylwnuruO2bfAFyvATVIo
         gc5rBVuEdRcztsOjV/UpItSsE3Oq3PZg61slLt5YdtO4Mq41VCbbQIwJ8xzonnrxYNsU
         8I030OTbtFONJCfSFHOwXxjrRWizVDlPxyLbwVnZsNbuG9SkzoOOxBl2alEVLcVCOJf/
         LCDUjEz6RIuZg65ulmXQdW4Ayzu5KCE1rmHTalm/cByeUQyp3T9atUsc/x76IASiQMYT
         qGUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubjcPG+nLYkw8d8ZWy3oqfe2wsD0AuIrQg0MO//7SYNyP/zlHr/
	7N9crFYoKOI8VHlRyYjTCrAW80REt8fPSmxa0nQc4IKfsublAwU8ENhvxvSLErFiPk8YzwMgo97
	W+5y0pD5yEXOEuv9PXo3T6YeDyTPv2VTMuxGWvqd+jsto4K/D5lBh4lc7LTPY9lIk1Q==
X-Received: by 2002:ac8:25d9:: with SMTP id f25mr9513213qtf.156.1549906879825;
        Mon, 11 Feb 2019 09:41:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IachIFI52k1iSn8dUV9Ev5s8qPSi2j0N0U9TarHiNpX+vfjp68rXxevtnqrAlxj0AIq4EL1
X-Received: by 2002:ac8:25d9:: with SMTP id f25mr9513180qtf.156.1549906879151;
        Mon, 11 Feb 2019 09:41:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906879; cv=none;
        d=google.com; s=arc-20160816;
        b=RdrcHjuP9o6ks6Z83Dz5hrIP2qGQUNfPKBAhGEiG3Nwj0FiyOXiNx5J6vKCOjntnD2
         5lPf+cow6rOeltTANbudjdXZALyu2xv2UpawVBO71G30LqtOI6IC95aN+fkiC4bGzV2W
         HncNKqza3wyT9FGIRC8JLoWcwDwfo/gB3gI5ayk005tdpNcmIol9lEOKJmonU1WQHrEN
         DJcgIuEkJZLJvYAzdVK1tmiH8Hx16TU7iGaCFbjvuy6OqKuorsZ5Uz0fH7zUR6BmrHYm
         r13IX41ECiT+PHdx2A9A10UDjac/BiOq1cSJ7P1i68QJs0DDLcH9susuFcIT3ALMJHyS
         hM+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=KKQvcF0oLxwEocMRsqRiTYer1w+ohxCcDbTPut2AcyU=;
        b=fnxSEAS7j+wTip+nT4UZPlS+atxc6XrtNQLIDMJRhVkBXT0zcS3lgOyorvSHAe1PxY
         3L6kiGB7sj7EoY9fl08YPfR8R83wEneKgMca/fXWY23Os+NGphCmV5kpHA6uIkc6+VOG
         WIjSvLwePqSvuMcqCPDeRHBXolQseYgiUtq6UggcW1NsK4ka+gTin7eR0mbilC3Ouz7h
         BCd8C38RKu1sNeORyxPwE2x6LfLsxABcG6DCRybZuDXg/ZtnJVUwXyNgOzJhA5SezOvX
         5cjWLANZjXR4ma1F1Z61mbo8ZLO/Mruh3uQkxn+kfu1yno3T4Rd8jA5a+ixT7XCi91A3
         AO5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t126si2919271qkc.5.2019.02.11.09.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:41:19 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 08DE5C01DE19;
	Mon, 11 Feb 2019 17:41:18 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A7962D321;
	Mon, 11 Feb 2019 17:41:08 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:41:08 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
Message-ID: <20190211123815-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
 <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
 <20190211091623-mutt-send-email-mst@kernel.org>
 <ac61d035-7c7b-bfec-c78b-b9387c40d3ea@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ac61d035-7c7b-bfec-c78b-b9387c40d3ea@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 11 Feb 2019 17:41:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:24:02AM -0500, Nitesh Narayan Lal wrote:
> 
> On 2/11/19 9:17 AM, Michael S. Tsirkin wrote:
> > On Mon, Feb 11, 2019 at 08:30:03AM -0500, Nitesh Narayan Lal wrote:
> >> On 2/9/19 7:57 PM, Michael S. Tsirkin wrote:
> >>> On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
> >>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>>>
> >>>> Because the implementation was limiting itself to only providing hints on
> >>>> pages huge TLB order sized or larger we introduced the possibility for free
> >>>> pages to slip past us because they are freed as something less then
> >>>> huge TLB in size and aggregated with buddies later.
> >>>>
> >>>> To address that I am adding a new call arch_merge_page which is called
> >>>> after __free_one_page has merged a pair of pages to create a higher order
> >>>> page. By doing this I am able to fill the gap and provide full coverage for
> >>>> all of the pages huge TLB order or larger.
> >>>>
> >>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>> Looks like this will be helpful whenever active free page
> >>> hints are added. So I think it's a good idea to
> >>> add a hook.
> >>>
> >>> However, could you split adding the hook to a separate
> >>> patch from the KVM hypercall based implementation?
> >>>
> >>> Then e.g. Nilal's patches could reuse it too.
> >> With the current design of my patch-set, if I use this hook to report
> >> free pages. I will end up making redundant hints for the same pfns.
> >>
> >> This is because the pages once freed by the host, are returned back to
> >> the buddy.
> > Suggestions on how you'd like to fix this? You do need this if
> > you introduce a size cut-off right?
> 
> I do, there are two ways to go about it.
> 
> One is to  use this and have a flag in the page structure indicating
> whether that page has been freed/used or not.

Not sure what do you mean. The refcount does this right?

> Though I am not sure if
> this will be acceptable upstream.
> Second is to find another place to invoke guest_free_page() post buddy
> merging.

Might be easier.

> >
> >>>
> >>>> ---
> >>>>  arch/x86/include/asm/page.h |   12 ++++++++++++
> >>>>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
> >>>>  include/linux/gfp.h         |    4 ++++
> >>>>  mm/page_alloc.c             |    2 ++
> >>>>  4 files changed, 46 insertions(+)
> >>>>
> >>>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> >>>> index 4487ad7a3385..9540a97c9997 100644
> >>>> --- a/arch/x86/include/asm/page.h
> >>>> +++ b/arch/x86/include/asm/page.h
> >>>> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
> >>>>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >>>>  		__arch_free_page(page, order);
> >>>>  }
> >>>> +
> >>>> +struct zone;
> >>>> +
> >>>> +#define HAVE_ARCH_MERGE_PAGE
> >>>> +void __arch_merge_page(struct zone *zone, struct page *page,
> >>>> +		       unsigned int order);
> >>>> +static inline void arch_merge_page(struct zone *zone, struct page *page,
> >>>> +				   unsigned int order)
> >>>> +{
> >>>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >>>> +		__arch_merge_page(zone, page, order);
> >>>> +}
> >>>>  #endif
> >>>>  
> >>>>  #include <linux/range.h>
> >>>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> >>>> index 09c91641c36c..957bb4f427bb 100644
> >>>> --- a/arch/x86/kernel/kvm.c
> >>>> +++ b/arch/x86/kernel/kvm.c
> >>>> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
> >>>>  		       PAGE_SIZE << order);
> >>>>  }
> >>>>  
> >>>> +void __arch_merge_page(struct zone *zone, struct page *page,
> >>>> +		       unsigned int order)
> >>>> +{
> >>>> +	/*
> >>>> +	 * The merging logic has merged a set of buddies up to the
> >>>> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> >>>> +	 * advantage of this moment to notify the hypervisor of the free
> >>>> +	 * memory.
> >>>> +	 */
> >>>> +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> >>>> +		return;
> >>>> +
> >>>> +	/*
> >>>> +	 * Drop zone lock while processing the hypercall. This
> >>>> +	 * should be safe as the page has not yet been added
> >>>> +	 * to the buddy list as of yet and all the pages that
> >>>> +	 * were merged have had their buddy/guard flags cleared
> >>>> +	 * and their order reset to 0.
> >>>> +	 */
> >>>> +	spin_unlock(&zone->lock);
> >>>> +
> >>>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> >>>> +		       PAGE_SIZE << order);
> >>>> +
> >>>> +	/* reacquire lock and resume freeing memory */
> >>>> +	spin_lock(&zone->lock);
> >>>> +}
> >>>> +
> >>>>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
> >>>>  
> >>>>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> >>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> >>>> index fdab7de7490d..4746d5560193 100644
> >>>> --- a/include/linux/gfp.h
> >>>> +++ b/include/linux/gfp.h
> >>>> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> >>>>  #ifndef HAVE_ARCH_FREE_PAGE
> >>>>  static inline void arch_free_page(struct page *page, int order) { }
> >>>>  #endif
> >>>> +#ifndef HAVE_ARCH_MERGE_PAGE
> >>>> +static inline void
> >>>> +arch_merge_page(struct zone *zone, struct page *page, int order) { }
> >>>> +#endif
> >>>>  #ifndef HAVE_ARCH_ALLOC_PAGE
> >>>>  static inline void arch_alloc_page(struct page *page, int order) { }
> >>>>  #endif
> >>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>>> index c954f8c1fbc4..7a1309b0b7c5 100644
> >>>> --- a/mm/page_alloc.c
> >>>> +++ b/mm/page_alloc.c
> >>>> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
> >>>>  		page = page + (combined_pfn - pfn);
> >>>>  		pfn = combined_pfn;
> >>>>  		order++;
> >>>> +
> >>>> +		arch_merge_page(zone, page, order);
> >>>>  	}
> >>>>  	if (max_order < MAX_ORDER) {
> >>>>  		/* If we are here, it means order is >= pageblock_order.
> >> -- 
> >> Regards
> >> Nitesh
> >>
> >
> >
> -- 
> Regards
> Nitesh
> 



