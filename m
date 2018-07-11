Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9FCC6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:14:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n19-v6so1465469pgv.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:14:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y67-v6si12847354pfa.47.2018.07.11.15.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 15:13:58 -0700 (PDT)
Message-ID: <1531347019.15351.89.camel@intel.com>
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 15:10:19 -0700
In-Reply-To: <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-23-yu-cheng.yu@intel.com>
	 <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-07-10 at 17:11 -0700, Dave Hansen wrote:
> Is this feature *integral* to shadow stacks?A A Or, should it just be
> in a
> different series?

The whole CET series is mostly about SHSTK and only a minority for IBT.
IBT changes cannot be applied by itself without first applying SHSTK
changes. A Would the titles help, e.g. x86/cet/ibt, x86/cet/shstk, etc.?

> 
> > 
> > diff --git a/arch/x86/include/asm/cet.h
> > b/arch/x86/include/asm/cet.h
> > index d9ae3d86cdd7..71da2cccba16 100644
> > --- a/arch/x86/include/asm/cet.h
> > +++ b/arch/x86/include/asm/cet.h
> > @@ -12,7 +12,10 @@ struct task_struct;
> > A struct cet_status {
> > A 	unsigned long	shstk_base;
> > A 	unsigned long	shstk_size;
> > +	unsigned long	ibt_bitmap_addr;
> > +	unsigned long	ibt_bitmap_size;
> > A 	unsigned int	shstk_enabled:1;
> > +	unsigned int	ibt_enabled:1;
> > A };
> Is there a reason we're not using pointers here?A A This seems like the
> kind of place that we probably want __user pointers.

Yes, I will change that.

> 
> 
> > 
> > +static unsigned long ibt_mmap(unsigned long addr, unsigned long
> > len)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	unsigned long populate;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	addr = do_mmap(NULL, addr, len, PROT_READ | PROT_WRITE,
> > +		A A A A A A A MAP_ANONYMOUS | MAP_PRIVATE,
> > +		A A A A A A A VM_DONTDUMP, 0, &populate, NULL);
> > +	up_write(&mm->mmap_sem);
> > +
> > +	if (populate)
> > +		mm_populate(addr, populate);
> > +
> > +	return addr;
> > +}
> We're going to have to start consolidating these at some point.A A We
> have
> at least three of them now, maybe more.

Maybe we can do the following in linux/mm.h?

+static inline unsigned long do_mmap_locked(addr, len, prot,
+					A  A  flags, vm_flags)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long populate;
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap(NULL, addr, len, prot, flags, vm_flags,
+		A  A  A  A 0, &populate, NULL);
+	up_write(&mm->mmap_sem);
+
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
+}A 

> > 
> > +int cet_setup_ibt_bitmap(void)
> > +{
> > +	u64 r;
> > +	unsigned long bitmap;
> > +	unsigned long size;
> > +
> > +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > +		return -EOPNOTSUPP;
> > +
> > +	size = TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE;
> Just a note: this table is going to be gigantic on 5-level paging
> systems, and userspace won't, by default use any of that extra
> address
> space.A A I think it ends up being a 512GB allocation in a 128TB
> address
> space.
> 
> Is that a problem?
>
> On 5-level paging systems, maybe we should just stick it up in the
> high
> part of the address space.

We do not know in advance if dlopen() needs to create the bitmap. A Do
we always reserve high address or force legacy libs to low address?

> 
> > 
> > +	bitmap = ibt_mmap(0, size);
> > +
> > +	if (bitmap >= TASK_SIZE_MAX)
> > +		return -ENOMEM;
> > +
> > +	bitmap &= PAGE_MASK;
> We're page-aligning the result of an mmap()?A A Why?

This may not be necessary. A The lower bits of MSR_IA32_U_CET are
settings and not part of the bitmap address. A Is this is safer?

> 
> > 
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> > +	wrmsrl(MSR_IA32_U_CET, r);
> Comments, please.A A What is this doing, logically?A A Also, why are we
> OR'ing the results into this MSR?A A What are we trying to preserve?

I will add comments.

> 
> > 
> > +	current->thread.cet.ibt_bitmap_addr = bitmap;
> > +	current->thread.cet.ibt_bitmap_size = size;
> > +	return 0;
> > +}
> > +
> > +void cet_disable_ibt(void)
> > +{
> > +	u64 r;
> > +
> > +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > +		return;
> Does this need a check for being already disabled?

We need that. A We cannot write to those MSRs if the CPU does not
support it.

> 
> > 
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN |
> > +	A A A A A A A MSR_IA32_CET_NO_TRACK_EN);
> > +	wrmsrl(MSR_IA32_U_CET, r);
> > +	current->thread.cet.ibt_enabled = 0;
> > +}
> What's the locking for current->thread.cet?

