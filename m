Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 504D56B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 02:04:37 -0500 (EST)
Message-ID: <5125C6DE.3010906@cn.fujitsu.com>
Date: Thu, 21 Feb 2013 15:03:58 +0800
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

Hi Andrew,

Please see below. :)

On 02/21/2013 05:36 AM, Andrew Morton wrote:
>
> Also, please review the changelogging for these:
>
> page_alloc-add-movable_memmap-kernel-parameter.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix-checkpatch-fixes.patch
> page_alloc-add-movable_memmap-kernel-parameter-fix-fix-fix.patch
> page_alloc-add-movable_memmap-kernel-parameter-rename-movablecore_map-to-movablemem_map.patch

**********
Add functions to parse movablemem_map boot option.  Since the option
could be specified more then once, all the maps will be stored in the
global variable movablemem_map.map array.

And also, we keep the array in monotonic increasing order by start_pfn.
And merge all overlapped ranges.
**********

>
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix.patch
> memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix-fix.patch

**********
When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start,
type} sysfs files are created.  But there is no code to remove these
files.  This patch implements the function to remove them.

We cannot free firmware_map_entry which is allocated by bootmem because
there is no way to do so when the system is up. But we can at least remember
the address of that memory and reuse the storage when the memory is added
next time.

This patch also introduces a new list map_entries_bootmem to link the map
entries allocated by bootmem when they are removed, and a lock to 
protect it.
And these entries will be reused when the memory is hot-added again.

The idea is suggestted by Andrew Morton <akpm@linux-foundation.org>

NOTE: It is unsafe to return an entry pointer and release the 
map_entries_lock.
       So we should not hold the map_entries_lock separately in
       firmware_map_find_entry() and firmware_map_remove_entry(). Hold the
       map_entries_lock across find and remove /sys/firmware/memmap/X 
operation.

       And also, users of these two functions need to be careful to hold 
the lock
       when using these two functions.
**********

>
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix.patch
> memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix-fix.patch

**********
For removing memmap region of sparse-vmemmap which is allocated bootmem,
memmap region of sparse-vmemmap needs to be registered by
get_page_bootmem(). So the patch searches pages of virtual mapping and
registers the pages by get_page_bootmem().

NOTE: register_page_bootmem_memmap() is not implemented for ia64, ppc, s390,
       and sparc. So introduce CONFIG_HAVE_BOOTMEM_INFO_NODE and revert
       register_page_bootmem_info_node() when platform doesn't support it.

       It's implemented by adding a new Kconfig option named
       CONFIG_HAVE_BOOTMEM_INFO_NODE, which will be automatically 
selected by
       memory-hotplug feature fully supported archs(currently only on 
x86_64).

       Since we have 2 config options called MEMORY_HOTPLUG and 
MEMORY_HOTREMOVE
       used for memory hot-add and hot-remove separately, and codes in 
function
       register_page_bootmem_info_node() are only used for collecting 
infomation
       for hot-remove, so reside it under MEMORY_HOTREMOVE.

       Besides page_isolation.c selected by MEMORY_ISOLATION under 
MEMORY_HOTPLUG
       is also such case, move it too.
**********

>
> memory-hotplug-common-apis-to-support-page-tables-hot-remove.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix.patch
> memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix-fix.patch

**********
When memory is removed, the corresponding pagetables should alse be removed.
This patch introduces some common APIs to support vmemmap pagetable and 
x86_64
architecture direct mapping pagetable removing.

All pages of virtual mapping in removed memory cannot be freed if some 
pages
used as PGD/PUD include not only removed memory but also other memory. 
So this
patch uses the following way to check whether a page can be freed or not.

1) When removing memory, the page structs of the removed memory are filled
    with 0FD.
2) All page structs are filled with 0xFD on PT/PMD, PT/PMD can be cleared.
    In this case, the page used as PT/PMD can be freed.

For direct mapping pages, update direct_pages_count[level] when we freed
their pagetables. And do not free the pages again because they were freed
when offlining.

For vmemmap pages, free the pages and their pagetables.

For larger pages, do not split them into smaller ones because there is 
no way
to know if the larger page has been split. As a result, there is no way to
decide when to split. We deal the larger pages in the following way:

1) For direct mapped pages, all the pages were freed when they were 
offlined.
    And since menmory offline is done section by section, all the memory 
ranges
    being removed are aligned to PAGE_SIZE. So only need to deal with 
unaligned
    pages when freeing vmemmap pages.

2) For vmemmap pages being used to store page_struct, if part of the larger
    page is still in use, just fill the unused part with 0xFD. And when the
    whole page is fulfilled with 0xFD, then free the larger page.
**********

>
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready.patch
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix.patch
> acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix-fix.patch

**********
On linux, the pages used by kernel could not be migrated.  As a result, if
a memory range is used by kernel, it cannot be hot-removed.  So if we want
to hot-remove memory, we should prevent kernel from using it.

The way now used to prevent this is specify a memory range by
movablemem_map boot option and set it as ZONE_MOVABLE.

But when the system is booting, memblock will allocate memory, and reserve
the memory for kernel.  And before we parse SRAT, and know the node memory
ranges, memblock is working.  And it may allocate memory in ranges to be
set as ZONE_MOVABLE.  This memory can be used by kernel, and never be
freed.

So, let's parse SRAT before memblock is called first. And it is early 
enough.

The first call of memblock_find_in_range_node() is in:
setup_arch()
  |-->setup_real_mode()

so, this patch add a function early_parse_srat() to parse SRAT, and call
it before setup_real_mode() is called.

NOTE:

1) early_parse_srat() is called before numa_init(), and has initialized
    numa_meminfo. So DO NOT clear numa_nodes_parsed in numa_init() and
    DO NOT zero numa_meminfo in numa_init(), otherwise we will lose memory
    numa info.

2) I don't know why using count of memory affinities parsed from SRAT
    as a return value in original acpi_numa_init().  So I add a static
    variable srat_mem_cnt to remember this count and use it as the return
    value of the new acpi_numa_init()
**********

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
