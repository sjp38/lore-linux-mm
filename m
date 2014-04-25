Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC546B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 04:38:36 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so2590192eek.10
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:38:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si12086392eel.350.2014.04.25.01.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 01:38:35 -0700 (PDT)
Date: Fri, 25 Apr 2014 09:38:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] swap: change swap_info singly-linked list to
 list_head
Message-ID: <20140425083830.GY23991@suse.de>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1397336454-13855-2-git-send-email-ddstreet@ieee.org>
 <20140423103400.GH23991@suse.de>
 <CALZtONCa3jLrYkPSFPNnV84zePxFtdkWJBu092ScgUe2AugMxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALZtONCa3jLrYkPSFPNnV84zePxFtdkWJBu092ScgUe2AugMxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Shaohua Li <shli@fusionio.com>, Weijie Yang <weijieut@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 24, 2014 at 02:48:43PM -0400, Dan Streetman wrote:
> >> <SNIP>
> >> -             }
> >> -
> >> +     list_for_each(tmp, &swap_list_head) {
> >> +             si = list_entry(tmp, typeof(*si), list);
> >>               spin_lock(&si->lock);
> >> -             if (!si->highest_bit) {
> >> -                     spin_unlock(&si->lock);
> >> -                     continue;
> >> -             }
> >> -             if (!(si->flags & SWP_WRITEOK)) {
> >> +             if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
> >>                       spin_unlock(&si->lock);
> >>                       continue;
> >>               }
> >>
> >> -             swap_list.next = next;
> >> +             /*
> >> +              * rotate the current swap_info that we're going to use
> >> +              * to after any other swap_info that have the same prio,
> >> +              * so that all equal-priority swap_info get used equally
> >> +              */
> >> +             next = si;
> >> +             list_for_each_entry_continue(next, &swap_list_head, list) {
> >> +                     if (si->prio != next->prio)
> >> +                             break;
> >> +                     list_rotate_left(&si->list);
> >> +                     next = si;
> >> +             }
> >>
> >
> > The list manipulations will be a lot of cache writes as the list is shuffled
> > around. On slow storage I do not think this will be noticable but it may
> > be noticable on faster swap devices that are SSD based. I've added Shaohua
> > Li to the cc as he has been concerned with the performance of swap in the
> > past. Shaohua, can you run this patchset through any of your test cases
> > with the addition that multiple swap files are used to see if the cache
> > writes are noticable? You'll need multiple swap files, some of which are
> > at equal priority so the list shuffling logic is triggered.
> 
> One performance improvement could be instead of rotating the current
> entry past each following same-prio entry, just scan to the end of the
> same-prio entries and move the current entry there; that would skip
> the extra writes.  Especially since this code will run for each
> get_swap_page(), no need for any unnecessary writes.
> 

Shaohua is the person that would be most sensitive to performance problems
in this area and his tests are in the clear. If he's happy then I don't
think there is justification for changing the patch as-is.

> >
> >>               spin_unlock(&swap_lock);
> >>               /* This is called for allocating swap entry for cache */
> >>               offset = scan_swap_map(si, SWAP_HAS_CACHE);
> >>               spin_unlock(&si->lock);
> >>               if (offset)
> >> -                     return swp_entry(type, offset);
> >> +                     return swp_entry(si->type, offset);
> >>               spin_lock(&swap_lock);
> >> -             next = swap_list.next;
> >> +             /*
> >> +              * shouldn't really have got here, but for some reason the
> >> +              * scan_swap_map came back empty for this swap_info.
> >> +              * Since we dropped the swap_lock, there may now be
> >> +              * non-full higher prio swap_infos; let's start over.
> >> +              */
> >> +             tmp = &swap_list_head;
> >>       }
> >
> > Has this ever triggered? The number of swap pages was examined under the
> > swap lock so no other process should have been iterating through the
> > swap files. Once a candidate was found, the si lock was acquired for the
> > swap scan map so nothing else should have raced with it.
> 
> Well scan_swap_map() does drop the si->lock if it has any trouble at
> all finding an offset to use, so I think it's possible that for a
> nearly-full si multiple concurrent get_swap_page() calls could enter
> scan_swap_map() with the same si, only some of them actually get pages
> from the si and then the si becomes full, and the other threads in
> scan_swap_map() see it's full and exit in failure.  I can update the
> code comment there to better indicate why it was reached, instead of
> just saying "we shouldn't have got here" :-)
> 

With the updates to some comments then feel free to add

Acked-by: Mel Gorman <mgorman@suse.de>

> It may also be worth trying to get a better indicator of "available"
> swap_info_structs for use in get_swap_page(), either by looking at
> something other than si->highest_bit and/or keeping the si out of the
> prio_list until it's actually available for use, not just has a single
> entry free.  However, that probably won't be simple and might be
> better as a separate patch to the rest of these changes.
> 

I agree that it is likely outside the scope of what this series is meant
to accomplish.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
