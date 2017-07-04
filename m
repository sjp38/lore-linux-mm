Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51ACC6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 02:51:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v60so44627415wrc.7
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 23:51:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u143si6598741wmu.44.2017.07.03.23.51.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 23:51:16 -0700 (PDT)
Date: Tue, 4 Jul 2017 08:51:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170704065112.GA12068@dhcp22.suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <20170630154224.GA9714@dhcp22.suse.cz>
 <20170630154416.GB9714@dhcp22.suse.cz>
 <20170704051138.GA28589@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170704051138.GA28589@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 04-07-17 14:11:41, Joonsoo Kim wrote:
> On Fri, Jun 30, 2017 at 05:44:16PM +0200, Michal Hocko wrote:
> > On Fri 30-06-17 17:42:24, Michal Hocko wrote:
> > [...]
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 16532fa0bb64..894697c1e6f5 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
> > >  	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> > >  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
> > >  {
> > > +	BUILD_BUG_ON(!IS_ENABLED(CONFIG_NUMA));
> > 
> > Err, this should read BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA)) of course
> 
> Agreed.
> 
> However, AFAIK, ARM can set CONFIG_NUMA but it doesn't have
> CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID and CONFIG_HAVE_MEMBLOCK_NODE_MAP.

$ git grep "config NUMA\|select NUMA" arch/arm
$

Did you mean arch64? If yes this one looks ok
$ git grep "HAVE_MEMBLOCK_NODE_MAP\|HAVE_ARCH_EARLY_PFN_TO_NID" arch/arm64/
arch/arm64/Kconfig:     select HAVE_MEMBLOCK_NODE_MAP if NUMA

> If page_ext uses early_pfn_to_nid(), it will cause build error in ARM.

Which would be intentional if it doesn't provide a proper implementation
of the function.
 
> Therefore, I suggest following change.
> CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on proper early_pfn_to_nid().
> So, following code will always work as long as
> CONFIG_DEFERRED_STRUCT_PAGE_INIT works.

I haven't checked all other callers of early_pfn_to_nid yet but I have
run my original patch (with !IS_ENABLED...) just to see whether anybody
actually uses this function from an innvalid context and it hasn't blown
up. So I suspect that all current users simply use the function from the
proper context. So if nobody objects I would just post the patch for
inclusion. If the compilation breaks we can think of a proper
implementation.

> 
> Thanks.
> 
> ----------->8---------------
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 88ccc044..e3db259 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -384,6 +384,7 @@ void __init page_ext_init(void)
>  
>         for_each_node_state(nid, N_MEMORY) {
>                 unsigned long start_pfn, end_pfn;
> +               int page_nid;
>  
>                 start_pfn = node_start_pfn(nid);
>                 end_pfn = node_end_pfn(nid);
> @@ -405,8 +406,15 @@ void __init page_ext_init(void)
>                          *
>                          * Take into account DEFERRED_STRUCT_PAGE_INIT.
>                          */
> -                       if (early_pfn_to_nid(pfn) != nid)
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +                       page_nid = early_pfn_to_nid(pfn);
> +#else
> +                       page_nid = pfn_to_nid(pfn);
> +#endif

I cannot say I would be happy about this ifdefery. Especially when there
is no existing user which would need it. 

> +
> +                       if (page_nid != nid)
>                                 continue;
> +
>                         if (init_section_page_ext(pfn, nid))
>                                 goto oom;
>                 }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
