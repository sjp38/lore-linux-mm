Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 41D846B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:32:44 -0400 (EDT)
Received: by qgj62 with SMTP id 62so32358276qgj.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:32:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 143si7598237qht.50.2015.08.28.09.32.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 09:32:43 -0700 (PDT)
Date: Fri, 28 Aug 2015 18:32:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/5] userfaultfd21 updates v2
Message-ID: <20150828163238.GB4637@redhat.com>
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
 <55E07A8E.3030808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55E07A8E.3030808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>

Hi Dave,

On Fri, Aug 28, 2015 at 08:13:18AM -0700, Dave Hansen wrote:
> Hi Andrea,
> 
> Is there a way you can think of to use userfaultfd without having a
> separate thread to sit there and be watching the file descriptor?  The
> current model doesn't seem like it would be possible to use with a
> single-threaded app, for instance.
> 
> Is there a reason we couldn't generate a signal and then have the
> userfaultfd handling done inside the signal handler?

Originally it worked precisely like that, much like volatile pages or
the regular PROT_NONE+sigsegv would do (it only avoided the vma
mangling). However that can't work for syscalls and get_user_pages. I
thought of taking care of get_user_pages called by the KVM shadow page
fault handler in a special way, but then there's O_DIRECT (or other
get_user_pages) that may be invoked by userland on top of the
userfault memory, which would also run into a get_user_pages done on a
userfault area.

How do you run a single threaded signal when get_user_pages finds that
it has been called on a userfault region or when copy-user returns
-EFAULT? It's unthinkable to break the syscall API with new retvals
and require all apps to change the error checks of the syscalls to use
userfaultfd safely. We could try to play tricks with restarting
syscalls within glibc but that sigbus would be the same as a real
SIGBUS. Even updating qemu alone to accept new retvals of read/write
O_DIRECT syscalls, sounds like a bad idea compared to the current
userfaultfd API which is entirely transparent to all syscalls and also
to the KVM shadow page fault handler.

The old MADV_USERFAULT/NOUSERFAULT madvise I entirely dropped it and
it's basically become the UFFDIO_REGISTER/UNREGISTER ioctls. It looked
bad idea to start with MADV_USERFAULT and signals, as you may later
notice you need to use a syscall and you've to rewrite the code with
the userfaultfd... better to start right away with userfaultfd and
avoid the risk of wasting time.

Right now copy-user and get_user_pages just blocks in kernel so
userfaults are effectively invisible to the single threaded workflow:
get_user_pages API from the caller point of view is totally
userfaultfd agnostic, but you need a separate thread to handle the
fault.

The fact the kernel in the blocked fault talks with the userland
thread directly over the fd should be more efficient too. The only
downside is a schedule() call when blocking, but on the plus side we
don't have to invoke the signal code at all which also isn't free
(even if potentially less costly than schedule when having lots of
runnable tasks and CPU overcommit). In addition signal themself can
trip on userfaults now, and gdb also will successfully send sigstop to
userfault blocked faults if they didn't happen in kernel context
(where again signals, not even sigstop/sigcont, can't run).

The only requirement added has been to have VM_FAULT_RETRY set in
every fault or get_user_pages that can hit on userfaultfd registered
regions, so we can drop the mmap_sem before blocking. We've to drop
the mmap_sem or we'd allow an userland thread to indefinitely leave
mmap_sem hold, which wouldn't safe (ps may block indefinitely etc..).

If there's a bug and VM_FAULT_RETRY is missing, SIGBUS is raised,
O_DIRECT or KVM page fault would return some noticeable error (like if
it was a real SIGBUS), and a rate limited printk is printed in the log
along with the offending stack trace that must be fixed to pass
VM_FAULT_RETRY.

On a side note, I'm about to extend this VM_FAULT_RETRY so that if the
userfault is invoked when FAULT_FLAG_TRIED is set (which means
VM_FAULT_RETRY was also previously set) we can one still hang and drop
the mmap_sem. This is the major not-self-contained change needed to
introduce the wrprotect fault tracking to userfaultfd (so that
postcopy live snapshotting becomes possible and distributed shared
memory with readonly-shared write-exclusive semantics also becomes
possible). With wrprotect faults, the pagetable-based vma-less
wrprotection can be armed with a UFFDIO_ ioctl while the page fault is
for other reason already in the VM_FAULT_RETRY path and it already
consumed it, so we may hit an wrprotect userfault in the
FAULT_FLAG_TRIED case (that cannot happen with the missing fault mode,
so we didn't need to alter the page fault logic yet and the stock
VM_FAULT_RETRY sufficed so far).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
