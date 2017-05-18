Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0C98831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 12:42:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u96so10369024wrc.7
        for <linux-mm@kvack.org>; Thu, 18 May 2017 09:42:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si5982968edp.312.2017.05.18.09.42.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 09:42:14 -0700 (PDT)
Date: Thu, 18 May 2017 18:42:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/14] mm: consider zone which is not fully populated to
 have holes
Message-ID: <20170518164210.GD18333@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-8-mhocko@kernel.org>
 <ae859e14-bf82-ae37-9c85-d4b31ce89b0a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae859e14-bf82-ae37-9c85-d4b31ce89b0a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 18-05-17 18:14:39, Vlastimil Babka wrote:
> On 05/15/2017 10:58 AM, Michal Hocko wrote:
[...]
> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > +/*
> > + * Return page for the valid pfn only if the page is online. All pfn
> > + * walkers which rely on the fully initialized page->flags and others
> > + * should use this rather than pfn_valid && pfn_to_page
> > + */
> > +#define pfn_to_online_page(pfn)				\
> > +({							\
> > +	struct page *___page = NULL;			\
> > +							\
> > +	if (online_section_nr(pfn_to_section_nr(pfn)))	\
> > +		___page = pfn_to_page(pfn);		\
> > +	___page;					\
> > +})
> 
> This seems to be already assuming pfn_valid() to be true. There's no
> "pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS" check and the comment
> suggests as such, but...

Yes, we should check the validity of the section number. We do not have
to check whether the section is valid because online sections are a
subset of those that are valid.

> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 05796ee974f7..c3a146028ba6 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -929,6 +929,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  	unsigned long i;
> >  	unsigned long onlined_pages = *(unsigned long *)arg;
> >  	struct page *page;
> > +
> > +	online_mem_sections(start_pfn, start_pfn + nr_pages);
> 
> Shouldn't this be moved *below* the loop that initializes struct pages?
> In the offline case you do mark sections offline before "tearing" struct
> pages, so that should be symmetric.

You are right! Andrew, could you fold the following intot the patch?
---
