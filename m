Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D973A6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:28:32 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i7so4141663plt.3
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:28:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h193sor1866724pfe.34.2017.12.01.00.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 00:28:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZOiEeS8wTDT-LP=biO7tmmJTsf-B82XjK-sEs-zGiMkA@mail.gmail.com>
References: <94eb2c03c9bcc3b127055f11171d@google.com> <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
 <20171129050606.GF24001@zzz.localdomain> <20171130004743.GB65846@gmail.com> <CACT4Y+ZOiEeS8wTDT-LP=biO7tmmJTsf-B82XjK-sEs-zGiMkA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 1 Dec 2017 09:28:10 +0100
Message-ID: <CACT4Y+a7bP2L8_AvtMza1h1XkxhmDNn0TvFd_Z6xm9d-iwy8fQ@mail.gmail.com>
Subject: Re: WARNING: suspicious RCU usage (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, "Paul E. McKenney" <paulmck@us.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Thu, Nov 30, 2017 at 9:04 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Nov 30, 2017 at 1:47 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
>> On Tue, Nov 28, 2017 at 09:06:06PM -0800, Eric Biggers wrote:
>>> On Tue, Nov 28, 2017 at 01:30:26PM -0800, Andrew Morton wrote:
>>> >
>>> > It looks like blkcipher_walk_done() passed a bad address to kfree().
>>> >
>>>
>>> Indeed, it's freeing uninitialized memory because the Salsa20 algorithms are
>>> using the blkcipher_walk API incorrectly.  I've sent a patch to fix it:
>>>
>>> "crypto: salsa20 - fix blkcipher_walk API usage"

This is already applied to crypto tree, so let's do:

#syz fix: crypto: salsa20 - fix blkcipher_walk API usage


>>> I am not sure why the bug reports show up as "suspicious RCU usage", though.
>>>
>>> There were also a few other syzbot reports of this same underlying bug; I marked
>>> them as duplicates of this one.
>>>
>>
>> The reason the "suspicious RCU usage" warning appeared is that due to the
>> incorrect call to blkcipher_walk_done(), kunmap_atomic() was being called
>> without a preceding kmap_atomic(), causing the preemption count to get screwed
>> up.  This was in addition to the uninitialized pointer being kfree()'d.
>>
>> Running a reproducer does show more information after the "WARNING: suspicious
>> RCU usage" (see below).  So it does look like the report from syzkaller was
>> truncated, perhaps because two things went wrong right after each other.
>>
>> Also, maybe enabling CONFIG_DEBUG_PREEMPT would be useful?
>
>
> DEBUG_PREEMPT depends on PREEMPT, which is not enabled. So it seems
> there is nothing to debug. Or how would it help?
>
>
>
>> [    9.136392]
>> [    9.137202] =============================
>> [    9.138014] WARNING: suspicious RCU usage
>> [    9.138909] 4.15.0-rc1-00033-gef0010a30935 #113 Not tainted
>> [    9.141195] -----------------------------
>> [    9.142145] ./include/trace/events/kmem.h:142 suspicious rcu_dereference_check() usage!
>> [    9.144400]
>> [    9.144400] other info that might help us debug this:
>> [    9.144400]
>> [    9.146292]
>> [    9.146292] rcu_scheduler_active = 2, debug_locks = 1
>> [    9.148203] 1 lock held by syz_salsa20/625:
>> [    9.149215]  #0:  (sk_lock-AF_ALG){+.+.}, at: [<00000000e0f6099e>] af_alg_wait_for_data+0xd8/0x150
>> [    9.151682]
>> [    9.151682] stack backtrace:
>> [    9.152658] CPU: 1 PID: 625 Comm: syz_salsa20 Not tainted 4.15.0-rc1-00033-gef0010a30935 #113
>> [    9.154669] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> [    9.156408] Call Trace:
>> [    9.156964]  dump_stack+0x7c/0xb3
>> [    9.157696]  kfree+0x1c1/0x210
>> [    9.158377]  blkcipher_walk_done+0x21c/0x2c0
>> [    9.159319]  encrypt+0x7b/0xd0
>> [    9.160000]  ? skcipher_decrypt_blkcipher+0x40/0x50
>> [    9.161061]  ? skcipher_recvmsg+0x37a/0x3a0
>> [    9.161981]  ? sock_read_iter+0x93/0xd0
>> [    9.162835]  ? __vfs_read+0xcc/0x140
>> [    9.163582]  ? vfs_read+0x9c/0x130
>> [    9.164282]  ? SyS_read+0x45/0xb0
>> [    9.164974]  ? entry_SYSCALL_64_fastpath+0x1f/0x96
>> [    9.166015] kfree_debugcheck: out of range ptr 28h
>> [    9.166985] ------------[ cut here ]------------
>> [    9.167834] kernel BUG at mm/slab.c:2753!
>> [    9.168584] invalid opcode: 0000 [#1] SMP
>> [    9.169335] CPU: 1 PID: 625 Comm: syz_salsa20 Not tainted 4.15.0-rc1-00033-gef0010a30935 #113
>> [    9.171067] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> [    9.172689] task: 00000000ee01d793 task.stack: 0000000004031a33
>> [    9.173885] RIP: 0010:kfree_debugcheck+0x23/0x30
>> [    9.174833] RSP: 0018:ffffb46b0092fc80 EFLAGS: 00010096
>> [    9.175857] RAX: 0000000000000026 RBX: 0000000000000028 RCX: 0000000000000000
>> [    9.177218] RDX: 0000000000000001 RSI: ffff99daff5cccc8 RDI: ffff99daff5cccc8
>> [    9.178555] RBP: 0000000000000206 R08: 0000000000000001 R09: 0000000000000001
>> [    9.179923] R10: 000000001f5d6993 R11: 0000000000000000 R12: ffffffff85b64b1c
>> [    9.181284] R13: 0000000000000000 R14: ffffb46b0092fd98 R15: ffff99daf87b9000
>> [    9.182617] FS:  00000000013bb880(0000) GS:ffff99daff400000(0000) knlGS:0000000000000000
>> [    9.184148] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    9.185246] CR2: 00007f087bad7008 CR3: 0000000079f52003 CR4: 00000000001606e0
>> [    9.186608] Call Trace:
>> [    9.187081]  kfree+0x5a/0x210
>> [    9.187602]  blkcipher_walk_done+0x21c/0x2c0
>> [    9.188370]  encrypt+0x7b/0xd0
>> [    9.188933]  ? skcipher_decrypt_blkcipher+0x40/0x50
>> [    9.189796]  ? skcipher_recvmsg+0x37a/0x3a0
>> [    9.190541]  ? sock_read_iter+0x93/0xd0
>> [    9.191241]  ? __vfs_read+0xcc/0x140
>> [    9.191897]  ? vfs_read+0x9c/0x130
>> [    9.192502]  ? SyS_read+0x45/0xb0
>> [    9.193110]  ? entry_SYSCALL_64_fastpath+0x1f/0x96
>> [    9.193959] Code: 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53 48 89 fb e8 32 f5 e1 ff 84 c0 74 02 5b c3 48 89 de 48 c7 c7 50 9c 21 86 e8 9a a0 f1 ff <0f> 0b 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 41 57 89
>> [    9.197364] RIP: kfree_debugcheck+0x23/0x30 RSP: ffffb46b0092fc80
>> [    9.198455] ---[ end trace 833d54cb4ca6de67 ]---
>> [    9.199291] Kernel panic - not syncing: Fatal exception in interrupt
>> [    9.200595] Kernel Offset: 0x4600000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
>> [    9.202405] Rebooting in 5 seconds..
>>
>> --
>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20171130004743.GB65846%40gmail.com.
>> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
