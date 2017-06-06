Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70F966B03BC
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 08:24:29 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i42so11416882otb.0
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 05:24:29 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j20si3885172oih.138.2017.06.06.05.24.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 05:24:28 -0700 (PDT)
Subject: Re: [PATCH 2/5] Protectable Memory Allocator
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
 <20170605192216.21596-3-igor.stoppa@huawei.com>
 <201706060444.v564iWds024768@www262.sakura.ne.jp>
 <a4ef229f-0dce-fa15-117b-2c7e904be7e7@huawei.com>
 <201706062108.JDD17143.MOQFFVtHLJOFOS@I-love.SAKURA.ne.jp>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a9c0b60b-d540-785b-3455-d35ae051b891@huawei.com>
Date: Tue, 6 Jun 2017 15:23:12 +0300
MIME-Version: 1.0
In-Reply-To: <201706062108.JDD17143.MOQFFVtHLJOFOS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


On 06/06/17 15:08, Tetsuo Handa wrote:
> Igor Stoppa wrote:
>>>> +struct pmalloc_node {
>>>> +	struct hlist_node nodes_list;
>>>> +	atomic_t used_words;
>>>> +	unsigned int total_words;
>>>> +	__PMALLOC_ALIGNED align_t data[];
>>>> +};
>>>
>>> Is this __PMALLOC_ALIGNED needed? Why not use "long" and "BITS_PER_LONG" ?
>>
>> In an earlier version I actually asked the same question.
>> It is currently there because I just don't know enough about various
>> architectures. The idea of having "align_t" was that it could be tied
>> into what is the most desirable alignment for each architecture.
>> But I'm actually looking for advise on this.
> 
> I think that let the compiler use natural alignment is OK.

On a 64 bit machine the preferred alignment might be either 32 or 64,
depending on the application. How can the compiler choose?


>>> You need to check for node != NULL before dereference it.
>>
>> So, if I understood correctly, there shouldn't be a case where node is
>> NULL, right?
>> Unless it has been tampered/damaged. Is that what you mean?
> 
> I meant to say
> 
> +	node = __pmalloc_create_node(req_words);
> // this location.
> +	starting_word = atomic_fetch_add(req_words, &node->used_words);

argh, yes


>>>> +const char *__pmalloc_check_object(const void *ptr, unsigned long n)
>>>> +{
>>>> +	unsigned long p;
>>>> +
>>>> +	p = (unsigned long)ptr;
>>>> +	n += (unsigned long)ptr;
>>>> +	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
>>>> +		if (is_vmalloc_addr((void *)p)) {
>>>> +			struct page *page;
>>>> +
>>>> +			page = vmalloc_to_page((void *)p);
>>>> +			if (!(page && PagePmalloc(page)))
>>>> +				return msg;
>>>> +		}
>>>> +	}
>>>> +	return NULL;
>>>> +}
>>>
>>> I feel that n is off-by-one if (ptr + n) % PAGE_SIZE == 0
>>> according to check_page_span().
>>
>> It seems to work. If I am missing your point, could you please
>> use the same format of the example I made, to explain me?
> 
> If ptr == NULL and n == PAGE_SIZE so that (ptr + n) % PAGE_SIZE == 0,
> this loop will access two pages (one page containing p == 0 and another
> page containing p == PAGE_SIZE) when this loop should access only one
> page containing p == 0. When checking n bytes, it's range is 0 to n - 1.

oh, so:

p = (unsigned long) ptr;
n = p + n - 1;


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
