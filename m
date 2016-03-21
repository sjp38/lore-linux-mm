Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 15C776B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:37:49 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id x3so260215922pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 03:37:49 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d27si18964009pfj.14.2016.03.21.03.37.47
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 03:37:48 -0700 (PDT)
Date: Mon, 21 Mar 2016 10:38:07 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: arch/ia64/kernel/entry.S:621: Error: Operand 2 of `adds' should
 be a 14-bit integer (-8192-8191)
Message-ID: <20160321103807.GB23397@arm.com>
References: <201603210433.xQKD3eNU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603210433.xQKD3eNU%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Mar 21, 2016 at 04:03:50AM +0800, kbuild test robot wrote:
> Hi Will,
> 
> FYI, the error/warning still remains.

... as does my patch to fix it [1]

Will

[1] http://lkml.kernel.org/r/1457541344-16961-1-git-send-email-will.deacon@arm.com

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   1e75a9f34a5ed5902707fb74b468356c55142b71
> commit: da48d094ce5d7c7dcdad9011648a81c42fd1c2ef Kconfig: remove HAVE_LATENCYTOP_SUPPORT
> date:   9 weeks ago
> config: ia64-allmodconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout da48d094ce5d7c7dcdad9011648a81c42fd1c2ef
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/ia64/kernel/entry.S: Assembler messages:
> >> arch/ia64/kernel/entry.S:621: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
>    arch/ia64/kernel/entry.S:728: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
>    arch/ia64/kernel/entry.S:859: Error: Operand 2 of `adds' should be a 14-bit integer (-8192-8191)
> --
>    arch/ia64/kernel/fsys.S: Assembler messages:
> >> arch/ia64/kernel/fsys.S:67: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:97: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:193: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:336: Error: Operand 3 of `add' should be a general register r0-r3
>    arch/ia64/kernel/fsys.S:338: Error: Operand 3 of `add' should be a general register r0-r3
> --
>    arch/ia64/kernel/ivt.S: Assembler messages:
> >> arch/ia64/kernel/ivt.S:759: Error: Operand 3 of `add' should be a general register r0-r3
> 
> vim +621 arch/ia64/kernel/entry.S
> 
> ^1da177e Linus Torvalds 2005-04-16  605  	PT_REGS_UNWIND_INFO(0)
> ^1da177e Linus Torvalds 2005-04-16  606  {	/*
> ^1da177e Linus Torvalds 2005-04-16  607  	 * Some versions of gas generate bad unwind info if the first instruction of a
> ^1da177e Linus Torvalds 2005-04-16  608  	 * procedure doesn't go into the first slot of a bundle.  This is a workaround.
> ^1da177e Linus Torvalds 2005-04-16  609  	 */
> ^1da177e Linus Torvalds 2005-04-16  610  	nop.m 0
> ^1da177e Linus Torvalds 2005-04-16  611  	nop.i 0
> ^1da177e Linus Torvalds 2005-04-16  612  	/*
> ^1da177e Linus Torvalds 2005-04-16  613  	 * We need to call schedule_tail() to complete the scheduling process.
> ^1da177e Linus Torvalds 2005-04-16  614  	 * Called by ia64_switch_to() after do_fork()->copy_thread().  r8 contains the
> ^1da177e Linus Torvalds 2005-04-16  615  	 * address of the previously executing task.
> ^1da177e Linus Torvalds 2005-04-16  616  	 */
> ^1da177e Linus Torvalds 2005-04-16  617  	br.call.sptk.many rp=ia64_invoke_schedule_tail
> ^1da177e Linus Torvalds 2005-04-16  618  }
> ^1da177e Linus Torvalds 2005-04-16  619  .ret8:
> 54d496c3 Al Viro        2012-10-14  620  (pKStk)	br.call.sptk.many rp=call_payload
> ^1da177e Linus Torvalds 2005-04-16 @621  	adds r2=TI_FLAGS+IA64_TASK_SIZE,r13
> ^1da177e Linus Torvalds 2005-04-16  622  	;;
> ^1da177e Linus Torvalds 2005-04-16  623  	ld4 r2=[r2]
> ^1da177e Linus Torvalds 2005-04-16  624  	;;
> ^1da177e Linus Torvalds 2005-04-16  625  	mov r8=0
> ^1da177e Linus Torvalds 2005-04-16  626  	and r2=_TIF_SYSCALL_TRACEAUDIT,r2
> ^1da177e Linus Torvalds 2005-04-16  627  	;;
> ^1da177e Linus Torvalds 2005-04-16  628  	cmp.ne p6,p0=r2,r0
> ^1da177e Linus Torvalds 2005-04-16  629  (p6)	br.cond.spnt .strace_check_retval
> 
> :::::: The code at line 621 was first introduced by commit
> :::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
> 
> :::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
> :::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
