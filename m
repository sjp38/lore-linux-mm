Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 22E576B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 07:12:48 -0400 (EDT)
Received: by wizk4 with SMTP id k4so197641298wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 04:12:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd7si9918594wjb.51.2015.05.06.04.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 04:12:46 -0700 (PDT)
Date: Wed, 6 May 2015 13:12:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: only define hashdist variable when needed
Message-ID: <20150506111245.GG14550@dhcp22.suse.cz>
References: <1430753249-30850-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430753249-30850-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 04-05-15 17:27:29, Rasmus Villemoes wrote:
> For !CONFIG_NUMA, hashdist will always be 0, since it's setter is
> otherwise compiled out. So we can save 4 bytes of data and some .text
> (although mostly in __init functions) by only defining it for
> CONFIG_NUMA.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/bootmem.h | 8 ++++----
>  mm/page_alloc.c         | 2 +-
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index 0995c2de8162..f589222bfa87 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -357,12 +357,12 @@ extern void *alloc_large_system_hash(const char *tablename,
>  /* Only NUMA needs hash distribution. 64bit NUMA architectures have
>   * sufficient vmalloc space.
>   */
> -#if defined(CONFIG_NUMA) && defined(CONFIG_64BIT)
> -#define HASHDIST_DEFAULT 1
> +#ifdef CONFIG_NUMA
> +#define HASHDIST_DEFAULT IS_ENABLED(CONFIG_64BIT)
> +extern int hashdist;		/* Distribute hashes across NUMA nodes? */
>  #else
> -#define HASHDIST_DEFAULT 0
> +#define hashdist (0)
>  #endif
> -extern int hashdist;		/* Distribute hashes across NUMA nodes? */
>  
>  
>  #endif /* _LINUX_BOOTMEM_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e4a9c0..159dbbc3375d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6013,9 +6013,9 @@ out:
>  	return ret;
>  }
>  
> +#ifdef CONFIG_NUMA
>  int hashdist = HASHDIST_DEFAULT;
>  
> -#ifdef CONFIG_NUMA
>  static int __init set_hashdist(char *str)
>  {
>  	if (!str)
> -- 
> 2.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
