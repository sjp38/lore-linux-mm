Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9436B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:20:52 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x2so11358685plv.16
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:20:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g190sor456829pfc.105.2018.02.14.11.20.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 11:20:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180214025533.GA28811@bombadil.infradead.org>
References: <001a1144c4ca5dc9d6056520c7b7@google.com> <20180214025533.GA28811@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 14 Feb 2018 20:20:29 +0100
Message-ID: <CACT4Y+YMhfpQQBPgVuH=bLwovO1-TPOyN95JP84XVgSydreG8w@mail.gmail.com>
Subject: Re: WARNING in kvmalloc_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, syzkaller-bugs@googlegroups.com, Vlastimil Babka <vbabka@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, netdev <netdev@vger.kernel.org>

On Wed, Feb 14, 2018 at 3:55 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Feb 13, 2018 at 03:59:01PM -0800, syzbot wrote:
>> Hello,
>>
>> syzbot hit the following crash on bpf-next commit
>> 7928b2cbe55b2a410a0f5c1f154610059c57b1b2 (Sun Feb 11 23:04:29 2018 +0000)
>> Linux 4.16-rc1
>>
>> So far this crash happened 236 times on bpf-next.
>> C reproducer is attached.
>> syzkaller reproducer is attached.
>> Raw console output is attached.
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached.
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com
>> It will help syzbot understand when the bug is fixed. See footer for
>> details.
>> If you forward the report, please keep this part and the footer.
>>
>> audit: type=1400 audit(1518457683.474:7): avc:  denied  { map } for
>> pid=4183 comm="syzkaller238030" path="/root/syzkaller238030826" dev="sda1"
>> ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
>> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
>> WARNING: CPU: 1 PID: 4183 at mm/util.c:403 kvmalloc_node+0xc3/0xd0
>> mm/util.c:403
>
> This WARN_ON is telling us that we were called with the wrong GFP flags.
>
>> audit: type=1400 audit(1518457683.474:8): avc:  denied  { map_create } for
>> pid=4183 comm="syzkaller238030"
>> scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
>> tcontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023 tclass=bpf
>> permissive=1
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 1 PID: 4183 Comm: syzkaller238030 Not tainted 4.16.0-rc1+ #12
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:17 [inline]
>>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>> audit: type=1400 audit(1518457683.474:9): avc:  denied  { map_read map_write
>> } for  pid=4183 comm="syzkaller238030"
>> scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
>> tcontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023 tclass=bpf
>> permissive=1
>>  panic+0x1e4/0x41c kernel/panic.c:183
>>  __warn+0x1dc/0x200 kernel/panic.c:547
>>  report_bug+0x211/0x2d0 lib/bug.c:184
>>  fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>>  fixup_bug arch/x86/kernel/traps.c:247 [inline]
>>  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>>  invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:988
>> RIP: 0010:kvmalloc_node+0xc3/0xd0 mm/util.c:403
>> RSP: 0018:ffff8801b436f6e8 EFLAGS: 00010293
>> RAX: ffff8801b1dd25c0 RBX: 0000000001088220 RCX: ffffffff81970ca3
>> RDX: 0000000000000000 RSI: 0000000001088220 RDI: 0000000000000070
>> RBP: ffff8801b436f708 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000070
>> R13: 0000000000000000 R14: 00000000ffffffff R15: ffff8801d304cd00
>>  kvmalloc include/linux/mm.h:541 [inline]
>>  kvmalloc_array include/linux/mm.h:557 [inline]
>>  __ptr_ring_init_queue_alloc include/linux/ptr_ring.h:474 [inline]
>>  ptr_ring_init include/linux/ptr_ring.h:492 [inline]
>>  __cpu_map_entry_alloc kernel/bpf/cpumap.c:359 [inline]
>>  cpu_map_update_elem+0x3c3/0x8e0 kernel/bpf/cpumap.c:490
>>  map_update_elem kernel/bpf/syscall.c:698 [inline]
>
> Blame the BPF people, not the MM people ;-)

Done:
https://github.com/google/syzkaller/commit/77ed06bf1628ff4554aa800240fbc22bb2a133b7
Now will be attributed to kernel/bpf/cpumap.c and titled "WARNING:
kmalloc bug in cpu_map_update_elem".

Thanks!


>>  SYSC_bpf kernel/bpf/syscall.c:1872 [inline]
>>  SyS_bpf+0x215f/0x4860 kernel/bpf/syscall.c:1843
>>  do_syscall_64+0x282/0x940 arch/x86/entry/common.c:287
>>  entry_SYSCALL_64_after_hwframe+0x26/0x9b
>> RIP: 0033:0x43fda9
>> RSP: 002b:00007ffe6b075798 EFLAGS: 00000203 ORIG_RAX: 0000000000000141
>> RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 000000000043fda9
>> RDX: 0000000000000020 RSI: 0000000020ef4fe0 RDI: 0000000000000002
>> RBP: 00000000006ca018 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000203 R12: 00000000004016d0
>> R13: 0000000000401760 R14: 0000000000000000 R15: 0000000000000000
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>>
>>
>> ---
>> This bug is generated by a dumb bot. It may contain errors.
>> See https://goo.gl/tpsmEJ for details.
>> Direct all questions to syzkaller@googlegroups.com.
>>
>> syzbot will keep track of this bug report.
>> If you forgot to add the Reported-by tag, once the fix for this bug is
>> merged
>> into any tree, please reply to this email with:
>> #syz fix: exact-commit-title
>> If you want to test a patch for this bug, please reply with:
>> #syz test: git://repo/address.git branch
>> and provide the patch inline or as an attachment.
>> To mark this as a duplicate of another syzbot report, please reply with:
>> #syz dup: exact-subject-of-another-report
>> If it's a one-off invalid bug report, please reply with:
>> #syz invalid
>> Note: if the crash happens again, it will cause creation of a new bug
>> report.
>> Note: all commands must start from beginning of the line in the email body.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