Now CET is not locked until the application callsA ARCH_CET_LOCK.

> 
> > 
> > diff --git a/arch/x86/kernel/cpu/common.c
> > b/arch/x86/kernel/cpu/common.c
> > index 705467839ce8..c609c9ce5691 100644
> > --- a/arch/x86/kernel/cpu/common.c
> > +++ b/arch/x86/kernel/cpu/common.c
> > @@ -413,7 +413,8 @@ __setup("nopku", setup_disable_pku);
> > A 
> > A static __always_inline void setup_cet(struct cpuinfo_x86 *c)
> > A {
> > -	if (cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +	if (cpu_feature_enabled(X86_FEATURE_SHSTK) ||
> > +	A A A A cpu_feature_enabled(X86_FEATURE_IBT))
> > A 		cr4_set_bits(X86_CR4_CET);
> > A }
> > A 
> > @@ -434,6 +435,23 @@ static __init int setup_disable_shstk(char *s)
> > A __setup("no_cet_shstk", setup_disable_shstk);
> > A #endif
> > A 
> > +#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
> > +static __init int setup_disable_ibt(char *s)
> > +{
> > +	/* require an exact match without trailing characters */
> > +	if (strlen(s))
> > +		return 0;
> > +
> > +	if (!boot_cpu_has(X86_FEATURE_IBT))
> > +		return 1;
> > +
> > +	setup_clear_cpu_cap(X86_FEATURE_IBT);
> > +	pr_info("x86: 'no_cet_ibt' specified, disabling Branch
> > Tracking\n");
> > +	return 1;
> > +}
> > +__setup("no_cet_ibt", setup_disable_ibt);
> > +#endif
> > A /*
> > A  * Some CPU features depend on higher CPUID levels, which may not
> > always
> > A  * be available due to CPUID level capping or broken
> > virtualization
> > diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> > index 233f6dad9c1f..42e08d3b573e 100644
> > --- a/arch/x86/kernel/elf.c
> > +++ b/arch/x86/kernel/elf.c
> > @@ -15,6 +15,7 @@
> > A #include <linux/fs.h>
> > A #include <linux/uaccess.h>
> > A #include <linux/string.h>
> > +#include <linux/compat.h>
> > A 
> > A /*
> > A  * The .note.gnu.property layout:
> > @@ -222,7 +223,8 @@ int arch_setup_features(void *ehdr_p, void
> > *phdr_p,
> > A 
> > A 	struct elf64_hdr *ehdr64 = ehdr_p;
> > A 
> > -	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> > +	A A A A !cpu_feature_enabled(X86_FEATURE_IBT))
> > A 		return 0;
> > A 
> > A 	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> > @@ -250,6 +252,9 @@ int arch_setup_features(void *ehdr_p, void
> > *phdr_p,
> > A 	current->thread.cet.shstk_enabled = 0;
> > A 	current->thread.cet.shstk_base = 0;
> > A 	current->thread.cet.shstk_size = 0;
> > +	current->thread.cet.ibt_enabled = 0;
> > +	current->thread.cet.ibt_bitmap_addr = 0;
> > +	current->thread.cet.ibt_bitmap_size = 0;
> > A 	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
> > A 		if (shstk) {
> > A 			err = cet_setup_shstk();
> > @@ -257,6 +262,15 @@ int arch_setup_features(void *ehdr_p, void
> > *phdr_p,
> > A 				goto out;
> > A 		}
> > A 	}
> > +
> > +	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
> > +		if (ibt) {
> > +			err = cet_setup_ibt();
> > +			if (err < 0)
> > +				goto out;
> > +		}
> > +	}
> You introduced 'ibt' before it was used.A A Please wait to introduce it
> until you actually use it to make it easier to review.
> 
> Also, what's wrong with:
> 
> 	if (cpu_feature_enabled(X86_FEATURE_IBT) && ibt) {
> 		...
> 	}
> 
> ?

I will fix it.
