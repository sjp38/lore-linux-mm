Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id BA05582BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 04:42:50 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id m8so5403925obr.10
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 01:42:50 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ut6si16298855obc.100.2014.11.10.01.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 01:42:49 -0800 (PST)
Message-ID: <54608706.6030109@huawei.com>
Date: Mon, 10 Nov 2014 17:36:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/2] Fix node meminfo and zoneinfo corruption.
References: <1415353481-3140-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1415353481-3140-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miaox@cn.fujitsu.com

On 2014/11/7 17:44, Tang Chen wrote:

> There are two problems in memory hot-add progress:
> 
> 1. When hot-adding a node without onlining any page, node meminfo corrupted:
> 
> # hot-add node2 (memory not onlined)
> # cat /sys/device/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB			/* corrupted */
> Node 2 MemFree:               0 kB
> Node 2 MemUsed:        33554432 kB
> Node 2 Active:                0 kB
> ......
> 
> 
> 2. When onlining memory on node2, node2 zoneinfo and node3 meminfo corrupted:
> 
> # for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
> # cat /sys/devices/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB
> Node 2 MemFree:        33549092 kB
> Node 2 MemUsed:            5340 kB
> ......
> # cat /sys/devices/system/node/node3/meminfo
> Node 3 MemTotal:              0 kB
> Node 3 MemFree:               248 kB      /* corrupted, should be 0 */
> Node 3 MemUsed:               0 kB
> ......
> 
> # cat /proc/zoneinfo
> ......
> Node 2, zone   Movable
> ......
>         spanned  8388608
>         present  16777216		/* corrupted, should be 8388608 */
>         managed  8388608
> 
> 
> 
> Change log v1 -> v2:
> 1. Replace patch 2/2 with a new one. It provides the simplest way to
>    fix problem 2. 
> 
> Tang Chen (2):
>   mem-hotplug: Reset node managed pages when hot-adding a new pgdat.
>   mem-hotplug: Reset node present pages when hot-adding a new pgdat.
> 
>  include/linux/bootmem.h |  1 +
>  mm/bootmem.c            |  9 +++++----
>  mm/memory_hotplug.c     | 24 ++++++++++++++++++++++++
>  mm/nobootmem.c          |  8 +++++---
>  4 files changed, 35 insertions(+), 7 deletions(-)
> 

Hi Tang,

How about cc stable ?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
