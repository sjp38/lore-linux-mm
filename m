Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8548E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:04:34 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s14-v6so40549874ioc.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:04:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h73-v6sor7572587iof.194.2018.09.24.08.04.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 08:04:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+z4HOF_PobxSys8svftWt8dhbuUXEpq2sdXBTCXwTEH2g@mail.gmail.com>
References: <cover.1535629099.git.andreyknvl@google.com> <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
 <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
 <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
 <CA+55aFzQ+ykLu10q3AdyaaKJx8SDWWL9Qiu6WH2jbN_ugRUTOg@mail.gmail.com>
 <20180911164152.GA29166@arrakis.emea.arm.com> <CAAeHK+z4HOF_PobxSys8svftWt8dhbuUXEpq2sdXBTCXwTEH2g@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 24 Sep 2018 17:04:31 +0200
Message-ID: <CAAeHK+z0C+GKK3dEVmtaAiS2koAZ5NDug7-nahUT79y3MX3MLQ@mail.gmail.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by sparse
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 17, 2018 at 7:01 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
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
>
> In case 1 we also have a special case of a pointer passed to one of
> the memory syscalls (mmap, mprotect, etc.). These syscalls "are not
> doing memory accesses but rather dealing with the memory range, hence
> an untagged pointer is better suited" as pointed out by Catalin (these
> syscalls do not always use "unsigned long" instead of "void __user *"
> though, for example shmat uses "void __user *").
>
> Looking at patch #8 ("usb, arm64: untag user addresses in devio") in
> this series, it seems that that devio ioctl actually accepts a pointer
> into a vma, so we shouldn't actually be untagging its argument and the
> patch needs to be dropped. Otherwise there's quite a few more cases
> that needs to be changed (like tcp_zerocopy_receive() for example,
> more can be found by grepping find_vma() in generic code).
>
> Regarding case 2, it seems that analyzing casts of __user pointers
> won't really help, since the code (arch/arm64/mm/fault.c) doesn't
> really use them. However all of this code is arch specific, so it
> shouldn't really change over time (right?). It looks like dealing with
> tags passed to the kernel through these fault handlers is already
> resolved with these patches (and therefore patch #6 ("arm64: untag
> user address in __do_user_fault") in this series is not actually
> needed and can be dropped (need to test that)):
>
> 276e9327 ("arm64: entry: improve data abort handling of tagged pointers"),
> 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on
> a tagged pointer")
> 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged pointers")
>
> Now, I also see two cases when kernel behavior changes depending on
> whether a pointer is tagged:
>
> 1. Kernel code checks that a pointer belongs to userspace by comparing
> it with TASK_SIZE/addr_limit/user_addr_max()/USER_DS/... .
> 2. A pointer gets passed to find_vma() or similar functions.
> (Is there something else?)
>
> The initial thought that I had here is that the pointers that reach
> find_vma() must be passed through memory syscalls and therefore
> shouldn't be untagged and don't require any fixes. There are at least
> two exceptions to this: 1. get_user_pages() (see patch #4 ("mm, arm64:
> untag user addresses in mm/gup.c") in this patch series) and 2.
> __do_page_fault() in arch/arm64/mm/fault.c. Are there any other
> obvious exceptions? I've tried adding BUG_ON(has_tag(addr)) to
> find_vma() and running a modified syzkaller version that passes tagged
> pointers to the kernel and failed to find anything else.
>
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
>
> WDYT?

ping
