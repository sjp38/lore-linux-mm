Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 713946B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 20:55:47 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id d124so152667445ybf.2
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 17:55:47 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id s9si13250049otb.240.2016.11.06.17.55.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Nov 2016 17:55:46 -0800 (PST)
Message-ID: <581FDD53.20804@huawei.com>
Date: Mon, 7 Nov 2016 09:48:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
References: <581D9103.1000202@huawei.com> <581DD097.5060400@linux.vnet.ibm.com>
In-Reply-To: <581DD097.5060400@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/11/5 20:29, Anshuman Khandual wrote:

> On 11/05/2016 01:27 PM, Xishi Qiu wrote:
>> Usually the memory of android phones is very small, so after a long
>> running, the fragment is very large. Kernel stack which called by
>> alloc_thread_stack_node() usually alloc 16K memory, and it failed
>> frequently.
>>
>> However we have CONFIG_VMAP_STACK now, but it do not support arm64,
>> and maybe it has some regression because of vmalloc, it need to
>> find an area and create page table dynamically, this will take a short
>> time.
>>
>> I think we can merge as soon as possible when pcp alloc/free to reduce
>> fragment. The pcp page is hot page, so free it will cause cache miss,
>> I use perf to test it, but it seems the regression is not so much, maybe
>> it need to test more. Any reply is welcome.
> 
> The idea of PCP is to have a fast allocation mechanism which does not depend
> on an interrupt safe spin lock for every allocation. I am not very familiar
> with this part of code but the following documentation from Mel Gorman kind
> of explains that the this type of fragmentation problem which you might be
> observing as one of the limitations of PCP mechanism.
> 
> https://www.kernel.org/doc/gorman/html/understand/understand009.html
> "Per CPU page list" sub header.
> 

"The last potential problem is that buddies of newly freed pages could exist
in other pagesets leading to possible fragmentation problems."
So we should not change it, and this is a known issue, right?

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
