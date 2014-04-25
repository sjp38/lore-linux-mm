Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 581DA6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 04:49:08 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so2532044eei.5
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:49:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si12175825een.104.2014.04.25.01.49.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 01:49:06 -0700 (PDT)
Date: Fri, 25 Apr 2014 09:49:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] swap: use separate priority list for available
 swap_infos
Message-ID: <20140425084902.GZ23991@suse.de>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1397336454-13855-3-git-send-email-ddstreet@ieee.org>
 <20140423131404.GI23991@suse.de>
 <CALZtONCpnrFTzZkoKx75Ev-NutACD2SAnTA0xBf6JAdoeFx9jQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALZtONCpnrFTzZkoKx75Ev-NutACD2SAnTA0xBf6JAdoeFx9jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 24, 2014 at 01:52:00PM -0400, Dan Streetman wrote:
> On Wed, Apr 23, 2014 at 9:14 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Sat, Apr 12, 2014 at 05:00:54PM -0400, Dan Streetman wrote:
> >> Originally get_swap_page() started iterating through the singly-linked
> >> list of swap_info_structs using swap_list.next or highest_priority_index,
> >> which both were intended to point to the highest priority active swap
> >> target that was not full.  The previous patch in this series changed the
> >> singly-linked list to a doubly-linked list, and removed the logic to start
> >> at the highest priority non-full entry; it starts scanning at the highest
> >> priority entry each time, even if the entry is full.
> >>
> >> Add a new list, also priority ordered, to track only swap_info_structs
> >> that are available, i.e. active and not full.  Use a new spinlock so that
> >> entries can be added/removed outside of get_swap_page; that wasn't possible
> >> previously because the main list is protected by swap_lock, which can't be
> >> taken when holding a swap_info_struct->lock because of locking order.
> >> The get_swap_page() logic now does not need to hold the swap_lock, and it
> >> iterates only through swap_info_structs that are available.
> >>
> >> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> >> ---
> >>  include/linux/swap.h |   1 +
> >>  mm/swapfile.c        | 128 ++++++++++++++++++++++++++++++++++-----------------
> >>  2 files changed, 87 insertions(+), 42 deletions(-)
> >>
> >> diff --git a/include/linux/swap.h b/include/linux/swap.h
> >> index 96662d8..d9263db 100644
> >> --- a/include/linux/swap.h
> >> +++ b/include/linux/swap.h
> >> @@ -214,6 +214,7 @@ struct percpu_cluster {
> >>  struct swap_info_struct {
> >>       unsigned long   flags;          /* SWP_USED etc: see above */
> >>       signed short    prio;           /* swap priority of this type */
> >> +     struct list_head prio_list;     /* entry in priority list */
> >>       struct list_head list;          /* entry in swap list */
> >>       signed char     type;           /* strange name for an index */
> >>       unsigned int    max;            /* extent of the swap_map */
> >> diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> index b958645..3c38461 100644
> >> --- a/mm/swapfile.c
> >> +++ b/mm/swapfile.c
> >> @@ -57,9 +57,13 @@ static const char Unused_file[] = "Unused swap file entry ";
> >>  static const char Bad_offset[] = "Bad swap offset entry ";
> >>  static const char Unused_offset[] = "Unused swap offset entry ";
> >>
> >> -/* all active swap_info */
> >> +/* all active swap_info; protected with swap_lock */
> >>  LIST_HEAD(swap_list_head);
> >>
> >> +/* all available (active, not full) swap_info, priority ordered */
> >> +static LIST_HEAD(prio_head);
> >> +static DEFINE_SPINLOCK(prio_lock);
> >> +
> >
> > I get why you maintain two lists with separate locking but it's code that
> > is specific to swap and in many respects, it's very similar to a plist. Is
> > there a reason why plist was not used at least for prio_head? They're used
> > for futex's so presumably the performance is reasonable. It might reduce
> > the size of swapfile.c further.
> >
> > It is the case that plist does not have the equivalent of rotate which
> > you need to recycle the entries of equal priority but you could add a
> > plist_shuffle helper that "rotates the list left if the next entry is of
> > equal priority".
> 
> I did look at plist, but as you said there's no plist_rotate_left() so
> that would either need to be implemented in plist or a helper specific
> to swap added.
> 

Which in itself should not be impossible and improves an existing structure
that might be usable elsewhere again.

> The plist sort order is also reverse from swap sort order; plist
> orders low->high while swap orders high->low.  So either the prio
> would need to be negated when storing in the plist to correct the
> order, or plist_for_each_entry_reverse() would need to be added (or
> another helper specific for swap).
> 

Or add a new plist iterator that wraps around list_for_each_entry_reverse
instead of list_for_each_entry? I admit I didn't actually check if this
would work.

> I think the main (only?) benefit of plist is during adds; insertion
> for lists is O(N) while insertion for plists is O(K) where K is the
> number of different priorities.  And for swap, the add only happens in
> two places: on swapon (or if swapoff fails and reinserts it) and in
> swap_entry_free() when the swap_info_struct changes from full to
> not-full.  The swapon and swapoff failure cases don't matter, and a
> swap_info_struct changing from full to not-full is (probably?) going
> to be a relatively rare occurrence.  And even then, unless there are a
> significant number of not-full same-priority swap_info_structs that
> are higher prio than the one being added, there should (?) be no
> difference between plist and normal list add speed.
> 

I'm not angling towards plist for performance reasons but for maintenance
reasons. It would just be preferable to use existing structures and
iterators instead of adding new swap-specific code.

> Finally, using a plist further increases the size of each swap_info_struct.
> 

Considering how many of them there are in the system I would not worry
too much about the memory footprint in this case. IT's not like we are
increasing the size of struct page :)

> So to me, it seemed list plists were best used in situations where
> list entries were constantly being added/removed, and the add speed
> needed to be as fast as possible.  That isn't typically the case with
> the swap_info_struct priority list, where adding/removing is a
> relatively rare occurrence.  However, in the case where there are
> multiple groups of many same-priority swap devices/files, using plists
> may reduce the add insertion time when one of the lower-priority
> swap_info_struct changes from full to not-full after some of the
> higher prio ones also have changed from full to not-full.  If you
> think it would be good to change to using a plist, I can update the
> patch.
> 

The full to not-full case is a concern but I also think it's a corner case
that's only going to be commonly hit on stress tests and rarely on "normal"
workloads. For maintenance reasons I would prefer if plist was used to
reduce the amount of swap-specific code and move to swap-specific code only
if there is a measurable gain from doing that. If that is not possible
or the performance would suck in the normal case then just update the
changelog accordingly so the next reviewer does not bring up the same topic.

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
