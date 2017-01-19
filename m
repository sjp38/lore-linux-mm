Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9026B0278
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:45:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so7868115wmt.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:45:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si3599078wrh.278.2017.01.19.00.45.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 00:45:19 -0800 (PST)
Date: Thu, 19 Jan 2017 09:45:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
Message-ID: <20170119084510.GF30786@dhcp22.suse.cz>
References: <20170116084717.GA13641@dhcp22.suse.cz>
 <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
 <20170116194052.GA9382@dhcp22.suse.cz>
 <1979f5e1-a335-65d8-8f9a-0aef17898ca1@nvidia.com>
 <20170116214822.GB9382@dhcp22.suse.cz>
 <be93f879-6bc7-a09e-26f3-09c82c669d74@nvidia.com>
 <20170117075100.GB19699@dhcp22.suse.cz>
 <bfd34f15-857f-b721-e27a-a6a1faad1aec@nvidia.com>
 <20170118082146.GC7015@dhcp22.suse.cz>
 <37232cc6-af8b-52e2-3265-9ef0c0d26e5f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <37232cc6-af8b-52e2-3265-9ef0c0d26e5f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Thu 19-01-17 00:37:08, John Hubbard wrote:
> 
> 
> On 01/18/2017 12:21 AM, Michal Hocko wrote:
> > On Tue 17-01-17 21:59:13, John Hubbard wrote:
[...]
> > >  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL should not be passed in.
> > >  * Passing in __GFP_REPEAT is supported, but note that it is ignored for small
> > >  * (<=64KB) allocations, during the kmalloc attempt.
> > 
> > > __GFP_REPEAT is fully
> > >  * honored for  all allocation sizes during the second part: the vmalloc attempt.
> > 
> > this is not true to be really precise because vmalloc doesn't respect
> > the given gfp mask all the way down (look at the pte initialization).
> > 
> 
> I'm having some difficulty in locating that pte initialization part, am I on
> the wrong code path? Here's what I checked, before making the claim about
> __GFP_REPEAT being honored:
> 
> kvmalloc_node
>   __vmalloc_node_flags
>     __vmalloc_node
>       __vmalloc_node_range
>         __vmalloc_area_node
	    map_vm_area
	      vmap_page_range
	        vmap_page_range_noflush
		  vmap_pud_range
		    pud_alloc
		      __pud_alloc
		        pud_alloc_one

pud will be allocated but the same pattern repeats on the pmd and pte
levels. This is btw. one of the reasons why vmalloc with gfp flags is
tricky!

moreover
>             alloc_pages_node

this is order-0 request so...

>               __alloc_pages_node
>                 __alloc_pages
>                   __alloc_pages_nodemask
>                     __alloc_pages_slowpath
> 
> 
> ...and __alloc_pages_slowpath does the __GFP_REPEAT handling:
> 
>     /*
>      * Do not retry costly high order allocations unless they are
>      * __GFP_REPEAT
>      */
>     if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>         goto nopage;

... this doesn't apply


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
