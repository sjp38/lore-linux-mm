Date: Mon, 25 Sep 2000 17:36:56 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925173656.C25814@athlon.random>
References: <20000925034551.C10381@athlon.random> <Pine.LNX.4.21.0009242306220.2029-200000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242306220.2029-200000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Sun, Sep 24, 2000 at 11:39:13PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 11:39:13PM -0300, Marcelo Tosatti wrote:
> - Change kmem_cache_shrink to return the number of freed pages. 

I did that too extending a patch from Mark. I also removed the first_not_full
ugliness providing a LIFO behaviour to the completly freed slabs (so
kmem_cache_reap removes the oldest completly unused slabs from the queue, not
the most recently used ones with potentially live cache in the CPU). 

> There was a comment on the shrink functions about making
> kmem_cache_shrink() work on a GFP_DMA/GFP_HIGHMEM basis to free only the
> wanted pages by the current allocation. 

This is meaningless at the moment because it can't be addressed without
classzone logic in the allocator (classzone means that the allocator will pass
to the memory balancing code the information about _which_ classzone you have
to allocate memory from, so you won't waste time to synchronously balance
unrelated zones).

My patch is here (it isn't going to apply cleanly due the test9 changes
in do_try_to_free_pages but porting is trivial). It was tested and
it was working for me.

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test7/slab-1

BTW, here there's a fix for a longstanding SMP race (since swap_out and msync
doesn't run with the big lock) that can corrupt memory: 

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test5/msync-smp-race-1

Here the fix for another SMP race in enstablish_pte:

	ftp://ftp.uskernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test5/tlb-flush-smp-race-1

The fix for this last bit is ugly bit it's safe because Manfred said s390 have
a flush_tlb_page that atomically flushes and makees the pte invalid (cleaner
fix means moving part of enstablish_pte into the arch inlines).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
