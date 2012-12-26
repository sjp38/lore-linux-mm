Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 675496B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:31:49 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E96943EE0BC
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:31:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6BB745DEB4
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:31:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A933C45DE4D
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:31:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99875E08003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:31:47 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 505971DB8037
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:31:47 +0900 (JST)
Message-ID: <50DA6F5A.2070601@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 12:30:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 04/14] memory-hotplug: remove /sys/firmware/memmap/X
 sysfs
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-5-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
> sysfs files are created. But there is no code to remove these files. The patch
> implements the function to remove them.
> 
> Note: The code does not free firmware_map_entry which is allocated by bootmem.
>        So the patch makes memory leak. But I think the memory leak size is
>        very samll. And it does not affect the system.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   drivers/firmware/memmap.c    |   98 +++++++++++++++++++++++++++++++++++++++++-
>   include/linux/firmware-map.h |    6 +++
>   mm/memory_hotplug.c          |    5 ++-
>   3 files changed, 106 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 90723e6..49be12a 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -21,6 +21,7 @@
>   #include <linux/types.h>
>   #include <linux/bootmem.h>
>   #include <linux/slab.h>
> +#include <linux/mm.h>
>   
>   /*
>    * Data types ------------------------------------------------------------------
> @@ -41,6 +42,7 @@ struct firmware_map_entry {
>   	const char		*type;	/* type of the memory range */
>   	struct list_head	list;	/* entry for the linked list */
>   	struct kobject		kobj;   /* kobject for each entry */
> +	unsigned int		bootmem:1; /* allocated from bootmem */
>   };

Can't we detect from which the object is allocated from, slab or bootmem ?

Hm, for example,

    PageReserved(virt_to_page(address_of_obj)) ?
    PageSlab(virt_to_page(address_of_obj)) ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
