Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 210CA6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 09:22:50 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o74so34707825iod.15
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 06:22:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g201sor2152327ita.122.2017.10.30.06.22.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 06:22:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509364987-29608-1-git-send-email-kyeongdon.kim@lge.com>
References: <1509364987-29608-1-git-send-email-kyeongdon.kim@lge.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Mon, 30 Oct 2017 16:22:04 +0300
Message-ID: <CAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com>
Subject: Re: [PATCH] ksm : use checksum and memcmp for rb_tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, broonie@kernel.org, mhocko@suse.com, mingo@kernel.org, jglisse@redhat.com, Arvind Yadav <arvind.yadav.cs@gmail.com>, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, bongkyu.kim@lge.com, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

2017-10-30 15:03 GMT+03:00 Kyeongdon Kim <kyeongdon.kim@lge.com>:
> The current ksm is using memcmp to insert and search 'rb_tree'.
> It does cause very expensive computation cost.
> In order to reduce the time of this operation,
> we have added a checksum to traverse before memcmp operation.
>
> Nearly all 'rb_node' in stable_tree_insert() function
> can be inserted as a checksum, most of it is possible
> in unstable_tree_search_insert() function.
> In stable_tree_search() function, the checksum may be an additional.
> But, checksum check duration is extremely small.
> Considering the time of the whole cmp_and_merge_page() function,
> it requires very little cost on average.
>
> Using this patch, we compared the time of ksm_do_scan() function
> by adding kernel trace at the start-end position of operation.
> (ARM 32bit target android device,
> over 1000 sample time gap stamps average)
>
> On original KSM scan avg duration = 0.0166893 sec
> 24991.975619 : ksm_do_scan_start: START: ksm_do_scan
> 24991.990975 : ksm_do_scan_end: END: ksm_do_scan
> 24992.008989 : ksm_do_scan_start: START: ksm_do_scan
> 24992.016839 : ksm_do_scan_end: END: ksm_do_scan
> ...
>
> On patch KSM scan avg duration = 0.0041157 sec
> 41081.461312 : ksm_do_scan_start: START: ksm_do_scan
> 41081.466364 : ksm_do_scan_end: END: ksm_do_scan
> 41081.484767 : ksm_do_scan_start: START: ksm_do_scan
> 41081.487951 : ksm_do_scan_end: END: ksm_do_scan
> ...
>
> We have tested randomly so many times for the stability
> and couldn't see any abnormal issue until now.
> Also, we found out this patch can make some good advantage
> for the power consumption than KSM default enable.
>
> Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> ---
>  mm/ksm.c | 49 +++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 45 insertions(+), 4 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index be8f457..66ab4f4 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -150,6 +150,7 @@ struct stable_node {
>         struct hlist_head hlist;
>         union {
>                 unsigned long kpfn;
> +               u32 oldchecksum;
>                 unsigned long chain_prune_time;
>         };
>         /*

May be just checksum? i.e. that's can be "old", where checksum can change,
in stable tree, checksum also stable.

Also, as checksum are stable, may be that make a sense to move it out
of union? (I'm afraid of clashes)

Also, you miss update comment above struct stable_node, about checksum var.

> @@ -1522,7 +1523,7 @@ static __always_inline struct page *chain(struct stable_node **s_n_d,
>   * This function returns the stable tree node of identical content if found,
>   * NULL otherwise.
>   */
> -static struct page *stable_tree_search(struct page *page)
> +static struct page *stable_tree_search(struct page *page, u32 checksum)
>  {
>         int nid;
>         struct rb_root *root;
> @@ -1540,6 +1541,8 @@ static struct page *stable_tree_search(struct page *page)
>
>         nid = get_kpfn_nid(page_to_pfn(page));
>         root = root_stable_tree + nid;
> +       if (!checksum)
> +               return NULL;

That's not a pointer, and 0x0 - is a valid checksum.
Also, jhash2 not so collision free, i.e.:
jhash2((uint32_t *) &num, 2, 17);

Example of collisions, where hash = 0x0:
hash: 0x0 - num:        610041898
hash: 0x0 - num:        4893164379
hash: 0x0 - num:        16423540221
hash: 0x0 - num:        29036382188

You also compare values, so hash = 0, is a acceptable checksum.

>  again:
>         new = &root->rb_node;
>         parent = NULL;
> @@ -1550,6 +1553,18 @@ static struct page *stable_tree_search(struct page *page)
>
>                 cond_resched();
>                 stable_node = rb_entry(*new, struct stable_node, node);
> +
> +               /* first make rb_tree by checksum */
> +               if (checksum < stable_node->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_left;
> +                       continue;
> +               } else if (checksum > stable_node->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_right;
> +                       continue;
> +               }
> +
>                 stable_node_any = NULL;
>                 tree_page = chain_prune(&stable_node_dup, &stable_node, root);
>                 /*
> @@ -1768,7 +1783,7 @@ static struct page *stable_tree_search(struct page *page)
>   * This function returns the stable tree node just allocated on success,
>   * NULL otherwise.
>   */
> -static struct stable_node *stable_tree_insert(struct page *kpage)
> +static struct stable_node *stable_tree_insert(struct page *kpage, u32 checksum)
>  {
>         int nid;
>         unsigned long kpfn;
> @@ -1792,6 +1807,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>                 cond_resched();
>                 stable_node = rb_entry(*new, struct stable_node, node);
>                 stable_node_any = NULL;
> +
> +               /* first make rb_tree by checksum */
> +               if (checksum < stable_node->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_left;
> +                       continue;
> +               } else if (checksum > stable_node->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_right;
> +                       continue;
> +               }
> +
>                 tree_page = chain(&stable_node_dup, stable_node, root);
>                 if (!stable_node_dup) {
>                         /*
> @@ -1850,6 +1877,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>
>         INIT_HLIST_HEAD(&stable_node_dup->hlist);
>         stable_node_dup->kpfn = kpfn;
> +       stable_node_dup->oldchecksum = checksum;
>         set_page_stable_node(kpage, stable_node_dup);
>         stable_node_dup->rmap_hlist_len = 0;
>         DO_NUMA(stable_node_dup->nid = nid);
> @@ -1907,6 +1935,19 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>
>                 cond_resched();
>                 tree_rmap_item = rb_entry(*new, struct rmap_item, node);
> +
> +               /* first make rb_tree by checksum */
> +               if (rmap_item->oldchecksum < tree_rmap_item->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_left;
> +                       continue;
> +               } else if (rmap_item->oldchecksum
> +                                       > tree_rmap_item->oldchecksum) {
> +                       parent = *new;
> +                       new = &parent->rb_right;
> +                       continue;
> +               }
> +
>                 tree_page = get_mergeable_page(tree_rmap_item);
>                 if (!tree_page)
>                         return NULL;
> @@ -2031,7 +2072,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>         }
>
>         /* We first start with searching the page inside the stable tree */
> -       kpage = stable_tree_search(page);
> +       kpage = stable_tree_search(page, rmap_item->oldchecksum);
>         if (kpage == page && rmap_item->head == stable_node) {
>                 put_page(kpage);
>                 return;
> @@ -2098,7 +2139,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>                          * node in the stable tree and add both rmap_items.
>                          */
>                         lock_page(kpage);
> -                       stable_node = stable_tree_insert(kpage);
> +                       stable_node = stable_tree_insert(kpage, checksum);
>                         if (stable_node) {
>                                 stable_tree_append(tree_rmap_item, stable_node,
>                                                    false);
> --
> 2.6.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Thanks,
anyway in general idea looks good.

Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>

-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
