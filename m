Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 077296B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 16:10:12 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so21533503pad.21
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 13:10:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id dq7si903446pdb.217.2014.08.25.13.10.11
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 13:10:11 -0700 (PDT)
Message-ID: <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Mon, 25 Aug 2014 14:10:03 -0600
In-Reply-To: <53ECB480.4060104@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>
	 <53ECB480.4060104@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Thu, 2014-08-14 at 16:07 +0300, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> This streamlines prd with the latest brd code.
> 
> In prd we do not allocate new devices dynamically on devnod
> access, because we need parameterization of each device. So
> the dynamic allocation in prd_init_one is removed.
> 
> Therefor prd_init_one only called from prd_prob is moved
> there, now that it is small.
> 
> And other small fixes regarding partitions
> 
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  drivers/block/prd.c | 47 ++++++++++++++++++++++++-----------------------
>  1 file changed, 24 insertions(+), 23 deletions(-)

<snip>

> @@ -333,16 +321,27 @@ static void prd_del_one(struct prd_device *prd)
>  	prd_free(prd);
>  }
>  
> +/*FIXME: Actually in our driver prd_probe is never used. Can be removed */
>  static struct kobject *prd_probe(dev_t dev, int *part, void *data)
>  {
>  	struct prd_device *prd;
>  	struct kobject *kobj;
> +	int number = MINOR(dev);

Unfortunately I think this is broken, and it was broken in the previous
version of prd_probe() as well.

When we were allocating minors from our own device we could rely on the fact
that there was a relationship between the minor number of the device and the
prd_number.  Now that we're using the dynamic minors scheme, our minor is
dependent on other drivers that are also using that same scheme.  For example,
when both PRD and BRD are using dynamic minors:

# ls -la /dev/ram* /dev/pmem*
brw-rw---- 1 root disk 259, 4 Aug 25 12:38 /dev/pmem0
brw-rw---- 1 root disk 259, 5 Aug 25 12:38 /dev/pmem1
brw-rw---- 1 root disk 259, 6 Aug 25 12:38 /dev/pmem2
brw-rw---- 1 root disk 259, 7 Aug 25 12:38 /dev/pmem3
brw-rw---- 1 root disk 259, 0 Aug 25 12:22 /dev/ram0
brw-rw---- 1 root disk 259, 1 Aug 25 12:22 /dev/ram1
brw-rw---- 1 root disk 259, 2 Aug 25 12:22 /dev/ram2
brw-rw---- 1 root disk 259, 3 Aug 25 12:22 /dev/ram3

pmem0 has prd_number 0, but has minor 4.

I think we can still have a working probe by instead comparing the passed in
dev_t against the dev_t we get back from disk_to_dev(prd->prd_disk), but I'd
really like a use case so I can test this.  Until then I think I'm just going
to stub out prd/pmem_probe() with a BUG() so we can see if anyone hits it.

It seems like this is preferable to just registering NULL for probe, as that
would cause an oops in kobj_lookup(() when probe() is blindly called without
checking for NULL.

- Ross

>  
>  	mutex_lock(&prd_devices_mutex);
> -	prd = prd_init_one(MINOR(dev));
> -	kobj = prd ? get_disk(prd->prd_disk) : NULL;
> -	mutex_unlock(&prd_devices_mutex);
>  
> +	list_for_each_entry(prd, &prd_devices, prd_list) {
> +		if (prd->prd_number == number) {
> +			kobj = get_disk(prd->prd_disk);
> +			goto out;
> +		}
> +	}
> +
> +	pr_err("prd: prd_probe: Unexpected parameter=%d\n", number);
> +	kobj = NULL;
> +
> +out:
> +	mutex_unlock(&prd_devices_mutex);
>  	return kobj;
>  }
>  
> @@ -424,5 +423,7 @@ static void __exit prd_exit(void)
>  
>  MODULE_AUTHOR("Ross Zwisler <ross.zwisler@linux.intel.com>");
>  MODULE_LICENSE("GPL");
> +MODULE_ALIAS("pmem");
> +
>  module_init(prd_init);
>  module_exit(prd_exit);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
