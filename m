Date: Tue, 8 May 2007 14:35:28 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
Message-ID: <20070508183528.GM355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au> <463E5A00.6070708@redhat.com> <464014B0.7060308@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <464014B0.7060308@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 08, 2007 at 04:12:00PM +1000, Nick Piggin wrote:
> I didn't actually check system and user times for the mysql
> benchmark, but that's exactly what I had in mind when I
> mentioned the poor cache behaviour this patch could cause. I
> definitely did see user times go up in benchmarks where I
> measured.
> 
> We have percpu and cache affine page allocators, so when
> userspace just frees a page, it is likely to be cache hot, so
> we want to free it up so it can be reused by this CPU ASAP.
> Likewise, when we newly allocate a page, we want it to be one
> that is cache hot on this CPU.

malloc has per-thread arenas, so when using MADV_FREE the pages
should be local to the thread as well (unless the thread has switched
to a different CPU also to the CPU) and in case of sysbench should
be cache hot as well (it is reused RSN).  With MADV_DONTNEED you need to
clear the pages while that is not necessary with MADV_FREE.

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
