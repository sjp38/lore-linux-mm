Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 632B66B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 09:41:17 -0500 (EST)
Date: Tue, 20 Dec 2011 15:41:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] page_cgroup: drop multi CONFIG_MEMORY_HOTPLUG
Message-ID: <20111220144114.GM10565@tiehlicka.suse.cz>
References: <1324375421-31358-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324375421-31358-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Tue 20-12-11 18:03:41, Bob Liu wrote:
> No need two CONFIG_MEMORY_HOTPLUG place.

I originally wanted to have alloc and dealloc at one location but this
makes sense as well.

> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/page_cgroup.c |   30 ++++++++++++++----------------
>  1 files changed, 14 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index b99d19e..de1616a 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -124,22 +124,6 @@ static void *__meminit alloc_page_cgroup(size_t size, int nid)
>  	return addr;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTPLUG
> -static void free_page_cgroup(void *addr)
> -{
> -	if (is_vmalloc_addr(addr)) {
> -		vfree(addr);
> -	} else {
> -		struct page *page = virt_to_page(addr);
> -		size_t table_size =
> -			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -
> -		BUG_ON(PageReserved(page));
> -		free_pages_exact(addr, table_size);
> -	}
> -}
> -#endif
> -
>  static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
>  {
>  	struct mem_section *section;
> @@ -176,6 +160,20 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
>  	return 0;
>  }
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +static void free_page_cgroup(void *addr)
> +{
> +	if (is_vmalloc_addr(addr)) {
> +		vfree(addr);
> +	} else {
> +		struct page *page = virt_to_page(addr);
> +		size_t table_size =
> +			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> +
> +		BUG_ON(PageReserved(page));
> +		free_pages_exact(addr, table_size);
> +	}
> +}
> +
>  void __free_page_cgroup(unsigned long pfn)
>  {
>  	struct mem_section *ms;
> -- 
> 1.7.0.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
