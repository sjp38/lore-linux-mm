Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8CC0A6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:21:45 -0400 (EDT)
Received: by obbta14 with SMTP id ta14so1322829obb.14
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 19:21:44 -0700 (PDT)
Date: Thu, 14 Jun 2012 11:21:32 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: add gfp_mask parameter to vm_map_ram()
Message-ID: <20120614022132.GA3766@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120612012134.GA7706@localhost>
 <20120613123932.GA1445@localhost>
 <20120614012026.GL3019@devil.redhat.com>
 <20120614014902.GB7289@localhost>
 <4FD94779.3030108@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD94779.3030108@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com

Hello, guys.

On Thu, Jun 14, 2012 at 11:07:53AM +0900, Minchan Kim wrote:
> It shouldn't work because vmap_page_range still can allocate
> GFP_KERNEL by pud_alloc in vmap_pud_range.  For it, I tried [1] but
> other mm guys want to add WARNING [2] so let's avoiding gfp context
> passing.
> 
> [1] https://lkml.org/lkml/2012/4/23/77
> [2] https://lkml.org/lkml/2012/5/2/340

Yeah, vmalloc area doesn't support !GFP_KERNEL allocations and as
Minchan said, changing this would require updating page table
allocation functions on all archs.  This is the same reason why percpu
allocator doesn't support !GFP_KERNEL allocations which in turn made
blk-throttle implement its own private percpu pool.

If xfs can't live without GFP_NOFS vmalloc allocations, either it has
to implement its own pool or maybe it's time to implement !GFP_KERNEL
allocs for vmalloc area.  I don't know.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
