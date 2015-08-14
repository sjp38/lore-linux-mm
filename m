Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id BD3196B0257
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 03:57:23 -0400 (EDT)
Received: by iodt126 with SMTP id t126so77482542iod.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 00:57:23 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h6si877635igg.4.2015.08.14.00.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Aug 2015 00:57:23 -0700 (PDT)
Message-ID: <55CD9EDF.5090707@huawei.com>
Date: Fri, 14 Aug 2015 15:55:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com> <55BEE99E.8090901@intel.com> <55C011A6.1090003@huawei.com> <55C0CBC3.2000602@intel.com> <55C1C132.2010805@huawei.com> <55C221EB.7060500@intel.com>
In-Reply-To: <55C221EB.7060500@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/8/5 22:47, Dave Hansen wrote:

> On 08/05/2015 12:54 AM, Xishi Qiu wrote:
>> I add some debug code like this, but it doesn't trigger the dump_stack().
> ...
>> +         if (!list_empty(&area->free_list[migratetype])) {
>> +                 printk("expand(), the list is not empty\n");
>> +                 dump_stack();
>> +         }
>> +
> 
> That will probably not trigger unless you have allocations that are
> falling back and converting other pageblocks from other migratetypes.
> 

Hi Dave,

I run some stress test, and trigger the print, it shows that the list 
is not empty. The reason is than fallback will find the largest possible
block of pages in the other list, 

e.g. 
1. we alloc order=2 block, and call __rmqueue_fallback().
2. we find other list current_order=7 is not empty, and the lists(in the
same pageblock) that order from 3~6 are not empty too.
3. then expand() will find the list is not empty.

right?

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
