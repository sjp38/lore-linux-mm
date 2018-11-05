Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01A46B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:41:48 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id a1-v6so2492659ljk.7
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:41:48 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 25-v6si20798083ljg.47.2018.11.05.02.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 02:41:47 -0800 (PST)
Subject: Re: [PATCH 2/2] mm: avoid unnecessary swap_info_struct allocation
References: <a24bf353-8715-2bee-d0fa-96ca06c5b69f@virtuozzo.com>
 <87sh0gbau6.fsf@yhuang-dev.intel.com>
 <bf132d36-e9cd-8c27-fffa-f3e734065aec@virtuozzo.com>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <94e89c5b-a7c3-2b5f-d509-df29fb07c53c@virtuozzo.com>
Date: Mon, 5 Nov 2018 13:41:39 +0300
MIME-Version: 1.0
In-Reply-To: <bf132d36-e9cd-8c27-fffa-f3e734065aec@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

I was wrong, openVz blocks sys_swapon/swapoff syscalls inside containers.
Our kernel just emulates /proc/swaps output inside containers,
it is enough for 'swapon' userspace to do not fail and show required info.

So I do not have any special arguments for proposed patch.

On 11/5/18 8:19 AM, Vasily Averin wrote:
> On 11/5/18 3:57 AM, Huang, Ying wrote:
>> Vasily Averin <vvs@virtuozzo.com> writes:
>>
>>> Currently newly allocated swap_info_struct can be quickly freed.
>>> This patch avoid uneccessary high-order page allocation and helps
>>> to decrease the memory pressure.
>>
>> I think swapon/swapoff are rare operations, so it will not increase the
>> memory pressure much.
> 
> You are right, typically it should not affect usual nodes.
> 
> It's OpenVz-specific usecase.
> 
> OpenVz allows hosters to run hundreds of non-trusted containers per node.
> Our containers have enabled "virtual swap" functionality, 
> and container's owners can call sys_swapon without any limits.
> Containers can be restarted in any time and we would like to 
> decrease number of unnecessary high-order memory allocations.
> 
>>> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
>>> ---
>>>  mm/swapfile.c | 18 +++++++++++++-----
>>>  1 file changed, 13 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>>> index 8688ae65ef58..53ec2f0cdf26 100644
>>> --- a/mm/swapfile.c
>>> +++ b/mm/swapfile.c
>>> @@ -2809,14 +2809,17 @@ late_initcall(max_swapfiles_check);
>>>  
>>>  static struct swap_info_struct *alloc_swap_info(void)
>>>  {
>>> -	struct swap_info_struct *p;
>>> +	struct swap_info_struct *p = NULL;
>>>  	unsigned int type;
>>>  	int i;
>>> +	bool force_alloc = false;
>>>  
>>> -	p = kvzalloc(sizeof(*p), GFP_KERNEL);
>>> -	if (!p)
>>> -		return ERR_PTR(-ENOMEM);
>>> -
>>> +retry:
>>> +	if (force_alloc) {
>>> +		p = kvzalloc(sizeof(*p), GFP_KERNEL);
>>> +		if (!p)
>>> +			return ERR_PTR(-ENOMEM);
>>> +	}
>>>  	spin_lock(&swap_lock);
>>>  	for (type = 0; type < nr_swapfiles; type++) {
>>>  		if (!(swap_info[type]->flags & SWP_USED))
>>> @@ -2828,6 +2831,11 @@ static struct swap_info_struct *alloc_swap_info(void)
>>>  		return ERR_PTR(-EPERM);
>>>  	}
>>>  	if (type >= nr_swapfiles) {
>>> +		if (!force_alloc) {
>>> +			force_alloc = true;
>>> +			spin_unlock(&swap_lock);
>>> +			goto retry;
>>> +		}
>>>  		p->type = type;
>>>  		swap_info[type] = p;
>>>  		/*
>>
