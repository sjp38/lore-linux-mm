Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0CB8C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:17:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 896A1222B8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:17:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 896A1222B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26CB28E00EC; Mon, 11 Feb 2019 09:17:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21C228E00EB; Mon, 11 Feb 2019 09:17:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 131358E00EC; Mon, 11 Feb 2019 09:17:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB8FC8E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:17:22 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id v4so12789342qtp.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:17:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=17mLUiLoUITEf9onrIviV0lzmU8oz0sx09jONf+UW20=;
        b=cM94yNk0RYFZi5F6K7nU83AsUlOCjs7MvxJs5hzpcte6MHTqrAPwrC3aDAZKdLZDEV
         kkI86+DGTbXgYwq/hLa31ZWwzjwA+XZbpTBaX/cr/Ru7+x0YDCiChLwynTsb+cwSmSyg
         jb/I72GS+/TrsdUGEYvL57JmMe7nfX4lmI7pdEIPpcUEhyEo4bY4S8d6FdY6gZCPYqyk
         HnNoEEgSmQqNkhLGj6R8oM4tc9Y1CNwJ0LQQ9efKwUtHScQ5P/SS8gQvWgDaz5d9adXk
         aofdjxunycOXdtUXwm2F+7Ho6ITNH2RZ/SytylcIcfiWias145W4KqsYzfL6u1Y4xO7c
         IqsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYE1tpZYijjS6GuIzEAZbndTRk3ooIX2IpdWSypE2uHp8/zIiAn
	gmMlT+LWlnRDONn9FbmD4B3CiRXy9TtP1jIdxtv8cbmFUtbZPdTr/Wir5XYe1+c8D1kbiBwfCEC
	rURl+g5aHBJ3HDLc64tVM5825fiRpABT0FBXNaMJNplwjvN7kDVtzkSsOlhQBzJKDqUUYxNddsk
	IOQJtjOttwDukGML+3J0cWlAFwqDTb6ZFeu9Mi7XUOyYCGt4GsPygDEP0voKg57xvlLEKrykm/L
	wP0Rpf/zLD6PReKfMTMB6MmugeUew7yBddQNHPszN6woiqAacmPa97PwV3noAOe9+u+G0aaHfxI
	ruyDUMffY8hPSFBQrCMTN8n0nnOjMsYDWjBFLDp/TX6/IS08LhFh4BKEsvGEMgx3seEArRmYClx
	d
X-Received: by 2002:ac8:7412:: with SMTP id p18mr26602878qtq.176.1549894642646;
        Mon, 11 Feb 2019 06:17:22 -0800 (PST)
X-Received: by 2002:ac8:7412:: with SMTP id p18mr26602813qtq.176.1549894641804;
        Mon, 11 Feb 2019 06:17:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549894641; cv=none;
        d=google.com; s=arc-20160816;
        b=RRC7h4h8sxlxnR0GdQh4iWvBYRkqmTKMdMy/92l62EDeQFaRX9AuM05z3AnKI0XVBW
         oenHsGBNFpCxeu5C3iSRvgAf7ykDIVpOFeJmgh/GQdbBDKpMiLLne7ntYS76msH0Tl0C
         AGISJ7MhwOFezb6t5Hn70bNg6uMTL6evnQmCTa0tG9xuqq8D29WMKS12uXTvUloWze0o
         BRtIgy6kWlIRxnmxSabytAlGocZCGHM/MrzEmi+9Go17MpgXEnmFq8IHz0fwJzlDcTZ7
         HxGQUBUtvKc1CmWqlMOaqkNtUs4zV/IrzA/yoLtQ33XsVz6nKxooArYUvXs7TzqxCXlQ
         /+CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=17mLUiLoUITEf9onrIviV0lzmU8oz0sx09jONf+UW20=;
        b=UR/OzzdN2H+b8ZQBz8HdV/AwhMKUnxg2PULAp2ZvosQJJS1j1wf5cA8kBDpMWtBp9r
         Ur5aMIj8yda6JoPPxCEE9DKwSCpn+LroOxm/DaPsAqrB++L9hXCYLch0XGINHUE5nQiB
         DKy4ey/+P9CxGCN4oMFrAk1ZQ+48Rfk2h7ScJyhPX6kIHRZRBlmruw/c4u1i3JmYIntW
         wvhyi8gjOyI2LocxKIyVJtrS3auqKoI6fYCRi4C/i5SOtrqacZ7uDz210h2lg6KUqBwy
         +tUyCdxFby/6E4AgcI7nXsfkjcunwdX0xv+duJAQOKs+lUZukC+l1nbCDrFKqg2qumZY
         04og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j190sor2478893qke.8.2019.02.11.06.17.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 06:17:21 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IZHNkA+yEICcjctSDV0G+ePVrUCaJsYwvi7jE9zWEXLcAw/EgNpnXrqlt0CsBBF8u+BQUztdQ==
