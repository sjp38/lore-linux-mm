Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7653B6B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 09:38:13 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id r65so11629687oih.19
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 06:38:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67si557981ote.293.2018.02.01.06.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 06:38:12 -0800 (PST)
Date: Thu, 1 Feb 2018 22:38:08 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 1/2] mm/sparsemem: Defer the ms->section_mem_map clearing
 a little later
Message-ID: <20180201143808.GE1770@localhost.localdomain>
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-2-bhe@redhat.com>
 <87acc80a-8a9a-5037-8efc-9bb64ddaaffb@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87acc80a-8a9a-5037-8efc-9bb64ddaaffb@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 02/01/18 at 06:15am, Dave Hansen wrote:
> On 01/31/2018 11:19 PM, Baoquan He wrote:
> >  	for_each_present_section_nr(0, pnum) {
> > +		struct mem_section *ms;
> > +		ms = __nr_to_section(pnum);
> >  		usemap = usemap_map[pnum];
> > -		if (!usemap)
> > +		if (!usemap) {
> > +#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> > +			ms->section_mem_map = 0;
> > +#endif
> >  			continue;
> > +		}
> >  
> >  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> >  		map = map_map[pnum];
> >  #else
> >  		map = sparse_early_mem_map_alloc(pnum);
> >  #endif
> > -		if (!map)
> > +		if (!map) {
> > +#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> > +			ms->section_mem_map = 0;
> > +#endif
> >  			continue;
> > +		}
> 
> This is starting to look like code that only a mother could love.  Can
> this be cleaned up a bit?

Sorry, will try. Just wonder why we don't need to clear
ms->section_mem_map when CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is not
set. Will look into to find reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
