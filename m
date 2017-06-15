Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0C26B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:52:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t10so21920993qte.14
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:52:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p65si493710qkc.231.2017.06.15.15.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:52:34 -0700 (PDT)
Date: Fri, 16 Jun 2017 00:52:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: shmem: handle coredumping in
 handle_userfault()
Message-ID: <20170615225231.GB11676@redhat.com>
References: <20170615214838.27429-1-aarcange@redhat.com>
 <20170615145428.55264cd6c7e058b6e7a58f58@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145428.55264cd6c7e058b6e7a58f58@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Thu, Jun 15, 2017 at 02:54:28PM -0700, Andrew Morton wrote:
> So what are the user-visible effects of the bug?  Incomplete core files,
> I assume?

The side effect is a BUG_ON with no lock held triggered by the
coredumping process which exits. This is why I converted it to
WARN_ON_ONCE for good.

------------[ cut here ]------------
kernel BUG at fs/userfaultfd.c:343!
invalid opcode: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 5 PID: 2054 Comm: userfaultfd-seg Tainted: G        W       4.11.0+ #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
task: ffff88006b991900 task.stack: ffff880067f38000
RIP: 0010:handle_userfault+0xaf8/0x1930
RSP: 0000:ffff880067f3ee98 EFLAGS: 00010246
RAX: ffff880065a7dec0 RBX: 1ffff1000cfe7de0 RCX: 1ffff1000cb4fbee
RDX: 0000000000000000 RSI: 0000000000000200 RDI: ffff8800684a6028
RBP: ffff880067f3f088 R08: ffff880065a7df70 R09: 0000000000000003
R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800684a5fe8
R13: ffff880067f3f380 R14: ffff880067f3f060 R15: ffff880067f3f2c0
FS:  00007f05d58d8700(0000) GS:ffff88006cf40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000000696c2000 CR4: 00000000000406e0
Call Trace:
 ? ext4_reserve_inode_write+0x200/0x200
 ? userfaultfd_ioctl+0x2d80/0x2d80
 ? find_get_entry+0x231/0x4b0
 ? lock_downgrade+0x820/0x820
 ? radix_tree_lookup_slot+0x58/0x90
 ? __radix_tree_lookup+0x330/0x330
 ? find_get_entry+0x250/0x4b0
 ? find_lock_entry+0x2d/0x330
 shmem_getpage_gfp+0x1381/0x1c20
 ? generic_file_readonly_mmap+0x1a0/0x1b0
 ? shmem_should_replace_page.isra.3+0x40/0x40
 ? lock_downgrade+0x820/0x820
 shmem_fault+0x1de/0x750
 ? shmem_getpage_gfp+0x1c20/0x1c20
 ? ext4_file_write_iter+0x477/0xf20
 ? read_cache_page_gfp+0xa0/0xa0
 ? ext4_file_open+0x890/0x890
 ? follow_page_pte+0x80b/0xa97
 __do_fault+0x80/0x340
 __handle_mm_fault+0x1b28/0x3d50
 ? vm_insert_page+0x6b0/0x6b0
 handle_mm_fault+0x1ae/0x440
 __get_user_pages+0x286/0x1020
 ? generic_file_llseek_size+0x20e/0x2c0
 ? follow_page_mask+0x11b0/0x11b0
 ? __kernel_write+0x268/0x350
 ? ext4_find_unwritten_pgoff.isra.1+0x790/0x790
 get_dump_page+0xc2/0x120
 ? __mm_populate+0x320/0x320
 ? cn_esc_printf+0x5d0/0x5d0
 ? __might_sleep+0x9a/0x190
 ? dump_skip+0xd5/0x190
 elf_core_dump+0x335f/0x40a0
 ? writenote+0x240/0x240
 ? rcu_sync_lockdep_assert+0x75/0xb0
 ? __sb_start_write+0xfc/0x270
 do_coredump+0x154f/0x2a10
 ? __dequeue_signal+0x3c2/0x580
 ? __dequeue_signal+0x527/0x580
 ? dump_align+0x70/0x70
 ? lock_downgrade+0x820/0x820
 ? try_to_wake_up+0x91/0x1250
 ? debug_check_no_locks_freed+0x3c0/0x3c0
 ? __sigqueue_free.part.3+0x51/0x60
 ? get_signal+0x568/0x12a0
 ? _raw_spin_unlock_irq+0x2c/0x80
 ? trace_hardirqs_on_caller+0x48a/0x5a0
 get_signal+0x5b6/0x12a0
 do_signal+0x92/0x1840
 ? force_sig_info_fault+0x199/0x290
 ? pgtable_bad+0x110/0x110
 ? setup_sigcontext+0x7d0/0x7d0
 ? printk+0x94/0xb0
 ? load_image_and_restore+0xd1/0xd1
 ? up_read+0x35/0x40
 ? printk+0x94/0xb0
 ? bad_area+0x69/0x80
 ? exit_to_usermode_loop+0x46/0x1a0
 exit_to_usermode_loop+0x132/0x1a0
 prepare_exit_to_usermode+0xf4/0x120
 retint_user+0x8/0x20