X-Received: by 2002:a37:c403:: with SMTP id d3mr4543650qki.54.1549894641430;
        Mon, 11 Feb 2019 06:17:21 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id r20sm5834424qtp.68.2019.02.11.06.17.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 06:17:20 -0800 (PST)
Date: Mon, 11 Feb 2019 09:17:18 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
Message-ID: <20190211091623-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
 <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:30:03AM -0500, Nitesh Narayan Lal wrote:
> 
> On 2/9/19 7:57 PM, Michael S. Tsirkin wrote:
> > On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
> >> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>
> >> Because the implementation was limiting itself to only providing hints on
> >> pages huge TLB order sized or larger we introduced the possibility for free
> >> pages to slip past us because they are freed as something less then
> >> huge TLB in size and aggregated with buddies later.
> >>
> >> To address that I am adding a new call arch_merge_page which is called
> >> after __free_one_page has merged a pair of pages to create a higher order
> >> page. By doing this I am able to fill the gap and provide full coverage for
> >> all of the pages huge TLB order or larger.
> >>
> >> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > Looks like this will be helpful whenever active free page
> > hints are added. So I think it's a good idea to
> > add a hook.
> >
> > However, could you split adding the hook to a separate
> > patch from the KVM hypercall based implementation?
> >
> > Then e.g. Nilal's patches could reuse it too.
> With the current design of my patch-set, if I use this hook to report
> free pages. I will end up making redundant hints for the same pfns.
> 
> This is because the pages once freed by the host, are returned back to
> the buddy.

Suggestions on how you'd like to fix this? You do need this if
you introduce a size cut-off right?

> >
> >
> >> ---
> >>  arch/x86/include/asm/page.h |   12 ++++++++++++
> >>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
> >>  include/linux/gfp.h         |    4 ++++
> >>  mm/page_alloc.c             |    2 ++
> >>  4 files changed, 46 insertions(+)
> >>
> >> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> >> index 4487ad7a3385..9540a97c9997 100644
> >> --- a/arch/x86/include/asm/page.h
> >> +++ b/arch/x86/include/asm/page.h
> >> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
> >>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >>  		__arch_free_page(page, order);
> >>  }
> >> +
> >> +struct zone;
> >> +
> >> +#define HAVE_ARCH_MERGE_PAGE
> >> +void __arch_merge_page(struct zone *zone, struct page *page,
> >> +		       unsigned int order);
> >> +static inline void arch_merge_page(struct zone *zone, struct page *page,
> >> +				   unsigned int order)
> >> +{
> >> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >> +		__arch_merge_page(zone, page, order);
> >> +}
> >>  #endif
> >>  
> >>  #include <linux/range.h>
> >> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> >> index 09c91641c36c..957bb4f427bb 100644
> >> --- a/arch/x86/kernel/kvm.c
> >> +++ b/arch/x86/kernel/kvm.c
> >> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
> >>  		       PAGE_SIZE << order);
> >>  }
> >>  
> >> +void __arch_merge_page(struct zone *zone, struct page *page,
> >> +		       unsigned int order)
> >> +{
> >> +	/*
> >> +	 * The merging logic has merged a set of buddies up to the
> >> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> >> +	 * advantage of this moment to notify the hypervisor of the free
> >> +	 * memory.
> >> +	 */
> >> +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> >> +		return;
> >> +
> >> +	/*
> >> +	 * Drop zone lock while processing the hypercall. This
> >> +	 * should be safe as the page has not yet been added
> >> +	 * to the buddy list as of yet and all the pages that
> >> +	 * were merged have had their buddy/guard flags cleared
> >> +	 * and their order reset to 0.
> >> +	 */
> >> +	spin_unlock(&zone->lock);
> >> +
> >> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> >> +		       PAGE_SIZE << order);
> >> +
> >> +	/* reacquire lock and resume freeing memory */
> >> +	spin_lock(&zone->lock);
> >> +}
> >> +
> >>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
> >>  
> >>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> >> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> >> index fdab7de7490d..4746d5560193 100644
> >> --- a/include/linux/gfp.h
> >> +++ b/include/linux/gfp.h
> >> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> >>  #ifndef HAVE_ARCH_FREE_PAGE
> >>  static inline void arch_free_page(struct page *page, int order) { }
> >>  #endif
> >> +#ifndef HAVE_ARCH_MERGE_PAGE
> >> +static inline void
> >> +arch_merge_page(struct zone *zone, struct page *page, int order) { }
> >> +#endif
> >>  #ifndef HAVE_ARCH_ALLOC_PAGE
> >>  static inline void arch_alloc_page(struct page *page, int order) { }
> >>  #endif
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index c954f8c1fbc4..7a1309b0b7c5 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
> >>  		page = page + (combined_pfn - pfn);
> >>  		pfn = combined_pfn;
> >>  		order++;
> >> +
> >> +		arch_merge_page(zone, page, order);
> >>  	}
> >>  	if (max_order < MAX_ORDER) {
> >>  		/* If we are here, it means order is >= pageblock_order.
> -- 
> Regards
> Nitesh
> 



