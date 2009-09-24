Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 953766B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:55:50 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1484144bwz.38
        for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:55:57 -0700 (PDT)
Message-ID: <4ABBA45A.8010305@vflare.org>
Date: Thu, 24 Sep 2009 22:24:50 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] virtual block device driver (ramzswap)
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>	<1253595414-2855-3-git-send-email-ngupta@vflare.org> <20090924141135.833474ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090924141135.833474ad.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>


On 09/24/2009 10:41 AM, KAMEZAWA Hiroyuki wrote:
> On Tue, 22 Sep 2009 10:26:53 +0530
> Nitin Gupta <ngupta@vflare.org> wrote:
> 
> <snip>
>> +	if (unlikely(clen > max_zpage_size)) {
>> +		if (rzs->backing_swap) {
>> +			mutex_unlock(&rzs->lock);
>> +			fwd_write_request = 1;
>> +			goto out;
>> +		}
>> +
>> +		clen = PAGE_SIZE;
>> +		page_store = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
> Here, and...
> 
>> +		if (unlikely(!page_store)) {
>> +			mutex_unlock(&rzs->lock);
>> +			pr_info("Error allocating memory for incompressible "
>> +				"page: %u\n", index);
>> +			stat_inc(rzs->stats.failed_writes);
>> +			goto out;
>> +		}
>> +
>> +		offset = 0;
>> +		rzs_set_flag(rzs, index, RZS_UNCOMPRESSED);
>> +		stat_inc(rzs->stats.pages_expand);
>> +		rzs->table[index].page = page_store;
>> +		src = kmap_atomic(page, KM_USER0);
>> +		goto memstore;
>> +	}
>> +
>> +	if (xv_malloc(rzs->mem_pool, clen + sizeof(*zheader),
>> +			&rzs->table[index].page, &offset,
>> +			GFP_NOIO | __GFP_HIGHMEM)) {
> 
> Here.
>     
> Do we need to wait until here for detecting page-allocation-failure ?
> Detecting it here means -EIO for end_swap_bio_write()....unhappy
> ALERT messages etc..
> 
> Can't we add a hook to get_swap_page() for preparing this ("do we have
> enough pool?") and use only GFP_ATOMIC throughout codes ?
> (memory pool for this swap should be big to some extent.)
>

Yes, we do need to wait until this step for detecting alloc failure since
we don't really know when pool grow will (almost) surely wail.
What we can probably do is, hook into OOM notify chain (oom_notify_list)
and whenever we get this callback, we can start sending pages directly
to backing swap and do not even attempt to do any allocation.


 
>>From my user support experience for heavy swap customers,  extra memory allocation for swapping out is just bad...in many cases.
> (*) I know GFP_IO works well to some extent.
> 

We cannot use GFP_IO here as it can cause a deadlock:
ramzswap alloc() --> not enough memory, try to reclaim some --> swap out ...
... some pages to ramzswap --> ramzswap alloc()

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
