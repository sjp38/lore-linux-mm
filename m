Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C63B6B025E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:04:08 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id u23so59333055vkb.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:04:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b185si5081877qkc.129.2016.04.28.08.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:04:07 -0700 (PDT)
Date: Thu, 28 Apr 2016 11:04:05 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] md: simplify free_params for kmalloc vs vmalloc
 fallback
In-Reply-To: <1461855076-1682-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.LRH.2.02.1604281059290.14065@file01.intranet.prod.int.rdu2.redhat.com>
References: <1461849846-27209-20-git-send-email-mhocko@kernel.org> <1461855076-1682-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>, dm-devel@redhat.com

Acked-by: Mikulas Patocka <mpatocka@redhat.com>

BTW. we could also use kvmalloc to complement kvfree, proposed here: 
https://www.redhat.com/archives/dm-devel/2015-July/msg00046.html

Mikulas

On Thu, 28 Apr 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Use kvfree rather than DM_PARAMS_[KV]MALLOC specific param flags.
> 
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Cc: dm-devel@redhat.com
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this is a rebase on top of dropped "dm: clean up GFP_NIO usage" which
> should be dropped as per the feedback from Mikulas.
> 
>  drivers/md/dm-ioctl.c | 16 +++-------------
>  1 file changed, 3 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> index 2c7ca258c4e4..e66e5b43bc18 100644
> --- a/drivers/md/dm-ioctl.c
> +++ b/drivers/md/dm-ioctl.c
> @@ -1670,19 +1670,14 @@ static int check_version(unsigned int cmd, struct dm_ioctl __user *user)
>  	return r;
>  }
>  
> -#define DM_PARAMS_KMALLOC	0x0001	/* Params alloced with kmalloc */
> -#define DM_PARAMS_VMALLOC	0x0002	/* Params alloced with vmalloc */
> -#define DM_WIPE_BUFFER		0x0010	/* Wipe input buffer before returning from ioctl */
> +#define DM_WIPE_BUFFER		0x0001	/* Wipe input buffer before returning from ioctl */
>  
>  static void free_params(struct dm_ioctl *param, size_t param_size, int param_flags)
>  {
>  	if (param_flags & DM_WIPE_BUFFER)
>  		memset(param, 0, param_size);
>  
> -	if (param_flags & DM_PARAMS_KMALLOC)
> -		kfree(param);
> -	if (param_flags & DM_PARAMS_VMALLOC)
> -		vfree(param);
> +	kvfree(param);
>  }
>  
>  static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kernel,
> @@ -1714,19 +1709,14 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
>  	 * Use kmalloc() rather than vmalloc() when we can.
>  	 */
>  	dmi = NULL;
> -	if (param_kernel->data_size <= KMALLOC_MAX_SIZE) {
> +	if (param_kernel->data_size <= KMALLOC_MAX_SIZE)
>  		dmi = kmalloc(param_kernel->data_size, GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
> -		if (dmi)
> -			*param_flags |= DM_PARAMS_KMALLOC;
> -	}
>  
>  	if (!dmi) {
>  		unsigned noio_flag;
>  		noio_flag = memalloc_noio_save();
>  		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
>  		memalloc_noio_restore(noio_flag);
> -		if (dmi)
> -			*param_flags |= DM_PARAMS_VMALLOC;
>  	}
>  
>  	if (!dmi) {
> -- 
> 2.8.0.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
