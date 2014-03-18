Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D4DF96B0102
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:02:07 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so7388021pad.28
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 07:02:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xr10si12561280pab.439.2014.03.18.07.02.05
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 07:02:06 -0700 (PDT)
Date: Tue, 18 Mar 2014 10:00:34 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
Message-ID: <20140318140034.GH6091@linux.intel.com>
References: <4C30833E5CDF444D84D942543DF65BDA625BD721@G4W3303.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C30833E5CDF444D84D942543DF65BDA625BD721@G4W3303.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zuckerman, Boris" <borisz@hp.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 18, 2014 at 01:10:44PM +0000, Zuckerman, Boris wrote:
> X86 cache lines are much smaller than a page. Cache lined are flushed "naturally", but we do not know about that.
> How many Dirty pages do we anticipate? What is the performance cost of msync()? Is that higher, if we do page-based accounting?

The number of dirty pages is going to depend on the workload.  The problem
with looking at today's workloads as an approximation of what workloads
will look like is that people will optimise their software for persistent
memory once persistent memory becomes more widely available.  So all
we can do is point out "hey, you have a lot of dirty pages, maybe you'd
like to change your algorithms".

> Reasons and frequency of msync():
> Atomicity: needs barriers, happens frequently, leaves relatively small number of Dirty pages. Here the cost is probably smaller. 
> Durability of application updates: issued infrequently, leaves many Dirty pages. The cost could be high, right?

We have two ways on x86 to implement msync.  One is to flush every
cacheline and the other is to flush the entire cache.  If the user asks
to flush a terabyte of memory, it's clearly cheaper to flush the cache.
If the user asks to flush 64 bytes, we should clearly just flush a single
line.  Somewhere in-between there's a cross-over point, and that's going
to depend on the size of the CPU's cache, the nature of the workload,
and a few other factors.  I'm not worrying about where that is right now,
because we can't make that decision without first tracking which pages
are dirty and which are clean.

> Let's assume that at some point we get CPU/Persistent Memory Controller
> combinations that support atomicity of multiple updates in hardware. Would
> you need to mark pages Dirty in such cases? If not, what is the right
> layer build that support for x86?

Regardless of future hardware innovations, we need to support the
semantics of msync().  That is, if the user calls msync(), sees that
it has successfully synced a range of data to media, and then after a
reboot discovers that all or part of that msync hadn't actually happened,
we're going to have a very unhappy user on our hands.

If we have a write-through cache, then we don't need to implement
dirty bit tracking.  But my impression is that write-through caches are
significantly worse performing than write-back, so I don't intend to
optimise for them.

If there's some fancy new hardware that lets you do an update of multiple
cachelines atomically and persistently, then I guess the software will
be calling that instead of msync(), so the question about whether msync()
would need to flush the cachelines for that page won't actually arise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
