Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 33E0D6B0005
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 20:57:27 -0500 (EST)
Message-ID: <511EE720.6060907@huawei.com>
Date: Sat, 16 Feb 2013 09:55:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
References: <51074786.5030007@huawei.com>  <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>  <51131248.3080203@huawei.com> <5113450C.1080109@huawei.com> <1360750028.24917.28.camel@mfleming-mobl1.ger.corp.intel.com>
In-Reply-To: <1360750028.24917.28.camel@mfleming-mobl1.ger.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt.fleming@intel.com>, "Luck, Tony" <tony.luck@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

On 2013/2/13 18:07, Matt Fleming wrote:

>> In efi_init() memory aligns in IA64_GRANULE_SIZE(16M). If set "crashkernel=1024M-:600M"
>> and use sparse memory model, when crash kernel booting it changes [128M-728M] to [128M-720M].
>> But initrd memory is in [709M-727M], and virt_addr_valid() *can not* check the invalid pages
>> when freeing initrd memory. There are some pages missed at the end of the seciton.
>>
>> ChangeLog V3:
>> 	fixed vaddr mistake
>> ChangeLog V2:
>> 	add invalid pages check when freeing initrd memory
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  arch/ia64/mm/init.c |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
>> index 082e383..8a269f8 100644
>> --- a/arch/ia64/mm/init.c
>> +++ b/arch/ia64/mm/init.c
>> @@ -173,6 +173,7 @@ void __init
>>  free_initrd_mem (unsigned long start, unsigned long end)
>>  {
>>  	struct page *page;
>> +	unsigned long pfn;
>>  	/*
>>  	 * EFI uses 4KB pages while the kernel can use 4KB or bigger.
>>  	 * Thus EFI and the kernel may have different page sizes. It is
>> @@ -213,6 +214,9 @@ free_initrd_mem (unsigned long start, unsigned long end)
>>  	for (; start < end; start += PAGE_SIZE) {
>>  		if (!virt_addr_valid(start))
>>  			continue;
>> +		pfn = __pa(start) >> PAGE_SHIFT;
>> +		if (pfn >= max_low_pfn)
>> +			continue;
>>  		page = virt_to_page(start);
>>  		ClearPageReserved(page);
>>  		init_page_count(page);
> 
> I would have presumed that fixing this bug would involve modifying the
> ia64-specific kexec code?
> 
> Tony, Fenghua? Any thoughts?


Hi, I had the Spring Festival a few days ago. Please ignore the earlier
patch and consider the V3 one above.

Thanks,
Xishi Qiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
