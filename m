Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 50ACE280033
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 23:55:29 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn18so386197igb.1
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 20:55:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f13si30756425ick.66.2014.11.10.20.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Nov 2014 20:55:28 -0800 (PST)
Date: Tue, 11 Nov 2014 13:54:09 +0900
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 1/2] mem-hotplug: Reset node managed pages when
 hot-adding a new pgdat.
Message-ID: <20141111045409.GA23920@kroah.com>
References: <1415669227-10996-1-git-send-email-tangchen@cn.fujitsu.com>
 <1415669227-10996-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415669227-10996-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miaox@cn.fujitsu.com, stable@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Tue, Nov 11, 2014 at 09:27:06AM +0800, Tang Chen wrote:
> In free_area_init_core(), zone->managed_pages is set to an approximate
> value for lowmem, and will be adjusted when the bootmem allocator frees
> pages into the buddy system. But free_area_init_core() is also called
> by hotadd_new_pgdat() when hot-adding memory. As a result, zone->managed_pages
> of the newly added node's pgdat is set to an approximate value in the
> very beginning. Even if the memory on that node has node been onlined,
> /sys/device/system/node/nodeXXX/meminfo has wrong value.
> 
> hot-add node2 (memory not onlined)
> cat /sys/device/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB
> Node 2 MemFree:               0 kB
> Node 2 MemUsed:        33554432 kB
> Node 2 Active:                0 kB
> 
> This patch fixes this problem by reset node managed pages to 0 after hot-adding
> a new node.
> 
> 1. Move reset_managed_pages_done from reset_node_managed_pages() to reset_all_zones_managed_pages()
> 2. Make reset_node_managed_pages() non-static
> 3. Call reset_node_managed_pages() in hotadd_new_pgdat() after pgdat is initialized
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>  include/linux/bootmem.h | 1 +
>  mm/bootmem.c            | 9 +++++----
>  mm/memory_hotplug.c     | 9 +++++++++
>  mm/nobootmem.c          | 8 +++++---
>  4 files changed, 20 insertions(+), 7 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
