Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E63046B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:18:57 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id p22so100902685qka.0
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 07:18:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m26si13133218qtm.22.2017.02.20.07.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 07:18:56 -0800 (PST)
Date: Mon, 20 Feb 2017 16:18:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: userfaultfd UFFDIO_REMAP
Message-ID: <20170220151853.GC25530@redhat.com>
References: <D4CF3398.111DF%louis.krigovski@emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <D4CF3398.111DF%louis.krigovski@emc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "krigovski, louis" <Louis.Krigovski@dell.com>
Cc: linux-mm@kvack.org, Noah Watkins <noahwatkins@gmail.com>, Cyprien Noel <cyprien.noel@gmail.com>

Hello Louis,

CC'ed linux-mm with your ACK as this may be of general interest, plus
CC'ed others that expressed interest in UFFDIO_REMAP use cases.

On Sun, Feb 19, 2017 at 04:35:54PM +0000, krigovski, louis wrote:
> Hi,
> I am looking at your slides from LinuxCon Toronto 2016.
> 
> You mention functionality
> 
>   1.  "Removing the memory atomically... after adding it with UFFDIO_COPY"
> 
> Is this possible? I dona??t see how you can unmap page and give copy of it to the caller.

Originally removing the memory atomically was the only way and there
was not UFFDIO_COPY.

The non linear relocation had some constraint (the source page had to
be not-shared so rmap re-linearization was possible).

The main complexity in UFFDIO_REMAP is about the re-linearization of
rmap for the pages moved post remap, copying atomically doesn't
require any rmap change instead so it's simpler.

As long as the page is not shared solving the rmap is possible as the
page will not become non-linear post-UFFDIO_REMAP and I solved that
already for anon pages already in the old userfault19 branch (last
branch where I included UFFDIO_REMAP, until it can be re-introduced
later).

The last UFFDIO_REMAP implementation is below, but it's only
worthwhile to remove memory, postcopy doesn't require it, but it would
benefit distributed shared memory implementations or similar usages
requiring full memory externalization. Others already asked for it.

https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/log/?h=userfault19
https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault19&id=7a84c6b2af19bd2f989be849b4b8d1096e44d5ea

The primary reason why UFFDIO_REMAP was deferred is that UFFDIO_COPY
is not only simpler but it's faster too, for the postcopy live
migration case (we verified it with benchmarks just in case).

The reason remap is slower is because of the IPIs that need to be
delivered to all CPUs that mapped the address space of the source
virtual range to flush/invalidate the TLB.

I think IPI deferral and batching would be possible to skip IPIs for
every single page UFFDIO_REMAPped (using a virtual range ring whose
TLB flush is only done at ring-overflow), but it's tricky and it'd
have more complext semantics than mremap. The above implementation in
the link retains the same strict semantics as mremap() but it's slower
than UFFDIO_COPY as result. When UFFDIO_REMAP is used to remove memory
from the final destination however the IPI cannot be deferred so if
only used to remove memory the current implementation would be already
optimal.

About the WP support it kind of works but I've (non-kernel-crashing)
bugreports pending for KVM get_user_pages access that we need to solve
before it's fully workable for things like postcopy live snapshotting
too. So it's not finished. We focused on completing the hugetlbfs
shmem and non cooperative features in time for 4.11 merge window and
so now we can concentrate on finishing the WP support.

I've more patches pending than what's currently in the aa.git
userfault main branch: the main objective of the pending work is to
have a user (non hw interpreted) flag on pagetables and swap entries
that can differentiate when a page is wrprotected by other means or
through UFFDIO_WRITEPROTECT. Just like the soft dirty pte/swapentry
flag. So that there will be no risk of false positive WP faults post
fork() or anything that wrprotect the pagetables by other means. Then
even soft dirty users can be converted to use userfaultfd WP support
that has a computational complexity lower than O(N), and just like PML
hw VT feature, won't require to scan all pagetables to find which
pages have been re-dirtied.

The WP feature isn't just good for distributed shared memory combined
with UFFDIO_REMAP to remove memory, but it'll be useful for postcopy
live snapshotting and for regular databases that may be using fork()
instead. fork() is not ideal because databases run into trouble with
THP WP faults that turn out to be less efficient than PAGE_SIZEd WP
faults for that specific snapshotting use case. Furthermore spawning a
userfaul thread will be more efficient than forking off a new process
and there will be no TLB trashing during the snapshotting. With user
page faults it's always userland to decides the granularity of the
fault resolution and THP in-kernel will cope with whatever granularity
the userfault handler thread decides. In the snapshotting case the
lower page size the kernel supports is always more efficient and
creates less memory footprint too. Last but not the least, userfaultfd
WP will allow the snapshotting to decide if to throttle on I/O if too
much memory is getting allocated despite using smallest page size
granularity available (fork() instead doesn't allow I/O throttling, so
no matter if THP is on or off, the max memory usage can reach twice
the size of the db cache, which may trigger OOM in containers or
similar).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
