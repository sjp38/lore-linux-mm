Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6F7E16B0152
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:42:36 -0400 (EDT)
Date: Wed, 29 May 2013 13:42:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv12 1/4] debugfs: add get/set for atomic types
Message-ID: <20130529174211.GD9443@phenom.dumpdata.com>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-2-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369067168-12291-2-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 20, 2013 at 11:26:05AM -0500, Seth Jennings wrote:
> debugfs currently lack the ability to create attributes
> that set/get atomic_t values.
> 
> This patch adds support for this through a new
> debugfs_create_atomic_t() function.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>

Let me join in the party:

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> ---
>  fs/debugfs/file.c       | 42 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/debugfs.h |  2 ++
>  lib/fault-inject.c      | 21 ---------------------
>  3 files changed, 44 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/debugfs/file.c b/fs/debugfs/file.c
> index c5ca6ae..ff64bcd 100644
> --- a/fs/debugfs/file.c
> +++ b/fs/debugfs/file.c
> @@ -21,6 +21,7 @@
>  #include <linux/debugfs.h>
>  #include <linux/io.h>
>  #include <linux/slab.h>
> +#include <linux/atomic.h>
>  
>  static ssize_t default_read_file(struct file *file, char __user *buf,
>  				 size_t count, loff_t *ppos)
> @@ -403,6 +404,47 @@ struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
>  }
>  EXPORT_SYMBOL_GPL(debugfs_create_size_t);
>  
> +static int debugfs_atomic_t_set(void *data, u64 val)
> +{
> +	atomic_set((atomic_t *)data, val);
> +	return 0;
> +}
> +static int debugfs_atomic_t_get(void *data, u64 *val)
> +{
> +	*val = atomic_read((atomic_t *)data);
> +	return 0;
> +}
> +DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t, debugfs_atomic_t_get,
> +			debugfs_atomic_t_set, "%lld\n");
> +DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t_ro, debugfs_atomic_t_get, NULL, "%lld\n");
> +DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t_wo, NULL, debugfs_atomic_t_set, "%lld\n");
> +
> +/**
> + * debugfs_create_atomic_t - create a debugfs file that is used to read and
> + * write an atomic_t value
> + * @name: a pointer to a string containing the name of the file to create.
> + * @mode: the permission that the file should have
> + * @parent: a pointer to the parent dentry for this file.  This should be a
> + *          directory dentry if set.  If this parameter is %NULL, then the
> + *          file will be created in the root of the debugfs filesystem.
> + * @value: a pointer to the variable that the file should read to and write
> + *         from.
> + */
> +struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
> +				 struct dentry *parent, atomic_t *value)
> +{
> +	/* if there are no write bits set, make read only */
> +	if (!(mode & S_IWUGO))
> +		return debugfs_create_file(name, mode, parent, value,
> +					&fops_atomic_t_ro);
> +	/* if there are no read bits set, make write only */
> +	if (!(mode & S_IRUGO))
> +		return debugfs_create_file(name, mode, parent, value,
> +					&fops_atomic_t_wo);
> +
> +	return debugfs_create_file(name, mode, parent, value, &fops_atomic_t);
> +}
> +EXPORT_SYMBOL_GPL(debugfs_create_atomic_t);
>  
>  static ssize_t read_file_bool(struct file *file, char __user *user_buf,
>  			      size_t count, loff_t *ppos)
> diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
> index 63f2465..d68b4ea 100644
> --- a/include/linux/debugfs.h
> +++ b/include/linux/debugfs.h
> @@ -79,6 +79,8 @@ struct dentry *debugfs_create_x64(const char *name, umode_t mode,
>  				  struct dentry *parent, u64 *value);
>  struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
>  				     struct dentry *parent, size_t *value);
> +struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
> +				     struct dentry *parent, atomic_t *value);
>  struct dentry *debugfs_create_bool(const char *name, umode_t mode,
>  				  struct dentry *parent, u32 *value);
>  
> diff --git a/lib/fault-inject.c b/lib/fault-inject.c
> index c5c7a76..d7d501e 100644
> --- a/lib/fault-inject.c
> +++ b/lib/fault-inject.c
> @@ -182,27 +182,6 @@ static struct dentry *debugfs_create_stacktrace_depth(
>  
>  #endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
>  
> -static int debugfs_atomic_t_set(void *data, u64 val)
> -{
> -	atomic_set((atomic_t *)data, val);
> -	return 0;
> -}
> -
> -static int debugfs_atomic_t_get(void *data, u64 *val)
> -{
> -	*val = atomic_read((atomic_t *)data);
> -	return 0;
> -}
> -
> -DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t, debugfs_atomic_t_get,
> -			debugfs_atomic_t_set, "%lld\n");
> -
> -static struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
> -				struct dentry *parent, atomic_t *value)
> -{
> -	return debugfs_create_file(name, mode, parent, value, &fops_atomic_t);
> -}
> -
>  struct dentry *fault_create_debugfs_attr(const char *name,
>  			struct dentry *parent, struct fault_attr *attr)
>  {
> -- 
> 1.8.2.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
