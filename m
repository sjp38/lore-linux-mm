Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB246B0069
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:13:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 82so25542oid.11
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:13:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p18si1390307otp.471.2017.10.31.12.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 12:13:41 -0700 (PDT)
Date: Tue, 31 Oct 2017 20:13:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Message-ID: <20171031191336.GA2799@redhat.com>
References: <94eb2c0433c8f42cac055cc86991@google.com>
 <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
 <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz>
 <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
 <CA+55aFwWJyArZMEuo1-4+VaiP95e__cRHkVvrfiQ+NUVJ15DNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwWJyArZMEuo1-4+VaiP95e__cRHkVvrfiQ+NUVJ15DNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Tue, Oct 31, 2017 at 08:37:47AM -0700, Linus Torvalds wrote:
> Yes. Accessing "vma" after calling "handle_mm_fault()" is a bug. An
> unfortunate issue with userfaultfd.
> 
> The suggested fix to simply look up pkey beforehand seems sane and simple.

Agreed.

> 
> But sadly, from a quick check, it looks like arch/um/ has the same
> bug, but even worse. It will do
> 
>  (a) handle_mm_fault() in a loop without re-calculating vma. Don't ask me why.
> 
>  (b) flush_tlb_page(vma, address); afterwards

Yes, that flush_tlb_page is unsafe. Luckily it's only using it for
vma->vm_mm so it doesn't sound major issue to fix it.

> 
> but much more importantly, I think __get_user_pages() is broken in two ways:
> 
>  - faultin_page() does:
> 
>         ret = handle_mm_fault(vma, address, fault_flags);
>         ...
>         if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
> 
>    (easily fixed the same way)
> 
>  - more annoyingly and harder to fix: the retry case in
> __get_user_pages(), and the VMA saving there.
> 
> Ho humm.
> 
> Andrea, looking at that get_user_pages() case, I really think it's
> userfaultfd that is broken.
> 
> Could we perhaps limit userfaultfd to _only_ do the VM_FAULT_RETRY,
> and simply fail for non-retry faults?

In the get_user_pages case we already limit it to do only
VM_FAULT_RETRY so no use after free should materialize whenever gup is
involved.

The problematic path for the return to userland (get_user_pages
returns to kernel) is this one:

	if (return_to_userland) {
		if (signal_pending(current) &&
		    !fatal_signal_pending(current)) {
			/*
			 * If we got a SIGSTOP or SIGCONT and this is
			 * a normal userland page fault, just let
			 * userland return so the signal will be
			 * handled and gdb debugging works.  The page
			 * fault code immediately after we return from
			 * this function is going to release the
			 * mmap_sem and it's not depending on it
			 * (unlike gup would if we were not to return
			 * VM_FAULT_RETRY).
			 *
			 * If a fatal signal is pending we still take
			 * the streamlined VM_FAULT_RETRY failure path
			 * and there's no need to retake the mmap_sem
			 * in such case.
			 */
			down_read(&mm->mmap_sem);
			ret = VM_FAULT_NOPAGE;
		}
	}

We could remove the above branch all together and then
handle_userfault() would always return VM_FAULT_RETRY whenever it
decides to release the mmap_sem. The above makes debugging with gdb
more user friendly and it potentially lowers the latency of signals as
signals can unblock handle_userfault. The downside is that the return
to userland cannot dereference the vma after calling handle_mm_fault.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
