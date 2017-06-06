Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24C2B6B03AC
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:43:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v102so14892515wrc.8
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:43:26 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t2si7897492wrb.3.2017.06.06.04.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 04:43:24 -0700 (PDT)
Subject: Re: [PATCH 2/5] Protectable Memory Allocator
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
 <20170605192216.21596-3-igor.stoppa@huawei.com>
 <201706060444.v564iWds024768@www262.sakura.ne.jp>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a4ef229f-0dce-fa15-117b-2c7e904be7e7@huawei.com>
Date: Tue, 6 Jun 2017 14:42:12 +0300
MIME-Version: 1.0
In-Reply-To: <201706060444.v564iWds024768@www262.sakura.ne.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Hi,
thanks a lot for the review. My answers are in-line below.
I have rearranged your comments because I wasn't sure how to reply to
them inlined.

On 06/06/17 07:44, Tetsuo Handa wrote:
> Igor Stoppa wrote:

[...]

> As far as I know, not all CONFIG_MMU=y architectures provide
> set_memory_ro()/set_memory_rw().

I'll follow up on this in the existing separate thread.

[...]

>> +struct pmalloc_node {
>> +	struct hlist_node nodes_list;
>> +	atomic_t used_words;
>> +	unsigned int total_words;
>> +	__PMALLOC_ALIGNED align_t data[];
>> +};
>
> Is this __PMALLOC_ALIGNED needed? Why not use "long" and "BITS_PER_LONG" ?

In an earlier version I actually asked the same question.
It is currently there because I just don't know enough about various
architectures. The idea of having "align_t" was that it could be tied
into what is the most desirable alignment for each architecture.
But I'm actually looking for advise on this.


>> +	size = ((HEADER_SIZE - 1 + PAGE_SIZE) +
>> +		WORD_SIZE * (unsigned long) words) & PAGE_MASK;
> 
>> +	req_words = (((int)size) + WORD_SIZE - 1) / WORD_SIZE;
>
> Please use macros for round up/down.

ok

[...]


> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list) {
> +		starting_word = atomic_fetch_add(req_words, &node->used_words);
> +		if (starting_word + req_words > node->total_words)
> +			atomic_sub(req_words, &node->used_words);
> +		else
> +			goto found_node;
> +	}
> +	rcu_read_unlock();
> 
> You need to check for node != NULL before dereference it.

This was intentionally left out, on the ground that I'm using the kernel
macros for both populating and walking the list.
So, if I understood correctly, there shouldn't be a case where node is
NULL, right?
Unless it has been tampered/damaged. Is that what you mean?


> Also, why rcu_read_lock()/rcu_read_unlock() ? 
> I can't find corresponding synchronize_rcu() etc. in this patch.

oops. Thanks for spotting it.


> pmalloc() won't be hotpath. Enclosing whole using a mutex might be OK.
> If any reason to use rcu, rcu_read_unlock() is missing if came from "goto".

If there are no strong objections, I'd rather fix it and keep it as RCU.
Kees Cook was mentioning the possibility of implementing also
"write seldom" in a similar fashion.
In that case the path is likely to warm up.
It might be premature optimization, but I'd prefer to avoid knowingly
introduce performance issues.
Said this, I agree on the bug you spotted.


>> +const char *__pmalloc_check_object(const void *ptr, unsigned long n)
>> +{
>> +	unsigned long p;
>> +
>> +	p = (unsigned long)ptr;
>> +	n += (unsigned long)ptr;
>> +	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
>> +		if (is_vmalloc_addr((void *)p)) {
>> +			struct page *page;
>> +
>> +			page = vmalloc_to_page((void *)p);
>> +			if (!(page && PagePmalloc(page)))
>> +				return msg;
>> +		}
>> +	}
>> +	return NULL;
>> +}
> 
> I feel that n is off-by-one if (ptr + n) % PAGE_SIZE == 0
> according to check_page_span().

Hmm,
let's say PAGE_SIZE is 0x0100 and PAGE MASK 0xFF00

Here are some cases (N = number of pages found):

 ptr       ptr + n   Pages        Test                  N

0x0005     0x00FF      1     0x0000 <= 0x00FF  true     1
0x0105     0x00FF            0x0100 <= 0x00FF  false    1

0x0005     0x0100      2     0x0000 <= 0x0100  true     1
0x0100     0x0100            0x0100 <= 0x0100  true     2
0x0200     0x0100            0x0200 <= 0x0100  false    2

0x0005     0x01FF      2     0x0000 <= 0x0100  true     1
0x0105     0x01FF            0x0100 <= 0x0100  true     2
0x0205     0x01FF            0x0200 <= 0x0100  false    2

It seems to work. If I am missing your point, could you please
use the same format of the example I made, to explain me?

I might be able to understand better.

>> +int __init pmalloc_init(void)
>> +{
>> +	pmalloc_data = vmalloc(sizeof(struct pmalloc_data));
>> +	if (!pmalloc_data)
>> +		return -ENOMEM;
>> +	INIT_HLIST_HEAD(&pmalloc_data->pools_list_head);
>> +	mutex_init(&pmalloc_data->pools_list_mutex);
>> +	atomic_set(&pmalloc_data->pools_count, 0);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(pmalloc_init);
>
> Why need to call pmalloc_init() from loadable kernel module?
> It has to be called very early stage of boot for only once.

Yes, this is a bug.
Actually I forgot to put in this patch the real call to pmalloc init,
which is in init/main.c, right before the security init.
I should see if I can move it higher, to allow for more early users of
pmalloc.

> Since pmalloc_data is a globally shared variable, why need to
> allocate it dynamically? If it is for randomizing the address
> of pmalloc_data, it does not make sense to continue because
> vmalloc() failure causes subsequent oops.

My idea was to delegate the failure-handling to the caller, which might
be able to take more sensible actions than what I can do in this function.

I see you have already replied in a different thread that the value is
not checked. So I will remove it.


thanks again for the feedback,
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
