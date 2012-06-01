Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B2B796B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 21:33:53 -0400 (EDT)
Date: Fri, 1 Jun 2012 09:33:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120601013348.GA7069@localhost>
References: <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
 <20120529135101.GD15293@tiehlicka.suse.cz>
 <20120531151816.GA32252@localhost>
 <20120531153249.GD12809@tiehlicka.suse.cz>
 <20120531154248.GA32734@localhost>
 <20120531154859.GA20546@tiehlicka.suse.cz>
 <20120531160129.GA439@localhost>
 <20120531182509.GA22539@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531182509.GA22539@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

[restore CC list]

On Thu, May 31, 2012 at 08:25:09PM +0200, Michal Hocko wrote:
> On Fri 01-06-12 00:01:29, Fengguang Wu wrote:
> > On Thu, May 31, 2012 at 05:49:00PM +0200, Michal Hocko wrote:
> > > On Thu 31-05-12 23:42:48, Fengguang Wu wrote:
> > > > On Thu, May 31, 2012 at 05:32:49PM +0200, Michal Hocko wrote:
> > > > > JFYI: You might have missed https://lkml.org/lkml/2012/5/31/122 because
> > > > > intel mail server returned with "we do not like shell scripts as a
> > > > > attachment".
> > > > 
> > > > Yeah I did miss it.. A quick question: does the PageReclaim patch
> > > > tested include the (priority < 3) test, or it's the originally posted
> > > > patch?
> > > 
> > > It's the original patch.
> > 
> > OK, that's fine. I suspect even adding (priority < 3), it can help
> > only some situations. In the others, the effect will be that writeback
> > pages get accumulated in LRU until it starts to throttle page reclaims
> > from both reads/writes. There will have to be some throttling somewhere.
> 
> Yes, I agree. But it could help at least sporadic "hey this is a PageReclaim"
> issues. I just didn't like to push priority into shrink_page_list
> without. The justification is quite hard.

Yeah priority is just a rule of thumb "there may be lots of
dirty/writeback pages or other pressure if priority goes low". 
And it's already been used this way in shrink_page_list().

Considering that it's also targeting for -stable merge, we do need
a very strict condition to safeguard no regressions on other cases.
This is also true for the wait_iff_congested() scheme.

> > Subject: mm: pass __GFP_WRITE to memcg charge and reclaim routines
> > 
> > __GFP_WRITE will be tested in vmscan to find out the write tasks.
> > 
> > For good interactive performance, we try to focus dirty reclaim waits on
> > them and avoid blocking unrelated tasks.
> > 
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> 
> I will have a look at this one tomorrow with a clean head.

OK. The usage in my mind is

        if (PageWriteback(page) && PageReclaim(page))
+               if ((sc->gfp_mask & __GFP_WAIT) || (priority < 3))
                        do some dirty throttling

But note that it only detects writes to new pages (ie. simple dd).
Overwrites to already cached clean pages cannot be detected this way..

Thanks,
Fengguang

> > ---
> >  include/linux/gfp.h |    2 +-
> >  mm/filemap.c        |   17 ++++++++++-------
> >  2 files changed, 11 insertions(+), 8 deletions(-)
> > 
> > --- linux.orig/include/linux/gfp.h	2012-03-02 14:06:47.501765703 +0800
> > +++ linux/include/linux/gfp.h	2012-03-02 14:07:39.921766949 +0800
> > @@ -129,7 +129,7 @@ struct vm_area_struct;
> >  /* Control page allocator reclaim behavior */
> >  #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
> >  			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
> > -			__GFP_NORETRY|__GFP_NOMEMALLOC)
> > +			__GFP_NORETRY|__GFP_NOMEMALLOC|__GFP_WRITE)
> >  
> >  /* Control slab gfp mask during early boot */
> >  #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
> > --- linux.orig/mm/filemap.c	2012-03-02 14:07:21.000000000 +0800
> > +++ linux/mm/filemap.c	2012-03-02 14:07:53.709767277 +0800
> > @@ -2339,23 +2339,26 @@ struct page *grab_cache_page_write_begin
> >  	int status;
> >  	gfp_t gfp_mask;
> >  	struct page *page;
> > -	gfp_t gfp_notmask = 0;
> > +	gfp_t lru_gfp_mask = GFP_KERNEL;
> >  
> >  	gfp_mask = mapping_gfp_mask(mapping);
> > -	if (mapping_cap_account_dirty(mapping))
> > +	if (mapping_cap_account_dirty(mapping)) {
> >  		gfp_mask |= __GFP_WRITE;
> > -	if (flags & AOP_FLAG_NOFS)
> > -		gfp_notmask = __GFP_FS;
> > +		lru_gfp_mask |= __GFP_WRITE;
> > +	}
> > +	if (flags & AOP_FLAG_NOFS) {
> > +		gfp_mask &= ~__GFP_FS;
> > +		lru_gfp_mask &= ~__GFP_FS;
> > +	}
> >  repeat:
> >  	page = find_lock_page(mapping, index);
> >  	if (page)
> >  		goto found;
> >  
> > -	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
> > +	page = __page_cache_alloc(gfp_mask);
> >  	if (!page)
> >  		return NULL;
> > -	status = add_to_page_cache_lru(page, mapping, index,
> > -						GFP_KERNEL & ~gfp_notmask);
> > +	status = add_to_page_cache_lru(page, mapping, index, lru_gfp_mask);
> >  	if (unlikely(status)) {
> >  		page_cache_release(page);
> >  		if (status == -EEXIST)
> 
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
