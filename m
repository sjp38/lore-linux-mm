Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0D67A6B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 08:47:30 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so3199647vcb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 05:47:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E1SuVpz-00028P-QG@eag09.americas.sgi.com>
References: <E1SuVpz-00028P-QG@eag09.americas.sgi.com>
Date: Fri, 27 Jul 2012 20:47:29 +0800
Message-ID: <CAJd=RBDW5f2LxgL9cjr53z+CJdX4DjG9nOiYX-mwrG6FE-dycA@mail.gmail.com>
Subject: Re: [PATCH] list corruption by gather_surplus
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>, LKML <linux-kernel@vger.kernel.org>
Cc: cmetcalf@tilera.com, dave@linux.vnet.ibm.com, dwg@au1.ibm.com, kamezawa.hiroyuki@gmail.com, khlebnikov@openvz.org, lee.schermerhorn@hp.com, mgorman@suse.de, mhocko@suse.cz, shhuiw@gmail.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org

On Fri, Jul 27, 2012 at 5:43 AM, Cliff Wickman <cpw@sgi.com> wrote:
> From: Cliff Wickman <cpw@sgi.com>
>
> Gentlemen,
> I see that you all have done maintenance on mm/hugetlb.c, so I'm hoping one
> or two of you could comment on a problem and proposed fix.
>
>
> I am seeing list corruption occurring from within gather_surplus_pages()
> (mm/hugetlb.c).  The problem occurs under a heavy load, and seems to be
> because this function drops the hugetlb_lock.
>
> I have CONFIG_DEBUG_LIST=y, and am running an MPI application with 64 threads
> and a library that creates a large heap of hugetlbfs pages for it.
>
> The below patch fixes the problem.
> The gist of this patch is that gather_surplus_pages() does not have to drop
> the lock if alloc_buddy_huge_page() is told whether the lock is already held.
>
> But I may be missing some reason why gather_surplus_pages() is unlocking and
> locking the hugetlb_lock several times (besides around the allocator).
>
> Could you take a look and advise?
>
> Signed-off-by: Cliff Wickman <cpw@sgi.com>
> ---
>  mm/hugetlb.c |   28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
>
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -747,7 +747,9 @@ static int free_pool_huge_page(struct hs
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
> @@ -778,7 +780,8 @@ static struct page *alloc_buddy_huge_pag
>          * the node values until we've gotten the hugepage and only the
>          * per-node value is checked there.
>          */
> -       spin_lock(&hugetlb_lock);
> +       if (!already_locked)
> +               spin_lock(&hugetlb_lock);
>         if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
>                 spin_unlock(&hugetlb_lock);
>                 return NULL;
> @@ -787,6 +790,7 @@ static struct page *alloc_buddy_huge_pag
>                 h->surplus_huge_pages++;
>         }
>         spin_unlock(&hugetlb_lock);
> +       /* page allocation may sleep, so the lock must be unlocked */
>
>         if (nid == NUMA_NO_NODE)
>                 page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
> @@ -799,6 +803,9 @@ static struct page *alloc_buddy_huge_pag
>
>         if (page && arch_prepare_hugepage(page)) {
>                 __free_pages(page, huge_page_order(h));
> +               if (already_locked)
> +                       /* leave it like it was */
> +                       spin_lock(&hugetlb_lock);
>                 return NULL;
>         }
>
> @@ -817,7 +824,9 @@ static struct page *alloc_buddy_huge_pag
>                 h->surplus_huge_pages--;
>                 __count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
>         }
> -       spin_unlock(&hugetlb_lock);
> +       if (!already_locked)
> +               /* leave it like it was */


Same comment for two different checks?


> +               spin_unlock(&hugetlb_lock);
>
>         return page;
>  }
> @@ -836,7 +845,7 @@ struct page *alloc_huge_page_node(struct
>         spin_unlock(&hugetlb_lock);
>
>         if (!page)
> -               page = alloc_buddy_huge_page(h, nid);
> +               page = alloc_buddy_huge_page(h, nid, 0);
>
>         return page;
>  }
> @@ -844,6 +853,7 @@ struct page *alloc_huge_page_node(struct
>  /*
>   * Increase the hugetlb pool such that it can accomodate a reservation
>   * of size 'delta'.
> + * This is entered and exited with hugetlb_lock locked.
>   */
>  static int gather_surplus_pages(struct hstate *h, int delta)
>  {
> @@ -863,9 +873,8 @@ static int gather_surplus_pages(struct h
>
>         ret = -ENOMEM;
>  retry:
> -       spin_unlock(&hugetlb_lock);
>         for (i = 0; i < needed; i++) {
> -               page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> +               page = alloc_buddy_huge_page(h, NUMA_NO_NODE, 1);
>                 if (!page)
>                         /*
>                          * We were not able to allocate enough pages to

Hm, what tree are you using(next tree please if not)?

Good Weekend
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
