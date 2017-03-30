Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED752806DF
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 11:04:44 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c133so25487983oia.17
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:04:44 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0075.outbound.protection.outlook.com. [104.47.37.75])
        by mx.google.com with ESMTPS id h36si1118449otc.252.2017.03.30.08.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 08:04:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
 <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
From: Thomas Hellstrom <thellstrom@vmware.com>
Message-ID: <6b390234-71e7-e379-201c-0fb4a05399c2@vmware.com>
Date: Thu, 30 Mar 2017 17:04:17 +0200
MIME-Version: 1.0
In-Reply-To: <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, akpm@linux-foundation.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On 03/30/2017 04:48 PM, Andrey Ryabinin wrote:
> On 03/30/2017 03:00 PM, Thomas Hellstrom wrote:
>
>>>  
>>>  	if (unlikely(nr_lazy > lazy_max_pages()))
>>> -		try_purge_vmap_area_lazy();
>> Perhaps a slight optimization would be to schedule work iff
>> !mutex_locked(&vmap_purge_lock) below?
>>
> Makes sense, we don't need to spawn workers if we already purging.
>
>
>
> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Subject: mm/vmalloc: allow to call vfree() in atomic context fix
>
> Don't spawn worker if we already purging.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/vmalloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ea1b4ab..88168b8 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
>  	/* After this point, we may free va at any time */
>  	llist_add(&va->purge_list, &vmap_purge_list);
>  
> -	if (unlikely(nr_lazy > lazy_max_pages()))
> +	if (unlikely(nr_lazy > lazy_max_pages()) &&
> +	    !mutex_is_locked(&vmap_purge_lock))
>  		schedule_work(&purge_vmap_work);
>  }
>  

For both patches,

Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>

Thanks,

Thomas


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
