Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EED938D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 20:01:53 -0500 (EST)
Date: Tue, 1 Mar 2011 17:01:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/dmapool.c: Do not create/destroy sysfs file while
 holding pools_lock
Message-Id: <20110301170117.258e06e2.akpm@linux-foundation.org>
In-Reply-To: <20110228224124.GA31769@blackmagic.digium.internal>
References: <20110228224124.GA31769@blackmagic.digium.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Meyerriecks <rmeyerriecks@digium.com>
Cc: sruffell@digium.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>

On Mon, 28 Feb 2011 16:41:24 -0600
Russ Meyerriecks <rmeyerriecks@digium.com> wrote:

> From: Shaun Ruffell <sruffell@digium.com>
> 
> Eliminates a circular lock dependency reported by lockdep. When reading the
> "pools" file from a PCI device via sysfs, the s_active lock is acquired before
> the pools_lock. When unloading the driver and destroying the pool, pools_lock
> is acquired before the s_active lock.
> 
>  cat/12016 is trying to acquire lock:
>   (pools_lock){+.+.+.}, at: [<c04ef113>] show_pools+0x43/0x140
> 
>  but task is already holding lock:
>   (s_active#82){++++.+}, at: [<c0554e1b>] sysfs_read_file+0xab/0x160
> 
>  which lock already depends on the new lock.

sysfs_dirent_init_lockdep() and the 6992f53349 ("sysfs: Use one lockdep
class per sysfs attribute") which added it are rather scary.

The alleged bug appears to be due to taking pools_lock outside
device_create_file() (which takes magical sysfs PseudoVirtualLocks)
versus show_pools(), which takes pools_lock but is called from inside
magical sysfs PseudoVirtualLocks.

I don't know if this is actually a real bug or not.  Probably not, as
this device_create_file() does not match the reasons for 6992f53349:
"There is a sysfs idiom where writing to one sysfs file causes the
addition or removal of other sysfs files".  But that's a guess.

> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -174,21 +174,28 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  	init_waitqueue_head(&retval->waitq);
>  
>  	if (dev) {
> -		int ret;
> +		int first_pool;
>  
>  		mutex_lock(&pools_lock);
>  		if (list_empty(&dev->dma_pools))
> -			ret = device_create_file(dev, &dev_attr_pools);
> +			first_pool = 1;
>  		else
> -			ret = 0;
> +			first_pool = 0;
>  		/* note:  not currently insisting "name" be unique */
> -		if (!ret)
> -			list_add(&retval->pools, &dev->dma_pools);
> -		else {
> -			kfree(retval);
> -			retval = NULL;
> -		}
> +		list_add(&retval->pools, &dev->dma_pools);
>  		mutex_unlock(&pools_lock);
> +
> +		if (first_pool) {
> +			int ret;
> +			ret = device_create_file(dev, &dev_attr_pools);
> +			if (ret) {
> +				mutex_lock(&pools_lock);
> +				list_del(&retval->pools);
> +				mutex_unlock(&pools_lock);
> +				kfree(retval);
> +				retval = NULL;
> +			}
> +		}

Not a good fix, IMO.  The problem is that if two CPUs concurrently call
dma_pool_create(), the first CPU will spend time creating the sysfs
file.  Meanwhile, the second CPU will whizz straight back to its
caller.  The caller now thinks that the sysfs file has been created and
returns to userspace, which immediately tries to read the sysfs file. 
But the first CPU hasn't finished creating it yet.  Userspace fails.

One way of fixing this would be to create another singleton lock:


	{
		static DEFINE_MUTEX(pools_sysfs_lock);
		static bool pools_sysfs_done;

		mutex_lock(&pools_sysfs_lock);
		if (pools_sysfs_done == false) {
			create_sysfs_stuff();
			pools_sysfs_done = true;
		}
		mutex_unlock(&pools_sysfs_lock);
	}

That's not terribly pretty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
