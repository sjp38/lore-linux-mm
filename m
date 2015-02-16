Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8DD6B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 10:09:43 -0500 (EST)
Received: by pdjz10 with SMTP id z10so36330773pdj.0
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 07:09:43 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ox2si7514423pbb.37.2015.02.16.07.09.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 07:09:42 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00H9HEAW4T70@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 15:13:44 +0000 (GMT)
Message-id: <54E2082F.4000100@samsung.com>
Date: Mon, 16 Feb 2015 18:09:35 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v11 19/19] kasan: enable instrumentation of global variables
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-20-git-send-email-a.ryabinin@samsung.com>
 <87a90ea7ge.fsf@rustcorp.com.au> <54E20238.3090902@samsung.com>
 <CACT4Y+bdf05fHtD87TtFZZYBgKudLna6yOBfs-dpYnccZJLhsw@mail.gmail.com>
In-reply-to: 
 <CACT4Y+bdf05fHtD87TtFZZYBgKudLna6yOBfs-dpYnccZJLhsw@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 02/16/2015 05:47 PM, Dmitry Vyukov wrote:
> Can a module be freed in an interrupt?
> 
> 

Since commit: c749637909ee ("module: fix race in kallsyms resolution during module load success.")
module's init section always freed rcu callback (rcu callbacks executed from softirq)

Currently, with DEBUG_PAGEALLOC and KASAN module loading always causing kernel crash.
It's harder to trigger this without DEBUG_PAGEALLOC because of lazy tlb flushing in vmalloc.

BUG: unable to handle kernel paging request at fffffbfff4011000
IP: [<ffffffff811d8f7b>] __asan_load8+0x2b/0xa0
PGD 7ffa3063 PUD 7ffa2063 PMD 484ea067 PTE 0
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in: ipv6
CPU: 0 PID: 30 Comm: kworker/0:1 Tainted: G        W       3.19.0-rc7-next-20150209+ #209
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
Workqueue: events free_work
task: ffff88006c5a8870 ti: ffff88006c630000 task.ti: ffff88006c630000
RIP: 0010:[<ffffffff811d8f7b>]  [<ffffffff811d8f7b>] __asan_load8+0x2b/0xa0
RSP: 0018:ffff88006c637cd8  EFLAGS: 00010286
RAX: fffffbfff4011000 RBX: ffffffffa0088000 RCX: ffffed000da000a9
RDX: dffffc0000000000 RSI: 0000000000000001 RDI: ffffffffa0088000
RBP: ffff88006c637d08 R08: 0000000000000000 R09: ffff88006d007840
R10: ffff88006d000540 R11: ffffed000da000a9 R12: ffffffffa0088000
R13: ffff88006d61a5d8 R14: ffff88006d61a5d8 R15: ffff88006d61a5c0
FS:  0000000000000000(0000) GS:ffff88006d600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: fffffbfff4011000 CR3: 000000004d967000 CR4: 00000000000006b0
Stack:
 ffff88006c637ce8 fffffbfff4011000 ffffffffa0088000 ffff88006d61a5d8
 ffff88006d61a5d8 ffff88006d61a5c0 ffff88006c637d28 ffffffff811bb1b8
 ffff88006c5bc618 ffff88006d617b28 ffff88006c637db8 ffffffff8108e1b0
Call Trace:
 [<ffffffff811bb1b8>] free_work+0x38/0x60
 [<ffffffff8108e1b0>] process_one_work+0x2a0/0x7d0
 [<ffffffff8108f653>] worker_thread+0x93/0x840
 [<ffffffff8108f5c0>] ? init_pwq.part.11+0x10/0x10
 [<ffffffff81096f37>] kthread+0x177/0x1a0
 [<ffffffff81096dc0>] ? kthread_worker_fn+0x290/0x290
 [<ffffffff81096dc0>] ? kthread_worker_fn+0x290/0x290
 [<ffffffff8158cd7c>] ret_from_fork+0x7c/0xb0
 [<ffffffff81096dc0>] ? kthread_worker_fn+0x290/0x290
Code: 48 b8 ff ff ff ff ff 7f ff ff 55 48 89 e5 48 83 ec 30 48 39 c7 76 59 48 ba 00 00 00 00 00 fc ff df 48 89 f8 48 c1 e8 03 48 01 d0 <66> 83 38 00 75 07 c9 c3 0f 1f 44 00 00 48 8d 4f 07 48 89 ce 48
RIP  [<ffffffff811d8f7b>] __asan_load8+0x2b/0xa0
 RSP <ffff88006c637cd8>
CR2: fffffbfff4011000
---[ end trace b9411d841784b6cf ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
