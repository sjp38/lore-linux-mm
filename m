Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5D26B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 19:17:20 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so41795055pab.5
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 16:17:20 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fu9si2834040pac.13.2015.01.19.16.17.18
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 16:17:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150119174317.GK20386@saruman>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
Subject: Re: [next-20150119]regression (mm)?
Content-Transfer-Encoding: 7bit
Message-Id: <20150120001643.7D15AA8@black.fi.intel.com>
Date: Tue, 20 Jan 2015 02:16:43 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felipe Balbi <balbi@ti.com>
Cc: Nishanth Menon <nm@ti.com>, linux-omap <linux-omap@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

Felipe Balbi wrote:
> Hi,
> 
> On Mon, Jan 19, 2015 at 10:42:04AM -0600, Nishanth Menon wrote:
> > Most platforms seem broken intoday's next tag.
> > 
> > https://github.com/nmenon/kernel-test-logs/tree/next-20150119
> > (defconfig: omap2plus_defconfig)
> > 
> > > [    7.166600] ------------[ cut here ]------------
> > > [    7.171676] WARNING: CPU: 0 PID: 54 at mm/mmap.c:2859 exit_mmap+0x1a8/0x21c()
> > > [    7.179194] Modules linked in:
> > > [    7.182479] CPU: 0 PID: 54 Comm: init Not tainted 3.19.0-rc5-next-20150119-00002-gfdefcded1272 #1
> > > [    7.191863] Hardware name: Generic AM33XX (Flattened Device Tree)
> > > [    7.198318] [<c00153f0>] (unwind_backtrace) from [<c0011a74>] (show_stack+0x10/0x14)
> > > [    7.206528] [<c0011a74>] (show_stack) from [<c0580150>] (dump_stack+0x78/0x94)
> > > [    7.214191] [<c0580150>] (dump_stack) from [<c003d4d0>] (warn_slowpath_common+0x7c/0xb4)
> > > [    7.222751] [<c003d4d0>] (warn_slowpath_common) from [<c003d524>] (warn_slowpath_null+0x1c/0x24)
> > > [    7.232038] [<c003d524>] (warn_slowpath_null) from [<c012de64>] (exit_mmap+0x1a8/0x21c)
> > > [    7.240536] [<c012de64>] (exit_mmap) from [<c003abb8>] (mmput+0x44/0xec)
> > > [    7.247612] [<c003abb8>] (mmput) from [<c0151368>] (flush_old_exec+0x300/0x5a4)
> > > [    7.255357] [<c0151368>] (flush_old_exec) from [<c0195c10>] (load_elf_binary+0x2ec/0x1144)
> > > [    7.264111] [<c0195c10>] (load_elf_binary) from [<c0150ea0>] (search_binary_handler+0x88/0x1ac)
> > > [    7.273311] [<c0150ea0>] (search_binary_handler) from [<c019554c>] (load_script+0x260/0x280)
> > > [    7.282232] [<c019554c>] (load_script) from [<c0150ea0>] (search_binary_handler+0x88/0x1ac)
> > > [    7.291066] [<c0150ea0>] (search_binary_handler) from [<c0151f0c>] (do_execveat_common+0x538/0x6c4)
> > > [    7.300628] [<c0151f0c>] (do_execveat_common) from [<c01520c4>] (do_execve+0x2c/0x34)
> > > [    7.308881] [<c01520c4>] (do_execve) from [<c000e5e0>] (ret_fast_syscall+0x0/0x4c)
> > > [    7.316881] ---[ end trace 3b8a46b1b280f423 ]---
> 
> seems like it's caused by:
> 
> b316feb3c37ff19cddcaf1f6b5056c633193257d is the first bad commit
> 
> Adding Kiryl to the loop.
> 
> git bisect start
> # good: [ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc] Linux 3.19-rc5
> git bisect good ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc
> # bad: [a0d4287f787889e59db0fd295853a0f1f55d0699] Add linux-next specific files for 20150119
> git bisect bad a0d4287f787889e59db0fd295853a0f1f55d0699
> # good: [1c2f70b77b8ca77f10c59d479d009e07359d00d2] Merge remote-tracking branch 'drm/drm-next'
> git bisect good 1c2f70b77b8ca77f10c59d479d009e07359d00d2
> # good: [73c1390843223d8bfc85795c560c36b3d0ffee40] Merge remote-tracking branch 'leds/for-next'
> git bisect good 73c1390843223d8bfc85795c560c36b3d0ffee40
> # good: [7bc6bef35d48e91ad796b6eead7304998842c782] Merge remote-tracking branch 'pinctrl/for-next'
> git bisect good 7bc6bef35d48e91ad796b6eead7304998842c782
> # bad: [45e1eaa38732ffa3de0d18fe95d2d2b960a7c777] lib: bitmap: change bitmap_shift_right to take unsigned parameters
> git bisect bad 45e1eaa38732ffa3de0d18fe95d2d2b960a7c777
> # good: [c82a73a0369a7dd6dcfaf9e6bd572a4e5deda223] mm, page_alloc: reduce number of alloc_pages* functions' parameters
> git bisect good c82a73a0369a7dd6dcfaf9e6bd572a4e5deda223
> # bad: [0b1c810fbc4bbff7e314dd6ff91c2b4af499199d] mm: don't split THP page when syscall is called
> git bisect bad 0b1c810fbc4bbff7e314dd6ff91c2b4af499199d
> # good: [54faa439355a9ae476a446429967e9e38f04363e] oom, PM: make OOM detection in the freezer path raceless
> git bisect good 54faa439355a9ae476a446429967e9e38f04363e
> # bad: [b6c9f11c6b6993303067f7c04a73258226a6e77e] mm/compaction: add tracepoint to observe behaviour of compaction defer
> git bisect bad b6c9f11c6b6993303067f7c04a73258226a6e77e
> # good: [9ce5d3fb13a80f28db450de4ecf2727893e99c93] mm: pagemap_read: limit scan to virtual region being asked
> git bisect good 9ce5d3fb13a80f28db450de4ecf2727893e99c93
> # bad: [1a7a376546ca56e7750987c15d0c7541c17a512c] mm/compaction: change tracepoint format from decimal to hexadecimal
> git bisect bad 1a7a376546ca56e7750987c15d0c7541c17a512c
> # bad: [4081187ff19cf2186010c003939c17d70d0bbb27] page_writeback: put account_page_redirty() after set_page_dirty()
> git bisect bad 4081187ff19cf2186010c003939c17d70d0bbb27
> # bad: [b316feb3c37ff19cddcaf1f6b5056c633193257d] mm: account pmd page tables to the process
> git bisect bad b316feb3c37ff19cddcaf1f6b5056c633193257d
> # first bad commit: [b316feb3c37ff19cddcaf1f6b5056c633193257d] mm: account pmd page tables to the process
> 
> I've added a dump_mm() call when the bug happens followed by a
> while (true) loop (to avoid constant reprinting of the same thing),
> here's what I get:
> 
> [    7.235903] ------------[ cut here ]------------
> [    7.240881] WARNING: CPU: 0 PID: 58 at mm/mmap.c:2859 exit_mmap+0x1b4/0x218()
> [    7.248369] Modules linked in: ipv6 autofs4
> [    7.252792] CPU: 0 PID: 58 Comm: systemd Not tainted 3.19.0-rc5-next-20150119-dirty #888
> [    7.261274] Hardware name: Generic AM43 (Flattened Device Tree)
> [    7.267512] [<c0015afc>] (unwind_backtrace) from [<c001221c>] (show_stack+0x10/0x14)
> [    7.275651] [<c001221c>] (show_stack) from [<c058972c>] (dump_stack+0x84/0x9c)
> [    7.283249] [<c058972c>] (dump_stack) from [<c003def0>] (warn_slowpath_common+0x78/0xb4)
> [    7.291750] [<c003def0>] (warn_slowpath_common) from [<c003dfc8>] (warn_slowpath_null+0x1c/0x24)
> [    7.300977] [<c003dfc8>] (warn_slowpath_null) from [<c0133410>] (exit_mmap+0x1b4/0x218)
> [    7.309376] [<c0133410>] (exit_mmap) from [<c003b5f0>] (mmput+0x44/0xec)
> [    7.316385] [<c003b5f0>] (mmput) from [<c0157e68>] (flush_old_exec+0x264/0x5d4)
> [    7.324061] [<c0157e68>] (flush_old_exec) from [<c019f180>] (load_elf_binary+0x288/0x1234)
> [    7.332727] [<c019f180>] (load_elf_binary) from [<c0158304>] (search_binary_handler+0x84/0x1e8)
> [    7.341857] [<c0158304>] (search_binary_handler) from [<c0158c84>] (do_execveat_common+0x53c/0x6b8)
> [    7.351346] [<c0158c84>] (do_execveat_common) from [<c0158e24>] (do_execve+0x24/0x2c)
> [    7.359561] [<c0158e24>] (do_execve) from [<c000e6c0>] (ret_fast_syscall+0x0/0x4c)
> [    7.367485] ---[ end trace 633a89eb76b1d46e ]---
> [    7.372360] mm ed29fa00 mmap ed29b6b8 seqnum 0 task_size 3204448256
> [    7.372360] get_unmapped_area c001cfc0
> [    7.372360] mmap_base 3069620224 mmap_legacy_base 0 highest_vm_end 3202711552
> [    7.372360] pgd ed184000 mm_users 0 mm_count 1 nr_ptes 1 nr_pmds 4294967292 map_count 59
> [    7.372360] hiwater_rss 37 hiwater_vm 37e total_vm 37e locked_vm 0
> [    7.372360] pinned_vm 0 shared_vm 324 exec_vm 254 stack_vm 22
> [    7.372360] start_code 10000 end_code c9d48 start_data da1b8 end_data ea1a4
> [    7.372360] start_brk eb000 brk 10c000 start_stack becd5f10
> [    7.372360] arg_start becd5fd4 arg_end becd5fdf env_start becd5fdf env_end becd5ff1
> [    7.372360] binfmt c08b3158 flags cd core_state   (null)
> [    7.372360] ioctx_table   (null)
> [    7.372360] owner   (null) exe_file ee49d040
> [    7.372360] tlb_flush_pending 0
> [    7.448908] flags: 0x0()
> 
> Looking at nr_pmds, that's basically (unsigned long) -4, which tells me
> we are decrementing mm->nr_pmds without incrementing first. In, when I
> add:
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ba5f3bcca55d..8425fb419eab 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1440,11 +1440,15 @@ static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
>  static inline void mm_inc_nr_pmds(struct mm_struct *mm)
>  {
>  	atomic_long_inc(&mm->nr_pmds);
> +	printk(KERN_INFO "===> %s nr_pmds %ld\n", __func__,
> +			atomic_long_read(&mm->nr_pmds));
>  }
>  
>  static inline void mm_dec_nr_pmds(struct mm_struct *mm)
>  {
>  	atomic_long_dec(&mm->nr_pmds);
> +	printk(KERN_INFO "===> %s nr_pmds %ld\n", __func__,
> +			atomic_long_read(&mm->nr_pmds));
>  }
>  #endif
> 
> I start getting:
> 
> [...]
> 
> [    5.935390] ===> mm_dec_nr_pmds nr_pmds -1
> [    6.236832] random: systemd urandom read with 34 bits of entropy
> available
> [    6.276340] systemd[1]: systemd 215 running in system mode. (+PAM
> +AUDIT +SELINUX +IMA +SYSVINIT +LIBC
> RYPTSETUP +GCRYPT +ACL +XZ -SECCOMP -APPARMOR)
> [    6.291380] systemd[1]: Detected architecture 'arm'.
> 
> Welcome to Debian GNU/Linux 8 (jessie)!
> 
> [    6.434013] systemd[1]: Inserted module 'autofs4'
> [    7.152037] NET: Registered protocol family 10
> [    7.165770] systemd[1]: Inserted module 'ipv6'
> [    7.170646] ===> mm_dec_nr_pmds nr_pmds -2
> [    7.174932] ===> mm_dec_nr_pmds nr_pmds -3
> [    7.179427] ===> mm_dec_nr_pmds nr_pmds -4
> [    7.258496] ===> mm_dec_nr_pmds nr_pmds -1
> [    7.262809] ===> mm_dec_nr_pmds nr_pmds -2
> [    7.267206] ===> mm_dec_nr_pmds nr_pmds -3
> [    7.271486] ===> mm_dec_nr_pmds nr_pmds -4
> [    7.275884] ------------[ cut here ]------------
> [    7.280773] WARNING: CPU: 0 PID: 58 at mm/mmap.c:2859 exit_mmap+0x1b4/0x218()
> 
> [...]
> 
> Which confirms my suspicion. So we never increment nr_pmds, but we
> decrement it. The simplest "fix" is to make mm_nr_pmds() return a signed
> long (see below) and cast roundup()'s return to (signed long), but
> that's not what we really want in this case because it's clear our PMD
> accounting is bogus.
> 
> Kiryl, any better idea on how to balance mm_inc_nr_pmds() and
> mm_dec_nr_pmds() ?

I assume it's on !LPAE kernel, right?

I did a quick look. ARM has folded PMD level in case of 2-level pages
tables, but it doesn't use standard approach -- pgtable-nopmd.h.
As result ARM doesn't have __PAGETABLE_PMD_FOLDED defined.

I will look further tomorrow, but I wounder if we can just define
__PAGETABLE_PMD_FOLDED in arch/arm/include/asm/pgtable-2level.h ?

This way we would also get rid of dead code -- __pmd_alloc() is never
called in this configuration. And fix the accounting issue: mm_*_nr_pmd()
helpers will become nop.

Better option would be converting 2-lvl ARM configuration to
<asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
