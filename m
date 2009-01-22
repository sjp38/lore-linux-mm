Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 762276B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:00:21 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so2332695fge.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2009 15:00:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0901221658550.14302@blonde.anvils>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com>
	 <Pine.LNX.4.64.0901221658550.14302@blonde.anvils>
Date: Fri, 23 Jan 2009 01:00:18 +0200
Message-ID: <8c5a844a0901221500m7af8ff45v169b6523ad9d7ad3@mail.gmail.com>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2009 at 7:22 PM, Hugh Dickins <hugh@veritas.com> wrote:
> Do you have some performance figures to support this patch?
> Some of the lmbench tests may be appropriate.
>
> The thing is, expanding vm_area_struct to include another pointer
> will have its own cost, which may well outweigh the efficiency
> (in one particular case) which you're adding.  Expanding mm_struct
> for this would be much more palatable, but I don't think that flies.
>
> And it seems a little greedy to require both an rbtree and a doubly
> linked list for working our way around the vmas.
>
> I suspect that originally your enhancement would only have hit when
> extending the stack: which I guess isn't enough to justify the cost.
> But it could well be that unmapped area handling has grown more
> complex down the years, and you get some hits now from that.
>
Thanks for the reply.
I ran an lmbench test on the 2.6.28 kernel and on the same kernel
after applying the patch.  Here's a portion of the results with the
format of
test : standard kernel / kernel after patch

Simple syscall: 0.7419 / 0.4244 microseconds
Simple read: 1.2071 / 0.7270 microseconds
Simple write: 1.0050 / 0.5879 microseconds
Simple stat: 7.4751 / 4.0744 microseconds
Simple fstat: 0.6659 / 0.6639 microseconds
Simple open/close: 3.6513 / 3.3521 microseconds
Select on 10 fd's: 0.7463 / 0.7951 microseconds
Select on 100 fd's: 2.9897 / 3.0293 microseconds
Select on 250 fd's: 6.5161 / 6.5836 microseconds
Select on 500 fd's: 12.5637 / 12.6398 microseconds
Signal handler installation: 0.6299 / 0.6530 microseconds
Signal handler overhead: 2.2980 / 2.2419 microseconds
Protection fault: 0.4292 / 0.4338 microseconds
Pipe latency: 6.0052 / 5.6193 microseconds
AF_UNIX sock stream latency: 9.2978 / 8.6451 microseconds
Process fork+exit: 127.1951 / 122.6517 microseconds
Process fork+execve: 483.3182 / 462.4583 microseconds
Process fork+/bin/sh -c: 2159.4000 / 2091.6667 microseconds
File /home/daniel/tmp/XXX write bandwidth: 22391 / 23671 KB/sec
Pagefaults on /home/daniel/tmp/XXX: 2.6980 / 3.0795 microseconds

"mappings
0.524288 9.989 / 7.411
1.048576 14 / 12
2.097152 24 / 22
4.194304 43 / 66
8.388608 88 / 73
16.777216 151 / 161
33.554432 289 / 268
67.108864 611 / 518
134.217728 1182 / 1033
268.435456 2342 / 2053
536.870912 4845 / 4105
1073.741824 10726 / 8836

I posted what seemed relevant, are there other results you'd like to see?
I'm not sure what to make of these results, In some places the
difference is rather large, a little to large it seems, in some place
there's no difference and in some places the patch does worse, but in
most places it does better.  Is this one test enough to go on?
In addition, I added some printks to tell me when the mm_cache was
being used by the patch in places that it wouldn't have been used by
the standard kernel.  The mm_cache was used about 4% more with the
patch.

> You mention using the doubly linked list to optimize some other parts
> of mm too: I guess those interfaces where we have to pass around prev
> would be simplified, are you thinking of those, or something else?
>
> (I don't think we need unmap_vmas to go backwards!)
>
> Hugh
>
The main other optimization I was thinking about was the fact that
even if there's no cache hit in find_vma, the rbtree search can be
terminated very quickly due to the fact that we can now be certain
when we're on the right node or in the right neighbourhood.  I was
thinking on implementing that in the next patch.
In addition, we can obviously discard the find_vma_prev function and
clean up code that passes a pointer to prev.
What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
