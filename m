Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 974C66B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:23:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r65so169583559qkd.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:23:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si1436076ywa.451.2016.07.14.08.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 08:23:04 -0700 (PDT)
Subject: Re: System freezes after OOM
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
From: Ondrej Kozina <okozina@redhat.com>
Message-ID: <740b17f0-e1bb-b021-e9e1-ad6dcf5f033a@redhat.com>
Date: Thu, 14 Jul 2016 16:08:28 +0200
MIME-Version: 1.0
In-Reply-To: <20160714125129.GA12289@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>
Cc: Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On 07/14/2016 02:51 PM, Michal Hocko wrote:
> On Wed 13-07-16 11:02:15, Mikulas Patocka wrote:
>> On Wed, 13 Jul 2016, Michal Hocko wrote:
> [...]
>
> We are discussing several topics together so let's focus on this
> particlar thing for now
>
>>>> The kernel 4.7-rc almost deadlocks in another way. The machine got stuck
>>>> and the following stacktrace was obtained when swapping to dm-crypt.
>>>>
>>>> We can see that dm-crypt does a mempool allocation. But the mempool
>>>> allocation somehow falls into throttle_vm_writeout. There, it waits for
>>>> 0.1 seconds. So, as a result, the dm-crypt worker thread ends up
>>>> processing requests at an unusually slow rate of 10 requests per second
>>>> and it results in the machine being stuck (it would proabably recover if
>>>> we waited for extreme amount of time).
>>>
>>> Hmm, that throttling is there since ever basically. I do not see what
>>> would have changed that recently, but I haven't looked too close to be
>>> honest.
>>>
>>> I agree that throttling a flusher (which this worker definitely is)
>>> doesn't look like a correct thing to do. We have PF_LESS_THROTTLE for
>>> this kind of things. So maybe the right thing to do is to use this flag
>>> for the dm_crypt worker:
>>>
>>> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
>>> index 4f3cb3554944..0b806810efab 100644
>>> --- a/drivers/md/dm-crypt.c
>>> +++ b/drivers/md/dm-crypt.c
>>> @@ -1392,11 +1392,14 @@ static void kcryptd_async_done(struct crypto_async_request *async_req,
>>>  static void kcryptd_crypt(struct work_struct *work)
>>>  {
>>>  	struct dm_crypt_io *io = container_of(work, struct dm_crypt_io, work);
>>> +	unsigned int pflags = current->flags;
>>>
>>> +	current->flags |= PF_LESS_THROTTLE;
>>>  	if (bio_data_dir(io->base_bio) == READ)
>>>  		kcryptd_crypt_read_convert(io);
>>>  	else
>>>  		kcryptd_crypt_write_convert(io);
>>> +	tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
>>>  }
>>>
>>>  static void kcryptd_queue_crypt(struct dm_crypt_io *io)
>>
>> ^^^ That fixes just one specific case - but there may be other threads
>> doing mempool allocations in the device mapper subsystem - and you would
>> need to mark all of them.
>
> Now that I am thinking about it some more. Are there any mempool users
> which would actually want to be throttled? I would expect mempool users
> are necessary to push IO through and throttle them sounds like a bad
> decision in the first place but there might be other mempool users which
> could cause issues. Anyway how about setting PF_LESS_THROTTLE
> unconditionally inside mempool_alloc? Something like the following:
>
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 8f65464da5de..e21fb632983f 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -310,7 +310,8 @@ EXPORT_SYMBOL(mempool_resize);
>   */
>  void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  {
> -	void *element;
> +	unsigned int pflags = current->flags;
> +	void *element = NULL;
>  	unsigned long flags;
>  	wait_queue_t wait;
>  	gfp_t gfp_temp;
> @@ -327,6 +328,12 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>
>  	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
>
> +	/*
> +	 * Make sure that the allocation doesn't get throttled during the
> +	 * reclaim
> +	 */
> +	if (gfpflags_allow_blocking(gfp_mask))
> +		current->flags |= PF_LESS_THROTTLE;
>  repeat_alloc:
>  	if (likely(pool->curr_nr)) {
>  		/*
> @@ -339,7 +346,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>
>  	element = pool->alloc(gfp_temp, pool->pool_data);
>  	if (likely(element != NULL))
> -		return element;
> +		goto out;
>
>  	spin_lock_irqsave(&pool->lock, flags);
>  	if (likely(pool->curr_nr)) {
> @@ -352,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  		 * for debugging.
>  		 */
>  		kmemleak_update_trace(element);
> -		return element;
> +		goto out;
>  	}
>
>  	/*
> @@ -369,7 +376,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
>  	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
>  		spin_unlock_irqrestore(&pool->lock, flags);
> -		return NULL;
> +		goto out;
>  	}
>
>  	/* Let's wait for someone else to return an element to @pool */
> @@ -386,6 +393,10 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>
>  	finish_wait(&pool->wait, &wait);
>  	goto repeat_alloc;
> +out:
> +	if (gfpflags_allow_blocking(gfp_mask))
> +		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
> +	return element;
>  }
>  EXPORT_SYMBOL(mempool_alloc);
>
>

As Mikulas pointed out, this doesn't work. The system froze as well with 
the patch above. Will try to tweak the patch with Mikulas's suggestion...

O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
