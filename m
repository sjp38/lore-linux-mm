Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 080EE6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 20:12:26 -0400 (EDT)
Received: by iofz202 with SMTP id z202so170270359iof.2
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 17:12:25 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id n3si10296526iga.30.2015.10.25.17.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 17:12:25 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so169485088pad.1
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 17:12:24 -0700 (PDT)
Date: Sun, 25 Oct 2015 17:12:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/6] ksm: fix rmap_item->anon_vma memory corruption and
 vma user after free
In-Reply-To: <1444925065-4841-2-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251642050.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> The ksm_test_exit() run after down_read(&mm->mmap_sem) assumed it
> could serialize against ksm_exit() and prevent exit_mmap() to run
> until the up_read(&mm->mmap_sem). That is true when the rmap_item->mm
> is the one associated with the ksm_scan.mm_slot, as ksm_exit() would
> take the !easy_to_free_path.
> 
> The problem is that when merging the current rmap_item (the one whose
> ->mm pointer is always associated ksm_scan.mm_slot) with a
> tree_rmap_item in the unstable tree, the unstable tree
> tree_rmap_item->mm can be any random mm. The locking technique
> described above is a noop if the rmap_item->mm is not the one
> associated with the ksm_scan.mm_slot.

I was convinced for an hour, though puzzled how this had survived
six years without being noticed: I'd certainly found the need for
the special ksm_exit()/ksm_test_exit() stuff when testing originally,
that wasn't hard, and why would this race be so very much harder?

Now, after looking again at ksm_exit(), I just don't see the point
you're making.  As I read it (and I certainly accept that I may be
wrong on all this), it will do the down_write,up_write on any mm
that is registered with it, and that has a chain of rmap_items -
the easy_to_free route is only for those that have no rmap_items
(and are not being worked on at present); and those that have no
rmap_items, have no rmap_items in the unstable or the stable tree.

Please explain what I'm missing before I look again harder.  One
nit below.  It looked very reasonable and nicely implemented to me,
but I didn't complete checking it before I lost sight of what it's
fixing.  (And incrementing mm_users always makes me worry a bit
about what happens under OOM, so I prefer not to do it.)

I've seen no problems at all in running rc5-mm1 and rc6-mm1
(with "allksm" of course) on this series.

Hugh

> In turn the tree_rmap_item when
> converted to a stable tree rmap_item and added to the
> stable_node->hlist, can have a &rmap_item->anon_vma that points to
> already freed memory. The find_vma and other vma operations to reach
> the anon_vma also run on potentially already freed memory. The
> get_anon_vma atomic_inc itself could corrupt memory randomly in
> already re-used memory.
> 
> The result are oopses like below:
> 
> general protection fault: 0000 [#1] SMP
> last sysfs file: /sys/kernel/mm/ksm/sleep_millisecs
> CPU 14
> Modules linked in: netconsole nfs nfs_acl auth_rpcgss fscache lockd sunrpc msr binfmt_misc sr_mod
> 
> Pid: 904, comm: ksmd Not tainted 2.6.32 #21 Supermicro X8DTN/X8DTN

Time for an update, maybe :-?  Though, in seriousness, I don't
think we have fixed anything of this nature in KSM since then.
Have probably fixed some anon_vma lifetime issues, though.

> RIP: 0010:[<ffffffff81138300>]  [<ffffffff81138300>] drop_anon_vma+0x0/0xe0
> RSP: 0000:ffff88023b94bd28  EFLAGS: 00010206
> RAX: 0000000000000000 RBX: ffff880231e64d50 RCX: 0000000000000017
> RDX: ffff88023b94bfd8 RSI: 0000000000000216 RDI: 80000002192c6067
> RBP: ffff88023b94bd40 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000001 R11: 0000000000000001 R12: ffff880217fa4198
> R13: ffff880217fa4198 R14: 000000000021916f R15: ffff880217fa419b
> FS:  0000000000000000(0000) GS:ffff880030600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 0000000000d116a0 CR3: 000000023aa35000 CR4: 00000000000007e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process ksmd (pid: 904, threadinfo ffff88023b948000, task ffff88023b946500)
> Stack:
>  ffffffff8114d049 ffffea000757d048 ffffea0000000000 ffff88023b94bda0
> <d> ffffffff8114d153 ffff88023b946500 ffff88023afaab40 ffffffff8114e85d
> <d> 0100000000000038 ffff88023b94bdb0 ffff880231d33560 ffff880217fa4198
> Call Trace:
>  [<ffffffff8114d049>] ? remove_node_from_stable_tree+0x29/0x80
>  [<ffffffff8114d153>] get_ksm_page+0xb3/0x1e0
>  [<ffffffff8114e85d>] ? ksm_scan_thread+0x60d/0x1130
>  [<ffffffff8114d499>] remove_rmap_item_from_tree+0x99/0x130
>  [<ffffffff8114ed19>] ksm_scan_thread+0xac9/0x1130
>  [<ffffffff81095ce0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff8114e250>] ? ksm_scan_thread+0x0/0x1130
>  [<ffffffff8109508b>] kthread+0x8b/0xb0
>  [<ffffffff8100c0ea>] child_rip+0xa/0x20
>  [<ffffffff8100b910>] ? restore_args+0x0/0x30
>  [<ffffffff81095000>] ? kthread+0x0/0xb0
>  [<ffffffff8100c0e0>] ? child_rip+0x0/0x20
> Code: 01 75 10 e8 d3 f7 ff ff 5d c3 90 0f 0b eb fe 0f 1f 40 00 e8 73 f6 ff ff 5d c3 e8 4c 77 01 00 5d c3 66 2e 0f 1f 84 00 00 00 00 00 <8b> 47 48 85 c0 0f 8e c5 00 00 00 55 48 89 e5 41 56 41 55 41 54
> RIP  [<ffffffff81138300>] drop_anon_vma+0x0/0xe0
>  RSP <ffff88023b94bd28>
> ---[ end trace b1f69fd4c12ce1ce ]---
> 
> rmap_item->anon_vma was set to the RDI value 0x80000002192c6067.
> 
>    0xffffffff81138300 <+0>:     mov    0x48(%rdi),%eax
>    0xffffffff81138303 <+3>:     test   %eax,%eax
>    0xffffffff81138305 <+5>:     jle    0xffffffff811383d0       <drop_anon_vma+208>
>    0xffffffff8113830b <+11>:    push   %rbp
> 
> Other oopses are more random and harder to debug side effects of
> memory corruption. In this case the anon_vma was a dangling pointer
> because when try_to_merge_with_ksm_page did rmap_item->anon_vma =
> vma->anon_vma, the vma already was already freed and reused memory. At
> other times the oopses materialize with an vma->anon_vma pointer that
> looks legit but it points to an already freed and reused anon_vma.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/ksm.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 51 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 7ee101e..8fc6793 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -350,6 +350,24 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
>  }
>  
>  /*
> + * If the mm isn't the one associated with the current
> + * ksm_scan.mm_slot ksm_exit() will not down_write();up_write() and in
> + * turn the ksm_test_exit() check run inside a mm->mmap_sem critical
> + * section, will not prevent exit_mmap() to run from under us. In
> + * turn, in those cases where we could work with an "mm" that isn't
> + * guaranteed to be associated with the current ksm_scan.mm_slot,
> + * ksm_get_mm() is needed instead of the ksm_test_exit() run inside
> + * the mmap_sem. Return true if the mm_users was incremented or false
> + * if it we failed at taking the mm because it was freed from under
> + * us. If it returns 1, the caller must take care of calling mmput()
> + * after it finishes using the mm.
> + */
> +static __always_inline bool ksm_get_mm(struct mm_struct *mm)

