Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C84D6B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 15:36:54 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w197so606414oif.23
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 12:36:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b24si2339922ote.518.2017.11.02.12.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 12:36:48 -0700 (PDT)
Date: Thu, 2 Nov 2017 20:36:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Message-ID: <20171102193644.GB22686@redhat.com>
References: <94eb2c0433c8f42cac055cc86991@google.com>
 <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
 <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz>
 <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
 <CA+55aFwWJyArZMEuo1-4+VaiP95e__cRHkVvrfiQ+NUVJ15DNQ@mail.gmail.com>
 <20171031191336.GA2799@redhat.com>
 <CA+55aFyxA2mdSEKaP7v2GTWY2qC971unym8grwe1VnxQRctaUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyxA2mdSEKaP7v2GTWY2qC971unym8grwe1VnxQRctaUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Wed, Nov 01, 2017 at 08:26:24AM -0700, Linus Torvalds wrote:
> On Tue, Oct 31, 2017 at 12:13 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > The problematic path for the return to userland (get_user_pages
> > returns to kernel) is this one:
> >
> >         if (return_to_userland) {
> >                 if (signal_pending(current) &&
> >                     !fatal_signal_pending(current)) {
> >                         /*
> >                          * If we got a SIGSTOP or SIGCONT and this is
> >                          * a normal userland page fault, just let
> >                          * userland return so the signal will be
> >                          * handled and gdb debugging works.  The page
> >                          * fault code immediately after we return from
> >                          * this function is going to release the
> >                          * mmap_sem and it's not depending on it
> >                          * (unlike gup would if we were not to return
> >                          * VM_FAULT_RETRY).
> >                          *
> >                          * If a fatal signal is pending we still take
> >                          * the streamlined VM_FAULT_RETRY failure path
> >                          * and there's no need to retake the mmap_sem
> >                          * in such case.
> >                          */
> >                         down_read(&mm->mmap_sem);
> >                         ret = VM_FAULT_NOPAGE;
> >                 }
> >         }
> >
> > We could remove the above branch all together and then
> > handle_userfault() would always return VM_FAULT_RETRY whenever it
> > decides to release the mmap_sem.
> 
> Honestly, I would *much* prefer that.
> 
> >    The above makes debugging with gdb
> > more user friendly and it potentially lowers the latency of signals as
> > signals can unblock handle_userfault.
> 
> I don't disagree about that, but why don't you use VM_FAULT_RETRY and
> not re-take the mmap_sem? Then we wouldn't have a special case for
> userfaultfd at all.

Yes I prefer that as well, it's much more generic and cleaner that
way.

> I see the gdb issue, but I wonder if we shouldn't fix that differently
> by changing the retry logic in the fault handler.
> 
> In particular, right now we do
> 
>  -  Retry at most once
> 
>  - handle fatal signals specially
> 
> and I think the gdb case actually shows that both of those decisions
> may have been wrong, or at least something we could improve on?
> 
> Maybe we should return to user space on _any_ pending signal? That
> might help latency for other things than gdb (think ^Z etc, but also
> things that catch SIGSEGV and abort).

That would be an ideal solution and then we can drop the special case
from handle_userfault() entirely and the signal check will cover more
cases then.

If VM_FAULT_RETRY is returned but there are pending signals we and the
page fault was invoked on top of userland, we will ignore the
VM_FAULT_RETRY request and return to userland instead.

> And maybe we should allow FAULT_FLAG_ALLOW_RETRY to just go on forever

Returning VM_FAULT_RETRY more than once is already a dependency in the
future userfaultfd WP support (at the moment to stay on the safe side
it only allows one more VM_FAULT_RETRY), as we may writeprotect
individual pagetables while there's already a page fault in flight, in
turn requiring two VM_FAULT_RETRY in a row if the second page fault
invocation ends up in handle_userfault() because of a concurrent
UFFDIO_WRITEPROTECT.

Such an issue cannot materialize with "missing" userfaults because by
definition if the virtual page is missing there cannot be already
other page faults in flight on it.

It'd be cleaner to just let it go on forever.

> - although that will want to verify that every case that returns
> VM_FAULT_RETRY does wait for the condition it dropped the mmap
> semaphore and is retrying for.

Agreed.

> There aren't that many places that return VM_FAULT_RETRY. The
> important one is lock_page_or_retry(), and that one does wait for the
> page.
> 
> (There's one in mm/shmem.c too, and obviously the userfaultfd case,
> but those seem to do waiting too).
> 
> So maybe we could just fix the gdb case without that userfaultfd hack?

That would be great, I will look into implementing the above.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
