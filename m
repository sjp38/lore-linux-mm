Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF626B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:34:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z3-v6so3116476pln.23
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:34:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3-v6si3855762pll.392.2018.03.15.05.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 05:34:29 -0700 (PDT)
Date: Thu, 15 Mar 2018 13:34:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: KVM hang after OOM
Message-ID: <20180315123427.GI23100@dhcp22.suse.cz>
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
 <20180312090054.mqu56pju7nijjufh@node.shutemov.name>
 <CABXGCsOKkqXTA417GQLE-aj_kYxuQF9W++2HQ=JO-BV3vjCqdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOKkqXTA417GQLE-aj_kYxuQF9W++2HQ=JO-BV3vjCqdQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, kvm@vger.kernel.org

On Mon 12-03-18 23:56:05, Mikhail Gavrilov wrote:
[...]
> [  355.531533] ============================================
> [  355.531534] WARNING: possible recursive locking detected
> [  355.531536] 4.16.0-rc1-amd-vega+ #6 Not tainted
> [  355.531537] --------------------------------------------
> [  355.531539] CPU 0/KVM/4034 is trying to acquire lock:
> [  355.531540]  (&mm->mmap_sem){++++}, at: [<0000000026cd8acd>] get_user_pages_unlocked+0xe0/0x1d0
> [  355.531549] 
>                but task is already holding lock:
> [  355.531550]  (&mm->mmap_sem){++++}, at: [<000000000690373b>] get_user_pages_unlocked+0x5e/0x1d0
> [  355.531554] 
>                other info that might help us debug this:
> [  355.531555]  Possible unsafe locking scenario:
> 
> [  355.531556]        CPU0
> [  355.531557]        ----
> [  355.531558]   lock(&mm->mmap_sem);
> [  355.531559]   lock(&mm->mmap_sem);
> [  355.531561] 
>                 *** DEADLOCK ***
> 
> [  355.531562]  May be due to missing lock nesting notation
> 
> [  355.531564] 3 locks held by CPU 0/KVM/4034:
> [  355.531564]  #0:  (&vcpu->mutex){+.+.}, at: [<00000000230699e6>] kvm_vcpu_ioctl+0x81/0x6b0 [kvm]
> [  355.531586]  #1:  (&kvm->srcu){....}, at: [<000000000a3cc9a1>] kvm_arch_vcpu_ioctl_run+0x752/0x1b90 [kvm]
> [  355.531602]  #2:  (&mm->mmap_sem){++++}, at: [<000000000690373b>] get_user_pages_unlocked+0x5e/0x1d0

Is this lockdep report real or a false positive? Because many tasks are
failing to take a mmap_sem. Maybe the same one?

[...]
> [  615.239436] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  615.239437] pidof           D11816  5076   5071 0x00000000
> [  615.239441] Call Trace:
> [  615.239443]  ? __schedule+0x2e9/0xba0
> [  615.239446]  ? rwsem_down_read_failed+0x147/0x190
> [  615.239449]  schedule+0x2f/0x90
> [  615.239450]  rwsem_down_read_failed+0x118/0x190
> [  615.239455]  ? call_rwsem_down_read_failed+0x14/0x30
> [  615.239457]  call_rwsem_down_read_failed+0x14/0x30
> [  615.239460]  ? proc_pid_cmdline_read+0xd2/0x4a0
> [  615.239462]  down_read+0x97/0xa0
> [  615.239464]  proc_pid_cmdline_read+0xd2/0x4a0
> [  615.239467]  ? lock_acquire+0x9f/0x200
> [  615.239469]  ? debug_check_no_obj_freed+0xda/0x244
> [  615.239473]  ? __vfs_read+0x36/0x170
> [  615.239475]  __vfs_read+0x36/0x170
> [  615.239479]  vfs_read+0x9e/0x150
> [  615.239482]  SyS_read+0x55/0xc0
> [  615.239484]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [  615.239487]  do_syscall_64+0x7a/0x220
> [  615.239489]  entry_SYSCALL_64_after_hwframe+0x26/0x9b
> [  615.239491] RIP: 0033:0x7f4d5da16701
> [  615.239492] RSP: 002b:00007ffd5200b188 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> [  615.239494] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f4d5da16701
> [  615.239496] RDX: 00000000000007ff RSI: 00007ffd5200b1a0 RDI: 0000000000000004
> [  615.239497] RBP: 0000000000000042 R08: 0000000000000007 R09: 00007f4d5e1825f4
> [  615.239498] R10: 0000000000000000 R11: 0000000000000246 R12: 000055abb07f5980
> [  615.239500] R13: 00007ffd5200b1a0 R14: 0000000000000004 R15: 0000000000000000
> [  615.239505] INFO: lockdep is turned off.
> [  639.815026] kworker/dying (149) used greatest stack depth: 10520 bytes left


-- 
Michal Hocko
SUSE Labs
