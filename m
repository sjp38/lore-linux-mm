Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id EBA726B00E4
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:23:29 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb10so96065pad.11
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:23:29 -0700 (PDT)
Message-ID: <5151BD61.7020401@gmail.com>
Date: Tue, 26 Mar 2013 23:23:13 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2, part4 03/39] c6x: normalize global variables exported
 by vmlinux.lds
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>  <1364109934-7851-4-git-send-email-jiang.liu@huawei.com> <1364234218.2334.2.camel@t520.redhat.com>
In-Reply-To: <1364234218.2334.2.camel@t520.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Aurelien Jacquiot <a-jacquiot@ti.com>, linux-c6x-dev@linux-c6x.org

On 03/26/2013 01:56 AM, Mark Salter wrote:
> On Sun, 2013-03-24 at 15:24 +0800, Jiang Liu wrote:
>> Normalize global variables exported by vmlinux.lds to conform usage
>> guidelines from include/asm-generic/sections.h.
>>
>> Use _text to mark the start of the kernel image including the head text,
>> and _stext to mark the start of the .text section.
>>
>> This patch also fixes possible bugs due to current address layout that
>> [__init_begin, __init_end] is a sub-range of [_stext, _etext] and pages
>> within range [__init_begin, __init_end] will be freed by free_initmem().
> 
> I won't have time to look at this in detail until later this week, but
> the reason for that layout is because c6x commonly stores text in flash.
> Not all of the xip support is in-tree yet, but when it is, we don't want
> to free init text.
Hi Mark,
	Thanks for reminder. It's possible to support the usage case you
have described, please take a look at arch/tile/kernel/vmlinux.lds.S.
By that way, we could only free init.data sections without freeing init.text
sections.
	Regards!
	Gerry

> 
> --Mark
> 
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Cc: Mark Salter <msalter@redhat.com>
>> Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
>> Cc: linux-c6x-dev@linux-c6x.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  arch/c6x/kernel/vmlinux.lds.S |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/c6x/kernel/vmlinux.lds.S b/arch/c6x/kernel/vmlinux.lds.S
>> index 1d81c4c..279d807 100644
>> --- a/arch/c6x/kernel/vmlinux.lds.S
>> +++ b/arch/c6x/kernel/vmlinux.lds.S
>> @@ -54,16 +54,15 @@ SECTIONS
>>  	}
>>  
>>  	. = ALIGN(PAGE_SIZE);
>> +	__init_begin = .;
>>  	.init :
>>  	{
>> -		_stext = .;
>>  		_sinittext = .;
>>  		HEAD_TEXT
>>  		INIT_TEXT
>>  		_einittext = .;
>>  	}
>>  
>> -	__init_begin = _stext;
>>  	INIT_DATA_SECTION(16)
>>  
>>  	PERCPU_SECTION(128)
>> @@ -74,6 +73,7 @@ SECTIONS
>>  	.text :
>>  	{
>>  		_text = .;
>> +		_stext = .;
>>  		TEXT_TEXT
>>  		SCHED_TEXT
>>  		LOCK_TEXT
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
