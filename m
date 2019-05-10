Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DEB8C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:26:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0E71217F5
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:26:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E71217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584D06B0003; Fri, 10 May 2019 19:26:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5348A6B0005; Fri, 10 May 2019 19:26:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 422AE6B0006; Fri, 10 May 2019 19:26:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08F3A6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 19:26:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f8so5012867pgp.9
        for <linux-mm@kvack.org>; Fri, 10 May 2019 16:26:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=e6pKgG1J6coIhN78Q0ADlQG6CLqCCPgPIklHE+JMvzw=;
        b=P+E9dQq9MeUks6mhpCnHaI+slDbx51fVnl3pCy6tzDle7+hZsshCu92u+f9/cKNf87
         0kzvyN44rdSMEYkqQBvw0VlIYsq4lrvUbwLuEKJnMzbsBYIqah/hTSOB2rrWL8D2eXEE
         YI2fM84j/2r9LAJrmdrcGD02A2oXvjuLW5BGUh4lh6u0rgARi/96E3b1oCpAjm6GG8Kh
         bbXzdEkkLNSh9IdU8OI39+qL1dxh2cddDW7weSSaTXm9sYUzFwUZ/Ma/s9YT+rtlvQxz
         uvk0dU8Mhm4JYYHXwBAE6ai6nDa7UABGT5bCtT+p0az52D+1C+edMnmiWuohvpR2XhbM
         dNPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWnsLzMT876IhVMP/q45YY+EbrY2AicwhLkxrYPYEXEo+RSjU38
	qy5OylcZsEg1zZLxf6k0/IVNHZX6vyYmC/vDxr1B8hBc4SSviyAkiuHvqHu4Sl2giOEUwQMWpol
	aZrX53y0ZAMGH43lbgXjwKvOcnEq98lc9DvHBXNV7s1XKZc8NVXVDQaWz1YoiYVGZVA==
X-Received: by 2002:a65:6255:: with SMTP id q21mr5788604pgv.211.1557530775451;
        Fri, 10 May 2019 16:26:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8ix63b+kSPRbp1mQKG48UBojAwzp9AO4QIlYtDbQYC/8q/854sEvywgxaUt1j9AoEMzok
X-Received: by 2002:a65:6255:: with SMTP id q21mr5788568pgv.211.1557530774626;
        Fri, 10 May 2019 16:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557530774; cv=none;
        d=google.com; s=arc-20160816;
        b=jbBGYZfl3PAdY3rDXjT90VVefUKOhlRFjTc/keePmJcRPt+Oo+cf66rlCGzJh679xw
         j1SpxCa64tioesoIYmbJhDrlpzlXW4i4Vy7FHvm+w2WII7GYfEZJtmGP78XbD0wzmxef
         v4krpJ+rmSxF34ENJSvHHo9837GxDY/EyZAi/gOiPq1dIeEl7mWTp5kla7NHMNYPbLQb
         dI77p3iXnQ1dllyq2/Fhu6b/YX/9NBpE1IxGMAKzic7QpOkd/Fr94f9cKG0HE2e9KEKg
         X6WGAUeHVvJ2Z8fSCZyflElQwXKLOSBe3Xtr4dt1fZHgj+ngdTNSG/HGhaX3rTegL0HW
         uHMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=e6pKgG1J6coIhN78Q0ADlQG6CLqCCPgPIklHE+JMvzw=;
        b=tfOa9eraHGk5qGnWUaG6Syff2lusTMPOEY5Vi9FIgisiIC4NII4Ov59AhHdkUWQfp2
         5o3xksMIFqQsRqmVlkCO7TLalxJgnolP3S6wNuh5e3QRlBjOmkoFU5RB08u0IP3tEUUW
         0ATZEypNxSDeoTRtxcbHWVH1ywqiVWO8UxsSlXhhzFzAYYN0NQlxRxp3y4bZYH/0b2GC
         jItav1g8Ju2URWREOYR7r+zxgAiQTWMGy7BiT/OYYfWYn9DpkPGbhyIXzLWeOVsGqeLc
         q05q8o08+oKdfl1YZX+RmQk6CG/ilTfY21kK4785PORdgIGJHC8QBwzvWO084P37OcOV
         9WWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f71si8658878pgc.150.2019.05.10.16.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 16:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 16:26:14 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 10 May 2019 16:26:13 -0700
Date: Fri, 10 May 2019 16:26:50 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH v2 14/15] mm: Pass order to try_to_free_pages in GFP flags
Message-ID: <20190510232650.GA14369@iweiny-DESK2.sc.intel.com>
References: <20190510135038.17129-1-willy@infradead.org>
 <20190510135038.17129-15-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510135038.17129-15-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 06:50:37AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Also remove the order argument from __perform_reclaim() and
