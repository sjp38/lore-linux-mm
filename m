Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EF34C6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:42:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0gVUn016844
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:42:31 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7A8E45DE61
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:42:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 694C445DE55
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:42:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33557E08008
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:42:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16461E18001
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:42:29 +0900 (JST)
Date: Wed, 24 Nov 2010 09:36:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] big chunk memory allocator v4
Message-Id: <20101124093653.bb8692e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <op.vmmre1vv7p4s8u@pikus>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119125653.16dd5452.akpm@linux-foundation.org>
	<20101122090431.4ff9c941.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vmmre1vv7p4s8u@pikus>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 16:46:03 +0100
MichaA? Nazarewicz <m.nazarewicz@samsung.com> wrote:

> A few things than:
> 
> 1. As Felipe mentioned, on ARM it is often desired to have the memory
>     mapped as non-cacheable, which most often mean that the memory never
>     reaches the page allocator.  This means, that alloc_contig_pages()
>     would not be suitable for cases where one needs such memory.
> 
>     Or could this be overcome by adding the memory back as highmem?  But
>     then, it would force to compile in highmem support even if platform
>     does not really need it.
> 
> 2. Device drivers should not by themselves know what ranges of memory to
>     allocate memory from.  Moreover, some device drivers could require
>     allocation different buffers from different ranges.  As such, this
>     would require some management code on top of alloc_contig_pages().
> 
> 3. When posting hwmem, Johan Mossberg mentioned that he'd like to see
>     notion of "pinning" chunks (so that not-pinned chunks can be moved
>     around when hardware does not use them to defragment memory).  This
>     would again require some management code on top of
>     alloc_contig_pages().
> 
> 4. I might be mistaken here, but the way I understand ZONE_MOVABLE work
>     is that it is cut of from the end of memory.  Or am I talking nonsense?
>     My concern is that at least one chip I'm working with requires
>     allocations from different memory banks which would basically mean that
>     there would have to be two movable zones, ie:
> 
>     +-------------------+-------------------+
>     | Memory Bank #1    | Memory Bank #2    |
>     +---------+---------+---------+---------+
>     | normal  | movable | normal  | movable |
>     +---------+---------+---------+---------+
> 
yes.

> So even though I'm personally somehow drawn by alloc_contig_pages()'s
> simplicity (compared to CMA at least), those quick thoughts make me think
> that alloc_contig_pages() would work rather as a backend (as Kamezawa
> mentioned) for some, maybe even tiny but still present, management code
> which would handle "marking memory fragments as ZONE_MOVABLE" (whatever
> that would involve) and deciding which memory ranges drivers can allocate
> from.
> 
> I'm also wondering whether alloc_contig_pages()'s first-fit is suitable but
> that probably cannot be judged without some benchmarks.
> 

I'll continue to update patches, you can freely reuse my code and integrate
this set to yours. I works for this firstly for EMBEDED but I want this to be
a _generic_ function for gerenal purpose architecture.
There may be guys who want 1G page on a host with tons of free memory.


Thanks,
-Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
