Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE736B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:27:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so5493336wmd.9
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:27:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x2si9438412wrc.202.2017.10.10.05.27.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 05:27:29 -0700 (PDT)
Date: Tue, 10 Oct 2017 14:27:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmlfw6mj.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Memory offlining can fail just too eagerly under a heavy memory pressure.
> >
> > [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> > [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> > [ 5410.336811] page dumped because: isolation failed
> > [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> > [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> >
> > Isolation has failed here because the page is not on LRU. Most probably
> > because it was on the pcp LRU cache or it has been removed from the LRU
> > already but it hasn't been freed yet. In both cases the page doesn't look
> > non-migrable so retrying more makes sense.
> 
> This breaks offline for me.
> 
> Prior to this commit:
>   /sys/devices/system/memory/memory0# time echo 0 > online
>   -bash: echo: write error: Device or resource busy
>   
>   real	0m0.001s
>   user	0m0.000s
>   sys	0m0.001s
> 
> After:
>   /sys/devices/system/memory/memory0# time echo 0 > online
>   -bash: echo: write error: Device or resource busy
>   
>   real	2m0.009s
>   user	0m0.000s
>   sys	1m25.035s
> 
> 
> There's no way that block can be removed, it contains the kernel text,
> so it should instantly fail - which it used to.

OK, that means that start_isolate_page_range should have failed but it
hasn't for some reason. I strongly suspect has_unmovable_pages is doing
something wrong. Is the kernel text marked somehow? E.g. PageReserved?
In other words, does the diff below helps?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3badcedf96a7..00d042052501 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7368,6 +7368,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		if (PageReserved(page))
+			return true;
+
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
 		 * We need not scan over tail pages bacause we don't


> With commit 3aa2823fdf66 ("mm, memory_hotplug: remove timeout from
> __offline_memory") also applied, it appears to just get stuck forever,
> and I get lots of:
> 
>   [ 1232.112953] INFO: task kworker/3:0:4609 blocked for more than 120 seconds.
>   [ 1232.113067]       Not tainted 4.14.0-rc4-gcc6-next-20171009-g49827b9 #1
>   [ 1232.113183] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>   [ 1232.113319] kworker/3:0     D11984  4609      2 0x00000800
>   [ 1232.113416] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
>   [ 1232.113531] Call Trace:
>   [ 1232.113579] [c0000000fb2db7a0] [c0000000fb2db900] 0xc0000000fb2db900 (unreliable)
>   [ 1232.113717] [c0000000fb2db970] [c00000000001c964] __switch_to+0x304/0x6e0
>   [ 1232.113840] [c0000000fb2dba10] [c000000000a408c0] __schedule+0x2e0/0xa80
>   [ 1232.113978] [c0000000fb2dbae0] [c000000000a410a8] schedule+0x48/0xc0
>   [ 1232.114113] [c0000000fb2dbb10] [c000000000a44d88] rwsem_down_read_failed+0x128/0x1b0
>   [ 1232.114269] [c0000000fb2dbb70] [c0000000001696a8] __percpu_down_read+0x108/0x110
>   [ 1232.114426] [c0000000fb2dbba0] [c00000000032e498] get_online_mems+0x68/0x80
>   [ 1232.115487] [c0000000fb2dbbc0] [c0000000002c82ec] memcg_create_kmem_cache+0x4c/0x190
>   [ 1232.115651] [c0000000fb2dbc60] [c0000000003483b8] memcg_kmem_cache_create_func+0x38/0xf0
>   [ 1232.115809] [c0000000fb2dbc90] [c000000000121594] process_one_work+0x2b4/0x590
>   [ 1232.115964] [c0000000fb2dbd20] [c000000000121908] worker_thread+0x98/0x5d0
>   [ 1232.116095] [c0000000fb2dbdc0] [c00000000012a134] kthread+0x164/0x1b0
>   [ 1232.116229] [c0000000fb2dbe30] [c00000000000bae0] ret_from_kernel_thread+0x5c/0x7c

I do not see how this is related to the offline path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
