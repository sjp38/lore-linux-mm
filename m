Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7860A6B03E7
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 02:51:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p64so2496884wrc.8
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 23:51:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si907303wrc.356.2017.07.05.23.51.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 23:51:10 -0700 (PDT)
Date: Thu, 6 Jul 2017 08:50:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disallow early_pfn_to_nid on configurations which do
 not implement it
Message-ID: <20170706065055.GB29724@dhcp22.suse.cz>
References: <20170704075803.15979-1-mhocko@kernel.org>
 <20170705160055.013fa5ff34bdf1f6efa4e6ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705160055.013fa5ff34bdf1f6efa4e6ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 05-07-17 16:00:55, Andrew Morton wrote:
> On Tue,  4 Jul 2017 09:58:03 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > early_pfn_to_nid will return node 0 if both HAVE_ARCH_EARLY_PFN_TO_NID
> > and HAVE_MEMBLOCK_NODE_MAP are disabled. It seems we are safe now
> > because all architectures which support NUMA define one of them (with an
> > exception of alpha which however has CONFIG_NUMA marked as broken) so
> > this works as expected. It can get silently and subtly broken too
> > easily, though. Make sure we fail the compilation if NUMA is enabled and
> > there is no proper implementation for this function. If that ever
> > happens we know that either the specific configuration is invalid
> > and the fix should either disable NUMA or enable one of the above
> > configs.
> > 
> > ...
> >
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
> >  	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> >  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
> >  {
> > +	BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA));
> >  	return 0;
> >  }
> >  #endif
> 
> Wouldn't this be more conventional?

Well, both would lead to a compilation errors which is what I want to
achieve. The above is easier to parse IMHO. If you believe a longer
ifdef chain is better I won't object.

> --- a/include/linux/mmzone.h~a
> +++ a/include/linux/mmzone.h
> @@ -1052,7 +1052,8 @@ static inline struct zoneref *first_zone
>  #endif
>  
>  #if !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && \
> -	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> +	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
> +	!defined(CONFIG_NUMA)
>  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  {
>  	return 0;
> _
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
