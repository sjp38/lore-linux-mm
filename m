Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9LFD3Ae225062
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:13:03 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LFD3pK2584712
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:13:03 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9LFD2Hb009877
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:13:02 +0200
Date: Tue, 21 Oct 2008 17:13:01 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: mlock: mlocked pages are unevictable
Message-ID: <20081021151301.GE4980@osiris.boeblingen.de.ibm.com>
References: <200810201659.m9KGxtFC016280@hera.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200810201659.m9KGxtFC016280@hera.kernel.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Mon, Oct 20, 2008 at 04:59:55PM +0000, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b291f000393f5a0b679012b39d79fbc85c018233
> Commit:     b291f000393f5a0b679012b39d79fbc85c018233
> Author:     Nick Piggin <npiggin@suse.de>
> AuthorDate: Sat Oct 18 20:26:44 2008 -0700
> Committer:  Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Mon Oct 20 08:52:30 2008 -0700
> 
>     mlock: mlocked pages are unevictable

[...]

I think the following part of your patch:

> diff --git a/mm/swap.c b/mm/swap.c
> index fee6b97..bc58c13 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -278,7 +278,7 @@ void lru_add_drain(void)
>  	put_cpu();
>  }
> 
> -#ifdef CONFIG_NUMA
> +#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
>  static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  {
>  	lru_add_drain();

causes this (allyesconfig on s390):

[17179587.988810] =======================================================
[17179587.988819] [ INFO: possible circular locking dependency detected ]
[17179587.988824] 2.6.27-06509-g2515ddc-dirty #190
[17179587.988827] -------------------------------------------------------
[17179587.988831] multipathd/3868 is trying to acquire lock:
[17179587.988834]  (events){--..}, at: [<0000000000157f82>] flush_work+0x42/0x124
[17179587.988850] 
[17179587.988851] but task is already holding lock:
[17179587.988854]  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
[17179587.988865] 
[17179587.988866] which lock already depends on the new lock.
[17179587.988867] 
[17179587.988871] 
[17179587.988871] the existing dependency chain (in reverse order) is:
[17179587.988875] 
[17179587.988876] -> #3 (&mm->mmap_sem){----}:
[17179587.988883]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.988891]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.988896]        [<0000000000b2a532>] down_read+0x62/0xd8
[17179587.988905]        [<0000000000b2cc40>] do_dat_exception+0x14c/0x390
[17179587.988910]        [<0000000000114d36>] sysc_return+0x0/0x8
[17179587.988917]        [<00000000006c694a>] copy_from_user_mvcos+0x12/0x84
[17179587.988926]        [<00000000007335f0>] eql_ioctl+0x3e8/0x590
[17179587.988935]        [<00000000008b6230>] dev_ifsioc+0x29c/0x2c8
[17179587.988942]        [<00000000008b6874>] dev_ioctl+0x618/0x680
[17179587.988946]        [<00000000008a1a8c>] sock_ioctl+0x2b4/0x2c8
[17179587.988953]        [<00000000001f99a8>] vfs_ioctl+0x50/0xbc
[17179587.988960]        [<00000000001f9ee2>] do_vfs_ioctl+0x4ce/0x510
[17179587.988965]        [<00000000001f9f94>] sys_ioctl+0x70/0x98
[17179587.988970]        [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.988975]        [<0000020000131286>] 0x20000131286
[17179587.988980] 
[17179587.988981] -> #2 (rtnl_mutex){--..}:
[17179587.988987]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.988993]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.988998]        [<0000000000b29ae8>] mutex_lock_nested+0x11c/0x31c
[17179587.989003]        [<00000000008bff1c>] rtnl_lock+0x30/0x40
[17179587.989009]        [<00000000008c144e>] linkwatch_event+0x26/0x6c
[17179587.989015]        [<0000000000157356>] run_workqueue+0x146/0x240
[17179587.989020]        [<000000000015756e>] worker_thread+0x11e/0x134
[17179587.989025]        [<000000000015cd8e>] kthread+0x6e/0xa4
[17179587.989030]        [<000000000010ad9a>] kernel_thread_starter+0x6/0xc
[17179587.989036]        [<000000000010ad94>] kernel_thread_starter+0x0/0xc
[17179587.989042] 
[17179587.989042] -> #1 ((linkwatch_work).work){--..}:
[17179587.989049]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.989054]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989059]        [<0000000000157350>] run_workqueue+0x140/0x240
[17179587.989064]        [<000000000015756e>] worker_thread+0x11e/0x134
[17179587.989069]        [<000000000015cd8e>] kthread+0x6e/0xa4
[17179587.989074]        [<000000000010ad9a>] kernel_thread_starter+0x6/0xc
[17179587.989079]        [<000000000010ad94>] kernel_thread_starter+0x0/0xc
[17179587.989084] 
[17179587.989085] -> #0 (events){--..}:
[17179587.989091]        [<00000000001716ca>] __lock_acquire+0x10c6/0x17c4
[17179587.989096]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989101]        [<0000000000157fb4>] flush_work+0x74/0x124
[17179587.989107]        [<0000000000158620>] schedule_on_each_cpu+0xec/0x138
[17179587.989112]        [<00000000001b0ab4>] lru_add_drain_all+0x2c/0x40
[17179587.989117]        [<00000000001c05ac>] __mlock_vma_pages_range+0xcc/0x2e8
[17179587.989123]        [<00000000001c0970>] mlock_fixup+0x1a8/0x280
[17179587.989128]        [<00000000001c0aec>] do_mlockall+0xa4/0xd4
[17179587.989133]        [<00000000001c0c36>] sys_mlockall+0xae/0xe0
[17179587.989138]        [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.989142]        [<000002000025a466>] 0x2000025a466
[17179587.989147] 
[17179587.989148] other info that might help us debug this:
[17179587.989149] 
[17179587.989154] 1 lock held by multipathd/3868:
[17179587.989156]  #0:  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
[17179587.989165] 
[17179587.989166] stack backtrace:
[17179587.989170] CPU: 0 Not tainted 2.6.27-06509-g2515ddc-dirty #190
[17179587.989174] Process multipathd (pid: 3868, task: 000000003978a298, ksp: 0000000039b23eb8)
[17179587.989178] 000000003978aa00 0000000039b238b8 0000000000000002 0000000000000000 
[17179587.989184]        0000000039b23958 0000000039b238d0 0000000039b238d0 00000000001060ee 
[17179587.989192]        0000000000000003 0000000000000000 0000000000000000 000000000000000b 
[17179587.989199]        0000000000000060 0000000000000008 0000000039b238b8 0000000039b23928 
[17179587.989207]        0000000000b30b50 00000000001060ee 0000000039b238b8 0000000039b23910 
[17179587.989216] Call Trace:
[17179587.989219] ([<0000000000106036>] show_trace+0xb2/0xd0)
[17179587.989225]  [<000000000010610c>] show_stack+0xb8/0xc8
[17179587.989230]  [<0000000000b27a96>] dump_stack+0xae/0xbc
[17179587.989234]  [<000000000017019e>] print_circular_bug_tail+0xee/0x100
[17179587.989240]  [<00000000001716ca>] __lock_acquire+0x10c6/0x17c4
[17179587.989245]  [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989250]  [<0000000000157fb4>] flush_work+0x74/0x124
[17179587.989256]  [<0000000000158620>] schedule_on_each_cpu+0xec/0x138
[17179587.989261]  [<00000000001b0ab4>] lru_add_drain_all+0x2c/0x40
[17179587.989266]  [<00000000001c05ac>] __mlock_vma_pages_range+0xcc/0x2e8
[17179587.989271]  [<00000000001c0970>] mlock_fixup+0x1a8/0x280
[17179587.989276]  [<00000000001c0aec>] do_mlockall+0xa4/0xd4
[17179587.989281]  [<00000000001c0c36>] sys_mlockall+0xae/0xe0
[17179587.989286]  [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.989290]  [<000002000025a466>] 0x2000025a466
[17179587.989294] INFO: lockdep is turned off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
