Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id CDAD26B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 10:02:46 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1849034vcb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 07:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343887288-8866-9-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
	<1343887288-8866-9-git-send-email-laijs@cn.fujitsu.com>
Date: Sat, 4 Aug 2012 22:02:45 +0800
Message-ID: <CAJd=RBBVVXj99zxSpCA_wz6Md371TTrJbDjCzJMntYHrrVOaYw@mail.gmail.com>
Subject: Re: [RFC PATCH 08/23 V2] hugetlb: use N_MEMORY instead N_HIGH_MEMORY
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, Aug 2, 2012 at 2:01 PM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> N_MEMORY stands for the nodes that has any memory.
>
> The code here need to handle with the nodes which have memory, we should
> use N_MEMORY instead.
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
>  drivers/base/node.c |    2 +-
>  mm/hugetlb.c        |   24 ++++++++++++------------
>  2 files changed, 13 insertions(+), 13 deletions(-)
>

Better if the patch is split for hugetlb and node respectively.

Acked-by: Hillf Danton <dhillf@gmail.com>

> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index af1a177..31f4805 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -227,7 +227,7 @@ static node_registration_func_t __hugetlb_unregister_node;
>  static inline bool hugetlb_register_node(struct node *node)
>  {
>         if (__hugetlb_register_node &&
> -                       node_state(node->dev.id, N_HIGH_MEMORY)) {
> +                       node_state(node->dev.id, N_MEMORY)) {
>                 __hugetlb_register_node(node);
>                 return true;
>         }
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e198831..661db47 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1046,7 +1046,7 @@ static void return_unused_surplus_pages(struct hstate *h,
>          * on-line nodes with memory and will handle the hstate accounting.
>          */
>         while (nr_pages--) {
> -               if (!free_pool_huge_page(h, &node_states[N_HIGH_MEMORY], 1))
> +               if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
>                         break;
>         }
>  }
> @@ -1150,14 +1150,14 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  int __weak alloc_bootmem_huge_page(struct hstate *h)
>  {
>         struct huge_bootmem_page *m;
> -       int nr_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
> +       int nr_nodes = nodes_weight(node_states[N_MEMORY]);
>
>         while (nr_nodes) {
>                 void *addr;
>
>                 addr = __alloc_bootmem_node_nopanic(
>                                 NODE_DATA(hstate_next_node_to_alloc(h,
> -                                               &node_states[N_HIGH_MEMORY])),
> +                                               &node_states[N_MEMORY])),
>                                 huge_page_size(h), huge_page_size(h), 0);
>
>                 if (addr) {
> @@ -1229,7 +1229,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
>                         if (!alloc_bootmem_huge_page(h))
>                                 break;
>                 } else if (!alloc_fresh_huge_page(h,
> -                                        &node_states[N_HIGH_MEMORY]))
> +                                        &node_states[N_MEMORY]))
>                         break;
>         }
>         h->max_huge_pages = i;
> @@ -1497,7 +1497,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>                 if (!(obey_mempolicy &&
>                                 init_nodemask_of_mempolicy(nodes_allowed))) {
>                         NODEMASK_FREE(nodes_allowed);
> -                       nodes_allowed = &node_states[N_HIGH_MEMORY];
> +                       nodes_allowed = &node_states[N_MEMORY];
>                 }
>         } else if (nodes_allowed) {
>                 /*
> @@ -1507,11 +1507,11 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>                 count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
>                 init_nodemask_of_node(nodes_allowed, nid);
>         } else
> -               nodes_allowed = &node_states[N_HIGH_MEMORY];
> +               nodes_allowed = &node_states[N_MEMORY];
>
>         h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>
> -       if (nodes_allowed != &node_states[N_HIGH_MEMORY])
> +       if (nodes_allowed != &node_states[N_MEMORY])
>                 NODEMASK_FREE(nodes_allowed);
>
>         return len;
> @@ -1812,7 +1812,7 @@ static void hugetlb_register_all_nodes(void)
>  {
>         int nid;
>
> -       for_each_node_state(nid, N_HIGH_MEMORY) {
> +       for_each_node_state(nid, N_MEMORY) {
>                 struct node *node = &node_devices[nid];
>                 if (node->dev.id == nid)
>                         hugetlb_register_node(node);
> @@ -1906,8 +1906,8 @@ void __init hugetlb_add_hstate(unsigned order)
>         h->free_huge_pages = 0;
>         for (i = 0; i < MAX_NUMNODES; ++i)
>                 INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> -       h->next_nid_to_alloc = first_node(node_states[N_HIGH_MEMORY]);
> -       h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
> +       h->next_nid_to_alloc = first_node(node_states[N_MEMORY]);
> +       h->next_nid_to_free = first_node(node_states[N_MEMORY]);
>         snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
>                                         huge_page_size(h)/1024);
>
> @@ -1995,11 +1995,11 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>                 if (!(obey_mempolicy &&
>                                init_nodemask_of_mempolicy(nodes_allowed))) {
>                         NODEMASK_FREE(nodes_allowed);
> -                       nodes_allowed = &node_states[N_HIGH_MEMORY];
> +                       nodes_allowed = &node_states[N_MEMORY];
>                 }
>                 h->max_huge_pages = set_max_huge_pages(h, tmp, nodes_allowed);
>
> -               if (nodes_allowed != &node_states[N_HIGH_MEMORY])
> +               if (nodes_allowed != &node_states[N_MEMORY])
>                         NODEMASK_FREE(nodes_allowed);
>         }
>  out:
> --
> 1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
