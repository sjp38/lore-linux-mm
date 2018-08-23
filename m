Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 614E86B2A7E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:05:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l11-v6so4722566qkk.0
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:05:42 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q63-v6si4513554qkb.152.2018.08.23.07.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:05:41 -0700 (PDT)
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
References: <20180823120707.10998-1-mhocko@kernel.org>
 <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
 <20180823135151.GM29735@dhcp22.suse.cz>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <9d2d11eb-7fe1-b836-056c-7886d6fc56e5@oracle.com>
Date: Thu, 23 Aug 2018 10:06:53 -0400
MIME-Version: 1.0
In-Reply-To: <20180823135151.GM29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>

On 08/23/2018 09:51 AM, Michal Hocko wrote:
> On Thu 23-08-18 22:44:07, Tetsuo Handa wrote:
>> On 2018/08/23 21:07, Michal Hocko wrote:
>>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>>> index 57390c7666e5..e7d8bb1bee2a 100644
>>> --- a/drivers/xen/gntdev.c
>>> +++ b/drivers/xen/gntdev.c
>>> @@ -519,21 +519,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
>>>  	struct gntdev_grant_map *map;
>>>  	int ret = 0;
>>>  
>>> -	/* TODO do we really need a mutex here? */
>>>  	if (blockable)
>>>  		mutex_lock(&priv->lock);
>>>  	else if (!mutex_trylock(&priv->lock))
>>>  		return -EAGAIN;
>>>  
>>>  	list_for_each_entry(map, &priv->maps, next) {
>>> -		if (in_range(map, start, end)) {
>>> +		if (!blockable && in_range(map, start, end)) {
>> This still looks strange. Prior to 93065ac753e4, in_range() test was
>> inside unmap_if_in_range(). But this patch removes in_range() test
>> if blockable == true. That is, unmap_if_in_range() will unconditionally
>> unmap if blockable == true, which seems to be an unexpected change.
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
>  		unmap_if_in_range(map, start, end);


(I obviously missed that too with my R-b).

This will never get anything done either. How about

A A A  if (in_range()) {
A A A  A A A  if (!blockable) {
A A A  A A A  A A A  ret = -EGAIN;
A A A  A A A  A A A  goto out_unlock;
A A A  A A A  }
A A A  A A A  unmap_range(); // new name since unmap_if_in_range() doesn't
perform any checks now
A A A  }



-boris


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
