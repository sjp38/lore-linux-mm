Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E43C26B004D
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 09:14:05 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so4179723vcb.14
        for <linux-mm@kvack.org>; Sat, 28 Jul 2012 06:14:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E1Sut4x-0001K1-7N@eag09.americas.sgi.com>
References: <E1Sut4x-0001K1-7N@eag09.americas.sgi.com>
Date: Sat, 28 Jul 2012 21:14:04 +0800
Message-ID: <CAJd=RBCKaBHboyrwvBt6=YFU-t_oqnrZ6p5pRio+GujuO2+hCg@mail.gmail.com>
Subject: Re: [PATCH v2] list corruption by gather_surp
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: cmetcalf@tilera.com, dave@linux.vnet.ibm.com, dwg@au1.ibm.com, kamezawa.hiroyuki@gmail.com, khlebnikov@openvz.org, lee.schermerhorn@hp.com, mgorman@suse.de, mhocko@suse.cz, shhuiw@gmail.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org

On Sat, Jul 28, 2012 at 6:32 AM, Cliff Wickman <cpw@sgi.com> wrote:
> From: Cliff Wickman <cpw@sgi.com>
>
> v2: diff'd against linux-next
>
> I am seeing list corruption occurring from within gather_surplus_pages()
> (mm/hugetlb.c).  The problem occurs in a RHEL6 kernel under a heavy load,
> and seems to be because this function drops the hugetlb_lock.
> The list_add() in gather_surplus_pages() seems to need to be protected by
> the lock.
> (I don't have a similar test for a linux-next kernel)
>

I wonder if the corruption could be triggered with 3.4.x, if yes then
add this work into the next tree.

Thanks,
                 Hillf

> I have CONFIG_DEBUG_LIST=y, and am running an MPI application with 64 threads
> and a library that creates a large heap of hugetlbfs pages for it.
>
> The below patch fixes the problem.
> The gist of this patch is that gather_surplus_pages() does not have to drop
> the lock if alloc_buddy_huge_page() is told whether the lock is already held.
>
> Signed-off-by: Cliff Wickman <cpw@sgi.com>
> ---
>  mm/hugetlb.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
>
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -838,7 +838,9 @@ static int free_pool_huge_page(struct hs
>         return ret;
>  }
>
> -static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
> +/* already_locked means the caller has already locked hugetlb_lock */
> +static struct page *alloc_buddy_huge_page(struct hstate *h, int nid,
> +                                               int already_locked)
>  {
>         struct page *page;
>         unsigned int r_nid;
> @@ -869,15 +871,19 @@ static struct page *alloc_buddy_huge_pag
>          * the node values until we've gotten the hugepage and only the
>          * per-node value is checked there.
>          */
> -       spin_lock(&hugetlb_lock);
> +       if (!already_locked)
> +               spin_lock(&hugetlb_lock);
> +
>         if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
> -               spin_unlock(&hugetlb_lock);
> +               if (!already_locked)
> +                       spin_unlock(&hugetlb_lock);
>                 return NULL;
>         } else {
>                 h->nr_huge_pages++;
>                 h->surplus_huge_pages++;
>         }
>         spin_unlock(&hugetlb_lock);
> +       /* page allocation may sleep, so the lock must be unlocked */
>
>         if (nid == NUMA_NO_NODE)
>                 page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
> @@ -910,7 +916,8 @@ static struct page *alloc_buddy_huge_pag
>                 h->surplus_huge_pages--;
>                 __count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
>         }
> -       spin_unlock(&hugetlb_lock);
> +       if (!already_locked)
> +               spin_unlock(&hugetlb_lock);
>
>         return page;
>  }
> @@ -929,7 +936,7 @@ struct page *alloc_huge_page_node(struct
>         spin_unlock(&hugetlb_lock);
>
>         if (!page)
> -               page = alloc_buddy_huge_page(h, nid);
> +               page = alloc_buddy_huge_page(h, nid, 0);
>
>         return page;
>  }
> @@ -937,6 +944,7 @@ struct page *alloc_huge_page_node(struct
>  /*
>   * Increase the hugetlb pool such that it can accommodate a reservation
>   * of size 'delta'.
> + * This is entered and exited with hugetlb_lock locked.
>   */
>  static int gather_surplus_pages(struct hstate *h, int delta)
>  {
> @@ -957,9 +965,8 @@ static int gather_surplus_pages(struct h
>
>         ret = -ENOMEM;
>  retry:
> -       spin_unlock(&hugetlb_lock);
>         for (i = 0; i < needed; i++) {
> -               page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> +               page = alloc_buddy_huge_page(h, NUMA_NO_NODE, 1);
>                 if (!page) {
>                         alloc_ok = false;
>                         break;
> @@ -969,10 +976,9 @@ retry:
>         allocated += i;
>
>         /*
> -        * After retaking hugetlb_lock, we need to recalculate 'needed'
> +        * With hugetlb_lock still locked, we need to recalculate 'needed'
>          * because either resv_huge_pages or free_huge_pages may have changed.
>          */
> -       spin_lock(&hugetlb_lock);
>         needed = (h->resv_huge_pages + delta) -
>                         (h->free_huge_pages + allocated);
>         if (needed > 0) {
> @@ -1010,15 +1016,12 @@ retry:
>                 enqueue_huge_page(h, page);
>         }
>  free:
> -       spin_unlock(&hugetlb_lock);
> -
>         /* Free unnecessary surplus pages to the buddy allocator */
>         if (!list_empty(&surplus_list)) {
>                 list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>                         put_page(page);
>                 }
>         }
> -       spin_lock(&hugetlb_lock);
>
>         return ret;
>  }
> @@ -1151,7 +1154,7 @@ static struct page *alloc_huge_page(stru
>                 spin_unlock(&hugetlb_lock);
>         } else {
>                 spin_unlock(&hugetlb_lock);
> -               page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> +               page = alloc_buddy_huge_page(h, NUMA_NO_NODE, 0);
>                 if (!page) {
>                         hugetlb_cgroup_uncharge_cgroup(idx,
>                                                        pages_per_huge_page(h),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
