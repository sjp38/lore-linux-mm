Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 786776B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 14:51:18 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id n12so3809460wgh.0
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 11:51:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id db4si6343174wjb.69.2014.03.06.11.51.16
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 11:51:16 -0800 (PST)
Date: Thu, 6 Mar 2014 14:51:06 -0500
From: Dave Jones <davej@redhat.com>
Subject: Bad page map during process exit. (ext4_file_mmap)
Message-ID: <20140306195106.GA9470@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

Just hit this while building a kernel on 3.14rc5

[60602.562954] BUG: Bad page map in process systemd-udevd  pte:ffff88005d47e270 pmd:148048067
[60602.563792] addr:00007fcf338e8000 vm_flags:08000070 anon_vma:          (null) mapping:ffff88009f2622f0 index:12c
[60602.564613] vma->vm_ops->fault: filemap_fault+0x0/0x420
[60602.565426] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x70
[60602.566245] CPU: 1 PID: 7946 Comm: systemd-udevd Not tainted 3.14.0-rc5+ #130 
[60602.567939]  ffff8801a5915200 0000000001ae188a ffff880199503c78 ffffffffa672edd8
[60602.568783]  00007fcf338e8000 ffff880199503cc0 ffffffffa617cfb4 ffff88005d47e270
[60602.569626]  000000000000012c ffff880148048740 00007fcf33800000 ffff880199503df0
[60602.570486] Call Trace:
[60602.571358]  [<ffffffffa672edd8>] dump_stack+0x4e/0x7a
[60602.572244]  [<ffffffffa617cfb4>] print_bad_pte+0x184/0x230
[60602.573116]  [<ffffffffa617ea58>] unmap_single_vma+0x738/0x8a0
[60602.573974]  [<ffffffffa617fce9>] unmap_vmas+0x49/0x90
[60602.574815]  [<ffffffffa6189095>] exit_mmap+0xe5/0x1a0
[60602.575655]  [<ffffffffa6068d13>] mmput+0x73/0x110
[60602.576495]  [<ffffffffa606d022>] do_exit+0x2a2/0xb50
[60602.577340]  [<ffffffffa60aa0a1>] ? vtime_account_user+0x91/0xa0
[60602.578193]  [<ffffffffa615213b>] ? context_tracking_user_exit+0x9b/0x100
[60602.579067]  [<ffffffffa606e8cc>] do_group_exit+0x4c/0xc0
[60602.579939]  [<ffffffffa606e954>] SyS_exit_group+0x14/0x20
[60602.580818]  [<ffffffffa67429ea>] tracesys+0xd4/0xd9

It's possible that the damage had been done by an earlier fuzzing run, and we never
touched that memory until the kernel install caused us to trip over it.
Only seen this one once so far.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
