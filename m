Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0C36B791E
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:02:14 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so23302459qte.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:02:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x1si2252657qvk.102.2018.12.06.01.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 01:02:12 -0800 (PST)
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181205122918.GL1286@dhcp22.suse.cz> <20181205165716.GS1286@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7ebd7fd7-e53e-9cf3-500b-1fddd4466e33@redhat.com>
Date: Thu, 6 Dec 2018 10:02:08 +0100
MIME-Version: 1.0
In-Reply-To: <20181205165716.GS1286@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 05.12.18 17:57, Michal Hocko wrote:
> On Wed 05-12-18 13:29:18, Michal Hocko wrote:
> [...]
>> After some more thinking I am not really sure the above reasoning is
>> still true with the current upstream kernel. Maybe I just managed to
>> confuse myself so please hold off on this patch for now. Testing by
>> Oscar has shown this patch is helping but the changelog might need to be
>> updated.
> 
> OK, so Oscar has nailed it down and it seems that 4.4 kernel we have
> been debugging on behaves slightly different. The underlying problem is
> the same though. So I have reworded the changelog and added "just in
> case" PageLRU handling. Naoya, maybe you have an argument that would
> make this void for current upstream kernels.
> 
> I have dropped all the reviewed tags as the patch has changed slightly.
> Thanks a lot to Oscar for his patience and testing he has devoted to
> this issue.
> 
> Btw. the way how we drop all the work on the first page that we cannot
> isolate is just goofy. Why don't we simply migrate all that we already
> have on the list and go on? Something for a followup cleanup though.
> ---
> From 909521051f41ae46a841b481acaf1ed9c695ae7b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 3 Dec 2018 10:27:18 +0100
> Subject: [PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to be
>  offlined
> 
> We have received a bug report that an injected MCE about faulty memory
> prevents memory offline to succeed on 4.4 base kernel. The underlying
> reason was that the HWPoison page has an elevated reference count and
> the migration keeps failing. There are two problems with that. First
> of all it is dubious to migrate the poisoned page because we know that
> accessing that memory is possible to fail. Secondly it doesn't make any
> sense to migrate a potentially broken content and preserve the memory
> corruption over to a new location.
> 
> Oscar has found out that 4.4 and the current upstream kernels behave
> slightly differently with his simply testcase
> ===
> 
> int main(void)
> {
>         int ret;
>         int i;
>         int fd;
>         char *array = malloc(4096);
>         char *array_locked = malloc(4096);
> 
>         fd = open("/tmp/data", O_RDONLY);
>         read(fd, array, 4095);
> 
>         for (i = 0; i < 4096; i++)
>                 array_locked[i] = 'd';
> 
>         ret = mlock((void *)PAGE_ALIGN((unsigned long)array_locked), sizeof(array_locked));
>         if (ret)
>                 perror("mlock");
> 
>         sleep (20);
> 
>         ret = madvise((void *)PAGE_ALIGN((unsigned long)array_locked), 4096, MADV_HWPOISON);
>         if (ret)
>                 perror("madvise");
> 
>         for (i = 0; i < 4096; i++)
>                 array_locked[i] = 'd';
> 
>         return 0;
> }
> ===
> 
> + offline this memory.
> 
> In 4.4 kernels he saw the hwpoisoned page to be returned back to the LRU
> list
> kernel:  [<ffffffff81019ac9>] dump_trace+0x59/0x340
> kernel:  [<ffffffff81019e9a>] show_stack_log_lvl+0xea/0x170
> kernel:  [<ffffffff8101ac71>] show_stack+0x21/0x40
> kernel:  [<ffffffff8132bb90>] dump_stack+0x5c/0x7c
> kernel:  [<ffffffff810815a1>] warn_slowpath_common+0x81/0xb0
> kernel:  [<ffffffff811a275c>] __pagevec_lru_add_fn+0x14c/0x160
> kernel:  [<ffffffff811a2eed>] pagevec_lru_move_fn+0xad/0x100
> kernel:  [<ffffffff811a334c>] __lru_cache_add+0x6c/0xb0
> kernel:  [<ffffffff81195236>] add_to_page_cache_lru+0x46/0x70
> kernel:  [<ffffffffa02b4373>] extent_readpages+0xc3/0x1a0 [btrfs]
> kernel:  [<ffffffff811a16d7>] __do_page_cache_readahead+0x177/0x200
> kernel:  [<ffffffff811a18c8>] ondemand_readahead+0x168/0x2a0
> kernel:  [<ffffffff8119673f>] generic_file_read_iter+0x41f/0x660
> kernel:  [<ffffffff8120e50d>] __vfs_read+0xcd/0x140
> kernel:  [<ffffffff8120e9ea>] vfs_read+0x7a/0x120
> kernel:  [<ffffffff8121404b>] kernel_read+0x3b/0x50
> kernel:  [<ffffffff81215c80>] do_execveat_common.isra.29+0x490/0x6f0
> kernel:  [<ffffffff81215f08>] do_execve+0x28/0x30
> kernel:  [<ffffffff81095ddb>] call_usermodehelper_exec_async+0xfb/0x130
> kernel:  [<ffffffff8161c045>] ret_from_fork+0x55/0x80
> 
> And that later confuses the hotremove path because an LRU page is
> attempted to be migrated and that fails due to an elevated reference
> count. It is quite possible that the reuse of the HWPoisoned page is
> some kind of fixed race condition but I am not really sure about that.
> 
> With the upstream kernel the failure is slightly different. The page
> doesn't seem to have LRU bit set but isolate_movable_page simply fails
> and do_migrate_range simply puts all the isolated pages back to LRU and
> therefore no progress is made and scan_movable_pages finds same set of
> pages over and over again.
> 
> Fix both cases by explicitly checking HWPoisoned pages before we even
> try to get a reference on the page, try to unmap it if it is still
> mapped. As explained by Naoya
> : Hwpoison code never unmapped those for no big reason because
> : Ksm pages never dominate memory, so we simply didn't have strong
> : motivation to save the pages.
> 
> Also put WARN_ON(PageLRU) in case there is a race and we can hit LRU
> HWPoison pages which shouldn't happen but I couldn't convince myself
> about that.
> 
> Debugged-by: Oscar Salvador <osalvador@suse.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c6c42a7425e5..cfa1a2736876 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -34,6 +34,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memblock.h>
>  #include <linux/compaction.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1366,6 +1367,21 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  			pfn = page_to_pfn(compound_head(page))
>  				+ hpage_nr_pages(page) - 1;
>  
> +		/*
> +		 * HWPoison pages have elevated reference counts so the migration would
> +		 * fail on them. It also doesn't make any sense to migrate them in the
> +		 * first place. Still try to unmap such a page in case it is still mapped
> +		 * (e.g. current hwpoison implementation doesn't unmap KSM pages but keep
> +		 * the unmap as the catch all safety net).
> +		 */
> +		if (PageHWPoison(page)) {
> +			if (WARN_ON(PageLRU(page)))
> +				isolate_lru_page(page);
> +			if (page_mapped(page))
> +				try_to_unmap(page, TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS);
> +			continue;
> +		}
> +
>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
> 

Complicated stuff. With or without the LRU handling

Acked-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
