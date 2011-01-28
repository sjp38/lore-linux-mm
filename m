Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 289B08D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 11:51:41 -0500 (EST)
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0SGot9b002214
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 11:50:55 -0500
Date: Fri, 28 Jan 2011 17:50:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: pgd_lock must be taken with irqs enabled
Message-ID: <20110128165050.GI16981@random.random>
References: <20110126135252.GQ926@random.random>
 <77942321.201910.1296197041743.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <77942321.201910.1296197041743.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 01:44:01AM -0500, CAI Qian wrote:
> > > INFO: task pgrep:6039 blocked for more than 120 seconds.
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> > > message.
> > > pgrep D ffff887f606f1ab0 0 6039 6038 0x00000080
> > >  ffff8821e39c1ce0 0000000000000082 0000000000000246 0000000000000000
> > >  0000000000014d40 ffff887f606f1520 ffff887f606f1ab0 ffff8821e39c1fd8
> > >  ffff887f606f1ab8 0000000000014d40 ffff8821e39c0010 0000000000014d40
> > > Call Trace:
> > >  [<ffffffff814afeb5>] rwsem_down_failed_common+0xb5/0x140
> > >  [<ffffffff814aff75>] rwsem_down_read_failed+0x15/0x17
> > >  [<ffffffff81230174>] call_rwsem_down_read_failed+0x14/0x30
> > >  [<ffffffff814af504>] ? down_read+0x24/0x30
> > >  [<ffffffff8111f4dc>] access_process_vm+0x4c/0x200
> > >  [<ffffffff8113f3fe>] ? fallback_alloc+0x14e/0x270
> > >  [<ffffffff811afa4d>] proc_pid_cmdline+0x6d/0x120
> > >  [<ffffffff81137eba>] ? alloc_pages_current+0x9a/0x100
> > >  [<ffffffff811b037d>] proc_info_read+0xad/0xf0
> > >  [<ffffffff81154315>] vfs_read+0xc5/0x190
> > >  [<ffffffff811544e1>] sys_read+0x51/0x90
> > >  [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
> > 
> > pgrep hung too, it's not just khugepaged hanging and it's not obvious
> > for now that khugepaged was guilty of forgetting an unlock, could be
> > the process deadlocked somewhere with the mmap_sem hold. Can you press
> > SYSRQ+T? Hopefully that will show the holder. Also is CONFIG_NUMA=y/n?
> Unfortunately, SYSRQ+T was not working. CONFIG_NUMA=y and this is an
> NUMA system as well.

I reviewed it again but it's unlikely the holder of the mmap_sem was
khugepaged. Something hung on the mmap_sem and pgrep and khugepaged
got blocked on it.

I'm however aware of a deadlock in pgd_lock, no idea if it's what
you're hitting but it worth fixing that one now!

x86 takes the pgd_lock by clearing irqs, and then it takes the
page_table_lock with irqs already off. It's always forbidden to keep
irqs off while taking the page_table_lock, because all IPIs are sent
for the tlb flushes with the page_table_lock held if PT locks are
disabled (NR_CPUS small) or if THP is on.  It's not THP bug, it's core
bug in pgd_lock that will trigger with PT locks disabled too without
THP: all those spin_lock_irqsave must become spin_lock. Either that or
the page_table_lock must not be taken with irqs off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
