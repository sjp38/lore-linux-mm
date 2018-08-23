Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2A26B2A63
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:44:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r131-v6so4852720oie.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:44:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g84-v6si2997659oif.285.2018.08.23.06.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:44:21 -0700 (PDT)
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
References: <20180823120707.10998-1-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
Date: Thu, 23 Aug 2018 22:44:07 +0900
MIME-Version: 1.0
In-Reply-To: <20180823120707.10998-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

On 2018/08/23 21:07, Michal Hocko wrote:
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 57390c7666e5..e7d8bb1bee2a 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -519,21 +519,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
>  	struct gntdev_grant_map *map;
>  	int ret = 0;
>  
> -	/* TODO do we really need a mutex here? */
>  	if (blockable)
>  		mutex_lock(&priv->lock);
>  	else if (!mutex_trylock(&priv->lock))
>  		return -EAGAIN;
>  
>  	list_for_each_entry(map, &priv->maps, next) {
> -		if (in_range(map, start, end)) {
> +		if (!blockable && in_range(map, start, end)) {

This still looks strange. Prior to 93065ac753e4, in_range() test was
inside unmap_if_in_range(). But this patch removes in_range() test
if blockable == true. That is, unmap_if_in_range() will unconditionally
unmap if blockable == true, which seems to be an unexpected change.

>  			ret = -EAGAIN;
>  			goto out_unlock;
>  		}
>  		unmap_if_in_range(map, start, end);
>  	}
