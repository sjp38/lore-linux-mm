Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BD3206B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:00:29 -0400 (EDT)
Message-ID: <516BC25B.9090708@cn.fujitsu.com>
Date: Mon, 15 Apr 2013 17:03:23 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] firmware, memmap: fix firmware_map_entry leak
References: <516B94A1.4040603@jp.fujitsu.com>
In-Reply-To: <516B94A1.4040603@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wency@cn.fujitsu.co, toshi.kani@hp.com


Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

Thanks. :)

On 04/15/2013 01:48 PM, Yasuaki Ishimatsu wrote:
> When hot removing a memory, a firmware_map_entry which has memory range
> of the memory is released by release_firmware_map_entry(). If the entry
> is allocated by bootmem, release_firmware_map_entry() adds the entry to
> map_entires_bootmem list when firmware_map_find_entry() finds the entry
> from map_entries list. But firmware_map_find_entry never find the entry
> sicne map_entires list does not have the entry. So the entry just leaks.
> 
> Here are steps of leaking firmware_map_entry:
> firmware_map_remove()
> ->  firmware_map_find_entry()
>     Find released entry from map_entries list
> ->  firmware_map_remove_entry()
>     Delete the entry from map_entries list
> ->  remove_sysfs_fw_map_entry()
>     ...
>     ->  release_firmware_map_entry()
>        ->  firmware_map_find_entry()
>           Find the entry from map_entries list but the entry has been
>           deleted from map_entries list. So the entry is not added
>           to map_entries_bootmem. Thus the entry leaks
> 
> release_firmware_map_entry() should not call firmware_map_find_entry()
> since releaed entry has been deleted from map_entries list.
> So the patch delete firmware_map_find_entry() from releae_firmware_map_entry()
> 
> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
> ---
>   drivers/firmware/memmap.c |    9 +++------
>   1 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 0b5b5f6..e2e04b0 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -114,12 +114,9 @@ static void __meminit release_firmware_map_entry(struct kobject *kobj)
>   		 * map_entries_bootmem here, and deleted from&map_entries in
>   		 * firmware_map_remove_entry().
>   		 */
> -		if (firmware_map_find_entry(entry->start, entry->end,
> -		    entry->type)) {
> -			spin_lock(&map_entries_bootmem_lock);
> -			list_add(&entry->list,&map_entries_bootmem);
> -			spin_unlock(&map_entries_bootmem_lock);
> -		}
> +		spin_lock(&map_entries_bootmem_lock);
> +		list_add(&entry->list,&map_entries_bootmem);
> +		spin_unlock(&map_entries_bootmem_lock);
> 
>   		return;
>   	}
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