RIP: 0033:0x401c9d
RSP: 002b:00007f05d58d7ee0 EFLAGS: 00010206
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007f05e447b3f4
RDX: 00007f05ddcdb000 RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00007f05d58d7f20 R08: 00007f05d58d8700 R09: 00007f05d58d8700
R10: 00007f05d58d89d0 R11: 0000000000000202 R12: 0000000000000000
R13: 00007ffd232d7eef R14: 0000000000000008 R15: 00007f05d58d8700
Code: de 49 89 46 c0 e8 a9 78 2c 01 8b 95 50 fe ff ff 4c 89 e7 89 95 50 fe ff ff e8 15 a5 ff ff 8b 95 50 fe ff ff e9 16 f7 ff ff 0f 0b <0f> 0b 0f 0b 0f 0b a8 08 0f 85 59 04 00 00 48 c7 c7 60 88 cf 82
RIP: handle_userfault+0xaf8/0x1930 RSP: ffff880067f3ee98
---[ end trace b85d6355d483e79f ]---

This doesn't affect the rest of the system at all and it's definitely
not exploitable, but there's a nuisance of a process left in D state.

> Can we please get that description into the changelog so that others
> can decide which kernel(s) need the fix?

Only 4.11 is affected, pre-4.11 anon memory holes are skipped in
__get_user_pages by checking FOLL_DUMP explicitly against empty
pagetables (mm/gup.c:no_page_table()).

Should I re-submit with this detail?

I checked ages ago that if get_dump_page() would ever later reach
handle_userfault somehow, VM_FAULT_RETRY couldn't get set. In turn
handle_userfault() would immediately return a SIGBUS without blocking
(so then the coredump would correctly skip the missing page).

What I missed is that the caller of get_dump_page doesn't hold the
mmap_sem and it ends up invoking handle_mm_fault without bothering to
take any mmap_sem because it assumes it's single threaded (same
assumption as in exit_mmap.. with the slight difference exit_mmap
would never dream to invoke handle_mm_fault without mmap_sem and it's
only a teardown op, not a bring-up pagein-and-fill-page-tables op).

To verify my earlier evaluation was correct (modulo the mmap_sem
part..) I added "if (!down_write_trylock(&current->mm->mmap_sem))
WARN_ON_ONCE()" around get_dump_page, and then it works as I
originally expected (handle_userfault complains because VM_FAULT_RETRY
is missing but it doesn't block and the coredump completes fine for
shmem).

We surely want local fix to handle_userfault() anyway so whatever else
happens in the coredump logic later (mmap_sem or not) cannot affect
handle_userfault() anymore.

I did such down_write_trylock test around get_dump_page also to verify
it was all working fine at the coredump level with the mmap_sem.

Adding a selftest is possible too, but it'll leave garbage in the abrt
spoool or on the local dir, depending on the system
config. Potentially leaving garbage in /var is not the norm for
selftests as far as I can tell, advice is welcome about that.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
