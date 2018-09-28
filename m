Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E42C88E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 13:50:23 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id p23-v6so7804949otl.23
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:50:23 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 66-v6si2747135oif.171.2018.09.28.10.50.22
        for <linux-mm@kvack.org>;
        Fri, 28 Sep 2018 10:50:22 -0700 (PDT)
Date: Fri, 28 Sep 2018 18:50:14 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180928175013.GC193149@arrakis.emea.arm.com>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
 <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
 <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
 <CA+55aFzQ+ykLu10q3AdyaaKJx8SDWWL9Qiu6WH2jbN_ugRUTOg@mail.gmail.com>
 <20180911164152.GA29166@arrakis.emea.arm.com>
 <CAAeHK+z4HOF_PobxSys8svftWt8dhbuUXEpq2sdXBTCXwTEH2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+z4HOF_PobxSys8svftWt8dhbuUXEpq2sdXBTCXwTEH2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, linux-mm <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrey,

(sorry for the delay)

On Mon, Sep 17, 2018 at 07:01:00PM +0200, Andrey Konovalov wrote:
> I took another look at the changes this patchset does to the kernel
> and here are my thoughts:
> 
> I see two ways how a (potentially tagged) user pointer gets into the kernel:
> 
> 1. A pointer is passed to a syscall (directly as an argument or
> indirectly as a struct field).
> 2. A pointer is extracted from user context (registers, etc.) by some
> kind of a trap/fault handler.
> (Is there something else?)

Not AFAICT.

> In case 1 we also have a special case of a pointer passed to one of
> the memory syscalls (mmap, mprotect, etc.). These syscalls "are not
> doing memory accesses but rather dealing with the memory range, hence
> an untagged pointer is better suited" as pointed out by Catalin (these
> syscalls do not always use "unsigned long" instead of "void __user *"
> though, for example shmat uses "void __user *").

If it makes things any simpler, we could revisit this though it seems to
me more consistent not to pass a tagged pointer back into the kernel
when the original one was untagged (i.e. mmap vs munmap).

(if it wasn't for pointers in structures, I would have just left the
problem entirely to the C library to do the untagging before calling the
kernel)

> Looking at patch #8 ("usb, arm64: untag user addresses in devio") in
> this series, it seems that that devio ioctl actually accepts a pointer
> into a vma, so we shouldn't actually be untagging its argument and the
> patch needs to be dropped.

You are right, the pointer seems to have originated from the kernel as
already untagged (mmap() on the driver), so we would expect the user to
pass it back an untagged pointer.

> Otherwise there's quite a few more cases that needs to be changed
> (like tcp_zerocopy_receive() for example, more can be found by
> grepping find_vma() in generic code).

Yes, it's similar to the devio one.

> Regarding case 2, it seems that analyzing casts of __user pointers
> won't really help, since the code (arch/arm64/mm/fault.c) doesn't
> really use them. However all of this code is arch specific, so it
> shouldn't really change over time (right?). It looks like dealing with
> tags passed to the kernel through these fault handlers is already
> resolved with these patches (and therefore patch #6 ("arm64: untag
> user address in __do_user_fault") in this series is not actually
> needed and can be dropped (need to test that)):

I'm less worried about (2) since, as you say, it's under the arch
control and, even if it changes slightly over time, we can be aware of
this.

> Now, I also see two cases when kernel behavior changes depending on
> whether a pointer is tagged:
> 
> 1. Kernel code checks that a pointer belongs to userspace by comparing
> it with TASK_SIZE/addr_limit/user_addr_max()/USER_DS/... .
> 2. A pointer gets passed to find_vma() or similar functions.
> (Is there something else?)

I think these are the main cases.

> The initial thought that I had here is that the pointers that reach
> find_vma() must be passed through memory syscalls and therefore
> shouldn't be untagged and don't require any fixes. There are at least
> two exceptions to this: 1. get_user_pages() (see patch #4 ("mm, arm64:
> untag user addresses in mm/gup.c") in this patch series) and 2.
> __do_page_fault() in arch/arm64/mm/fault.c. Are there any other
> obvious exceptions?

Vincenzo F did some more in-depth analysis, I'll let him answer whether
he has found any more cases.

At a quick grep, arm64_notify_segfault() (it changes the siginfo
si_code). There are a few other places which assume that the address is
already untagged but we don't seem to have a clear guideline on the ABI.
For example, prctl(PR_SET_MM) takes user addresses and we assume they
are untagged (as in the mmap() and friends).

> I've tried adding BUG_ON(has_tag(addr)) to find_vma() and running a
> modified syzkaller version that passes tagged pointers to the kernel
> and failed to find anything else.

I added a similar test with an LD_PRELOAD'ed malloc/free implementation
on Debian and seemed alright but I'd rather want something more
consistent when defining the user ABI, otherwise we have places where
find_vma() is called but requires untagging.

> As for case 1, the places where pointers are compared with TASK_SIZE
> and others can be found with grep. Maybe it makes sense to introduce
> some kind of routine like is_user_pointer() that handles tagged
> pointers and refactor the existing code to use it? And maybe add a
> rule to checkpatch.pl that forbids the direct usage of TASK_SIZE and
> others.
> 
> So I think detecting direct comparisons with TASK_SIZE and others
> would more useful than finding __user pointer casts (it seems that the
> latter requires a lot of annotations to be fixed/added), and I should
> just drop this patch with annotations.

I think point (1) is not too bad, usually found with grep.

As I've said in my previous reply, I kind of came to the same conclusion
that searching __user pointer casts to long may not actually scale. If
we could add an __untagged annotation to ulong where it matters (e.g.
find_vma()), we could identify a ulong (default tagged) and annotate
some of those.

However, this analysis on __user * casting was useful even if we don't
end up using it. If we come up with a clearer definition of the ABI
(which syscalls accept tagged pointers), we may conclude that the only
places where untagging matters are a few find_vma() calls in the arch
and mm code and can ignore the rest.

FTR, this code is a prerequisite for ARM's memory tagging hardware
feature. Interestingly, I can't find SPARC ADI support dealing with this
aspect at all. I suspect their user ABI does not allow tagged addresses
passed to the kernel.

-- 
Catalin
