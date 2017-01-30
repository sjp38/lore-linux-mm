Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03F506B026C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:16:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so204231734pfd.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:16:24 -0800 (PST)
Received: from smtpbg298.qq.com (smtpbg298.qq.com. [184.105.67.102])
        by mx.google.com with ESMTPS id v187si8680294pgv.219.2017.01.30.07.16.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 07:16:24 -0800 (PST)
Subject: Re: [RFC v2 PATCH] mm/hotplug: enable memory hotplug for non-lru
 movable pages
References: <1485327585-62872-1-git-send-email-xieyisheng1@huawei.com>
 <20170126094303.GE6590@dhcp22.suse.cz>
From: Yisheng Xie <ysxie@foxmail.com>
Message-ID: <588F584F.5080904@foxmail.com>
Date: Mon, 30 Jan 2017 23:14:23 +0800
MIME-Version: 1.0
In-Reply-To: <20170126094303.GE6590@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, n-horiguchi@ah.jp.nec.com, minchan@kernel.org, qiuxishi@huawei.com, guohanjun@huawei.com


hi Michal,
Thank you for reviewing and sorry for late reply.

On 01/26/2017 05:43 PM, Michal Hocko wrote:
> On Wed 25-01-17 14:59:45, Yisheng Xie wrote:
>
>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
> @@ -1531,6 +1531,16 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  					pfn = round_up(pfn + 1,
>  						1 << compound_order(page)) - 1;
>  			}
> +			/*
> +			 * check __PageMovable in lock_page to avoid miss some
> +			 * non-lru movable pages at race condition.
> +			 */
> +			lock_page(page);
> +			if (__PageMovable(page)) {
> +				unlock_page(page);
> +				return pfn;
> +			}
> +			unlock_page(page);
> This doesn't make any sense to me. __PageMovable can change right after
> you drop the lock so why the race matters? If we cannot tolerate races
> then the above doesn't work and if we can then taking the lock is
> pointless.
hmm, for PageLRU check may also race without lru-locki 1/4 ?
I think it is ok to check __PageMovable without lock_page, here.

>>  		}
>>  	}
>>  	return 0;
>> @@ -1600,21 +1610,25 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>>  		if (!get_page_unless_zero(page))
>>  			continue;
>>  		/*
>> -		 * We can skip free pages. And we can only deal with pages on
>> -		 * LRU.
>> +		 * We can skip free pages. And we can deal with pages on
>> +		 * LRU and non-lru movable pages.
>>  		 */
>> -		ret = isolate_lru_page(page);
>> +		if (PageLRU(page))
>> +			ret = isolate_lru_page(page);
>> +		else
>> +			ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
> we really want to propagate the proper error code to the caller.
Yes , I make the same mistake again. Really sorry about that.

Maybe I can rewrite the isolate_movable_page to let it return int as isolate_lru_page
do in this patchset :)

Thanks
Yisheng Xie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
