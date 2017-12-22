Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323626B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:18:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 79so3510030iou.19
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:18:18 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e63si321127ioi.152.2017.12.22.00.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 00:18:16 -0800 (PST)
Date: Fri, 22 Dec 2017 09:17:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: general protection fault in finish_task_switch
Message-ID: <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com>
 <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>

On Thu, Dec 21, 2017 at 10:42:04AM -0800, Linus Torvalds wrote:
> On Wed, Dec 20, 2017 at 8:03 AM, syzbot
> <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>
> wrote:
> > Hello,
> >
> > syzkaller hit the following crash on
> > 7dc9f647127d6955ffacaf51cb6a627b31dceec2
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> >
> > kasan: CONFIG_KASAN_INLINE enabled
> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > general protection fault: 0000 [#1] SMP KASAN
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 0 PID: 4227 Comm: syzkaller244813 Not tainted 4.15.0-rc4-next-20171220+
> > #77
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: __fire_sched_in_preempt_notifiers kernel/sched/core.c:2534 [inline]
> 
> That line 2534 is the call inside the hlist_for_each_entry() loop:
> 
>         hlist_for_each_entry(notifier, &curr->preempt_notifiers, link)
>                 notifier->ops->sched_in(notifier, raw_smp_processor_id());
> 
> and the Code: line disassembly is
> 
>    0: ff 11                callq  *(%rcx)
>    2: 4c 89 f9              mov    %r15,%rcx
>    5: 48 c1 e9 03          shr    $0x3,%rcx
>    9: 42 80 3c 31 00        cmpb   $0x0,(%rcx,%r14,1)
>    e: 0f 85 1b 02 00 00    jne    0x22f
>   14: 4d 8b 3f              mov    (%r15),%r15
>   17: 4d 85 ff              test   %r15,%r15
>   1a: 0f 84 c0 fd ff ff    je     0xfffffffffffffde0
>   20: 49 8d 7f 10          lea    0x10(%r15),%rdi
>   24: 48 89 f9              mov    %rdi,%rcx
>   27: 48 c1 e9 03          shr    $0x3,%rcx
>   2b:* 42 80 3c 31 00        cmpb   $0x0,(%rcx,%r14,1) <-- trapping instruction
>   30: 74 ae                je     0xffffffffffffffe0
>   32: e8 a7 cc 5b 00        callq  0x5bccde
>   37: eb a7                jmp    0xffffffffffffffe0
>   39: 4c 89 fe              mov    %r15,%rsi
>   3c: 4c 89 e7              mov    %r12,%rdi
> 
> and while the "callq *(%rcx)" might be just the end part of some
> previous instruction, I think it may be right (there is indeed an
> indirect call in that function - that very "->sched_in()" call).
> 
> So I think the oops happens after the indirect call returns.
> 
> I think the second "callq" is
> 
>     call    __asan_report_load8_noabort
> 
> and the actual trapping instruction is loading the KASAN byte state.
> 
> As far as I can tell, the kasan check is trying to check this part of
> hlist_for_each_entry():
> 
>     movq    (%r15), %r15    # notifier_110->link.next,
> 
> and %r15 is dead000000000100, which is LIST_POISON1.
> 
> End result: KASAN actually makes these things harder to debug, because
> it's trying to "validate" the list poison values before they are used,
> and takes a much more complex and indirect fault in the process,
> instead of just getting a page-fault on the LIST_POISON1 that would
> have made it more obvious.
> 
> Oh well.
> 
> There is nothing in this that indicates that it's actually related to
> KASAN, and it _should_ oops even without KASAN enabled.
> 
> But the reproducer does nothing for me. Of course, I didn't actually
> run it on linux-next at all, so it is quite possibly related to
> scheduler work (or the TLB/pagetable work) that just hasn't hit
> mainstream yet.
> 
> None of the scheduler people seem to have been on the report, though.
> Adding some in.

So the only user of that preempt_notifier stuff is KVM, if you don't run
a guest the notifiers are empty and are in fact disabled with a
static_key.

We've not touched this part of the scheduler in a fair while. I'll go
dig out the original report and see if that reproducer does anything for
me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
