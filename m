Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2AB436B00DB
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:44:30 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 27 May 2013 20:41:38 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 74D912CE8054
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:44:23 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4QNTxe524641618
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:30:00 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4QNiLh3008827
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:44:22 +1000
Date: Mon, 27 May 2013 07:44:20 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 1/6] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Message-ID: <20130526234419.GA980@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <51A21B9A.1090206@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51A21B9A.1090206@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Jiang <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Sun, May 26, 2013 at 10:26:34PM +0800, Liu Jiang wrote:
>On Sun 26 May 2013 01:58:36 PM CST, Wanpeng Li wrote:
>> Changelog:
>>  v1 -> v2:
>> 	* show number of HighTotal before hotremove
>> 	* remove CONFIG_HIGHMEM
>> 	* cc stable kernels
>> 	* add Michal reviewed-by
>>
>> Logic memory-remove code fails to correctly account the Total High Memory
>> when a memory block which contains High Memory is offlined as shown in the
>> example below. The following patch fixes it.
>>
>> Stable for 2.6.24+.
>>
>> Before logic memory remove:
>>
>> MemTotal:        7603740 kB
>> MemFree:         6329612 kB
>> Buffers:           94352 kB
>> Cached:           872008 kB
>> SwapCached:            0 kB
>> Active:           626932 kB
>> Inactive:         519216 kB
>> Active(anon):     180776 kB
>> Inactive(anon):   222944 kB
>> Active(file):     446156 kB
>> Inactive(file):   296272 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> HighTotal:       7294672 kB
>> HighFree:        5704696 kB
>> LowTotal:         309068 kB
>> LowFree:          624916 kB
>>
>> After logic memory remove:
>>
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
>>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/page_alloc.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 98cbdf6..23b921f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6140,6 +6140,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>  		list_del(&page->lru);
>>  		rmv_page_order(page);
>>  		zone->free_area[order].nr_free--;
>> +		if (PageHighMem(page))
>> +			totalhigh_pages -= 1 << order;
>>  		for (i = 0; i < (1 << order); i++)
>>  			SetPageReserved((page+i));
>>  		pfn += (1 << order);
>
>Hi Wanpeng,
>         The memory hotplug code adjusts totalram_pages, 
>totalhigh_pages,  zone->present_pages
>and zone->managed_pages all in memory_hotplug.c, so suggest to move 
>this into memory_hotplug.c
>too.
>          One of my patch fixes this issue in another way, please refer 
>to:
>http://marc.info/?l=linux-mm&m=136957578620221&w=2

Greate to see your effort. ;-)

>Regards!
>Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
