Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6CC786B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 13:25:02 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 11:25:01 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 88ABB1FF001A
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:20:08 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IIOkpX289210
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:24:46 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IIOcJD010044
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:24:39 -0700
Message-ID: <512271E1.9000105@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 12:24:33 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
References: <1359937421-19921-1-git-send-email-minchan@kernel.org> <511F2721.2000305@gmail.com>
In-Reply-To: <511F2721.2000305@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 02/16/2013 12:28 AM, Ric Mason wrote:
> On 02/04/2013 08:23 AM, Minchan Kim wrote:
>> Zsmalloc has two methods 1) copy-based and 2) pte based to access
>> allocations that span two pages.
>> You can see history why we supported two approach from [1].
>>
>> But it was bad choice that adding hard coding to select architecture
>> which want to use pte based method. This patch removed it and adds
>> new Kconfig to select the approach.
>>
>> This patch is based on next-20130202.
>>
>> [1] https://lkml.org/lkml/2012/7/11/58
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>   drivers/staging/zsmalloc/Kconfig         |   12 ++++++++++++
>>   drivers/staging/zsmalloc/zsmalloc-main.c |   11 -----------
>>   2 files changed, 12 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/staging/zsmalloc/Kconfig
>> b/drivers/staging/zsmalloc/Kconfig
>> index 9084565..2359123 100644
>> --- a/drivers/staging/zsmalloc/Kconfig
>> +++ b/drivers/staging/zsmalloc/Kconfig
>> @@ -8,3 +8,15 @@ config ZSMALLOC
>>         non-standard allocator interface where a handle, not a
>> pointer, is
>>         returned by an alloc().  This handle must be mapped in order to
>>         access the allocated space.
>> +
>> +config ZSMALLOC_PGTABLE_MAPPING
>> +        bool "Use page table mapping to access allocations that
>> span two pages"
>> +        depends on ZSMALLOC
>> +        default n
>> +        help
>> +      By default, zsmalloc uses a copy-based object mapping method
>> to access
>> +      allocations that span two pages. However, if a particular
>> architecture
>> +      performs VM mapping faster than copying, then you should
>> select this.
>> +      This causes zsmalloc to use page table mapping rather than
>> copying
>> +      for object mapping. You can check speed with zsmalloc
>> benchmark[1].
>> +      [1] https://github.com/spartacus06/zsmalloc
> 
> Is there benchmark to test zcache? eg. internal fragmentation level ...

First, zsmalloc is not used in zcache right now so just wanted to say
that.  It is used in zram and the proposed zswap
(https://lwn.net/Articles/528817/)

There is not an official benchmark.  However anything that generates
activity that will hit the frontswap or cleancache hooks will do.
These are workloads that overcommit memory and use swap, or access
file sets whose size is larger that the system page cache.

The closest thing to a fragmentation metric is an effective
compression ratio that can be calculated with debugfs attributes:

zcache_[eph|pers]_zbytes / (zcache_[eph|pers]_pageframes * PAGE_SIZE)

eph for cleancache, and pers for frontswap.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
