Date: Wed, 5 May 2004 12:50:18 -0400 (EDT)
From: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Subject: Re: 2.6.6-rc3-mm1
Message-ID: <Pine.GSO.4.58.0405051231470.28174@azure.engin.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hch@infradead.org
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> +rmap-14-i_shared_lock-fixes.patch
>> +rmap-15-vma_adjust.patch
>> +rmap-16-pretend-prio_tree.patch
>> +rmap-17-real-prio_tree.patch
>> +rmap-18-i_mmap_nonlinear.patch
>> +rmap-19-arch-prio_tree.patch
>>
>>  More VM work from Hugh
>
> That's about 600 lines of additional code.

Agreed.

> And that prio tree code is
> used a lot, so even worse for that caches.

The prio tree code is designed to handle common cases (almost)
as well as the simple i_mmap lists. Although we add 600 lines
of code, many parts of the additional code are not exercised
in the common paths. In common cases, the tree has only one
or two nodes and all other vmas hang from these tree nodes
(check vm_set.list). So it more looks (and performs) like a
single list or two lists.

In cases where all processes map the same set of pages from a
file (e.g., libc), plain i_mmap lists are the best for objrmap.
I think we cannot do any better than a simple list in these cases.
The prio tree patch tries emulate a simple list in such cases.

My kernel compile tests with and without these patches did not
show much performance difference. The overhead due to prio tree
is in the noise level for kernel compiles. Martin's SDET tests
(after converting i_shared_sem to i_shared_lock) showed that
prio tree patch does not affect performance.

> Do we have some benchmarks of real-life situation where the prio trees
> show a big enough improvement or some 'exploits' where the linear list
> walking leads to DoS situtations?

Please check the first prio tree patch post. You will find pointers
to programs developed by Andrew and Ingo that show poor performance
of linear lists.

The first prio tree patch post link:

http://marc.theaimsgroup.com/?l=linux-kernel&m=107990752323873

Overall, prio tree patch increases kernel size. However, it seems not
to affect performance in the common cases. In addition, it handles
corner cases pretty well. I am confident that prio tree does not
affect performance significantly in the common cases. However, futher
testing may prove me wrong. I agree that these patches should
be ripped out of the kernel if someone shows significantly poor
performance or we find an easier way to handle corner cases.

Thanks,
Rajesh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
