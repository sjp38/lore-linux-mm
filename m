Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 7842F6B0007
	for <linux-mm@kvack.org>; Sat,  2 Feb 2013 03:25:50 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id fq12so3326639lab.5
        for <linux-mm@kvack.org>; Sat, 02 Feb 2013 00:25:48 -0800 (PST)
Message-ID: <510CCD88.30200@openvz.org>
Date: Sat, 02 Feb 2013 12:25:44 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: shmem: use new radix tree iterator
References: <1359699238-7327-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1359699238-7327-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Johannes Weiner wrote:
> In shmem_find_get_pages_and_swap, use the faster radix tree iterator
> construct from 78c1d78 "radix-tree: introduce bit-optimized iterator".
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Hmm, ACK. shmem_unuse_inode() also can be redone in this way.
I did something similar year ago: https://lkml.org/lkml/2012/2/10/388
As result we can rid of radix_tree_locate_item() and shmem_find_get_pages_and_swap()

> ---
>   mm/shmem.c | 25 ++++++++++++-------------
>   1 file changed, 12 insertions(+), 13 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index a368a1c..c5dc8ae 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -336,19 +336,19 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
>   					pgoff_t start, unsigned int nr_pages,
>   					struct page **pages, pgoff_t *indices)
>   {
> -	unsigned int i;
> -	unsigned int ret;
> -	unsigned int nr_found;
> +	void **slot;
> +	unsigned int ret = 0;
> +	struct radix_tree_iter iter;
> +
> +	if (!nr_pages)
> +		return 0;
>
>   	rcu_read_lock();
>   restart:
> -	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
> -				(void ***)pages, indices, start, nr_pages);
> -	ret = 0;
> -	for (i = 0; i<  nr_found; i++) {
> +	radix_tree_for_each_slot(slot,&mapping->page_tree,&iter, start) {
>   		struct page *page;
>   repeat:
> -		page = radix_tree_deref_slot((void **)pages[i]);
> +		page = radix_tree_deref_slot(slot);
>   		if (unlikely(!page))
>   			continue;
>   		if (radix_tree_exception(page)) {
> @@ -365,17 +365,16 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
>   			goto repeat;
>
>   		/* Has the page moved? */
> -		if (unlikely(page != *((void **)pages[i]))) {
> +		if (unlikely(page != *slot)) {
>   			page_cache_release(page);
>   			goto repeat;
>   		}
>   export:
> -		indices[ret] = indices[i];
> +		indices[ret] = iter.index;
>   		pages[ret] = page;
> -		ret++;
> +		if (++ret == nr_pages)
> +			break;
>   	}
> -	if (unlikely(!ret&&  nr_found))
> -		goto restart;
>   	rcu_read_unlock();
>   	return ret;
>   }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
