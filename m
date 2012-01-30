Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 346BF6B0085
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 11:53:06 -0500 (EST)
Message-ID: <4F26CAD1.2000209@stericsson.com>
Date: Mon, 30 Jan 2012 17:52:33 +0100
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com> <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com> <20120130152237.GS25268@csn.ul.ie>
In-Reply-To: <20120130152237.GS25268@csn.ul.ie>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

Hello Mel,

Thanks for your comments,

On 01/30/2012 04:22 PM, Mel Gorman wrote:
> On Mon, Jan 30, 2012 at 02:33:53PM +0100, Maxime Coquelin wrote:
>> Any allocators might call the PASR Framework for DDR power savings. Currently,
>> only Linux Buddy allocator is patched, but HWMEM and PMEM physically
>> contiguous memory allocators will follow.
>>
>> Linux Buddy allocator porting uses Buddy specificities to reduce the overhead
>> induced by the PASR Framework counter updates. Indeed, the PASR Framework is
>> called only when MAX_ORDER (4MB page blocs by default) buddies are
>> inserted/removed from the free lists.
>>
>> To port PASR FW into a new allocator:
>>
>> * Call pasr_put(phys_addr, size) each time a memory chunk becomes unused.
>> * Call pasr_get(phys_addr, size) each time a memory chunk becomes used.
>>
>>
>> Signed-off-by: Maxime Coquelin<maxime.coquelin@stericsson.com>
>> ---
>>   mm/page_alloc.c |    9 +++++++++
>>   1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 03d8c48..c62fe11 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -57,6 +57,7 @@
>>   #include<linux/ftrace_event.h>
>>   #include<linux/memcontrol.h>
>>   #include<linux/prefetch.h>
>> +#include<linux/pasr.h>
>>
>>   #include<asm/tlbflush.h>
>>   #include<asm/div64.h>
>> @@ -534,6 +535,7 @@ static inline void __free_one_page(struct page *page,
>>   		/* Our buddy is free, merge with it and move up one order. */
>>   		list_del(&buddy->lru);
>>   		zone->free_area[order].nr_free--;
>> +		pasr_kget(buddy, order);
>>   		rmv_page_order(buddy);
>>   		combined_idx = buddy_idx&  page_idx;
>>   		page = page + (combined_idx - page_idx);
> I did not review this series carefully and I know nothing about
> how you implemented PASR support but driver hooks like this in the
> page allocator are heavily frowned upon. It is subject to abuse but
> it adds overhead to the allocator although I note that you avoiding
> putting hooks in the per-cpu page allocator.
I catch your point.
However, adding hooks in the page allocator is the only way I see to 
ensure memory that is accessed is refreshed.

> I note that you hardcode
> it so only PASR can use the hook but it looks like there is no way
> of avoiding that overhead on platforms that do not have PASR if
> it is enabled in the config.
In that RFC patch set, I assumed the PASR would be enabled in the config 
only in case it is used.
If not activated, there is no overhead.

This could of course be improved in next patch set.
>   At a glance, it appears to be doing a
> fair amount of work too - looking up maps, taking locks etc.
Note that we do that work only on MAX_ORDER pages, so it limits the 
overhead.
>   This
> potentially creates a new hot lock because in this paths, we have
> per-zone locking but you are adding a PASR lock into the mix that
> may be more coarse than zone->lock (I didn't check).
Ok.
We might fall in a deadlock if the underlying PASR driver allocates 
something in its apply_mask callback.
However, this callback should be used only to write a register of the 
DDR controller.

> You may be able to use the existing arch_alloc_page() hook and
> call PASR on architectures that support it if and only if PASR is
> present and enabled by the administrator but even this is likely to be
> unpopular as it'll have a measurable performance impact on platforms
> with PASR (not to mention the PASR lock will be even heavier as it'll
> now be also used for per-cpu page allocations). To get the hook you
> want, you'd need to show significant benefit before they were happy with
> the hook.
Your proposal sounds good.
AFAIK, per-cpu allocation maximum size is 32KB. Please correct me if I'm 
wrong.
Since pasr_kget/kput() calls the PASR framework only on MAX_ORDER 
allocations, we wouldn't add any locking risks nor contention compared 
to current patch.
I will update the patch set using  arch_alloc/free_page().

>
> What is more likely is that you will get pushed to doing something like
> periodically scanning memory as part of a separate power management
> module and calling into PASR if regions of memory that are found that
> can be powered down in some ways.
With this solution, we need in any case to add some hooks in the 
allocator to ensure the pages being allocated are refreshed.

Best regards,
Maxime

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
