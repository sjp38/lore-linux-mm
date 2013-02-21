Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 04B006B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 22:04:26 -0500 (EST)
Message-ID: <51258E92.8040504@cn.fujitsu.com>
Date: Thu, 21 Feb 2013 11:03:46 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH 0/2] Make whatever node kernel resides in un-hotpluggable.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com> <20130220133650.4e0913f3.akpm@linux-foundation.org>
In-Reply-To: <20130220133650.4e0913f3.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/21/2013 05:36 AM, Andrew Morton wrote:
> On Wed, 20 Feb 2013 19:00:54 +0800
> Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>
>> As mentioned by HPA before, when we are using movablemem_map=acpi, if all the
>> memory in SRAT is hotpluggable, then the kernel will have no memory to use, and
>> will fail to boot.
>>
>> Before parsing SRAT, memblock has already reserved some memory in memblock.reserve,
>> which is used by the kernel, such as storing the kernel image. We are not able to
>> prevent the kernel from using these memory. So, these 2 patches make the node which
>> the kernel resides in un-hotpluggable.
>
> I'm planning to roll all these into a single commit:
>
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat.patch
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix.patch
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix.patch
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix-fix.patch
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix-fix-fix.patch
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix-fix-fix-fix.patch
>
> for reasons of tree-cleanliness and to avoid bisection holes.  They're
> at http://ozlabs.org/~akpm/mmots/broken-out/.
>
> Can you please check the changelog for
> acpi-memory-hotplug-support-getting-hotplug-info-from-srat.patch to see
> if it needs any updates due to all the fixup patches?  If so, please
> send me the new changelog, thanks.

Hi Andrew,

Please use the following changelog for
acpi-memory-hotplug-support-getting-hotplug-info-from-srat.patch

**********

We now provide an option for users who don't want to specify physical 
memory address
in kernel commandline.

         /*
          * For movablemem_map=acpi:
          *
          * SRAT:                |_____| |_____| |_________| |_________| 
......
          * node id:                0       1         1           2
          * hotpluggable:           n       y         y           n
          * movablemem_map:              |_____| |_________|
          *
          * Using movablemem_map, we can prevent memblock from 
allocating memory
          * on ZONE_MOVABLE at boot time.
          */

So user just specify movablemem_map=acpi, and the kernel will use 
hotpluggable info
in SRAT to determine which memory ranges should be set as ZONE_MOVABLE.

If all the memory ranges in SRAT is hotpluggable, then no memory can be 
used by kernel.
But before parsing SRAT, memblock has already reserve some memory ranges 
for other
purposes, such as for kernel image, and so on. We cannot prevent kernel 
from using
these memory. So we need to exclude these ranges even if these memory is 
hotpluggable.

Furthermore, there could be several memory ranges in the single node 
which the kernel
resides in. We may skip one range that have memory reserved by memblock, 
but if the
rest of memory is too small, then the kernel will fail to boot. So, make 
the whole node
which the kernel resides in un-hotpluggable. Then the kernel has enough 
memory to use.

NOTE: Using this way will cause NUMA performance down because the whole node
       will be set as ZONE_MOVABLE, and kernel cannot use memory on it.
       If users don't want to lose NUMA performance, just don't use it.

**********

>
> Also, please review the changelogging for these:

The following xxx-fix-... patches will also be rolled, right ?
I'll post the changelogs later.

Thanks. :)

>
> page_alloc-add-movable_memmap-kernel-parameter.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix-checkpatch-fixes.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-rename-movablecore_map-to-movablemem_map.patch
>
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix-fix.patch
>
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix-fix.patch
>
> memory-hotplug-common-apis-to-support-page-tables-hot-remove.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix-fix.patch
>
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready.patch
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix.patch
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix-fix.patch
>
>
> and while we're there, let's pause to admire how prescient I was in
> refusing to merge all this into 3.8-rc1 :)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
