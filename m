Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1CC66B2A86
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:21:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q130-v6so1771378oic.22
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:21:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w130-v6si3312598oiw.396.2018.08.23.07.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:21:06 -0700 (PDT)
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
References: <20180823120707.10998-1-mhocko@kernel.org>
 <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
 <20180823135151.GM29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <470950f0-a579-6c74-c5f0-bea635259176@i-love.sakura.ne.jp>
Date: Thu, 23 Aug 2018 23:20:54 +0900
MIME-Version: 1.0
In-Reply-To: <20180823135151.GM29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

On 2018/08/23 22:51, Michal Hocko wrote:
> You are right. I completely forgot I've removed in_range there. Does
> this look any better?
> 
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index e7d8bb1bee2a..30f81004ea63 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -525,14 +525,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
>  		return -EAGAIN;
>  
>  	list_for_each_entry(map, &priv->maps, next) {
> -		if (!blockable && in_range(map, start, end)) {
> +		if (in_range(map, start, end)) {
> +			if (blockable)
> +				continue;
> +
>  			ret = -EAGAIN;
>  			goto out_unlock;
>  		}

This still looks strange. in_range() returns false if map->vma == NULL.
But unmap_if_in_range() unconditionally dereferences map->vma->vm_[start|end] .
Suggestion from Boris looks better.

>  		unmap_if_in_range(map, start, end);
>  	}
>  	list_for_each_entry(map, &priv->freeable_maps, next) {
> -		if (!blockable && in_range(map, start, end)) {
> +		if (in_range(map, start, end)) {
> +			if (blockable)
> +				continue;
> +			
>  			ret = -EAGAIN;
>  			goto out_unlock;
>  		}
> 
