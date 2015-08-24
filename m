Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8871C6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:58:14 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so62460476wic.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 23:58:14 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id f5si19767479wiz.82.2015.08.23.23.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 23:58:13 -0700 (PDT)
Received: by wijp15 with SMTP id p15so67651966wij.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 23:58:12 -0700 (PDT)
Date: Mon, 24 Aug 2015 08:58:09 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150824065809.GA13082@gmail.com>
References: <20150823060443.GA9882@gmail.com>
 <20150823064603.14050.qmail@ns.horizon.com>
 <20150823081750.GA28349@gmail.com>
 <87lhd1wwtz.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lhd1wwtz.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> On Sun, Aug 23 2015, Ingo Molnar <mingo@kernel.org> wrote:
> 
> > Ok, fair enough - so how about the attached approach instead, which
> > uses a 64-bit generation counter to track changes to the vmalloc
> > state.
> 
> How does this invalidation approach compare to the jiffies approach? In
> other words, how often does the vmalloc info actually change (or rather,
> in this approximation, how often is vmap_area_lock taken)? In
> particular, does it also solve the problem with git's test suite and
> similar situations with lots of short-lived processes?

The two approaches are pretty similar, and in a typical distro with typical 
workload vmalloc() is mostly a boot time affair.

But vmalloc() can be used more often in certain corner cases - neither of the 
patches makes that in any way slower, just the optimization won't trigger that 
often.

Since vmalloc() use is suboptimal for several reasons (it does not use large pages 
for kernel space allocations, etc.), this is all pretty OK IMHO.

> > ==============================>
> > From f9fd770e75e2edb4143f32ced0b53d7a77969c94 Mon Sep 17 00:00:00 2001
> > From: Ingo Molnar <mingo@kernel.org>
> > Date: Sat, 22 Aug 2015 12:28:01 +0200
> > Subject: [PATCH] mm/vmalloc: Cache the vmalloc memory info
> >
> > Linus reported that glibc (rather stupidly) reads /proc/meminfo
> > for every sysinfo() call,
> 
> Not quite: It is done by the two functions get_{av,}phys_pages
> functions; and get_phys_pages is called (once per process) by glibc's
> qsort implementation. In fact, sysinfo() is (at least part of) the cure,
> not the disease. Whether qsort should care about the total amount of
> memory is another discussion.
> 
> <http://thread.gmane.org/gmane.comp.lib.glibc.alpha/54342/focus=54558>

Thanks, is the fixed up changelog below better?

	Ingo

===============>

mm/vmalloc: Cache the vmalloc memory info

Linus reported that for scripting-intense workloads such as the
Git build, glibc's qsort will read /proc/meminfo for every process
created (by way of get_phys_pages()), which causes the Git build 
to generate a surprising amount of kernel overhead.

A fair chunk of the overhead is due to get_vmalloc_info() - which 
walks a potentially long list to do its statistics.

Modify Linus's jiffies based patch to use generation counters
to cache the vmalloc info: vmap_unlock() increases the generation
counter, and the get_vmalloc_info() reads it and compares it
against a cached generation counter.

Also use a seqlock to make sure we always print a consistent
set of vmalloc statistics.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
