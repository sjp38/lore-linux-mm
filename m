Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D18A76B0461
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:56:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so1338016wme.5
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:56:17 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id w133si3291489wma.138.2016.11.18.09.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:56:16 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id a20so8562046wme.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:56:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <SN1PR21MB00770A0E46912C21844645F0CBB00@SN1PR21MB0077.namprd21.prod.outlook.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1479341856-30320-59-git-send-email-mawilcox@linuxonhyperv.com>
 <CALYGNiN++jFZZwvShjD4PDV=cZczVOs+K-ib-ZL=M+v2XU_aYQ@mail.gmail.com> <SN1PR21MB00770A0E46912C21844645F0CBB00@SN1PR21MB0077.namprd21.prod.outlook.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Fri, 18 Nov 2016 20:56:15 +0300
Message-ID: <CALYGNiMCJ+r37xPAht7tJM0s9_kX5J6SD2X0F65mqC4Mr6z0Tw@mail.gmail.com>
Subject: Re: [PATCH 20/29] radix tree: Improve multiorder iterators
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Matthew Wilcox <mawilcox@linuxonhyperv.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>

On Fri, Nov 18, 2016 at 7:31 PM, Matthew Wilcox <mawilcox@microsoft.com> wr=
ote:
> From: Konstantin Khlebnikov [mailto:koct9i@gmail.com]
>> On Thu, Nov 17, 2016 at 3:17 AM, Matthew Wilcox
>> <mawilcox@linuxonhyperv.com> wrote:
>> > This fixes several interlinked problems with the iterators in the
>> > presence of multiorder entries.
>> >
>> > 1. radix_tree_iter_next() would only advance by one slot, which would
>> > result in the iterators returning the same entry more than once if the=
re
>> > were sibling entries.
>>
>> Is this a problem? Do we have users who cannot evalate length of entry
>> by looking into it head?
>
> At the moment we have no users in tree :-)  The two users I know of are t=
he page cache and DAX.  The page cache stores a pointer to a struct page, w=
hich has compound_order() to tell you the size.  DAX uses a couple of bits =
in the radix tree entry to describe whether this is a PTE/PMD/PUD and so al=
so knows the size of the entry that it found.  We also store swap cache ent=
ries in the same radix tree (tagged exceptional).  These currently have no =
information in them to describe their size because each one represents only=
 one page.  The latest patchset to support swapping huge pages inserts 512 =
entries into the radix tree instead of taking advantage of the multiorder e=
ntry infrastructure.  Hopefully that gets fixed soon, but it will require s=
tealing a bit from either the number of swap files allowed or from the maxi=
mum size of each swap file (currently 32/128GB)
>
> I think what you're suggesting is that we introduce a new API:
>
>  slot =3D radix_tree_iter_save(&iter, order);
>
> where the caller tells us the order of the entry it just consumed.  Or ma=
ybe you're suggesting
>
>  slot =3D radix_tree_iter_advance(&iter, newindex)

Yes, someting like that.

>
> which would allow us to skip to any index.  Although ... isn't that just =
radix_tree_iter_init()?

Iterator could keep pointer to current node and reuse it for next
iteration if possible.

>
> It does push a bit of complexity onto the callers.  We have 7 callers of =
radix_tree_iter_next() in my current tree (after applying this patch set, s=
o range_tag_if_tagged and locate_item have been pushed into their callers):=
 btrfs, kugepaged, page-writeback and shmem.  btrfs knows its objects occup=
y one slot.  khugepaged knows that its page is order 0 at the time it calls=
 radix_tree_iter_next().  Page-writeback has a struct page and can simply u=
se compound_order().  It's shmem where things get sticky, although it's all=
 solvable with some temporary variables.
>

Users who work only with single slot enties don't get any complications,
all other already manage these multiorder entries somehow.

