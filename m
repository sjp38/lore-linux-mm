Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C15426B007D
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 03:24:01 -0500 (EST)
Date: Thu, 28 Jan 2010 00:23:55 -0800 (PST)
From: Steve VanDeBogart <vandebo-lkml@NerdBox.Net>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
In-Reply-To: <20100127181424.GA21585@shareable.org>
Message-ID: <alpine.DEB.1.00.1001272343050.2909@abydos.NerdBox.Net>
References: <20100120215712.GO27212@frostnet.net> <20100127181424.GA21585@shareable.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Chris Frost <frost@cs.ucla.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010, Jamie Lokier wrote:

> Chris Frost wrote:
>> We introduced this system call while modifying SQLite and the GIMP to
>> request large prefetches for what would otherwise be non-sequential reads.
>> As a macrobenchmark, we see a 125s SQLite query (72s system time) reduced
>> to 75s (18s system time) by using fincore() instead of mincore(). This
>> speedup of course varies by benchmark and benchmarks size; we've seen
>> both minimal speedups and 1000x speedups. More on these benchmarks in the
>> publication _Reducing Seek Overhead with Application-Directed Prefetching_
>> in USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.
>
> My first thought was:
>
> Why is calling fincore() and then issuing reads better than simply
> calling readahead() on the same range?  I.e. why is readahead() (or
> POSIX_FADV_WILLNEED) unsuitable to give the same result?  Or even
> issuing lots of AIO requests.

A stupid example can illustrate the difference.  If you have X bytes
of RAM, and have a file 10 X in size, reading the entire thing in
before accessing it will only hurt performance. (The same situation
where an MRU replacement policy can perform better then a strict LRU
policy.) In other words, using fincore helps the prefetching library
figure out how much to prefetch to optimize performance.

> I knew that I was missing something, so I read the paper ;-) I don't
> fully understand it, but *think* that it says fincore() is used to
> detect when the kernel is evicting pages faster than libprefetch had
> planned for, implying memory pressure, so it adjusts its planning in
> response.

In some sense, yes.  At core, Libprefetch uses fincore to detect how much 
memory can be used for prefetching.  We can ask proc how much is 
free and how much is in buffers, but memory use is dynamic, so
libprefetch must monitor it and react appropriately.

> Interesting idea, though I wonder if it wouldn't be even better to
> have a direct way to ask the kernel "tell me when there is memory
> pressure causing my file to be evicted".

Such an interface sounds fairly specialized. It's possible that it would
be more efficient for this particular purpose, but useless for other,
related, purposes.  For example, if you want to backup a file without
polluting the buffer cache: before accessing each page of the file,
fincore that page, send it to the backup device, then restore the page
to its previous state with fadvise.  fincore is obviously modelled on
mincore, which has stood the test of time as an interface. Even if you
don't like the mincore/fincore interface, you have to admit it can't be
that bad because no replacement interface has been accepted.

--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
