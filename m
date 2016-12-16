Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 783FC6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:32:38 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so35894653wje.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:32:38 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id vt6si7271771wjb.55.2016.12.16.06.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:32:37 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id j10so14894782wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:32:37 -0800 (PST)
Date: Fri, 16 Dec 2016 15:32:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: crash during oom reaper
Message-ID: <20161216143235.GO13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
 <20161216140043.GN13940@dhcp22.suse.cz>
 <2d65449b-5f8a-7a29-e879-9c27bd1d4537@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d65449b-5f8a-7a29-e879-9c27bd1d4537@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 15:25:27, Vegard Nossum wrote:
> On 12/16/2016 03:00 PM, Michal Hocko wrote:
> > On Fri 16-12-16 14:14:17, Vegard Nossum wrote:
> > [...]
> > > Out of memory: Kill process 1650 (trinity-main) score 90 or sacrifice child
> > > Killed process 1724 (trinity-c14) total-vm:37280kB, anon-rss:236kB,
> > > file-rss:112kB, shmem-rss:112kB
> > > BUG: unable to handle kernel NULL pointer dereference at 00000000000001e8
> > > IP: [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
> > > PGD c001067 PUD c000067
> > > PMD 0
> > > Oops: 0002 [#1] PREEMPT SMP KASAN
> > > Dumping ftrace buffer:
> > >    (ftrace buffer empty)
> > > CPU: 28 PID: 1650 Comm: trinity-main Not tainted 4.9.0-rc6+ #317
> > 
> > Hmm, so this was the oom victim initially but we have decided to kill
> > its child 1724 instead.
> > 
> > > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> > > Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > > task: ffff88000f9bc440 task.stack: ffff88000c778000
> > > RIP: 0010:[<ffffffff8126b1c0>]  [<ffffffff8126b1c0>]
> > > copy_process.part.41+0x2150/0x5580
> > 
> > Could you match this to the kernel source please?
> 
> kernel/fork.c:629 dup_mmap()

Ok, so this is before the child is made visible so the oom reaper
couldn't have seen it.

> it's atomic_dec(&inode->i_writecount), it matches up with
> file_inode(file) == NULL:
> 
> (gdb) p &((struct inode *)0)->i_writecount
> $1 = (atomic_t *) 0x1e8 <irq_stack_union+488>

is this a p9 inode?

> 
> > > Killed process 1775 (trinity-c21) total-vm:37404kB, anon-rss:232kB,
> > > file-rss:420kB, shmem-rss:116kB
> > > oom_reaper: reaped process 1775 (trinity-c21), now anon-rss:0kB,
> > > file-rss:0kB, shmem-rss:116kB
> > > ==================================================================
> > > BUG: KASAN: use-after-free in p9_client_read+0x8f0/0x960 at addr
> > > ffff880010284d00
> > > Read of size 8 by task trinity-main/1649
> > > CPU: 3 PID: 1649 Comm: trinity-main Not tainted 4.9.0+ #318
> > > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> > > Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > >  ffff8800068a7770 ffffffff82012301 ffff88001100f600 ffff880010284d00
> > >  ffff880010284d60 ffff880010284d00 ffff8800068a7798 ffffffff8165872c
> > >  ffff8800068a7828 ffff880010284d00 ffff88001100f600 ffff8800068a7818
> > > Call Trace:
> > >  [<ffffffff82012301>] dump_stack+0x83/0xb2
> > >  [<ffffffff8165872c>] kasan_object_err+0x1c/0x70
> > >  [<ffffffff816589c5>] kasan_report_error+0x1f5/0x4e0
> > >  [<ffffffff81657d92>] ? kasan_slab_alloc+0x12/0x20
> > >  [<ffffffff82079357>] ? check_preemption_disabled+0x37/0x1e0
> > >  [<ffffffff81658e4e>] __asan_report_load8_noabort+0x3e/0x40
> > >  [<ffffffff82079300>] ? assoc_array_gc+0x1310/0x1330
> > >  [<ffffffff83b84c30>] ? p9_client_read+0x8f0/0x960
> > >  [<ffffffff83b84c30>] p9_client_read+0x8f0/0x960
> > 
> > no idea how we would end up with use after here. Even if I unmapped the
> > page then the read code should be able to cope with that. This smells
> > like a p9 issue to me.
> 
> This is fid->clnt dereference at the top of p9_client_read().
> 
> Ah, yes, this is the one coming from a page fault:
> 
> p9_client_read
> v9fs_fid_readpage
> v9fs_vfs_readpage
> handle_mm_fault
> __do_page_fault
> 
> the bad fid pointer is filp->private_data.
> 
> Hm, so I guess the file itself was NOT freed prematurely (as otherwise
> we'd probably have seen a KASAN report for the filp->private_data
> dereference), but the ->private_data itself was.
> 
> Maybe the whole thing is fundamentally a 9p bug and the OOM killer just
> happens to trigger it.

It smells like that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
