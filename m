Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28D286B04C6
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 15:10:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so218384067pgr.6
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 12:10:13 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id o29si5731221pli.228.2017.08.19.12.10.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 12:10:12 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
	<1500177424-13695-36-git-send-email-linuxram@us.ibm.com>
Date: Sat, 19 Aug 2017 14:09:58 -0500
In-Reply-To: <1500177424-13695-36-git-send-email-linuxram@us.ibm.com> (Ram
	Pai's message of "Sat, 15 Jul 2017 20:56:37 -0700")
Message-ID: <87d17rnzll.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC v6 35/62] powerpc: Deliver SEGV signal on pkey violation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
> index d4e545d..fe1e7c7 100644
> --- a/arch/powerpc/kernel/traps.c
> +++ b/arch/powerpc/kernel/traps.c
> @@ -20,6 +20,7 @@
>  #include <linux/sched/debug.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> +#include <linux/pkeys.h>
>  #include <linux/stddef.h>
>  #include <linux/unistd.h>
>  #include <linux/ptrace.h>
> @@ -247,6 +248,15 @@ void user_single_step_siginfo(struct task_struct *tsk,
>  	info->si_addr = (void __user *)regs->nip;
>  }
>  
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +static void fill_sig_info_pkey(int si_code, siginfo_t *info, unsigned long addr)
> +{
> +	if (si_code != SEGV_PKUERR)
> +		return;

Given that SEGV_PKUERR is a signal specific si_code this test is
insufficient to detect an pkey error.  You also need to check
that signr == SIGSEGV

> +	info->si_pkey = get_paca()->paca_pkey;
> +}
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> +
>  void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
>  {
>  	siginfo_t info;
> @@ -274,6 +284,11 @@ void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
>  	info.si_signo = signr;
>  	info.si_code = code;
>  	info.si_addr = (void __user *) addr;
> +
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +	fill_sig_info_pkey(code, &info, addr);
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> +
>  	force_sig_info(signr, &info, current);
>  }

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
