Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACCE46B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:04:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y2-v6so5809410pll.16
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:04:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y17-v6si18997190plp.219.2018.07.11.14.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:04:50 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:04:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: general protection fault in _vm_normal_page
Message-Id: <20180711140449.3702358d7e8898017e34dcfd@linux-foundation.org>
In-Reply-To: <00000000000010c9390570bc0643@google.com>
References: <00000000000010c9390570bc0643@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com>
Cc: jglisse@redhat.com, kirill.shutemov@linux.intel.com, ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, ross.zwisler@linux.intel.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On Wed, 11 Jul 2018 09:49:01 -0700 syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com> wrote:

> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    98be45067040 Add linux-next specific files for 20180711
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=12496ac2400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=3f3b3673fec35d01
> dashboard link: https://syzkaller.appspot.com/bug?extid=120abb1c3f7bfdc523f7
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=12a46568400000

Handy.  /dev/ion from drivers/staging/android/ion/ion.c

> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com
> 
> R10: 0000000004000812 R11: 0000000000000246 R12: 0000000000000005
> R13: 00000000004c0565 R14: 00000000004cffb0 R15: 0000000000000005
> ion_mmap: failure mapping buffer to userspace
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> CPU: 0 PID: 4785 Comm: syz-executor0 Not tainted 4.18.0-rc4-next-20180711+  
> #4
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> RIP: 0010:_vm_normal_page+0x1e5/0x330 mm/memory.c:828

Presumably has a NULL vma->vm_ops.  Probably one of the now-removed
checks in mm-drop-unneeded-vm_ops-checks.patch would have avoided
this.

Something for Kirill to think about ;)
