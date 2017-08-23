Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC110280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 02:47:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x6so1359124wme.4
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 23:47:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 199si840502wma.60.2017.08.22.23.47.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 23:47:40 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
Date: Wed, 23 Aug 2017 08:47:37 +0200
MIME-Version: 1.0
In-Reply-To: <20170724123843.GH25221@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On 07/24/2017 02:38 PM, Michal Hocko wrote:
> On Thu 20-07-17 15:40:26, Vlastimil Babka wrote:
>> In init_pages_in_zone() we currently use the generic set_page_owner() function
>> to initialize page_owner info for early allocated pages. This means we
>> needlessly do lookup_page_ext() twice for each page, and more importantly
>> save_stack(), which has to unwind the stack and find the corresponding stack
>> depot handle. Because the stack is always the same for the initialization,
>> unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
>> repeated lookup_page_ext().
> 
> Yes this looks like an improvement but I have to admit that I do not
> really get why we even do save_stack at all here. Those pages might
> got allocated from anywhere so we could very well provide a statically
> allocated "fake" stack trace, no?

We could, but it's much simpler to do it this way than try to extend
stack depot/stack saving to support creating such fakes. Would it be
worth the effort?

> Memory allocated for the stackdepot storage can be tracked inside
> depot_alloc_stack as well I guess (again with a statically preallocated
> storage).

I'm not sure I get your point here? The pages we have to "fake" are not
just the stackdepot storage itself, but everything that has been
allocated before the page_owner is initialized.

>> This can significantly reduce boot times with page_owner=on on large machines,
>> especially for kernels built without frame pointer, where the stack unwinding
>> is noticeably slower.
> 
> Some numbders would be really nice here

Well, the problem was that on a 3TB machine I just gave up and rebooted
it after ~30 minutes of waiting for the init to finish. After this patch
it was maybe 5 minutes.

>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/page_owner.c | 19 ++++++++++++++++++-
>>  1 file changed, 18 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_owner.c b/mm/page_owner.c
>> index 401feb070335..5aa21ca237d9 100644
>> --- a/mm/page_owner.c
>> +++ b/mm/page_owner.c
>> @@ -183,6 +183,20 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
>>  	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
>>  }
>>  
>> +static void __set_page_owner_init(struct page_ext *page_ext,
>> +					depot_stack_handle_t handle)
>> +{
>> +	struct page_owner *page_owner;
>> +
>> +	page_owner = get_page_owner(page_ext);
>> +	page_owner->handle = handle;
>> +	page_owner->order = 0;
>> +	page_owner->gfp_mask = 0;
>> +	page_owner->last_migrate_reason = -1;
>> +
>> +	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
>> +}
> 
> Do we need to duplicated a part of __set_page_owner? Can we pull out
> both owner and handle out __set_page_owner?

I wanted to avoid overhead in __set_page_owner() by introducing extra
shared function, but I'll check if that can be helped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
