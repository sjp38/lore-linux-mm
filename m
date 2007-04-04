Message-ID: <4613660C.5010108@yahoo.com.au>
Date: Wed, 04 Apr 2007 18:47:08 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <461357C4.4010403@yahoo.com.au> <20070404082015.GG355@devserv.devel.redhat.com>
In-Reply-To: <20070404082015.GG355@devserv.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Jakub Jelinek wrote:
> On Wed, Apr 04, 2007 at 05:46:12PM +1000, Nick Piggin wrote:
> 
>>Does mmap(PROT_NONE) actually free the memory?
> 
> 
> Yes.
>         /* Clear old maps */
>         error = -ENOMEM;
> munmap_back:
>         vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
>         if (vma && vma->vm_start < addr + len) {
>                 if (do_munmap(mm, addr, len))
>                         return -ENOMEM;
>                 goto munmap_back;
>         }

Thanks, I overlooked the mmap vs mprotect detail. So how are the subsequent
access faults avoided?


>>In the case of pages being unused then almost immediately reused, why is
>>it a bad solution to avoid freeing? Is it that you want to avoid
>>heuristics because in some cases they could fail and end up using memory?
> 
> 
> free(3) doesn't know if the memory will be reused soon, late or never.
> So avoiding trimming could substantially increase memory consumption with
> certain malloc/free patterns, especially in threaded programs that use
> multiple arenas.  Implementing some sort of deferred memory trimming
> in malloc is "solving" the problem in a wrong place, each app really has no
> idea (and should not have) what the current system memory pressure is.

Thanks for the clarification.


>>Secondly, why is MADV_DONTNEED bad? How much more expensive is a pagefault
>>than a syscall? (including the cost of the TLB fill for the memory access
>>after the syscall, of course).
> 
> 
> That's page fault per page rather than a syscall for the whole chunk,
> furthermore zeroing is expensive.

Ah, for big allocations. OK, we could make a MADV_POPULATE to prefault
pages (like mmap's MAP_POPULATE, but without the down_write(mmap_sem)).

If you're just about to use the pages anyway, how much of a win would
it be to avoid zeroing? We allocate cache hot pages for these guys...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
