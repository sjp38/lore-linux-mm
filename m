Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71AF26B0008
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:00:25 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v7-v6so14852635plo.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:00:25 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id z31-v6si31002754plb.15.2018.11.01.03.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:00:24 -0700 (PDT)
Message-ID: <1541066412.31492.10.camel@mtkswgap22>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
From: Miles Chen <miles.chen@mediatek.com>
Date: Thu, 1 Nov 2018 18:00:12 +0800
In-Reply-To: <20181031114107.GM32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
	 <20181029080708.GA32673@dhcp22.suse.cz>
	 <20181029081706.GC32673@dhcp22.suse.cz>
	 <1540862950.12374.40.camel@mtkswgap22>
	 <20181030060601.GR32673@dhcp22.suse.cz>
	 <1540882551.23278.12.camel@mtkswgap22>
	 <20181030081537.GV32673@dhcp22.suse.cz>
	 <1540975637.10275.10.camel@mtkswgap22>
	 <20181031101501.GL32673@dhcp22.suse.cz>
	 <1540981182.16084.1.camel@mtkswgap22>
	 <20181031114107.GM32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Wed, 2018-10-31 at 12:41 +0100, Michal Hocko wrote:
> On Wed 31-10-18 18:19:42, Miles Chen wrote:
> > On Wed, 2018-10-31 at 11:15 +0100, Michal Hocko wrote:
> > > On Wed 31-10-18 16:47:17, Miles Chen wrote:
> > > > On Tue, 2018-10-30 at 09:15 +0100, Michal Hocko wrote:
> > > > > On Tue 30-10-18 14:55:51, Miles Chen wrote:
> > > > > [...]
> > > > > > It's a real problem when using page_owner.
> > > > > > I found this issue recently: I'm not able to read page_owner information
> > > > > > during a overnight test. (error: read failed: Out of memory). I replace
> > > > > > kmalloc() with vmalloc() and it worked well.
> > > > > 
> > > > > Is this with trimming the allocation to a single page and doing shorter
> > > > > than requested reads?
> > > > 
> > > > 
> > > > I printed out the allocate count on my device the request count is <=
> > > > 4096. So I tested this scenario by trimming the count to from 4096 to
> > > > 1024 bytes and it works fine. 
> > > > 
> > > > count = count > 1024? 1024: count;
> > > > 
> > > > It tested it on both 32bit and 64bit kernel.
> > > 
> > > Are you saying that you see OOMs for 4k size?
> > > 
> > yes, because kmalloc only use normal memor, not highmem + normal memory
> > I think that's why vmalloc() works.
> 
> Can I see an OOM report please? I am especially interested that 1k
> doesn't cause the problem because there shouldn't be that much of a
> difference between the two. Larger allocations could be a result of
> memory fragmentation but 1k vs. 4k to make a difference really seems
> unexpected.
> 
You're right.

I pulled out the log and found  that the allocation fail is for order=4.

I found that the if I do the read on the device, the read count is <=
4096; if I do the read by 'adb pull' from my host PC, the read count
becomes 65532. (I'm working on a android device)

The overnight test used 'adb pull' command, so allocation fail occurred
because of the large read count and the arbitrary size allocation design
of page_owner. That also explains why vmalloc() works.

I did a test today, the only code changed is to clamp to read count to
PAGE_SIZE and it worked well. Maybe we can solve this issue by just
clamping the read count.

count = count > PAGE_SIZE ? PAGE_SIZE : count;


Here is the log:

<4>[  261.841770] (0)[2880:sync svc 43]sync svc 43: page allocation
failure: order:4, mode:0x24040c0
<4>[  261.841815]-(0)[2880:sync svc 43]CPU: 0 PID: 2880 Comm: sync svc
43 Tainted: G        W  O    4.4.146+ #16
<4>[  261.841825]-(0)[2880:sync svc 43]Hardware name: Generic DT based
system
<4>[  261.841834]-(0)[2880:sync svc 43]Backtrace:
<4>[  261.841844]-(0)[2880:sync svc 43][<c010d57c>] (dump_backtrace)
from [<c010d7a4>] (show_stack+0x18/0x1c)
<4>[  261.841866]-(0)[2880:sync svc 43] r6:60030013 r5:c123d488
r4:00000000 r3:dc8ba692
<4>[  261.841880]-(0)[2880:sync svc 43][<c010d78c>] (show_stack) from
[<c0470b84>] (dump_stack+0x94/0xa8)
<4>[  261.841892]-(0)[2880:sync svc 43][<c0470af0>] (dump_stack) from
[<c0236060>] (warn_alloc_failed+0x108/0x148)
<4>[  261.841905]-(0)[2880:sync svc 43] r6:00000000 r5:024040c0
r4:c1204948 r3:dc8ba692
<4>[  261.841919]-(0)[2880:sync svc 43][<c0235f5c>] (warn_alloc_failed)
from [<c023a284>] (__alloc_pages_nodemask+0xa08/0xbd8)
<4>[  261.841929]-(0)[2880:sync svc 43] r3:0000000f r2:00000000
<4>[  261.841939]-(0)[2880:sync svc 43] r8:0000002f r7:00000004
r6:dbb7a000 r5:024040c0
<4>[  261.841953]-(0)[2880:sync svc 43][<c023987c>]
(__alloc_pages_nodemask) from [<c023a5fc>] (alloc_kmem_pages+0x18/0x20)
<4>[  261.841963]-(0)[2880:sync svc 43] r10:c0286560 r9:c027b348
r8:0000fff8 r7:00000004
<4>[  261.841978]-(0)[2880:sync svc 43][<c023a5e4>] (alloc_kmem_pages)
from [<c02573c0>] (kmalloc_order_trace+0x2c/0xec)
