Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 692906B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 08:45:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x61so1783806wrb.8
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 05:45:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y27si24392725wrd.81.2017.04.04.05.45.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 05:45:15 -0700 (PDT)
Date: Tue, 4 Apr 2017 14:45:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory
 to zones until online
Message-ID: <20170404124508.GK15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-6-mhocko@kernel.org>
 <20170404122119.qsj3bhqse2qp46fi@builder>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404122119.qsj3bhqse2qp46fi@builder>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Regnery <tobias.regnery@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 14:21:19, Tobias Regnery wrote:
[...]
> Hi Michal,

Hi

> building an x86 allmodconfig with next-20170404 results in the following 
> section mismatch warnings probably caused by this patch:
> 
> WARNING: mm/built-in.o(.text+0x5a1c2): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:memmap_init_zone()
> The function move_pfn_range_to_zone() references
> the function __meminit memmap_init_zone().
> This is often because move_pfn_range_to_zone lacks a __meminit 
> annotation or the annotation of memmap_init_zone is wrong.

Right. __add_pages which used to call memmap_init_zone before
is __ref (to hide it the checker) which is not the case for
move_pfn_range_to_zone. I cannot say I would see the point of separating
all meminit functions because they are not going away but using __ref
for move_pfn_range_to_zone should be as safe as __add_pages is.

> WARNING: mm/built-in.o(.text+0x5a25b): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:init_currently_empty_zone()
> The function move_pfn_range_to_zone() references
> the function __meminit init_currently_empty_zone().
> This is often because move_pfn_range_to_zone lacks a __meminit 
> annotation or the annotation of init_currently_empty_zone is wrong.

and this is the same thing. Thanks a lot. The following patch should fix
it. I will keep it separate to have a reference why this has been
done...
---
