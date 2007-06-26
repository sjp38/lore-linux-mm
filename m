Message-ID: <4680784F.60607@yahoo.com.au>
Date: Tue, 26 Jun 2007 12:22:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22-rc5-yesterdaygit with VM debug: BUG in mm/rmap.c:66: anon_vma_link
 ?
References: <467F6882.9000800@vmware.com> <Pine.LNX.4.64.0706252129430.22492@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0706252129430.22492@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Petr Vandrovec <petr@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 25 Jun 2007, Petr Vandrovec wrote:
> 
>>Hello,
>>  to catch some memory corruption bug in our code I've modified malloc to do
>>mmap + mprotect - which has unfortunate effect that it creates thousands and
>>thousands of VMAs.  Everything works (though rather slowly on kernel with
>>CONFIG_VM_DEBUG) until application does fork() - kernel crashes on fork()
>>because copy_process()'s anon_vma_link complains that it could not find anon
>>vma after walking through 100000 elements of anon list - which seems strange,
>>as I did not touch system wide limit (which is 65536 vmas), and mprotect()s
>>started failing after creating 65536 vmas, as expected.
>>
>>Full output of test program and full kernel dmesg are at
>>http://buk.vc.cvut.cz/linux/rmap.
> 
> 
> Thanks for finding that, Petr.  Patch below just solves the problem
> by removing validate_anon_vma; but in the past both Nick and Andrea
> have been less eager to delete old debug code than I am, so it would
> be rude to put this patch in without an Ack from at least one of them
> - they may prefer to tinker with the limit instead, but removing the
> whole function is my preference.
> 
> You were puzzled by the numbers.  What happens is that the parent
> builds up to 65536 vmas, and from that point on is not allowed to
> split vmas any more, so the mprotects fail as you expected and
> observed.  But further mmaps succeed, up to your own 131072 limit,
> because each added area can simply extend the last vma.
> 
> All the vmas of interest here (i.e. not the executable, libs, stack
> etc.), for better or worse, share the same anon_vma: so that if
> mprotect were later used to undo the difference between neighbouring
> vmas, they could be merged together - assigning different anon_vmas
> would obstruct that merge (but yes, we've a guessed tradeoff there).
> 
> So the parent has around 65500 vmas all linked to the same anon_vma;
> and in the course of its fork, links the child's dup vmas one by one
> to that same anon_vma, until it hits the validate_anon_vma's 100000
> BUG_ON.  It's very much the nature of the anon_vma, to be shared
> between parent and child: anon pages may be shared between both.
> 
> If we raised the 100000 limit to 2*sysctl_max_map_count, then your
> program would be safe (setting aside changes to that max_map_count),
> but another program in which the child also forked would then BUG.
> 
> 
> 
> [PATCH] kill validate_anon_vma to avoid mapcount BUG

Fine by me. I had been meaning to get rid of that so DEBUG_VM is more
useful to be turned on in betas or even production kernels.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
