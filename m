Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id A2D426B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:37:31 -0500 (EST)
Received: by igcph11 with SMTP id ph11so80142122igc.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:37:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k2si25301509igx.42.2015.11.11.12.37.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 12:37:31 -0800 (PST)
Date: Wed, 11 Nov 2015 21:37:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
Message-ID: <20151111203728.GH4573@redhat.com>
References: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <20151111173044.GF4573@redhat.com>
 <56439EA8.80505@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56439EA8.80505@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, KVM list <kvm@vger.kernel.org>

On Wed, Nov 11, 2015 at 09:01:44PM +0100, Christian Borntraeger wrote:
> Am 11.11.2015 um 18:30 schrieb Andrea Arcangeli:
> > Hi Jason,
> > 
> > On Wed, Nov 11, 2015 at 10:35:16AM -0500, Jason J. Herne wrote:
> >> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> >> hugepage but hugepage_madvise() takes the error path when we ask to turn
> >> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> > 
> > I wonder why KVM disables transparent hugepages on s390. It sounds
> > weird to disable transparent hugepages with KVM. In fact on x86 we
> > call MADV_HUGEPAGE to be sure transparent hugepages are enabled on the
> > guest physical memory, even if the transparent_hugepage/enabled ==
> > madvise.
> > 
> >> new postcopy migration feature to fail on s390 because its first action is
> >> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> >> code so that the operation succeeds without error now.
> > 
> > The other way is to change qemu to keep track it already called
> > MADV_NOHUGEPAGE and not to call it again. I don't have a strong
> > opinion on this, I think it's ok to return 0 but it's a visible change
> > to userland, I can't imagine it to break anything though. It sounds
> > very unlikely that an app could error out if it notices the kernel
> > doesn't error out on the second call of MADV_NOHUGEPAGE.
> > 
> > Glad to hear KVM postcopy live migration is already running on s390 too.
> 
> Sometimes....we have some issues with userfaultd, which we currently address.
> One place is interesting: the kvm code might have to call fixup_user_fault
> for a guest address (to map the page writable). Right now we do not pass
> FAULT_FLAG_ALLOW_RETRY, which can trigger a warning like
> 
> [  119.414573] FAULT_FLAG_ALLOW_RETRY missing 1
> [  119.414577] CPU: 42 PID: 12853 Comm: qemu-system-s39 Not tainted 4.3.0+ #315
> [  119.414579]        000000011c4579b8 000000011c457a48 0000000000000002 0000000000000000 
>                       000000011c457ae8 000000011c457a60 000000011c457a60 0000000000113e26 
>                       00000000000002cf 00000000009feef8 0000000000a1e054 000000000000000b 
>                       000000011c457aa8 000000011c457a48 0000000000000000 0000000000000000 
>                       0000000000000000 0000000000113e26 000000011c457a48 000000011c457aa8 
> [  119.414590] Call Trace:
> [  119.414596] ([<0000000000113d16>] show_trace+0xf6/0x148)
> [  119.414598]  [<0000000000113dda>] show_stack+0x72/0xf0
> [  119.414600]  [<0000000000551b9e>] dump_stack+0x6e/0x90
> [  119.414605]  [<000000000032d168>] handle_userfault+0xe0/0x448
> [  119.414609]  [<000000000029a2d4>] handle_mm_fault+0x16e4/0x1798
> [  119.414611]  [<00000000002930be>] fixup_user_fault+0x86/0x118
> [  119.414614]  [<0000000000126bb8>] gmap_ipte_notify+0xa0/0x170
> [  119.414617]  [<000000000013ae90>] kvm_arch_vcpu_ioctl_run+0x448/0xc58
> [  119.414619]  [<000000000012e4dc>] kvm_vcpu_ioctl+0x37c/0x668
> [  119.414622]  [<00000000002eba68>] do_vfs_ioctl+0x3a8/0x508
> [  119.414624]  [<00000000002ebc6c>] SyS_ioctl+0xa4/0xb8
> [  119.414627]  [<0000000000815c56>] system_call+0xd6/0x264
> [  119.414629]  [<000003ff9628721a>] 0x3ff9628721a
> 
> I think we can rework this to use something that sets FAULT_FLAG_ALLOW_RETRY,
> but this begs the question if a futex operation on userfault backed memory 
> would also be broken. The futex code also does fixup_user_fault without 
> FAULT_FLAG_ALLOW_RETRY as far as I can tell.

That's a good point, but qemu never does futex on the guest physical
memory so can't be a problem for postcopy at least, it's also not
destabilizing in any way (and the stack dump also happens only if you
have DEBUG_VM selected).

The userfaultfd stress test actually could end up using futex on the
userfault memory, but it never triggered anything, it doesn't get to
that fixup_user_fault at runtime.

Still it should be fixed for s390 and futex.

It's probably better to add a fixup_user_fault_unlocked that will work
like get_user_pages_unlocked. I.e. leaves the details of the mmap_sem
locking internally to the function, and will handle VM_FAULT_RETRY
automatically by re-taking the mmap_sem and repeating the
fixup_user_fault after updating the FAULT_FLAG_ALLOW_RETRY to
FAULT_FLAG_TRIED.

Note that the FAULT_FLAG_TRIED logic will need an overhaul soon, as we
must be able to release the mmap_sem in handle_userfault() even if
FAULT_FLAG_TRIED is passed instead of FAULT_FLAG_ALLOW_RETRY for to
reasons:

1) the theoretical scheduler race, with the schedule() not blocking
   after setting the state to TASK_KILLABLE and then calling
   schedule() will be not an issue anymore (we'll return
   VM_FAULT_RETRY and handle_userfault() will be repeated by the
   caller immediately later and hopefully eventually schedule() will
   block...). We never experienced this race a single time and
   thousands of postcopy live migration happened so it seems mostly a
   theoretical issue. Even in the worst case it triggers it cannot
   corrupt memory but you'll get a sigbus and a stuck dump identical
   to what you already experienced above on s390 (not because of the
   theoretical scheduler race for s390 case, but the failure point
   ends the same).
   
2) we'll be able to wrprotect pagetables (only with mmap_sem for
   reading, without touching vmas) as the program runs, and while
   faults are already in progress. If the wrprotection happens after
   the kernel already returned VM_FAULT_RETRY of its own because a
   page fault was already in flight and it was processed as a
   lightweight-locking one, we may enter the write protect tracking
   handle_userfault() with FAULT_FLAG_TRIED and we must still be
   allowed to block and in turn to drop the mmap_sem and in turn to
   return VM_FAULT_RETRY or a VM_FAULT_USERFAULT or some other
   flag. In fact it's also fine if the handle_userfault() won't cause
   a transition from the caller fault_flags from
   FAULT_FLAG_ALLOW_RETRY to FAULT_FLAG_TRIED. I think a new
   VM_FAULT_? flag is the way to go and then the caller will know
   nothing has really happened and the caller must retry also if it
   was already at the FAULT_FLAG_TRIED stage when it entered
   handle_mm_fault. Or the caller will avoid the transition to
   FAULT_FLAG_TRIED if it was still at the FAULT_FLAG_ALLOW_RETRY
   stage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
