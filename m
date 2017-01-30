Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9506B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:04:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so62062372wjc.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 06:04:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e68si13521783wmd.117.2017.01.30.06.04.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 06:04:46 -0800 (PST)
Subject: Re: [PATCH 3/9] rhashtable: simplify a strange allocation pattern
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <42a48532-23f5-f965-1e14-aa4b292b13cd@suse.cz>
Date: Mon, 30 Jan 2017 15:04:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170130094940.13546-4-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> alloc_bucket_locks allocation pattern is quite unusual. We are
> preferring vmalloc when CONFIG_NUMA is enabled. The rationale is that
> vmalloc will respect the memory policy of the current process and so the
> backing memory will get distributed over multiple nodes if the requester
> is configured properly. At least that is the intention, in reality
> rhastable is shrunk and expanded from a kernel worker so no mempolicy
> can be assumed.
>
> Let's just simplify the code and use kvmalloc helper, which is a
> transparent way to use kmalloc with vmalloc fallback, if the caller
> is allowed to block and use the flag otherwise.
>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  lib/rhashtable.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
>
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 32d0ad058380..1a487ea70829 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -77,16 +77,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
>  	size = min_t(unsigned int, size, tbl->size >> 1);
>
>  	if (sizeof(spinlock_t) != 0) {
> -		tbl->locks = NULL;
> -#ifdef CONFIG_NUMA
> -		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
> -		    gfp == GFP_KERNEL)
> -			tbl->locks = vmalloc(size * sizeof(spinlock_t));
> -#endif
> -		if (gfp != GFP_KERNEL)
> -			gfp |= __GFP_NOWARN | __GFP_NORETRY;
> -
> -		if (!tbl->locks)
> +		if (gfpflags_allow_blocking(gfp))
> +			tbl->locks = kvmalloc(size * sizeof(spinlock_t), gfp);
> +		else
>  			tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
>  						   gfp);
>  		if (!tbl->locks)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
