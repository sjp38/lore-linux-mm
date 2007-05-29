Date: Tue, 29 May 2007 17:23:35 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC/PATCH 2/2] shmem: use lib/parser for mount options
In-Reply-To: <20070524000044.b62a0792.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0705291657230.21029@blonde.wat.veritas.com>
References: <20070524000044.b62a0792.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Randy Dunlap wrote:

> 
> Build-tested only.  I will run-test it, but I want to ask first:
> Is there any trick to mounting/testing shmem/tmpfs?

Sorry, no, I've no tricks or shortcuts for that.

Thanks for trying this: it's never seemed worth the effort to me,
but I know Andrew's in favour - here's our exchange from last year.

+  >  > [ Vaguely suprised that tmpfs isn't using match_token()... ]
+  > 
+  >  I did briefly consider that back in the days when I noticed a host of
+  >  fs filesystems got converted.  But didn't see any point in messing
+  >  with what was already working.  Haven't looked recently: would it
+  >  actually be a useful change to make?
+  
+  I guess it'd be nice to do for uniformity's sake, but it's hardly pressing.
+  I have a vague memory that the ext3 conversion actually increased .text
+  size, which was a bit irritating.

Well, your changes do save something like 150 bytes, so that's good.

Though you end up using both match_token and memparse (I'm not surprised,
I thought it likely that tmpfs mount option quirks might require that),
so it's not entirely satisfying.  But if your testing works out, yes,
let's do it.

Your addition of an "is_remount" arg looks redundant to me: isn't it?
By all means add your "not valid on remount" comment to the !mode,
!uid, !gid lines (though "ignored on remount" would be clearer),
but I don't see the point of the "is_remount" addition.

hugetlbfs would be another candidate for conversion if you wish.

Thanks,
Hugh

> 
> Thanks.
> ---
> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Convert shmem (tmpfs) to use the in-kernel mount options parsing library.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  mm/shmem.c |  150 +++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 88 insertions(+), 62 deletions(-)
> 
> --- linux-2622-rc2.orig/mm/shmem.c
> +++ linux-2622-rc2/mm/shmem.c
> @@ -32,6 +32,7 @@
>  #include <linux/mman.h>
>  #include <linux/file.h>
>  #include <linux/swap.h>
> +#include <linux/parser.h>
>  #include <linux/pagemap.h>
>  #include <linux/string.h>
>  #include <linux/slab.h>
> @@ -84,6 +85,23 @@ enum sgp_type {
>  	SGP_WRITE,	/* may exceed i_size, may allocate page */
>  };
>  
> +enum {
> +	Opt_size, Opt_nr_blocks, Opt_nr_inodes,
> +	Opt_mode, Opt_uid, Opt_gid,
> +	Opt_mpol, Opt_err,
> +};
> +
> +static match_table_t tokens = {
> +	{Opt_size,	"size=%u"},
> +	{Opt_nr_blocks,	"nr_blocks=%u"},
> +	{Opt_nr_inodes,	"nr_inodes=%u"},
> +	{Opt_mode,	"mode=%u"},	/* not for remount */
> +	{Opt_uid,	"uid=%u"},	/* not for remount */
> +	{Opt_gid,	"gid=%u"},	/* not for remount */
> +	{Opt_mpol,	"mpol=%s"},	/* various NUMA memory policy options */
> +	{Opt_err,	NULL},
> +};
> +
>  static int shmem_getpage(struct inode *inode, unsigned long idx,
>  			 struct page **pagep, enum sgp_type sgp, int *type);
>  
> @@ -2113,92 +2131,100 @@ static struct export_operations shmem_ex
>  
>  static int shmem_parse_options(char *options, int *mode, uid_t *uid,
>  	gid_t *gid, unsigned long *blocks, unsigned long *inodes,
> -	int *policy, nodemask_t *policy_nodes)
> +	int *policy, nodemask_t *policy_nodes, int is_remount)
>  {
> -	char *this_char, *value, *rest;
> +	char *rest;
> +	substring_t args[MAX_OPT_ARGS];
> +	char *p;
> +	int option;
>  
> -	while (options != NULL) {
> -		this_char = options;
> -		for (;;) {
> -			/*
> -			 * NUL-terminate this option: unfortunately,
> -			 * mount options form a comma-separated list,
> -			 * but mpol's nodelist may also contain commas.
> -			 */
> -			options = strchr(options, ',');
> -			if (options == NULL)
> -				break;
> -			options++;
> -			if (!isdigit(*options)) {
> -				options[-1] = '\0';
> -				break;
> -			}
> -		}
> -		if (!*this_char)
> -			continue;
> -		if ((value = strchr(this_char,'=')) != NULL) {
> -			*value++ = 0;
> -		} else {
> -			printk(KERN_ERR
> -			    "tmpfs: No value for mount option '%s'\n",
> -			    this_char);
> -			return 1;
> -		}
> +	if (!options)
> +		return 0;
>  
> -		if (!strcmp(this_char,"size")) {
> +	while ((p = strsep(&options, ",")) != NULL) {
> +		int token;
> +
> +		if (!*p)
> +			continue;
> +		token = match_token(p, tokens, args);
> +		switch (token) {
> +		case Opt_size: {
>  			unsigned long long size;
> -			size = memparse(value,&rest);
> +			size = memparse(args[0].from, &rest);
>  			if (*rest == '%') {
>  				size <<= PAGE_SHIFT;
>  				size *= totalram_pages;
>  				do_div(size, 100);
>  				rest++;
>  			}
> -			if (*rest)
> -				goto bad_val;
>  			*blocks = size >> PAGE_CACHE_SHIFT;
> -		} else if (!strcmp(this_char,"nr_blocks")) {
> -			*blocks = memparse(value,&rest);
> -			if (*rest)
> -				goto bad_val;
> -		} else if (!strcmp(this_char,"nr_inodes")) {
> -			*inodes = memparse(value,&rest);
> -			if (*rest)
> -				goto bad_val;
> -		} else if (!strcmp(this_char,"mode")) {
> +			break;
> +		}
> +		case Opt_nr_blocks:
> +			*blocks = memparse(args[0].from, &rest);
> +			break;
> +		case Opt_nr_inodes:
> +			*inodes = memparse(args[0].from, &rest);
> +			break;
> +		case Opt_mode:
> +			if (is_remount)		/* not valid on remount */
> +				break;
>  			if (!mode)
> -				continue;
> -			*mode = simple_strtoul(value,&rest,8);
> -			if (*rest)
> +				break;
> +			if (match_int(&args[0], &option))
>  				goto bad_val;
> -		} else if (!strcmp(this_char,"uid")) {
> +			*mode = option;
> +			break;
> +		case Opt_uid:
> +			if (is_remount)		/* not valid on remount */
> +				break;
>  			if (!uid)
> -				continue;
> -			*uid = simple_strtoul(value,&rest,0);
> -			if (*rest)
> +				break;
> +			if (match_int(&args[0], &option))
>  				goto bad_val;
> -		} else if (!strcmp(this_char,"gid")) {
> +			*uid = option;
> +			break;
> +		case Opt_gid:
> +			if (is_remount)		/* not valid on remount */
> +				break;
>  			if (!gid)
> -				continue;
> -			*gid = simple_strtoul(value,&rest,0);
> -			if (*rest)
> +				break;
> +			if (match_int(&args[0], &option))
>  				goto bad_val;
> -		} else if (!strcmp(this_char,"mpol")) {
> -			if (shmem_parse_mpol(value,policy,policy_nodes))
> +			*gid = option;
> +			break;
> +		case Opt_mpol:
> +			if (shmem_parse_mpol(args[0].from, policy, policy_nodes))
>  				goto bad_val;
> -		} else {
> -			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
> -			       this_char);
> +			break;
> +		default:
> +			printk(KERN_ERR "tmpfs: Bad mount option %s\n", p);
>  			return 1;
> +			break;
> +		}
> +
> +		for (;;) {
> +			/*
> +			 * NUL-terminate this option: unfortunately,
> +			 * mount options form a comma-separated list,
> +			 * but mpol's nodelist may also contain commas.
> +			 */
> +			options = strchr(options, ',');
> +			if (options == NULL)
> +				break;
> +			options++;
> +			if (!isdigit(*options)) {
> +				options[-1] = '\0';
> +				break;
> +			}
>  		}
>  	}
>  	return 0;
>  
>  bad_val:
>  	printk(KERN_ERR "tmpfs: Bad value '%s' for mount option '%s'\n",
> -	       value, this_char);
> +	       args[0].from, p);
>  	return 1;
> -
>  }
>  
>  static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
> @@ -2213,7 +2239,7 @@ static int shmem_remount_fs(struct super
>  	int error = -EINVAL;
>  
>  	if (shmem_parse_options(data, NULL, NULL, NULL, &max_blocks,
> -				&max_inodes, &policy, &policy_nodes))
> +				&max_inodes, &policy, &policy_nodes, 1))
>  		return error;
>  
>  	spin_lock(&sbinfo->stat_lock);
> @@ -2280,7 +2306,7 @@ static int shmem_fill_super(struct super
>  		if (inodes > blocks)
>  			inodes = blocks;
>  		if (shmem_parse_options(data, &mode, &uid, &gid, &blocks,
> -					&inodes, &policy, &policy_nodes))
> +					&inodes, &policy, &policy_nodes, 0))
>  			return -EINVAL;
>  	}
>  	sb->s_export_op = &shmem_export_ops;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
