Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB0966B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:16:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x18-v6so6857446wrl.21
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:16:50 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id p21-v6si1169598wmc.93.2018.05.23.01.16.49
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 01:16:49 -0700 (PDT)
Date: Wed, 23 May 2018 10:16:49 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523081649.GA30518@techadventures.net>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523075239.GF20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed, May 23, 2018 at 09:52:39AM +0200, Michal Hocko wrote:
> On Wed 23-05-18 09:35:47, Oscar Salvador wrote:
> > Hi,
> > 
> > This is something I spotted while testing offlining memory.
> > 
> > __offline_pages() calls do_migrate_range() to try to migrate a range,
> > but we do not actually check for the error code.
> 
> Yes, this is intentional. do_migrate_range doesn't distinguish between
> temporal and permanent migration failure. Getting EBUSY would be just
> too easy and that is why we retry. We rely on start_isolate_page_range
> to tell us about any non-migrateable pages and we consider all other
> failures as temporal.
> 
> > This, besides of ignoring underlying failures, can led to a situations
> > where we never break up the loop because we are totally unaware of
> > what is going on.
> 
> This shouldn't happen. If it does then start_isolate_page_range should
> handle those non-migrateable pages.
> 
> > They way I spotted this was when trying to offline all memblocks belonging
> > to a node.
> > Due to an unfortunate setting with movablecore, memblocks containing bootmem
> > memory (pages marked by get_page_bootmem()) ended up marked in zone_movable.
> 
> This is a bug as well. Zone movable shouldn't contain any
> non-migrateable pages.
> 
> [...]
> 
> > Since the pages from bootmem are not LRU, we call isolate_movable_page()
> > but we fail when checking for __PageMovable().
> > Since the page_count is more than 0 we return -EBUSY, but we do not check this
> > in our caller, so we keep trying to migrate this memory over and over:
> > 
> > repeat:
> > ...
> >         pfn = scan_movable_pages(start_pfn, end_pfn);
> >         if (pfn) { /* We have movable pages */
> >                 ret = do_migrate_range(pfn, end_pfn);
> >                 goto repeat;
> >         }
> > 
> > But this is not only situation where we can get stuck.
> > For example, if we fail with -ENOMEM in
> > migrate_pages()->unmap_and_move()/unmap_and_move_huge_page(), we will keep trying as well.
> 
> ENOMEM is highly unlikely because we are should be allocating only small
> order pages and those do not fail unless the originator is killed by the
> oom killer and we would break out of the loop in such a cace because of
> signals pending.
> 
> > I think we should really detect these cases and fail with "goto failed_removal".
> > Something like
> > 
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1651,6 +1651,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >         pfn = scan_movable_pages(start_pfn, end_pfn);
> >         if (pfn) { /* We have movable pages */
> >                 ret = do_migrate_range(pfn, end_pfn);
> > +               if (ret) {
> > +                       if (ret != -ENOMEM)
> > +                               ret = -EBUSY;
> > +                       goto failed_removal;
> > +               }
> >                 goto repeat;
> >         }
> 
> no, not really. As explained above this would allow to fail the
> offlining way too easily. Yeah, the current code is far from optimal. We
> used to have a retry count but that one was removed exactly because of
> premature failures. There are three things here
> 1) zone_movable should contain any bootmem or otherwise non-migrateable
>    pages
> 2) start_isolate_page_range should fail when seeing such pages - maybe
>    has_unmovable_pages is overly optimistic and it should check all
>    pages even in movable zones.

I will see if I can work this out.

> 3) migrate_pages should really tell us whether the failure is temporal
>    or permanent. I am not sure we can do that easily though.

AFAIU, permament errors are things like -EBUSY, -ENOSYS, -ENOMEM,
and a temporary one would be -EAGAIN?
Maybe it is overcomplicated, but what about adding another parameter to
migrate_pages() where we set the real error.
something like:

int migrate_pages(struct list_head *from, new_page_t get_new_page,
		free_page_t put_new_page, unsigned long private,
		enum migrate_mode mode, int reason, int *error)

Now it is not possible to find out why did we fail there.
We just get the number of pages that were not migrated (unless it is -ENOMEM, 
which completely bails out and returns that)
For -EBUSY,-ENOSYS and -EAGAIN we just increment some value and return it.

Although as I said, this might be overcomplicating things.

Oscar Salvador
