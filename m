Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9B186B025E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 11:30:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t140so101537403oie.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:30:36 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id 94si2055546ots.166.2016.05.04.08.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 08:30:36 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id x201so69408242oif.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:30:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504092133.GG29978@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
	<20160503085356.GD28039@dhcp22.suse.cz>
	<20160504021449.GA10256@js1304-P5Q-DELUXE>
	<20160504092133.GG29978@dhcp22.suse.cz>
Date: Thu, 5 May 2016 00:30:35 +0900
Message-ID: <CAAmzW4NYWaNvC5MPR8RwQSiKP2b2Z5wVy9nnNxc+sTVWvQ6BGA@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-04 18:21 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 04-05-16 11:14:50, Joonsoo Kim wrote:
>> On Tue, May 03, 2016 at 10:53:56AM +0200, Michal Hocko wrote:
>> > On Tue 03-05-16 14:23:04, Joonsoo Kim wrote:
> [...]
>> > > Memory saving looks as following. (Boot 4GB memory system with page_owner)
>> > >
>> > > 92274688 bytes -> 25165824 bytes
>> >
>> > It is not clear to me whether this is after a fresh boot or some workload
>> > which would grow the stack depot as well. What is a usual cap for the
>> > memory consumption.
>>
>> It is static allocation size after a fresh boot. I didn't add size of
>> dynamic allocation memory so it could be larger a little. See below line.
>> >
>> > > 72% reduction in static allocation size. Even if we should add up size of
>> > > dynamic allocation memory, it would not that big because stacktrace is
>> > > mostly duplicated.
>
> This would be true only if most of the allocation stacks are basically
> same after the boot which I am not really convinced is true. But you are
> right that the number of sublicates will grow only a little. I was
> interested about how much is that little ;)

After a fresh boot, it just uses 14 order-2 pages.

>> > > Note that implementation looks complex than someone would imagine because
>> > > there is recursion issue. stackdepot uses page allocator and page_owner
>> > > is called at page allocation. Using stackdepot in page_owner could re-call
>> > > page allcator and then page_owner. That is a recursion.
>> >
>> > This is rather fragile. How do we check there is no lock dependency
>> > introduced later on - e.g. split_page called from a different
>> > locking/reclaim context than alloc_pages? Would it be safer to
>>
>> There is no callsite that calls set_page_owner() with
>> __GFP_DIRECT_RECLAIM. So, there would be no lock/context dependency
>> now.
>
> I am confused now. prep_new_page is called with the gfp_mask of the
> original request, no?

Yes. I assume that set_page_owner() in prep_new_page() is okay. Sorry
for confusion.

>> split_page() doesn't call set_page_owner(). Instead, it calls
>> split_page_owner() and just copies previous entry. Since it doesn't
>> require any new stackdepot entry, it is safe in any context.
>
> Ohh, you are right. I have missed patch 4
> (http://lkml.kernel.org/r/1462252984-8524-5-git-send-email-iamjoonsoo.kim@lge.com)
>
>> > use ~__GFP_DIRECT_RECLAIM for those stack allocations? Or do you think
>> > there would be too many failed allocations? This alone wouldn't remove a
>> > need for the recursion detection but it sounds less tricky.
>> >
>> > > To detect and
>> > > avoid it, whenever we obtain stacktrace, recursion is checked and
>> > > page_owner is set to dummy information if found. Dummy information means
>> > > that this page is allocated for page_owner feature itself
>> > > (such as stackdepot) and it's understandable behavior for user.
>> > >
>> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> >
>> > I like the idea in general I just wish this would be less subtle. Few
>> > more comments below.
>> >
>> > [...]
>> > > -void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>> > > +static inline bool check_recursive_alloc(struct stack_trace *trace,
>> > > +                                 unsigned long ip)
>> > >  {
>> > > - struct page_ext *page_ext = lookup_page_ext(page);
>> > > + int i, count;
>> > > +
>> > > + if (!trace->nr_entries)
>> > > +         return false;
>> > > +
>> > > + for (i = 0, count = 0; i < trace->nr_entries; i++) {
>> > > +         if (trace->entries[i] == ip && ++count == 2)
>> > > +                 return true;
>> > > + }
>> >
>> > This would deserve a comment I guess. Btw, don't we have a better and
>> > more robust way to detect the recursion? Per task_struct flag or
>> > something like that?
>>
>> Okay. I will add a comment.
>>
>> I already considered task_struct flag and I know that it is a better
>> solution. But, I don't think that this debugging feature deserve to
>> use such precious flag. This implementation isn't efficient but I
>> think that it is at least robust.
>
> I guess there are many holes in task_structs where a single bool would
> comfortably fit in. But I do not consider this to be a large issue. It
> is just the above looks quite ugly.
>
>> > [...]
>> > > +static noinline depot_stack_handle_t save_stack(gfp_t flags)
>> > > +{
>> > > + unsigned long entries[PAGE_OWNER_STACK_DEPTH];
>> > >   struct stack_trace trace = {
>> > >           .nr_entries = 0,
>> > > -         .max_entries = ARRAY_SIZE(page_ext->trace_entries),
>> > > -         .entries = &page_ext->trace_entries[0],
>> > > -         .skip = 3,
>> > > +         .entries = entries,
>> > > +         .max_entries = PAGE_OWNER_STACK_DEPTH,
>> > > +         .skip = 0
>> > >   };
>> > [...]
>> > >  void __dump_page_owner(struct page *page)
>> > >  {
>> > >   struct page_ext *page_ext = lookup_page_ext(page);
>> > > + unsigned long entries[PAGE_OWNER_STACK_DEPTH];
>> >
>> > This is worrying because of the excessive stack consumption while we
>> > might be in a deep call chain already. Can we preallocate a hash table
>> > for few buffers when the feature is enabled? This would require locking
>> > of course but chances are that contention wouldn't be that large.
>>
>> Make sense but I'm not sure that excessive stack consumption would
>> cause real problem. For example, if direct reclaim is triggered during
>> allocation, it may go more deeper than this path.
>
> Do we really consume 512B of stack during reclaim. That sounds more than
> worrying to me.

Hmm...I checked it by ./script/stackusage and result is as below.

shrink_zone() 128
shrink_zone_memcg() 248
shrink_active_list() 176

We have a call path that shrink_zone() -> shrink_zone_memcg() ->
shrink_active_list().
I'm not sure whether it is the deepest path or not.

>> I'd like to postpone to handle this issue until stack breakage is
>> reported due to this feature.
>
> I dunno, but I would expect that a debugging feature wouldn't cause
> problems like that. It is more than sad when you cannot debug your
> issue just because of the stack consumption...

Okay. I will think more.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
