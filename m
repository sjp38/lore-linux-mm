Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 934276B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 18:19:22 -0500 (EST)
Date: Wed, 9 Jan 2013 15:19:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 04/15] memory-hotplug: remove /sys/firmware/memmap/X
 sysfs
Message-Id: <20130109151920.fb9b4029.akpm@linux-foundation.org>
In-Reply-To: <1357723959-5416-5-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-5-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:28 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
> sysfs files are created. But there is no code to remove these files. The patch
> implements the function to remove them.
> 
> Note: The code does not free firmware_map_entry which is allocated by bootmem.
>       So the patch makes memory leak. But I think the memory leak size is
>       very samll. And it does not affect the system.
> 
> ...
>
> +static struct firmware_map_entry * __meminit
> +firmware_map_find_entry(u64 start, u64 end, const char *type)
> +{
> +	struct firmware_map_entry *entry;
> +
> +	spin_lock(&map_entries_lock);
> +	list_for_each_entry(entry, &map_entries, list)
> +		if ((entry->start == start) && (entry->end == end) &&
> +		    (!strcmp(entry->type, type))) {
> +			spin_unlock(&map_entries_lock);
> +			return entry;
> +		}
> +
> +	spin_unlock(&map_entries_lock);
> +	return NULL;
> +}
>
> ...
>
> +	entry = firmware_map_find_entry(start, end - 1, type);
> +	if (!entry)
> +		return -EINVAL;
> +
> +	firmware_map_remove_entry(entry);
>
> ...
>

The above code looks racy.  After firmware_map_find_entry() does the
spin_unlock() there is nothing to prevent a concurrent
firmware_map_remove_entry() from removing the entry, so the kernel ends
up calling firmware_map_remove_entry() twice against the same entry.

An easy fix for this is to hold the spinlock across the entire
lookup/remove operation.


This problem is inherent to firmware_map_find_entry() as you have
implemented it, so this function simply should not exist in the current
form - no caller can use it without being buggy!  A simple fix for this
is to remove the spin_lock()/spin_unlock() from
firmware_map_find_entry() and add locking documentation to
firmware_map_find_entry(), explaining that the caller must hold
map_entries_lock and must not release that lock until processing of
firmware_map_find_entry()'s return value has completed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
