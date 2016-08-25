Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C06D8308D
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 02:54:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so27327128wme.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 23:54:28 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id mn7si12376516wjc.177.2016.08.24.23.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 23:54:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so5965229wmf.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 23:54:27 -0700 (PDT)
Date: Thu, 25 Aug 2016 08:54:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160825065424.GA4230@dhcp22.suse.cz>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1608241750220.98155@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608241750220.98155@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 24-08-16 17:54:52, David Rientjes wrote:
> On Tue, 23 Aug 2016, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > The current wording of the COMPACTION Kconfig help text doesn't
> > emphasise that disabling COMPACTION might cripple the page allocator
> > which relies on the compaction quite heavily for high order requests and
> > an unexpected OOM can happen with the lack of compaction. Make sure
> > we are vocal about that.
> > 
> 
> Since when has this been an issue? 

Well, pretty much since we have dropped the lumpy reclaim. 

> I don't believe it has been an issue in the past for any archs that
> don't use thp.

Well, fragmentation is a real problem and order-0 reclaim will be never
anywhere close to reliably provide higher order pages. Well, reclaiming
a lot of memory can increase the probability of a success but that
can quite often lead to over reclaim and long stalls. There are other
sources of high order requests than THP so this is not about THP at all
IMHO.

> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/Kconfig | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 78a23c5c302d..0dff2f05b6d1 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -262,7 +262,14 @@ config COMPACTION
> >  	select MIGRATION
> >  	depends on MMU
> >  	help
> > -	  Allows the compaction of memory for the allocation of huge pages.
> > +          Compaction is the only memory management component to form
> > +          high order (larger physically contiguous) memory blocks
> > +          reliably. Page allocator relies on the compaction heavily and
> > +          the lack of the feature can lead to unexpected OOM killer
> > +          invocation for high order memory requests. You shouldnm't
> > +          disable this option unless there is really a strong reason for
> > +          it and then we are really interested to hear about that at
> > +          linux-mm@kvack.org.
> >  
> >  #
> >  # support for page migration
> 
> This seems to strongly suggest that all kernels should be built with 
> CONFIG_COMPACTION and its requirement

Yes. Do you see any reason why the compaction should be disabled and we
should rely solely on order-0 reclaim?

> , CONFIG_MIGRATION.  Migration has a 
> dependency of NUMA or memory hot-remove (not all popular).  Compaction can 
> defragment memory within single zone without reliance on NUMA.

I am not sure I am following you here.
MIGRATION depends on (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU
 
> This seems like a very bizarre requirement and I'm wondering where we 
> regressed from this thp-only behavior.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
