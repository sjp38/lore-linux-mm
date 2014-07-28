Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 72C1C6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 10:24:10 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so4540954wiw.12
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 07:24:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fm4si13956992wib.2.2014.07.28.07.24.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 07:24:08 -0700 (PDT)
Date: Mon, 28 Jul 2014 10:23:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix direct reclaim writeback regression
Message-ID: <20140728142313.GN1725@cmpxchg.org>
References: <alpine.LSU.2.11.1407261248140.13796@eggly.anvils>
 <53D42F80.7000000@suse.cz>
 <alpine.LSU.2.11.1407261600570.14577@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407261600570.14577@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jul 26, 2014 at 04:15:25PM -0700, Hugh Dickins wrote:
> On Sun, 27 Jul 2014, Vlastimil Babka wrote:
> > On 07/26/2014 09:58 PM, Hugh Dickins wrote:
> > > Yes, 3.16-rc1's 68711a746345 ("mm, migration: add destination page
> > > freeing callback") has provided such a way to compaction: if migrating
> > > a SwapBacked page fails, its newpage may be put back on the list for
> > > later use with PageSwapBacked still set, and nothing will clear it.
> > 
> > Ugh good catch. So is this the only flag that can become "stray" like
> > this? It seems so from quick check...
> 
> Yes, it seemed so to me too; but I would prefer a regime in which
> we only mess with newpage once it's sure to be successful.
> 
> > > --- 3.16-rc6/mm/migrate.c	2014-06-29 15:22:10.584003935 -0700
> > > +++ linux/mm/migrate.c	2014-07-26 11:28:34.488126591 -0700
> > > @@ -988,9 +988,10 @@ out:
> > >  	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
> > >  	 * during isolation.
> > >  	 */
> > > -	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> > > +	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
> > > +		ClearPageSwapBacked(newpage);
> > >  		put_new_page(newpage, private);
> > > -	else
> > > +	} else
> > >  		putback_lru_page(newpage);
> > >  
> > >  	if (result) {
> > 
> > What about unmap_and_move_huge_page()? Seems to me it can also get the
> > same stray flag. Although compaction, who is the only user so far of
> > custom put_new_page, wouldn't of course migrate huge pages. But might
> > bite us in the future, if a new user appears before a cleanup...
> 
> I think you're right, thanks for pointing it out.  We don't have an
> actual bug there at present, so no need to rush back and fix up the
> patch now in Linus's tree; but unmap_and_move_huge_page() gives
> another reason why my choice was "probably the worst place to fix it".
> 
> More reason for a cleanup, but not while the memcg interface is in flux.
> In mmotm I'm a little anxious about the PageAnon case when newpage's
> mapping is left set, I wonder if that might also be problematic: I
> mailed Hannes privately to think about that - perhaps that will give
> more impulse for a cleanup, though I've not noticed any bug from it.

I made that change for oldpage because uncharge in the final put_page
relies on PageAnon() to work for statistics.

The newpage case could have been left alone, but it looked like an
anomaly to me - anonymous mappings are usually sticky and only cleared
by the page allocator - so I was eager to make the cases symmetrical.
I don't see a bug there because if the page is reused its mapping will
be overwritten right away, and if freed the allocator will reset it.

mem_cgroup_migrate() has since changed to fully uncharge the old page
and not leave this task to the final put_page, so ->mapping does not
need to be maintained past that point.  I'll send a revert of these
conditional ->mapping resets to Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
