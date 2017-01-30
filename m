Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 506D26B0069
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:20:06 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so63374542wjd.2
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:20:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si14119038wmi.125.2017.01.30.09.20.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 09:20:04 -0800 (PST)
Date: Mon, 30 Jan 2017 18:20:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 9/9] net, bpf: use kvzalloc helper
Message-ID: <20170130172002.GA14783@dhcp22.suse.cz>
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-10-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170130094940.13546-10-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Andrey Konovalov <andreyknvl@google.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Daniel Borkmann <daniel@iogearbox.net>

Andrew, please ignore this one.

On Mon 30-01-17 10:49:40, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> both bpf_map_area_alloc and xt_alloc_table_info try really hard to
> play nicely with large memory requests which can be triggered from
> the userspace (by an admin). See 5bad87348c70 ("netfilter: x_tables:
> avoid warn and OOM killer on vmalloc call") resp. d407bd25a204 ("bpf:
> don't trigger OOM killer under pressure with map alloc").
> 
> The current allocation pattern strongly resembles kvmalloc helper except
> for one thing __GFP_NORETRY is not used for the vmalloc fallback. The
> main reason why kvmalloc doesn't really support __GFP_NORETRY is
> because vmalloc doesn't support this flag properly and it is far from
> straightforward to make it understand it because there are some hard
> coded GFP_KERNEL allocation deep in the call chains. This patch simply
> replaces the open coded variants with kvmalloc and puts a note to
> push on MM people to support __GFP_NORETRY in kvmalloc it this turns out
> to be really needed along with OOM report pointing at vmalloc.
> 
> If there is an immediate need and no full support yet then
> 	kvmalloc(size, gfp | __GFP_NORETRY)
> will work as good as __vmalloc(gfp | __GFP_NORETRY) - in other words it
> might trigger the OOM in some cases.
> 
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  kernel/bpf/syscall.c     | 19 +++++--------------
>  net/netfilter/x_tables.c | 16 ++++++----------
>  2 files changed, 11 insertions(+), 24 deletions(-)
> 
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 08a4d287226b..3d38c7a51e1a 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -54,21 +54,12 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
>  
>  void *bpf_map_area_alloc(size_t size)
>  {
> -	/* We definitely need __GFP_NORETRY, so OOM killer doesn't
> -	 * trigger under memory pressure as we really just want to
> -	 * fail instead.
> +	/*
> +	 * FIXME: we would really like to not trigger the OOM killer and rather
> +	 * fail instead. This is not supported right now. Please nag MM people
> +	 * if these OOM start bothering people.
>  	 */
> -	const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
> -	void *area;
> -
> -	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> -		area = kmalloc(size, GFP_USER | flags);
> -		if (area != NULL)
> -			return area;
> -	}
> -
> -	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
> -			 PAGE_KERNEL);
> +	return kvzalloc(size, GFP_USER);
>  }
>  
>  void bpf_map_area_free(void *area)
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index d529989f5791..ba8ba633da72 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -995,16 +995,12 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
>  		return NULL;
>  
> -	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> -		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> -	if (!info) {
> -		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
> -				     __GFP_NORETRY | __GFP_HIGHMEM,
> -				 PAGE_KERNEL);
> -		if (!info)
> -			return NULL;
> -	}
> -	memset(info, 0, sizeof(*info));
> +	/*
> +	 * FIXME: we would really like to not trigger the OOM killer and rather
> +	 * fail instead. This is not supported right now. Please nag MM people
> +	 * if these OOM start bothering people.
> +	 */
> +	info = kvzalloc(sz, GFP_KERNEL);
>  	info->size = size;
>  	return info;
>  }
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
