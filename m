Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 29EDA6B0075
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:02:05 -0400 (EDT)
Message-ID: <4FC4F273.6060807@parallels.com>
Date: Tue, 29 May 2012 19:59:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 15/28] slub: always get the cache from its page in
 kfree
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-16-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290939540.4666@router.home>
In-Reply-To: <alpine.DEB.2.00.1205290939540.4666@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/29/2012 06:42 PM, Christoph Lameter wrote:
> On Fri, 25 May 2012, Glauber Costa wrote:
>
>> struct page already have this information. If we start chaining
>> caches, this information will always be more trustworthy than
>> whatever is passed into the function
>
> Yes but the lookup of the page struct also costs some cycles. SLAB in
> !NUMA mode and SLOB avoid these lookups and can improve their freeing
> speed because of that.

But for our case, I don't really see a way around. What I can do, is 
wrap it further, so when we're not using it, code goes exactly the same 
way as before, instead of always calculating the page. Would it be better?

>> diff --git a/mm/slub.c b/mm/slub.c
>> index 0eb9e72..640872f 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -2598,10 +2598,14 @@ redo:
>>   void kmem_cache_free(struct kmem_cache *s, void *x)
>>   {
>>   	struct page *page;
>> +	bool slab_match;
>>
>>   	page = virt_to_head_page(x);
>>
>> -	slab_free(s, page, x, _RET_IP_);
>> +	slab_match = (page->slab == s) | slab_is_parent(page->slab, s);
>> +	VM_BUG_ON(!slab_match);
>
> Why add a slab_match bool if you do not really need it?

style. I find aux variables a very human readable way to deal with the 
80-col limitation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
