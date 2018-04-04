Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8386B0026
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 17:53:55 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o33-v6so13888611plb.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 14:53:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x16sor1752222pfe.2.2018.04.04.14.53.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 14:53:53 -0700 (PDT)
Date: Wed, 4 Apr 2018 14:53:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
In-Reply-To: <147e8be3-2c33-2111-aacc-dc2bb932fa8c@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804041451220.152749@chino.kir.corp.google.com>
References: <20180317075119.u6yuem2bhxvggbz3@inn> <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com> <alpine.DEB.2.20.1803251510040.80485@chino.kir.corp.google.com> <aa6f2ff1-ff67-106a-e0e4-522ac82a7bf0@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804031748120.27686@chino.kir.corp.google.com> <147e8be3-2c33-2111-aacc-dc2bb932fa8c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: kernel test robot <fengguang.wu@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org

On Wed, 4 Apr 2018, Laurent Dufour wrote:

> > I also think the following is needed:
> > 
> > diff --git a/fs/exec.c b/fs/exec.c
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -312,6 +312,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
> >  	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
> >  	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
> >  	INIT_LIST_HEAD(&vma->anon_vma_chain);
> > +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> > +	seqcount_init(&vma->vm_sequence);
> > +	atomic_set(&vma->vm_ref_count, 0);
> > +#endif
> > 
> >  	err = insert_vm_struct(mm, vma);
> >  	if (err)
> 
> No, this not needed because the vma is allocated with kmem_cache_zalloc() so
> vm_ref_count is 0, and insert_vm_struc() will later call
> __vma_link_rb() which will call seqcount_init().
> 
> Furhtermore, in case of error, the vma structure is freed without calling
> get_vma() so there is risk of lockdep warning.
> 

Perhaps you're working from a different tree than I am, or you fixed the 
lockdep warning differently when adding to dup_mmap() and mmap_region().

I got the following two lockdep errors.

I fixed it locally by doing the seqcount_init() and atomic_set() 
everywhere a vma could be initialized.

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 12 PID: 1 Comm: init Not tainted
Call Trace:
 [<ffffffff8b12026f>] dump_stack+0x67/0x98
 [<ffffffff8a92b616>] register_lock_class+0x1e6/0x4e0
 [<ffffffff8a92cfe9>] __lock_acquire+0xb9/0x1710
 [<ffffffff8a92ef3a>] lock_acquire+0xba/0x200
 [<ffffffff8aa827df>] mprotect_fixup+0x10f/0x310
 [<ffffffff8aade3fd>] setup_arg_pages+0x12d/0x230
 [<ffffffff8ab4564a>] load_elf_binary+0x44a/0x1740
 [<ffffffff8aadde9b>] search_binary_handler+0x9b/0x1e0
 [<ffffffff8ab44e96>] load_script+0x206/0x270
 [<ffffffff8aadde9b>] search_binary_handler+0x9b/0x1e0
 [<ffffffff8aae0355>] do_execveat_common.isra.32+0x6b5/0x9d0
 [<ffffffff8aae069c>] do_execve+0x2c/0x30
 [<ffffffff8a80047b>] run_init_process+0x2b/0x30
 [<ffffffff8b1358d4>] kernel_init+0x54/0x110
 [<ffffffff8b2001ca>] ret_from_fork+0x3a/0x50

and

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 21 PID: 1926 Comm: mkdir Not tainted
Call Trace:
 [<ffffffff985202af>] dump_stack+0x67/0x98
 [<ffffffff97d2b616>] register_lock_class+0x1e6/0x4e0
 [<ffffffff97d2cfe9>] __lock_acquire+0xb9/0x1710
 [<ffffffff97d2ef3a>] lock_acquire+0xba/0x200
 [<ffffffff97e73c09>] unmap_page_range+0x89/0xaa0
 [<ffffffff97e746af>] unmap_single_vma+0x8f/0x100
 [<ffffffff97e74a1b>] unmap_vmas+0x4b/0x90
 [<ffffffff97e7f833>] exit_mmap+0xa3/0x1c0
 [<ffffffff97cc1b23>] mmput+0x73/0x120
 [<ffffffff97ccbacd>] do_exit+0x2bd/0xd60
 [<ffffffff97ccc5b7>] SyS_exit+0x17/0x20
 [<ffffffff97c01f1d>] do_syscall_64+0x6d/0x1a0
 [<ffffffff9860005a>] entry_SYSCALL_64_after_hwframe+0x26/0x9b

I think it would just be better to generalize vma allocation to initialize 
certain fields and init both spf fields properly for 
CONFIG_SPECULATIVE_PAGE_FAULT.  It's obviously too delicate as is.
