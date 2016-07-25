Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFB706B0005
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 21:57:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so371134474pfg.1
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 18:57:14 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id tu5si30655273pab.149.2016.07.24.18.57.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 24 Jul 2016 18:57:14 -0700 (PDT)
Message-ID: <579570D5.7060803@huawei.com>
Date: Mon, 25 Jul 2016 09:52:21 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mem-hotplug: alloc new page from the next node if
 zone is MOVABLE_ZONE
References: <57918BAC.8000008@huawei.com> <20160722131103.23c02a66d086df8f2ddae601@linux-foundation.org>
In-Reply-To: <20160722131103.23c02a66d086df8f2ddae601@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/23 4:11, Andrew Morton wrote:

> On Fri, 22 Jul 2016 10:57:48 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> Memory offline could happen on both movable zone and non-movable zone.
>> We can offline the whole node if the zone is movable zone, and if the
>> zone is non-movable zone, we cannot offline the whole node, because
>> some kernel memory can't be migrated.
>>
>> So if we offline a node with movable zone, use prefer mempolicy to alloc
>> new page from the next node instead of the current node or other remote
>> nodes, because re-migrate is a waste of time and the distance of the
>> remote nodes is often very large.
>>
>> Also use GFP_HIGHUSER_MOVABLE to alloc new page if the zone is movable
>> zone.
> 
> This conflicts pretty significantly with your "mem-hotplug: use
> different mempolicy in alloc_migrate_target()".  Does it replace
> "mem-hotplug: use different mempolicy in alloc_migrate_target()" and
> your "mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
> alloc_migrate_target()", or what?
> 

Hi Andrew,

Yes, this patch is v2, "mem-hotplug: use different mempolicy in alloc_migrate_target()"
and "mem-hotplug: use GFP_HIGHUSER_MOVABLE in alloc_migrate_target()" are v1,
so just replace them.

Joonsoo and Vlastimil point that migratable pages are not always from user space,
so it is not correct to use GFP_HIGHUSER_MOVABLE in alloc_migrate_target().

David points that CMA and memory offline are distinct usecases and probably 
deserve their own callbacks.

Thanks,
Xishi Qiu

> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