The nit was to ask, what's behind that __always_inline?
If the compiler chooses oddly not to inline it, that's okay, isn't it?

> +{
> +	return likely(atomic_inc_not_zero(&mm->mm_users));
> +}
> +
> +/*
>   * We use break_ksm to break COW on a ksm page: it's a stripped down
>   *
>   *	if (get_user_pages(current, mm, addr, 1, 1, 1, &page, NULL) == 1)
> @@ -412,8 +430,6 @@ static struct vm_area_struct *find_mergeable_vma(struct mm_struct *mm,
>  		unsigned long addr)
>  {
>  	struct vm_area_struct *vma;
> -	if (ksm_test_exit(mm))
> -		return NULL;
>  	vma = find_vma(mm, addr);
>  	if (!vma || vma->vm_start > addr)
>  		return NULL;
> @@ -434,11 +450,21 @@ static void break_cow(struct rmap_item *rmap_item)
>  	 */
>  	put_anon_vma(rmap_item->anon_vma);
>  
> +	/*
> +	 * The "mm" of the unstable tree rmap_item isn't necessairly
> +	 * associated with the current ksm_scan.mm_slot, it could be
> +	 * any random mm. So we need ksm_get_mm here to prevent the
> +	 * exit_mmap to run from under us in mmput().
> +	 */
> +	if (!ksm_get_mm(mm))
> +		return;
> +
>  	down_read(&mm->mmap_sem);
>  	vma = find_mergeable_vma(mm, addr);
>  	if (vma)
>  		break_ksm(vma, addr);
>  	up_read(&mm->mmap_sem);
> +	mmput(mm);
>  }
>  
>  static struct page *page_trans_compound_anon(struct page *page)
> @@ -462,6 +488,15 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>  	struct vm_area_struct *vma;
>  	struct page *page;
>  
> +	/*
> +	 * The "mm" of the unstable tree rmap_item isn't necessairly
> +	 * associated with the current ksm_scan.mm_slot, it could be
> +	 * any random mm. So we need ksm_get_mm here to prevent the
> +	 * exit_mmap to run from under us in mmput().
> +	 */
> +	if (!ksm_get_mm(mm))
> +		return NULL;
> +
>  	down_read(&mm->mmap_sem);
>  	vma = find_mergeable_vma(mm, addr);
>  	if (!vma)
> @@ -478,6 +513,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>  out:		page = NULL;
>  	}
>  	up_read(&mm->mmap_sem);
> +	mmput(mm);
>  	return page;
>  }
>  
> @@ -1086,9 +1122,19 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  	struct vm_area_struct *vma;
>  	int err = -EFAULT;
>  
> +	/*
> +	 * The "mm" of the unstable tree rmap_item isn't necessairly
> +	 * associated with the current ksm_scan.mm_slot, it could be
> +	 * any random mm. So we need ksm_get_mm() here to prevent the
> +	 * exit_mmap to run from under us in mmput(). Otherwise
> +	 * rmap_item->anon_vma could point to an anon_vma that has
> +	 * already been freed (i.e. get_anon_vma() below would run too
> +	 * late).
> +	 */
> +	if (!ksm_get_mm(mm))
> +		return err;
> +
>  	down_read(&mm->mmap_sem);
> -	if (ksm_test_exit(mm))
> -		goto out;
>  	vma = find_vma(mm, rmap_item->address);
>  	if (!vma || vma->vm_start > rmap_item->address)
>  		goto out;
> @@ -1105,6 +1151,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  	get_anon_vma(vma->anon_vma);
>  out:
>  	up_read(&mm->mmap_sem);
> +	mmput(mm);
>  	return err;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
