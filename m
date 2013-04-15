Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 614436B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 19:38:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EA24F3EE0AE
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:38:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C969145DE5A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:38:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE97245DE55
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:38:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A20391DB804D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:38:34 +0900 (JST)
Received: from g01jpexchkw32.g01.fujitsu.local (g01jpexchkw32.g01.fujitsu.local [10.0.193.115])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B2191DB8046
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:38:34 +0900 (JST)
Message-ID: <516C8F5A.2030900@jp.fujitsu.com>
Date: Tue, 16 Apr 2013 08:38:02 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] firmware, memmap: fix firmware_map_entry leak
References: <516B94A1.4040603@jp.fujitsu.com> <1366059610.3824.25.camel@misato.fc.hp.com>
In-Reply-To: <1366059610.3824.25.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com

2013/04/16 6:00, Toshi Kani wrote:
> On Mon, 2013-04-15 at 14:48 +0900, Yasuaki Ishimatsu wrote:
>> When hot removing a memory, a firmware_map_entry which has memory range
>> of the memory is released by release_firmware_map_entry(). If the entry
>> is allocated by bootmem, release_firmware_map_entry() adds the entry to
>> map_entires_bootmem list when firmware_map_find_entry() finds the entry
>> from map_entries list. But firmware_map_find_entry never find the entry
>> sicne map_entires list does not have the entry. So the entry just leaks.
>>
>> Here are steps of leaking firmware_map_entry:
>> firmware_map_remove()
>> -> firmware_map_find_entry()
>>     Find released entry from map_entries list
>> -> firmware_map_remove_entry()
>>     Delete the entry from map_entries list
>> -> remove_sysfs_fw_map_entry()
>>     ...
>>     -> release_firmware_map_entry()
>>        -> firmware_map_find_entry()
>>           Find the entry from map_entries list but the entry has been
>>           deleted from map_entries list. So the entry is not added
>>           to map_entries_bootmem. Thus the entry leaks
>>
>> release_firmware_map_entry() should not call firmware_map_find_entry()
>> since releaed entry has been deleted from map_entries list.
>> So the patch delete firmware_map_find_entry() from releae_firmware_map_entry()
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> Acked-by: Toshi Kani <toshi.kani@hp.com>

Thank you for your review.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>
>> ---
>>   drivers/firmware/memmap.c |    9 +++------
>>   1 files changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
>> index 0b5b5f6..e2e04b0 100644
>> --- a/drivers/firmware/memmap.c
>> +++ b/drivers/firmware/memmap.c
>> @@ -114,12 +114,9 @@ static void __meminit release_firmware_map_entry(struct kobject *kobj)
>>   		 * map_entries_bootmem here, and deleted from &map_entries in
>>   		 * firmware_map_remove_entry().
>>   		 */
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
>>   		return;
>>   	}
>>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
