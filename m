Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 67EB26B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 04:58:58 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id vb8so3905871obc.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:58:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375075929-6119-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1375075929-6119-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 29 Jul 2013 16:58:57 +0800
Message-ID: <CAJd=RBD6ySxfeX0ebzJ1jsTWnOfvwSm4iyQ8Zr2W05x2LVWE2Q@mail.gmail.com>
Subject: Re: [PATCH 05/18] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, Jul 29, 2013 at 1:31 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> There is a race condition if we map a same file on different processes.
> Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> When we do mmap, we don't grab a hugetlb_instantiation_mutex, but,
> grab a mmap_sem. This doesn't prevent other process to modify region
> structure, so it can be modified by two processes concurrently.
>
> To solve this, I introduce a lock to resv_map and make region manipulation
> function grab a lock before they do actual work. This makes region
> tracking safe.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 2677c07..e29e28f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -26,6 +26,7 @@ struct hugepage_subpool {
>
>  struct resv_map {
>         struct kref refs;
> +       spinlock_t lock;
>         struct list_head regions;
>  };
>  extern struct resv_map *resv_map_alloc(void);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 24c0111..bf2ee11 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
[...]
> @@ -193,6 +188,7 @@ static long region_chg(struct resv_map *resv, long f, long t)
>         struct file_region *rg, *nrg;
>         long chg = 0;
>
> +       spin_lock(&resv->lock);
>         /* Locate the region we are before or in. */
>         list_for_each_entry(rg, head, link)
>                 if (f <= rg->to)
> @@ -203,14 +199,18 @@ static long region_chg(struct resv_map *resv, long f, long t)
>          * size such that we can guarantee to record the reservation. */
>         if (&rg->link == head || t < rg->from) {
>                 nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);

Hm, you are allocating a piece of memory with spin lock held.
How about replacing that spin lock with a mutex?

> -               if (!nrg)
> -                       return -ENOMEM;
> +               if (!nrg) {
> +                       chg = -ENOMEM;
> +                       goto out;
> +               }
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
