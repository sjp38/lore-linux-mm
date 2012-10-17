Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 33B7E6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 00:05:27 -0400 (EDT)
Date: Wed, 17 Oct 2012 00:05:15 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
Message-ID: <20121017040515.GA13505@redhat.com>
References: <20121008150949.GA15130@redhat.com>
 <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 16, 2012 at 05:31:23PM -0700, David Rientjes wrote:

 > -	pol = get_vma_policy(proc_priv->task, vma, vma->vm_start);
 > +	task_lock(task);
 > +	pol = get_vma_policy(task, vma, vma->vm_start);
 >  	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 >  	mpol_cond_put(pol);
 > +	task_unlock(task);

This seems to cause some fallout for me..

BUG: sleeping function called from invalid context at kernel/mutex.c:269
in_atomic(): 1, irqs_disabled(): 0, pid: 8558, name: trinity-child2
3 locks on stack by trinity-child2/8558:
 #0: held:     (&p->lock){+.+.+.}, instance: ffff88010c9a00b0, at: [<ffffffff8120cd1f>] seq_lseek+0x3f/0x120
 #1: held:     (&mm->mmap_sem){++++++}, instance: ffff88013956f7c8, at: [<ffffffff81254437>] m_start+0xa7/0x190
 #2: held:     (&(&p->alloc_lock)->rlock){+.+...}, instance: ffff88011fc64f30, at: [<ffffffff81254f8f>] show_numa_map+0x14f/0x610
Pid: 8558, comm: trinity-child2 Not tainted 3.7.0-rc1+ #32
Call Trace:
 [<ffffffff810ae4ec>] __might_sleep+0x14c/0x200
 [<ffffffff816bdf4e>] mutex_lock_nested+0x2e/0x50
 [<ffffffff811c43a3>] mpol_shared_policy_lookup+0x33/0x90
 [<ffffffff8118d5c3>] shmem_get_policy+0x33/0x40
 [<ffffffff811c31fa>] get_vma_policy+0x3a/0x90
 [<ffffffff81254fa3>] show_numa_map+0x163/0x610
 [<ffffffff81255b10>] ? pid_maps_open+0x20/0x20
 [<ffffffff81255980>] ? pagemap_hugetlb_range+0xf0/0xf0
 [<ffffffff81255483>] show_pid_numa_map+0x13/0x20
 [<ffffffff8120c902>] traverse+0xf2/0x230
 [<ffffffff8120cd8b>] seq_lseek+0xab/0x120
 [<ffffffff811e6c0b>] sys_lseek+0x7b/0xb0
 [<ffffffff816ca088>] tracesys+0xe1/0xe6


same problem, different syscall..


BUG: sleeping function called from invalid context at kernel/mutex.c:269
in_atomic(): 1, irqs_disabled(): 0, pid: 21996, name: trinity-child3
3 locks on stack by trinity-child3/21996:
 #0: held:     (&p->lock){+.+.+.}, instance: ffff88008d712c08, at: [<ffffffff8120ce3d>] seq_read+0x3d/0x3e0
 #1: held:     (&mm->mmap_sem){++++++}, instance: ffff88013956f7c8, at: [<ffffffff81254437>] m_start+0xa7/0x190
 #2: held:     (&(&p->alloc_lock)->rlock){+.+...}, instance: ffff88011fc64f30, at: [<ffffffff81254f8f>] show_numa_map+0x14f/0x610
Pid: 21996, comm: trinity-child3 Not tainted 3.7.0-rc1+ #32
Call Trace:
 [<ffffffff810ae4ec>] __might_sleep+0x14c/0x200
 [<ffffffff816bdf4e>] mutex_lock_nested+0x2e/0x50
 [<ffffffff811c43a3>] mpol_shared_policy_lookup+0x33/0x90
 [<ffffffff8118d5c3>] shmem_get_policy+0x33/0x40
 [<ffffffff811c31fa>] get_vma_policy+0x3a/0x90
 [<ffffffff81254fa3>] show_numa_map+0x163/0x610
 [<ffffffff81255b10>] ? pid_maps_open+0x20/0x20
 [<ffffffff81255980>] ? pagemap_hugetlb_range+0xf0/0xf0
 [<ffffffff81255483>] show_pid_numa_map+0x13/0x20
 [<ffffffff8120c902>] traverse+0xf2/0x230
 [<ffffffff8120d14b>] seq_read+0x34b/0x3e0
 [<ffffffff8120ce00>] ? seq_lseek+0x120/0x120
 [<ffffffff811e751a>] do_loop_readv_writev+0x5a/0x90
 [<ffffffff811e7851>] do_readv_writev+0x1c1/0x1e0
 [<ffffffff810b0de1>] ? get_parent_ip+0x11/0x50
 [<ffffffff811e7905>] vfs_readv+0x35/0x60
 [<ffffffff811e7b72>] sys_preadv+0xc2/0xe0
 [<ffffffff816ca088>] tracesys+0xe1/0xe6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
