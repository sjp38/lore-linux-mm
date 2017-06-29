Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 747236B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:10:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c81so681288wmd.10
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:10:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si427468wmr.54.2017.06.29.00.10.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 00:10:49 -0700 (PDT)
Date: Thu, 29 Jun 2017 09:10:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: convert three more cases to kvmalloc
Message-ID: <20170629071046.GA31603@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706282317480.11892@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1706282317480.11892@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 28-06-17 23:24:10, Mikulas Patocka wrote:
[...]
> From: Mikulas Patocka <mpatocka@redhat.com>
> 
> The patch a7c3e901 ("mm: introduce kv[mz]alloc helpers") converted a lot 
> of kernel code to kvmalloc. This patch converts three more forgotten 
> cases.

Thanks! I have two remarks below but other than that feel free to add

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>
[...]
> Index: linux-2.6/kernel/bpf/syscall.c
> ===================================================================
> --- linux-2.6.orig/kernel/bpf/syscall.c
> +++ linux-2.6/kernel/bpf/syscall.c
> @@ -58,16 +58,7 @@ void *bpf_map_area_alloc(size_t size)
>  	 * trigger under memory pressure as we really just want to
>  	 * fail instead.
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
> -	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
> +	return kvmalloc(size, GFP_USER | __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO);

kvzalloc without additional flags would be more appropriate.
__GFP_NORETRY is explicitly documented as non-supported and NOWARN
wouldn't be applied everywhere in the vmalloc path.

>  }
>  
>  void bpf_map_area_free(void *area)
> Index: linux-2.6/kernel/cgroup/cgroup-v1.c
> ===================================================================
> --- linux-2.6.orig/kernel/cgroup/cgroup-v1.c
> +++ linux-2.6/kernel/cgroup/cgroup-v1.c
> @@ -184,15 +184,10 @@ struct cgroup_pidlist {
>  /*
>   * The following two functions "fix" the issue where there are more pids
>   * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
> - * TODO: replace with a kernel-wide solution to this problem
>   */
> -#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))
>  static void *pidlist_allocate(int count)
>  {
> -	if (PIDLIST_TOO_LARGE(count))
> -		return vmalloc(count * sizeof(pid_t));
> -	else
> -		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
> +	return kvmalloc(count * sizeof(pid_t), GFP_KERNEL);
>  }

I would rather use kvmalloc_array to have an overflow protection as
well.

>  
>  static void pidlist_free(void *p)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
