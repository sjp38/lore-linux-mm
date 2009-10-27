Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 439DF6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:12:48 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id n9RLCfKt029254
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:12:42 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz9.hot.corp.google.com with ESMTP id n9RLCLme020207
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:12:38 -0700
Received: by pzk37 with SMTP id 37so96066pzk.10
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:12:38 -0700 (PDT)
Date: Tue, 27 Oct 2009 14:12:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <20091027130924.fa903f5a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.orgMel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, Andrew Morton wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index dfa4362..7f2aa3e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1769,7 +1769,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> >  		 */
> >  		alloc_flags &= ~ALLOC_CPUSET;
> > -	} else if (unlikely(rt_task(p)))
> > +	} else if (unlikely(rt_task(p)) && !in_interrupt())
> >  		alloc_flags |= ALLOC_HARDER;
> >  
> >  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> 
> What are the runtime-observeable effects of this change?
> 

Giving rt tasks access to memory reserves is necessary to reduce latency, 
the privilege does not apply to interrupts that subsequently get run on 
the same cpu.

> The description is a bit waffly-sounding for a -stable backportable
> thing, IMO.  What reason do the -stable maintainers and users have to
> believe that this patch is needed, and an improvement?
> 

Allowing interrupts to allocate below the low watermark when not 
GFP_ATOMIC depletes memory reserves; this fixes an inconsistency 
introduced by the page allocator refactoring patchset that went into 
2.6.31.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
