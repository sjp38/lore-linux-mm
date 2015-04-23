Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9F33F6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 02:34:35 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so6075006lbc.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 23:34:34 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id zz9si5306463lbb.157.2015.04.22.23.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 23:34:33 -0700 (PDT)
Message-ID: <55389261.50105@parallels.com>
Date: Thu, 23 Apr 2015 09:34:09 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] UserfaultFD: Extension for non cooperative uffd usage
References: <5509D342.7000403@parallels.com> <20150421120222.GC4481@redhat.com>
In-Reply-To: <20150421120222.GC4481@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Dave Hansen <dave.hansen@intel.com>

On 04/21/2015 03:02 PM, Andrea Arcangeli wrote:
> Hi Pavel,
> 
> On Wed, Mar 18, 2015 at 10:34:26PM +0300, Pavel Emelyanov wrote:
>> Hi,
>>
>> On the recent LSF Andrea presented his userfault-fd patches and
>> I had shown some issues that appear in usage scenarios when the
>> monitor task and mm task do not cooperate to each other on VM
>> changes (and fork()-s).
>>
>> Here's the implementation of the extended uffd API that would help 
>> us to address those issues.
>>
>> As proof of concept I've implemented only fix for fork() case, but
>> I also plan to add the mremap() and exit() notifications, both are
>> also required for such non-cooperative usage.
>>
>> More details about the extension itself is in patch #2 and the fork()
>> notification description is in patch #3.
>>
>> Comments and suggestion are warmly welcome :)
> 
> This looks feasible.
> 
>> Andrea, what's the best way to go on with the patches -- would you
>> prefer to include them in your git tree or should I instead continue
>> with them on my own, re-sending them when required? Either way would
>> be OK for me.
> 
> Ok so various improvements happened in userfaultfd patchset over the
> last month so your incremental patchset likely requires a rebase
> sorry. When you posted it I was in the middle of the updates. Now
> things are working stable and I have no pending updates, so it would
> be a good time for a rebase.

OK, thanks for the heads up! I will rebase my patches.

> I can merge it if you like, it's your call if you prefer to maintain
> it incrementally or if I should merge it, but I wouldn't push it to
> Andrew for upstream integration in the first batch, as this
> complicates things further and it's not fully complete yet (at least
> the version posted only handled fork). I think it can be merged
> incrementally in a second stage.

Sure!

> The major updates of the userfaultfd patchset over the last month were:
> 
> 1) Various mixed fixes thanks to the feedback from Dave Hansen and
>    David Gilbert.
> 
>    The most notable one is the use of mm_users instead of mm_count to
>    pin the mm to avoid crashes that assumed the vma still existed (in
>    the userfaultfd_release method and in the various ioctl). exit_mmap
>    doesn't even set mm->mmap to NULL, so unless I introduce a
>    userfaultfd_exit to call in mmput, I have to pin the mm_users to be
>    safe. This is mainly an issue for the non-cooperative usage you're
>    implementing. Can you catch the exit somehow so you can close the
>    fd? The memory won't be released until you do. Is this ok with you?
>    I suppose you had to close the fd somehow anyway.
> 
> 2) userfaults are waken immediately even if they're not been "read"
>    yet, this can lead to POLLIN false positives (so I only allow poll
>    if the fd is open in nonblocking mode to be sure it won't hang). Is
>    it too paranoid to return POLLERR if the fd is not open in
>    nonblocking mode?
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=f222d9de0a5302dc8ac62d6fab53a84251098751
> 
> 3) optimize read to return entries in O(1) and poll which was already
>    O(1) becomes lockless. This required to split the waitqueue in two,
>    one for pending faults and one for non pending faults, and the
>    faults are refiled across the two waitqueues when they're
>    read. Both waitqueues are protected by a single lock to be simpler
>    and faster at runtime (the fault_pending_wqh one).
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=9aa033ed43a1134c2223dac8c5d9e02e0100fca1
> 
> 4) Allocate the ctx with kmem_cache_alloc. This is going to collide a
>    bit with your cleanup patch sorry.
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=f5a8db16d2876eed8906a4d36f1d0e06ca5490f6
> 
> 5) Originally qemu had two bitflags for each page and kept 3 states
>    (of the 4 possible with two bits) for each page in order to deal
>    with the races that can happen if one thread is reading the
>    userfaults and another thread is calling the UFFDIO_COPY ioctl in
>    the background. This patch solves all races in the kernel so the
>    two bits per page can be dropped from qemu codebase. I started
>    documenting the races that can materialize by using 2 threads
>    (instead of running the workload single threaded with a single poll
>    event loop), and how userland had to solve them until I decided it
>    was simpler to fix the race in the kernel by running an ad-hoc
>    pagetable walk inside the wait_event()-kind-of-section. This
>    simplified qemu significantly and it doesn't make the kernel much
>    more complicated.
> 
>    I tried this before in much older versions but I use gup_fast for
>    it and it didn't work well with gup_fast for various reasons.
> 
>    http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=41efeae4e93f0296436f2a9fc6b28b6b0158512a
> 
>    After this patch the only reason to call UFFDIO_WAKE is to handle
>    the userfaults in batches in combination with the DONT_WAKE flag of
>    UFFDIO_COPY.
> 
> 6) I removed the read recursion from mcopy_atomic. This avoids to
>    depend on the write-starvation behavior of rwsem to be safe. After
>    this change the rwsem is free to stop any further down_read if
>    there's a down_write waiting on the lock.
> 
>    	  http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=b1e3a08acc9e3f6c2614e89fc3b8e338daa58e18
> 
> About other troubles for the non cooperative usage: MADV_DONTNEED
> likely needs to be trapped too or how do you know that you shall map a
> zero page instead of the old data at the faulting address?
> 
> Thanks,
> Andrea
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
