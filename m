Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4A56B0407
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:50:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so12511460wmf.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:50:59 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id o7si7208669wjd.181.2016.11.18.03.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:50:58 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id a20so5373812wme.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:50:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1479341856-30320-60-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com> <1479341856-30320-60-git-send-email-mawilcox@linuxonhyperv.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Fri, 18 Nov 2016 14:50:56 +0300
Message-ID: <CALYGNiObc5zm8TQ9xTzwpBJRvOrgeMVkQM5wxges=9TsSj9Msg@mail.gmail.com>
Subject: Re: [PATCH 21/29] radix-tree: Delete radix_tree_locate_item()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Nov 17, 2016 at 3:17 AM, Matthew Wilcox
<mawilcox@linuxonhyperv.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> This rather complicated function can be better implemented as an iterator.
> It has only one caller, so move the functionality to the only place that
> needs it.  Update the test suite to follow the same pattern.

Looks good. I suppose this patch could be applied separately.

>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/radix-tree.h            |  1 -
>  lib/radix-tree.c                      | 99 -----------------------------------
>  mm/shmem.c                            | 26 ++++++++-
>  tools/testing/radix-tree/main.c       |  8 +--
>  tools/testing/radix-tree/multiorder.c |  2 +-
>  tools/testing/radix-tree/test.c       | 22 ++++++++
>  tools/testing/radix-tree/test.h       |  2 +
>  7 files changed, 54 insertions(+), 106 deletions(-)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 36c6175..57bf635 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -306,7 +306,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
>                 unsigned long nr_to_tag,
>                 unsigned int fromtag, unsigned int totag);
>  int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
> -unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item);
>
>  static inline void radix_tree_preload_end(void)
>  {
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 27b53ef..7e70ac9 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -1605,105 +1605,6 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
>  }
>  EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
>
> -#if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
> -#include <linux/sched.h> /* for cond_resched() */
> -
> -struct locate_info {
> -       unsigned long found_index;
> -       bool stop;
> -};
> -
> -/*
> - * This linear search is at present only useful to shmem_unuse_inode().
> - */
> -static unsigned long __locate(struct radix_tree_node *slot, void *item,
> -                             unsigned long index, struct locate_info *info)
> -{
> -       unsigned long i;
> -
> -       do {
> -               unsigned int shift = slot->shift;
> -
> -               for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
> -                    i < RADIX_TREE_MAP_SIZE;
> -                    i++, index += (1UL << shift)) {
> -                       struct radix_tree_node *node =
> -                                       rcu_dereference_raw(slot->slots[i]);
> -                       if (node == RADIX_TREE_RETRY)
> -                               goto out;
> -                       if (!radix_tree_is_internal_node(node)) {
> -                               if (node == item) {
> -                                       info->found_index = index;
> -                                       info->stop = true;
> -                                       goto out;
> -                               }
> -                               continue;
> -                       }
> -                       node = entry_to_node(node);
> -                       if (is_sibling_entry(slot, node))
> -                               continue;
> -                       slot = node;
> -                       break;
> -               }
> -       } while (i < RADIX_TREE_MAP_SIZE);
> -
> -out:
> -       if ((index == 0) && (i == RADIX_TREE_MAP_SIZE))
> -               info->stop = true;
> -       return index;
> -}
> -
> -/**
> - *     radix_tree_locate_item - search through radix tree for item
> - *     @root:          radix tree root
> - *     @item:          item to be found
> - *
> - *     Returns index where item was found, or -1 if not found.
> - *     Caller must hold no lock (since this time-consuming function needs
> - *     to be preemptible), and must check afterwards if item is still there.
> - */
> -unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
> -{
> -       struct radix_tree_node *node;
> -       unsigned long max_index;
> -       unsigned long cur_index = 0;
> -       struct locate_info info = {
> -               .found_index = -1,
> -               .stop = false,
> -       };
> -
> -       do {
> -               rcu_read_lock();
> -               node = rcu_dereference_raw(root->rnode);
> -               if (!radix_tree_is_internal_node(node)) {
> -                       rcu_read_unlock();
> -                       if (node == item)
> -                               info.found_index = 0;
> -                       break;
> -               }
> -
> -               node = entry_to_node(node);
> -
> -               max_index = node_maxindex(node);
> -               if (cur_index > max_index) {
> -                       rcu_read_unlock();
> -                       break;
> -               }
> -
> -               cur_index = __locate(node, item, cur_index, &info);
> -               rcu_read_unlock();
> -               cond_resched();
> -       } while (!info.stop && cur_index <= max_index);
> -
> -       return info.found_index;
> -}
> -#else
> -unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
> -{
> -       return -1;
> -}
> -#endif /* CONFIG_SHMEM && CONFIG_SWAP */
> -
>  /**
>   *     radix_tree_shrink    -    shrink radix tree to minimum height
>   *     @root           radix tree root
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 0b3fe33..8f9c9aa 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1046,6 +1046,30 @@ static void shmem_evict_inode(struct inode *inode)
>         clear_inode(inode);
>  }
>
> +static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
> +{
> +       struct radix_tree_iter iter;
> +       void **slot;
> +       unsigned long found = -1;
> +       unsigned int checked = 0;
> +
> +       rcu_read_lock();
> +       radix_tree_for_each_slot(slot, root, &iter, 0) {
> +               if (*slot == item) {
> +                       found = iter.index;
> +                       break;
> +               }
> +               checked++;
> +               if ((checked % 4096) != 0)
> +                       continue;
> +               slot = radix_tree_iter_next(slot, &iter);
> +               cond_resched_rcu();
> +       }
> +
> +       rcu_read_unlock();
> +       return found;
> +}
> +
>  /*
>   * If swap found in inode, free it and move page from swapcache to filecache.
>   */
> @@ -1059,7 +1083,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
>         int error = 0;
>
>         radswap = swp_to_radix_entry(swap);
> -       index = radix_tree_locate_item(&mapping->page_tree, radswap);
> +       index = find_swap_entry(&mapping->page_tree, radswap);
>         if (index == -1)
>                 return -EAGAIN; /* tell shmem_unuse we found nothing */
>
> diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
> index 8621542..93a77f9 100644
> --- a/tools/testing/radix-tree/main.c
> +++ b/tools/testing/radix-tree/main.c
> @@ -239,7 +239,7 @@ static void __locate_check(struct radix_tree_root *tree, unsigned long index,
>
>         item_insert_order(tree, index, order);
>         item = item_lookup(tree, index);
> -       index2 = radix_tree_locate_item(tree, item);
> +       index2 = find_item(tree, item);
>         if (index != index2) {
>                 printf("index %ld order %d inserted; found %ld\n",
>                         index, order, index2);
> @@ -273,17 +273,17 @@ static void locate_check(void)
>                              index += (1UL << order)) {
>                                 __locate_check(&tree, index + offset, order);
>                         }
> -                       if (radix_tree_locate_item(&tree, &tree) != -1)
> +                       if (find_item(&tree, &tree) != -1)
>                                 abort();
>
>                         item_kill_tree(&tree);
>                 }
>         }
>
> -       if (radix_tree_locate_item(&tree, &tree) != -1)
> +       if (find_item(&tree, &tree) != -1)
>                 abort();
>         __locate_check(&tree, -1, 0);
> -       if (radix_tree_locate_item(&tree, &tree) != -1)
> +       if (find_item(&tree, &tree) != -1)
>                 abort();
>         item_kill_tree(&tree);
>  }
> diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
> index 588209a..400de5c 100644
> --- a/tools/testing/radix-tree/multiorder.c
> +++ b/tools/testing/radix-tree/multiorder.c
> @@ -347,7 +347,7 @@ static void __multiorder_join(unsigned long index,
>         item_insert_order(&tree, index, order2);
>         item = radix_tree_lookup(&tree, index);
>         radix_tree_join(&tree, index + 1, order1, item2);
> -       loc = radix_tree_locate_item(&tree, item);
> +       loc = find_item(&tree, item);
>         if (loc == -1)
>                 free(item);
>         item = radix_tree_lookup(&tree, index + 1);
> diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
> index a6e8099..a68ed3b 100644
> --- a/tools/testing/radix-tree/test.c
> +++ b/tools/testing/radix-tree/test.c
> @@ -142,6 +142,28 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
>         assert(nfound == 0);
>  }
>
> +/* Use the same pattern as find_swap_entry() in mm/shmem.c */
> +unsigned long find_item(struct radix_tree_root *root, void *item)
> +{
> +       struct radix_tree_iter iter;
> +       void **slot;
> +       unsigned long found = -1;
> +       unsigned long checked = 0;
> +
> +       radix_tree_for_each_slot(slot, root, &iter, 0) {
> +               if (*slot == item) {
> +                       found = iter.index;
> +                       break;
> +               }
> +               checked++;
> +               if ((checked % 4) != 0)
> +                       continue;
> +               slot = radix_tree_iter_next(slot, &iter);
> +       }
> +
> +       return found;
> +}
> +
>  static int verify_node(struct radix_tree_node *slot, unsigned int tag,
>                         int tagged)
>  {
> diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
> index b678f13..ccdd3c1 100644
> --- a/tools/testing/radix-tree/test.h
> +++ b/tools/testing/radix-tree/test.h
> @@ -27,6 +27,8 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
>                         unsigned long nr, int chunk);
>  void item_kill_tree(struct radix_tree_root *root);
>
> +unsigned long find_item(struct radix_tree_root *, void *item);
> +
>  void tag_check(void);
>  void multiorder_checks(void);
>  void iteration_test(void);
> --
> 2.10.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
