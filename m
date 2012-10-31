Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 22F8E6B0078
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 13:17:04 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 31 Oct 2012 11:17:03 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id F14A619D804A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:16:57 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9VHDq8f064120
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:16:57 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9VH8NUD008916
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:08:24 -0600
Message-ID: <50915A5C.8000303@linux.vnet.ibm.com>
Date: Wed, 31 Oct 2012 12:05:32 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com> <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, minchan@kernel.org, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

On 10/31/2012 10:07 AM, Dan Magenheimer wrote:
> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> built/loaded as modules rather than built-in and enabled by a boot parameter,
> this patch provides "lazy initialization", allowing backends to register to
> frontswap even after swapon was run. Before a backend registers all calls
> to init are recorded and the creation of tmem_pools delayed until a backend
> registers or until a frontswap put is attempted.
> 
> Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
> Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
> Signed-off-by: Andor Daam <andor.daam@googlemail.com>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> ---
>  include/linux/frontswap.h |    1 +
>  mm/frontswap.c            |   70 +++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 63 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
> index 3044254..ef6ada6 100644
> --- a/include/linux/frontswap.h
> +++ b/include/linux/frontswap.h
> @@ -23,6 +23,7 @@ extern void frontswap_writethrough(bool);
>  extern void frontswap_tmem_exclusive_gets(bool);
> 
>  extern void __frontswap_init(unsigned type);
> +#define FRONTSWAP_HAS_LAZY_INIT
>  extern int __frontswap_store(struct page *page);
>  extern int __frontswap_load(struct page *page);
>  extern void __frontswap_invalidate_page(unsigned, pgoff_t);
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 2890e67..523a19b 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -80,6 +80,19 @@ static inline void inc_frontswap_succ_stores(void) { }
>  static inline void inc_frontswap_failed_stores(void) { }
>  static inline void inc_frontswap_invalidates(void) { }
>  #endif
> +
> +/*
> + * When no backend is registered all calls to init are registered and
> + * remembered but fail to create tmem_pools. When a backend registers with
> + * frontswap the previous calls to init are executed to create tmem_pools
> + * and set the respective poolids.
> + * While no backend is registered all "puts", "gets" and "flushes" are
> + * ignored or fail.
> + */
> +#define MAX_INITIALIZABLE_SD 32

MAX_INITIALIZABLE_SD should just be MAX_SWAPFILES

> +static int sds[MAX_INITIALIZABLE_SD];

Rather than store and array of enabled types indexed by type, why not
an array of booleans indexed by type.  Or a bitfield if you really
want to save space.

> +static int backend_registered;

(backend_registered) is equivalent to checking (frontswap_ops != NULL)
right?

> +
>  /*
>   * Register operations for frontswap, returning previous thus allowing
>   * detection of multiple backends and possible nesting.
> @@ -87,9 +100,16 @@ static inline void inc_frontswap_invalidates(void) { }
>  struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
>  {
>  	struct frontswap_ops old = frontswap_ops;
> +	int i;
> 
>  	frontswap_ops = *ops;
>  	frontswap_enabled = true;
> +
> +	backend_registered = 1;
> +	for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
> +		if (sds[i] != -1)
> +			(*frontswap_ops.init)(sds[i]);
> +	}
>  	return old;
>  }
>  EXPORT_SYMBOL(frontswap_register_ops);
> @@ -122,7 +142,10 @@ void __frontswap_init(unsigned type)
>  	BUG_ON(sis == NULL);
>  	if (sis->frontswap_map == NULL)
>  		return;
> -	frontswap_ops.init(type);
> +	if (backend_registered) {
> +		(*frontswap_ops.init)(type);
> +		sds[type] = type;

This is weird, storing the type in an array indexed by type.  Hence my
suggestion above about an array of booleans or a bitfield.

> +	}
>  }
>  EXPORT_SYMBOL(__frontswap_init);
> 
> @@ -147,10 +170,20 @@ int __frontswap_store(struct page *page)
>  	struct swap_info_struct *sis = swap_info[type];
>  	pgoff_t offset = swp_offset(entry);
> 
> +	if (!backend_registered) {
> +		inc_frontswap_failed_stores();
> +		return ret;
> +	}
> +
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset))
>  		dup = 1;
> +	if (type < MAX_INITIALIZABLE_SD && sds[type] == -1) {
> +		/* lazy init call to handle post-boot insmod backends*/
> +		(*frontswap_ops.init)(type);
> +		sds[type] = type;
> +	}
>  	ret = frontswap_ops.store(type, offset, page);
>  	if (ret == 0) {
>  		frontswap_set(sis, offset);
> @@ -186,6 +219,9 @@ int __frontswap_load(struct page *page)
>  	struct swap_info_struct *sis = swap_info[type];
>  	pgoff_t offset = swp_offset(entry);
> 
> +	if (!backend_registered)
> +		return ret;
> +
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset))
> @@ -209,6 +245,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
>  {
>  	struct swap_info_struct *sis = swap_info[type];
> 
> +	if (!backend_registered)
> +		return;
> +
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset)) {
>  		frontswap_ops.invalidate_page(type, offset);
> @@ -225,13 +264,23 @@ EXPORT_SYMBOL(__frontswap_invalidate_page);
>  void __frontswap_invalidate_area(unsigned type)
>  {
>  	struct swap_info_struct *sis = swap_info[type];
> -
> -	BUG_ON(sis == NULL);
> -	if (sis->frontswap_map == NULL)
> -		return;
> -	frontswap_ops.invalidate_area(type);
> -	atomic_set(&sis->frontswap_pages, 0);
> -	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +	int i;
> +
> +	if (backend_registered) {
> +		BUG_ON(sis == NULL);
> +		if (sis->frontswap_map == NULL)
> +			return;
> +		(*frontswap_ops.invalidate_area)(type);
> +		atomic_set(&sis->frontswap_pages, 0);
> +		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +	} else {
> +		for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
> +			if (sds[i] == type) {

Additional weirdness with sds.  It seems this whole for loop could
just be reduced to:

sds[type] = -1;

> +				sds[i] = -1;
> +				break;
> +			}
> +		}
> +	}
>  }
>  EXPORT_SYMBOL(__frontswap_invalidate_area);
> 
> @@ -353,6 +402,7 @@ EXPORT_SYMBOL(frontswap_curr_pages);
> 
>  static int __init init_frontswap(void)
>  {
> +	int i;
>  #ifdef CONFIG_DEBUG_FS
>  	struct dentry *root = debugfs_create_dir("frontswap", NULL);
>  	if (root == NULL)
> @@ -364,6 +414,10 @@ static int __init init_frontswap(void)
>  	debugfs_create_u64("invalidates", S_IRUGO,
>  				root, &frontswap_invalidates);
>  #endif
> +	for (i = 0; i < MAX_INITIALIZABLE_SD; i++)
> +		sds[i] = -1;
> +
> +	frontswap_enabled = 1;

If frontswap_enabled is going to be on all the time, then what point
does it serve?  By extension, can all of the static inline wrappers in
frontswap.h be done away with?

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
