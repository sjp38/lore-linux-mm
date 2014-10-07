Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BB8D76B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 09:25:35 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so9428459wgg.32
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 06:25:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qt9si20945350wjc.93.2014.10.07.06.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 06:25:34 -0700 (PDT)
Date: Tue, 7 Oct 2014 15:24:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 08/17] mm: madvise MADV_USERFAULT
Message-ID: <20141007132458.GZ2342@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-9-git-send-email-aarcange@redhat.com>
 <20141007103645.GB30762@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007103645.GB30762@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Hi Kirill,

On Tue, Oct 07, 2014 at 01:36:45PM +0300, Kirill A. Shutemov wrote:
> On Fri, Oct 03, 2014 at 07:07:58PM +0200, Andrea Arcangeli wrote:
> > MADV_USERFAULT is a new madvise flag that will set VM_USERFAULT in the
> > vma flags. Whenever VM_USERFAULT is set in an anonymous vma, if
> > userland touches a still unmapped virtual address, a sigbus signal is
> > sent instead of allocating a new page. The sigbus signal handler will
> > then resolve the page fault in userland by calling the
> > remap_anon_pages syscall.
> 
> Hm. I wounder if this functionality really fits madvise(2) interface: as
> far as I understand it, it provides a way to give a *hint* to kernel which
> may or may not trigger an action from kernel side. I don't think an
> application will behaive reasonably if kernel ignore the *advise* and will
> not send SIGBUS, but allocate memory.
> 
> I would suggest to consider to use some other interface for the
> functionality: a new syscall or, perhaps, mprotect().

I didn't feel like adding PROT_USERFAULT to mprotect, which looks
hardwired to just these flags:

       PROT_NONE  The memory cannot be accessed at all.

       PROT_READ  The memory can be read.

       PROT_WRITE The memory can be modified.

       PROT_EXEC  The memory can be executed.

Normally mprotect doesn't just alter the vmas but it also alters
pte/hugepmds protection bits, that's something that is never needed
with VM_USERFAULT so I didn't feel like VM_USERFAULT is a protection
change to the VMA.

mprotect is also hardwired to mangle only the VM_READ|WRITE|EXEC
flags, while madvise is ideal to set arbitrary vma flags.

>From an implementation standpoint the perfect place to set a flag in a
vma is madvise. This is what MADV_DONTFORK (it sets VM_DONTCOPY)
already does too in an identical way to MADV_USERFAULT/VM_USERFAULT.

MADV_DONTFORK is as critical as MADV_USERFAULT because people depends
on it for example to prevent the O_DIRECT vs fork race condition that
results in silent data corruption during I/O with threads that may
fork. The other reason why MADV_DONTFORK is critical is that fork()
would otherwise fail with OOM unless full overcommit is enabled
(i.e. pci hotplug crashes the guest if you forget to set
MADV_DONTFORK).

Another madvise that would generate a failure if not obeyed by the
kernel is MADV_DONTNEED that if it does nothing it could run lead to
OOM killing. We don't inflate virt balloons using munmap just to make
an example. Various other apps (maybe JVM garbage collection too)
makes extensive use of MADV_DONTNEED and depend on it.

Said that I can change it to mprotect, the only thing that I don't
like is that it'll result in a less clean patch and I can't possibly
see a practical risk in keeping it simpler with madvise, as long as we
always return -EINVAL whenever we encounter a vma type that cannot
raise userfaults yet (that is something I already enforced).

Yet another option would be to drop MADV_USERFAULT and
vm_flags&VM_USERFAULT entirely and in turn the ability to handle
userfaults with SIGBUS, and retain only the userfaultfd. The new
userfaultfd protocol requires registering each created userfaultfd
into its own private virtual memory ranges (that is to allow an
unlimited number of userfaultfd per process). Currently the
userfaultfd engages iff the fault address intersects both the
MADV_USERFAULT range and the userfaultfd registered ranges. So I could
drop MADV_USERFAULT and VM_USERFAULT and just check for
vma->vm_userfaultfd_ctx!=NULL to know if the userfaultfd protocol
needs to be engaged during the first page fault for a still unmapped
virtual address. I just thought it would be more flexibile to also
allow SIGBUS without forcing people to use userfaultfd (that's in fact
the only reason to still retain madvise(MADV_USERFAULT)!).

Volatile pages earlier patches only supported SIGBUS behavior for
example.. and I didn't intend to force them to use userfaultfd if
they're guaranteed to access the memory with the CPU and never through
a kernel syscall (that is something the app can enforce by
design). userfaultfd becomes necessary the moment you want to handle
userfaults through syscalls/gup etc... qemu obviously requires
userfaultfd and it never uses the userfaultfd-less SIGBUS behavior as
it touches the memory in all possible ways (first and foremost with
the KVM page fault that uses almost all variants of gup..).

So here somebody should comment and choose between:

1) set VM_USERFAULT with mprotect(PROT_USERFAULT) instead of
   the current madvise(MADV_USERFAULT)

2) drop MADV_USERFAULT and VM_USERFAULT and force the usage of the
   userfaultfd protocol as the only way for userland to catch
   userfaults (each userfaultfd must already register itself into its
   own virtual memory ranges so it's a trivial change for userfaultfd
   users that deletes just 1 or 2 lines of userland code, but it would
   prevent to use the SIGBUS behavior with info->si_addr=faultaddr for
   other users)

3) keep things as they are now: use MADV_USERFAULT for SIGBUS
   userfaults, with optional intersection between the
   vm_flags&VM_USERFAULT ranges and the userfaultfd registered ranges
   with vma->vm_userfaultfd_ctx!=NULL to know if to engage the
   userfaultfd protocol instead of the plain SIGBUS

I will update the code accordingly to feedback, so please comment.

I implemented 3) because I thought it provided the most flexibility
for userland to choose if to engage in the userfaultfd protocol or to
stay simple with the SIGBUS if the app doesn't require to access the
userfault virtual memory from the kernel code. It also provides the
cleanest and simplest implementation to set the VM_USERFAULT flags
with madvise.

My second choice would be 2). We could always add MADV_USERFAULT later
except then we'd be forced to set and clear VM_USERFAULT within the
userfaultfd registration to remain backwards compatible. The main cons
and the reason I didn't pick 2) is that it wouldn't be a drop in
replacement for volatile pages that would then be force to use the
userfaultfd protocol too.

I don't like 3) very much mostly because the changes to mprotect would
just make things more complex on the implementation side with purely
conceptual benefits, but then it's possible too and it's feature
equivalent to 1) as far as volatile pages are concerned, so I'm
overall fine with this change if that's the preferred way.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
