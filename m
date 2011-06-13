Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97A52900117
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 17:32:18 -0400 (EDT)
Date: Mon, 13 Jun 2011 14:31:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix negative commitlimit when gigantic hugepages
 are allocated
Message-Id: <20110613143144.c457ff42.akpm@linux-foundation.org>
In-Reply-To: <20110613211153.GA23597@optiplex.tchesoft.com>
References: <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
	<20110519045630.GA22533@sgi.com>
	<BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
	<20110519221101.GC19648@sgi.com>
	<20110520130411.d1e0baef.akpm@linux-foundation.org>
	<20110520223032.GA15192@x61.tchesoft.com>
	<20110526210751.GA14819@optiplex.tchesoft.com>
	<20110602040821.GA7934@sgi.com>
	<20110603025555.GA10530@optiplex.tchesoft.com>
	<20110609164408.8370746e.akpm@linux-foundation.org>
	<20110613211153.GA23597@optiplex.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aquini@linux.com
Cc: Russ Anderson <rja@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, rja@americas.sgi.com

On Mon, 13 Jun 2011 18:11:55 -0300
Rafael Aquini <aquini@linux.com> wrote:

> Howdy Andrew,
> 
> Sorry, for this late reply.
> 
> On Thu, Jun 09, 2011 at 04:44:08PM -0700, Andrew Morton wrote:
> > On Thu, 2 Jun 2011 23:55:57 -0300
> > Rafael Aquini <aquini@linux.com> wrote:
> > 
> > > When 1GB hugepages are allocated on a system, free(1) reports
> > > less available memory than what really is installed in the box.
> > > Also, if the total size of hugepages allocated on a system is
> > > over half of the total memory size, CommitLimit becomes
> > > a negative number.
> > > 
> > > The problem is that gigantic hugepages (order > MAX_ORDER)
> > > can only be allocated at boot with bootmem, thus its frames
> > > are not accounted to 'totalram_pages'. However,  they are
> > > accounted to hugetlb_total_pages()
> > > 
> > > What happens to turn CommitLimit into a negative number
> > > is this calculation, in fs/proc/meminfo.c:
> > > 
> > >         allowed = ((totalram_pages - hugetlb_total_pages())
> > >                 * sysctl_overcommit_ratio / 100) + total_swap_pages;
> > > 
> > > A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.
> > > 
> > > Also, every vm statistic which depends on 'totalram_pages' will render
> > > confusing values, as if system were 'missing' some part of its memory.
> > 
> > Is this bug serious enough to justify backporting the fix into -stable
> > kernels?
> 
> Despite not having testing it, I can think the following scenario as
> troublesome:
> When gigantic hugepages are allocated and sysctl_overcommit_memory == OVERCOMMIT_NEVER.
> In a such situation, __vm_enough_memory() goes through the mentioned 'allowed'
> calculation and might end up mistakenly returning -ENOMEM, thus forcing
> the system to start reclaiming pages earlier than it would be ususal, and this could
> cause detrimental impact to overall system's performance, depending on the
> workload.
> 
> Besides the aforementioned scenario, I can only think of this causing annoyances
> with memory reports from /proc/meminfo and free(1).
> 

hm, OK, thanks.  That sounds a bit thin, but the patch is really simple
so I stuck the cc:stable onto its changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
