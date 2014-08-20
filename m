Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 60C4C6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:03:22 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so12685854pdb.41
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:03:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id qz10si28648805pab.198.2014.08.20.16.03.20
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 16:03:21 -0700 (PDT)
Message-ID: <1408575780.26863.21.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [RFC 5/9] SQUASHME: prd: Last fixes for partitions
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Wed, 20 Aug 2014 17:03:00 -0600
In-Reply-To: <53EB5709.4090401@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Wed, 2014-08-13 at 15:16 +0300, Boaz Harrosh wrote:
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

> @@ -308,24 +314,6 @@ static void prd_free(struct prd_device *prd)
>  	kfree(prd);
>  }
>  
> -static struct prd_device *prd_init_one(int i)
> -{
> -	struct prd_device *prd;
> -
> -	list_for_each_entry(prd, &prd_devices, prd_list) {
> -		if (prd->prd_number == i)
> -			goto out;
> -	}
> -
> -	prd = prd_alloc(i);
> -	if (prd) {
> -		add_disk(prd->prd_disk);
> -		list_add_tail(&prd->prd_list, &prd_devices);
> -	}
> -out:
> -	return prd;
> -}
> -
>  static void prd_del_one(struct prd_device *prd)
>  {
>  	list_del(&prd->prd_list);
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

I really like where you're going with getting rid of prd_probe.  Clearly I
just copied this from brd, but I'd love to be rid of it entirely.  Is there a
valid way for our probe function to get called?  If not, can we just have a
little stub with a BUG() in it to make sure we hear about it if it does ever
get called, and delete a bunch of code?

I think this would let us get rid of pmem_probe(), pmem_init_one(), and the
pmem_devices_mutex.

If there *is* a valid way for this code to get called, let's figure it out so
we can at least test this function.  This will be especially necessary as we
add support for more pmem disks.

>  
> @@ -424,5 +423,7 @@ static void __exit prd_exit(void)
>  
>  MODULE_AUTHOR("Ross Zwisler <ross.zwisler@linux.intel.com>");
>  MODULE_LICENSE("GPL");
> +MODULE_ALIAS("pmem");

Let's just go with the full rename s/prd/pmem/.  That turned out to be really
clean & made everything consistent - thanks for the good suggestion.

- Ross


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
