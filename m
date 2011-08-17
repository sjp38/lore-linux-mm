Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11CA5900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 18:54:19 -0400 (EDT)
Date: Wed, 17 Aug 2011 15:54:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: Distinguish between mlocked and pinned pages
Message-Id: <20110817155412.cc302033.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1108101516430.20403@router.home>
References: <alpine.DEB.2.00.1108101516430.20403@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Wed, 10 Aug 2011 15:21:47 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> Some kernel components pin user space memory (infiniband and perf)
> (by increasing the page count) and account that memory as "mlocked".
> 
> The difference between mlocking and pinning is:
> 
> A. mlocked pages are marked with PG_mlocked and are exempt from
>    swapping. Page migration may move them around though.
>    They are kept on a special LRU list.
> 
> B. Pinned pages cannot be moved because something needs to
>    directly access physical memory. They may not be on any
>    LRU list.
> 
> I recently saw an mlockalled process where mm->locked_vm became
> bigger than the virtual size of the process (!) because some
> memory was accounted for twice:
> 
> Once when the page was mlocked and once when the Infiniband
> layer increased the refcount because it needt to pin the RDMA
> memory.
> 
> This patch introduces a separate counter for pinned pages and
> accounts them seperately.
> 

Sounds reasonable.  But how do we prevent future confusion?  We should
carefully define these terms in an obvious place, please.

> --- linux-2.6.orig/include/linux/mm_types.h	2011-08-10 14:08:42.000000000 -0500
> +++ linux-2.6/include/linux/mm_types.h	2011-08-10 14:09:02.000000000 -0500
> @@ -281,7 +281,7 @@ struct mm_struct {
>  	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
>  	unsigned long hiwater_vm;	/* High-water virtual memory usage */
> 
> -	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
> +	unsigned long total_vm, locked_vm, pinned_vm, shared_vm, exec_vm;
>  	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
>  	unsigned long start_code, end_code, start_data, end_data;
>  	unsigned long start_brk, brk, start_stack;

This is an obvious place.  Could I ask that you split all these up into
one-definition-per-line and we can start in on properly documenting
each field?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
