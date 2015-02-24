Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E0D8C6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 06:25:10 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id i50so29222682qgf.0
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:25:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v7si33084036qav.36.2015.02.24.03.25.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 03:25:10 -0800 (PST)
Date: Tue, 24 Feb 2015 12:24:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-ID: <20150224112412.GG5542@redhat.com>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424731603.6539.51.camel@stgolabs.net>
 <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
 <54EC533E.8040805@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54EC533E.8040805@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

Hi everyone,

On Tue, Feb 24, 2015 at 11:32:30AM +0100, Vlastimil Babka wrote:
> I would suspect mmap_sem being held during whole THP page fault 
> (including the needed reclaim and compaction), which I forgot to mention 
> in the first e-mail - it's not just the problem page fault latency, but 
> also potentially holding back other processes, why we should allow 
> shifting from THP page faults to deferred collapsing.
> Although the attempts for opportunistic page faults without mmap_sem 
> would also help in this particular case.
> 
> Khugepaged also used to hold mmap_sem (for read) during the allocation 
> attempt, but that was fixed since then. It could be also zone lru_lock 
> pressure.

I'm traveling and I didn't have much time to read the code yet but if
I understood well the proposal, I've some doubt boosting khugepaged
CPU utilization is going to provide a better universal trade off. I
think the low overhead background scan is safer default.

If we want to do more async background work and less "synchronous work
at fault time", what may be more interesting is to generate
transparent hugepages in the background and possibly not to invoke
compaction (or much compaction) in the page faults.

I'd rather move compaction to a background kernel thread, and to
invoke compaction synchronously only in khugepaged. I like it more if
nothing else because it is a kind of background load that can come to
a full stop, once enough THP have been created. Unlike khugepaged that
can never stop to scan and it better be lightweight kind of background
load, as it'd be running all the time.

Creating THP through khugepaged is much more expensive than creating
them on page faults. khugepaged will need to halt the userland access
on the range once more and it'll have to copy the 2MB.

Overall I agree with Andi we need more data collected for various
workloads before embarking into big changes, at least so we can proof
the changes to be beneficial to those workloads.

I would advise not to make changes for app that are already the
biggest users ever of hugetlbfs (like Oracle). Those already are
optimized by other means. THP target are apps that have several
benefit in not ever using hugetlbfs, so apps that are more dynamic
workloads that don't fit well with NUMA hard pinning with numactl or
other static placements of memory and CPU.

There are also other corner cases to optimize, that have nothing to do
with khugepaged nor compaction: for example redis has issues in the
way it forks() and then uses the child memory as a snapshot while the
parent keeps running and writing to the memory. If THP is enabled, the
parent that writes to the memory will allocate and copy 2MB objects
instead of 4k objects. That means more memory utilization but
especially the problem are those copy_user of 2MB instead of 4k hurting
the parent runtime.

For redis we need a more finegrined thing than MADV_NOHUGEPAGE. It
needs a MADV_COW_NOHUGEPAGE (please think at a better name) that will
only prevent THP creation during COW faults but still maximize THP
utilization for every other case. Once such a madvise will become
available, redis will run faster with THP enabled (currently redis
recommends THP disabled because of the higher latencies in the 2MB COW
faults while the child process is snapshotting). When the snapshot is
finished and the child quits, khugepaged will recreate THP for those
fragmented cows.

OTOH redis could also use the userfaultfd to do the snapshotting and
it could avoid fork in the first place, after I add UFFDIO_WP ioctl to
mark and unmark the memory wrprotected or not without altering the
vma, while catching the faults with read or POLLIN on the ufd to copy
the memory off before removing the wrprotection. The real problem to
fully implement the UFFDIO_WP will be the swapcache and swapouts: swap
entries have no wrprotection bit to know if to fire wrprotected
userfaults on write faults, if the range is registered as
uffdio_register.mode & UFFDIO_REGISTER_MODE_WP. So far I only
implemented in full the UFFDIO_REGISTER_MODE_MISSING tracking mode, so
I didn't need to attack the wrprotected swapentry thingy, but the new
userfaultfd API already is ready to implement all write protection (or
any other faulting reason) as well and it can incrementally be
extended to different memory types (tmpfs etc..) without backwards
compatibility issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
