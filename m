Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39C8C6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 13:14:42 -0500 (EST)
Date: Wed, 27 Jan 2010 18:14:24 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-ID: <20100127181424.GA21585@shareable.org>
References: <20100120215712.GO27212@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100120215712.GO27212@frostnet.net>
Sender: owner-linux-mm@kvack.org
To: Chris Frost <frost@cs.ucla.edu>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

Chris Frost wrote:
> We introduced this system call while modifying SQLite and the GIMP to
> request large prefetches for what would otherwise be non-sequential reads.
> As a macrobenchmark, we see a 125s SQLite query (72s system time) reduced
> to 75s (18s system time) by using fincore() instead of mincore(). This
> speedup of course varies by benchmark and benchmarks size; we've seen
> both minimal speedups and 1000x speedups. More on these benchmarks in the
> publication _Reducing Seek Overhead with Application-Directed Prefetching_
> in USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.

My first thought was:

Why is calling fincore() and then issuing reads better than simply
calling readahead() on the same range?  I.e. why is readahead() (or
POSIX_FADV_WILLNEED) unsuitable to give the same result?  Or even
issuing lots of AIO requests.

I knew that I was missing something, so I read the paper ;-) I don't
fully understand it, but *think* that it says fincore() is used to
detect when the kernel is evicting pages faster than libprefetch had
planned for, implying memory pressure, so it adjusts its planning in
response.

Interesting idea, though I wonder if it wouldn't be even better to
have a direct way to ask the kernel "tell me when there is memory
pressure causing my file to be evicted".

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
