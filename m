Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86B886B026C
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 09:23:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id f185so22177189itc.2
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:23:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m62si9242120iof.251.2017.12.18.06.23.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 06:23:18 -0800 (PST)
Subject: Re: BUG: bad usercopy in memdup_user
References: <001a113e9ca8a3affd05609d7ccf@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
Date: Mon, 18 Dec 2017 23:22:46 +0900
MIME-Version: 1.0
In-Reply-To: <001a113e9ca8a3affd05609d7ccf@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, dave@nullcore.net, keescook@chromium.org, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-kernel@vger.kernel.org, mark.rutland@arm.com, mingo@kernel.org, syzkaller-bugs@googlegroups.com, will.deacon@arm.com

On 2017/12/18 22:40, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> 
> Unfortunately, I don't have any reproducer for this bug yet.
> 
> 

This BUG is reporting

[   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)

line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?

> netlink: 1 bytes leftover after parsing attributes in process `syz-executor5'.
> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:84!
> invalid opcode: 0000 [#1] SMP
> Dumping ftrace buffer:
> A A  (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 3943 Comm: syz-executor0 Not tainted 4.15.0-rc3-next-20171214+ #67
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> RIP: 0010:report_usercopy mm/usercopy.c:76 [inline]
> RIP: 0010:__check_object_size+0x1e2/0x250 mm/usercopy.c:276
> RSP: 0018:ffffc90000d6fca8 EFLAGS: 00010292
> RAX: 0000000000000062 RBX: ffffffff82e57be7 RCX: ffffffff8123dede
> RDX: 0000000000006340 RSI: ffffc900036c9000 RDI: ffff88021fc136f8
> RBP: ffffc90000d6fce0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801e076dc50
> R13: 0000000000000400 R14: 0000000000000000 R15: ffffffff82edf8a5
> FS:A  00007fe747e20700(0000) GS:ffff88021fc00000(0000) knlGS:0000000000000000
> CS:A  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000002000bffa CR3: 00000001dbd02006 CR4: 00000000001626f0
> DR0: 0000000020000000 DR1: 0000000000010000 DR2: 000000000000f004
> DR3: 0000000000000000 DR6: 00000000fffe0ff3 DR7: 0000000000000600
> Call Trace:
> A check_object_size include/linux/thread_info.h:112 [inline]
> A check_copy_size include/linux/thread_info.h:143 [inline]
> A copy_from_user include/linux/uaccess.h:146 [inline]
> A memdup_user+0x46/0x90 mm/util.c:168
> A kvm_arch_vcpu_ioctl+0xc85/0x1810 arch/x86/kvm/x86.c:3499
> A kvm_vcpu_ioctl+0xf3/0x820 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2715
> A vfs_ioctl fs/ioctl.c:46 [inline]
> A do_vfs_ioctl+0xaf/0x840 fs/ioctl.c:686
> A SYSC_ioctl fs/ioctl.c:701 [inline]
> A SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
> A entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x452a09
> RSP: 002b:00007fe747e1fc58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 000000000071bea0 RCX: 0000000000452a09
> RDX: 0000000020ebec00 RSI: 000000004400ae8f RDI: 0000000000000019
> RBP: 000000000000023b R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 00000000006f0628
> R13: 00000000ffffffff R14: 00007fe747e206d4 R15: 0000000000000000
> Code: 7b e5 82 48 0f 44 da e8 8d 82 eb ff 48 8b 45 d0 4d 89 e9 4c 89 e1 4c 89 fa 48 89 de 48 c7 c7 a8 51 e6 82 49 89 c0 e8 76 b7 e3 ff <0f> 0b 48 c7 c0 43 51 e6 82 eb a1 48 c7 c0 53 51 e6 82 eb 98 48
> RIP: report_usercopy mm/usercopy.c:76 [inline] RSP: ffffc90000d6fca8
> RIP: __check_object_size+0x1e2/0x250 mm/usercopy.c:276 RSP: ffffc90000d6fca8
> ---[ end trace 189465b430781fff ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
> A A  (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
