Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2B66B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 09:40:35 -0400 (EDT)
Received: by pdea3 with SMTP id a3so84296311pde.3
        for <linux-mm@kvack.org>; Fri, 08 May 2015 06:40:35 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gg10si7025493pbc.14.2015.05.08.06.39.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 06:39:45 -0700 (PDT)
Message-ID: <554CBC99.2050808@parallels.com>
Date: Fri, 8 May 2015 16:39:37 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
References: <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com> <55425A74.3020604@parallels.com> <20150507134236.GB13098@redhat.com> <554B769E.1040000@parallels.com> <20150507143343.GG13098@redhat.com> <554B79C0.5060807@parallels.com> <20150507151136.GH13098@redhat.com> <554B82D4.4060809@parallels.com> <20150507170802.GI13098@redhat.com>
In-Reply-To: <20150507170802.GI13098@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>

Andrea,

On 05/07/2015 08:08 PM, Andrea Arcangeli wrote:
> On Thu, May 07, 2015 at 06:20:52PM +0300, Pavel Emelyanov wrote:
>> Yes. Longer message (type + 3 u64-s) and the ability to request for extra
>> events is all I need. If you're OK with this being in the 0xAA API, then
> 
> This started from the request to get the full address (even if
> personally I'm not convinced that the bits below PAGE_SHIFT can be
> meaningful to userland) but I thought we could achieve both things and
> hopefully this change is for the best.
> 
> Can you have a look at this and let me know if it looks ok?


On the recent userfaultfd branch (dee0a1d0) even w/o my patches I see the stack
corruption panic. It only appeared after the uffd_msg introduction, but maybe I 
just was lucky before it :)

[   48.302949] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff81251ad9
[   48.302949] 
[   48.303032] CPU: 0 PID: 603 Comm: a.out Not tainted 4.1.0-rc2-uffd-criu+ #27
[   48.303032] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   48.303032]  0000000000000000 00000000e6804e19 ffff88003da13c28 ffffffff816c584a
[   48.303032]  0000000000000000 ffffffff819fc4b8 ffff88003da13ca8 ffffffff816c136e
[   48.303032]  ffff880000000010 ffff88003da13cb8 ffff88003da13c58 00000000e6804e19
[   48.303032] Call Trace:
[   48.303032]  [<ffffffff816c584a>] dump_stack+0x45/0x57
[   48.303032]  [<ffffffff816c136e>] panic+0xd0/0x204
[   48.303032]  [<ffffffff81251ad9>] ? userfault_msg+0x69/0x70
[   48.303032]  [<ffffffff8108c76b>] __stack_chk_fail+0x1b/0x20
[   48.303032]  [<ffffffff81251ad9>] userfault_msg+0x69/0x70
[   48.303032]  [<ffffffff81251ce0>] ? userfaultfd_poll+0x80/0x80
[   48.303032]  [<ffffffff810cf7b0>] ? abort_exclusive_wait+0xb0/0xb0
[   48.303032]  [<ffffffff811be622>] ? handle_mm_fault+0x1692/0x1900
[   48.303032]  [<ffffffff810be358>] ? __enqueue_entity+0x78/0x80
[   48.303032]  [<ffffffff810c2369>] ? pick_next_entity+0xa9/0x190
[   48.303032]  [<ffffffff810c9450>] ? pick_next_task_fair+0x640/0x900
[   48.303032]  [<ffffffff81054e61>] ? __do_page_fault+0x181/0x420
[   48.303032]  [<ffffffff810551c7>] ? trace_do_page_fault+0x47/0x110
[   48.303032]  [<ffffffff8105028e>] ? do_async_page_fault+0x1e/0xe0
[   48.303032]  [<ffffffff816ceb98>] ? async_page_fault+0x28/0x30
[   48.303032] Kernel Offset: disabled
[   48.303032] ---[ end Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff81251ad9

What I do is a trivial test -- fork a kid, make uffd, create and register a mapping, send 
one to child and access the memory. Child reads the uffd_msg and copies the data back. Crash
happens when parent reads the memory and parents sits in read(). The address in question is
in the userfaultfd_msg():

ffffffff81251a70 <userfault_msg>:
ffffffff81251a70:       55                      push   %rbp
ffffffff81251a71:       48 89 f8                mov    %rdi,%rax
ffffffff81251a74:       48 89 e5                mov    %rsp,%rbp
ffffffff81251a77:       48 83 ec 10             sub    $0x10,%rsp
ffffffff81251a7b:       c6 00 12                movb   $0x12,(%rax)
ffffffff81251a7e:       65 48 8b 3c 25 28 00    mov    %gs:0x28,%rdi
ffffffff81251a85:       00 00 
ffffffff81251a87:       48 89 7d f8             mov    %rdi,-0x8(%rbp)
ffffffff81251a8b:       31 ff                   xor    %edi,%edi
ffffffff81251a8d:       83 e2 01                and    $0x1,%edx
ffffffff81251a90:       48 c7 45 f0 00 00 00    movq   $0x0,-0x10(%rbp)
ffffffff81251a97:       00 
ffffffff81251a98:       48 c7 45 f8 00 00 00    movq   $0x0,-0x8(%rbp)
ffffffff81251a9f:       00 
ffffffff81251aa0:       48 c7 45 00 00 00 00    movq   $0x0,0x0(%rbp)
ffffffff81251aa7:       00 
ffffffff81251aa8:       48 c7 45 08 00 00 00    movq   $0x0,0x8(%rbp)
ffffffff81251aaf:       00 
ffffffff81251ab0:       48 89 70 10             mov    %rsi,0x10(%rax)
ffffffff81251ab4:       74 04                   je     ffffffff81251aba <userfault_msg+0x4a>
ffffffff81251ab6:       83 48 08 01             orl    $0x1,0x8(%rax)
ffffffff81251aba:       80 e5 10                and    $0x10,%ch
ffffffff81251abd:       74 04                   je     ffffffff81251ac3 <userfault_msg+0x53>
ffffffff81251abf:       83 48 08 02             orl    $0x2,0x8(%rax)
ffffffff81251ac3:       48 8b 7d f8             mov    -0x8(%rbp),%rdi
ffffffff81251ac7:       65 48 33 3c 25 28 00    xor    %gs:0x28,%rdi
ffffffff81251ace:       00 00 
ffffffff81251ad0:       75 02                   jne    ffffffff81251ad4 <userfault_msg+0x64>
ffffffff81251ad2:       c9                      leaveq 
ffffffff81251ad3:       c3                      retq   
ffffffff81251ad4:       e8 77 ac e3 ff          callq  ffffffff8108c750 <__stack_chk_fail>
ffffffff81251ad9:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
