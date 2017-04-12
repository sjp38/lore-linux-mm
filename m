Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC5F96B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 08:14:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x86so23441882ioe.5
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 05:14:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j75si2916474ioj.63.2017.04.12.05.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 05:14:23 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test in warn_alloc().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170412102341.GA13958@redhat.com>
	<20170412105951.GB7157@dhcp22.suse.cz>
	<20170412112154.GB14892@redhat.com>
	<20170412113528.GC7157@dhcp22.suse.cz>
	<20170412114754.GA15135@redhat.com>
In-Reply-To: <20170412114754.GA15135@redhat.com>
Message-Id: <201704122114.JDG73963.SFFLVQOOtMJHFO@I-love.SAKURA.ne.jp>
Date: Wed, 12 Apr 2017 21:14:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sgruszka@redhat.com, mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rjw@sisk.pl, aarcange@redhat.com, cl@linux-foundation.org, mgorman@suse.de, penberg@cs.helsinki.fi

Stanislaw Gruszka wrote:
> On Wed, Apr 12, 2017 at 01:35:28PM +0200, Michal Hocko wrote:
> > OK, I see. That is a rather weird feature and the naming is more than
> > surprising. But put that aside. Then it means that the check should be
> > pulled out to 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6632256ef170..1e5f3b5cdb87 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3941,7 +3941,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto retry;
> >  	}
> >  fail:
> > -	warn_alloc(gfp_mask, ac->nodemask,
> > +	if (!debug_guardpage_minorder())
> > +		warn_alloc(gfp_mask, ac->nodemask,
> >  			"page allocation failure: order:%u", order);
> >  got_pg:
> >  	return page;
> 
> Looks good to me assuming it will be applied on top of Tetsuo's patch.
> 
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 

There are two warn_alloc() usages in mm/vmalloc.c which the check should be
pulled out. Then, I feel changing to use a different function for reporting
allocation stalls might be better than pulling out

	if (!debug_guardpage_minorder())

into three locations.

Michal, you can fold my patch into your patch if you prefer pulling out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
