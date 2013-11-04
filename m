Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2457E6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 02:00:41 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so6569267pab.32
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:00:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id fk10si10003673pab.290.2013.11.03.23.00.39
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 23:00:40 -0800 (PST)
Received: by mail-ee0-f49.google.com with SMTP id e52so875050eek.22
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:00:37 -0800 (PST)
Date: Mon, 4 Nov 2013 08:00:34 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104070034.GD13030@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Sun, 2013-11-03 at 11:12 +0100, Ingo Molnar wrote:
> > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 
> > > While caching the last used vma already does a nice job avoiding
> > > having to iterate the rbtree in find_vma, we can improve. After
> > > studying the hit rate on a load of workloads and environments,
> > > it was seen that it was around 45-50% - constant for a standard
> > > desktop system (gnome3 + evolution + firefox + a few xterms),
> > > and multiple java related workloads (including Hadoop/terasort),
> > > and aim7, which indicates it's better than the 35% value documented
> > > in the code.
> > > 
> > > By also caching the largest vma, that is, the one that contains
> > > most addresses, there is a steady 10-15% hit rate gain, putting
> > > it above the 60% region. This improvement comes at a very low
> > > overhead for a miss. Furthermore, systems with !CONFIG_MMU keep
> > > the current logic.
> > > 
> > > This patch introduces a second mmap_cache pointer, which is just
> > > as racy as the first, but as we already know, doesn't matter in
> > > this context. For documentation purposes, I have also added the
> > > ACCESS_ONCE() around mm->mmap_cache updates, keeping it consistent
> > > with the reads.
> > > 
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Michel Lespinasse <walken@google.com>
> > > Cc: Ingo Molnar <mingo@kernel.org>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > ---
> > > Please note that nommu and unicore32 arch are *untested*.
> > > 
> > > I also have a patch on top of this one that caches the most 
> > > used vma, which adds another 8-10% hit rate gain, However,
> > > since it does add a counter to the vma structure and we have
> > > to do more logic in find_vma to keep track, I was hesitant about
> > > the overhead. If folks are interested I can send that out as well.
> > 
> > Would be interesting to see.
> > 
> > Btw., roughly how many cycles/instructions do we save by increasing 
> > the hit rate, in the typical case (for example during a kernel build)?
> 
> Good point. The IPC from perf stat doesn't show any difference with or 
> without the patch -- note that this is probably the least interesting 
> one as we already get a really nice hit rate with the single mmap_cache. 
> I have yet to try it on the other workloads.

I'd be surprised if this was measureable via perf stat, unless you do the 
measurement in a really, really careful way - and even then it's easy to 
make a hard to detect mistake larger in magnitude than the measured effect 
...

An easier and more reliable measurement would be to stick 2-3 get_cycles() 
calls into the affected code and save the pure timestamps into 
task.se.statistics, and extract the timestamps via /proc/sched_debug by 
adding matching seq_printf()s to kernel/sched/debug.c. (You can clear the 
statistics by echoing 0 to /proc/<PID>/sched_debug, see 
proc_sched_set_task().)

That measurement is still subject to skid and other artifacts but 
hopefully the effect is larger than cycles fuzz - and we are interested in 
a ballpark figure in any case.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
