Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 31BDE6B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 14:32:27 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <20121102182945.GC30100@konrad-lan.dumpdata.com>
Date: Fri, 2 Nov 2012 11:29:45 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/5] mm: cleancache: lazy initialization to allow tmem
 backends to build/run as modules
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
 <1351696074-29362-2-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1351696074-29362-2-git-send-email-dan.magenheimer@oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, minchan@kernel.org, fschmaus@gmail.com, andor.damm@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

On Wed, Oct 31, 2012 at 08:07:50AM -0700, Dan Magenheimer wrote:
> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> built/loaded as modules rather than built-in and enabled by a boot parameter,
> this patch provides "lazy initialization", allowing backends to register to
> cleancache even after filesystems were mounted. Calls to init_fs and
> init_shared_fs are remembered as fake poolids but no real tmem_pools created.
> On backend registration the fake poolids are mapped to real poolids and
> respective tmem_pools.
> 
> Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
> Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
> Signed-off-by: Andor Daam <andor.daam@googlemail.com>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> ---
>  include/linux/cleancache.h |    1 +
>  mm/cleancache.c            |  157 +++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 141 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
> index 42e55de..f7e32f0 100644
> --- a/include/linux/cleancache.h
> +++ b/include/linux/cleancache.h
> @@ -37,6 +37,7 @@ extern struct cleancache_ops
>  	cleancache_register_ops(struct cleancache_ops *ops);
>  extern void __cleancache_init_fs(struct super_block *);
>  extern void __cleancache_init_shared_fs(char *, struct super_block *);
> +#define CLEANCACHE_HAS_LAZY_INIT
>  extern int  __cleancache_get_page(struct page *);
>  extern void __cleancache_put_page(struct page *);
>  extern void __cleancache_invalidate_page(struct address_space *, struct page *);
> diff --git a/mm/cleancache.c b/mm/cleancache.c
> index 32e6f41..29430b7 100644
> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -45,15 +45,42 @@ static u64 cleancache_puts;
>  static u64 cleancache_invalidates;
>  
>  /*
> + * When no backend is registered all calls to init_fs and init_shard_fs
> + * are registered and fake poolids are given to the respective
> + * super block but no tmem_pools are created. When a backend
> + * registers with cleancache the previous calls to init_fs and
> + * init_shared_fs are executed to create tmem_pools and set the
> + * respective poolids. While no backend is registered all "puts",
> + * "gets" and "flushes" are ignored or fail.
> + */
> +#define MAX_INITIALIZABLE_FS 32
> +#define FAKE_FS_POOLID_OFFSET 1000
> +#define FAKE_SHARED_FS_POOLID_OFFSET 2000
> +static int fs_poolid_map[MAX_INITIALIZABLE_FS];
> +static int shared_fs_poolid_map[MAX_INITIALIZABLE_FS];
> +static char *uuids[MAX_INITIALIZABLE_FS];
> +static int backend_registered;

Those could use some #define's and bool, so please see attached
patch which does this.
