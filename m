Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A14366B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:58:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so12330020wmz.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:58:58 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id k23si12181608wmc.105.2016.07.28.00.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 00:58:57 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id o80so94934772wme.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:58:57 -0700 (PDT)
Date: Thu, 28 Jul 2016 09:58:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction
 failed
Message-ID: <20160728075856.GE31860@dhcp22.suse.cz>
References: <5799AF6A.2070507@huawei.com>
 <20160728072028.GC31860@dhcp22.suse.cz>
 <5799B741.8090506@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5799B741.8090506@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Yisheng Xie <xieyisheng1@huawei.com>

On Thu 28-07-16 15:41:53, Xishi Qiu wrote:
> On 2016/7/28 15:20, Michal Hocko wrote:
> 
> > On Thu 28-07-16 15:08:26, Xishi Qiu wrote:
> >> Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
> >> physical memory during fork a new process.
> >>
> >> If the system's memory is very small, especially the smart phone, maybe there
> >> is only 1G memory. So the free memory is very small and compaction is not
> >> always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
> >> may be failed for memory fragment.
> > 
> > Well, with the current implementation of the page allocator those
> > requests will not fail in most cases. The oom killer would be invoked in
> > order to free up some memory.
> > 
> 
> Hi Michal,
> 
> Yes, it success in most cases, but I did have seen this problem in some
> stress-test.
> 
> DMA free:470628kB, but alloc 2 order block failed during fork a new process.
> There are so many memory fragments and the large block may be soon taken by
> others after compact because of stress-test.
> 
> --- dmesg messages ---
> 07-13 08:41:51.341 <4>[309805.658142s][pid:1361,cpu5,sManagerService]sManagerService: page allocation failure: order:2, mode:0x2000d1

Yes but this is __GFP_DMA allocation. I guess you have already reported
this failure and you've been told that this is quite unexpected for the
kernel stack allocation. It is your out-of-tree patch which just makes
things worse because DMA restricted allocations are considered "lowmem"
and so they do not invoke OOM killer and do not retry like regular
GFP_KERNEL allocations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
