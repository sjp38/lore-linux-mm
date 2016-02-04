Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id E78294403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 03:50:36 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id bc4so26980302lbc.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:50:36 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id r200si6638089lfe.208.2016.02.04.00.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 00:50:35 -0800 (PST)
Received: by mail-lf0-x22d.google.com with SMTP id m1so31935779lfg.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:50:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453929472-25566-6-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
	<1453929472-25566-6-git-send-email-matthew.r.wilcox@intel.com>
Date: Thu, 4 Feb 2016 11:50:35 +0300
Message-ID: <CALYGNiOr42QxHh4GrmB3REzXYDXaa7U=903VKHcDDWtd2Wureg@mail.gmail.com>
Subject: Re: [PATCH 5/5] radix-tree,shmem: Introduce radix_tree_iter_next()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 28, 2016 at 12:17 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> shmem likes to occasionally drop the lock, schedule, then reacqire
> the lock and continue with the iteration from the last place it
> left off.  This is currently done with a pretty ugly goto.  Introduce
> radix_tree_iter_next() and use it throughout shmem.c.
>
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> ---
>  include/linux/radix-tree.h | 15 +++++++++++++++
>  mm/shmem.c                 | 12 +++---------
>  2 files changed, 18 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index db0ed595749b..dec2c6c77eea 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -403,6 +403,21 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
>  }
>
>  /**
> + * radix_tree_iter_next - resume iterating when the chunk may be invalid
> + * @iter:      iterator state
> + *
> + * If the iterator needs to release then reacquire a lock, the chunk may
> + * have been invalidated by an insertion or deletion.  Call this function
> + * to continue the iteration from the next index.
> + */
> +static inline __must_check
> +void **radix_tree_iter_next(struct radix_tree_iter *iter)
> +{
> +       iter->next_index = iter->index + 1;
> +       return NULL;
> +}
> +
> +/**

This works for normal iterator but not for tagged.
It must also reset iter->tags to zero.

>   * radix_tree_chunk_size - get current chunk size
>   *
>   * @iter:      pointer to radix tree iterator
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 6ec14b70d82d..438ea8004c26 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -376,7 +376,6 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>
>         rcu_read_lock();
>
> -restart:
>         radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
>                 if (iter.index >= end)
>                         break;
> @@ -398,8 +397,7 @@ restart:
>
>                 if (need_resched()) {
>                         cond_resched_rcu();
> -                       start = iter.index + 1;
> -                       goto restart;
> +                       slot = radix_tree_iter_next(&iter);
>                 }
>         }
>
> @@ -1950,7 +1948,6 @@ static void shmem_tag_pins(struct address_space *mapping)
>         start = 0;
>         rcu_read_lock();
>
> -restart:
>         radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
>                 page = radix_tree_deref_slot(slot);
>                 if (!page || radix_tree_exception(page)) {
> @@ -1967,8 +1964,7 @@ restart:
>
>                 if (need_resched()) {
>                         cond_resched_rcu();
> -                       start = iter.index + 1;
> -                       goto restart;
> +                       slot = radix_tree_iter_next(&iter);
>                 }
>         }
>         rcu_read_unlock();
> @@ -2005,7 +2001,6 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>
>                 start = 0;
>                 rcu_read_lock();
> -restart:
>                 radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
>                                            start, SHMEM_TAG_PINNED) {
>
> @@ -2039,8 +2034,7 @@ restart:
>  continue_resched:
>                         if (need_resched()) {
>                                 cond_resched_rcu();
> -                               start = iter.index + 1;
> -                               goto restart;
> +                               slot = radix_tree_iter_next(&iter);
>                         }
>                 }
>                 rcu_read_unlock();
> --
> 2.7.0.rc3
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
