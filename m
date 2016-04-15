Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6FA6B0262
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:29:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t184so75933266qkh.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:29:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e46si19957155qgd.31.2016.04.15.05.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 05:29:30 -0700 (PDT)
Date: Fri, 15 Apr 2016 08:29:28 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH 17/19] dm: get rid of superfluous gfp flags
In-Reply-To: <1460372892-8157-18-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.LRH.2.02.1604150826280.16981@file01.intranet.prod.int.rdu2.redhat.com>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org> <1460372892-8157-18-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>



On Mon, 11 Apr 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> copy_params seems to be little bit confused about which allocation flags
> to use. It enforces GFP_NOIO even though it uses
> memalloc_noio_{save,restore} which enforces GFP_NOIO at the page

memalloc_noio_{save,restore} is used because __vmalloc is flawed and 
doesn't respect GFP_NOIO properly (it doesn't use gfp flags when 
allocating pagetables).

The proper fix it to correct __vmalloc (though, it would require change to 
pagetable allocation routine on all architectures), not to remove GFP_NOIO 
from __vmalloc.

Mikulas

> allocator level automatically (via memalloc_noio_flags). It also
> uses __GFP_REPEAT for the __vmalloc request which doesn't make much
> sense either because vmalloc doesn't rely on costly high order
> allocations.
> 
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/md/dm-ioctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> index 2adf81d81fca..dfe629a294e1 100644
> --- a/drivers/md/dm-ioctl.c
> +++ b/drivers/md/dm-ioctl.c
> @@ -1723,7 +1723,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
>  	if (!dmi) {
>  		unsigned noio_flag;
>  		noio_flag = memalloc_noio_save();
> -		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_REPEAT | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
> +		dmi = __vmalloc(param_kernel->data_size, __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
>  		memalloc_noio_restore(noio_flag);
>  		if (dmi)
>  			*param_flags |= DM_PARAMS_VMALLOC;
> -- 
> 2.8.0.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
