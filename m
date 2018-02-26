Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E33046B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:26:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d137so5856752pga.6
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:26:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a10sor1981714pgf.37.2018.02.26.10.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 10:26:02 -0800 (PST)
Subject: Re: [PATCH 4/7] Protectable Memory
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-5-igor.stoppa@huawei.com>
 <55aea52e-3557-4d8d-7b1a-a0b5c9ce3090@gmail.com>
 <4aa98672-7b36-5bf3-33b0-f7e69901cbe5@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <e4116e4f-3a74-f37b-1aa7-4d71aae680d6@gmail.com>
Date: Mon, 26 Feb 2018 10:25:57 -0800
MIME-Version: 1.0
In-Reply-To: <4aa98672-7b36-5bf3-33b0-f7e69901cbe5@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

inlined responses.


On 2/26/18 6:28 AM, Igor Stoppa wrote:
>
> On 24/02/18 02:10, J Freyensee wrote:
>> On 2/23/18 6:48 AM, Igor Stoppa wrote:
> [...]
>
>>> +struct gen_pool *pmalloc_create_pool(const char *name,
>>> +					 int min_alloc_order);
>> Same comments as earlier.A  If this is new API with new code being
>> introduced into the kernel, can the variables be declared to avoid weird
>> problems?A  Like min_alloc_order being a negative value makes little
>> sense (based on the description here), so can it be declared as size_t
>> or unsigned int?
> in this case, yes, but I see it as different case

OK.

>
> [...]
>
>>> + * * NULL				- either no memory available or
>>> + *					  pool already read-only
>>> + */
>> I don't know if an errno value is being set, but setting a variable
>> somewhere using EROFS or ENOMEM would more accurate diagnose those two
>> NULL conditions.
> I expect that the latter is highly unlikely to happen, because the user
> of the API controls if the pool is locked or not.
>
> I think it shouldn't come as a surprise to the one who locked the pool,
> if the pool is locked.
>
> If the pool is used with concurrent users, attention should be paid to
> not lock it before ever user is happy (this is where the user of the API
> has to provide own locking.)
>
> Since the information if the pool is already protected is actually
> present in the pmalloc_data structure associated with the pool, I was
> tempted to make it available through the API, but that seemed wrong.
>
> The user of the API should be very aware of the state of the pool, since
> the user is the one who sets it. Why would it have to be read back?

OK, sounds good :-).

>
>>> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp);
>>> +
>>> +
>>> +/**
>>> + * pzalloc() - zero-initialized version of pmalloc
>>> + * @pool: handle to the pool to be used for memory allocation
>>> + * @size: amount of memory (in bytes) requested
>>> + * @gfp: flags for page allocation
>>> + *
>>> + * Executes pmalloc, initializing the memory requested to 0,
>>> + * before returning the pointer to it.
>>> + *
>>> + * Return:
>>> + * * pointer to the memory requested	- success
>>> + * * NULL				- either no memory available or
>>> + *					  pool already read-only
>>> + */
>> Same comment here, though that inline function below looks highly
>> optimized...
> The same applies here.
> I'm not very fond of the idea of returning the status elsewhere and in a
> way that is not intrinsically connected with the action that has
> determined the change of state.
>
> AFAIK *alloc functions return either the memory requested or NULL.
> I wonder how realistic this case is.

OK.

>
> [...]
>
>>> +	if (unlikely(!(pool && n && size)))
>> Has this code been run through sparse?
> I use "make C=1 W=1"

OK.

>
>> I know one thing sparse looks at
>> is if NULL is being treated like a 0, and sparse does check cases when 0
>> is being used in place for NULL for pointer checks, and I'm wondering if
>> that line of code would pass.
> It's a logical AND: wouldn't NULL translate to false, rather 0?
> I can add an explicit check against NULL, it's probably more readable
> too, but I don't think that the current construct treats NULL as 0.

If it passes sparse, I think it's fine.

>
> [...]
>
>>> +	if (unlikely(pool == NULL || s == NULL))
>> Here, the right check is being done, so at the very least, I would make
>> the last line I commented on the same as this one for code continuity.
> ok
>
> [...]
>
>>> +	if (unlikely(!(pool && chunk)))
>> Please make this check the same as the last line I commented on,
>> especially since it's the same struct being checked.
> yes

OK :-)


