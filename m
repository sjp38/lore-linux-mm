Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id D9ED96B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 09:30:36 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id 131so1305073ykp.41
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 06:30:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d35si5166500qgd.84.2014.11.26.06.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Nov 2014 06:30:35 -0800 (PST)
Date: Wed, 26 Nov 2014 15:30:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/10] RFC: userfault (question about remap_anon_pages
 API)
Message-ID: <20141126143030.GV4569@redhat.com>
References: <546D8882.4040908@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <546D8882.4040908@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

Hi Pavel,

On Thu, Nov 20, 2014 at 10:21:54AM +0400, Pavel Emelyanov wrote:
> Andrea,
> 
> We'd like to use this code to implement the post-copy migration
> too, but this time for containers, not for virtual machines. This
> will be done as a part of the CRIU [1] project.
> 
> From our experiments almost everything is suitable, but the
> remap_anon_pages() system call, so I'd like you to comment on

Ok, as a side note, we'll soon stop using remap_anon_pages for
postcopy, we'll do a copy instead of a move. As Linus pointed out that
should improve performance. I'm mentioning it just as a reminder, for
this discussion below it changes nothing if we do a copy or a move,
and you also should benefit from doing a copy instead of a move.

> whether we're mis-using your API or not :) So, for containers the
> post-copy migration would look like this.
> 
> 
> On the source node we freeze the container's process tree, read
> its state, except for the memory contents using CRIU tool, then
> copy the state on remote host and recreate the processes back
> using the CRIU tool again.
> 
> At this step (restore) we mark all the memory of the tasks we
> restore with MADV_USERFAULT so that any attempt to access one 
> results in the notification via userfaultfd. The userfaultfd, in
> turn, exists for every process in the container and, in our plans, 
> is owned by the CRIU daemon, that will provide the post-copy 
> memory updates. Then we unfreeze the processes and let them run
> further.
>
> So, when a process tries to access the memory the CRIU daemon
> wakes up, reads the fault address, pulls the page from source node
> and then it should put this page into the proper process' address
> space. And here's where we have problems.
> 
> The page with data is in CRIU daemon address space and the syscall
> remap_anon_pages() works on current process address space. So, in
> order to have the data in the container's process address space, we
> have two choices. Either we somehow make the page be available in 
> the other process address space and make this process call the remap
> system call, or we should extend the syscall to accept the pid of 
> the process on whose address space we'd like to work on.
> 
> 
> What do you think? Are you OK with tuning the remap_anon_pages, or
> we should do things in completely different way? If the above
> explanation is not clear enough, we'd be happy to provide more 
> details.

The problem with remap_anon_pages is clear. What's not clear is how
you make the userfaultfd "owned" by the CRIU daemon. userfaultfd()
should be run by each process in the container, not by the daemon, so
during creation it has the same constraints of the
remap_anon_pages/mcopy_atomic.

Or you passing all processes' fd to the CRIU through unix domain
sockets or something like that? I actually didn't think of sending the
fd over to a different process and I'd originally expected you to run
on the same issue you have with remap_anon_pages also with
userfaultfd() because userfaultfd() also doesn't get a "pid" as
parameter.

The issue with adding a "pid" will complicate things a bit, I don't
think it's impossible, just a pid is not a proper representation of an
mm, it could be kernel thread that transiently own the mm. But you'll
just use the pid of the main user thread so it still shall work and
then it's userland responsibility to ensure the pid isn't killed and
replaced by another spawned process with a different mm. Just it's not
the normal thing to have a pid parameter in syscalls that alter the
address space.

Sending the page over should be possible with a pipe plus vmsplice, so
you could do this already with the current code.

If we'd expose the new vma-less VM operations as ufd commands (instead
of syscalls) then you could just use the source address in the MM
context of the process that is running the write syscall into the ufd,
and the destination address would be still interpreted in the original
MM context of the process that owns the fd. That assuming you got a
working way to send the fd over (unix domain sockets /proc or something).

I still didn't hear much comments on what peoples prefer between
exposing those vma-less mprotect-mremap-like operations as syscalls
(mcopy_atomic for postcopy live migration, mprotect_pagetable for
postcopy live snapshot) or if to hide those operations into ufd
commands.

If we use syscalls userland will have to do the below (for simplicity
I'll ignore err retval that should be checked, it's c-like pseudocode):

    u64 range[2];

    /* enable userfault on the region */
    madvise(guest_start, guest_len, MADV_USERFAULT);

    /* register userfaultfd into the region, disable SIGBUS behavior */
    ufd = userfaultfd(0);
    range[0] = guest_start | USERFAULTFD_RANGE_REGISTER;
    range[1] = guest_start + guest_len;
    write(ufd, range, sizeof(range));

    poll(fd = ufd, ....);

    /*
     * userfault trigger on addr "dst" and userland decides to solve
     * it with 4k granularity below
     */

    /* map the page in the faulting address "dst", "src" is where you got the data */
    mcopy_atomic(dst, src, 4096);

    range[0] = dst;
    range[1] = dst + 4096;
    /* tell the kernel to wake and retry the blocked page fault */
    write(ufd, range, sizeof(range));

If we use ufd commands then pure MADV_USERFAULT (without userfaultfd)
won't be able anymore to call mcopy_atomic in SIGBUS and it probably
should be dropped entirely (forcing everyone including volatile pages
to use userfaultfd) and the code would become:

    u64 range[4];

    /* register userfaultfd into the region */
    ufd = userfaultfd(0);
    range[0] = USERFAULTFD_RANGE_REGISTER_NOT_PRESENT;
    range[1] = guest_start;
    range[2] = guest_start + guest_len;
    write(ufd, range, sizeof(range));

    poll(fd = ufd, ....);

    /*
     * userfault trigger on addr "dst" and userland decides to solve
     * it with 4k granularity below
     */

    range[0] = USERFAULTFD_MCOPY_ATOMIC;
    range[1] = dst;
    range[2] = dst + 4096;
    /* src is where you transferred the data */
    range[3] = src;
    /* tell the kernel to copy the page atomically and wake and retry the blocked page fault */
    write(ufd, range, sizeof(range));

If we hide all pagetable mangling operations as ufd commands, then we
would add the USERFAULTFD_RANGE_REGISTER_WRPROTECTED and other
commands to mark and unmark pagetables wrprotected to arm and disarm
the wrprotect faults without thouching vmas.

The range[4] above in the second case is just to make it smaller
above, it'd need to be a proper structure of course, but you get the
idea.

Comments on what is preferred between the two APIs would be welcome,
as some bit of plumbing code would change and I could save some
time. I'm quite netural on the two approaches.

Doing everything inside userfaultfd would imply that the only way
those operations could ever be useful would be in combination with the
userfaultfd.

Doing it with syscalls has the main advantage of not requiring a
userfaultfd protocol bump every single time if we add new operations,
so we could have a fully feature userfaultfd notification mechanism to
start with (that allows to register for not present or wrprotect
faults and reports also the type of the fault), and later we could add
more pte mangling syscalls incrementally. However if we're sure those
operations cannot be useful without userfaultfd open, we could as well
hide them as ufd commands and then you could use them from a different
process and they would act on the mm attached to the ufd.

Comments to decide which API is better are welcome, the internals
won't change it's an API matter but it's still quite some code it may
affect if we switch between the two.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
