Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53F716B0268
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:10:10 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so1569691wjb.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:10:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si28504465wrg.183.2017.01.18.02.10.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 02:10:09 -0800 (PST)
Date: Wed, 18 Jan 2017 11:10:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, page_alloc: warn_alloc print nodemask
Message-ID: <20170118101006.GO7015@dhcp22.suse.cz>
References: <20170117091543.25850-1-mhocko@kernel.org>
 <20170117091543.25850-3-mhocko@kernel.org>
 <alpine.DEB.2.10.1701171459570.142998@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701171459570.142998@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-01-17 15:01:35, David Rientjes wrote:
> On Tue, 17 Jan 2017, Michal Hocko wrote:
> 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 57dc3c3b53c1..3e35eb04a28a 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1912,8 +1912,8 @@ extern void si_meminfo_node(struct sysinfo *val, int nid);
> >  extern unsigned long arch_reserved_kernel_pages(void);
> >  #endif
> >  
> > -extern __printf(2, 3)
> > -void warn_alloc(gfp_t gfp_mask, const char *fmt, ...);
> > +extern __printf(3, 4)
> > +void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...);
> >  
> >  extern void setup_per_cpu_pageset(void);
> >  
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8f4f306d804c..7f9c0ee18ae0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3031,12 +3031,13 @@ static void warn_alloc_show_mem(gfp_t gfp_mask)
> >  	show_mem(filter);
> >  }
> >  
> > -void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > +void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  {
> >  	struct va_format vaf;
> >  	va_list args;
> >  	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
> >  				      DEFAULT_RATELIMIT_BURST);
> > +	nodemask_t *nm = (nodemask) ? nodemask : &cpuset_current_mems_allowed;
> 
> Small nit: wouldn't it be helpful to know if ac->nodemask is actually NULL 
> rather than setting it to cpuset_current_mems_allowed here?  We know the 
> effective nodemask from cpuset_print_current_mems_allowed(), but we don't 
> know if there's a bug in the page allocator which is failing to set 
> ac->nodemask appropriately if we blindly set it here when cpusets are not 
> enabled.

You are right that games with the nodemask are dangerous and can
potentially lead to unexpected behavior. I wanted to make this code as
simple as possible though and printing mems_allowed for NULL nodemask
looked like the way. Feel free to post a patch to handle null nodemask
in the output if you think it is an improvement.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
