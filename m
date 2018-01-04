Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10F2D280262
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 13:50:51 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id a17so1220769otd.15
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 10:50:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v198sor1169515oia.174.2018.01.04.10.50.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jan 2018 10:50:49 -0800 (PST)
Subject: Re: WARNING in __alloc_pages_slowpath
References: <94eb2c081602cc13290561f3b471@google.com>
 <7bb33381-4167-b0e0-2de1-dd9faa1fc463@suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <aa57fa20-dba4-1df2-4b60-80b9563c8fed@redhat.com>
Date: Thu, 4 Jan 2018 10:50:46 -0800
MIME-Version: 1.0
In-Reply-To: <7bb33381-4167-b0e0-2de1-dd9faa1fc463@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+76e7efc4748495855a4d@syzkaller.appspotmail.com>, akpm@linux-foundation.org, kemi.wang@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, syzkaller-bugs@googlegroups.com, Sumit Semwal <sumit.semwal@linaro.org>
Cc: devel@driverdev.osuosl.org

On 01/04/2018 06:10 AM, Vlastimil Babka wrote:
> On 01/04/2018 02:57 PM, syzbot wrote:
>> Hello,
>>
>> syzkaller hit the following crash on
>> 71ee203389f7cb1c1927eab22b95baa01405791c
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>> C reproducer is attached
>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>> for information about syzkaller reproducers
>>
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+76e7efc4748495855a4d@syzkaller.appspotmail.com
>> It will help syzbot understand when the bug is fixed. See footer for
>> details.
>> If you forward the report, please keep this part and the footer.
>>
>> audit: type=1400 audit(1514727386.271:7): avc:  denied  { map } for
>> pid=3485 comm="syzkaller426814" path="/root/syzkaller426814263" dev="sda1"
>> ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
>> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
>> WARNING: CPU: 1 PID: 3485 at mm/page_alloc.c:3926
>> __alloc_pages_slowpath+0x1ffc/0x2d00 mm/page_alloc.c:3936
> 
> This is a warning about order >= MAX_ORDER.
> 
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 1 PID: 3485 Comm: syzkaller426814 Not tainted 4.15.0-rc5+ #244
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>    __dump_stack lib/dump_stack.c:17 [inline]
>>    dump_stack+0x194/0x257 lib/dump_stack.c:53
>>    panic+0x1e4/0x41c kernel/panic.c:183
>>    __warn+0x1dc/0x200 kernel/panic.c:547
>>    report_bug+0x211/0x2d0 lib/bug.c:184
>>    fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>>    fixup_bug arch/x86/kernel/traps.c:247 [inline]
>>    do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>>    do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>>    invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:1079
>> RIP: 0010:__alloc_pages_slowpath+0x1ffc/0x2d00 mm/page_alloc.c:3936
>> RSP: 0018:ffff8801c011f418 EFLAGS: 00010246
>> RAX: ffffed0038023ea4 RBX: 1ffff10038023ea4 RCX: 0000000000000000
>> RDX: ffff8801c011fa70 RSI: 0000000000000033 RDI: 0000000000000000
>> RBP: ffff8801c011f908 R08: 0000000000000000 R09: fffffffffff80f8a
>> R10: 0000000000000033 R11: 0000000000000033 R12: 0000000000000000
>> R13: ffff8801c011fad0 R14: 00000000014280c2 R15: ffff8801c011fa70
>>    __alloc_pages_nodemask+0x9fb/0xd80 mm/page_alloc.c:4252
>>    alloc_pages_current+0xb6/0x1e0 mm/mempolicy.c:2036
>>    alloc_pages include/linux/gfp.h:492 [inline]
>>    ion_system_contig_heap_allocate+0x40/0x2c0
>> drivers/staging/android/ion/ion_system_heap.c:374
> 
> And the allocation came from here. It should use smaller order, or
> __NOWARN if this is some kind of opportunistic attempt. Maybe the order
> comes all the way from userspace ioctl?
> 

Yes, the order is coming directly from userspace as the size
requested for an Ion allocation. I think we do need to at least
pass __NOWARN for the system contig heap case.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
