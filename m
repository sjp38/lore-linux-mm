Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0946B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:44:15 -0400 (EDT)
Date: Thu, 9 Jun 2011 16:44:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix negative commitlimit when gigantic hugepages
 are allocated
Message-Id: <20110609164408.8370746e.akpm@linux-foundation.org>
In-Reply-To: <20110603025555.GA10530@optiplex.tchesoft.com>
References: <20110518153445.GA18127@sgi.com>
	<BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
	<20110519045630.GA22533@sgi.com>
	<BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
	<20110519221101.GC19648@sgi.com>
	<20110520130411.d1e0baef.akpm@linux-foundation.org>
	<20110520223032.GA15192@x61.tchesoft.com>
	<20110526210751.GA14819@optiplex.tchesoft.com>
	<20110602040821.GA7934@sgi.com>
	<20110603025555.GA10530@optiplex.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aquini@linux.com
Cc: Russ Anderson <rja@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, rja@americas.sgi.com

On Thu, 2 Jun 2011 23:55:57 -0300
Rafael Aquini <aquini@linux.com> wrote:

> When 1GB hugepages are allocated on a system, free(1) reports
> less available memory than what really is installed in the box.
> Also, if the total size of hugepages allocated on a system is
> over half of the total memory size, CommitLimit becomes
> a negative number.
> 
> The problem is that gigantic hugepages (order > MAX_ORDER)
> can only be allocated at boot with bootmem, thus its frames
> are not accounted to 'totalram_pages'. However,  they are
> accounted to hugetlb_total_pages()
> 
> What happens to turn CommitLimit into a negative number
> is this calculation, in fs/proc/meminfo.c:
> 
>         allowed = ((totalram_pages - hugetlb_total_pages())
>                 * sysctl_overcommit_ratio / 100) + total_swap_pages;
> 
> A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.
> 
> Also, every vm statistic which depends on 'totalram_pages' will render
> confusing values, as if system were 'missing' some part of its memory.

Is this bug serious enough to justify backporting the fix into -stable
kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
