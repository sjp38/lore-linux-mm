Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 938506B0261
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:26:19 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 189so2523519iow.8
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 13:26:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor4104151ioq.293.2017.11.15.13.26.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 13:26:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510715958-9174-1-git-send-email-kyeongdon.kim@lge.com>
References: <1510715958-9174-1-git-send-email-kyeongdon.kim@lge.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 16 Nov 2017 00:25:36 +0300
Message-ID: <CAGqmi77HCNiO=5Xc=c4CSHS1OioXX86bHynt560umsPZCu5n2A@mail.gmail.com>
Subject: Re: [PATCH v2] ksm : use checksum and memcmp for rb_tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, broonie@kernel.org, mhocko@suse.com, mingo@kernel.org, jglisse@redhat.com, Arvind Yadav <arvind.yadav.cs@gmail.com>, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, bongkyu.kim@lge.com, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>

2017-11-15 6:19 GMT+03:00 Kyeongdon Kim <kyeongdon.kim@lge.com>:
> The current ksm is using memcmp to insert and search 'rb_tree'.
> It does cause very expensive computation cost.
> In order to reduce the time of this operation,
> we have added a checksum to traverse.
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
> 14991.975619 : ksm_do_scan_start: START: ksm_do_scan
> 14991.990975 : ksm_do_scan_end: END: ksm_do_scan
> 14992.008989 : ksm_do_scan_start: START: ksm_do_scan
> 14992.016839 : ksm_do_scan_end: END: ksm_do_scan
> ...
>
> On patch KSM scan avg duration = 0.0041157 sec
> 41081.46131 : ksm_do_scan_start : START: ksm_do_scan
> 41081.46636 : ksm_do_scan_end : END: ksm_do_scan
> 41081.48476 : ksm_do_scan_start : START: ksm_do_scan
> 41081.48795 : ksm_do_scan_end : END: ksm_do_scan
> ...
>
> We have tested randomly so many times for the stability
> and couldn't see any abnormal issue until now.
> Also, we found out this patch can make some good advantage
> for the power consumption than KSM default enable.
>
> v1 -> v2
> - add comment for oldchecksum value
> - move the oldchecksum value out of union
> - remove check code regarding checksum 0 in stable_tree_search()
>
> link to v1 : https://lkml.org/lkml/2017/10/30/251
>
> Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> ---
>  mm/ksm.c | 48 ++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 44 insertions(+), 4 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index be8f457..9280569 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -134,6 +134,7 @@ struct ksm_scan {
>   * @kpfn: page frame number of this ksm page (perhaps temporarily on wrong nid)
>   * @chain_prune_time: time of the last full garbage collection
>   * @rmap_hlist_len: number of rmap_item entries in hlist or STABLE_NODE_CHAIN
> + * @oldchecksum: previous checksum of the page about a stable_node
>   * @nid: NUMA node id of stable tree in which linked (may not match kpfn)
>   */
>  struct stable_node {
> @@ -159,6 +160,7 @@ struct stable_node {
>          */
>  #define STABLE_NODE_CHAIN -1024
>         int rmap_hlist_len;
> +       u32 oldchecksum;
>  #ifdef CONFIG_NUMA
>         int nid;
>  #endif
> @@ -1522,7 +1524,7 @@ static __always_inline struct page *chain(struct stable_node **s_n_d,
>   * This function returns the stable tree node of identical content if found,
>   * NULL otherwise.
>   */
> -static struct page *stable_tree_search(struct page *page)
> +static struct page *stable_tree_search(struct page *page, u32 checksum)
>  {
>         int nid;
>         struct rb_root *root;
> @@ -1550,6 +1552,18 @@ static struct page *stable_tree_search(struct page *page)
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
> @@ -1768,7 +1782,7 @@ static struct page *stable_tree_search(struct page *page)
>   * This function returns the stable tree node just allocated on success,
>   * NULL otherwise.
>   */
> -static struct stable_node *stable_tree_insert(struct page *kpage)
> +static struct stable_node *stable_tree_insert(struct page *kpage, u32 checksum)
>  {
>         int nid;
>         unsigned long kpfn;
> @@ -1792,6 +1806,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
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
> @@ -1850,6 +1876,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>
>         INIT_HLIST_HEAD(&stable_node_dup->hlist);
>         stable_node_dup->kpfn = kpfn;
> +       stable_node_dup->oldchecksum = checksum;
>         set_page_stable_node(kpage, stable_node_dup);
>         stable_node_dup->rmap_hlist_len = 0;
>         DO_NUMA(stable_node_dup->nid = nid);
> @@ -1907,6 +1934,19 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
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
> @@ -2031,7 +2071,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>         }
>
>         /* We first start with searching the page inside the stable tree */
> -       kpage = stable_tree_search(page);
> +       kpage = stable_tree_search(page, rmap_item->oldchecksum);
>         if (kpage == page && rmap_item->head == stable_node) {
>                 put_page(kpage);
>                 return;
> @@ -2098,7 +2138,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
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



-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
