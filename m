Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C815F6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:26:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w5so17174842pgt.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:26:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 201sor5309481pga.272.2017.12.22.00.26.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 00:26:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com> <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
 <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 22 Dec 2017 09:26:28 +0100
Message-ID: <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
Subject: Re: general protection fault in finish_task_switch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 9:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Dec 21, 2017 at 10:42:04AM -0800, Linus Torvalds wrote:
>> On Wed, Dec 20, 2017 at 8:03 AM, syzbot
>> <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>
>> wrote:
>> > Hello,
>> >
>> > syzkaller hit the following crash on
>> > 7dc9f647127d6955ffacaf51cb6a627b31dceec2
>> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> >
>> > kasan: CONFIG_KASAN_INLINE enabled
>> > kasan: GPF could be caused by NULL-ptr deref or user memory access
>> > general protection fault: 0000 [#1] SMP KASAN
>> > Dumping ftrace buffer:
>> >    (ftrace buffer empty)
>> > Modules linked in:
>> > CPU: 0 PID: 4227 Comm: syzkaller244813 Not tainted 4.15.0-rc4-next-20171220+
>> > #77
>> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> > Google 01/01/2011
>> > RIP: __fire_sched_in_preempt_notifiers kernel/sched/core.c:2534 [inline]
>>
>> That line 2534 is the call inside the hlist_for_each_entry() loop:
>>
>>         hlist_for_each_entry(notifier, &curr->preempt_notifiers, link)
>>                 notifier->ops->sched_in(notifier, raw_smp_processor_id());
>>
>> and the Code: line disassembly is
>>
>>    0: ff 11                callq  *(%rcx)
>>    2: 4c 89 f9              mov    %r15,%rcx
>>    5: 48 c1 e9 03          shr    $0x3,%rcx
>>    9: 42 80 3c 31 00        cmpb   $0x0,(%rcx,%r14,1)
>>    e: 0f 85 1b 02 00 00    jne    0x22f
>>   14: 4d 8b 3f              mov    (%r15),%r15
>>   17: 4d 85 ff              test   %r15,%r15
>>   1a: 0f 84 c0 fd ff ff    je     0xfffffffffffffde0
>>   20: 49 8d 7f 10          lea    0x10(%r15),%rdi
>>   24: 48 89 f9              mov    %rdi,%rcx
>>   27: 48 c1 e9 03          shr    $0x3,%rcx
>>   2b:* 42 80 3c 31 00        cmpb   $0x0,(%rcx,%r14,1) <-- trapping instruction
>>   30: 74 ae                je     0xffffffffffffffe0
>>   32: e8 a7 cc 5b 00        callq  0x5bccde
>>   37: eb a7                jmp    0xffffffffffffffe0
>>   39: 4c 89 fe              mov    %r15,%rsi
>>   3c: 4c 89 e7              mov    %r12,%rdi
>>
>> and while the "callq *(%rcx)" might be just the end part of some
>> previous instruction, I think it may be right (there is indeed an
>> indirect call in that function - that very "->sched_in()" call).
>>
>> So I think the oops happens after the indirect call returns.
>>
>> I think the second "callq" is
>>
>>     call    __asan_report_load8_noabort
>>
>> and the actual trapping instruction is loading the KASAN byte state.
>>
>> As far as I can tell, the kasan check is trying to check this part of
>> hlist_for_each_entry():
>>
>>     movq    (%r15), %r15    # notifier_110->link.next,
>>
>> and %r15 is dead000000000100, which is LIST_POISON1.
>>
>> End result: KASAN actually makes these things harder to debug, because
>> it's trying to "validate" the list poison values before they are used,
>> and takes a much more complex and indirect fault in the process,
>> instead of just getting a page-fault on the LIST_POISON1 that would
>> have made it more obvious.
>>
>> Oh well.
>>
>> There is nothing in this that indicates that it's actually related to
>> KASAN, and it _should_ oops even without KASAN enabled.
>>
>> But the reproducer does nothing for me. Of course, I didn't actually
>> run it on linux-next at all, so it is quite possibly related to
>> scheduler work (or the TLB/pagetable work) that just hasn't hit
>> mainstream yet.
>>
>> None of the scheduler people seem to have been on the report, though.
>> Adding some in.
>
> So the only user of that preempt_notifier stuff is KVM, if you don't run
> a guest the notifiers are empty and are in fact disabled with a
> static_key.
>
> We've not touched this part of the scheduler in a fair while. I'll go
> dig out the original report and see if that reproducer does anything for
> me.


I think this is another manifestation of "KASAN: use-after-free Read
in __schedule":
https://groups.google.com/forum/#!msg/syzkaller-bugs/-8JZhr4W8AY/FpPFh8EqAQAJ
+Eric already mailed a fix for it (indeed new bug in kvm code).

Let's tell syzbot:

#syz dup: KASAN: use-after-free Read in __schedule

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