> __alloc_pages_direct_reclaim() which only passed the argument down.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  include/linux/swap.h          |  2 +-
>  include/trace/events/vmscan.h | 20 +++++++++-----------
>  mm/page_alloc.c               | 15 ++++++---------
>  mm/vmscan.c                   | 13 ++++++-------
>  4 files changed, 22 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 4bfb5c4ac108..029737fec38b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -348,7 +348,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>  
>  /* linux/mm/vmscan.c */
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> -extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> +extern unsigned long try_to_free_pages(struct zonelist *zonelist,
>  					gfp_t gfp_mask, nodemask_t *mask);
>  extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
>  extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a5ab2973e8dc..a6b1b20333b4 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -100,45 +100,43 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
>  
>  DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
>  
> -	TP_PROTO(int order, gfp_t gfp_flags),
> +	TP_PROTO(gfp_t gfp_flags),
>  
> -	TP_ARGS(order, gfp_flags),
> +	TP_ARGS(gfp_flags),
>  
>  	TP_STRUCT__entry(
> -		__field(	int,	order		)
>  		__field(	gfp_t,	gfp_flags	)
>  	),
>  
>  	TP_fast_assign(
> -		__entry->order		= order;
>  		__entry->gfp_flags	= gfp_flags;
>  	),
>  
>  	TP_printk("order=%d gfp_flags=%s",
> -		__entry->order,
> +		gfp_order(__entry->gfp_flags),
>  		show_gfp_flags(__entry->gfp_flags))
>  );
>  
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
>  
> -	TP_PROTO(int order, gfp_t gfp_flags),
> +	TP_PROTO(gfp_t gfp_flags),
>  
> -	TP_ARGS(order, gfp_flags)
> +	TP_ARGS(gfp_flags)
>  );
>  
>  #ifdef CONFIG_MEMCG
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
>  
> -	TP_PROTO(int order, gfp_t gfp_flags),
> +	TP_PROTO(gfp_t gfp_flags),
>  
> -	TP_ARGS(order, gfp_flags)
> +	TP_ARGS(gfp_flags)
>  );
>  
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
>  
> -	TP_PROTO(int order, gfp_t gfp_flags),
> +	TP_PROTO(gfp_t gfp_flags),
>  
> -	TP_ARGS(order, gfp_flags)
> +	TP_ARGS(gfp_flags)
>  );
>  #endif /* CONFIG_MEMCG */
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d457dfa8a0ac..29daaf4ae4fb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4024,9 +4024,7 @@ EXPORT_SYMBOL_GPL(fs_reclaim_release);
>  #endif
>  
>  /* Perform direct synchronous page reclaim */
> -static int
> -__perform_reclaim(gfp_t gfp_mask, unsigned int order,
> -					const struct alloc_context *ac)
> +static int __perform_reclaim(gfp_t gfp_mask, const struct alloc_context *ac)
>  {
>  	struct reclaim_state reclaim_state;
>  	int progress;
> @@ -4043,8 +4041,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  	reclaim_state.reclaimed_slab = 0;
>  	current->reclaim_state = &reclaim_state;
>  
> -	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
> -								ac->nodemask);
> +	progress = try_to_free_pages(ac->zonelist, gfp_mask, ac->nodemask);
>  
>  	current->reclaim_state = NULL;
>  	memalloc_noreclaim_restore(noreclaim_flag);
> @@ -4058,14 +4055,14 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  
>  /* The really slow allocator path where we enter direct reclaim */
>  static inline struct page *
> -__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> -		unsigned int alloc_flags, const struct alloc_context *ac,
> +__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int alloc_flags,
> +		const struct alloc_context *ac,
>  		unsigned long *did_some_progress)
>  {
>  	struct page *page = NULL;
>  	bool drained = false;
>  
> -	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
> +	*did_some_progress = __perform_reclaim(gfp_mask, ac);
>  	if (unlikely(!(*did_some_progress)))
>  		return NULL;
>  
> @@ -4458,7 +4455,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto nopage;
>  
>  	/* Try direct reclaim and then allocating */
> -	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> +	page = __alloc_pages_direct_reclaim(gfp_mask, alloc_flags, ac,
>  							&did_some_progress);
>  	if (page)
>  		goto got_pg;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e873eca6..e4d4d9c1d7a9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3182,15 +3182,15 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  	return false;
>  }
>  
> -unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> -				gfp_t gfp_mask, nodemask_t *nodemask)
> +unsigned long try_to_free_pages(struct zonelist *zonelist, gfp_t gfp_mask,
> +		nodemask_t *nodemask)
>  {
>  	unsigned long nr_reclaimed;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.gfp_mask = current_gfp_context(gfp_mask),
>  		.reclaim_idx = gfp_zone(gfp_mask),
> -		.order = order,
> +		.order = gfp_order(gfp_mask),

NIT: Could we remove order from scan_control?

Ira

>  		.nodemask = nodemask,
>  		.priority = DEF_PRIORITY,
>  		.may_writepage = !laptop_mode,
> @@ -3215,7 +3215,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>  		return 1;
>  
> -	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
> +	trace_mm_vmscan_direct_reclaim_begin(sc.gfp_mask);
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>  
> @@ -3244,8 +3244,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>  
> -	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> -						      sc.gfp_mask);
> +	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.gfp_mask);
>  
>  	/*
>  	 * NOTE: Although we can get the priority field, using it
> @@ -3294,7 +3293,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  
>  	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
>  
> -	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
> +	trace_mm_vmscan_memcg_reclaim_begin(sc.gfp_mask);
>  
>  	psi_memstall_enter(&pflags);
>  	noreclaim_flag = memalloc_noreclaim_save();
> -- 
> 2.20.1
> 

