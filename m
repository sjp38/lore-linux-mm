Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1449D6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:50:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so16098575pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:50:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 16si10247045pfm.61.2016.04.19.00.50.19
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 00:50:20 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:51:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 11/16] zsmalloc: separate free_zspage from
 putback_zspage
Message-ID: <20160419075118.GD18448@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-12-git-send-email-minchan@kernel.org>
 <20160418010408.GB5882@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160418010408.GB5882@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hi Sergey,

On Mon, Apr 18, 2016 at 10:04:08AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (03/30/16 16:12), Minchan Kim wrote:
> [..]
> > @@ -1835,23 +1827,31 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
> >  			if (!migrate_zspage(pool, class, &cc))
> >  				break;
> >  
> > -			putback_zspage(pool, class, dst_page);
> > +			VM_BUG_ON_PAGE(putback_zspage(pool, class,
> > +				dst_page) == ZS_EMPTY, dst_page);
> 
> can this VM_BUG_ON_PAGE() condition ever be true?

I guess it is remained thing after I rebased to catch any mistake.
But I'm heavily chainging this part.
Please review next version instead of this after a few days. :)

> 
> >  		}
> >  		/* Stop if we couldn't find slot */
> >  		if (dst_page == NULL)
> >  			break;
> > -		putback_zspage(pool, class, dst_page);
> > -		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
> > +		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> > +				dst_page) == ZS_EMPTY, dst_page);
> 
> hm... this VM_BUG_ON_PAGE(dst_page) is sort of confusing. under what
> circumstances it can be true?
> 
> a minor nit, it took me some time (need some coffee I guess) to
> correctly parse this macro wrapper
> 
> 		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> 			dst_page) == ZS_EMPTY, dst_page);
> 
> may be do it like:
> 		fullness = putback_zspage(pool, class, dst_page);
> 		VM_BUG_ON_PAGE(fullness == ZS_EMPTY, dst_page);
> 
> 
> well, if we want to VM_BUG_ON_PAGE() at all. there haven't been any
> problems with compaction, is there any specific reason these macros
> were added?
> 
> 
> 
> > +		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
> >  			pool->stats.pages_compacted += class->pages_per_zspage;
> > -		spin_unlock(&class->lock);
> > +			spin_unlock(&class->lock);
> > +			free_zspage(pool, class, src_page);
> 
> do we really need to free_zspage() out of class->lock?
> wouldn't something like this
> 
> 		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
> 			pool->stats.pages_compacted += class->pages_per_zspage;
> 			free_zspage(pool, class, src_page);
> 		}
> 		spin_unlock(&class->lock);
> 
> be simpler?

The reason I did out of class->lock is deadlock between page_lock
and class->lock with upcoming page migration.
However, as I said, I'm now heavily changing the part. :)

> 
> besides, free_zspage() now updates class stats out of class lock,
> not critical but still.
> 
> 	-ss
> 
> > +		} else {
> > +			spin_unlock(&class->lock);
> > +		}
> > +
> >  		cond_resched();
> >  		spin_lock(&class->lock);
> >  	}
> >  
> >  	if (src_page)
> > -		putback_zspage(pool, class, src_page);
> > +		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> > +				src_page) == ZS_EMPTY, src_page);
> >  
> >  	spin_unlock(&class->lock);
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