>
> [...]
>
>>> +	if (!name) {
>>> +		WARN_ON(1);
>> ??A  Maybe the name check should be in WARN_ON()?
> true :-(

OK.


>
> [...]
>
>>> +	if (unlikely(!req_size || !pool))
>> same unlikely() check problem mentioned before.
>>> +		return -1;
>> Can we use an errno value instead for better diagnosibility?
>>> +
>>> +	data = pool->data;
>>> +
>>> +	if (data == NULL)
>>> +		return -1;
>> Same here (ENOMEM or ENXIO comes to mind).
>>> +
>>> +	if (unlikely(data->protected)) {
>>> +		WARN_ON(1);
>> Maybe re-write this with the check inside WARN_ON()?
>>> +		return -1;
>> Same here, how about a different errno value for this case?
> yes, to all of the above

OK.

>
> [...]
>
>>> +static void pmalloc_chunk_set_protection(struct gen_pool *pool,
>>> +
>>> +					 struct gen_pool_chunk *chunk,
>>> +					 void *data)
>>> +{
>>> +	const bool *flag = data;
>>> +	size_t chunk_size = chunk->end_addr + 1 - chunk->start_addr;
>>> +	unsigned long pages = chunk_size / PAGE_SIZE;
>>> +
>>> +	BUG_ON(chunk_size & (PAGE_SIZE - 1));
>> Re-think WARN_ON() for BUG_ON()?A  And also check chunk as well, as it's
>> being used below?
> ok
>
>>> +
>>> +	if (*flag)
>>> +		set_memory_ro(chunk->start_addr, pages);
>>> +	else
>>> +		set_memory_rw(chunk->start_addr, pages);
>>> +}
>>> +
>>> +static int pmalloc_pool_set_protection(struct gen_pool *pool, bool protection)
>>> +{
>>> +	struct pmalloc_data *data;
>>> +	struct gen_pool_chunk *chunk;
>>> +
>>> +	if (unlikely(!pool))
>>> +		return -EINVAL;
>> This is example of what I'd perfer seeing in check_alloc_params().
> yes
>
>>> +
>>> +	data = pool->data;
>>> +
>>> +	if (unlikely(!data))
>>> +		return -EINVAL;
>> ENXIO or EIO or ENOMEM sound better?
> Why? At least based on he description from errno-base.h, EINVAL seemed
> the most appropriate:
>
> #define	EIO		 5	/* I/O error */
> #define	ENXIO		 6	/* No such device or address */
> #define	ENOMEM		12	/* Out of memory */
>
> #define	EINVAL		22	/* Invalid argument */
>
> If I was really pressed to change it, I'd rather pick:
>
> #define	EFAULT		14	/* Bad address */
>

OK, very reasonable.


>>> +
>>> +	if (unlikely(data->protected == protection)) {
>>> +		WARN_ON(1);
>> Better to put the check inside WARN_ON, me thinks...
> yes, I have no idea why I wrote it like that  :-(

No worries :-).


>
>>> +		return 0;
>>> +	}
>>> +
>>> +	data->protected = protection;
>>> +	list_for_each_entry(chunk, &(pool)->chunks, next_chunk)
>>> +		pmalloc_chunk_set_protection(pool, chunk, &protection);
>>> +	return 0;
>>> +}
>>> +
>>> +int pmalloc_protect_pool(struct gen_pool *pool)
>>> +{
>>> +	return pmalloc_pool_set_protection(pool, true);
>> Is pool == NULL being checked somewhere, similar to previous functions
>> in this patch?
> right.

OK.


>
>>> +}
>>> +
>>> +
>>> +static void pmalloc_chunk_free(struct gen_pool *pool,
>>> +			       struct gen_pool_chunk *chunk, void *data)
>>> +{
>> Wat is 'data' being used for? Looks unused.A  Should parameters be
>> checked, like other ones?
>
> This is the iterator that is passed to genalloc
> genalloc defines the format for the iterator, because it *will* want to
> pass the pointer to the opaque data structure.

OK.


>
>>> +	untag_chunk(chunk);
>>> +	gen_pool_flush_chunk(pool, chunk);
>>> +	vfree_atomic((void *)chunk->start_addr);
>>> +}
>>> +
>>> +
>>> +int pmalloc_destroy_pool(struct gen_pool *pool)
>>> +{
>>> +	struct pmalloc_data *data;
>>> +
>>> +	if (unlikely(pool == NULL))
>>> +		return -EINVAL;
>>> +
>>> +	data = pool->data;
>>> +
>>> +	if (unlikely(data == NULL))
>>> +		return -EINVAL;
>> I'd use a different errno value since you already used it for pool.
> Thinking more about this, how about collapsing them?
> I do need to check for the value of data, before I dereference it,
> however the causes are very different:
>
> * wrong pool pointer - definitely possible
> * corrupted data structure (data member overwritten) - highly unlikely


That sounds good.


>>> +
>>> +	mutex_lock(&pmalloc_mutex);
>>> +	list_del(&data->node);
>>> +	mutex_unlock(&pmalloc_mutex);
>>> +
>>> +	if (likely(data->pool_kobject))
>>> +		pmalloc_disconnect(data, data->pool_kobject);
>>> +
>>> +	pmalloc_pool_set_protection(pool, false);
>>> +	gen_pool_for_each_chunk(pool, pmalloc_chunk_free, NULL);
>>> +	gen_pool_destroy(pool);
>>> +	kfree(data);
>> Does data need to be set to NULL in this case, as data is a member of
>> pool (pool->data)?A  I'm worried about dangling pointer scenarios which
>> probably isn't good for security modules?
> The pool was destroyed in the previous step.
> There is nothing left that can be set to NULL.
> Unless we are expecting an use-after-free of the pool structure.
> But everything it was referring to is gone as well.
>
> If we really want to go after this case, then basically everything that
> has been allocated should be poisoned before being freed.
>
> Isn't it a bit too much?

I'd ask one of the maintainers (James or Serge) if it's too much, this 
is the Linux Security Module after all.A  But it also could be a kernel 
hardening thing to do?

>
>>> +	return 0;
>>> +}
>>> +
>>> +/*
>>> + * When the sysfs is ready to receive registrations, connect all the
>>> + * pools previously created. Also enable further pools to be connected
>>> + * right away.
>>> + */
>>> +static int __init pmalloc_late_init(void)
>>> +{
>>> +	struct pmalloc_data *data, *n;
>>> +
>>> +	pmalloc_kobject = kobject_create_and_add("pmalloc", kernel_kobj);
>>> +
>>> +	mutex_lock(&pmalloc_mutex);
>>> +	pmalloc_list = &pmalloc_final_list;
>>> +
>>> +	if (likely(pmalloc_kobject != NULL)) {
>>> +		list_for_each_entry_safe(data, n, &pmalloc_tmp_list, node) {
>>> +			list_move(&data->node, &pmalloc_final_list);
>>> +			pmalloc_connect(data);
>>> +		}
>>> +	}
>> It would be nice to have the init() return an error value in case of
>> failure.
> ok
>
> --
> igor

Thanks,
Jay


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
