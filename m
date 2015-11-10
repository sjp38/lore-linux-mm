Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 215916B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:34:03 -0500 (EST)
Received: by wmvv187 with SMTP id v187so8096482wmv.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:34:02 -0800 (PST)
Received: from zimbra13.linbit.com (zimbra13.linbit.com. [212.69.166.240])
        by mx.google.com with ESMTPS id uc9si4435195wjc.194.2015.11.10.05.34.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:34:01 -0800 (PST)
Date: Tue, 10 Nov 2015 14:34:00 +0100
From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Re: [DRBD-user] [PATCH] tree wide: Use kvfree() than conditional
 kfree()/vfree()
Message-ID: <20151110133400.GZ14472@soda.linbit>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, drbd-user@lists.linbit.com

On Mon, Nov 09, 2015 at 08:56:10PM +0900, Tetsuo Handa wrote:
> There are many locations that do
> 
>   if (memory_was_allocated_by_vmalloc)
>     vfree(ptr);
>   else
>     kfree(ptr);
> 
> but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
> using is_vmalloc_addr(). Unless callers have special reasons, we can
> replace this branch with kvfree(). Please check and reply if you found
> problems.

For the DRBD part:

>  drivers/block/drbd/drbd_bitmap.c                   | 26 +++++------------
>  drivers/block/drbd/drbd_int.h                      |  3 --

> diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
> index 9462d27..2daaafb 100644
> --- a/drivers/block/drbd/drbd_bitmap.c
> +++ b/drivers/block/drbd/drbd_bitmap.c
> @@ -364,12 +364,9 @@ static void bm_free_pages(struct page **pages, unsigned long number)
>  	}
>  }
>  
> -static void bm_vk_free(void *ptr, int v)
> +static inline void bm_vk_free(void *ptr)

Maybe drop this inline completely ...

>  {
> -	if (v)
> -		vfree(ptr);
> -	else
> -		kfree(ptr);
> +	kvfree(ptr);
>  }

... and just call kvfree() directly below?

> -				bm_vk_free(new_pages, vmalloced);
> +				bm_vk_free(new_pages);

  +				kvfree(new_pages);
  ...


Other than that: looks good and harmless enough.
Thanks,

	Lars

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