> MM people, what do you think of this patch?  It's on top of my current ID=
R tree, although I'd fold it into patch 20 of the series if it's acceptable=
.
>
> diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
> index 6d3457a..7f864ec 100644
> --- a/fs/btrfs/tests/btrfs-tests.c
> +++ b/fs/btrfs/tests/btrfs-tests.c
> @@ -162,7 +162,7 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *f=
s_info)
>                                 slot =3D radix_tree_iter_retry(&iter);
>                         continue;
>                 }
> -               slot =3D radix_tree_iter_next(slot, &iter);
> +               slot =3D radix_tree_iter_save(&iter, 0);
>                 spin_unlock(&fs_info->buffer_lock);
>                 free_extent_buffer_stale(eb);
>                 spin_lock(&fs_info->buffer_lock);
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 4e42d4d..4419325 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -421,15 +421,22 @@ __radix_tree_iter_add(struct radix_tree_iter *iter,=
 unsigned long slots)
>  }
>
>  /**
> - * radix_tree_iter_next - resume iterating when the chunk may be invalid
> - * @iter:      iterator state
> + * radix_tree_iter_save - resume iterating when the chunk may be invalid
> + * @iter: iterator state
> + * @order: order of the entry that was just processed
>   *
> - * If the iterator needs to release then reacquire a lock, the chunk may
> - * have been invalidated by an insertion or deletion.  Call this functio=
n
> + * If the iteration needs to release then reacquire a lock, the chunk ma=
y
> + * be invalidated by an insertion or deletion.  Call this function
>   * before releasing the lock to continue the iteration from the next ind=
ex.
>   */
> -void **__must_check radix_tree_iter_next(void **slot,
> -                                       struct radix_tree_iter *iter);
> +static inline void **__must_check
> +radix_tree_iter_save(struct radix_tree_iter *iter, unsigned order)
> +{
> +       iter->next_index =3D round_up(iter->index, 1 << order);
> +       iter->index =3D 0;
> +       iter->tags =3D 0;
> +       return NULL;
> +}
>
>  /**
>   * radix_tree_chunk_size - get current chunk size
> @@ -467,7 +474,7 @@ static inline void ** __radix_tree_next_slot(void **s=
lot,
>   * For tagged lookup it also eats @iter->tags.
>   *
>   * There are several cases where 'slot' can be passed in as NULL to this
> - * function.  These cases result from the use of radix_tree_iter_next() =
or
> + * function.  These cases result from the use of radix_tree_iter_save() =
or
>   * radix_tree_iter_retry().  In these cases we don't end up dereferencin=
g
>   * 'slot' because either:
>   * a) we are doing tagged iteration and iter->tags has been set to 0, or
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 7e2469b..fcbadad 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -1245,6 +1245,7 @@ static inline void __set_iter_shift(struct radix_tr=
ee_iter *iter,
>  #endif
>  }
>
> +#ifdef CONFIG_RADIX_TREE_MULTIORDER
>  static void ** __radix_tree_iter_next(struct radix_tree_node **nodep,
>                         void **slot, struct radix_tree_iter *iter)
>  {
> @@ -1263,7 +1264,6 @@ static void ** __radix_tree_iter_next(struct radix_=
tree_node **nodep,
>         return NULL;
>  }
>
> -#ifdef CONFIG_RADIX_TREE_MULTIORDER
>  void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter=
,
>                                         unsigned flags)
>  {
> @@ -1321,20 +1321,6 @@ void ** __radix_tree_next_slot(void **slot, struct=
 radix_tree_iter *iter,
>  EXPORT_SYMBOL(__radix_tree_next_slot);
>  #endif
>
> -void **radix_tree_iter_next(void **slot, struct radix_tree_iter *iter)
> -{
> -       struct radix_tree_node *node;
> -
> -       slot++;
> -       iter->index =3D __radix_tree_iter_add(iter, 1);
> -       node =3D rcu_dereference_raw(*slot);
> -       __radix_tree_iter_next(&node, slot, iter);
> -       iter->next_index =3D iter->index;
> -       iter->tags =3D 0;
> -       return NULL;
> -}
> -EXPORT_SYMBOL(radix_tree_iter_next);
> -
>  /**
>   * radix_tree_next_chunk - find next chunk of slots for iteration
>   *
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 46155d1..54446e6 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1614,7 +1614,7 @@ static void khugepaged_scan_shmem(struct mm_struct =
*mm,
>                 present++;
>
>                 if (need_resched()) {
> -                       slot =3D radix_tree_iter_next(slot, &iter);
> +                       slot =3D radix_tree_iter_save(&iter, 0);
>                         cond_resched_rcu();
>                 }
>         }
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index c593715..7d6b870 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2119,7 +2119,7 @@ void tag_pages_for_writeback(struct address_space *=
mapping,
>                 tagged++;
>                 if ((tagged % WRITEBACK_TAG_BATCH) !=3D 0)
>                         continue;
> -               slot =3D radix_tree_iter_next(slot, &iter);
> +               slot =3D radix_tree_iter_save(&iter, compound_order(*slot=
));
>                 spin_unlock_irq(&mapping->tree_lock);
>                 cond_resched();
>                 spin_lock_irq(&mapping->tree_lock);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8f9c9aa..3f2d07a 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -644,6 +644,7 @@ unsigned long shmem_partial_swap_usage(struct address=
_space *mapping,
>         rcu_read_lock();
>
>         radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start)=
 {
> +               unsigned int order =3D 0;
>                 if (iter.index >=3D end)
>                         break;
>
> @@ -656,9 +657,11 @@ unsigned long shmem_partial_swap_usage(struct addres=
s_space *mapping,
>
>                 if (radix_tree_exceptional_entry(page))
>                         swapped++;
> +               else
> +                       order =3D compound_order(page);
>
>                 if (need_resched()) {
> -                       slot =3D radix_tree_iter_next(slot, &iter);
> +                       slot =3D radix_tree_iter_save(&iter, order);
>                         cond_resched_rcu();
>                 }
>         }
> @@ -1062,7 +1065,7 @@ static unsigned long find_swap_entry(struct radix_t=
ree_root *root, void *item)
>                 checked++;
>                 if ((checked % 4096) !=3D 0)
>                         continue;
> -               slot =3D radix_tree_iter_next(slot, &iter);
> +               slot =3D radix_tree_iter_save(&iter, 0);
>                 cond_resched_rcu();
>         }
>
> @@ -2444,21 +2447,25 @@ static void shmem_tag_pins(struct address_space *=
mapping)
>         rcu_read_lock();
>
>         radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start)=
 {
> +               unsigned int order =3D 0;
>                 page =3D radix_tree_deref_slot(slot);
>                 if (!page || radix_tree_exception(page)) {
>                         if (radix_tree_deref_retry(page)) {
>                                 slot =3D radix_tree_iter_retry(&iter);
>                                 continue;
>                         }
> -               } else if (page_count(page) - page_mapcount(page) > 1) {
> -                       spin_lock_irq(&mapping->tree_lock);
> -                       radix_tree_tag_set(&mapping->page_tree, iter.inde=
x,
> -                                          SHMEM_TAG_PINNED);
> -                       spin_unlock_irq(&mapping->tree_lock);
> +               } else {
> +                       order =3D compound_order(page);
> +                       if (page_count(page) - page_mapcount(page) > 1) {
> +                               spin_lock_irq(&mapping->tree_lock);
> +                               radix_tree_tag_set(&mapping->page_tree,
> +                                               iter.index, SHMEM_TAG_PIN=
NED);
> +                               spin_unlock_irq(&mapping->tree_lock);
> +                       }
>                 }
>
>                 if (need_resched()) {
> -                       slot =3D radix_tree_iter_next(slot, &iter);
> +                       slot =3D radix_tree_iter_save(&iter, order);
>                         cond_resched_rcu();
>                 }
>         }
> @@ -2528,7 +2535,10 @@ static int shmem_wait_for_pins(struct address_spac=
e *mapping)
>                         spin_unlock_irq(&mapping->tree_lock);
>  continue_resched:
>                         if (need_resched()) {
> -                               slot =3D radix_tree_iter_next(slot, &iter=
);
> +                               unsigned int order =3D 0;
> +                               if (page)
> +                                       order =3D compound_order(page);
> +                               slot =3D radix_tree_iter_save(&iter, orde=
r);
>                                 cond_resched_rcu();
>                         }
>                 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
