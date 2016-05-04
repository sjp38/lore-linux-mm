Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 321B16B007E
	for <linux-mm@kvack.org>; Tue,  3 May 2016 22:34:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k129so88411198iof.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 19:34:35 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i6si1276937igh.56.2016.05.03.19.34.33
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 19:34:34 -0700 (PDT)
Date: Wed, 4 May 2016 11:35:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160504023500.GB10256@js1304-P5Q-DELUXE>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20160503085356.GD28039@dhcp22.suse.cz>
 <20160504021449.GA10256@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504021449.GA10256@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 04, 2016 at 11:14:50AM +0900, Joonsoo Kim wrote:
> On Tue, May 03, 2016 at 10:53:56AM +0200, Michal Hocko wrote:
> > On Tue 03-05-16 14:23:04, Joonsoo Kim wrote:
> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > Currently, we store each page's allocation stacktrace on corresponding
> > > page_ext structure and it requires a lot of memory. This causes the problem
> > > that memory tight system doesn't work well if page_owner is enabled.
> > > Moreover, even with this large memory consumption, we cannot get full
> > > stacktrace because we allocate memory at boot time and just maintain
> > > 8 stacktrace slots to balance memory consumption. We could increase it
> > > to more but it would make system unusable or change system behaviour.
> > > 
> > > To solve the problem, this patch uses stackdepot to store stacktrace.
> > > It obviously provides memory saving but there is a drawback that
> > > stackdepot could fail.
> > > 
> > > stackdepot allocates memory at runtime so it could fail if system has
> > > not enough memory. But, most of allocation stack are generated at very
> > > early time and there are much memory at this time. So, failure would not
> > > happen easily. And, one failure means that we miss just one page's
> > > allocation stacktrace so it would not be a big problem. In this patch,
> > > when memory allocation failure happens, we store special stracktrace
> > > handle to the page that is failed to save stacktrace. With it, user
> > > can guess memory usage properly even if failure happens.
> > > 
> > > Memory saving looks as following. (Boot 4GB memory system with page_owner)
> > > 
> > > 92274688 bytes -> 25165824 bytes
> > 
> > It is not clear to me whether this is after a fresh boot or some workload
> > which would grow the stack depot as well. What is a usual cap for the
> > memory consumption.
> 
> It is static allocation size after a fresh boot. I didn't add size of
> dynamic allocation memory so it could be larger a little. See below line.
> > 
> > > 72% reduction in static allocation size. Even if we should add up size of
> > > dynamic allocation memory, it would not that big because stacktrace is
> > > mostly duplicated.
> > > 
> > > Note that implementation looks complex than someone would imagine because
> > > there is recursion issue. stackdepot uses page allocator and page_owner
> > > is called at page allocation. Using stackdepot in page_owner could re-call
> > > page allcator and then page_owner. That is a recursion.
> > 
> > This is rather fragile. How do we check there is no lock dependency
> > introduced later on - e.g. split_page called from a different
> > locking/reclaim context than alloc_pages? Would it be safer to
> 
> There is no callsite that calls set_page_owner() with
> __GFP_DIRECT_RECLAIM. So, there would be no lock/context dependency
> now.
> 
> split_page() doesn't call set_page_owner(). Instead, it calls
> split_page_owner() and just copies previous entry. Since it doesn't
> require any new stackdepot entry, it is safe in any context.
> 
> > use ~__GFP_DIRECT_RECLAIM for those stack allocations? Or do you think
> > there would be too many failed allocations? This alone wouldn't remove a
> > need for the recursion detection but it sounds less tricky.
> > 
> > > To detect and
> > > avoid it, whenever we obtain stacktrace, recursion is checked and
> > > page_owner is set to dummy information if found. Dummy information means
> > > that this page is allocated for page_owner feature itself
> > > (such as stackdepot) and it's understandable behavior for user.
> > > 
> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > I like the idea in general I just wish this would be less subtle. Few
> > more comments below.
> > 
> > [...]
> > > -void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
> > > +static inline bool check_recursive_alloc(struct stack_trace *trace,
> > > +					unsigned long ip)
> > >  {
> > > -	struct page_ext *page_ext = lookup_page_ext(page);
> > > +	int i, count;
> > > +
> > > +	if (!trace->nr_entries)
> > > +		return false;
> > > +
> > > +	for (i = 0, count = 0; i < trace->nr_entries; i++) {
> > > +		if (trace->entries[i] == ip && ++count == 2)
> > > +			return true;
> > > +	}
> > 
> > This would deserve a comment I guess. Btw, don't we have a better and
> > more robust way to detect the recursion? Per task_struct flag or
> > something like that?
> 
> Okay. I will add a comment.
> 
> I already considered task_struct flag and I know that it is a better
> solution. But, I don't think that this debugging feature deserve to
> use such precious flag. This implementation isn't efficient but I
> think that it is at least robust.
> 
> > [...]
> > > +static noinline depot_stack_handle_t save_stack(gfp_t flags)
> > > +{
> > > +	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
> > >  	struct stack_trace trace = {
> > >  		.nr_entries = 0,
> > > -		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
> > > -		.entries = &page_ext->trace_entries[0],
> > > -		.skip = 3,
> > > +		.entries = entries,
> > > +		.max_entries = PAGE_OWNER_STACK_DEPTH,
> > > +		.skip = 0
> > >  	};
> > [...]
> > >  void __dump_page_owner(struct page *page)
> > >  {
> > >  	struct page_ext *page_ext = lookup_page_ext(page);
> > > +	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
> > 
> > This is worrying because of the excessive stack consumption while we
> > might be in a deep call chain already. Can we preallocate a hash table
> > for few buffers when the feature is enabled? This would require locking
> > of course but chances are that contention wouldn't be that large.
> 
> Make sense but I'm not sure that excessive stack consumption would
> cause real problem. For example, if direct reclaim is triggered during
> allocation, it may go more deeper than this path. I'd like to
> postpone to handle this issue until stack breakage is reported due to
> this feature.

Oops... I think more deeply and change my mind. In recursion case,
stack is consumed more than 1KB and it would be a problem. I think
that best approach is using preallocated per cpu entry. It will also
close recursion detection issue by paying interrupt on/off overhead.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
