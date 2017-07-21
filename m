Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1DBF6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 21:33:08 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 32so26010560qtv.5
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:33:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o2si2912059qkc.372.2017.07.20.18.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 18:33:08 -0700 (PDT)
Date: Thu, 20 Jul 2017 21:33:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170721013303.GA25991@redhat.com>
References: <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
 <20170715005554.GA12694@redhat.com>
 <cfba9bfb-5178-bcae-0fa9-ef66e2a871d5@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cfba9bfb-5178-bcae-0fa9-ef66e2a871d5@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Jul 20, 2017 at 06:00:08PM -0700, Evgeny Baskakov wrote:
> On 7/14/17 5:55 PM, Jerome Glisse wrote:
> Hi Jerome,
> 
> I think I just found a couple of new issues, now related to fork/execve.
> 
> 1) With a fork() followed by execve(), the child process makes a copy of the
> parent mm_struct object, including the "hmm" pointer. Later on, an execve()
> syscall in the child process frees the old mm_struct, and destroys the "hmm"
> object - which apparently it shouldn't do, because the "hmm" object is
> shared between the parent and child processes:
> 
> (gdb) bt
> #0  hmm_mm_destroy (mm=0xffff88080757aa40) at mm/hmm.c:134
> #1  0xffffffff81058567 in __mmdrop (mm=0xffff88080757aa40) at
> kernel/fork.c:889
> #2  0xffffffff8105904f in mmdrop (mm=<optimized out>) at
> ./include/linux/sched/mm.h:42
> #3  __mmput (mm=<optimized out>) at kernel/fork.c:916
> #4  mmput (mm=0xffff88080757aa40) at kernel/fork.c:927
> #5  0xffffffff811c5a68 in exec_mmap (mm=<optimized out>) at fs/exec.c:1057
> #6  flush_old_exec (bprm=<optimized out>) at fs/exec.c:1284
> #7  0xffffffff81214460 in load_elf_binary (bprm=0xffff8808133b1978) at
> fs/binfmt_elf.c:855
> #8  0xffffffff811c4fce in search_binary_handler (bprm=0xffff88081b40cb78) at
> fs/exec.c:1625
> #9  0xffffffff811c6bbf in exec_binprm (bprm=<optimized out>) at
> fs/exec.c:1667
> #10 do_execveat_common (fd=<optimized out>, filename=0xffff88080a101200,
> flags=0x0, argv=..., envp=...) at fs/exec.c:1789
> #11 0xffffffff811c6fda in do_execve (__envp=<optimized out>,
> __argv=<optimized out>, filename=<optimized out>) at fs/exec.c:1833
> #12 SYSC_execve (envp=<optimized out>, argv=<optimized out>,
> filename=<optimized out>) at fs/exec.c:1914
> #13 SyS_execve (filename=<optimized out>, argv=0x7f4e5c2aced0,
> envp=0x7f4e5c2aceb0) at fs/exec.c:1909
> #14 0xffffffff810018dd in do_syscall_64 (regs=0xffff88081b40cb78) at
> arch/x86/entry/common.c:284
> #15 0xffffffff819e2c06 in entry_SYSCALL_64 () at
> arch/x86/entry/entry_64.S:245
> 
> This leads to a sporadic memory corruption in the parent process:
> 
> Thread 200 received signal SIGSEGV, Segmentation fault.
> [Switching to Thread 3685]
> 0xffffffff811a3efe in __mmu_notifier_invalidate_range_start
> (mm=0xffff880807579000, start=0x7f4e5c62f000, end=0x7f4e5c66f000) at
> mm/mmu_notifier.c:199
> 199            if (mn->ops->invalidate_range_start)
> (gdb) bt
> #0  0xffffffff811a3efe in __mmu_notifier_invalidate_range_start
> (mm=0xffff880807579000, start=0x7f4e5c62f000, end=0x7f4e5c66f000) at
> mm/mmu_notifier.c:199
> #1  0xffffffff811ae471 in mmu_notifier_invalidate_range_start
> (end=<optimized out>, start=<optimized out>, mm=<optimized out>) at
> ./include/linux/mmu_notifier.h:282
> #2  migrate_vma_collect (migrate=0xffffc90003ca3940) at mm/migrate.c:2280
> #3  0xffffffff811b04a7 in migrate_vma (ops=<optimized out>,
> vma=0x7f4e5c62f000, start=0x7f4e5c62f000, end=0x7f4e5c66f000,
> src=0xffffc90003ca39d0, dst=0xffffc90003ca39d0, private=0xffffc90003ca39c0)
> at mm/migrate.c:2819
> (gdb) p mn->ops
> $2 = (const struct mmu_notifier_ops *) 0x6b6b6b6b6b6b6b6b
> 
> Please see attached a reproducer (sanity_rmem004_fork.tgz). Use "./build.sh;
> sudo ./kload.sh; ./run.sh" to recreate the issue on your end.
> 
> 
> 2) A slight modification of the affected application does not use fork().
> Instead, an execve() call from a parallel thread replaces the original
> process. This is a particularly interesting case, because at that point the
> process is busy migrating pages to/from device.
> 
> Here's what happens:
> 
> 0xffffffff811b9879 in commit_charge (page=<optimized out>,
> lrucare=<optimized out>, memcg=<optimized out>) at mm/memcontrol.c:2060
> 2060        VM_BUG_ON_PAGE(page->mem_cgroup, page);
> (gdb) bt
> #0  0xffffffff811b9879 in commit_charge (page=<optimized out>,
> lrucare=<optimized out>, memcg=<optimized out>) at mm/memcontrol.c:2060
> #1  0xffffffff811b93d6 in commit_charge (lrucare=<optimized out>,
> memcg=<optimized out>, page=<optimized out>) at
> ./include/linux/page-flags.h:149
> #2  mem_cgroup_commit_charge (page=0xffff88081b68cb70,
> memcg=0xffff88081b051548, lrucare=<optimized out>, compound=<optimized out>)
> at mm/memcontrol.c:5468
> #3  0xffffffff811b10d4 in migrate_vma_insert_page (migrate=<optimized out>,
> dst=<optimized out>, src=<optimized out>, page=<optimized out>,
> addr=<optimized out>) at mm/migrate.c:2605
> #4  migrate_vma_pages (migrate=<optimized out>) at mm/migrate.c:2647
> #5  migrate_vma (ops=<optimized out>, vma=<optimized out>, start=<optimized
> out>, end=<optimized out>, src=<optimized out>, dst=<optimized out>,
> private=0xffffc900037439c0) at mm/migrate.c:2844
> 
> 
> Please find another reproducer attached (sanity_rmem004_execve.tgz) for this
> issue.
> 

So i pushed an updated hmm-next branch it should have all fixes so far, including
something that should fix this issue. I still want to go over all emails again
to make sure i am not forgetting anything.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
