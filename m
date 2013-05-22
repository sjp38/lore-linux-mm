Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 46B9F6B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:39:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 23 May 2013 09:32:31 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BC7852BB0051
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:38:57 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4MNOdWk11534390
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:24:39 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4MNctF8004129
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:38:56 +1000
Date: Thu, 23 May 2013 07:38:54 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Message-ID: <20130522233854.GA13972@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130522104937.GC19989@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130522104937.GC19989@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 22, 2013 at 12:49:37PM +0200, Michal Hocko wrote:
>On Wed 22-05-13 17:29:27, Wanpeng Li wrote:
>> Logic memory-remove code fails to correctly account the Total High Memory 
>> when a memory block which contains High Memory is offlined as shown in the
>> example below. The following patch fixes it.
>> 
>> cat /proc/meminfo 
>> MemTotal:        7079452 kB
>> MemFree:         5805976 kB
>> Buffers:           94372 kB
>> Cached:           872000 kB
>> SwapCached:            0 kB
>> Active:           626936 kB
>> Inactive:         519236 kB
>> Active(anon):     180780 kB
>> Inactive(anon):   222944 kB
>> Active(file):     446156 kB
>> Inactive(file):   296292 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> HighTotal:       7294672 kB
>> HighFree:        5181024 kB
>> LowTotal:       4294752076 kB
>> LowFree:          624952 kB
>
>Ok, so the HighTotal is higher than MemTotal but it would have been more
>straightforward to show number of HighTotal before hotremove, show how
>much memory has been removed and the number after.
>
>It is not clear which stable kernels need this fix as well.
>

THanks for your review, Michal, I will update soon. ;-)

>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Anyway
>Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
>with a nit pick bellow
>
>> ---
>>  mm/page_alloc.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 98cbdf6..80474b2 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6140,6 +6140,10 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>  		list_del(&page->lru);
>>  		rmv_page_order(page);
>>  		zone->free_area[order].nr_free--;
>> +#ifdef CONFIG_HIGHMEM
>> +		if (PageHighMem(page))
>> +			totalhigh_pages -= 1 << order;
>> +#endif
>
>ifdef shouldn't be necessary as PageHighMem should default to false for
>!CONFIG_HIGHMEM AFAICS.
>
>>  		for (i = 0; i < (1 << order); i++)
>>  			SetPageReserved((page+i));
>>  		pfn += (1 << order);
>> -- 
>> 1.8.1.2
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
