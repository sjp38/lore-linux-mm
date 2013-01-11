Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 0AA5C6B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 12:00:41 -0500 (EST)
Date: Fri, 11 Jan 2013 18:00:38 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 2/2] mm: mmap: annotate vm_lock_anon_vma locking properly
 for lockdep
Message-ID: <20130111170038.GC21882@liondog.tnic>
References: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
 <alpine.LNX.2.00.1301050134420.2946@pobox.suse.cz>
 <alpine.LNX.2.00.1301050135050.2946@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301050135050.2946@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ok, I see this still on -rc3, also with kvm.

Will run your patches and verify them.

Thanks.

On Sat, Jan 05, 2013 at 01:35:45AM +0100, Jiri Kosina wrote:
> Commit 5a505085f04 ("mm/rmap: Convert the struct anon_vma::mutex to an 
> rwsem") turned anon_vma mutex to rwsem.
> 
> However, the properly annotated nested locking in mm_take_all_locks() has 
> been converted from
> 
> 	mutex_lock_nest_lock(&anon_vma->root->mutex, &mm->mmap_sem);
> 
> to
> 
> 	down_write(&anon_vma->root->rwsem);
> 
> which is incomplete, and causes the false positive report from lockdep below.
> 
> Annotate the fact that mmap_sem is used as an outter lock to serialize taking
> of all the anon_vma rwsems at once no matter the order, using the
> down_write_nest_lock() primitive.
> 
> This patch fixes this lockdep report:
> 
>  =============================================
>  [ INFO: possible recursive locking detected ]
>  3.8.0-rc2-00036-g5f73896 #171 Not tainted
>  ---------------------------------------------
>  qemu-kvm/2315 is trying to acquire lock:
>   (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
> 
>  but task is already holding lock:
>   (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
> 
>  other info that might help us debug this:
>   Possible unsafe locking scenario:
> 
>         CPU0
>         ----
>    lock(&anon_vma->rwsem);
>    lock(&anon_vma->rwsem);
> 
>   *** DEADLOCK ***
> 
>   May be due to missing lock nesting notation
> 
>  4 locks held by qemu-kvm/2315:
>   #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81177f1c>] do_mmu_notifier_register+0xfc/0x170
>   #1:  (mm_all_locks_mutex){+.+...}, at: [<ffffffff8115d436>] mm_take_all_locks+0x36/0x1b0
>   #2:  (&mapping->i_mmap_mutex){+.+...}, at: [<ffffffff8115d4c9>] mm_take_all_locks+0xc9/0x1b0
>   #3:  (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
> 
>  stack backtrace:
>  Pid: 2315, comm: qemu-kvm Not tainted 3.8.0-rc2-00036-g5f73896 #171
>  Call Trace:
>   [<ffffffff810afea2>] print_deadlock_bug+0xf2/0x100
>   [<ffffffff810b1a76>] validate_chain+0x4f6/0x720
>   [<ffffffff810b1ff9>] __lock_acquire+0x359/0x580
>   [<ffffffff810b0e7d>] ? trace_hardirqs_on_caller+0x12d/0x1b0
>   [<ffffffff810b2341>] lock_acquire+0x121/0x190
>   [<ffffffff8115d549>] ? mm_take_all_locks+0x149/0x1b0
>   [<ffffffff815a12bf>] down_write+0x3f/0x70
>   [<ffffffff8115d549>] ? mm_take_all_locks+0x149/0x1b0
>   [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
>   [<ffffffff81177e88>] do_mmu_notifier_register+0x68/0x170
>   [<ffffffff81177fae>] mmu_notifier_register+0xe/0x10
>   [<ffffffffa04bd6ab>] kvm_create_vm+0x22b/0x330 [kvm]
>   [<ffffffffa04bd8a8>] kvm_dev_ioctl+0xf8/0x1a0 [kvm]
>   [<ffffffff811a45bd>] do_vfs_ioctl+0x9d/0x350
>   [<ffffffff815ad215>] ? sysret_check+0x22/0x5d
>   [<ffffffff811a4901>] sys_ioctl+0x91/0xb0
>   [<ffffffff815ad1e9>] system_call_fastpath+0x16/0x1b
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  mm/mmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f54b235..35730ee 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2886,7 +2886,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
>  		 * The LSB of head.next can't change from under us
>  		 * because we hold the mm_all_locks_mutex.
>  		 */
> -		down_write(&anon_vma->root->rwsem);
> +		down_write_nest_lock(&anon_vma->root->rwsem, &mm->mmap_sem);
>  		/*
>  		 * We can safely modify head.next after taking the
>  		 * anon_vma->root->rwsem. If some other vma in this mm shares
> -- 
> Jiri Kosina
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
