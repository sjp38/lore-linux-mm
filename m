Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E3E116B0062
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 02:36:16 -0500 (EST)
Message-ID: <50C19C33.9030502@huawei.com>
Date: Fri, 7 Dec 2012 15:35:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MCE: fix an error of mce_bad_pages statistics
References: <50C15A35.5020007@huawei.com> <20121207072541.GA27708@liondog.tnic>
In-Reply-To: <20121207072541.GA27708@liondog.tnic>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 2012/12/7 15:25, Borislav Petkov wrote:

> On Fri, Dec 07, 2012 at 10:53:41AM +0800, Xishi Qiu wrote:
>> On x86 platform, if we use "/sys/devices/system/memory/soft_offline_page" to offline a
>> free page twice, the value of mce_bad_pages will be added twice. So this is an error,
>> since the page was already marked HWPoison, we should skip the page and don't add the
>> value of mce_bad_pages.
>>
>> $ cat /proc/meminfo | grep HardwareCorrupted
>>
>> soft_offline_page()
>> 	get_any_page()
>> 		atomic_long_add(1, &mce_bad_pages)
>>
>> The free page which marked HWPoison is still managed by page buddy allocator. So when
>> offlining it again, get_any_page() always returns 0 with
>> "pr_info("%s: %#lx free buddy page\n", __func__, pfn);".
>>
>> When page is allocated, the PageBuddy is removed in bad_page(), then get_any_page()
>> returns -EIO with pr_info("%s: %#lx: unknown zero refcount page type %lx\n", so
>> mce_bad_pages will not be added.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> ---
>>  mm/memory-failure.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 8b20278..02a522e 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1375,6 +1375,11 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
>>  	if (flags & MF_COUNT_INCREASED)
>>  		return 1;
>>
>> +	if (PageHWPoison(p)) {
>> +		pr_info("%s: %#lx page already poisoned\n", __func__, pfn);
>> +		return -EBUSY;
>> +	}
> 
> Shouldn't this be done in soft_offline_page() instead, like it is done
> in soft_offline_huge_page() for hugepages?
> 
> Thanks.
> 

Hi Borislav, you mean we should move this to the beginning of soft_offline_page()?

soft_offline_page()
{
	...
	get_any_page()
	...
	/*
	 * Synchronized using the page lock with memory_failure()
	 */
	if (PageHWPoison(page)) {
		unlock_page(page);
		put_page(page);
		pr_info("soft offline: %#lx page already poisoned\n", pfn);
		return -EBUSY;
	}
	...
}

Thanks
Xishi Qiu













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
