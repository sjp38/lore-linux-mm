Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 51E7F6B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:03:26 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4BK3Of0028739
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:24 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq7.eem.corp.google.com with ESMTP id p4BK3Ixm013578
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:22 -0700
Received: by pwi5 with SMTP id 5so540920pwi.31
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:22 -0700 (PDT)
Date: Wed, 11 May 2011 13:03:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 2/5] slub: get_map() function to establish map
 of free objects in a slab
In-Reply-To: <20110415194830.839125394@linux.com>
Message-ID: <alpine.DEB.2.00.1105111302020.9346@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194830.839125394@linux.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-2111188955-1305144189=:9346"
Content-ID: <alpine.DEB.2.00.1105111303190.9346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-2111188955-1305144189=:9346
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1105111303191.9346@chino.kir.corp.google.com>

On Fri, 15 Apr 2011, Christoph Lameter wrote:

> The bit map of free objects in a slab page is determined in various functions
> if debugging is enabled.
> 
> Provide a common function for that purpose.
> 

Although it makes writing to /sys/kernel/slab/cache/validate slower 
because of the double iteration in validate_slab().

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  mm/slub.c |   34 ++++++++++++++++++++++------------
>  1 file changed, 22 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-03-30 14:09:27.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-03-30 14:30:24.000000000 -0500
> @@ -271,10 +271,6 @@ static inline void set_freepointer(struc
>  	for (__p = (__addr); __p < (__addr) + (__objects) * (__s)->size;\
>  			__p += (__s)->size)
>  
> -/* Scan freelist */
> -#define for_each_free_object(__p, __s, __free) \
> -	for (__p = (__free); __p; __p = get_freepointer((__s), __p))
> -
>  /* Determine object index from a given position */
>  static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
>  {
> @@ -330,6 +326,21 @@ static inline int oo_objects(struct kmem
>  	return x.x & OO_MASK;
>  }
>  
> +/*
> + * Determine a map of object in use on a page.
> + *
> + * Slab lock or node listlock must be held to guarantee that the page does
> + * not vanish from under us.
> + */
> +static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
> +{
> +	void *p;
> +	void *addr = page_address(page);
> +
> +	for (p = page->freelist; p; p = get_freepointer(s, p))
> +		set_bit(slab_index(p, s, addr), map);
> +}
> +
>  #ifdef CONFIG_SLUB_DEBUG
>  /*
>   * Debug settings:

This generates a warning without CONFIG_SLUB_DEBUG:

mm/slub.c:335: warning: a??get_mapa?? defined but not used
--531368966-2111188955-1305144189=:9346--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
