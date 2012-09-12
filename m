Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E4B5B6B0083
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 20:48:43 -0400 (EDT)
Date: Wed, 12 Sep 2012 02:48:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120912004840.GI27078@redhat.com>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911163455.bb249a3c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, mgorman@suse.de

On Tue, Sep 11, 2012 at 04:34:55PM -0700, Andrew Morton wrote:
> On Mon, 10 Sep 2012 09:18:30 +0800
> Shaohua Li <shli@kernel.org> wrote:
> 
> > isolate_migratepages_range() might isolate none pages, for example, when
> > zone->lru_lock is contended and compaction is async. In this case, we should
> > abort compaction, otherwise, compact_zone will run a useless loop and make
> > zone->lru_lock is even contended.
> > 
> > ...
> >
> > @@ -838,12 +838,14 @@ static unsigned long compact_zone_order(
> >  		.migratetype = allocflags_to_migratetype(gfp_mask),
> >  		.zone = zone,
> >  		.sync = sync,
> > -		.contended = contended,
> >  	};
> >  	INIT_LIST_HEAD(&cc.freepages);
> >  	INIT_LIST_HEAD(&cc.migratepages);
> >  
> > -	return compact_zone(zone, &cc);
> > +	ret = compact_zone(zone, &cc);
> > +	if (contended)
> > +		*contended = cc.contended;
> > +	return ret;
> >  }
> >  
> 
> From a quick read, `contended' is never NULL here.  And defining the

"contended" pointer can be null with some caller so the if is
needed. The inner code was checking it before. This is also why we
couldn't use *contended for the loop break bugfix, because contended
could have been null at times. Now cc.contended is always available so
we can use that to fix the bug and it's self documenting as well.

> interface so that `contended' must be a valid pointer is a good change,
> IMO - it results in simpler and faster code.

Agreed.

> Alas, try_to_compact_pages()'s kerneldoc altogether forgets to describe
> this argument.  Mel's
> mm-compaction-capture-a-suitable-high-order-page-immediately-when-it-is-made-available.patch
> adds a `pages' arg and forgets to document that as well.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
