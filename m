Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 121BA6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:52:22 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x12so2541413wgg.18
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 10:52:22 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id vj2si2736674wjc.184.2014.04.24.10.52.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 10:52:21 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so1499243wib.11
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 10:52:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140423131404.GI23991@suse.de>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org> <1397336454-13855-3-git-send-email-ddstreet@ieee.org>
 <20140423131404.GI23991@suse.de>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 24 Apr 2014 13:52:00 -0400
Message-ID: <CALZtONCpnrFTzZkoKx75Ev-NutACD2SAnTA0xBf6JAdoeFx9jQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] swap: use separate priority list for available swap_infos
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Apr 23, 2014 at 9:14 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Sat, Apr 12, 2014 at 05:00:54PM -0400, Dan Streetman wrote:
>> Originally get_swap_page() started iterating through the singly-linked
>> list of swap_info_structs using swap_list.next or highest_priority_index,
>> which both were intended to point to the highest priority active swap
>> target that was not full.  The previous patch in this series changed the
>> singly-linked list to a doubly-linked list, and removed the logic to start
>> at the highest priority non-full entry; it starts scanning at the highest
>> priority entry each time, even if the entry is full.
>>
>> Add a new list, also priority ordered, to track only swap_info_structs
>> that are available, i.e. active and not full.  Use a new spinlock so that
>> entries can be added/removed outside of get_swap_page; that wasn't possible
>> previously because the main list is protected by swap_lock, which can't be
>> taken when holding a swap_info_struct->lock because of locking order.
>> The get_swap_page() logic now does not need to hold the swap_lock, and it
>> iterates only through swap_info_structs that are available.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  include/linux/swap.h |   1 +
>>  mm/swapfile.c        | 128 ++++++++++++++++++++++++++++++++++-----------------
>>  2 files changed, 87 insertions(+), 42 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 96662d8..d9263db 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -214,6 +214,7 @@ struct percpu_cluster {
>>  struct swap_info_struct {
>>       unsigned long   flags;          /* SWP_USED etc: see above */
>>       signed short    prio;           /* swap priority of this type */
>> +     struct list_head prio_list;     /* entry in priority list */
>>       struct list_head list;          /* entry in swap list */
>>       signed char     type;           /* strange name for an index */
>>       unsigned int    max;            /* extent of the swap_map */
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index b958645..3c38461 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -57,9 +57,13 @@ static const char Unused_file[] = "Unused swap file entry ";
>>  static const char Bad_offset[] = "Bad swap offset entry ";
>>  static const char Unused_offset[] = "Unused swap offset entry ";
>>
>> -/* all active swap_info */
>> +/* all active swap_info; protected with swap_lock */
>>  LIST_HEAD(swap_list_head);
>>
>> +/* all available (active, not full) swap_info, priority ordered */
>> +static LIST_HEAD(prio_head);
>> +static DEFINE_SPINLOCK(prio_lock);
>> +
>
> I get why you maintain two lists with separate locking but it's code that
> is specific to swap and in many respects, it's very similar to a plist. Is
> there a reason why plist was not used at least for prio_head? They're used
> for futex's so presumably the performance is reasonable. It might reduce
> the size of swapfile.c further.
>
> It is the case that plist does not have the equivalent of rotate which
> you need to recycle the entries of equal priority but you could add a
> plist_shuffle helper that "rotates the list left if the next entry is of
> equal priority".

I did look at plist, but as you said there's no plist_rotate_left() so
that would either need to be implemented in plist or a helper specific
to swap added.

The plist sort order is also reverse from swap sort order; plist
orders low->high while swap orders high->low.  So either the prio
would need to be negated when storing in the plist to correct the
order, or plist_for_each_entry_reverse() would need to be added (or
another helper specific for swap).

I think the main (only?) benefit of plist is during adds; insertion
for lists is O(N) while insertion for plists is O(K) where K is the
number of different priorities.  And for swap, the add only happens in
two places: on swapon (or if swapoff fails and reinserts it) and in
swap_entry_free() when the swap_info_struct changes from full to
not-full.  The swapon and swapoff failure cases don't matter, and a
swap_info_struct changing from full to not-full is (probably?) going
to be a relatively rare occurrence.  And even then, unless there are a
significant number of not-full same-priority swap_info_structs that
are higher prio than the one being added, there should (?) be no
difference between plist and normal list add speed.

Finally, using a plist further increases the size of each swap_info_struct.


So to me, it seemed list plists were best used in situations where
list entries were constantly being added/removed, and the add speed
needed to be as fast as possible.  That isn't typically the case with
the swap_info_struct priority list, where adding/removing is a
relatively rare occurrence.  However, in the case where there are
multiple groups of many same-priority swap devices/files, using plists
may reduce the add insertion time when one of the lower-priority
swap_info_struct changes from full to not-full after some of the
higher prio ones also have changed from full to not-full.  If you
think it would be good to change to using a plist, I can update the
patch.

Otherwise, I can update the patch to add more code comments about why
a plist wasn't used, and/or update the commit log.

> I was going to suggest that you could then get rid of swap_list_head but
> it's a relatively big change. swapoff wouldn't care but frontswap would
> suffer if it had to walk all of swap_info[] to find all active swap
> files.
>
>>  struct swap_info_struct *swap_info[MAX_SWAPFILES];
>>
>>  static DEFINE_MUTEX(swapon_mutex);
>> @@ -73,6 +77,27 @@ static inline unsigned char swap_count(unsigned char ent)
>>       return ent & ~SWAP_HAS_CACHE;   /* may include SWAP_HAS_CONT flag */
>>  }
>>
>> +/*
>> + * add, in priority order, swap_info (p)->(le) list_head to list (lh)
>> + * this list-generic function is needed because both swap_list_head
>> + * and prio_head need to be priority ordered:
>> + * swap_list_head in swapoff to adjust lower negative prio swap_infos
>> + * prio_list in get_swap_page to scan highest prio swap_info first
>> + */
>> +#define swap_info_list_add(p, lh, le) do {                   \
>> +     struct swap_info_struct *_si;                           \
>> +     BUG_ON(!list_empty(&(p)->le));                          \
>> +     list_for_each_entry(_si, (lh), le) {                    \
>> +             if ((p)->prio >= _si->prio) {                   \
>> +                     list_add_tail(&(p)->le, &_si->le);      \
>> +                     break;                                  \
>> +             }                                               \
>> +     }                                                       \
>> +     /* lh empty, or p lowest prio */                        \
>> +     if (list_empty(&(p)->le))                               \
>> +             list_add_tail(&(p)->le, (lh));                  \
>> +} while (0)
>> +
>
> Why is this a #define instead of a static uninlined function?
>
> That aside, it's again very similar to what a plist does with some
> minor structure modifications.

It's a #define because the ->member is different; for the
swap_list_head the entry member name is list while for the prio_head
the entry name is prio_list.

If the patch was accepted, I also planned to follow up with a patch to
add list_add_ordered(new, head, bool compare(a, b)) that would replace
this swap-specific #define.  I do agree having an ordered list is
similar to what plist provides, but I don't think plist is a perfect
fit for what swap needs in this case.


>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
