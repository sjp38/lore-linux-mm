Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id B6BB16B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 21:33:08 -0500 (EST)
Message-ID: <51131248.3080203@huawei.com>
Date: Thu, 7 Feb 2013 10:32:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] ia64/mm: fix a bad_page bug when crash kernel booting
References: <51074786.5030007@huawei.com> <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
In-Reply-To: <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt.fleming@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

On 2013/2/5 0:32, Matt Fleming wrote:

> On Tue, 2013-01-29 at 11:52 +0800, Xishi Qiu wrote:
>> On ia64 platform, I set "crashkernel=1024M-:600M", and dmesg shows 128M-728M
>> memory is reserved for crash kernel. Then "echo c > /proc/sysrq-trigger" to
>> test kdump.
>>
>> When crash kernel booting, efi_init() will aligns the memory address in
>> IA64_GRANULE_SIZE(16M), so 720M-728M memory will be dropped, It means
>> crash kernel only manage 128M-720M memory.
>>
>> But initrd start and end are fixed in boot loader, it is before efi_init(),
>> so initrd size maybe overflow when free_initrd_mem().
> 
> [...]
> 
>> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
>> index b755ea9..cfdb1eb 100644
>> --- a/arch/ia64/mm/init.c
>> +++ b/arch/ia64/mm/init.c
>> @@ -207,6 +207,17 @@ free_initrd_mem (unsigned long start, unsigned long end)
>>  	start = PAGE_ALIGN(start);
>>  	end = end & PAGE_MASK;
>>
>> +	/*
>> +	 * Initrd size is fixed in boot loader, but kernel parameter max_addr
>> +	 * which aligns in granules is fixed after boot loader, so initrd size
>> +	 * maybe overflow.
>> +	 */
>> +	if (max_addr != ~0UL) {
>> +		end = GRANULEROUNDDOWN(end);
>> +		if (start > end)
>> +			start = end;
>> +	}
>> +
>>  	if (start < end)
>>  		printk(KERN_INFO "Freeing initrd memory: %ldkB freed\n", (end - start) >> 10);
> 
> I don't think this is the correct fix.
> 
> Now, my ia64-fu is weak, but could it be that there's actually a bug in
> efi_init() and that the following patch would be the best way to fix
> this?
> 
> ---
> 
> diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> index f034563..8d579f1 100644
> --- a/arch/ia64/kernel/efi.c
> +++ b/arch/ia64/kernel/efi.c
> @@ -482,7 +482,7 @@ efi_init (void)
>  		if (memcmp(cp, "mem=", 4) == 0) {
>  			mem_limit = memparse(cp + 4, &cp);
>  		} else if (memcmp(cp, "max_addr=", 9) == 0) {
> -			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
> +			max_addr = GRANULEROUNDUP(memparse(cp + 9, &cp));
>  		} else if (memcmp(cp, "min_addr=", 9) == 0) {
>  			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
>  		} else {
> 
> 

Sorry, this bug will be happen when use Sparse-Memory(section is valid, but last
several pages are invalid). If use Flat-Memory, crash kernel will boot successfully.
I think the following patch would be better.

Hi Andrew, will you just ignore the earlier patch and consider the following one? :>

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/ia64/mm/init.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 082e383..23f2ee3 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -213,6 +213,8 @@ free_initrd_mem (unsigned long start, unsigned long end)
 	for (; start < end; start += PAGE_SIZE) {
 		if (!virt_addr_valid(start))
 			continue;
+		if ((start >> PAGE_SHIFT) >= max_low_pfn)
+			continue;
 		page = virt_to_page(start);
 		ClearPageReserved(page);
 		init_page_count(page);
-- 
1.7.6.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
