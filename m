Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB7316B0005
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 00:18:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so5240027plp.21
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 21:18:59 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j12-v6si20593369pgq.312.2018.06.07.21.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 21:18:58 -0700 (PDT)
Date: Fri, 8 Jun 2018 12:18:22 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/9] x86/cet: Control protection exception handler
Message-ID: <201806081216.5vaA5ieM%fengguang.wu@intel.com>
References: <20180607143705.3531-2-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Content-Disposition: inline
In-Reply-To: <20180607143705.3531-2-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yu-cheng,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on asm-generic/master]
[also build test ERROR on v4.17 next-20180607]
[cannot apply to tip/x86/core mmotm/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yu-cheng-Yu/Control-Flow-Enforcement-Part-2/20180608-111152
base:   https://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from arch/x86/include/asm/thread_info.h:53:0,
                    from include/linux/thread_info.h:38,
                    from arch/x86/include/asm/preempt.h:7,
                    from include/linux/preempt.h:81,
                    from include/linux/rcupdate.h:40,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from include/linux/context_tracking.h:5,
                    from arch/x86/kernel/traps.c:15:
   arch/x86/kernel/traps.c: In function 'do_control_protection':
>> arch/x86/kernel/traps.c:605:27: error: 'X86_FEATURE_SHSTK' undeclared (first use in this function); did you mean 'X86_FEATURE_EST'?
     if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
                              ^
   arch/x86/include/asm/cpufeature.h:127:24: note: in definition of macro 'cpu_feature_enabled'
     (__builtin_constant_p(bit) && DISABLED_MASK_BIT_SET(bit) ? 0 : static_cpu_has(bit))
                           ^~~
   arch/x86/kernel/traps.c:605:27: note: each undeclared identifier is reported only once for each function it appears in
     if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
                              ^
   arch/x86/include/asm/cpufeature.h:127:24: note: in definition of macro 'cpu_feature_enabled'
     (__builtin_constant_p(bit) && DISABLED_MASK_BIT_SET(bit) ? 0 : static_cpu_has(bit))
                           ^~~
>> arch/x86/kernel/traps.c:606:27: error: 'X86_FEATURE_IBT' undeclared (first use in this function); did you mean 'X86_FEATURE_IBS'?
         !cpu_feature_enabled(X86_FEATURE_IBT)) {
                              ^
   arch/x86/include/asm/cpufeature.h:127:24: note: in definition of macro 'cpu_feature_enabled'
     (__builtin_constant_p(bit) && DISABLED_MASK_BIT_SET(bit) ? 0 : static_cpu_has(bit))
                           ^~~

vim +605 arch/x86/kernel/traps.c

   589	
   590	/*
   591	 * When a control protection exception occurs, send a signal
   592	 * to the responsible application.  Currently, control
   593	 * protection is only enabled for the user mode.  This
   594	 * exception should not come from the kernel mode.
   595	 */
   596	dotraplinkage void
   597	do_control_protection(struct pt_regs *regs, long error_code)
   598	{
   599		struct task_struct *tsk;
   600	
   601		RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
   602		cond_local_irq_enable(regs);
   603	
   604		tsk = current;
 > 605		if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
 > 606		    !cpu_feature_enabled(X86_FEATURE_IBT)) {
   607			goto exit;
   608		}
   609	
   610		if (!user_mode(regs)) {
   611			tsk->thread.error_code = error_code;
   612			tsk->thread.trap_nr = X86_TRAP_CP;
   613			if (notify_die(DIE_TRAP, "control protection fault", regs,
   614				       error_code, X86_TRAP_CP, SIGSEGV) != NOTIFY_STOP)
   615				die("control protection fault", regs, error_code);
   616			return;
   617		}
   618	
   619		tsk->thread.error_code = error_code;
   620		tsk->thread.trap_nr = X86_TRAP_CP;
   621	
   622		if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
   623		    printk_ratelimit()) {
   624			unsigned int max_idx, err_idx;
   625	
   626			max_idx = ARRAY_SIZE(control_protection_err) - 1;
   627			err_idx = min((unsigned int)error_code - 1, max_idx);
   628			pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
   629				tsk->comm, task_pid_nr(tsk),
   630				regs->ip, regs->sp, error_code,
   631				control_protection_err[err_idx]);
   632			print_vma_addr(" in ", regs->ip);
   633			pr_cont("\n");
   634		}
   635	
   636	exit:
   637		force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);
   638	}
   639	NOKPROBE_SYMBOL(do_control_protection);
   640	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--pf9I7BMVVzbSWLtt
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
F0/njkA8JpDswTBmN+L4/Ad5PGBNS2AAAA==

--pf9I7BMVVzbSWLtt--
