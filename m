Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84F046B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:56:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r2-v6so617998pgp.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:56:20 -0700 (PDT)
Received: from SMTP03.CITRIX.COM (smtp03.citrix.com. [162.221.156.55])
        by mx.google.com with ESMTPS id a21-v6si1238037pgm.417.2018.07.17.08.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:56:19 -0700 (PDT)
From: Anoob Soman <anoob.soman@citrix.com>
Subject: GP fault in free_pcppages_bulk() while trying to list_del(&page->lru)
Message-ID: <1f1b5a3a-9787-a134-992e-b8fbc2a9e86b@citrix.com>
Date: Tue, 17 Jul 2018 16:55:54 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi All,

A customer of us have encountered GP fault, when free_pcppages_bulk() 
tries to access list_del(). A snippet of kernel backtrace is pasted below.

CPU: 1 PID: 0 Comm: swapper/1 Tainted: GA A A A A A A A A A  OA A A  4.4.0+2 #1
Hardware name: IBM System x3650 M3 -[7945K2G]-/69Y5698, BIOS 
-[D6E162AUS-1.20]- 05/07/2014
task: ffff880189dbb580 ti: ffff880189dc4000 task.ti: ffff880189dc4000
RIP: e030:[<ffffffff8115e055>]A  [<ffffffff8115e055>] 
free_pcppages_bulk+0xe5/0x520
RSP: e02b:ffff88018a823d70A  EFLAGS: 00010093
RAX: ffffea0004150f20 RBX: ffffffff81ac3040 RCX: ffff88018a839058
RDX: dead000000000200 RSI: ffffea00057b4900 RDI: dead000000000100
RBP: ffff88018a823dd0 R08: 0000000000000525 R09: ffffea00057b4940
R10: 0000000000000560 R11: ffff88007ee9f000 R12: 0000000004150f00
R13: 0000000000000001 R14: 0000160000000000 R15: ffffea0004150f00
FS:A  00007fa2bc2e9840(0000) GS:ffff88018a820000(0000) 
knlGS:0000000000000000
CS:A  e033 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 00007ffafd0e3b50 CR3: 0000000149f34000 CR4: 0000000000002660
Stack:
ffff88018a823d98 ffffffff81ac34d0 ffff88018a82ae80 ffff88018a839038
ffff88018a839058 0000000100000052 0000000000000001 ffff88018a839038
ffffffff81ac0040 ffffffff8115e590 0000000000000000 0000000000000000
Call Trace:
<IRQ>
[<ffffffff8115e590>] ? page_alloc_cpu_notify+0x50/0x50
[<ffffffff8115e4cf>] drain_pages_zone+0x3f/0x60
[<ffffffff8115e51f>] drain_pages+0x2f/0x50
[<ffffffff8115e5b5>] drain_local_pages+0x25/0x30
[<ffffffff810e3d58>] flush_smp_call_function_queue+0xc8/0x130
[<ffffffff810e45d3>] generic_smp_call_function_single_interrupt+0x13/0x60
[<ffffffff81014303>] xen_call_function_interrupt+0x13/0x30
[<ffffffff810bff2f>] handle_irq_event_percpu+0x7f/0x1e0
[<ffffffff810c347a>] handle_percpu_irq+0x3a/0x50
[<ffffffff810bf732>] generic_handle_irq+0x22/0x30
[<ffffffff813c646b>] __evtchn_fifo_handle_events+0x14b/0x170
[<ffffffff813c64a0>] evtchn_fifo_handle_events+0x10/0x20
[<ffffffff813c34ba>] __xen_evtchn_do_upcall+0x4a/0x80
[<ffffffff813c5290>] xen_evtchn_do_upcall+0x30/0x50
[<ffffffff815a25ae>] xen_do_hypervisor_callback+0x1e/0x40
<EOI>

I tried decoding as much as I can, but I am confused at the moment 
wondering how this crash could happen.

Some relevant bits of objdump free_pcppages_bulk(), which is mainly 
list_del().
ffffffff8115e034:A A A A A A  48 bf 00 01 00 00 00A A A  movabs 
$0xdead000000000100,%rdi
ffffffff8115e03b:A A A A A A  00 ad de
ffffffff8115e03e:A A A A A A  48 8b 40 08A A A A A A A A A A A A  mov 0x8(%rax),%rax
ffffffff8115e042:A A A A A A  48 8b 50 08A A A A A A A A A A A A  mov 0x8(%rax),%rdx
ffffffff8115e046:A A A A A A  48 8b 08A A A A A A A A A A A A A A A  movA A A  (%rax),%rcx
ffffffff8115e049:A A A A A A  4c 8d 78 e0A A A A A A A A A A A A  lea -0x20(%rax),%r15
ffffffff8115e04d:A A A A A A  4f 8d 24 37A A A A A A A A A A A A  lea (%r15,%r14,1),%r12
ffffffff8115e051:A A A A A A  48 89 51 08A A A A A A A A A A A A  mov %rdx,0x8(%rcx)
ffffffff8115e055:A A A A A A  48 89 0aA A A A A A A A A A A A A A A  movA A A  %rcx,(%rdx) 
<------ RIP is here
ffffffff8115e058:A A A A A A  48 ba 00 02 00 00 00A A A  movabs 
$0xdead000000000200,%rdx
ffffffff8115e05f:A A A A A A  00 ad de
ffffffff8115e062:A A A A A A  48 89 38A A A A A A A A A A A A A A A  movA A A  %rdi,(%rax)
ffffffff8115e065:A A A A A A  48 89 50 08A A A A A A A A A A A A  mov %rdx,0x8(%rax)

RIP points to ffffffff8115e055 and GP fault because RDX contains 
LIST_POISON2. RDI contains LIST_POISON1 (this doesn't matter as it is 
just a temporary register which holds POISON1)

Based on objdump, I can conclude that RDX points to entry->prev and RCX 
points to entry->next.

free_pcppages_bulk() tries to delete an entry, from pcp->list, whose 
"prev" pointer is LIST_POISON2, but "next" pointer is not poisoned. Is 
it safe to assume that this entry was in the middle of being add into a 
list and free_pcppages_bulk() went and deleted it ? One possibility it a 
different CPU is processing another CPU pcp list, but looking to the 
code, I am certain that this can never happen.

Are there any other explanation why this might happen.

As you can see from backtrace, we are running 4.4-24 kernel and we might 
have missed some patches. But looking at the history of commits, I don't 
see anything relevant fixed in this area.

Can someone point me right direction as to how to debug this further.

Thanks,
Anoob.
