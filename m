Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9A066B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 17:08:10 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id i4so7598758oah.38
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 14:08:10 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id i2si18542711oeu.51.2014.03.10.14.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 14:08:10 -0700 (PDT)
Message-ID: <1394485688.3867.13.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [vma caching] BUG: unable to handle kernel paging request at
 ffff880008142f40
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 10 Mar 2014 14:08:08 -0700
In-Reply-To: <20140310024356.GB9322@localhost>
References: <20140310024356.GB9322@localhost>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-03-10 at 10:43 +0800, Fengguang Wu wrote:
> Hi Davidlohr,
> 
> I got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> commit 0d9ad4220e6d73f63a9eeeaac031b92838f75bb3
> Author:     Davidlohr Bueso <davidlohr@hp.com>
> AuthorDate: Thu Mar 6 11:01:48 2014 +1100
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Thu Mar 6 11:01:48 2014 +1100
> 
>     mm: per-thread vma caching
>     
> hwclock: can't open '/dev/misc/rtc': No such file or directory
> Running postinst /etc/rpm-postinsts/100...

Hmm this kind of errors strike me as dealing with some bogus vma from a
stale cache.

> [    3.658976] BUG: unable to handle kernel paging request at ffff880008142f40
> [    3.661422] IP: [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
> [    3.662223] PGD 2542067 PUD 2543067 PMD fba5067 PTE 8000000008142060
> [    3.662223] Oops: 0000 [#1] DEBUG_PAGEALLOC
> [    3.662223] Modules linked in:
> [    3.662223] CPU: 0 PID: 326 Comm: 90-trinity Not tainted 3.14.0-rc5-next-20140307 #1

Have you only seen this through DEBUG_PAGEALLOC + trinity?

> [    3.662223] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [    3.662223] task: ffff8800083020d0 ti: ffff8800082a0000 task.ti: ffff8800082a0000
> [    3.662223] RIP: 0010:[<ffffffff8111a1d8>]  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
> [    3.662223] RSP: 0000:ffff8800082a1e00  EFLAGS: 00010282
> [    3.662223] RAX: ffff880008142f40 RBX: 00000000000000a9 RCX: ffff8800083020d0
> [    3.662223] RDX: 0000000000000002 RSI: 00007fff8a141698 RDI: ffff880008124bc0
> [    3.662223] RBP: ffff8800082a1e00 R08: 0000000000000000 R09: 0000000000000001
> [    3.662223] R10: ffff8800083020d0 R11: 0000000000000000 R12: 00007fff8a141698
> [    3.662223] R13: ffff880008124bc0 R14: ffff8800082a1f58 R15: ffff8800083020d0
> [    3.662223] FS:  00007fe3ca364700(0000) GS:ffffffff81a06000(0000) knlGS:0000000000000000
> [    3.662223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    3.662223] CR2: ffff880008142f40 CR3: 000000000824c000 CR4: 00000000000006b0
> [    3.662223] Stack:
> [    3.662223]  ffff8800082a1e28 ffffffff81125219 00000000000000a9 00007fff8a141698
> [    3.662223]  ffff880008124bc0 ffff8800082a1f28 ffffffff816d71fe 0000000000000246
> [    3.662223]  0000000000000002 ffff880008124c58 0000000000000006 0000000000000010
> [    3.662223] Call Trace:
> [    3.662223]  [<ffffffff81125219>] find_vma+0x19/0x70
> [    3.662223]  [<ffffffff816d71fe>] __do_page_fault+0x29e/0x560
> [    3.662223]  [<ffffffff8116cc6f>] ? mntput_no_expire+0x6f/0x1a0
> [    3.662223]  [<ffffffff8116cc11>] ? mntput_no_expire+0x11/0x1a0
> [    3.662223]  [<ffffffff8116cdd5>] ? mntput+0x35/0x40
> [    3.662223]  [<ffffffff8114f51f>] ? __fput+0x24f/0x290
> [    3.662223]  [<ffffffff812794ca>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> [    3.662223]  [<ffffffff816d74ce>] do_page_fault+0xe/0x10
> [    3.662223]  [<ffffffff816d6ad5>] do_async_page_fault+0x35/0x90
> [    3.662223]  [<ffffffff816d3b05>] async_page_fault+0x25/0x30
> [    3.662223] Code: c7 81 b0 02 00 00 00 00 00 00 eb 32 0f 1f 80 00 00 00 00 31 d2 66 0f 1f 44 00 00 48 63 c2 48 8b 84 c1 98 02 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 0a 83 c2 01 83 fa 04 75 dd 31 c0 
> [    3.662223] RIP  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90

So this is:
   0:   c7 81 b0 02 00 00 00    movl   $0x0,0x2b0(%rcx)
   7:   00 00 00 
   a:   eb 32                   jmp    0x3e
   c:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)
  13:   31 d2                   xor    %edx,%edx
  15:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
  1b:   48 63 c2                movslq %edx,%rax
  1e:   48 8b 84 c1 98 02 00    mov    0x298(%rcx,%rax,8),%rax
  25:   00 
  26:   48 85 c0                test   %rax,%rax
  29:   74 0b                   je     0x36
  2b:*  48 39 30                cmp    %rsi,(%rax)              <-- trapping instruction


which seems to be the following, where vma is stale:
		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
			return vma;


  2e:   77 06                   ja     0x36
  30:   48 3b 70 08             cmp    0x8(%rax),%rsi
  34:   72 0a                   jb     0x40
  36:   83 c2 01                add    $0x1,%edx
  39:   83 fa 04                cmp    $0x4,%edx
  3c:   75 dd                   jne    0x1b
  3e:   31 c0                   xor    %eax,%eax

Could you please try this fix: https://lkml.org/lkml/2014/3/10/505 - it
is fix for a race Oleg found that can cause us to keep bogus vmas in the
cache under certain VM_CLONE scenarios. Also, how frequently are you
able to trigger this?

Thanks for the report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
