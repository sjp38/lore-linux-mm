Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB7EB6B03A5
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:48:58 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id v33so9213915uaf.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:48:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j22sor58335uab.18.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Feb 2017 04:48:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bkN=S-a6_JLai7G8EtSBSe+G=eHES90KXMvg+12YmjUg@mail.gmail.com>
References: <CACT4Y+bkN=S-a6_JLai7G8EtSBSe+G=eHES90KXMvg+12YmjUg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Feb 2017 13:48:36 +0100
Message-ID: <CACT4Y+aWWOdCsMjEjg9dq1+f1_gCgWoXbO_P8NMjx_guvbKLtw@mail.gmail.com>
Subject: Re: kvm: WARNING in nested_vmx_vmexit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, KVM list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jim Mattson <jmattson@google.com>, Steve Rutherford <srutherford@google.com>, haozhong.zhang@intel.com, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: syzkaller <syzkaller@googlegroups.com>

On Tue, Feb 28, 2017 at 1:15 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> The following program triggers WARNING in nested_vmx_vmexit:
> https://gist.githubusercontent.com/dvyukov/16b946d7dc703bb07b9b933f12fb8a6e/raw/dac60506feb8dd9dd22828c486e46ee8a5e30f13/gistfile1.txt
>
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 27742 at arch/x86/kvm/vmx.c:11029
> nested_vmx_vmexit+0x5c35/0x74d0 arch/x86/kvm/vmx.c:11029
> CPU: 1 PID: 27742 Comm: a.out Not tainted 4.10.0+ #229
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  panic+0x1fb/0x412 kernel/panic.c:179
>  __warn+0x1c4/0x1e0 kernel/panic.c:540
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:583
>  nested_vmx_vmexit+0x5c35/0x74d0 arch/x86/kvm/vmx.c:11029
>  vmx_leave_nested arch/x86/kvm/vmx.c:11136 [inline]
>  vmx_set_msr+0x1565/0x1910 arch/x86/kvm/vmx.c:3324
>  kvm_set_msr+0xd4/0x170 arch/x86/kvm/x86.c:1099
>  do_set_msr+0x11e/0x190 arch/x86/kvm/x86.c:1128
>  __msr_io arch/x86/kvm/x86.c:2577 [inline]
>  msr_io+0x24b/0x450 arch/x86/kvm/x86.c:2614
>  kvm_arch_vcpu_ioctl+0x35b/0x46a0 arch/x86/kvm/x86.c:3497
>  kvm_vcpu_ioctl+0x232/0x1120 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2721
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x451229
> RSP: 002b:00007fc1e7ebec98 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000451229
> RDX: 0000000020aecfe8 RSI: 000000004008ae89 RDI: 0000000000000008
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> R13: 0000000000000000 R14: 00007fc1e7ebf9c0 R15: 00007fc1e7ebf700
>
>
> On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570


The bug that I tried to localize is a different one:

WARNING: CPU: 1 PID: 4106 at mm/filemap.c:259
__delete_from_page_cache+0x1066/0x1390 mm/filemap.c:259
CPU: 1 PID: 4106 Comm: syz-executor Not tainted 4.10.0+ #229
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 panic+0x1fb/0x412 kernel/panic.c:179
 __warn+0x1c4/0x1e0 kernel/panic.c:540
 warn_slowpath_null+0x2c/0x40 kernel/panic.c:583
 __delete_from_page_cache+0x1066/0x1390 mm/filemap.c:259
 delete_from_page_cache+0x242/0x720 mm/filemap.c:282
 truncate_complete_page mm/truncate.c:156 [inline]
 truncate_inode_page+0x2ce/0x510 mm/truncate.c:195
 shmem_undo_range+0x90c/0x2720 mm/shmem.c:828
 shmem_truncate_range+0x27/0xa0 mm/shmem.c:956
 shmem_evict_inode+0x35f/0xca0 mm/shmem.c:1047
 evict+0x46e/0x980 fs/inode.c:553
 iput_final fs/inode.c:1515 [inline]
 iput+0x589/0xb20 fs/inode.c:1542
 dentry_unlink_inode+0x43b/0x600 fs/dcache.c:343
 __dentry_kill+0x34d/0x740 fs/dcache.c:538
 dentry_kill fs/dcache.c:579 [inline]
 dput.part.27+0x5ce/0x7c0 fs/dcache.c:791
 dput+0x1f/0x30 fs/dcache.c:753
 __fput+0x527/0x7f0 fs/file_table.c:226
 ____fput+0x15/0x20 fs/file_table.c:244
 task_work_run+0x18a/0x260 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x23b/0x2a0 arch/x86/entry/common.c:160
 prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
 syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
 entry_SYSCALL_64_fastpath+0xc0/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fb393062b58 EFLAGS: 00000282 ORIG_RAX: 0000000000000009
RAX: 0000000020000000 RBX: 0000000000708000 RCX: 00000000004458d9
RDX: 0000000000000003 RSI: 0000000000af7000 RDI: 0000000020000000
RBP: 0000000000002f20 R08: ffffffffffffffff R09: 0000000000000000
R10: 4000000000000032 R11: 0000000000000282 R12: 00000000006e0fe0
R13: 0000000020000000 R14: 0000000000af7000 R15: 0000000000000003


But it only reproduces when I run the following syzkaller program
using syz-execprog utility:

mmap(&(0x7f0000000000/0xaef000)=nil, (0xaef000), 0x3, 0x31,
0xffffffffffffffff, 0x0)
r0 = openat$kvm(0xffffffffffffff9c,
&(0x7f0000005000-0x9)="2f6465762f6b766d00", 0x0, 0x0)
r1 = ioctl$KVM_CREATE_VM(r0, 0xae01, 0x0)
r2 = ioctl$KVM_CREATE_VCPU(r1, 0xae41, 0x0)
getpid()
mmap(&(0x7f0000aef000/0x1000)=nil, (0x1000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
syz_kvm_setup_cpu$x86(r1, r2, &(0x7f0000274000/0x18000)=nil,
&(0x7f0000adf000)=[@text64={0x40,
&(0x7f000099d000-0x64)="b6c3f8e788595d2a1ba31779d22e2453ab6fe204d8cb17bc3c4ab8e3e0483b9931418b5c1612cb68cb1f08acd253883205213823efd610026d3b892f9ecf43c837882ddb41cb3a22a62644cc9081d865b5c7d6d371bfbc1b7da5ab28911fcb5667d0e8b0ca",
0x65}], 0x1, 0x42, &(0x7f0000ae2000-0x10)=[@vmwrite={0x8, 0x0, 0x1ff,
0x0, 0x4, 0x0, 0x1, 0x0, 0x6}], 0x1)
getpid()
ioctl$KVM_RUN(r2, 0xae80)
mmap(&(0x7f0000000000/0xaf7000)=nil, (0xaf7000), 0x3,
0x4000000000000032, 0xffffffffffffffff, 0x0)
ioctl$KVM_SET_MSRS(r2, 0x4008ae89, &(0x7f0000aed000-0x18)={0x1, 0x0,
[{0x3a, 0x0, 0x0}]})

The C reproducer does not reproduce the mm WARNING, but instead
triggers the kvm WARNING.
The program itself does not use any shared memory, so the shmem
regions in the warning probably refer to auxiliary shared memory
regions created by syz-execprog. The code running inside of kvm
somehow manager to corrupt them (?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
