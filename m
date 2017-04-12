Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89B956B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 10:07:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z109so3092903wrb.12
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 07:07:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si8249497wmh.73.2017.04.12.07.07.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 07:07:45 -0700 (PDT)
Date: Wed, 12 Apr 2017 16:07:43 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test
 in warn_alloc().
Message-ID: <20170412140742.GH7157@dhcp22.suse.cz>
References: <20170412112154.GB14892@redhat.com>
 <20170412113528.GC7157@dhcp22.suse.cz>
 <20170412114754.GA15135@redhat.com>
 <201704122114.JDG73963.SFFLVQOOtMJHFO@I-love.SAKURA.ne.jp>
 <20170412123042.GF7157@dhcp22.suse.cz>
 <201704122249.CJC39594.SOFJOFVOtHMQFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704122249.CJC39594.SOFJOFVOtHMQFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sgruszka@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rjw@rjwysocki.net, aarcange@redhat.com, cl@linux-foundation.org, mgorman@suse.de, penberg@cs.helsinki.fi

On Wed 12-04-17 22:49:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 12-04-17 21:14:10, Tetsuo Handa wrote:
> > > Stanislaw Gruszka wrote:
> > > > On Wed, Apr 12, 2017 at 01:35:28PM +0200, Michal Hocko wrote:
> > > > > OK, I see. That is a rather weird feature and the naming is more than
> > > > > surprising. But put that aside. Then it means that the check should be
> > > > > pulled out to 
> > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > index 6632256ef170..1e5f3b5cdb87 100644
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -3941,7 +3941,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > > >  		goto retry;
> > > > >  	}
> > > > >  fail:
> > > > > -	warn_alloc(gfp_mask, ac->nodemask,
> > > > > +	if (!debug_guardpage_minorder())
> > > > > +		warn_alloc(gfp_mask, ac->nodemask,
> > > > >  			"page allocation failure: order:%u", order);
> > > > >  got_pg:
> > > > >  	return page;
> > > > 
> > > > Looks good to me assuming it will be applied on top of Tetsuo's patch.
> > > > 
> > > > Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > > > 
> > > 
> > > There are two warn_alloc() usages in mm/vmalloc.c which the check should be
> > > pulled out.
> > 
> > Do we actually care about vmalloc for this?
> 
> Does it make sense not to apply debug_guardpage_minorder() > 0 test when
> kmalloc() path in kvmalloc() failed due to out of available pages and
> vmalloc() fallback path again failed due to out of available pages?

Well, vmalloc warns in 2 situations
	- when the order-0 page allocation fails
	- when the vmalloc area fails which can be either due to memory
	  allocation failure or because of vmalloc space depletion for
	  the given size when debug_guardpage_minorder is mostly
	  irrelevant

considering that we are talking about small allocations, mostly
GFP_KERNEL compatible, none of this should cause any warning floods in
the kernel log. So I do not really think they should care about
debug_guardpage_minorder at all.

In fact the more I think about this the more I am convinced that the
whole debug_guardpage_minorder check is just pointless. Because small
allocations would simply go OOM and we would flood the log anyway and
large order allocations are not all that common to actually matter. So,
let me ask again, is this something that is a result of a real problem
showing up with the guardpage or whatever is the name of the debugging
feature, or this is more a just in case thing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
