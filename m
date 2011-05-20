Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 976CD8D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:04:13 -0400 (EDT)
Date: Fri, 20 May 2011 13:04:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
Message-Id: <20110520130411.d1e0baef.akpm@linux-foundation.org>
In-Reply-To: <20110519221101.GC19648@sgi.com>
References: <20110518153445.GA18127@sgi.com>
	<BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
	<20110519045630.GA22533@sgi.com>
	<BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
	<20110519221101.GC19648@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Rafael Aquini <aquini@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>

On Thu, 19 May 2011 17:11:01 -0500
Russ Anderson <rja@sgi.com> wrote:

> OK, I see your point.  The root problem is hugepages allocated at boot are
> subtracted from totalram_pages but hugepages allocated at run time are not.
> Correct me if I've mistate it or are other conditions.
> 
> By "allocated at run time" I mean "echo 1 > /proc/sys/vm/nr_hugepages".
> That allocation will not change totalram_pages but will change
> hugetlb_total_pages().
> 
> How best to fix this inconsistency?  Should totalram_pages include or exclude
> hugepages?  What are the implications?

The problem is that hugetlb_total_pages() is trying to account for two
different things, while totalram_pages accounts for only one of those
things, yes?

One fix would be to stop accounting for huge pages in totalram_pages
altogether.  That might break other things so careful checking would be
needed.

Or we stop accounting for the boot-time allocated huge pages in
hugetlb_total_pages().  Split the two things apart altogether and
account for boot-time allocated and runtime-allocated pages separately.  This
souds saner to me - it reflects what's actually happening in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
