Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 876F16B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:27:11 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id ep20so729317lab.32
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 14:27:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1358247267-18089-2-git-send-email-tangchen@cn.fujitsu.com>
References: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com> <1358247267-18089-2-git-send-email-tangchen@cn.fujitsu.com>
From: Julian Calaby <julian.calaby@gmail.com>
Date: Wed, 16 Jan 2013 09:26:49 +1100
Message-ID: <CAGRGNgWCdvWhp=9+PDRbC9bK100BdBv9kpcsqoM-J6ipq22Szw@mail.gmail.com>
Subject: Re: [BUG Fix Patch 1/6] Bug fix: Hold spinlock across find|remove
 /sys/firmware/memmap/X operation.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Tang,

One minor point.

On Tue, Jan 15, 2013 at 9:54 PM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> It is unsafe to return an entry pointer and release the map_entries_lock. So we should
> not hold the map_entries_lock separately in firmware_map_find_entry() and
> firmware_map_remove_entry(). Hold the map_entries_lock across find and remove
> /sys/firmware/memmap/X operation.
>
> And also, users of these two functions need to be careful to hold the lock when using
> these two functions.
>
> The suggestion is from Andrew Morton <akpm@linux-foundation.org>
>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  drivers/firmware/memmap.c |   25 +++++++++++++++++--------
>  1 files changed, 17 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 4211da5..940c4e9 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -188,23 +188,28 @@ static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
>  }
>
>  /*
> - * Search memmap entry
> + * firmware_map_find_entry: Search memmap entry.
> + * @start: Start of the memory range.
> + * @end:   End of the memory range (exclusive).
> + * @type:  Type of the memory range.
> + *
> + * This function is to find the memmap entey of a given memory range.
> + * The caller must hold map_entries_lock, and must not release the lock
> + * until the processing of the returned entry has completed.
> + *
> + * Return pointer to the entry to be found on success, or NULL on failure.

Why not make this completely kernel-doc compliant as you're already
re-writing the comment?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
