Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0F98F6B0044
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:20:53 -0500 (EST)
Message-ID: <50DA6CDC.4050101@cn.fujitsu.com>
Date: Wed, 26 Dec 2012 11:19:56 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/14] memory-hotplug: Common APIs to support page
 tables hot-remove
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-9-git-send-email-tangchen@cn.fujitsu.com> <50D96116.1070305@huawei.com> <50DA65B7.2050707@cn.fujitsu.com> <50DA6AC5.4020904@cn.fujitsu.com>
In-Reply-To: <50DA6AC5.4020904@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 12/26/2012 11:11 AM, Tang Chen wrote:
> On 12/26/2012 10:49 AM, Tang Chen wrote:
>> On 12/25/2012 04:17 PM, Jianguo Wu wrote:
>>>> +
>>>> +static void __meminit free_pagetable(struct page *page, int order)
>>>> +{
>>>> + struct zone *zone;
>>>> + bool bootmem = false;
>>>> + unsigned long magic;
>>>> +
>>>> + /* bootmem page has reserved flag */
>>>> + if (PageReserved(page)) {
>>>> + __ClearPageReserved(page);
>>>> + bootmem = true;
>>>> +
>>>> + magic = (unsigned long)page->lru.next;
>>>> + if (magic == SECTION_INFO || magic == MIX_SECTION_INFO)
>
> And also, I think we don't need to check MIX_SECTION_INFO since it is
> for the pageblock_flags, not the memmap in the section.

Oh, no :)

We also need to check MIX_SECTION_INFO because we set pgd, pud, pmd
pages as MIX_SECTION_INFO in register_page_bootmem_memmap() in patch6.

Thanks. :)

>
> Thanks. :)
>
>>>> + put_page_bootmem(page);
>>>
>>> Hi Tang,
>>>
>>> For removing memmap of sparse-vmemmap, in cpu_has_pse case, if magic
>>> == SECTION_INFO,
>>> the order will be get_order(PMD_SIZE), so we need a loop here to put
>>> all the 512 pages.
>>>
>> Hi Wu,
>>
>> Thanks for reminding me that. I truely missed it.
>>
>> And since in register_page_bootmem_info_section(), a whole memory
>> section will be set as SECTION_INFO, I think we don't need to check
>> the page magic one by one, just the first one is enough. :)
>>
>> I will fix it, thanks. :)
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
