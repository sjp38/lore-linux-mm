Date: Fri, 14 Dec 2007 18:02:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-Id: <20071214180206.e0325503.akpm@linux-foundation.org>
In-Reply-To: <20071215010940.GB28613@csn.ul.ie>
References: <476188C4.9030802@rtr.ca>
	<20071213193937.GG10104@kernel.dk>
	<47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
	<20071213142935.47ff19d9.akpm@linux-foundation.org>
	<20071215010940.GB28613@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, jens.axboe@oracle.com, liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Dec 2007 01:09:41 +0000 Mel Gorman <mel@csn.ul.ie> wrote:

> On (13/12/07 14:29), Andrew Morton didst pronounce:
> > > The simple way seems to be to malloc a large area, touch every page and
> > > then look at the physical pages assigned ... they now mostly seem to be
> > > descending in physical address.
> > > 
> > 
> > OIC.  -mm's /proc/pid/pagemap can be used to get the pfn's...
> > 
> 
> I tried using pagemap to verify the patch but it triggered BUG_ON
> checks. Perhaps I am using the interface wrong but I would still not
> expect it to break in this fashion. I tried 2.6.24-rc4-mm1, 2.6.24-rc5-mm1,
> 2.6.24-rc5 with just the maps4 patches applied and 2.6.23 with maps4 patches
> applied. Each time I get errors like this;
> 
> [   90.108315] BUG: sleeping function called from invalid context at include/asm/uaccess_32.h:457
> [   90.211227] in_atomic():1, irqs_disabled():0
> [   90.262251] no locks held by showcontiguous/2814.
> [   90.318475] Pid: 2814, comm: showcontiguous Not tainted 2.6.24-rc5 #1
> [   90.395344]  [<c010522a>] show_trace_log_lvl+0x1a/0x30
> [   90.456948]  [<c0105bb2>] show_trace+0x12/0x20
> [   90.510173]  [<c0105eee>] dump_stack+0x6e/0x80
> [   90.563409]  [<c01205b3>] __might_sleep+0xc3/0xe0
> [   90.619765]  [<c02264fd>] copy_to_user+0x3d/0x60
> [   90.675153]  [<c01b3e9c>] add_to_pagemap+0x5c/0x80
> [   90.732513]  [<c01b43e8>] pagemap_pte_range+0x68/0xb0
> [   90.793010]  [<c0175ed2>] walk_page_range+0x112/0x210
> [   90.853482]  [<c01b47c6>] pagemap_read+0x176/0x220
> [   90.910863]  [<c0182dc4>] vfs_read+0x94/0x150
> [   90.963058]  [<c01832fd>] sys_read+0x3d/0x70
> [   91.014219]  [<c0104262>] syscall_call+0x7/0xb
> 
> ...
>
> Just using cp to read the file is enough to cause problems but I included
> a very basic program below that produces the BUG_ON checks. Is this a known
> issue or am I using the interface incorrectly?

I'd say you're using it correctly but you've found a hitherto unknown bug. 
On i386 highmem machines with CONFIG_HIGHPTE (at least) pte_offset_map()
takes kmap_atomic(), so pagemap_pte_range() can't do copy_to_user() as it
presently does.

Drat.

Still, that shouldn't really disrupt the testing which you're doing.  You
could disable CONFIG_HIGHPTE to shut it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
