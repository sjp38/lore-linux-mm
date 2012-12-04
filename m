Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 405326B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 05:46:17 -0500 (EST)
Message-ID: <50BDD46D.9070404@oracle.com>
Date: Tue, 04 Dec 2012 18:46:05 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/3] memcg: refactor pages allocation/free for swap_cgroup
References: <50BDB5E0.7030906@oracle.com> <50BDB5EB.70909@oracle.com> <20121204101137.GA1343@dhcp22.suse.cz>
In-Reply-To: <20121204101137.GA1343@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

Hi Michal,

Thanks for your prompt response.
On 12/04/2012 06:11 PM, Michal Hocko wrote:
> On Tue 04-12-12 16:35:55, Jeff Liu wrote:
> [...]
>>  /*
>> - * allocate buffer for swap_cgroup.
>> + * Allocate pages for swap_cgroup upon a given type.
>>   */
>> -static int swap_cgroup_prepare(int type)
>> +static int swap_cgroup_alloc_pages(int type)
> 
> I am not sure this name is better. The whole point of the function is
> the prepare swap accounting internals. Yeah we are allocating here as
> well but this is not that important.
I spent nearly half time of writing these patches to figure out a couple
of meaningful names for pages allocation/free, but...

Maybe I should keeping the old name(swap_cgroup_prepare()) unchanged and
don't introduce the corresponding swap_cgroup_free_pages(), since this
helper only called by swap_cgroup_destroy() in my current implementation.

> It also feels strange that the function name suggests we allocate pages
> but none of them are returned.
Yep, generally, only those functions with pages allocated and returned
should be named as xxxx_alloc_pages_xxx(), it really looks strange so.

> 
>>  {
>> -	struct page *page;
>>  	struct swap_cgroup_ctrl *ctrl;
>> -	unsigned long idx, max;
>> +	unsigned long i, length, max;
>>  
>>  	ctrl = &swap_cgroup_ctrl[type];
>> -
>> -	for (idx = 0; idx < ctrl->length; idx++) {
>> -		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
>> +	length = ctrl->length;
>> +	for (i = 0; i < length; i++) {
>> +		struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
>>  		if (!page)
>>  			goto not_enough_page;
>> -		ctrl->map[idx] = page;
>> +		ctrl->map[i] = page;
>>  	}
>> +
>>  	return 0;
>> +
>>  not_enough_page:
>> -	max = idx;
>> -	for (idx = 0; idx < max; idx++)
>> -		__free_page(ctrl->map[idx]);
>> +	max = i;
>> +	for (i = 0; i < max; i++)
>> +		__free_page(ctrl->map[i]);
>>  
>>  	return -ENOMEM;
>>  }
> 
> Is there any reason for the local variables rename exercise?
> I really do not like it.
Ah, I can not recall why I renamed it at that time, will change it
back in the next round of post.
> 
>>  
>> +static void swap_cgroup_free_pages(int type)
>> +{
>> +	struct swap_cgroup_ctrl *ctrl;
>> +	struct page **map;
>> +
>> +	ctrl = &swap_cgroup_ctrl[type];
>> +	map = ctrl->map;
>> +	if (map) {
>> +		unsigned long length = ctrl->length;
>> +		unsigned long i;
>> +
>> +		for (i = 0; i < length; i++) {
>> +			struct page *page = map[i];
>> +			if (page)
>> +				__free_page(page);
>> +		}
>> +	}
>> +}
>> +
> 
> This function is not used in this patch so I would suggest moving it
> into the #2.
Ok. Maybe it will be merged into swap_cgroup_destroy() as is mentioned
above.
> 
>>  static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
>>  					struct swap_cgroup_ctrl **ctrlp)
>>  {
>> @@ -477,7 +497,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>>  	ctrl->length = length;
>>  	ctrl->map = array;
>>  	spin_lock_init(&ctrl->lock);
>> -	if (swap_cgroup_prepare(type)) {
>> +	if (swap_cgroup_alloc_pages(type)) {
>>  		/* memory shortage */
>>  		ctrl->map = NULL;
>>  		ctrl->length = 0;
> 
Thanks Again!

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
