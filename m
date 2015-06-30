Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B23B6B006C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 22:54:27 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so1077442pac.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 19:54:26 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id nx9si33950250pbb.73.2015.06.29.19.54.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 19:54:26 -0700 (PDT)
Message-ID: <559202E2.8060609@huawei.com>
Date: Tue, 30 Jun 2015 10:45:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 2/8] mm: introduce MIGRATE_MIRROR to manage the
 mirrored pages
References: <558E084A.60900@huawei.com> <558E0948.2010104@huawei.com> <5590F4A7.4030606@jp.fujitsu.com>
In-Reply-To: <5590F4A7.4030606@jp.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/29 15:32, Kamezawa Hiroyuki wrote:

> On 2015/06/27 11:24, Xishi Qiu wrote:
>> This patch introduces a new migratetype called "MIGRATE_MIRROR", it is used to
>> allocate mirrored pages.
>> When cat /proc/pagetypeinfo, you can see the count of free mirrored blocks.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> 
> My fear about this approarch is that this may break something existing.
> 
> Now, when we add MIGRATE_MIRROR type, we'll hide attributes of pageblocks as
> MIGRATE_UNMOVABOLE, MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE.
> 
> Logically, MIRROR attribute is independent from page mobility and this overwrites
> will make some information lost.
> 
> Then,
> 
>> ---
>>   include/linux/mmzone.h | 9 +++++++++
>>   mm/page_alloc.c        | 3 +++
>>   mm/vmstat.c            | 3 +++
>>   3 files changed, 15 insertions(+)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 54d74f6..54e891a 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -39,6 +39,9 @@ enum {
>>       MIGRATE_UNMOVABLE,
>>       MIGRATE_RECLAIMABLE,
>>       MIGRATE_MOVABLE,
>> +#ifdef CONFIG_MEMORY_MIRROR
>> +    MIGRATE_MIRROR,
>> +#endif
> 
> I think
>         MIGRATE_MIRROR_UNMOVABLE,
>         MIGRATE_MIRROR_RECLAIMABLE,
>         MIGRATE_MIRROR_MOVABLE,         <== adding this may need discuss.
>         MIGRATE_MIRROR_RESERVED,        <== reserved pages should be maintained per mirrored/unmirrored.
> 

Hi Kame,

You mean add 3 or 4 new migratetype?

> should be added with the following fallback list.
> 
> /*
>  * MIRROR page range is defined by firmware at boot. The range is limited
>  * and is used only for kernel memory mirroring.
>  */
> [MIGRATE_UNMOVABLE_MIRROR]   = {MIGRATE_RECLAIMABLE_MIRROR, MIGRATE_RESERVE}
> [MIGRATE_RECLAIMABLE_MIRROR] = {MIGRATE_UNMOVABLE_MIRROR, MIGRATE_RESERVE}
> 

Why not like this:
{MIGRATE_RECLAIMABLE_MIRROR, MIGRATE_MIRROR_RESERVED, MIGRATE_RESERVE}

> Then, we'll not lose the original information of "Reclaiable Pages".
> 
> One problem here is whteher we should have MIGRATE_RESERVE_MIRROR.
> 
> If we never allow users to allocate mirrored memory, we should have MIGRATE_RESERVE_MIRROR.
> But it seems to require much more code change to do that.
> 
> Creating a zone or adding an attribues to zones are another design choice.
> 

If we add a new zone, mirror_zone will span others, I'm worry about this
maybe have problems.

Thanks,
Xishi Qiu

> Anyway, your patch doesn't takes care of reserved memory calculation at this point.
> Please check setup_zone_migrate_reserve() That will be a problem.
> 
> Thanks,
> -Kame
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
