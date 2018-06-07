Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77DF26B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 13:50:05 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so5730679pld.23
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 10:50:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v65-v6si541046pfb.324.2018.06.07.10.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 10:50:04 -0700 (PDT)
Message-ID: <1528393611.4636.70.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 01/10] x86/cet: User-mode shadow stack support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 10:46:51 -0700
In-Reply-To: <CALCETrX4ALKbphJiZs4MXWtRFvQYD905bNAMTogbOeLh0Pp6xw@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-2-yu-cheng.yu@intel.com>
	 <CALCETrX4ALKbphJiZs4MXWtRFvQYD905bNAMTogbOeLh0Pp6xw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 09:37 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > This patch adds basic shadow stack enabling/disabling routines.
> > A task's shadow stack is allocated from memory with VM_SHSTK
> > flag set and read-only protection.  The shadow stack is
> > allocated to a fixed size and that can be changed by the system
> > admin.
> 
> How do threads work?  Can a user program mremap() its shadow stack to
> make it bigger?

A pthread's shadow stack is allocated/freed by the kernel.  This patch
has the supporting routines that handle both non-pthread and pthread.

In [PATCH 04/10] "Handle thread shadow stack", we allocate pthread
shadow stack in copy_thread_tls(), and free it in deactivate_mm().

If clone of a pthread fails, shadow stack is freed in
cet_disable_free_shstk() below (I will add more comments):

If (Current thread existing)
	Disable and free shadow stack

If (Clone of a pthread fails)
	Free the pthread shadow stack

We block mremap, mprotect, madvise, and munmap on a vma that has
VM_SHSTK (in separate patches).

> Also, did you add all the needed checks to make get_user_pages(),
> access_process_vm(), etc fail when called on the shadow stack?  (Or at
> least fail if they're requesting write access and the FORCE bit isn't
> set.)

Currently if FORCE bit is set, these functions can write to shadow
stack, otherwise write access will fail.  I will test it.

> > +#define SHSTK_SIZE (0x8000 * (test_thread_flag(TIF_IA32) ? 4 : 8))
> 
> Please don't add more mode-dependent #defines.  Also, please try to
> avoid adding any new code that looks at TIF_IA32 or similar.  Uses of
> that bit are generally bugs, and the bit itself should get removed
> some day.  If you need to make a guess, use in_compat_syscall() or
> similar if appropriate.

OK.

> 
> > +
> > +static inline int cet_set_shstk_ptr(unsigned long addr)
> > +{
> > +       u64 r;
> > +
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +               return -1;
> > +
> > +       if ((addr >= TASK_SIZE) || (!IS_ALIGNED(addr, 4)))
> > +               return -1;'
> 
> TASK_SIZE_MAX, please.  TASK_SIZE is weird and is usually the wrong
> thing to use.

OK.

> 
> > +static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
> > +{
> > +       struct mm_struct *mm = current->mm;
> > +       unsigned long populate;
> > +
> > +       down_write(&mm->mmap_sem);
> > +       addr = do_mmap(NULL, addr, len, PROT_READ,
> > +                      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
> > +                      0, &populate, NULL);
> > +       up_write(&mm->mmap_sem);
> > +
> > +       if (populate)
> > +               mm_populate(addr, populate);
> 
> Please don't populate if do_mmap() failed.

I will fix it.

> 
> > +int cet_setup_shstk(void)
> > +{
> > +       unsigned long addr, size;
> > +
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +               return -EOPNOTSUPP;
> > +
> > +       size = SHSTK_SIZE;
> > +       addr = shstk_mmap(0, size);
> > +
> > +       if (addr >= TASK_SIZE)
> > +               return -ENOMEM;
> 
> Please check the actual value that do_mmap() would return on error.
> (IS_ERR, 0, MAP_FAILED -- I don't remember.)

OK.

> 
> > +
> > +       cet_set_shstk_ptr(addr + size - sizeof(void *));
> > +       current->thread.cet.shstk_base = addr;
> > +       current->thread.cet.shstk_size = size;
> > +       current->thread.cet.shstk_enabled = 1;
> > +       return 0;
> > +}
> > +
> > +void cet_disable_shstk(void)
> > +{
> > +       u64 r;
> > +
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +               return;
> > +
> > +       rdmsrl(MSR_IA32_U_CET, r);
> > +       r &= ~(MSR_IA32_CET_SHSTK_EN);
> > +       wrmsrl(MSR_IA32_U_CET, r);
> > +       wrmsrl(MSR_IA32_PL3_SSP, 0);
> > +       current->thread.cet.shstk_enabled = 0;
> > +}
> > +
> > +void cet_disable_free_shstk(struct task_struct *tsk)
> > +{
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK) ||
> > +           !tsk->thread.cet.shstk_enabled)
> > +               return;
> > +
> > +       if (tsk == current)
> > +               cet_disable_shstk();
> 
> if tsk != current, then this will malfunction, right?  What is it
> intended to do?

We get here when clone fails.  In this condition, we don't disable the
calling task's shadow stack.  I will add comments.

> 
> > +
> > +       /*
> > +        * Free only when tsk is current or shares mm
> > +        * with current but has its own shstk.
> > +        */
> > +       if (tsk->mm && (tsk->mm == current->mm) &&
> > +           (tsk->thread.cet.shstk_base)) {
> > +               vm_munmap(tsk->thread.cet.shstk_base,
> > +                         tsk->thread.cet.shstk_size);
> > +               tsk->thread.cet.shstk_base = 0;
> > +               tsk->thread.cet.shstk_size = 0;
> > +       }
> 
> I'm having trouble imagining why the kernel would ever want to
> automatically free the shadow stack vma.  What is this for?

This is for pthreads.  When a pthread exits, its shadow stack needs to
be freed.
