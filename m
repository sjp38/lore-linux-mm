Message-ID: <4615B79E.9080407@yahoo.com.au>
Date: Fri, 06 Apr 2007 12:59:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <4614A5CC.5080508@redhat.com> <46151F73.50602@redhat.com> <4615B043.8060001@yahoo.com.au> <4615B5D9.7060703@redhat.com>
In-Reply-To: <4615B5D9.7060703@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Jakub Jelinek <jakub@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> Nick Piggin wrote:
> 
>>Cool. According to my thinking, madvise(MADV_DONTNEED) even in today's
>>kernels using down_write(mmap_sem) for MADV_DONTNEED is better than
>>mmap/mprotect, which have more fundamental locking requirements, more
>>overhead and no benefits (except debugging, I suppose).
> 
> 
> It's a tiny bit faster, see
> 
>   http://people.redhat.com/drepper/dontneed.png
> 
> I just ran it once so the graph is not smooth.  This is on a UP dual
> core machine.  Maybe tomorrow I'll turn on the big 4p machine.

Hmm, I saw an improvement, but that was just on a raw syscall test
with a single page chunk. Real-world use I guess will get progressively
less dramatic as other overheads start being introduced.

Multi-thread performance probably won't get a whole lot better (it does
eliminate 1 down_write(mmap_sem), but one remains) until you use my
madvise patch.


> I would have to see dramatically different results on the big machine to
> make me change the libc code.  The reason is that there is a big drawback.
> 
> So far, when we allocate a new arena, we allocate address space with
> PROT_NONE and only when we need memory the protection is changed to
> PROT_READ|PROT_WRITE.  This is the advantage of catching wild pointer
> accesses.

Sure, yes. And I guess you'd always want to keep that options around as
a debugging aid.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
