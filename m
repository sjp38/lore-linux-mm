Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9B1936B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 21:35:16 -0500 (EST)
Date: Thu, 7 Mar 2013 21:35:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Swap defragging
Message-ID: <20130308023511.GD23767@cmpxchg.org>
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
> Just a two cent question, but is there any merit to having the kernel
> defragment swap space?

That is a good question.

Swap does fragment quite a bit, and there are several reasons for
that.

We swap pages in our LRU list order, but this list is sorted by first
access, not by access frequency (not quite that cookie cutter, but the
ordering is certainly fairly coarse).  This means that the pages may
already be in suboptimal order for swap in at the time of swap out.

Once written to disk, the layout tends to stick.  One reason is that
we actually try to not free swap slots unless there is a shortage of
swap space to save future swap out IO (grep for vm_swap_full()).  The
other reason is that if a page shared among multiple threads is
swapped out, it can not be removed from swap until all threads have
faulted the page back in because of page table entries still referring
to the swap slot on disk.  In a multi-threaded application, this is
rather unlikely.

So even though the referencing order of the application might change,
the disk layout won't.  But adjusting the disk layout speculatively
increases disk IO, so it could be hard to prove that you came up with
a net improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
