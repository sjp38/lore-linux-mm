Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A54F6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 19:19:38 -0500 (EST)
Received: by qyk5 with SMTP id 5so864287qyk.14
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:19:29 -0800 (PST)
Message-ID: <3e8340490901141619g3c32ebads482d1176efbd98a3@mail.gmail.com>
Date: Wed, 14 Jan 2009 19:19:29 -0500
From: "Bryan Donlan" <bdonlan@gmail.com>
Subject: Re: OOPS and panic on 2.6.29-rc1 on xen-x86
In-Reply-To: <20090114025910.GA17395@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090112172613.GA8746@shion.is.fushizen.net>
	 <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com>
	 <20090114025910.GA17395@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 13, 2009 at 9:59 PM, Nick Piggin <npiggin@suse.de> wrote:
> On Mon, Jan 12, 2009 at 11:54:32PM -0500, Bryan Donlan wrote:
>> On Mon, Jan 12, 2009 at 12:26 PM, Bryan Donlan <bdonlan@gmail.com> wrote:
>> > [resending with log/config inline as my previous message seems to have
>> >  been eaten by vger's spam filters]
>> >
>> > Hi,
>> >
>> > After testing 2.6.29-rc1 on xen-x86 with a btrfs root filesystem, I
>> > got the OOPS quoted below and a hard freeze shortly after boot.
>> > Boot messages and config are attached.
>> >
>> > This is on a test system, so I'd be happy to test any patches.
>> >
>> > Thanks,
>> >
>> > Bryan Donlan
>>
>> I've bisected the bug in question, and the faulty commit appears to be:
>> commit e97a630eb0f5b8b380fd67504de6cedebb489003
>> Author: Nick Piggin <npiggin@suse.de>
>> Date:   Tue Jan 6 14:39:19 2009 -0800
>>
>>     mm: vmalloc use mutex for purge
>>
>>     The vmalloc purge lock can be a mutex so we can sleep while a purge is
>>     going on (purge involves a global kernel TLB invalidate, so it can take
>>     quite a while).
>>
>>     Signed-off-by: Nick Piggin <npiggin@suse.de>
>>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>> The bug is easily reproducable by a kernel build on -j4 - it will
>> generally OOPS and panic before the build completes.
>> Also, I've tested it with ext3, and it still occurs, so it seems
>> unrelated to btrfs at least :)
>>
>> >
>> > ------------[ cut here ]------------
>> > Kernel BUG at c05ef80d [verbose debug info unavailable]
>> > invalid opcode: 0000 [#1] SMP
>> > last sysfs file: /sys/block/xvdc/size
>> > Modules linked in:
>
> It is bugging in schedule somehow, but you don't have verbose debug
> info compiled in. Can you compile that in and reproduce if you have
> the time?
>
> Going bug here might indicate that there is some other problem with
> the Xen and/or vmalloc code, regardless of reverting this patch.
>
> Thanks,
> Nick
>

Here's one from a config with CONFIG_DEBUG_BUGVERBOSE:

------------[ cut here ]------------
kernel BUG at /root/linux-2.6/arch/x86/include/asm/mmu_context_32.h:39!
invalid opcode: 0000 [#1] SMP
last sysfs file:
Modules linked in:

Pid: 13, comm: ksoftirqd/3 Not tainted (2.6.29-rc1badwdebug #18)
EIP: 0061:[<c0597e2c>] EFLAGS: 00010087 CPU: 3
EIP is at schedule+0x52c/0x980
EAX: d5b47580 EBX: 00000003 ECX: 00000000 EDX: d5b2de40
ESI: c12f9200 EDI: d5b2de40 EBP: d6059030 ESP: d6071f40
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0069
Process ksoftirqd/3 (pid: 13, ti=d6070000 task=d6059030 task.ti=d6070000)
Stack:
 c06c0d80 c06c0e00 c06c0200 c0105cf6 c06c0200 c06c0200 c06c0200 d60edbd0
 c0599c10 d5b2de40 c0776200 c06c0d80 c06c0e00 c12f5ec0 d6059030 d60591c4
 00000003 00000100 c0165e73 c684ddb8 00000012 d6070200 d60591c4 c070b5d4
Call Trace:
 [<c0105cf6>] check_events+0x8/0x12
 [<c0599c10>] _spin_unlock_irqrestore+0x20/0x40
 [<c0165e73>] rcu_process_callbacks+0x33/0x40
 [<c0105cf6>] check_events+0x8/0x12
 [<c0105c5f>] xen_restore_fl_direct_end+0x0/0x1
 [<c013354d>] ksoftirqd+0xdd/0x120
 [<c0133470>] ksoftirqd+0x0/0x120
 [<c0142769>] kthread+0x39/0x70
 [<c0142730>] kthread+0x0/0x70
 [<c0108d53>] kernel_thread_helper+0x7/0x10
Code: 00 00 e9 0a fe ff ff e8 d3 1f 00 00 8d 76 00 e9 33 fb ff ff 89
f0 e8 e4 e5 b6 ff 90 51 52 ff 15 a8 df 6b c0 5a 59 e9 52 fe ff ff <0f>
0b eb fe a1 00 2b 6f c0 8b 6c 24 40 05 e8 03 00 00 89 44 24
EIP: [<c0597e2c>] schedule+0x52c/0x980 SS:ESP 0069:d6071f40
---[ end trace 60197587eb4e6dfb ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
