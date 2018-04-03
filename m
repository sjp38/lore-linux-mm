Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8EE56B000A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:06:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i4so9403918wrh.4
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:06:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si221578wmh.46.2018.04.03.04.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 04:06:16 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:06:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403110612.GM5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330102038.2378925b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Fri 30-03-18 10:20:38, Steven Rostedt wrote:
> 
> [ Adding memory management folks to discuss the issue ]
> 
> On Thu, 29 Mar 2018 18:41:44 +0800
> Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
> 
> > It is reported that some user app would like to echo a huge
> > number to "/sys/kernel/debug/tracing/buffer_size_kb" regardless
> >  of the available memory, which will cause the coinstantaneous
> > page allocation failed and introduce OOM. The commit checking the
> > val against the available mem first to avoid the consequence allocation.
> > 
> > Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> > ---
> >  kernel/trace/trace.c | 39 ++++++++++++++++++++++++++++++++++++++-
> >  1 file changed, 38 insertions(+), 1 deletion(-)
> > 
> > diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
> > index 2d0ffcc..a4a4237 100644
> > --- a/kernel/trace/trace.c
> > +++ b/kernel/trace/trace.c
> > @@ -43,6 +43,8 @@
> >  #include <linux/trace.h>
> >  #include <linux/sched/rt.h>
> >  
> > +#include <linux/mm.h>
> > +#include <linux/swap.h>
> >  #include "trace.h"
> >  #include "trace_output.h"
> >  
> > @@ -5967,6 +5969,39 @@ static ssize_t tracing_splice_read_pipe(struct file *filp,
> >  	return ret;
> >  }
> >  
> > +static long get_available_mem(void)
> > +{
> > +	struct sysinfo i;
> > +	long available;
> > +	unsigned long pagecache;
> > +	unsigned long wmark_low = 0;
> > +	unsigned long pages[NR_LRU_LISTS];
> > +	struct zone *zone;
> > +	int lru;
> > +
> > +	si_meminfo(&i);
> > +	si_swapinfo(&i);
> > +
> > +	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
> > +		pages[lru] = global_page_state(NR_LRU_BASE + lru);
> > +
> > +	for_each_zone(zone)
> > +		wmark_low += zone->watermark[WMARK_LOW];
> > +
> > +	available = i.freeram - wmark_low;
> > +
> > +	pagecache = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
> > +	pagecache -= min(pagecache / 2, wmark_low);
> > +	available += pagecache;
> > +
> > +	available += global_page_state(NR_SLAB_RECLAIMABLE) -
> > +		min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
> > +
> > +	if (available < 0)
> > +		available = 0;
> > +	return available;
> > +}
> > +
> 
> As I stated in my other reply, the above function does not belong in
> tracing.
> 
> That said, it appears you are having issues that were caused by the
> change by commit 848618857d2 ("tracing/ring_buffer: Try harder to
> allocate"), where we replaced NORETRY with RETRY_MAYFAIL. The point of
> NORETRY was to keep allocations of the tracing ring-buffer from causing
> OOMs. But the RETRY was too strong in that case, because there were
> those that wanted to allocate large ring buffers but it would fail due
> to memory being used that could be reclaimed. Supposedly, RETRY_MAYFAIL
> is to allocate with reclaim but still allow to fail, and isn't suppose
> to trigger an OOM. From my own tests, this is obviously not the case.
> 
> Perhaps this is because the ring buffer allocates one page at a time,
> and by doing so, it can get every last available page, and if anything
> in the mean time does an allocation without MAYFAIL, it will cause an
> OOM. For example, when I stressed this I triggered this:

Yes, this is indeed the case.

>  pool invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
>  pool cpuset=/ mems_allowed=0
>  CPU: 7 PID: 1040 Comm: pool Not tainted 4.16.0-rc4-test+ #663
>  Hardware name: Hewlett-Packard HP Compaq Pro 6300 SFF/339A, BIOS K01 v03.03 07/14/2016
>  Call Trace:
>   dump_stack+0x8e/0xce
>   dump_header.isra.30+0x6e/0x28f
>   ? _raw_spin_unlock_irqrestore+0x30/0x60
>   oom_kill_process+0x218/0x400
>   ? has_capability_noaudit+0x17/0x20
>   out_of_memory+0xe3/0x5c0
>   __alloc_pages_slowpath+0xa8e/0xe50
>   __alloc_pages_nodemask+0x206/0x220
>   alloc_pages_current+0x6a/0xe0
>   __page_cache_alloc+0x6a/0xa0
>   filemap_fault+0x208/0x5f0
>   ? __might_sleep+0x4a/0x80
>   ext4_filemap_fault+0x31/0x44
>   __do_fault+0x20/0xd0
>   __handle_mm_fault+0xc08/0x1160
>   handle_mm_fault+0x76/0x110
>   __do_page_fault+0x299/0x580
>   do_page_fault+0x2d/0x110
>   ? page_fault+0x2f/0x50
>   page_fault+0x45/0x50
> 
> I wonder if I should have the ring buffer allocate groups of pages, to
> avoid this. Or try to allocate with NORETRY, one page at a time, and
> when that fails, allocate groups of pages with RETRY_MAYFAIL, and that
> may keep it from causing an OOM?

I wonder why it really matters. The interface is root only and we expect
some sanity from an admin, right? So allocating such a large ring buffer
that it sends the system to the OOM is a sign that the admin should be
more careful. Balancing on the OOM edge is always a risk and the result
will highly depend on the workload running in parallel.
-- 
Michal Hocko
SUSE Labs
