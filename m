Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D75326B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 20:58:34 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id v37-v6so3938603uag.6
        for <linux-mm@kvack.org>; Sat, 26 May 2018 17:58:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s200-v6sor3041420vks.51.2018.05.26.17.58.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 17:58:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000000000000f1e2b9056d1f663c@google.com>
References: <000000000000f1e2b9056d1f663c@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 26 May 2018 17:58:32 -0700
Message-ID: <CAGXu5j+DR2ZFyxUdJuY1wGchwmN=XD0s3c1N6ZipEYuBWzkyxg@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in __kvm_write_guest_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+083f3b88782aa3a46bdb@syzkaller.appspotmail.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

On Sat, May 26, 2018 at 10:42 AM, syzbot
<syzbot+083f3b88782aa3a46bdb@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    73fcb1a370c7 Merge branch 'akpm' (patches from Andrew)
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=15b3a827800000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=f3b4e30da84ec1ed
> dashboard link: https://syzkaller.appspot.com/bug?extid=083f3b88782aa3a46bdb
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=1027dbcf800000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=159eff97800000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+083f3b88782aa3a46bdb@syzkaller.appspotmail.com
>
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> from SLAB object 'kvm_vcpu' (offset 23192, size 8)!

Looks like something else besides the "arch" field is being copied
in/out of struct kvm_vcpu? (Also, whoa, 22K struct?) Oh, in looking, I
assume it's something in struct vcpu_vmx ?

(i.e. this is not fixed by 46515736f8687 ("kvm: whitelist struct
kvm_vcpu_arch").)

Looks like this is:

        if (kvm_write_guest_virt_system(&vcpu->arch.emulate_ctxt, vmcs_gva,
                                 (void *)&to_vmx(vcpu)->nested.current_vmptr,
                                 sizeof(u64), &e)) {

... this is a fixed size, but it looks like it gets down to the
copy_*_user() as a variable so automatically whitelisting is
happening. :(

-Kees

> WARNING: CPU: 0 PID: 4554 at mm/usercopy.c:81 usercopy_warn+0xf5/0x120
> mm/usercopy.c:76
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 0 PID: 4554 Comm: syz-executor726 Not tainted 4.17.0-rc5+ #58
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
>  panic+0x22f/0x4de kernel/panic.c:184
>  __warn.cold.8+0x163/0x1b3 kernel/panic.c:536
>  report_bug+0x252/0x2d0 lib/bug.c:186
>  fixup_bug arch/x86/kernel/traps.c:178 [inline]
>  do_error_trap+0x1de/0x490 arch/x86/kernel/traps.c:296
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:992
> RIP: 0010:usercopy_warn+0xf5/0x120 mm/usercopy.c:76
> RSP: 0018:ffff8801ad54f0b0 EFLAGS: 00010286
> RAX: 000000000000007e RBX: ffffffff889d52f0 RCX: ffffffff8160aa5d
> RDX: 0000000000000000 RSI: ffffffff8160f711 RDI: ffff8801ad54ec10
> RBP: ffff8801ad54f110 R08: ffff8801d96c8680 R09: 0000000000000006
> R10: ffff8801d96c8680 R11: 0000000000000000 R12: ffffffff87d2fa60
> R13: ffffffff87c19ec0 R14: 0000000000000000 R15: 0000000000000008
>  __check_heap_object+0x89/0xb5 mm/slab.c:4440
>  check_heap_object mm/usercopy.c:236 [inline]
>  __check_object_size+0x4c7/0x5d9 mm/usercopy.c:259
>  check_object_size include/linux/thread_info.h:108 [inline]
>  __copy_to_user include/linux/uaccess.h:104 [inline]
>  __kvm_write_guest_page+0x90/0x140
> arch/x86/kvm/../../../virt/kvm/kvm_main.c:1828
>  kvm_vcpu_write_guest_page arch/x86/kvm/../../../virt/kvm/kvm_main.c:1849
> [inline]
>  kvm_vcpu_write_guest+0x65/0xe0
> arch/x86/kvm/../../../virt/kvm/kvm_main.c:1883
>  kvm_write_guest_virt_system+0x8a/0x190 arch/x86/kvm/x86.c:4843
>  handle_vmptrst+0x1d2/0x260 arch/x86/kvm/vmx.c:8196
>  vmx_handle_exit+0x2c0/0x17b0 arch/x86/kvm/vmx.c:9234
>  vcpu_enter_guest+0x13af/0x6060 arch/x86/kvm/x86.c:7503
>  vcpu_run arch/x86/kvm/x86.c:7565 [inline]
>  kvm_arch_vcpu_ioctl_run+0x33e/0x1690 arch/x86/kvm/x86.c:7742
>  kvm_vcpu_ioctl+0x79d/0x12e0 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2560
>  vfs_ioctl fs/ioctl.c:46 [inline]
>  file_ioctl fs/ioctl.c:500 [inline]
>  do_vfs_ioctl+0x1cf/0x16a0 fs/ioctl.c:684
>  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:701
>  __do_sys_ioctl fs/ioctl.c:708 [inline]
>  __se_sys_ioctl fs/ioctl.c:706 [inline]
>  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:706
>  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x443039
> RSP: 002b:00007ffc272242b8 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 0000000000443039
> RDX: 0000000000000000 RSI: 000000000000ae80 RDI: 0000000000000005
> RBP: 00000000006cd018 R08: 0000000020000580 R09: 0000000020000580
> R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000404080
> R13: 0000000000404110 R14: 0000000000000000 R15: 0000000000000000
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches



-- 
Kees Cook
Pixel Security
