Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C17BE6B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 09:49:37 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m16so25098374ioe.17
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 06:49:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h196si5387012itb.121.2017.04.12.06.49.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 06:49:36 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test in warn_alloc().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170412112154.GB14892@redhat.com>
	<20170412113528.GC7157@dhcp22.suse.cz>
	<20170412114754.GA15135@redhat.com>
	<201704122114.JDG73963.SFFLVQOOtMJHFO@I-love.SAKURA.ne.jp>
	<20170412123042.GF7157@dhcp22.suse.cz>
In-Reply-To: <20170412123042.GF7157@dhcp22.suse.cz>
Message-Id: <201704122249.CJC39594.SOFJOFVOtHMQFL@I-love.SAKURA.ne.jp>
Date: Wed, 12 Apr 2017 22:49:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: sgruszka@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, rjw@rjwysocki.net, aarcange@redhat.com, cl@linux-foundation.org, mgorman@suse.de, penberg@cs.helsinki.fi

Michal Hocko wrote:
> On Wed 12-04-17 21:14:10, Tetsuo Handa wrote:
> > Stanislaw Gruszka wrote:
> > > On Wed, Apr 12, 2017 at 01:35:28PM +0200, Michal Hocko wrote:
> > > > OK, I see. That is a rather weird feature and the naming is more than
> > > > surprising. But put that aside. Then it means that the check should be
> > > > pulled out to 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 6632256ef170..1e5f3b5cdb87 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -3941,7 +3941,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  		goto retry;
> > > >  	}
> > > >  fail:
> > > > -	warn_alloc(gfp_mask, ac->nodemask,
> > > > +	if (!debug_guardpage_minorder())
> > > > +		warn_alloc(gfp_mask, ac->nodemask,
> > > >  			"page allocation failure: order:%u", order);
> > > >  got_pg:
> > > >  	return page;
> > > 
> > > Looks good to me assuming it will be applied on top of Tetsuo's patch.
> > > 
> > > Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > > 
> > 
> > There are two warn_alloc() usages in mm/vmalloc.c which the check should be
> > pulled out.
> 
> Do we actually care about vmalloc for this?

Does it make sense not to apply debug_guardpage_minorder() > 0 test when
kmalloc() path in kvmalloc() failed due to out of available pages and
vmalloc() fallback path again failed due to out of available pages?

If the purpose of debug_guardpage_minorder() > 0 test is to prevent from flooding
allocation failure messages, why not to treat kmalloc()/vmalloc() evenly?

Yes, we might think it is better to print allocation failure messages if memory is
tight enough to even vmalloc() fails. But this patch's intention is to make sure
that allocation stall messages are not disabled by debug_guardpage_minorder() > 0
test. I guess this patch should not change behavior of allocation failure messages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
