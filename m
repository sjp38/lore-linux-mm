Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE07F6B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:02:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e129so119168902pfh.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:02:32 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id p17si7700391pgi.218.2017.03.17.00.02.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 00:02:31 -0700 (PDT)
Subject: Re: [HMM 16/16] mm/hmm/devmem: dummy HMM device for ZONE_DEVICE
 memory v2
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-17-git-send-email-jglisse@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <e3163e6a-654d-cbf6-3aad-788c31f20655@huawei.com>
Date: Fri, 17 Mar 2017 14:55:57 +0800
MIME-Version: 1.0
In-Reply-To: <1489680335-6594-17-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny
 Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

Hi JA(C)rA'me,

On 2017/3/17 0:05, JA(C)rA'me Glisse wrote:
> This introduce a dummy HMM device class so device driver can use it to
> create hmm_device for the sole purpose of registering device memory.

May I ask where is the latest dummy HMM device driver?
I can only get this one: https://patchwork.kernel.org/patch/4352061/

Thanks,
Bob

> It is usefull to device driver that want to manage multiple physical
> device memory under same struct device umbrella.
> 
> Changed since v1:
>   - Improve commit message
>   - Add drvdata parameter to set on struct device
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---
>  include/linux/hmm.h | 22 +++++++++++-
>  mm/hmm.c            | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 117 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 3054ce7..e4e6b36 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -79,11 +79,11 @@
>  
>  #if IS_ENABLED(CONFIG_HMM)
>  
> +#include <linux/device.h>
>  #include <linux/migrate.h>
>  #include <linux/memremap.h>
>  #include <linux/completion.h>
>  
> -
>  struct hmm;
>  
>  /*
> @@ -433,6 +433,26 @@ static inline unsigned long hmm_devmem_page_get_drvdata(struct page *page)
>  
>  	return drvdata[1];
>  }
> +
> +
> +/*
> + * struct hmm_device - fake device to hang device memory onto
> + *
> + * @device: device struct
> + * @minor: device minor number
> + */
> +struct hmm_device {
> +	struct device		device;
> +	unsigned		minor;
> +};
> +
> +/*
> + * Device driver that wants to handle multiple devices memory through a single
> + * fake device can use hmm_device to do so. This is purely a helper and it
> + * is not needed to make use of any HMM functionality.
> + */
> +struct hmm_device *hmm_device_new(void *drvdata);
> +void hmm_device_put(struct hmm_device *hmm_device);
>  #endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
>  
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 019f379..c477bd1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -24,6 +24,7 @@
>  #include <linux/slab.h>
>  #include <linux/sched.h>
>  #include <linux/mmzone.h>
> +#include <linux/module.h>
>  #include <linux/pagemap.h>
>  #include <linux/swapops.h>
>  #include <linux/hugetlb.h>
> @@ -1132,4 +1133,99 @@ int hmm_devmem_fault_range(struct hmm_devmem *devmem,
>  	return 0;
>  }
>  EXPORT_SYMBOL(hmm_devmem_fault_range);
> +
> +/*
> + * A device driver that wants to handle multiple devices memory through a
> + * single fake device can use hmm_device to do so. This is purely a helper
> + * and it is not needed to make use of any HMM functionality.
> + */
> +#define HMM_DEVICE_MAX 256
> +
> +static DECLARE_BITMAP(hmm_device_mask, HMM_DEVICE_MAX);
> +static DEFINE_SPINLOCK(hmm_device_lock);
> +static struct class *hmm_device_class;
> +static dev_t hmm_device_devt;
> +
> +static void hmm_device_release(struct device *device)
> +{
> +	struct hmm_device *hmm_device;
> +
> +	hmm_device = container_of(device, struct hmm_device, device);
> +	spin_lock(&hmm_device_lock);
> +	clear_bit(hmm_device->minor, hmm_device_mask);
> +	spin_unlock(&hmm_device_lock);
> +
> +	kfree(hmm_device);
> +}
> +
> +struct hmm_device *hmm_device_new(void *drvdata)
> +{
> +	struct hmm_device *hmm_device;
> +	int ret;
> +
> +	hmm_device = kzalloc(sizeof(*hmm_device), GFP_KERNEL);
> +	if (!hmm_device)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = alloc_chrdev_region(&hmm_device->device.devt,0,1,"hmm_device");
> +	if (ret < 0) {
> +		kfree(hmm_device);
> +		return NULL;
> +	}
> +
> +	spin_lock(&hmm_device_lock);
> +	hmm_device->minor=find_first_zero_bit(hmm_device_mask,HMM_DEVICE_MAX);
> +	if (hmm_device->minor >= HMM_DEVICE_MAX) {
> +		spin_unlock(&hmm_device_lock);
> +		kfree(hmm_device);
> +		return NULL;
> +	}
> +	set_bit(hmm_device->minor, hmm_device_mask);
> +	spin_unlock(&hmm_device_lock);
> +
> +	dev_set_name(&hmm_device->device, "hmm_device%d", hmm_device->minor);
> +	hmm_device->device.devt = MKDEV(MAJOR(hmm_device_devt),
> +					hmm_device->minor);
> +	hmm_device->device.release = hmm_device_release;
> +	dev_set_drvdata(&hmm_device->device, drvdata);
> +	hmm_device->device.class = hmm_device_class;
> +	device_initialize(&hmm_device->device);
> +
> +	return hmm_device;
> +}
> +EXPORT_SYMBOL(hmm_device_new);
> +
> +void hmm_device_put(struct hmm_device *hmm_device)
> +{
> +	put_device(&hmm_device->device);
> +}
> +EXPORT_SYMBOL(hmm_device_put);
> +
> +static int __init hmm_init(void)
> +{
> +	int ret;
> +
> +	ret = alloc_chrdev_region(&hmm_device_devt, 0,
> +				  HMM_DEVICE_MAX,
> +				  "hmm_device");
> +	if (ret)
> +		return ret;
> +
> +	hmm_device_class = class_create(THIS_MODULE, "hmm_device");
> +	if (IS_ERR(hmm_device_class)) {
> +		unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
> +		return PTR_ERR(hmm_device_class);
> +	}
> +	return 0;
> +}
> +
> +static void __exit hmm_exit(void)
> +{
> +	unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
> +	class_destroy(hmm_device_class);
> +}
> +
> +module_init(hmm_init);
> +module_exit(hmm_exit);
> +MODULE_LICENSE("GPL");
>  #endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
