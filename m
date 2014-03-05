Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E3E3D6B0070
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 08:52:42 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1125381pab.27
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 05:52:42 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hh1si2502669pac.100.2014.03.05.05.52.37
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 05:52:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <53166881.1020504@oracle.com>
References: <530F3F0A.5040304@oracle.com>
 <20140227150313.3BA27E0098@blue.fi.intel.com>
 <53166881.1020504@oracle.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
Content-Transfer-Encoding: 7bit
Message-Id: <20140305135232.EC420E0098@blue.fi.intel.com>
Date: Wed,  5 Mar 2014 15:52:32 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Sasha Levin wrote:
> On 02/27/2014 10:03 AM, Kirill A. Shutemov wrote:
> > Sasha Levin wrote:
> >> >Hi all,
> >> >
> >> >While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
> >> >following spew:
> >> >
> >> >[ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
> > Hm, interesting.
> >
> > It seems we either failed to split huge page on vma split or it
> > materialized from under us. I don't see how it can happen:
> >
> >    - it seems we do the right thing with vma_adjust_trans_huge() in
> >      __split_vma();
> >    - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
> >      a place where we could drop it;
> >
> > Andrea, any ideas?
> 
> And a somewhat related issue (please correct me if I'm wrong):

Yeah. Looks similar. And I still have no idea how it could happened.

Do you trinity logs for the crash?

> 
> [ 2208.713223] kernel BUG at mm/mlock.c:528!
> [ 2208.713692] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2208.714488] Dumping ftrace buffer:
> [ 2208.715209]    (ftrace buffer empty)
> [ 2208.715759] Modules linked in:
> [ 2208.716206] CPU: 34 PID: 3736 Comm: trinity-c209 Tainted: G        W    3.14.0-rc5-next-20140304-sasha-00009-geaa4df0 #77
> [ 2208.717637] task: ffff880ff90c8000 ti: ffff880ff90c6000 task.ti: ffff880ff90c6000
> [ 2208.718742] RIP: 0010:[<ffffffff812a53d6>]  [<ffffffff812a53d6>] munlock_vma_pages_range+0x176/0x1d0
> [ 2208.720107] RSP: 0018:ffff880ff90c7e08  EFLAGS: 00010206
> [ 2208.720711] RAX: 00000000000001ff RBX: 000000000003f000 RCX: 0000000000000000
> [ 2208.721456] RDX: 000000000000003f RSI: ffffffff8129d92d RDI: ffffffff84476115
> [ 2208.721456] RBP: ffff880ff90c7ec8 R08: 0000000000000000 R09: 0000000000000000
> [ 2208.721456] R10: 0000000000000001 R11: 0000000000000000 R12: fffffffffffffff2
> [ 2208.721456] R13: ffff880313b41600 R14: 0000000000040000 R15: ffff880ff90c7e94
> [ 2208.721456] FS:  00007f2bd5330700(0000) GS:ffff88032bc00000(0000) knlGS:0000000000000000
> [ 2208.721456] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2208.721456] CR2: 0000000002767c90 CR3: 0000000ffa1d4000 CR4: 00000000000006e0
> [ 2208.721456] DR0: 00007f15fe555000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 2208.721456] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 2208.721456] Stack:
> [ 2208.721456]  0000000000000000 0000000000000000 0001880ff90c7e38 0000000000000000
> [ 2208.721456]  0000000000000000 ffff880313b41600 00000000f90c7e88 0000000000000000
> [ 2208.721456]  00ff880ff90c7e58 ffff880815e8cba0 ffff880ff90c7eb8 ffff880313b41600
> [ 2208.721456] Call Trace:
> [ 2208.721456]  [<ffffffff812a8a52>] do_munmap+0x1d2/0x350
> [ 2208.721456]  [<ffffffff84473eb6>] ? down_write+0xa6/0xc0
> [ 2208.721456]  [<ffffffff812a8c16>] ? vm_munmap+0x46/0x80
> [ 2208.721456]  [<ffffffff812a8c24>] vm_munmap+0x54/0x80
> [ 2208.721456]  [<ffffffff812a8c7c>] SyS_munmap+0x2c/0x40
> [ 2208.721456]  [<ffffffff84480110>] tracesys+0xdd/0xe2
> [ 2208.721456] Code: fd ff ff 4c 89 e6 48 89 c3 48 8d bd 40 ff ff ff e8 80 fa ff ff eb 2f 66 0f 1f 44 00 00 8b 45 cc 48 89 da 48 c1 ea 0c 85 d0 74 12 <0f> 0b 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f 44 00 00 ff c0 48
> [ 2208.721456] RIP  [<ffffffff812a53d6>] munlock_vma_pages_range+0x176/0x1d0
> [ 2208.721456]  RSP <ffff880ff90c7e08>
> 
> 
> Thanks,
> Sasha

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
