Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4D39000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:04:43 -0400 (EDT)
Date: Wed, 21 Sep 2011 11:04:20 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->invalidate
Message-ID: <20110921150420.GC541@phenom.oracle.com>
References: <20110915213506.GA26426@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110915213506.GA26426@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, Sep 15, 2011 at 02:35:06PM -0700, Dan Magenheimer wrote:
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->invalidate

Just call it 's/flush/invalidate/' change.
> 
> This sixth patch of six in this frontswap series completes the renaming
> from "flush" to "invalidate" across both tmem frontends (cleancache and
> frontswap) and both tmem backends (Xen and zcache), as required by akpm.
> This change is completely cosmetic.
> 
> [v10: no change]

No need for that.. You only need to include them if you did provide some
new content to the patch.

> [v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 3]
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Jan Beulich <JBeulich@novell.com>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Chris Mason <chris.mason@oracle.com>
> Cc: Rik Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> ---
> 
> Diffstat:
>  drivers/staging/zcache/zcache-main.c     |   10 +++++-----
>  drivers/xen/tmem.c                       |   10 +++++-----
>  include/linux/cleancache.h               |   11 +++--------
>  include/linux/frontswap.h                |    9 ++-------
>  mm/cleancache.c                          |    7 ++++---
>  mm/frontswap.c                           |    4 ++--
>  6 files changed, 21 insertions(+), 30 deletions(-)
> 
> diff -Napur -x .git frontswap-v10-no_flush_change/drivers/staging/zcache/zcache-main.c frontswap-v10-with_flush_change/drivers/staging/zcache/zcache-main.c
> --- frontswap-v10-no_flush_change/drivers/staging/zcache/zcache-main.c	2011-09-15 11:50:06.237805199 -0600
> +++ frontswap-v10-with_flush_change/drivers/staging/zcache/zcache-main.c	2011-09-15 12:14:11.739746973 -0600
> @@ -1775,9 +1775,9 @@ static int zcache_cleancache_init_shared
>  static struct cleancache_ops zcache_cleancache_ops = {
>  	.put_page = zcache_cleancache_put_page,
>  	.get_page = zcache_cleancache_get_page,
> -	.flush_page = zcache_cleancache_flush_page,
> -	.flush_inode = zcache_cleancache_flush_inode,
> -	.flush_fs = zcache_cleancache_flush_fs,
> +	.invalidate_page = zcache_cleancache_flush_page,
> +	.invalidate_inode = zcache_cleancache_flush_inode,
> +	.invalidate_fs = zcache_cleancache_flush_fs,
>  	.init_shared_fs = zcache_cleancache_init_shared_fs,
>  	.init_fs = zcache_cleancache_init_fs
>  };
> @@ -1883,8 +1883,8 @@ static void zcache_frontswap_init(unsign
>  static struct frontswap_ops zcache_frontswap_ops = {
>  	.put_page = zcache_frontswap_put_page,
>  	.get_page = zcache_frontswap_get_page,
> -	.flush_page = zcache_frontswap_flush_page,
> -	.flush_area = zcache_frontswap_flush_area,
> +	.invalidate_page = zcache_frontswap_flush_page,
> +	.invalidate_area = zcache_frontswap_flush_area,
>  	.init = zcache_frontswap_init
>  };
>  
> diff -Napur -x .git frontswap-v10-no_flush_change/drivers/xen/tmem.c frontswap-v10-with_flush_change/drivers/xen/tmem.c
> --- frontswap-v10-no_flush_change/drivers/xen/tmem.c	2011-09-15 11:50:07.742683966 -0600
> +++ frontswap-v10-with_flush_change/drivers/xen/tmem.c	2011-09-15 12:14:11.751802513 -0600
> @@ -242,9 +242,9 @@ __setup("nocleancache", no_cleancache);
>  static struct cleancache_ops tmem_cleancache_ops = {
>  	.put_page = tmem_cleancache_put_page,
>  	.get_page = tmem_cleancache_get_page,
> -	.flush_page = tmem_cleancache_flush_page,
> -	.flush_inode = tmem_cleancache_flush_inode,
> -	.flush_fs = tmem_cleancache_flush_fs,
> +	.invalidate_page = tmem_cleancache_flush_page,
> +	.invalidate_inode = tmem_cleancache_flush_inode,
> +	.invalidate_fs = tmem_cleancache_flush_fs,
>  	.init_shared_fs = tmem_cleancache_init_shared_fs,
>  	.init_fs = tmem_cleancache_init_fs
>  };
> @@ -369,8 +369,8 @@ __setup("nofrontswap", no_frontswap);
>  static struct frontswap_ops tmem_frontswap_ops = {
>  	.put_page = tmem_frontswap_put_page,
>  	.get_page = tmem_frontswap_get_page,
> -	.flush_page = tmem_frontswap_flush_page,
> -	.flush_area = tmem_frontswap_flush_area,
> +	.invalidate_page = tmem_frontswap_flush_page,
> +	.invalidate_area = tmem_frontswap_flush_area,
>  	.init = tmem_frontswap_init
>  };
>  #endif
> diff -Napur -x .git frontswap-v10-no_flush_change/include/linux/cleancache.h frontswap-v10-with_flush_change/include/linux/cleancache.h
> --- frontswap-v10-no_flush_change/include/linux/cleancache.h	2011-09-15 12:03:06.126744226 -0600
> +++ frontswap-v10-with_flush_change/include/linux/cleancache.h	2011-09-15 12:14:11.752742905 -0600
> @@ -28,14 +28,9 @@ struct cleancache_ops {
>  			pgoff_t, struct page *);
>  	void (*put_page)(int, struct cleancache_filekey,
>  			pgoff_t, struct page *);
> -	/*
> -	 * NOTE: per akpm, flush_page, flush_inode and flush_fs will be
> -	 * renamed to invalidate_* in a later commit in which all
> -	 * dependencies (i.e Xen, zcache) will be renamed simultaneously
> -	 */
> -	void (*flush_page)(int, struct cleancache_filekey, pgoff_t);
> -	void (*flush_inode)(int, struct cleancache_filekey);
> -	void (*flush_fs)(int);
> +	void (*invalidate_page)(int, struct cleancache_filekey, pgoff_t);
> +	void (*invalidate_inode)(int, struct cleancache_filekey);
> +	void (*invalidate_fs)(int);
>  };
>  
>  extern struct cleancache_ops
> diff -Napur -x .git frontswap-v10-no_flush_change/include/linux/frontswap.h frontswap-v10-with_flush_change/include/linux/frontswap.h
> --- frontswap-v10-no_flush_change/include/linux/frontswap.h	2011-09-15 12:03:06.127744888 -0600
> +++ frontswap-v10-with_flush_change/include/linux/frontswap.h	2011-09-15 12:14:11.753714019 -0600
> @@ -9,13 +9,8 @@ struct frontswap_ops {
>  	void (*init)(unsigned);
>  	int (*put_page)(unsigned, pgoff_t, struct page *);
>  	int (*get_page)(unsigned, pgoff_t, struct page *);
> -	/*
> -	 * NOTE: per akpm, flush_page and flush_area will be renamed to
> -	 * invalidate_page and invalidate_area in a later commit in which
> -	 * all dependencies (i.e. Xen, zcache) will be renamed simultaneously
> -	 */
> -	void (*flush_page)(unsigned, pgoff_t);
> -	void (*flush_area)(unsigned);
> +	void (*invalidate_page)(unsigned, pgoff_t);
> +	void (*invalidate_area)(unsigned);
>  };
>  
>  extern int frontswap_enabled;
> diff -Napur -x .git frontswap-v10-no_flush_change/mm/cleancache.c frontswap-v10-with_flush_change/mm/cleancache.c
> --- frontswap-v10-no_flush_change/mm/cleancache.c	2011-09-15 12:03:48.030836482 -0600
> +++ frontswap-v10-with_flush_change/mm/cleancache.c	2011-09-15 12:14:11.754662260 -0600
> @@ -166,7 +166,8 @@ void __cleancache_invalidate_page(struct
>  	if (pool_id >= 0) {
>  		VM_BUG_ON(!PageLocked(page));
>  		if (cleancache_get_key(mapping->host, &key) >= 0) {
> -			(*cleancache_ops.flush_page)(pool_id, key, page->index);
> +			(*cleancache_ops.invalidate_page)(pool_id,
> +							  key, page->index);
>  			cleancache_invalidates++;
>  		}
>  	}
> @@ -184,7 +185,7 @@ void __cleancache_invalidate_inode(struc
>  	struct cleancache_filekey key = { .u.key = { 0 } };
>  
>  	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
> -		(*cleancache_ops.flush_inode)(pool_id, key);
> +		(*cleancache_ops.invalidate_inode)(pool_id, key);
>  }
>  EXPORT_SYMBOL(__cleancache_invalidate_inode);
>  
> @@ -198,7 +199,7 @@ void __cleancache_invalidate_fs(struct s
>  	if (sb->cleancache_poolid >= 0) {
>  		int old_poolid = sb->cleancache_poolid;
>  		sb->cleancache_poolid = -1;
> -		(*cleancache_ops.flush_fs)(old_poolid);
> +		(*cleancache_ops.invalidate_fs)(old_poolid);
>  	}
>  }
>  EXPORT_SYMBOL(__cleancache_invalidate_fs);
> diff -Napur -x .git frontswap-v10-no_flush_change/mm/frontswap.c frontswap-v10-with_flush_change/mm/frontswap.c
> --- frontswap-v10-no_flush_change/mm/frontswap.c	2011-09-15 12:04:02.956697561 -0600
> +++ frontswap-v10-with_flush_change/mm/frontswap.c	2011-09-15 12:14:11.754662260 -0600
> @@ -147,7 +147,7 @@ void __frontswap_invalidate_page(unsigne
>  
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset)) {
> -		(*frontswap_ops.flush_page)(type, offset);
> +		(*frontswap_ops.invalidate_page)(type, offset);
>  		atomic_dec(&sis->frontswap_pages);
>  		frontswap_clear(sis, offset);
>  		frontswap_invalidates++;
> @@ -166,7 +166,7 @@ void __frontswap_invalidate_area(unsigne
>  	BUG_ON(sis == NULL);
>  	if (sis->frontswap_map == NULL)
>  		return;
> -	(*frontswap_ops.flush_area)(type);
> +	(*frontswap_ops.invalidate_area)(type);
>  	atomic_set(&sis->frontswap_pages, 0);
>  	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
