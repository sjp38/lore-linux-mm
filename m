Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8A96B000D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 20:11:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u18-v6so14975981pfh.21
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 17:11:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h8-v6si17254336pgr.379.2018.07.10.17.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 17:11:45 -0700 (PDT)
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-23-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
Date: Tue, 10 Jul 2018 17:11:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-23-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

Is this feature *integral* to shadow stacks?  Or, should it just be in a
different series?

> diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
> index d9ae3d86cdd7..71da2cccba16 100644
> --- a/arch/x86/include/asm/cet.h
> +++ b/arch/x86/include/asm/cet.h
> @@ -12,7 +12,10 @@ struct task_struct;
>  struct cet_status {
>  	unsigned long	shstk_base;
>  	unsigned long	shstk_size;
> +	unsigned long	ibt_bitmap_addr;
> +	unsigned long	ibt_bitmap_size;
>  	unsigned int	shstk_enabled:1;
> +	unsigned int	ibt_enabled:1;
>  };

Is there a reason we're not using pointers here?  This seems like the
kind of place that we probably want __user pointers.


> +static unsigned long ibt_mmap(unsigned long addr, unsigned long len)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long populate;
> +
> +	down_write(&mm->mmap_sem);
> +	addr = do_mmap(NULL, addr, len, PROT_READ | PROT_WRITE,
> +		       MAP_ANONYMOUS | MAP_PRIVATE,
> +		       VM_DONTDUMP, 0, &populate, NULL);
> +	up_write(&mm->mmap_sem);
> +
> +	if (populate)
> +		mm_populate(addr, populate);
> +
> +	return addr;
> +}

We're going to have to start consolidating these at some point.  We have
at least three of them now, maybe more.

> +int cet_setup_ibt_bitmap(void)
> +{
> +	u64 r;
> +	unsigned long bitmap;
> +	unsigned long size;
> +
> +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> +		return -EOPNOTSUPP;
> +
> +	size = TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE;

Just a note: this table is going to be gigantic on 5-level paging
systems, and userspace won't, by default use any of that extra address
space.  I think it ends up being a 512GB allocation in a 128TB address
space.

Is that a problem?

On 5-level paging systems, maybe we should just stick it up in the high
part of the address space.

> +	bitmap = ibt_mmap(0, size);
> +
> +	if (bitmap >= TASK_SIZE_MAX)
> +		return -ENOMEM;
> +
> +	bitmap &= PAGE_MASK;

We're page-aligning the result of an mmap()?  Why?

> +	rdmsrl(MSR_IA32_U_CET, r);
> +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> +	wrmsrl(MSR_IA32_U_CET, r);

Comments, please.  What is this doing, logically?  Also, why are we
OR'ing the results into this MSR?  What are we trying to preserve?

> +	current->thread.cet.ibt_bitmap_addr = bitmap;
> +	current->thread.cet.ibt_bitmap_size = size;
> +	return 0;
> +}
> +
> +void cet_disable_ibt(void)
> +{
> +	u64 r;
> +
> +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> +		return;

Does this need a check for being already disabled?

> +	rdmsrl(MSR_IA32_U_CET, r);
> +	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN |
> +	       MSR_IA32_CET_NO_TRACK_EN);
> +	wrmsrl(MSR_IA32_U_CET, r);
> +	current->thread.cet.ibt_enabled = 0;
> +}

What's the locking for current->thread.cet?

> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index 705467839ce8..c609c9ce5691 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -413,7 +413,8 @@ __setup("nopku", setup_disable_pku);
>  
>  static __always_inline void setup_cet(struct cpuinfo_x86 *c)
>  {
> -	if (cpu_feature_enabled(X86_FEATURE_SHSTK))
> +	if (cpu_feature_enabled(X86_FEATURE_SHSTK) ||
> +	    cpu_feature_enabled(X86_FEATURE_IBT))
>  		cr4_set_bits(X86_CR4_CET);
>  }
>  
> @@ -434,6 +435,23 @@ static __init int setup_disable_shstk(char *s)
>  __setup("no_cet_shstk", setup_disable_shstk);
>  #endif
>  
> +#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
> +static __init int setup_disable_ibt(char *s)
> +{
> +	/* require an exact match without trailing characters */
> +	if (strlen(s))
> +		return 0;
> +
> +	if (!boot_cpu_has(X86_FEATURE_IBT))
> +		return 1;
> +
> +	setup_clear_cpu_cap(X86_FEATURE_IBT);
> +	pr_info("x86: 'no_cet_ibt' specified, disabling Branch Tracking\n");
> +	return 1;
> +}
> +__setup("no_cet_ibt", setup_disable_ibt);
> +#endif
>  /*
>   * Some CPU features depend on higher CPUID levels, which may not always
>   * be available due to CPUID level capping or broken virtualization
> diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> index 233f6dad9c1f..42e08d3b573e 100644
> --- a/arch/x86/kernel/elf.c
> +++ b/arch/x86/kernel/elf.c
> @@ -15,6 +15,7 @@
>  #include <linux/fs.h>
>  #include <linux/uaccess.h>
>  #include <linux/string.h>
> +#include <linux/compat.h>
>  
>  /*
>   * The .note.gnu.property layout:
> @@ -222,7 +223,8 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
>  
>  	struct elf64_hdr *ehdr64 = ehdr_p;
>  
> -	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> +	    !cpu_feature_enabled(X86_FEATURE_IBT))
>  		return 0;
>  
>  	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> @@ -250,6 +252,9 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
>  	current->thread.cet.shstk_enabled = 0;
>  	current->thread.cet.shstk_base = 0;
>  	current->thread.cet.shstk_size = 0;
> +	current->thread.cet.ibt_enabled = 0;
> +	current->thread.cet.ibt_bitmap_addr = 0;
> +	current->thread.cet.ibt_bitmap_size = 0;
>  	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
>  		if (shstk) {
>  			err = cet_setup_shstk();
> @@ -257,6 +262,15 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
>  				goto out;
>  		}
>  	}
> +
> +	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
> +		if (ibt) {
> +			err = cet_setup_ibt();
> +			if (err < 0)
> +				goto out;
> +		}
> +	}

You introduced 'ibt' before it was used.  Please wait to introduce it
until you actually use it to make it easier to review.

Also, what's wrong with:

	if (cpu_feature_enabled(X86_FEATURE_IBT) && ibt) {
		...
	}

?
