Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 034DD6B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:13:58 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id c10so8167096ieb.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:13:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130617210422.GN32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
	<1371128589-8953-4-git-send-email-tangchen@cn.fujitsu.com>
	<20130617210422.GN32663@mtj.dyndns.org>
Date: Mon, 17 Jun 2013 14:13:58 -0700
Message-ID: <CAE9FiQXTAT69WKvzXe7FuuSqiA9epuSGPFP2ihhpDZkqYtn9_g@mail.gmail.com>
Subject: Re: [Part1 PATCH v5 03/22] x86, ACPI, mm: Kill max_low_pfn_mapped
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jacob Shin <jacob.shin@amd.com>, Pekka Enberg <penberg@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Mon, Jun 17, 2013 at 2:04 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Thu, Jun 13, 2013 at 09:02:50PM +0800, Tang Chen wrote:
>> From: Yinghai Lu <yinghai@kernel.org>
>>
>> Now we have pfn_mapped[] array, and max_low_pfn_mapped should not
>> be used anymore. Users should use pfn_mapped[] or just
>> 1UL<<(32-PAGE_SHIFT) instead.
>>
>> The only user of max_low_pfn_mapped is ACPI_INITRD_TABLE_OVERRIDE.
>> We could change to use 1U<<(32_PAGE_SHIFT) with it, aka under 4G.
>
>                                 ^ typo

ok.

>
> ...
>> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
>> index e721863..93e3194 100644
>> --- a/drivers/acpi/osl.c
>> +++ b/drivers/acpi/osl.c
>> @@ -624,9 +624,9 @@ void __init acpi_initrd_override(void *data, size_t size)
>>       if (table_nr == 0)
>>               return;
>>
>> -     acpi_tables_addr =
>> -             memblock_find_in_range(0, max_low_pfn_mapped << PAGE_SHIFT,
>> -                                    all_tables_size, PAGE_SIZE);
>> +     /* under 4G at first, then above 4G */
>> +     acpi_tables_addr = memblock_find_in_range(0, (1ULL<<32) - 1,
>> +                                     all_tables_size, PAGE_SIZE);
>
> No bigge, but why (1ULL << 32) - 1?  Shouldn't it be just 1ULL << 32?
> memblock deals with [@start, @end) areas, right?

that is for 32bit, when phys_addr_t is 32bit, in that case
(1ULL<<32) cast to 32bit would be 0.

>
> Other than that,
>
>  Acked-by: Tejun Heo <tj@kernel.org>

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
