Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 72AF26B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 14:49:05 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so2594807wes.7
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:49:04 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id hk15si340458wib.33.2014.04.24.11.49.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 11:49:03 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so2667392wgh.27
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:49:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140423103400.GH23991@suse.de>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org> <1397336454-13855-2-git-send-email-ddstreet@ieee.org>
 <20140423103400.GH23991@suse.de>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 24 Apr 2014 14:48:43 -0400
Message-ID: <CALZtONCa3jLrYkPSFPNnV84zePxFtdkWJBu092ScgUe2AugMxQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] swap: change swap_info singly-linked list to list_head
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Shaohua Li <shli@fusionio.com>, Weijie Yang <weijieut@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Apr 23, 2014 at 6:34 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Sat, Apr 12, 2014 at 05:00:53PM -0400, Dan Streetman wrote:
>> Replace the singly-linked list tracking active, i.e. swapon'ed,
>> swap_info_struct entries with a doubly-linked list using struct list_heads.
>> Simplify the logic iterating and manipulating the list of entries,
>> especially get_swap_page(), by using standard list_head functions,
>> and removing the highest priority iteration logic.
>>
>> The change fixes the bug:
>> https://lkml.org/lkml/2014/2/13/181
>> in which different priority swap entries after the highest priority entry
>> are incorrectly used equally in pairs.  The swap behavior is now as
>> advertised, i.e. different priority swap entries are used in order, and
>> equal priority swap targets are used concurrently.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  include/linux/swap.h     |   7 +--
>>  include/linux/swapfile.h |   2 +-
>>  mm/frontswap.c           |  13 ++--
>>  mm/swapfile.c            | 156 +++++++++++++++++------------------------------
>>  4 files changed, 63 insertions(+), 115 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 3507115..96662d8 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -214,8 +214,8 @@ struct percpu_cluster {
>>  struct swap_info_struct {
>>       unsigned long   flags;          /* SWP_USED etc: see above */
>>       signed short    prio;           /* swap priority of this type */
>> +     struct list_head list;          /* entry in swap list */
>>       signed char     type;           /* strange name for an index */
>> -     signed char     next;           /* next type on the swap list */
>>       unsigned int    max;            /* extent of the swap_map */
>>       unsigned char *swap_map;        /* vmalloc'ed array of usage counts */
>>       struct swap_cluster_info *cluster_info; /* cluster info. Only for SSD */
>> @@ -255,11 +255,6 @@ struct swap_info_struct {
>>       struct swap_cluster_info discard_cluster_tail; /* list tail of discard clusters */
>>  };
>>
>> -struct swap_list_t {
>> -     int head;       /* head of priority-ordered swapfile list */
>> -     int next;       /* swapfile to be used next */
>> -};
>> -
>>  /* linux/mm/workingset.c */
>>  void *workingset_eviction(struct address_space *mapping, struct page *page);
>>  bool workingset_refault(void *shadow);
>> diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
>> index e282624..2eab382 100644
>> --- a/include/linux/swapfile.h
>> +++ b/include/linux/swapfile.h
>> @@ -6,7 +6,7 @@
>>   * want to expose them to the dozens of source files that include swap.h
>>   */
>>  extern spinlock_t swap_lock;
>> -extern struct swap_list_t swap_list;
>> +extern struct list_head swap_list_head;
>>  extern struct swap_info_struct *swap_info[];
>>  extern int try_to_unuse(unsigned int, bool, unsigned long);
>>
>> diff --git a/mm/frontswap.c b/mm/frontswap.c
>> index 1b24bdc..fae1160 100644
>> --- a/mm/frontswap.c
>> +++ b/mm/frontswap.c
>> @@ -327,15 +327,12 @@ EXPORT_SYMBOL(__frontswap_invalidate_area);
>>
>>  static unsigned long __frontswap_curr_pages(void)
>>  {
>> -     int type;
>>       unsigned long totalpages = 0;
>>       struct swap_info_struct *si = NULL;
>>
>>       assert_spin_locked(&swap_lock);
>> -     for (type = swap_list.head; type >= 0; type = si->next) {
>> -             si = swap_info[type];
>> +     list_for_each_entry(si, &swap_list_head, list)
>>               totalpages += atomic_read(&si->frontswap_pages);
>> -     }
>>       return totalpages;
>>  }
>>
>> @@ -347,11 +344,9 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>>       int si_frontswap_pages;
>>       unsigned long total_pages_to_unuse = total;
>>       unsigned long pages = 0, pages_to_unuse = 0;
>> -     int type;
>>
>>       assert_spin_locked(&swap_lock);
>> -     for (type = swap_list.head; type >= 0; type = si->next) {
>> -             si = swap_info[type];
>> +     list_for_each_entry(si, &swap_list_head, list) {
>>               si_frontswap_pages = atomic_read(&si->frontswap_pages);
>>               if (total_pages_to_unuse < si_frontswap_pages) {
>>                       pages = pages_to_unuse = total_pages_to_unuse;
>
> The frontswap shrink code looks suspicious. If the target is smaller than
> the total number of frontswap pages then it does nothing. The callers
> appear to get this right at least. Similarly, if the first swapfile has
> fewer frontswap pages than the target then it does not unuse the target
> number of pages because it only handles one swap file. It's outside the
> scope of your patch to address this or wonder if xen balloon driver is
> really using it the way it's expected.

I didn't look into the frontswap shrinking code, but I agree the
existing logic there doesn't look right.  I'll review frontswap in
more detail to see if it needs changing here, unless anyone else gets
it to first :-)

And as you said, it's outside the scope of this particular patch.

>
> The old code scanned the files in priority order. Superficially this does
> not appear to but it actually does because you add the swap files to the
> list in priority order during swapon. If you do another revision it's
> worth adding a comment above swap_list_head that the list is ordered by
> priority and protected by the swap_lock.

Yep you're right, I will add a comment to make clear it's also
priority ordered, and why.  The only reason it needs to be priority
ordered is because swapoff has to adjust the auto-priority of any
following swap_info_structs when one is removed, that has an
automatically assigned (i.e. negative) priority.

>
>> @@ -366,7 +361,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>>               }
>>               vm_unacct_memory(pages);
>>               *unused = pages_to_unuse;
>> -             *swapid = type;
>> +             *swapid = si->type;
>>               ret = 0;
>>               break;
>>       }
>> @@ -413,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
>>       /*
>>        * we don't want to hold swap_lock while doing a very
>>        * lengthy try_to_unuse, but swap_list may change
>> -      * so restart scan from swap_list.head each time
>> +      * so restart scan from swap_list_head each time
>>        */
>>       spin_lock(&swap_lock);
>>       ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 4a7f7e6..b958645 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -51,14 +51,14 @@ atomic_long_t nr_swap_pages;
>>  /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
>>  long total_swap_pages;
>>  static int least_priority;
>> -static atomic_t highest_priority_index = ATOMIC_INIT(-1);
>>
>>  static const char Bad_file[] = "Bad swap file entry ";
>>  static const char Unused_file[] = "Unused swap file entry ";
>>  static const char Bad_offset[] = "Bad swap offset entry ";
>>  static const char Unused_offset[] = "Unused swap offset entry ";
>>
>> -struct swap_list_t swap_list = {-1, -1};
>> +/* all active swap_info */
>> +LIST_HEAD(swap_list_head);
>>
>>  struct swap_info_struct *swap_info[MAX_SWAPFILES];
>>
>> @@ -640,66 +640,50 @@ no_page:
>>
>>  swp_entry_t get_swap_page(void)
>>  {
>> -     struct swap_info_struct *si;
>> +     struct swap_info_struct *si, *next;
>>       pgoff_t offset;
>> -     int type, next;
>> -     int wrapped = 0;
>> -     int hp_index;
>> +     struct list_head *tmp;
>>
>>       spin_lock(&swap_lock);
>>       if (atomic_long_read(&nr_swap_pages) <= 0)
>>               goto noswap;
>>       atomic_long_dec(&nr_swap_pages);
>>
>> -     for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
>> -             hp_index = atomic_xchg(&highest_priority_index, -1);
>> -             /*
>> -              * highest_priority_index records current highest priority swap
>> -              * type which just frees swap entries. If its priority is
>> -              * higher than that of swap_list.next swap type, we use it.  It
>> -              * isn't protected by swap_lock, so it can be an invalid value
>> -              * if the corresponding swap type is swapoff. We double check
>> -              * the flags here. It's even possible the swap type is swapoff
>> -              * and swapon again and its priority is changed. In such rare
>> -              * case, low prority swap type might be used, but eventually
>> -              * high priority swap will be used after several rounds of
>> -              * swap.
>> -              */
>> -             if (hp_index != -1 && hp_index != type &&
>> -                 swap_info[type]->prio < swap_info[hp_index]->prio &&
>> -                 (swap_info[hp_index]->flags & SWP_WRITEOK)) {
>> -                     type = hp_index;
>> -                     swap_list.next = type;
>> -             }
>> -
>> -             si = swap_info[type];
>> -             next = si->next;
>> -             if (next < 0 ||
>> -                 (!wrapped && si->prio != swap_info[next]->prio)) {
>> -                     next = swap_list.head;
>> -                     wrapped++;
>> -             }
>> -
>> +     list_for_each(tmp, &swap_list_head) {
>> +             si = list_entry(tmp, typeof(*si), list);
>>               spin_lock(&si->lock);
>> -             if (!si->highest_bit) {
>> -                     spin_unlock(&si->lock);
>> -                     continue;
>> -             }
>> -             if (!(si->flags & SWP_WRITEOK)) {
>> +             if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
>>                       spin_unlock(&si->lock);
>>                       continue;
>>               }
>>
>> -             swap_list.next = next;
>> +             /*
>> +              * rotate the current swap_info that we're going to use
>> +              * to after any other swap_info that have the same prio,
>> +              * so that all equal-priority swap_info get used equally
>> +              */
>> +             next = si;
>> +             list_for_each_entry_continue(next, &swap_list_head, list) {
>> +                     if (si->prio != next->prio)
>> +                             break;
>> +                     list_rotate_left(&si->list);
>> +                     next = si;
>> +             }
>>
>
> The list manipulations will be a lot of cache writes as the list is shuffled
> around. On slow storage I do not think this will be noticable but it may
> be noticable on faster swap devices that are SSD based. I've added Shaohua
> Li to the cc as he has been concerned with the performance of swap in the
> past. Shaohua, can you run this patchset through any of your test cases
> with the addition that multiple swap files are used to see if the cache
> writes are noticable? You'll need multiple swap files, some of which are
> at equal priority so the list shuffling logic is triggered.

One performance improvement could be instead of rotating the current
entry past each following same-prio entry, just scan to the end of the
same-prio entries and move the current entry there; that would skip
the extra writes.  Especially since this code will run for each
get_swap_page(), no need for any unnecessary writes.

>
>>               spin_unlock(&swap_lock);
>>               /* This is called for allocating swap entry for cache */
>>               offset = scan_swap_map(si, SWAP_HAS_CACHE);
>>               spin_unlock(&si->lock);
>>               if (offset)
>> -                     return swp_entry(type, offset);
>> +                     return swp_entry(si->type, offset);
>>               spin_lock(&swap_lock);
>> -             next = swap_list.next;
>> +             /*
>> +              * shouldn't really have got here, but for some reason the
>> +              * scan_swap_map came back empty for this swap_info.
>> +              * Since we dropped the swap_lock, there may now be
>> +              * non-full higher prio swap_infos; let's start over.
>> +              */
>> +             tmp = &swap_list_head;
>>       }
>
> Has this ever triggered? The number of swap pages was examined under the
> swap lock so no other process should have been iterating through the
> swap files. Once a candidate was found, the si lock was acquired for the
> swap scan map so nothing else should have raced with it.

Well scan_swap_map() does drop the si->lock if it has any trouble at
all finding an offset to use, so I think it's possible that for a
nearly-full si multiple concurrent get_swap_page() calls could enter
scan_swap_map() with the same si, only some of them actually get pages
from the si and then the si becomes full, and the other threads in
scan_swap_map() see it's full and exit in failure.  I can update the
code comment there to better indicate why it was reached, instead of
just saying "we shouldn't have got here" :-)

It may also be worth trying to get a better indicator of "available"
swap_info_structs for use in get_swap_page(), either by looking at
something other than si->highest_bit and/or keeping the si out of the
prio_list until it's actually available for use, not just has a single
entry free.  However, that probably won't be simple and might be
better as a separate patch to the rest of these changes.

>
>>
>>       atomic_long_inc(&nr_swap_pages);
>> @@ -766,27 +750,6 @@ out:
>>       return NULL;
>>  }
>>
>> -/*
>> - * This swap type frees swap entry, check if it is the highest priority swap
>> - * type which just frees swap entry. get_swap_page() uses
>> - * highest_priority_index to search highest priority swap type. The
>> - * swap_info_struct.lock can't protect us if there are multiple swap types
>> - * active, so we use atomic_cmpxchg.
>> - */
>> -static void set_highest_priority_index(int type)
>> -{
>> -     int old_hp_index, new_hp_index;
>> -
>> -     do {
>> -             old_hp_index = atomic_read(&highest_priority_index);
>> -             if (old_hp_index != -1 &&
>> -                     swap_info[old_hp_index]->prio >= swap_info[type]->prio)
>> -                     break;
>> -             new_hp_index = type;
>> -     } while (atomic_cmpxchg(&highest_priority_index,
>> -             old_hp_index, new_hp_index) != old_hp_index);
>> -}
>> -
>>  static unsigned char swap_entry_free(struct swap_info_struct *p,
>>                                    swp_entry_t entry, unsigned char usage)
>>  {
>> @@ -830,7 +793,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
>>                       p->lowest_bit = offset;
>>               if (offset > p->highest_bit)
>>                       p->highest_bit = offset;
>> -             set_highest_priority_index(p->type);
>>               atomic_long_inc(&nr_swap_pages);
>>               p->inuse_pages--;
>>               frontswap_invalidate_page(p->type, offset);
>> @@ -1765,7 +1727,7 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>>                               unsigned char *swap_map,
>>                               struct swap_cluster_info *cluster_info)
>>  {
>> -     int i, prev;
>> +     struct swap_info_struct *si;
>>
>>       if (prio >= 0)
>>               p->prio = prio;
>> @@ -1777,18 +1739,21 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>>       atomic_long_add(p->pages, &nr_swap_pages);
>>       total_swap_pages += p->pages;
>>
>> -     /* insert swap space into swap_list: */
>> -     prev = -1;
>> -     for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
>> -             if (p->prio >= swap_info[i]->prio)
>> -                     break;
>> -             prev = i;
>> +     assert_spin_locked(&swap_lock);
>> +     BUG_ON(!list_empty(&p->list));
>> +     /* insert into swap list: */
>> +     list_for_each_entry(si, &swap_list_head, list) {
>> +             if (p->prio >= si->prio) {
>> +                     list_add_tail(&p->list, &si->list);
>> +                     return;
>> +             }
>
> An additional comment saying that it must be priority ordered for
> get_swap_page wouldn't kill.

will do.

>
>>       }
>> -     p->next = i;
>> -     if (prev < 0)
>> -             swap_list.head = swap_list.next = p->type;
>> -     else
>> -             swap_info[prev]->next = p->type;
>> +     /*
>> +      * this covers two cases:
>> +      * 1) p->prio is less than all existing prio
>> +      * 2) the swap list is empty
>> +      */
>> +     list_add_tail(&p->list, &swap_list_head);
>>  }
>>
>>  static void enable_swap_info(struct swap_info_struct *p, int prio,
>> @@ -1823,8 +1788,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>       struct address_space *mapping;
>>       struct inode *inode;
>>       struct filename *pathname;
>> -     int i, type, prev;
>> -     int err;
>> +     int err, found = 0;
>>       unsigned int old_block_size;
>>
>>       if (!capable(CAP_SYS_ADMIN))
>> @@ -1842,17 +1806,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>               goto out;
>>
>>       mapping = victim->f_mapping;
>> -     prev = -1;
>>       spin_lock(&swap_lock);
>> -     for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
>> -             p = swap_info[type];
>> +     list_for_each_entry(p, &swap_list_head, list) {
>>               if (p->flags & SWP_WRITEOK) {
>> -                     if (p->swap_file->f_mapping == mapping)
>> +                     if (p->swap_file->f_mapping == mapping) {
>> +                             found = 1;
>>                               break;
>> +                     }
>>               }
>> -             prev = type;
>>       }
>> -     if (type < 0) {
>> +     if (!found) {
>>               err = -EINVAL;
>>               spin_unlock(&swap_lock);
>>               goto out_dput;
>> @@ -1864,20 +1827,15 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>               spin_unlock(&swap_lock);
>>               goto out_dput;
>>       }
>> -     if (prev < 0)
>> -             swap_list.head = p->next;
>> -     else
>> -             swap_info[prev]->next = p->next;
>> -     if (type == swap_list.next) {
>> -             /* just pick something that's safe... */
>> -             swap_list.next = swap_list.head;
>> -     }
>>       spin_lock(&p->lock);
>>       if (p->prio < 0) {
>> -             for (i = p->next; i >= 0; i = swap_info[i]->next)
>> -                     swap_info[i]->prio = p->prio--;
>> +             struct swap_info_struct *si = p;
>> +             list_for_each_entry_continue(si, &swap_list_head, list) {
>> +                     si->prio++;
>> +             }
>>               least_priority++;
>>       }
>> +     list_del_init(&p->list);
>>       atomic_long_sub(p->pages, &nr_swap_pages);
>>       total_swap_pages -= p->pages;
>>       p->flags &= ~SWP_WRITEOK;
>> @@ -1885,7 +1843,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>       spin_unlock(&swap_lock);
>>
>>       set_current_oom_origin();
>> -     err = try_to_unuse(type, false, 0); /* force all pages to be unused */
>> +     err = try_to_unuse(p->type, false, 0); /* force unuse all pages */
>>       clear_current_oom_origin();
>>
>>       if (err) {
>> @@ -1926,7 +1884,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>       frontswap_map = frontswap_map_get(p);
>>       spin_unlock(&p->lock);
>>       spin_unlock(&swap_lock);
>> -     frontswap_invalidate_area(type);
>> +     frontswap_invalidate_area(p->type);
>>       frontswap_map_set(p, NULL);
>>       mutex_unlock(&swapon_mutex);
>>       free_percpu(p->percpu_cluster);
>> @@ -1935,7 +1893,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>       vfree(cluster_info);
>>       vfree(frontswap_map);
>>       /* Destroy swap account information */
>> -     swap_cgroup_swapoff(type);
>> +     swap_cgroup_swapoff(p->type);
>>
>>       inode = mapping->host;
>>       if (S_ISBLK(inode->i_mode)) {
>> @@ -2142,8 +2100,8 @@ static struct swap_info_struct *alloc_swap_info(void)
>>                */
>>       }
>>       INIT_LIST_HEAD(&p->first_swap_extent.list);
>> +     INIT_LIST_HEAD(&p->list);
>>       p->flags = SWP_USED;
>> -     p->next = -1;
>>       spin_unlock(&swap_lock);
>>       spin_lock_init(&p->lock);
>>
>> --
>> 1.8.3.1
>>
>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
