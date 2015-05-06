Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DBFB36B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 19:30:18 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so22729024pab.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 16:30:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id je6si331784pbd.73.2015.05.06.16.30.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 16:30:17 -0700 (PDT)
Date: Wed, 6 May 2015 16:30:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm/memblock: Allocate boot time data structures
 from mirrored memory
Message-Id: <20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
In-Reply-To: <ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
	<ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 3 Feb 2015 14:38:02 -0800 Tony Luck <tony.luck@intel.com> wrote:

> Try to allocate all boot time kernel data structures from mirrored
> memory. If we run out of mirrored memory print warnings, but fall
> back to using non-mirrored memory to make sure that we still boot.
> 
> ...
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 1d448879caae..20bf3dfab564 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -22,6 +22,7 @@
>  
>  /* Definition of memblock flags. */
>  #define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
> +#define MEMBLOCK_MIRROR		0x2	/* mirrored region */

It would be nice to make these an enum.  Then all those literal "0"'s
which were added in [1/3] become MEMBLOCK_NONE, which is
self-documenting.

>
> ...
>
> +static inline bool memblock_is_mirror(struct memblock_region *m)
> +{
> +	return m->flags & MEMBLOCK_MIRROR;
> +}
> +
>
> ...
>
> +u32 __init_memblock memblock_has_mirror(void)
> +{
> +	return memblock_have_mirror ? MEMBLOCK_MIRROR : 0;
> +}

hm, these are very similar.  But I guess they're different enough.

Gramatically, a function called "memblock_has_mirror()" should return a
bool.  This guy is misnamed.  "memblock_mirror_flag()"?


>  /* inline so we don't get a warning when pr_debug is compiled out */
>  static __init_memblock const char *
>  memblock_type_name(struct memblock_type *type)
> @@ -257,8 +263,19 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
>  					phys_addr_t end, phys_addr_t size,
>  					phys_addr_t align)
>  {
> -	return memblock_find_in_range_node(size, align, start, end,
> +	phys_addr_t ret;
> +	u32 flag = memblock_has_mirror();
> +
> +	ret = memblock_find_in_range_node(size, align, start, end,
> +					    NUMA_NO_NODE, flag);
> +
> +	if (!ret && flag) {
> +		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);

This printk will warn on some configs.  Print a phys_addr_t with %pap. 
I think.  See huge comment over lib/vsprintf.c:pointer().  There are
other instances of this.

> +		ret = memblock_find_in_range_node(size, align, start, end,
>  					    NUMA_NO_NODE, 0);
> +	}
> +
> +	return ret;
>  }
>
> ...
>
>  phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
>  {
> -	return memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE, nid, 0);
> +	u32 flag = memblock_has_mirror();
> +	phys_addr_t ret;
> +
> +again:
> +	ret = memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE, nid, flag);
> +
> +	if (!ret && flag) {
> +		flag = 0;
> +		goto again;
> +	}

What's going on here?  This is where we're falling back to
non-mirrored.  But it's happening silently?  Should it warn, or is that
handled elsewhere?

This function isn't specific to mirrored memory - for any future flags,
falling back to flags==0 may not be the desired behavior.  What do we
do then?  I guess

	if (!ret && (flag & MEMBLOCK_MIRROR)) (
		flag &= ~MEMBLOCK_MIRROR;
		goto again;

yes?

That can be done later if needed, I suppose.

> +	return ret;
>  }
>  
>
> ...
>
> @@ -1181,13 +1232,13 @@ static void * __init memblock_virt_alloc_internal(
>  
>  again:
>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
> -					    nid, 0);
> +					    nid, flag);
>  	if (alloc)
>  		goto done;
>  
>  	if (nid != NUMA_NO_NODE) {
>  		alloc = memblock_find_in_range_node(size, align, min_addr,
> -						    max_addr,  NUMA_NO_NODE, 0);
> +						    max_addr,  NUMA_NO_NODE, flag);
>  		if (alloc)
>  			goto done;
>  	}
> @@ -1195,10 +1246,15 @@ again:
>  	if (min_addr) {
>  		min_addr = 0;
>  		goto again;
> -	} else {
> -		goto error;
>  	}
>  
> +	if (flag) {
> +		flag = 0;
> +		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);

printk warning.

Please don't torture people who use 80-col displays!

> +		goto again;
> +	}
> +
> +	return NULL;
>
> ...
>
> @@ -37,11 +37,19 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
>  {
>  	void *ptr;
>  	u64 addr;
> +	u32 flag = memblock_has_mirror();
>  
>  	if (limit > memblock.current_limit)
>  		limit = memblock.current_limit;
>  
> -	addr = memblock_find_in_range_node(size, align, goal, limit, nid, 0);
> +again:
> +	addr = memblock_find_in_range_node(size, align, goal, limit, nid, flag);
> +
> +	if (flag && !addr) {
> +		flag = 0;
> +		pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);

dittoes.

> +		goto again;
> +	}
>  	if (!addr)
>  		return NULL;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
