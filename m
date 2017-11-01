Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2AC56B0289
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:26:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n33so8517215ioi.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:26:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r81sor505358itb.14.2017.11.01.08.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 08:26:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031191336.GA2799@redhat.com>
References: <94eb2c0433c8f42cac055cc86991@google.com> <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz> <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz> <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
 <CA+55aFwWJyArZMEuo1-4+VaiP95e__cRHkVvrfiQ+NUVJ15DNQ@mail.gmail.com> <20171031191336.GA2799@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 08:26:24 -0700
Message-ID: <CA+55aFyxA2mdSEKaP7v2GTWY2qC971unym8grwe1VnxQRctaUA@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Tue, Oct 31, 2017 at 12:13 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> The problematic path for the return to userland (get_user_pages
> returns to kernel) is this one:
>
>         if (return_to_userland) {
>                 if (signal_pending(current) &&
>                     !fatal_signal_pending(current)) {
>                         /*
>                          * If we got a SIGSTOP or SIGCONT and this is
>                          * a normal userland page fault, just let
>                          * userland return so the signal will be
>                          * handled and gdb debugging works.  The page
>                          * fault code immediately after we return from
>                          * this function is going to release the
>                          * mmap_sem and it's not depending on it
>                          * (unlike gup would if we were not to return
>                          * VM_FAULT_RETRY).
>                          *
>                          * If a fatal signal is pending we still take
>                          * the streamlined VM_FAULT_RETRY failure path
>                          * and there's no need to retake the mmap_sem
>                          * in such case.
>                          */
>                         down_read(&mm->mmap_sem);
>                         ret = VM_FAULT_NOPAGE;
>                 }
>         }
>
> We could remove the above branch all together and then
> handle_userfault() would always return VM_FAULT_RETRY whenever it
> decides to release the mmap_sem.

Honestly, I would *much* prefer that.

>    The above makes debugging with gdb
> more user friendly and it potentially lowers the latency of signals as
> signals can unblock handle_userfault.

I don't disagree about that, but why don't you use VM_FAULT_RETRY and
not re-take the mmap_sem? Then we wouldn't have a special case for
userfaultfd at all.

I see the gdb issue, but I wonder if we shouldn't fix that differently
by changing the retry logic in the fault handler.

In particular, right now we do

 -  Retry at most once

 - handle fatal signals specially

and I think the gdb case actually shows that both of those decisions
may have been wrong, or at least something we could improve on?

Maybe we should return to user space on _any_ pending signal? That
might help latency for other things than gdb (think ^Z etc, but also
things that catch SIGSEGV and abort).

And maybe we should allow FAULT_FLAG_ALLOW_RETRY to just go on forever
- although that will want to verify that every case that returns
VM_FAULT_RETRY does wait for the condition it dropped the mmap
semaphore and is retrying for.

There aren't that many places that return VM_FAULT_RETRY. The
important one is lock_page_or_retry(), and that one does wait for the
page.

(There's one in mm/shmem.c too, and obviously the userfaultfd case,
but those seem to do waiting too).

So maybe we could just fix the gdb case without that userfaultfd hack?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
