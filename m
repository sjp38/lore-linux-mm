Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id ADDA482F86
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:11:22 -0500 (EST)
Received: by wmww144 with SMTP id w144so76412054wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:11:22 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m19si4585910wjr.103.2015.11.18.07.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 07:11:20 -0800 (PST)
Received: by wmww144 with SMTP id w144so201279500wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:11:20 -0800 (PST)
Date: Wed, 18 Nov 2015 16:11:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
Message-ID: <20151118151119.GG19145@dhcp22.suse.cz>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
 <564C91E9.8000904@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564C91E9.8000904@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-11-15 15:57:45, Vlastimil Babka wrote:
[...]
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3046,32 +3046,36 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 * allocations are system rather than user orientated
> >  		 */
> >  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > -		do {
> > -			page = get_page_from_freelist(gfp_mask, order,
> > -							ALLOC_NO_WATERMARKS, ac);
> > -			if (page)
> > -				goto got_pg;
> > -
> > -			if (gfp_mask & __GFP_NOFAIL)
> > -				wait_iff_congested(ac->preferred_zone,
> > -						   BLK_RW_ASYNC, HZ/50);
> 
> I've been thinking if the lack of unconditional wait_iff_congested() can affect
> something negatively. I guess not?

Considering that the wait_iff_congested is removed only for PF_MEMALLOC
with __GFP_NOFAIL which should be non-existent in the kernel then I
think the risk is really low. Even if there was a caller _and_ there
was a congestion then the behavior wouldn't be much more worse than
what we have currently. The system is out of memory hoplessly if
ALLOC_NO_WATERMARKS allocation fails.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
