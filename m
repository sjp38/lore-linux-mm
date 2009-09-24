Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 657C56B006A
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 21:47:11 -0400 (EDT)
Subject: Re: a patch drop request in -mm
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090924092903.B648.A69D9226@jp.fujitsu.com>
References: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com>
	 <20090921152219.GQ12726@csn.ul.ie>
	 <20090924092903.B648.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 23 Sep 2009 21:47:12 -0400
Message-Id: <1253756832.6489.33.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-24 at 09:40 +0900, KOSAKI Motohiro wrote:
> > On Tue, Sep 22, 2009 at 12:00:51AM +0900, KOSAKI Motohiro wrote:
> > > Mel,
> > > 
> > > Today, my test found following patch makes false-positive warning.
> > > because, truncate can free the pages
> > > although the pages are mlock()ed.
> > > 
> > > So, I think following patch should be dropped.
> > > .. or, do you think truncate should clear PG_mlock before free the page?
> > 
> > Is there a reason that truncate cannot clear PG_mlock before freeing the
> > page?
> 
> CC to Lee.
> IIRC, Lee tried it at first. but after some trouble, he decided change free_hot_cold_page().
> but unfortunately, I don't recall the reason ;-)
> 
> Lee, Can you recall it?

Well, truncation does call clear_page_mlock() for this purpose.  This
should always succeed in clearing PG_mlock, altho' I suppose it could be
set from somewhere else after that?  Looking at the 2.6.31 sources, I
see that there is a call to page_cache_release() in
truncate_inode_pages_range() that doesn't have a corresponding
clear_page_mlock() associated with it.  Perhaps we missed this one, or
it's been added since w/o munlocking the page. 

If you can eliminate the false positive, I think it would be good to
keep the warning in place.   There might be other "leaks" of mlocked
pages that aren't as benign as this.  But, keeping it in -mm until it's
sorted out sound reasonable to me
 

> 
> 
> > > Can I ask your patch intention?
> > 
> > Locked pages being freed to the page allocator were considered
> > unexpected and a counter was in place to determine how often that
> > situation occurred. However, I considered it unlikely that the counter
> > would be noticed so the warning was put in place to catch what class of
> > pages were getting freed locked inappropriately. I think a few anomolies
> > have been cleared up since. Ultimately, it should have been safe to
> > delete the check.
> 
> OK. it seems reasonable. so, I only hope no see linus tree output false-positive warnings.
> Thus, I propse 
> 
>   - don't merge this patch to linus tree
>   - but, no drop from -mm
>     it be holded in mm until this issue fixed.
>   - I'll working on fixing this issue.
> 
> I think this is enough fair.
> 
> 
> Hannes, I'm sorry. I haven't review your patch. I'm too busy now. please gime me more
> sevaral time.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
