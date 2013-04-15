Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id E66126B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 03:24:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EDAE33EE0C1
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:24:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D393445DEB5
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:24:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B486A45DEBA
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:24:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F8C1DB803C
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:24:26 +0900 (JST)
Received: from g01jpexchyt28.g01.fujitsu.local (g01jpexchyt28.g01.fujitsu.local [10.128.193.111])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5481F1DB803F
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 16:24:26 +0900 (JST)
Message-ID: <516BAB16.4070501@jp.fujitsu.com>
Date: Mon, 15 Apr 2013 16:24:06 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] firmware, memmap: fix firmware_map_entry leak
References: <516B94A1.4040603@jp.fujitsu.com> <20130415070415.GA16757@hacker.(null)>
In-Reply-To: <20130415070415.GA16757@hacker.(null)>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, toshi.kani@hp.com

2013/04/15 16:04, Wanpeng Li wrote:
> On Mon, Apr 15, 2013 at 02:48:17PM +0900, Yasuaki Ishimatsu wrote:
>> When hot removing a memory, a firmware_map_entry which has memory range
>> of the memory is released by release_firmware_map_entry(). If the entry
>> is allocated by bootmem, release_firmware_map_entry() adds the entry to
>> map_entires_bootmem list when firmware_map_find_entry() finds the entry
>>from map_entries list. But firmware_map_find_entry never find the entry
>> sicne map_entires list does not have the entry. So the entry just leaks.
>>
>> Here are steps of leaking firmware_map_entry:
>> firmware_map_remove()
>> -> firmware_map_find_entry()
>>    Find released entry from map_entries list
>> -> firmware_map_remove_entry()
>>    Delete the entry from map_entries list
>> -> remove_sysfs_fw_map_entry()
>>    ...
>>    -> release_firmware_map_entry()
>>       -> firmware_map_find_entry()
>>          Find the entry from map_entries list but the entry has been
>>          deleted from map_entries list. So the entry is not added
>>          to map_entries_bootmem. Thus the entry leaks
>>
>> release_firmware_map_entry() should not call firmware_map_find_entry()
>> since releaed entry has been deleted from map_entries list.
>> So the patch delete firmware_map_find_entry() from releae_firmware_map_entry()
>>
>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Thank you for your review.

Thanks,
Yasuaki Ishimatsu

>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>> drivers/firmware/memmap.c |    9 +++------
>> 1 files changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
>> index 0b5b5f6..e2e04b0 100644
>> --- a/drivers/firmware/memmap.c
>> +++ b/drivers/firmware/memmap.c
>> @@ -114,12 +114,9 @@ static void __meminit release_firmware_map_entry(struct kobject *kobj)
>> 		 * map_entries_bootmem here, and deleted from &map_entries in
>> 		 * firmware_map_remove_entry().
>> 		 */
>> -		if (firmware_map_find_entry(entry->start, entry->end,
>> -		    entry->type)) {
>> -			spin_lock(&map_entries_bootmem_lock);
>> -			list_add(&entry->list, &map_entries_bootmem);
>> -			spin_unlock(&map_entries_bootmem_lock);
>> -		}
>> +		spin_lock(&map_entries_bootmem_lock);
>> +		list_add(&entry->list, &map_entries_bootmem);
>> +		spin_unlock(&map_entries_bootmem_lock);
>>
>> 		return;
>> 	}
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
