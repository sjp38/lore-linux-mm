Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7B9726B0033
	for <linux-mm@kvack.org>; Sun, 25 Aug 2013 19:24:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 09:13:28 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 208B93578051
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:23:54 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7PNNXHD66912390
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:23:43 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7PNNh3x026874
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:23:44 +1000
Date: Mon, 26 Aug 2013 07:23:42 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 5/7] mm/hwpoison: don't set migration type twice to
 avoid hold heavy contend zone->lock
Message-ID: <20130825232341.GA22730@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377253841-17620-5-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377268598-md0gqi8g-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377268598-md0gqi8g-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 23, 2013 at 10:36:38AM -0400, Naoya Horiguchi wrote:
>On Fri, Aug 23, 2013 at 06:30:39PM +0800, Wanpeng Li wrote:
>> v1 -> v2:
>> 	* add more explanation in patch description.
>> 
>> Set pageblock migration type will hold zone->lock which is heavy contended
>> in system to avoid race. However, soft offline page will set pageblock
>> migration type twice during get page if the page is in used, not hugetlbfs
>> page and not on lru list. There is unnecessary to set the pageblock migration
>> type and hold heavy contended zone->lock again if the first round get page
>> have already set the pageblock to right migration type.
>> 
>> The trick here is migration type is MIGRATE_ISOLATE. There are other two parts 
>> can change MIGRATE_ISOLATE except hwpoison. One is memory hoplug, however, we 
>> hold lock_memory_hotplug() which avoid race. The second is CMA which umovable 
>> page allocation requst can't fallback to. So it's safe here.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/memory-failure.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 297965e..f357c91 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1426,7 +1426,8 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
>>  	 * was free. This flag should be kept set until the source page
>>  	 * is freed and PG_hwpoison on it is set.
>>  	 */
>> -	set_migratetype_isolate(p, true);
>> +	if (get_pageblock_migratetype(p) == MIGRATE_ISOLATE)
>> +		set_migratetype_isolate(p, true);
>
>Do you really mean "we set MIGRATE_ISOLATE only if it's already set?"
>

Ouch, it's my fault, I will fix it in next version. ;-)

Regards,
Wanpeng Li 

>Thanks,
>Naoya Horiguchi
>
>>  	/*
>>  	 * When the target page is a free hugepage, just remove it
>>  	 * from free hugepage list.
>> -- 
>> 1.8.1.2
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
